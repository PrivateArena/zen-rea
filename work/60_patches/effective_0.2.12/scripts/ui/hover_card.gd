class_name HoverCard
extends CanvasLayer







const RO_FONT = preload("res://assets/ro/fonts/SCDream4.otf")
const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")
const DEFAULT_COLOR: = Color(0.95, 0.8, 0.4)


const TEXT_W: = 280.0



const INK: = Color(0.1, 0.12, 0.2)
const LABEL_INK: = Color(0.25, 0.27, 0.36)
const SUB_INK: = Color(0.28, 0.3, 0.4)
const HINT_INK: = Color(0.48, 0.34, 0.05)

const CHIP_WHO: = Color(0.2, 0.45, 0.28)
const CHIP_KIND: = Color(0.38, 0.27, 0.55)
const CHIP_AREA: = Color(0.24, 0.34, 0.62)
const CHIP_STR: = Color(0.66, 0.24, 0.2)
const CHIP_INT: = Color(0.16, 0.4, 0.72)
const CHIP_HYBRID: = Color(0.45, 0.26, 0.55)
const CHIP_GOLD: = Color(0.55, 0.42, 0.12)
const CHIP_GREY: = Color(0.32, 0.34, 0.42)

var _card: PanelContainer
var _owner: Control
var _key: = ""

var test_target: Control


func _init() -> void :
	layer = 125
	process_mode = Node.PROCESS_MODE_ALWAYS







static func build(info: Dictionary, wide: = 1.0) -> PanelContainer:
	var col: Color = info.get("color", DEFAULT_COLOR)

	var k: = UiKit.text_k()
	var fs: = func(n: int) -> int: return roundi(n * k)
	var text_w: = roundf(TEXT_W * k * wide)
	var card: = PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.set_meta("wide", wide)

	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.985, 0.99, 1.0, 0.98)
	box.border_color = rim(col).lerp(Color.WHITE, 0.25)
	box.set_border_width_all(1)
	box.border_width_top = 3
	box.set_corner_radius_all(8)
	box.set_content_margin_all(11)
	box.shadow_color = Color(0.03, 0.06, 0.18, 0.3)
	box.shadow_size = 7
	box.shadow_offset = Vector2(0, 3)
	box.anti_aliasing = true
	card.add_theme_stylebox_override("panel", box)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 5)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(head)
	var icon: Texture2D = info.get("icon")
	if icon != null:
		var frame: = PanelContainer.new()
		var fb: = StyleBoxFlat.new()
		fb.bg_color = Color.WHITE.lerp(col, 0.12)
		fb.border_color = Color(rim(col), 0.6)
		fb.set_border_width_all(1)
		fb.set_corner_radius_all(6)
		fb.anti_aliasing = true
		fb.set_content_margin_all(3)
		frame.add_theme_stylebox_override("panel", fb)
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ir: = UiKit.icon_rect(icon, float(info.get("icon_size", 30)))
		ir.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.add_child(ir)
		head.add_child(frame)
	var tbox: = VBoxContainer.new()
	tbox.add_theme_constant_override("separation", 1)
	tbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(tbox)
	var title: = label(str(info.get("title", "")), fs.call(16), ink(col), true)
	var head_w: = text_w - (float(info.get("icon_size", 30)) + 16.0 if icon != null else 0.0)
	if title.get_minimum_size().x > head_w:
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.custom_minimum_size.x = head_w
	tbox.add_child(title)
	if str(info.get("tag", "")) != "":
		var tag: = label(str(info.tag), fs.call(12), SUB_INK)
		if tag.get_minimum_size().x > head_w:
			tag.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			tag.custom_minimum_size.x = head_w
		tbox.add_child(tag)
	var lines: Array = info.get("lines", [])
	if not lines.is_empty():
		var sep: = ColorRect.new()
		sep.color = Color(rim(col), 0.25)
		sep.custom_minimum_size = Vector2(0, 1)
		sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(sep)
		var grid: = GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 14)
		grid.add_theme_constant_override("v_separation", 2)
		grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(grid)

		var lab_w: = 0.0
		for ln in lines:
			lab_w = maxf(lab_w, label(str(ln[0]), fs.call(13), LABEL_INK).get_minimum_size().x)
		for ln in lines:
			grid.add_child(label(str(ln[0]), fs.call(13), LABEL_INK))
			var val: = label(str(ln[1]), fs.call(13), ink(ln[2]) if ln.size() > 2 and ln[2] is Color else INK, true)
			if val.get_minimum_size().x > text_w - lab_w - 14.0:
				val.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				val.custom_minimum_size.x = maxf(80.0, text_w - lab_w - 14.0)
			grid.add_child(val)
	var chip_list: Array = info.get("chips", [])
	if not chip_list.is_empty():
		var flow: = HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 5)
		flow.add_theme_constant_override("v_separation", 5)
		flow.custom_minimum_size.x = text_w
		flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(flow)
		for c in chip_list:
			flow.add_child(chip(str(c[0]), c[1], fs.call(11)))
	if str(info.get("desc", "")) != "":
		var d: = label(str(info.desc), fs.call(13), INK)
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.custom_minimum_size.x = text_w
		v.add_child(d)
	if info.has("set"):
		v.add_child(set_block(info.set, true, text_w, k))



	var hints: = []
	for f in info.get("foot", []):
		if f.size() > 2 and f[2] == true:
			hints.append(str(f[0]))
			continue
		var fl: = label(str(f[0]), fs.call(12), ink(f[1]), true)
		fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		fl.custom_minimum_size.x = text_w
		v.add_child(fl)


	if info.has("harmony"):
		var hopt: Dictionary = (info.get("harmony_opt", {}) as Dictionary).duplicate()
		hopt["width"] = text_w
		hopt["k"] = k
		v.add_child(load("res://scripts/ui/harmony_view.gd").panel(info.harmony, hopt))
	if not hints.is_empty():

		var one: = label("  ·  ".join(hints), fs.call(11), HINT_INK, true)
		var rows: Array = [one.text] if one.get_minimum_size().x <= text_w else hints
		one.free()
		for h in rows:
			var hl: = label(str(h), fs.call(11), HINT_INK, true)
			hl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			hl.custom_minimum_size.x = text_w
			v.add_child(hl)
	return card




static func chip(text: String, color: Color, size: = 11) -> PanelContainer:
	var p: = PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb: = StyleBoxFlat.new()
	var bg: = color
	var i: = 0
	while bg.srgb_to_linear().get_luminance() > 0.17 and i < 12:
		bg = bg.darkened(0.08)
		i += 1
	sb.bg_color = bg
	sb.set_corner_radius_all(5)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 1
	sb.content_margin_bottom = 2
	sb.anti_aliasing = true
	p.add_theme_stylebox_override("panel", sb)
	p.add_child(label(text, size, Color.WHITE, true))
	return p







static func scale_chips(text: String) -> Array:
	var out: = []
	if text == "":
		return out
	var t: = func(s: String) -> String: return TranslationServer.translate(s)
	for part in text.split(" + ", false):
		var c: = CHIP_GOLD
		if part == t.call("FUE"):
			c = CHIP_STR
		elif part == t.call("INT"):
			c = CHIP_INT
		elif part.contains("/") or part == t.call("La más alta de FUE e INT"):
			c = CHIP_HYBRID
		elif part == t.call("AGI"):
			c = Color(0.1, 0.45, 0.45)
		elif part == t.call("DES"):
			c = Color(0.22, 0.45, 0.18)
		elif part in [t.call("Daño de habilidades"), t.call("Daño básico")]:
			c = CHIP_GREY
		out.append([part, c])
	return out



static func element_chip(element: String, arrows: = false) -> Array:
	var text: = TranslationServer.translate(str(GameData.ELEMENT_NAMES.get(element, "Neutral")))
	if arrows:
		text = TranslationServer.translate("%s · flecha") % text
	return [text, GameData.ELEMENT_COLORS.get(element, GameData.ELEMENT_COLORS.neutral)]




static func skill_kind(type: String) -> Array:

	match type:
		"buff":
			return [TranslationServer.translate("Apoyo"), CHIP_KIND]
		"heal":
			return [TranslationServer.translate("Curación"), CHIP_KIND]
		"shield":
			return [TranslationServer.translate("Barrera"), CHIP_KIND]
		"projectile":
			return [TranslationServer.translate("Proyectil"), CHIP_KIND]
		"summon":
			return [TranslationServer.translate("Invocación"), CHIP_KIND]
		"melee_arc":
			return [TranslationServer.translate("Cuerpo a cuerpo"), CHIP_KIND]
		"aoe_target", "aoe_self", "ground":
			return [TranslationServer.translate("Área"), CHIP_AREA]
	return []





static func skill_chips(id: String, scaling: = "", element: = "", arrows: = false) -> Array:
	var def: Dictionary = GameData.SKILLS.get(id, {})
	var out: = []
	var kind: = skill_kind(str(def.get("type", "")))
	if not kind.is_empty():
		out.append(kind)
	if def.get("ninjutsu", false):
		out.append([TranslationServer.translate("Ninjutsu"), CHIP_KIND])
	if def.get("thrown", false):
		out.append([TranslationServer.translate("Lanzable"), CHIP_KIND])

	if def.get("falcon_passive", false) or str(def.get("type", "")) == "falcon_assault":
		out.append([TranslationServer.translate("Daño de habilidades"), CHIP_GREY])
	out.append_array(scale_chips(scaling))
	var nature: = GameData.skill_nature(id)
	if nature != "":
		out.append([nature, CHIP_GREY])
	if element != "":
		out.append(element_chip(element, arrows))

	if GameData.PUNISH_SKILLS.has(id):
		out.append([TranslationServer.translate("Castigo"), GameData.PUNISH_COLOR.darkened(0.3)])

	if GameData.GUN_MARK_SKILLS.has(id.trim_suffix("_x")):
		out.append([TranslationServer.translate("Dragon Tail"), GameData.DRAGON_TAIL_COLOR.darkened(0.25)])
	return out





static func gear_chips(d: Dictionary, users: Array = []) -> Array:
	var out: = []
	if users.size() >= GameData.CLASSES.size() and users.size() > 0 and users == GameData.CLASSES.keys().map( func(c): return TranslationServer.translate(str(GameData.CLASSES[c].name))):
		out.append([TranslationServer.translate("Todas las clases"), CHIP_WHO])
	else:
		for u in users:
			out.append([str(u), CHIP_WHO])


	if d.has("proc_hit"):
		out.append([TranslationServer.translate("Al ser golpeado"), CHIP_KIND])
	out.append_array(scale_chips(GameData.gear_scaling(d)))
	var nature: = GameData.gear_nature(d)
	if nature != "":
		out.append([nature, CHIP_GREY])
	var cast: = GameData.gear_cast_skill(d)
	if GameData.SKILLS.has(cast) and GameData.skill_has_element(cast) and not GameData.SKILLS[cast].has("elements"):
		out.append(element_chip(str(GameData.SKILLS[cast].get("element", "neutral"))))
	return out




static func wider_card(card: Control, info: Dictionary, view: Vector2) -> PanelContainer:
	var sz: = card.get_combined_minimum_size() * card.scale
	var wide: = float(card.get_meta("wide", 1.0))
	if sz.y <= view.y - 8.0 or sz.x * 1.35 > view.x * 0.9:
		return null
	return build(info, wide * 1.35)





static func ink(c: Color) -> Color:
	if c.s < 0.12 and c.v > 0.7:
		return INK
	var out: = c
	var i: = 0
	while out.srgb_to_linear().get_luminance() > 0.095 and i < 16:
		out = out.darkened(0.08)
		i += 1
	return out



static func rim(c: Color) -> Color:
	if c.s < 0.12 and c.v > 0.7:
		return Color(0.1, 0.13, 0.24)
	var l: = c.get_luminance()
	return c.darkened(clampf((l - 0.3) * 1.1, 0.0, 0.6)) if l > 0.35 else c


const SET_GOLD: = Color(1.0, 0.78, 0.3)
const SET_ON: = Color(0.45, 1.0, 0.55)











static func set_block(info: Dictionary, light: = false, width: = 230.0, k: = 0.0) -> PanelContainer:
	var active: bool = info.get("active", false)
	var gold: = SET_GOLD.darkened(0.5) if light else SET_GOLD
	var on: = Color(0.05, 0.45, 0.15) if light else SET_ON
	var off: = Color(0.3, 0.32, 0.42) if light else Color(0.55, 0.58, 0.68)

	var big: = k > 0.0
	var fs: = func(n: int) -> int: return roundi((n + 1) * k) if big else n
	var box: = PanelContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(gold, 0.1) if not active else Color(on, 0.12)
	sb.border_color = Color(gold, 0.55) if not active else Color(on, 0.8)
	sb.set_border_width_all(1)
	sb.border_width_left = 3
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(6)
	box.add_theme_stylebox_override("panel", sb)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(col)
	var pieces: Array = info.get("pieces", [])
	var have: = pieces.filter( func(pc): return pc.have).size()
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(head)
	var title: = label(TranslationServer.translate("Set: %s") % str(info.get("name", "")), fs.call(11), gold if not active else on, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	head.add_child(label("%d/%d" % [have, pieces.size()], fs.call(11), on if active else gold, true))
	for pc in pieces:
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 5)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(row)


		var stored: bool = pc.get("stored", false)
		var ic: = UiKit.icon_rect(pc.icon, 18 if not big else roundi(20 * k))
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ic.modulate = Color.WHITE if pc.have else Color(1, 1, 1, 0.65 if stored else 0.3)
		row.add_child(ic)
		var nm: = label(str(pc.name), fs.call(10), (Color(0.1, 0.12, 0.2) if light else Color(0.95, 0.96, 1.0)) if pc.have else off, pc.have)
		nm.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(nm)
		if stored:
			var where: = label(TranslationServer.translate("en tu almacén"), fs.call(9), Color(0.15, 0.32, 0.7) if light else Color(0.6, 0.78, 1.0))
			where.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			row.add_child(where)



	var need: = 2 if str(info.get("desc4", "")) != "" else pieces.size()
	var bonus: = label(TranslationServer.translate("Bono (%d): %s") % [need, str(info.get("desc", ""))], fs.call(10), on if active else off, active)
	bonus.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bonus.custom_minimum_size.x = width - 14
	col.add_child(bonus)

	if str(info.get("desc4", "")) != "":
		var active4: bool = info.get("active4", false)
		var bonus4: = label(TranslationServer.translate("Bono (4): %s") % str(info.desc4), fs.call(10), on if active4 else off, active4)
		bonus4.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bonus4.custom_minimum_size.x = width - 14
		col.add_child(bonus4)

	if str(info.get("drops", "")) != "":
		var drops: = label(TranslationServer.translate("Cae en: %s") % str(info.drops), fs.call(9), Color(0.55, 0.3, 0.0) if light else Color(1.0, 0.8, 0.4), true)
		drops.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		drops.custom_minimum_size.x = width - 14
		col.add_child(drops)
	if str(info.get("here", "")) != "":
		col.add_child(label(str(info.here), fs.call(9), off))
	return box


static func label(text: String, size: int, color: Color, bold: = false) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", RO_FONT_BOLD if bold else RO_FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l



static func place(card: Control, ctrl: Control) -> void :
	if card == null or not is_instance_valid(ctrl):
		return
	var view: = ctrl.get_viewport().get_visible_rect().size
	var r: = ctrl.get_global_rect()
	var sz: = card.get_combined_minimum_size() * card.scale
	var pos: = Vector2(r.position.x + r.size.x * 0.5 - sz.x * 0.5, r.position.y - sz.y - 6)
	if pos.y < 4:
		pos = Vector2(r.position.x + r.size.x * 0.5 - sz.x * 0.5, r.end.y + 6)
	pos.x = clampf(pos.x, 4, view.x - sz.x - 4)
	pos.y = clampf(pos.y, 4, view.y - sz.y - 4)
	card.position = pos.floor()



static func from_text(text: String) -> Dictionary:
	var parts: = text.split("\n", false)
	if parts.is_empty():
		return {}
	var info: = {"title": parts[0]}
	if parts.size() > 1:
		info["desc"] = "\n".join(parts.slice(1))
	return info


func _process(_delta: float) -> void :
	var c: = test_target if is_instance_valid(test_target) else get_viewport().gui_get_hovered_control()
	var target: Control = null
	var hops: = 0
	while c != null and hops < 4:


		if c.tooltip_text != "":
			c.set_meta("hover_text", c.tooltip_text)
			c.tooltip_text = ""


		if c.has_meta("hover_fn") and not c.has_meta("hover"):
			c.set_meta("hover", (c.get_meta("hover_fn") as Callable).call())
		if c.has_meta("hover") or str(c.get_meta("hover_text", "")) != "":
			target = c
			break
		c = c.get_parent() as Control
		hops += 1
	var info: Dictionary = {}
	if target != null:
		info = target.get_meta("hover") if target.has_meta("hover") else from_text(str(target.get_meta("hover_text")))
	var key: = str(info.hash()) if not info.is_empty() else ""
	if target == _owner and key == _key:
		if _card != null:
			place(_card, target)


			if not _card.visible:


				var wider: = wider_card(_card, info, get_viewport().get_visible_rect().size)
				if wider != null:
					wider.scale = _card.scale
					wider.modulate.a = 0.0
					wider.visible = false
					_card.queue_free()
					_card = wider
					add_child(_card)
					return
				_card.visible = true
				_card.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(_card, "modulate:a", 1.0, 0.08)
		return
	_hide()
	if info.is_empty():
		return
	_owner = target
	_key = key
	_card = build(info)
	var k: = maxf(1.0, floorf(target.get_global_transform_with_canvas().get_scale().x))
	_card.scale = Vector2(k, k)
	_card.modulate.a = 0.0
	_card.visible = false
	add_child(_card)
	place(_card, target)




func _hide() -> void :
	if _card != null and is_instance_valid(_card):
		_card.queue_free()
	_card = null
	_owner = null
	_key = ""
