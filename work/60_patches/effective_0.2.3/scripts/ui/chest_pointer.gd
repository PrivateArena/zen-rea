extends Control





const MARGIN: = 40.0
const MARGIN_BOTTOM: = 78.0
const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")

var world: World
var _icons: = {}




const RING: = 0.4


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = RoAssets.ui_filter()


func _process(_delta: float) -> void :
	queue_redraw()


func _icon(tier: int) -> Texture2D:
	if not _icons.has(tier):
		var spr: = RoAssets.sprite([GameData.CHEST_SPRITES[tier], "chest"])
		_icons[tier] = spr.get_frame(0, 0) if spr != null else null
	return _icons[tier]


var _mvp_tex: Texture2D
func _mvp_icon() -> Texture2D:
	if _mvp_tex == null:
		var spr: = RoAssets.sprite(["fx_mvp"])
		if spr != null:
			var img: = spr.compose_image(0, 0)
			var used: = img.get_used_rect()
			img = img.get_region(used)
			var k: = minf(30.0 / img.get_width(), 30.0 / img.get_height())
			img.resize(maxi(1, int(img.get_width() * k)), maxi(1, int(img.get_height() * k)), Image.INTERPOLATE_NEAREST)
			_mvp_tex = ImageTexture.create_from_image(img)
	return _mvp_tex


var _mob_tex: = {}

func _mob_icon(mob: String) -> Texture2D:
	if mob == "" or not GameData.MONSTERS.has(mob):
		return null
	if not _mob_tex.has(mob):
		_mob_tex[mob] = StagePreview._cropped(mob)
	return _mob_tex[mob]


var _quest_tex: Texture2D

func _quest_icon() -> Texture2D:
	if _quest_tex == null:
		var spr: = RoAssets.sprite(["fx_emotion"])
		if spr != null:
			var img: = spr.compose_image(int(GameData.EMOTES.quest), 0)
			var used: = img.get_used_rect()
			if used.has_area():
				img = img.get_region(used)
				_quest_tex = ImageTexture.create_from_image(img)
	return _quest_tex



const HYPNO_MARK_DIST: = 30.0

const HYPNO_MARK_NEAR: = 9.0


func _draw() -> void :
	if world == null or world.player == null or not world.running or world.camera == null:
		return
	var cam: = world.camera
	var view: = get_viewport_rect().size
	var center: = view * 0.5
	var t: = Time.get_ticks_msec() / 1000.0
	var bounce: = absf(sin(t * 4.0))
	var marks: Array = []
	for p in world.pickups:
		if p.kind == "chest":
			var tier: = int(p.get("tier", 0))
			marks.append([p.get("hop_to", p.node.position), GameData.CHEST_COLORS[tier], _icon(tier)])

	if world.raid.portal_pos != Vector3.INF:
		var face: = _mob_icon(world.raid.mvp)

		if face == null:
			face = _mob_icon(str(world.stage.get("mvp", "")))
		marks.append([world.raid.portal_pos, world.raid.color, face if face != null else _mvp_icon(), true])

	if world.runner != null and is_instance_valid(world.runner) and not world.runner.dead:
		var rface: = _mob_icon(str(GameData.RUNNER.mob))
		marks.append([world.runner.position, GameData.RUNNER.color, rface, true, tr("¡Atrápalo!  %d s") % ceili(world.runner.runner_life)])

	if world.quest != null and world.quest.pointer() != Vector3.INF and not world.raid.in_arena():
		marks.append([world.quest.pointer(), GameData.QUEST_COLOR, null, true, 
			world.quest.pointer_label(), "quest", world.quest.pointer_head()])


	for a in world.altars.waiting:
		var d: = (a.pos as Vector3).distance_to(world.player.position)
		if str(a.id) == "hypnotist" and is_instance_valid(a.node) and d < HYPNO_MARK_DIST and d > HYPNO_MARK_NEAR:
			marks.append([a.pos, Color(GameData.ALTARS.hypnotist.color), null, true, tr("El Hipnotista"), "quest", 
				(a.pos as Vector3) + Vector3(0, 2.8, 0)])
	for m in marks:
		var pos: Vector3 = m[0]
		var color: Color = m[1]
		var icon: Texture2D = m[2]
		var behind: = cam.is_position_behind(pos)
		var sp: = cam.unproject_position(pos)
		var inner: = Rect2(Vector2(MARGIN, MARGIN), view - Vector2(MARGIN * 2.0, MARGIN + MARGIN_BOTTOM))
		if not behind and inner.has_point(sp):
			if m.size() > 6:

				var head: = cam.unproject_position(m[6])
				_arrow(head + Vector2(0, -20.0 - 6.0 * bounce), Vector2(0, 1), color, 10.0)
				var qp: = (head + Vector2(-4.0, -34.0 - 6.0 * bounce)).round()
				draw_string_outline(RO_FONT_BOLD, qp, "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 4, Color(0.3, 0.15, 0.0))
				draw_string(RO_FONT_BOLD, qp, "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, color.lightened(0.2))
			else:
				_arrow(sp + Vector2(0, -38.0 - 6.0 * bounce), Vector2(0, 1), color, 10.0)
			continue
		var portal: bool = m.size() > 3 and m[3]
		var dir: = (sp - center) * (-1.0 if behind else 1.0)
		if dir.length_squared() < 1.0:
			continue
		dir = dir.normalized()

		var room_x: = center.x - MARGIN
		var room_y: = (view.y - MARGIN_BOTTOM - center.y) if dir.y > 0.0 else (center.y - MARGIN)
		var k: = minf(room_x / maxf(absf(dir.x), 0.001), room_y / maxf(absf(dir.y), 0.001))


		var at: = center + dir * minf(k, view.y * RING)
		var radius: = 24.0 if portal else 19.0
		draw_circle(at, radius, Color(0.05, 0.06, 0.1, 0.65))
		draw_arc(at, radius, 0.0, TAU, 28, Color(color, 0.6 + 0.4 * bounce), 3.0 if portal else 2.0, true)
		if portal:

			draw_arc(at, radius + 4.0 + 6.0 * bounce, 0.0, TAU, 28, Color(color, 0.5 * (1.0 - bounce)), 2.0, true)
			var label: String = m[4] if m.size() > 4 else tr("Portal MVP")
			var lw: = RO_FONT_BOLD.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
			var lp: = (at + Vector2( - lw * 0.5, - radius - 6.0)).round()
			draw_string_outline(RO_FONT_BOLD, lp, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, 3, Color.BLACK)
			draw_string(RO_FONT_BOLD, lp, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, color.lightened(0.4))
		if m.size() > 5 and m[5] == "quest":

			var ew: = RO_FONT_BOLD.get_string_size("!", HORIZONTAL_ALIGNMENT_LEFT, -1, 26).x
			var ep: = (at + Vector2( - ew * 0.5, 9.0)).round()
			draw_string_outline(RO_FONT_BOLD, ep, "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, 4, Color(0.3, 0.15, 0.0))
			draw_string(RO_FONT_BOLD, ep, "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, color.lightened(0.2))
		elif icon != null:
			var s: = icon.get_size()

			var fit: = (radius * 1.7) / maxf(s.x, s.y)
			if fit < 1.0:
				s *= fit
			draw_texture_rect(icon, Rect2((at - s * 0.5).round(), s.round()), false)
		_arrow(at + dir * (26.0 + 3.0 * bounce), dir, color, 8.0)
		var to: = (pos - world.player.position) * Vector3(1, 0, 1)
		var txt: = "%d" % roundi(to.length())
		var tw: = RO_FONT_BOLD.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
		var tp: = (at + Vector2( - tw * 0.5, 32)).round()
		draw_string_outline(RO_FONT_BOLD, tp, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, 3, Color.BLACK)
		draw_string(RO_FONT_BOLD, tp, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)



func _arrow(tip: Vector2, dir: Vector2, color: Color, size: float) -> void :
	var n: = Vector2( - dir.y, dir.x)
	var pts: = PackedVector2Array([tip, tip - dir * size + n * size * 0.75, tip - dir * size * 0.55, tip - dir * size - n * size * 0.75])
	draw_colored_polygon(pts, color)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color(0.1, 0.06, 0.0), 1.5, true)
