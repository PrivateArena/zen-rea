class_name RoMinimap
extends Control








const SIZE: = 128.0
const ARROW: = Color(1.0, 0.15, 0.1)
const BOSS_DOT: = Color(1.0, 0.25, 0.25)
const ELITE_DOT: = Color(1.0, 0.75, 0.2)
const CHEST_DOT: = Color(1.0, 0.85, 0.2)
const ZOOMS: = [1.0, 2.0, 3.0]

var world: World
var _tex: Texture2D
var _map_name: = ""
var placeholder: = false

var zoom: = 1.0
var _view: = Rect2(0, 0, 1, 1)


func _ready() -> void :
	custom_minimum_size = Vector2(SIZE, SIZE)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = tr("Clic o rueda: zoom del minimapa")
	zoom = float(Save.setting("minimap_zoom", 1.0))
	if not ZOOMS.has(zoom):
		zoom = 1.0


func _gui_input(event: InputEvent) -> void :
	if not (event is InputEventMouseButton and event.pressed):
		return
	var i: = ZOOMS.find(zoom)
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			i = (i + 1) % ZOOMS.size()
		MOUSE_BUTTON_WHEEL_UP:
			i = mini(i + 1, ZOOMS.size() - 1)
		MOUSE_BUTTON_WHEEL_DOWN:
			i = maxi(i - 1, 0)
		_:
			return
	accept_event()
	if ZOOMS[i] != zoom:
		zoom = ZOOMS[i]
		Save.set_setting("minimap_zoom", zoom)
		if world != null:
			world.play_sound("ui_click", 0.05, -8.0)


func _process(_delta: float) -> void :
	if world == null or world.map == null:
		return
	if world.map.map_name != _map_name:
		_map_name = world.map.map_name
		_load_texture()
	queue_redraw()


func _load_texture() -> void :
	var path: = "res://assets/ro/ui/map/%s.png" % _map_name
	if ResourceLoader.exists(path):
		_tex = load(path)
		placeholder = false
		_letterbox = _is_letterboxed(_tex)
		return
	_letterbox = false

	placeholder = true
	var m: = world.map
	var img: = Image.create(m.width, m.height, false, Image.FORMAT_RGBA8)
	for ty in m.height:
		for tx in m.width:
			var p: = Vector3(tx - m.width * 0.5 + 0.5, 0, m.height * 0.5 - ty - 0.5)
			img.set_pixel(tx, m.height - 1 - ty, Color(0.62, 0.72, 0.5) if m.is_walkable(p) else Color(0.3, 0.38, 0.3))
	_tex = ImageTexture.create_from_image(img)









var _letterbox: = false


func _is_letterboxed(tex: Texture2D) -> bool:
	var m: = world.map
	if m.width == m.height or m.width <= 0 or m.height <= 0:
		return false
	var img: = tex.get_image()
	if img == null or img.is_empty():
		return false
	if img.is_compressed():
		img.decompress()
	var iw: = img.get_width()
	var ih: = img.get_height()
	var s: = float(maxi(m.width, m.height))
	var hits: = [0, 0]
	for ty in range(1, m.height - 1, 3):
		for tx in range(1, m.width - 1, 3):
			if not m.cell_walkable(tx, ty):
				continue
			for k in 2:
				var uv: = Vector2((tx + 0.5) / m.width, 1.0 - (ty + 0.5) / m.height) if k == 0\
				else Vector2(((s - m.width) * 0.5 + tx + 0.5) / s, 1.0 - ((s - m.height) * 0.5 + ty + 0.5) / s)
				var c: = img.get_pixel(mini(iw - 1, int(uv.x * iw)), mini(ih - 1, int(uv.y * ih)))
				if c.a > 0.15 and c.r + c.g + c.b > 0.18:
					hits[k] += 1
	return hits[1] > hits[0]



func _uv(pos: Vector3) -> Vector2:
	var m: = world.map
	var tx: = pos.x + m.width * 0.5
	var ty: = m.height * 0.5 - pos.z
	if _letterbox:
		var s: = float(maxi(m.width, m.height))
		return Vector2(((s - m.width) * 0.5 + tx) / s, 1.0 - ((s - m.height) * 0.5 + ty) / s)
	return Vector2(tx / m.width, 1.0 - ty / m.height)



func to_minimap(pos: Vector3) -> Vector2:
	return (_uv(pos) - _view.position) / _view.size * SIZE




func _update_view() -> void :
	var span: = 1.0 / zoom
	if zoom <= 1.0 or world.player == null:
		_view = Rect2(0, 0, 1, 1)
		return
	var c: = _uv(world.player.position)
	var o: = Vector2(clampf(c.x - span * 0.5, 0.0, 1.0 - span), clampf(c.y - span * 0.5, 0.0, 1.0 - span))
	_view = Rect2(o, Vector2(span, span))




func _mark(pos: Vector3, keep: = false) -> Vector2:
	var p: = to_minimap(pos)
	if Rect2(Vector2.ZERO, Vector2(SIZE, SIZE)).has_point(p):
		return p.round()
	if not keep:
		return Vector2.INF
	return Vector2(clampf(p.x, 7.0, SIZE - 7.0), clampf(p.y, 7.0, SIZE - 7.0)).round()



func cell() -> Vector2i:
	var m: = world.map
	var p: = world.player.position
	return Vector2i(floori(p.x + m.width * 0.5), floori(m.height * 0.5 - p.z))



const PARTY_DOT: = Color(0.5, 0.85, 1.0)




const ALTAR_LOOK: = {
	"odin": ["triangle", Color(0.9, 0.93, 1.0)], 
	"thor": ["bolt", Color(0.3, 0.58, 1.0)], 
	"freyja": ["heart", Color(1.0, 0.52, 0.2)], 
	"emperium": ["diamond", Color(1.0, 0.86, 0.22)], 
	"baldur": ["sun", Color(1.0, 0.97, 0.7)], 
	"loki": ["triangle_down", Color(0.62, 0.95, 0.18)], 
	"yggdrasil": ["leaf", Color(0.2, 0.9, 0.78)], 
	"niflheim": ["cross", Color(0.68, 0.42, 1.0)], 
	"valkyrie": ["star", Color(1.0, 0.55, 0.76)], 
	"hel": ["square", Color(0.92, 0.14, 0.22)], 
}




func _altar_glyph(c: Vector2, shape: String, r: float, col: Color) -> void :
	var pts: = PackedVector2Array()
	match shape:
		"triangle":
			pts = [c + Vector2(0, - r * 1.05), c + Vector2(r, r * 0.75), c + Vector2( - r, r * 0.75)]
		"triangle_down":
			pts = [c + Vector2( - r, - r * 0.75), c + Vector2(r, - r * 0.75), c + Vector2(0, r * 1.05)]
		"square":
			var s: = r * 0.8
			pts = [c + Vector2( - s, - s), c + Vector2(s, - s), c + Vector2(s, s), c + Vector2( - s, s)]
		"bolt":
			for p in [Vector2(1.2, -5), Vector2(-3, 0.6), Vector2(-0.2, 0.6), Vector2(-1.2, 5), Vector2(3, -0.9), Vector2(0.3, -0.9)]:
				pts.append(c + p * r / 5.0)
		"heart":
			for k in 20:
				var t: = k / 20.0 * TAU
				var x: = 16.0 * pow(sin(t), 3)
				var y: = 13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)
				pts.append(c + Vector2(x, - y - 2.0) * r / 15.0)
		"star":
			for k in 10:
				pts.append(c + Vector2.from_angle( - PI / 2.0 + k * PI / 5.0) * (r * 1.1 if k % 2 == 0 else r * 0.45))
		"cross":

			var w: = r * 0.32
			for p in [Vector2( - w, - r), Vector2(w, - r), Vector2(w, - w), Vector2(r, - w), Vector2(r, w), Vector2(w, w), 
					Vector2(w, r), Vector2( - w, r), Vector2( - w, w), Vector2( - r, w), Vector2( - r, - w), Vector2( - w, - w)]:
				pts.append(c + p.rotated(PI / 4.0))
		"leaf":

			for k in 9:
				var t: = k / 8.0
				pts.append(c + Vector2(r * 0.6 * sin(PI * t), - r + 2.0 * r * t).rotated(PI / 4.0))
			for k in range(7, 0, -1):
				var t: = k / 8.0
				pts.append(c + Vector2( - r * 0.6 * sin(PI * t), - r + 2.0 * r * t).rotated(PI / 4.0))
		"sun":
			for k in 8:
				var d: = Vector2.from_angle(k * TAU / 8.0)
				draw_line(c + d * r * 0.55, c + d * r * 1.05, Color(0.05, 0.05, 0.1), 2.6, true)
				draw_line(c + d * r * 0.55, c + d * r * 1.0, col, 1.4, true)
			draw_circle(c, r * 0.55, col)
			draw_arc(c, r * 0.55, 0.0, TAU, 16, Color.WHITE, 1.0, true)
			return
		_:
			pts = [c + Vector2(0, - r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2( - r, 0)]
	draw_colored_polygon(pts, col)
	var edge: = pts.duplicate()
	edge.append(pts[0])
	draw_polyline(edge, Color.WHITE, 1.0, true)


const FALLEN_MARK: = Color(1.0, 0.2, 0.15)





func _draw_fallen(at: Vector2, revive: float, blink: float) -> void :
	draw_circle(at, 5.5, Color(0.08, 0.02, 0.02, 0.85))
	draw_arc(at, 6.5 + 2.5 * blink, 0.0, TAU, 20, Color(FALLEN_MARK, 0.35 + 0.55 * blink), 1.5, true)
	var r: = 3.0
	var col: = Color(FALLEN_MARK.lightened(0.25 * blink), 0.75 + 0.25 * blink)
	draw_line(at + Vector2( - r, - r), at + Vector2(r, r), col, 2.0, true)
	draw_line(at + Vector2( - r, r), at + Vector2(r, - r), col, 2.0, true)
	draw_arc(at, 5.5, 0.0, TAU, 18, Color(1, 1, 1, 0.85), 1.0, true)
	if revive > 0.0:
		draw_arc(at, 5.5, - PI * 0.5, - PI * 0.5 + TAU * clampf(revive, 0.0, 1.0), 18, Color(0.5, 1.0, 0.55), 2.0, true)


func _draw() -> void :
	draw_rect(Rect2(Vector2.ZERO, Vector2(SIZE, SIZE)), Color(0, 0, 0, 0.35))
	if world != null and world.map != null:
		_update_view()
	if _tex != null:
		var ts: = Vector2(_tex.get_width(), _tex.get_height())
		draw_texture_rect_region(_tex, Rect2(Vector2.ZERO, Vector2(SIZE, SIZE)), Rect2(_view.position * ts, _view.size * ts), Color(1, 1, 1, 0.92))

	draw_rect(Rect2(Vector2(-1, -1), Vector2(SIZE + 2, SIZE + 2)), Color(0.58, 0.66, 0.86), false, 1.0)
	draw_rect(Rect2(Vector2(0.5, 0.5), Vector2(SIZE - 1, SIZE - 1)), Color(1, 1, 1, 0.55), false, 1.0)
	if world == null or world.player == null:
		return
	for e in [world.boss]:
		if e != null and is_instance_valid(e) and not e.dead:
			var bp: = _mark(e.position, true)
			draw_circle(bp, 3.0, BOSS_DOT if e.is_boss else ELITE_DOT)
			draw_arc(bp, 3.5, 0.0, TAU, 12, Color.BLACK, 1.0)

	var blink: = 0.55 + 0.45 * absf(sin(Time.get_ticks_msec() / 250.0))
	for p in world.pickups:
		if p.kind == "chest":
			var cp: = _mark(p.node.position)
			if cp == Vector2.INF:
				continue
			draw_rect(Rect2(cp - Vector2(3, 3), Vector2(6, 6)), Color(CHEST_DOT, blink))
			draw_rect(Rect2(cp - Vector2(3, 3), Vector2(6, 6)), Color(0.25, 0.15, 0.0), false, 1.0)


	var hl = world.hell_late
	if hl != null and hl.fog_on and not world.raid.in_arena():
		var lp: = _mark(hl.fog_center)
		var lr: float = (to_minimap(hl.fog_center + Vector3(hl.shown_radius(), 0, 0)) - to_minimap(hl.fog_center)).length()
		if lp != Vector2.INF and lr > 1.0:
			draw_arc(lp, lr, 0.0, TAU, 32, Color(0.85, 0.75, 1.0, 0.8), 1.5, true)
		if hl.fog_next != Vector3.INF:
			var np: = _mark(hl.fog_next, true)
			var nr: float = maxf(4.0, (to_minimap(hl.fog_next + Vector3(hl.fog_radius, 0, 0)) - to_minimap(hl.fog_next)).length())
			draw_circle(np, nr, Color(0.8, 0.6, 1.0, 0.18 + 0.25 * blink))
			draw_arc(np, nr, 0.0, TAU, 32, Color(0.95, 0.85, 1.0, 0.5 + 0.5 * blink), 2.0, true)

	if world.raid != null and world.raid.portal_pos != Vector3.INF:
		var pp: = _mark(world.raid.portal_pos, true)
		draw_circle(pp, 4.5, Color(world.raid.color, 0.35 + 0.4 * blink))
		draw_arc(pp, 6.0 + 2.0 * blink, 0.0, TAU, 20, Color(world.raid.color.lightened(0.3), blink), 1.5, true)

	if world.runner != null and is_instance_valid(world.runner) and not world.runner.dead:
		var rp: = _mark(world.runner.position, true)
		draw_circle(rp, 4.5, Color(GameData.RUNNER.color, 0.6 + 0.4 * blink))
		draw_arc(rp, 6.0 + 2.0 * blink, 0.0, TAU, 18, Color(1, 1, 1, 0.8 * blink), 1.5, true)
		draw_arc(rp, 4.5, 0.0, TAU, 16, Color(0.3, 0.18, 0.0), 1.0, true)

	var q: = world.quest
	if q != null and q.pointer() != Vector3.INF:
		var qp: = _mark(q.pointer(), true)
		draw_circle(qp, 4.5, Color(GameData.QUEST_COLOR, 0.4 + 0.5 * blink))
		draw_arc(qp, 4.5, 0.0, TAU, 16, Color(0.3, 0.18, 0.0), 1.0, true)
		draw_rect(Rect2(qp + Vector2(-0.5, -3), Vector2(1.5, 3.5)), Color(0.25, 0.12, 0.0))
		draw_rect(Rect2(qp + Vector2(-0.5, 1.5), Vector2(1.5, 1.5)), Color(0.25, 0.12, 0.0))




	if world.altars != null and not world.raid.in_arena():
		for a in world.altars.waiting:
			var ap: = _mark(a.pos, true)
			var col: Color = GameData.ALTARS[a.id].color
			if GameData.ALTARS[a.id].has("npc"):

				draw_circle(ap, 6.5, Color(0.05, 0.05, 0.1, 0.8))
				draw_arc(ap, 7.0 + 2.5 * blink, 0.0, TAU, 20, Color(col.lightened(0.2), 0.4 + 0.5 * blink), 1.5, true)
				draw_circle(ap, 4.8, Color(col, 0.9))
				var spin: = Time.get_ticks_msec() * 0.006
				var spiral: = PackedVector2Array()
				for k in 14:
					var t: = k / 13.0
					spiral.append(ap + Vector2.from_angle(spin + t * TAU * 1.6) * (0.6 + 3.6 * t))
				draw_polyline(spiral, Color(0.08, 0.1, 0.2), 1.2, true)
				draw_arc(ap, 4.8, 0.0, TAU, 16, Color.WHITE, 1.0, true)
				continue



			var look: Array = ALTAR_LOOK.get(str(a.id), ["diamond", col])
			col = look[1]
			draw_circle(ap, 7.0, Color(0.05, 0.05, 0.1, 0.85))
			draw_arc(ap, 7.5 + 2.5 * blink, 0.0, TAU, 20, Color(col.lightened(0.2), 0.4 + 0.5 * blink), 1.5, true)
			_altar_glyph(ap, str(look[0]), 4.9 + 0.5 * blink, Color(col, 0.9 + 0.1 * blink))


	for h in world.heroes:
		if h == world.player or not is_instance_valid(h) or h.downed:
			continue
		var hp: = _mark(h.position, true)
		draw_circle(hp, 3.6, PARTY_DOT)
		draw_arc(hp, 3.8, 0.0, TAU, 14, Color(0.05, 0.12, 0.3), 1.2, true)
	for h in world.heroes:
		if h != world.player and is_instance_valid(h) and h.downed:
			_draw_fallen(_mark(h.position, true), h.revive_t / GameData.COOP_REVIVE_TIME, blink)

	var c: = to_minimap(world.player.position)
	var f: = world.player.facing
	var d: = Vector2(f.x, f.z).normalized()
	if d == Vector2.ZERO:
		d = Vector2(0, 1)
	var n: = Vector2( - d.y, d.x)
	var tip: = c + d * 5.0
	var pts: = PackedVector2Array([tip, c - d * 3.0 + n * 3.5, c - d * 1.5, c - d * 3.0 - n * 3.5])
	draw_colored_polygon(pts, ARROW)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color(0.3, 0, 0), 1.0)

	if zoom > 1.0:
		var font: = ThemeDB.fallback_font
		var label: = "x%d" % int(zoom)
		var at: = Vector2(SIZE - 4.0 - font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x, SIZE - 4.0)
		draw_string_outline(font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, 3, Color(0, 0, 0, 0.8))
		draw_string(font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
