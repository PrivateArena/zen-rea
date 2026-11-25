extends CanvasLayer




const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")
const COFFEE_URL: = "https://ko-fi.com/pawgress"

const LINKS: = [
	["", 12, Color(0.35, 0.4, 0.95), "Discord", "https://discord.gg/YD4mqwysRb"], 
	["▶", 14, Color(0.86, 0.13, 0.13), "YouTube", "https://www.youtube.com/@pawgress_studios"], 
	["X", 16, Color(0.08, 0.08, 0.1), "X (Twitter)", "https://x.com/Pawgres_Studios"], 
	["itch", 12, Color(0.96, 0.32, 0.36), "itch.io", "https://nearq.itch.io/"], 
]

const DISCORD_SVG: = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" width=\"64\" height=\"64\"><path fill=\"#ffffff\" d=\"M19.6 5.3A16.5 16.5 0 0 0 15.5 4l-.5 1a15.3 15.3 0 0 0-6 0l-.5-1a16.5 16.5 0 0 0-4.1 1.3C1.8 9.2 1.1 13 1.4 16.8A16.6 16.6 0 0 0 6.5 19.4l1.1-1.7a10.7 10.7 0 0 1-1.7-.8l.4-.3a11.8 11.8 0 0 0 11.4 0l.4.3c-.5.3-1.1.6-1.7.8l1.1 1.7a16.6 16.6 0 0 0 5.1-2.6c.4-4.4-.6-8.2-3-11.5ZM8.7 14.5c-1 0-1.8-.9-1.8-2s.8-2 1.8-2 1.8.9 1.8 2-.8 2-1.8 2Zm6.6 0c-1 0-1.8-.9-1.8-2s.8-2 1.8-2 1.8.9 1.8 2-.8 2-1.8 2Z\"/></svg>"
const GAP: = 8.0
const HEIGHT: = 30.0

var world: World
var _box: HBoxContainer
var _pill: Button
var _heart: Label


func _ready() -> void :
	layer = 119
	process_mode = Node.PROCESS_MODE_ALWAYS
	_box = HBoxContainer.new()
	_box.add_theme_constant_override("separation", 4)
	_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_box.offset_right = - GAP
	_box.offset_top = 6.0
	add_child(_box)
	_pill = _button(Color(1.0, 0.95, 0.88), Color(0.95, 0.62, 0.62), "")
	_pill.pressed.connect(_toggle_card)
	_pill.tooltip_text = tr("Ko-fi  ·  PayPal o transferencia")
	_pill.add_theme_font_override("font", UiKit.FONT_TITLE)
	_pill.add_theme_font_size_override("font_size", 15)
	for c in ["font_color", "font_hover_color", "font_pressed_color"]:
		_pill.add_theme_color_override(c, Color(0.5, 0.26, 0.2))
	for st in ["normal", "hover", "pressed"]:
		var sb: StyleBoxFlat = _pill.get_theme_stylebox(st)
		sb.content_margin_left = 12
		sb.content_margin_right = 32
	_pill.text = tr("Cómprame un café")
	_box.add_child(_pill)
	_heart = Label.new()
	_heart.text = "♥"
	_heart.add_theme_font_size_override("font_size", 15)
	_heart.add_theme_color_override("font_color", Color(0.93, 0.3, 0.4))
	_heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pill.add_child(_heart)
	var beat: = _heart.create_tween().set_loops()
	beat.tween_property(_heart, "scale", Vector2.ONE * 1.25, 0.14).set_trans(Tween.TRANS_SINE)
	beat.tween_property(_heart, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_SINE)
	beat.tween_interval(1.1)
	for l in LINKS:
		var tile: Color = l[2]
		var b: = _button(tile, tile.darkened(0.25), str(l[4]))
		b.text = str(l[0])
		b.tooltip_text = str(l[3])
		if str(l[3]) == "Discord":
			var img: = Image.new()
			if img.load_svg_from_string(DISCORD_SVG) == OK:
				b.icon = ImageTexture.create_from_image(img)
				b.expand_icon = true
				b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				b.add_theme_constant_override("icon_max_width", 20)
				for st in ["normal", "hover", "pressed"]:
					var sb: StyleBoxFlat = b.get_theme_stylebox(st)
					sb.content_margin_left = 4
					sb.content_margin_right = 4
					sb.content_margin_top = 4
					sb.content_margin_bottom = 4
			else:
				b.text = "Discord"
		b.custom_minimum_size.x = 38.0 if str(l[0]).length() > 1 else HEIGHT
		b.add_theme_font_override("font", UiKit.FONT_TITLE)
		b.add_theme_font_size_override("font_size", int(l[1]))
		for c in ["font_color", "font_hover_color", "font_pressed_color"]:
			b.add_theme_color_override(c, Color.WHITE)
		_box.add_child(b)




func _button(bg: Color, edge: Color, url: String) -> Button:
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.custom_minimum_size.y = HEIGHT
	for st in ["normal", "hover", "pressed"]:
		var sb: = StyleBoxFlat.new()
		sb.bg_color = bg.lightened(0.14) if st == "hover" else (bg.darkened(0.08) if st == "pressed" else bg)
		sb.border_color = edge
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(4)
		sb.anti_aliasing = true
		sb.content_margin_left = 2
		sb.content_margin_right = 2
		sb.shadow_color = Color(0, 0, 0, 0.25)
		sb.shadow_size = 2
		sb.shadow_offset = Vector2(0, 1)
		b.add_theme_stylebox_override(st, sb)
	if url != "":
		b.pressed.connect( func(): OS.shell_open(url))
	b.resized.connect( func(): b.pivot_offset = b.size * 0.5)
	b.mouse_entered.connect( func(): _grow(b, 1.08))
	b.mouse_exited.connect( func(): _grow(b, 1.0))
	return b








const PICS: = {"golden_poring": "res://assets/brand/support_golden_poring.png", "angeling": "res://assets/brand/support_angeling.png"}




const ANIMS: = {"angeling": ["res://assets/brand/support_angeling_anim.png", 38, 8, Vector2i(230, 250), 12.0]}
const BROWN: = Color(0.5, 0.26, 0.2)
const INK: = Color(0.3, 0.22, 0.2)
var _win: Dictionary = {}


func _toggle_card() -> void :
	if not _win.is_empty() and is_instance_valid(_win.root):
		_win.shut.call()
		return
	if world == null or world.menus == null:
		return
	var menus = world.menus
	var shade: = UiKit.backdrop(0.6)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var win: Dictionary = UiStyles.ro_window(tr("Apoya Midgard Survivors ♥"), UiKit.FONT_TITLE)
	var root: Control = win.root
	add_child(root)


	var frame: StyleBoxFlat = (win.body.get_parent() as PanelContainer).get_theme_stylebox("panel").duplicate()
	frame.bg_color = Color(frame.bg_color, 1.0)
	frame.content_margin_left = 16
	frame.content_margin_right = 16
	frame.content_margin_top = 12
	frame.content_margin_bottom = 12
	(win.body.get_parent() as PanelContainer).add_theme_stylebox_override("panel", frame)
	var w: = {"root": root, "body": win.body, "shut": func():
		if is_instance_valid(shade):
			shade.queue_free()
		if is_instance_valid(root):
			root.queue_free()
		_win = {}}
	_win = w
	shade.gui_input.connect( func(ev):
		if ev is InputEventMouseButton and ev.pressed:
			w.shut.call())
	var body: VBoxContainer = w.body
	body.add_theme_constant_override("separation", 6)
	var touch: bool = menus.touch_ui()
	var width: = 680.0

	var code: = ""
	if world.friends != null:
		code = str(world.friends.me())
	body.add_child(_step("1", tr("Copia tu código de amigo")))
	var code_box: = PanelContainer.new()
	var cb: = _flat(UiKit.panel_box(Color(0.95, 0.97, 1.0), Color(0.6, 0.7, 0.95), 8, 1))
	cb.set_content_margin_all(6)
	cb.content_margin_left = 12
	code_box.add_theme_stylebox_override("panel", cb)
	body.add_child(code_box)
	var crow: = HBoxContainer.new()
	crow.add_theme_constant_override("separation", 10)
	code_box.add_child(crow)
	var shown: = UiKit.label(code if code != "" else "...", 22, Color(0.12, 0.25, 0.75), true)
	shown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shown.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crow.add_child(shown)
	var copy: = UiKit.button(tr("Copiar código"), true)
	copy.focus_mode = Control.FOCUS_NONE
	copy.custom_minimum_size = Vector2(150, 40)
	copy.disabled = code == ""
	copy.pressed.connect( func():
		UiKit.copy(code)
		copy.text = tr("¡Copiado!"))
	crow.add_child(copy)
	var paste: = UiKit.label(tr("En Ko-fi, pégalo en el mensaje (Ctrl+V). Así el título llega solo, en minutos."), 12, INK)
	paste.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	paste.custom_minimum_size.x = width
	body.add_child(paste)

	body.add_child(_step("2", tr("Elige cómo apoyar en Ko-fi")))
	var cards: = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 10)
	body.add_child(cards)
	cards.add_child(_reward("golden_poring", tr("Un apoyo"), tr("Cualquier monto, una vez."), [
		tr("Título Golden Poring"), tr("Nombre dorado")]))
	cards.add_child(_reward("angeling", tr("Membresía mensual"), tr("Mientras sigas siendo miembro."), [
		tr("Título Angeling"), tr("Nombre rosa"), tr("Aura en Prontera")]))
	var note: = UiKit.label(tr("El nombre se ve en Prontera, el chat y los rankings. Solo de adorno."), 11, Color(0.45, 0.4, 0.4))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size.x = width
	body.add_child(note)

	body.add_child(_step("3", tr("¿Ya apoyaste y olvidaste el código?")))
	var claim_row: = HBoxContainer.new()
	claim_row.add_theme_constant_override("separation", 6)
	body.add_child(claim_row)
	var kofi_name: = LineEdit.new()
	kofi_name.add_theme_color_override("font_color", Color(0.15, 0.15, 0.2))
	kofi_name.add_theme_color_override("font_placeholder_color", Color(0.42, 0.42, 0.48))
	var lsb: = _flat(UiKit.panel_box(Color(1, 1, 1), Color(0.78, 0.72, 0.7), 6, 1))
	lsb.content_margin_left = 8
	kofi_name.add_theme_stylebox_override("normal", lsb)
	kofi_name.add_theme_stylebox_override("focus", lsb)
	kofi_name.placeholder_text = tr("El nombre que usaste en Ko-fi")
	kofi_name.custom_minimum_size = Vector2(300, 36)
	kofi_name.max_length = 48
	kofi_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	claim_row.add_child(kofi_name)
	var claim: = UiKit.button(tr("Reclamar"))
	claim.focus_mode = Control.FOCUS_NONE
	claim.custom_minimum_size = Vector2(120, 36)
	claim_row.add_child(claim)
	var said: = UiKit.label("", 12, INK)
	said.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	said.custom_minimum_size.x = width
	body.add_child(said)
	claim.pressed.connect( func(): _claim(kofi_name.text, claim, said))
	kofi_name.text_submitted.connect( func(_t): _claim(kofi_name.text, claim, said))

	var foot: = HBoxContainer.new()
	foot.alignment = BoxContainer.ALIGNMENT_END
	foot.add_theme_constant_override("separation", 8)
	body.add_child(foot)
	var close: = UiKit.button(tr("Cerrar"))
	close.focus_mode = Control.FOCUS_NONE
	close.pressed.connect(w.shut)
	foot.add_child(close)
	var go: = UiKit.button(tr("Copiar código e ir a Ko-fi"), true)
	go.focus_mode = Control.FOCUS_NONE
	go.custom_minimum_size.x = 220
	go.pressed.connect( func():
		if code != "":
			UiKit.copy(code)
			copy.text = tr("¡Copiado!")
		OS.shell_open(COFFEE_URL))
	foot.add_child(go)
	for b in [close, go]:
		if touch:
			(b as Button).custom_minimum_size.y = 46
	for b in [copy, claim, close, go]:
		_flat_button(b)
	root.reset_size()
	var view: = root.get_viewport_rect().size
	root.position = ((view - root.size) * 0.5).floor()



static func _flat(sb: StyleBoxFlat) -> StyleBoxFlat:
	sb.shadow_size = 0
	sb.shadow_color = Color(0, 0, 0, 0)
	return sb



static func _flat_button(b: Button) -> void :
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		var s: = b.get_theme_stylebox(st)
		if s is StyleBoxFlat:
			b.add_theme_stylebox_override(st, _flat((s as StyleBoxFlat).duplicate()))



func _step(n: String, text: String) -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var badge: = Label.new()
	badge.text = n
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.custom_minimum_size = Vector2(22, 22)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.add_theme_font_override("font", UiKit.FONT_TITLE)
	badge.add_theme_font_size_override("font_size", 14)
	badge.add_theme_color_override("font_color", Color.WHITE)
	var bsb: = _flat(UiKit.panel_box(Color(0.93, 0.4, 0.45), Color(0.93, 0.4, 0.45), 11, 1))
	bsb.content_margin_top = 0
	bsb.content_margin_bottom = 0
	badge.add_theme_stylebox_override("normal", bsb)
	row.add_child(badge)
	var l: = UiKit.label(text, 15, BROWN, true)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(l)
	return row



func _reward(id: String, head: String, sub: String, gives: Array) -> Control:
	var card: = PanelContainer.new()
	var col: Color = world.titles.support_color(id, false) if world.titles != null else BROWN
	var sb: = _flat(UiKit.panel_box(Color(1.0, 0.985, 0.97), Color(col, 0.55), 8, 1))
	sb.set_content_margin_all(8)
	card.add_theme_stylebox_override("panel", sb)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)
	var tex: Texture2D = load(PICS[id]) if ResourceLoader.exists(PICS[id]) else null
	if ANIMS.has(id) and ResourceLoader.exists(str(ANIMS[id][0])):
		row.add_child(_anim_pic(ANIMS[id]))
	elif tex != null:
		var pic: = TextureRect.new()
		pic.texture = tex
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.custom_minimum_size = Vector2(100, 152)
		row.add_child(pic)
	var info: = VBoxContainer.new()
	info.add_theme_constant_override("separation", 5)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	info.add_child(UiKit.label(head, 15, col, true))
	info.add_child(UiKit.label(sub, 11, Color(0.45, 0.4, 0.4)))
	if world.titles != null:
		var chip_row: = HBoxContainer.new()
		chip_row.add_child(world.titles.chip(id, 12))
		info.add_child(chip_row)
	for g in gives:
		var l: = UiKit.label("• " + str(g), 12, INK)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 160
		info.add_child(l)
	return card




func _anim_pic(a: Array) -> Control:
	var atlas: = AtlasTexture.new()
	atlas.atlas = load(str(a[0]))
	var n: = int(a[1])
	var cols: = int(a[2])
	var fsize: Vector2i = a[3]
	atlas.region = Rect2(Vector2.ZERO, Vector2(fsize))
	var pic: = TextureRect.new()
	pic.texture = atlas
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.custom_minimum_size = Vector2(fsize) * 0.62
	var tw: = pic.create_tween().set_loops()
	tw.tween_method( func(f: float):
		var i: = mini(int(f), n - 1)
		atlas.region = Rect2(Vector2((i % cols) * fsize.x, (i / cols) * fsize.y), Vector2(fsize)), 0.0, float(n), n / float(a[4]))
	return pic




func _claim(kofi: String, btn: Button, said: Label) -> void :
	kofi = kofi.strip_edges()
	if kofi.length() < 2 or world.board == null:
		said.text = tr("Escribe el nombre que usaste en Ko-fi.")
		return
	btn.disabled = true
	said.text = tr("Buscando...")
	world.board._call("claim_kofi", {"p_player": Leaderboard.player_id(), "p_kofi": kofi}, func(ok: bool, d):
		if not is_instance_valid(btn):
			return
		btn.disabled = false
		if not ok or not d is Dictionary:
			said.text = tr("Sin conexión. Inténtalo más tarde.")
			return
		if bool(d.get("ok", false)):
			var got: = []
			if bool(d.get("golden_poring", false)):
				got.append("Golden Poring")
			if bool(d.get("angeling", false)):
				got.append("Angeling")
			said.add_theme_color_override("font_color", Color(0.15, 0.55, 0.25))
			said.text = tr("¡Listo! Ya tienes: %s. ¡Gracias!") % ", ".join(got)
			if world.titles != null:
				world.titles.fetch_special()
		elif str(d.get("why", "")) == "wait":
			said.text = tr("Demasiados intentos hoy. Prueba mañana o escríbenos en Discord.")
		else:
			said.text = tr("No encontramos un apoyo sin reclamar con ese nombre. Revisa cómo aparece en Ko-fi, o escríbenos en Discord."))


func _grow(b: Button, k: float) -> void :
	b.create_tween().tween_property(b, "scale", Vector2.ONE * k, 0.1).set_trans(Tween.TRANS_SINE)


func _notification(what: int) -> void :
	if what == NOTIFICATION_TRANSLATION_CHANGED and _pill != null:
		_pill.text = tr("Cómprame un café")


func _place_heart() -> void :
	_heart.pivot_offset = _heart.size * 0.5
	_heart.position = Vector2(_pill.size.x - 25.0, (_pill.size.y - _heart.size.y) * 0.5 - 2.0)


func _process(_delta: float) -> void :
	var on: bool = world != null and world.menus != null and world.menus.mode() == "class_select"
	_box.visible = on
	if not on and not _win.is_empty() and is_instance_valid(_win.root):
		_win.shut.call()
	if on:
		_place_heart()

	var label: Label = world._fps_label if world != null else null
	if label != null and is_instance_valid(label):
		var side: = 0.0 if on else 1.0
		if label.anchor_left != side:
			label.anchor_left = side
			label.anchor_right = side
			label.offset_left = 8.0 if on else -90.0
			label.offset_right = 90.0 if on else -8.0
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if on else HORIZONTAL_ALIGNMENT_RIGHT
