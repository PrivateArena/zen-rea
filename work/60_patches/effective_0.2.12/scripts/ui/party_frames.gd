class_name PartyFrames
extends VBoxContainer







const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")
const FONT = preload("res://assets/ro/fonts/SCDream4.otf")
const FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")
const WIDTH: = 232.0


const ACCENT_LEADER: = Color(0.88, 0.68, 0.24)
const ACCENT: = Color(0.38, 0.55, 0.9)
const ACCENT_DOWN: = Color(0.85, 0.25, 0.2)

const LOW_HP: = 0.25

var world: World
var _win: Dictionary
var _rows: = {}
var _t: = 0.0
var _clock: = 0.0


func setup(p_world: World) -> void :
	world = p_world
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _win.is_empty():
		_win = UiStyles.hud_window(tr("Party"), FONT_BOLD)
		(_win.root as Control).custom_minimum_size.x = WIDTH
		(_win.body as Control).add_theme_constant_override("separation", 4)
		add_child(_win.root)


func _process(delta: float) -> void :
	visible = world != null and world.running and world.is_coop()
	if not visible:
		return
	_clock += delta
	_t -= delta
	if _t > 0.0:
		return
	_t = 0.1
	(_win.title as Label).text = "%s (%d)" % [tr("Party"), world.heroes.size()]
	for h in world.heroes:
		if h == world.player:
			continue
		if not _rows.has(h.slot):
			_rows[h.slot] = _row()
			(_win.body as Control).add_child(_rows[h.slot].box)
		_fill(_rows[h.slot], h)
	for slot in _rows.keys():
		if slot >= world.heroes.size() or world.heroes[slot] == world.player:
			_rows[slot].box.queue_free()
			_rows.erase(slot)


func _row() -> Dictionary:

	var box: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.97, 1.0)
	sb.border_color = Color(0.74, 0.79, 0.92)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(7)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 4
	sb.content_margin_bottom = 5
	sb.shadow_color = Color(0.1, 0.15, 0.35, 0.12)
	sb.shadow_size = 2
	sb.shadow_offset = Vector2(0, 1)
	box.add_theme_stylebox_override("panel", sb)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(row)

	var frame: = Panel.new()
	var fb: = StyleBoxFlat.new()
	fb.bg_color = Color(0.17, 0.2, 0.34)
	fb.border_color = ACCENT
	fb.set_border_width_all(2)
	fb.set_corner_radius_all(17)
	fb.shadow_color = Color(0, 0, 0, 0.25)
	fb.shadow_size = 1
	frame.add_theme_stylebox_override("panel", fb)
	frame.custom_minimum_size = Vector2(34, 34)
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(frame)
	var icon: = TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = RoAssets.ui_filter()
	icon.position = Vector2(5, 4)
	icon.size = Vector2(24, 24)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(icon)

	var badge: = PanelContainer.new()
	var bb: = StyleBoxFlat.new()
	bb.bg_color = Color(0.14, 0.18, 0.36)
	bb.set_corner_radius_all(5)
	bb.content_margin_left = 4
	bb.content_margin_right = 4
	bb.content_margin_top = 0
	bb.content_margin_bottom = 1
	badge.add_theme_stylebox_override("panel", bb)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lv: = _text("", FONT_BOLD, 9, Color.WHITE)
	badge.add_child(lv)

	var crown: = TextureRect.new()
	var cp: = "res://assets/ro/ui/skin/job_icons/crown.png"
	if ResourceLoader.exists(cp):
		crown.texture = load(cp)
	crown.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	crown.position = Vector2(-5, -7)
	crown.size = Vector2(15, 13)
	crown.visible = false
	crown.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(crown)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(col)
	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 4)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(top)
	var name: = _text("", FONT_BOLD, 11, Color(0.12, 0.14, 0.25))
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.clip_text = true
	top.add_child(name)
	var job: = _text("", FONT, 9, Color(0.4, 0.45, 0.62))
	top.add_child(job)
	top.add_child(badge)
	var arrow: = PartyArrow.new()
	arrow.custom_minimum_size = Vector2(12, 12)
	arrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	arrow.visible = false
	top.add_child(arrow)
	var bar: = PartyHpBar.new()
	bar.custom_minimum_size = Vector2(WIDTH - 66.0, 14)
	col.add_child(bar)


	var buffs: = HBoxContainer.new()
	buffs.add_theme_constant_override("separation", 2)
	buffs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	buffs.visible = false
	col.add_child(buffs)
	return {"box": box, "card": sb, "name": name, "job": job, "lv": lv, "badge": badge, "bar": bar, "icon": icon, 
		"crown": crown, "frame": fb, "arrow": arrow, "id": -1, "buffs": buffs, "buff_sig": ""}


func _text(t: String, font: Font, size: int, col: Color) -> Label:
	var l: = Label.new()
	l.text = t
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l



static func job_key(h: Player) -> String:
	if not h.job2.is_empty():
		return GameData.job_title(h.job2, h.female())
	if h.reborn:
		return str(GameData.HIGH_NAMES.get(h.class_id, h.def.name))
	return str(h.def.name)


func _fill(r: Dictionary, h: Player) -> void :
	var shown: = str(h.appearance.get("name", "")).strip_edges()
	var job_name: = tr(h.job_name())
	(r.name as Label).text = shown if shown != "" else job_name

	(r.job as Label).text = job_name if shown != "" and shown != job_name else ""
	(r.lv as Label).text = "Lv %d" % h.level
	var id: = int(GameData.JOB_ICON_IDS.get(job_key(h), 0))
	if id != int(r.id):
		r.id = id
		var path: = "res://assets/ro/ui/skin/job_icons/%d.png" % id
		(r.icon as TextureRect).texture = load(path) if ResourceLoader.exists(path) else null
	(r.crown as TextureRect).visible = h.slot == 0

	var accent: = ACCENT_DOWN if h.downed else (ACCENT_LEADER if h.slot == 0 else ACCENT)
	var card: StyleBoxFlat = r.card
	card.bg_color = Color(1.0, 0.93, 0.92) if h.downed else Color(0.96, 0.97, 1.0)
	var k: = clampf(h.hp / maxf(1.0, h.max_hp), 0.0, 1.0)
	if not h.downed and k < LOW_HP:

		accent = accent.lerp(ACCENT_DOWN, 0.4 + 0.6 * (0.5 + 0.5 * sin(_clock * 7.0)))

	card.border_color = accent
	(r.frame as StyleBoxFlat).border_color = accent

	(r.icon as TextureRect).modulate = Color(0.45, 0.45, 0.5) if h.downed else Color.WHITE
	(r.name as Label).add_theme_color_override("font_color", Color(0.55, 0.2, 0.18) if h.downed else Color(0.12, 0.14, 0.25))

	var arrow: PartyArrow = r.arrow
	var cam: = get_viewport().get_camera_3d()
	var off: = cam != null and not cam.is_position_in_frustum(h.position)
	arrow.visible = off
	if off:
		var view: = get_viewport().get_visible_rect().size
		var at: = cam.unproject_position(h.position)
		if cam.is_position_behind(h.position):
			at = view - at
		arrow.dir = (at - view * 0.5).normalized()
		arrow.color = accent
		arrow.queue_redraw()
	_fill_buffs(r, h)
	var bar: PartyHpBar = r.bar
	bar.hp = h.hp
	bar.max_hp = h.max_hp
	bar.shield = h.shield
	bar.downed = h.downed
	bar.revive = h.revive_t / GameData.COOP_REVIVE_TIME if h.downed else 0.0
	bar.queue_redraw()



const BUFF_MAX: = 9
const BUFF_ICON: = 18.0





static func buffs_of(w: World, h: Player) -> Array:
	var list: Array = []
	if h == null or not is_instance_valid(h):
		return list
	for id in h.skills:
		if GameData.SKILLS.has(id) and str(GameData.SKILLS[id].get("type", "")) == "buff":
			list.append(["skill", str(id)])
	for id in h.party_buffs:
		if not h.skills.has(id) and GameData.SKILLS.has(id):
			list.append(["skill", str(id)])
	if w.hud != null:
		for id in h.powers:
			if w.hud._power_icon(str(id)) != null:
				list.append(["power", str(id)])
	return list





func _fill_buffs(r: Dictionary, h: Player) -> void :

	var list: Array = world.net.party_buff_lists.get(h.slot, []) if world.net.is_client() else buffs_of(world, h)
	var sig: = str(list)
	var row: HBoxContainer = r.buffs
	row.visible = not list.is_empty()
	if sig == str(r.buff_sig):
		return
	r.buff_sig = sig
	for c in row.get_children():
		c.queue_free()
	for i in mini(list.size(), BUFF_MAX):
		var e: Array = list[i]
		if not (e is Array) or (e as Array).size() < 2:
			continue
		var tex: Texture2D = UiKit.skill_icon(str(e[1])) if str(e[0]) == "skill" else world.hud._power_icon(str(e[1]))
		if tex == null:
			continue
		var slot: = PanelContainer.new()
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(1, 1, 1, 0.95)
		sb.border_color = Color(0.55, 0.68, 0.95) if e[0] == "skill" else Color(0.95, 0.72, 0.3)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(4)
		sb.set_content_margin_all(1)
		slot.add_theme_stylebox_override("panel", sb)
		slot.custom_minimum_size = Vector2(BUFF_ICON, BUFF_ICON)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ic: = UiKit.icon_rect(tex, BUFF_ICON - 4.0)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(ic)
		row.add_child(slot)
	if list.size() > BUFF_MAX:
		row.add_child(_text("+%d" % (list.size() - BUFF_MAX), FONT_BOLD, 9, Color(0.3, 0.36, 0.55)))





class PartyHpBar extends Control:
	var hp: = 1.0
	var max_hp: = 1.0
	var shield: = 0.0
	var downed: = false
	var revive: = 0.0

	var trail: = 1.0
	var _shown: = 1.0

	func _process(delta: float) -> void :
		var k: = clampf(hp / maxf(1.0, max_hp), 0.0, 1.0)
		if downed:
			trail = 0.0
		elif trail < k:
			trail = k
		elif trail > k:
			trail = maxf(k, trail - delta * 0.6)
			queue_redraw()

	func _draw() -> void :
		var r: = Rect2(Vector2.ZERO, size)
		var back: = StyleBoxFlat.new()
		back.bg_color = Color(0.22, 0.1, 0.12)
		back.border_color = Color(0.08, 0.08, 0.16)
		back.set_border_width_all(1)
		back.set_corner_radius_all(4)
		draw_style_box(back, r)
		var inner: = r.grow(-1.0)
		var k: = clampf(hp / maxf(1.0, max_hp), 0.0, 1.0)
		var col: = Color(0.3, 0.8, 0.34)
		if downed:
			col = Color(0.92, 0.72, 0.3)
			k = revive
		elif k < 0.25:
			col = Color(0.92, 0.22, 0.2)
		elif k < 0.5:
			col = Color(0.95, 0.78, 0.22)
		if not downed and trail > k:
			_fill(inner, k, trail, Color(1.0, 0.88, 0.62, 0.85))
		_fill(inner, 0.0, k, col)

		_fill(Rect2(inner.position, Vector2(inner.size.x, inner.size.y * 0.4)), 0.0, k, Color(1, 1, 1, 0.22))
		_fill(Rect2(inner.position + Vector2(0, inner.size.y * 0.75), Vector2(inner.size.x, inner.size.y * 0.25)), 0.0, k, Color(0, 0, 0, 0.14))
		if shield > 0.0 and not downed:

			var s: = clampf(shield / maxf(1.0, max_hp), 0.0, 1.0)
			var from: = minf(k, 1.0 - s)
			_fill(inner, from, from + s, Color(0.45, 0.75, 1.0, 0.8))
			_fill(Rect2(inner.position, Vector2(inner.size.x, inner.size.y * 0.4)), from, from + s, Color(1, 1, 1, 0.3))
		var text: = (tr("Caído") + ("  %d%%" % roundi(revive * 100.0) if revive > 0.0 else "")) if downed\
		else "%s / %s" % [RoAssets.short_number(roundi(hp)), RoAssets.short_number(roundi(max_hp))]
		if shield > 0.0 and not downed:
			text += "  +%s" % RoAssets.short_number(roundi(shield))
		var size_px: = 10
		var w: = FONT_BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
		var at: = Vector2(roundf((size.x - w) * 0.5), roundf((size.y + FONT_BOLD.get_ascent(size_px) - FONT_BOLD.get_descent(size_px)) * 0.5))
		draw_string_outline(FONT_BOLD, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, 3, Color(0, 0, 0, 0.85))
		draw_string(FONT_BOLD, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, Color.WHITE)


	func _fill(inner: Rect2, a: float, b: float, col: Color) -> void :
		if b <= a:
			return
		var rect: = Rect2(inner.position + Vector2(inner.size.x * a, 0), Vector2(inner.size.x * (b - a), inner.size.y))
		var sb: = StyleBoxFlat.new()
		sb.bg_color = col
		sb.corner_radius_top_left = 3 if a <= 0.0 else 0
		sb.corner_radius_bottom_left = 3 if a <= 0.0 else 0
		sb.corner_radius_top_right = 3 if b >= 1.0 else 0
		sb.corner_radius_bottom_right = 3 if b >= 1.0 else 0
		draw_style_box(sb, rect)



class PartyArrow extends Control:
	var dir: = Vector2.RIGHT
	var color: = Color.WHITE

	func _draw() -> void :
		var c: = size * 0.5
		var f: = dir * 5.5
		var s: = Vector2( - dir.y, dir.x) * 3.5
		var pts: = PackedVector2Array([c + f, c - f * 0.6 + s, c - f * 0.25, c - f * 0.6 - s])
		draw_colored_polygon(pts, color)
		draw_polyline(pts + PackedVector2Array([c + f]), Color(0, 0, 0, 0.5), 1.0, true)
