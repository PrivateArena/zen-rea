extends CanvasLayer






signal closed


func _question_list() -> Array:
	return [[tr("¿Cuál es tu monstruo favorito?"), "monster"], [tr("¿Qué MVP respetas más?"), "mvp"], 
		[tr("¿Qué oficio te gusta más?"), "job"], [tr("¿Qué mascota te quedarías?"), "pet"]]


const NAME_RE: = "^[A-Za-z0-9_.-]{3,20}$"
const INK: = Color(0.12, 0.2, 0.45)
const BAD: = Color(0.72, 0.16, 0.12)
const GOOD: = Color(0.15, 0.5, 0.2)

var world: Node
var cloud: Node

var tab: = "create"
var _body: VBoxContainer
var _note: Label
var _busy: = false



func open(w: Node, start_tab: = "") -> void :
	world = w
	cloud = w.get("cloud")
	layer = 70
	process_mode = Node.PROCESS_MODE_ALWAYS
	if start_tab != "":
		tab = start_tab
	elif cloud != null and cloud.user() != "":
		tab = "account"


	if cloud != null and cloud.has_signal("changed"):
		cloud.changed.connect(_on_cloud_changed)
	_build()


func _on_cloud_changed() -> void :
	if tab == "account" and not _busy and is_inside_tree():
		_build()


func _build() -> void :
	for c in get_children():
		c.queue_free()
	var root: = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)
	root.add_child(UiKit.backdrop(0.55))
	var view: = root.get_viewport().get_visible_rect().size if root.is_inside_tree() else Vector2(1280, 720)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var panel: = PanelContainer.new()
	var box: = UiKit.panel_box(Color(0.97, 0.98, 1.0), Color(0.55, 0.65, 0.9), 12, 1)
	box.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", box)
	center.add_child(panel)

	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(400, minf(620.0, view.y * 0.88))
	panel.add_child(scroll)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 8)
	_body.custom_minimum_size.x = 384
	scroll.add_child(_body)
	var head: = HBoxContainer.new()
	_body.add_child(head)
	var title: = UiKit.label(tr("Cuenta"), 18, INK, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var x: = UiKit.button("×")
	x.custom_minimum_size = Vector2(34, 30)
	x.pressed.connect(close)
	head.add_child(x)
	if cloud == null:
		_body.add_child(UiKit.label(tr("Sin conexión: prueba de nuevo."), 13, BAD))
		return
	if tab == "account" and cloud.user() != "":
		_account()
	elif tab in ["change_pass", "change_q"] and cloud.user() != "":
		_change(tab == "change_q")
	else:
		if tab == "account":
			tab = "create"
		_tabs()
		match tab:
			"guest":
				_guest()
			"login":
				_login()
			"recover":
				_recover()
			_:
				_create()
	_note = UiKit.label("", 12, BAD)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note.custom_minimum_size.x = 380
	_body.add_child(_note)


func _tabs() -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	_body.add_child(row)
	for t in [["guest", tr("Invitado")], ["login", tr("Entrar")], ["create", tr("Crear cuenta")]]:
		var id: String = t[0]
		var b: = UiKit.button(t[1], tab == id or (tab == "recover" and id == "login"))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.y = 34
		b.pressed.connect( func():
			tab = id
			_build())
		row.add_child(b)


func _text(t: String, size: = 12, col: = UiKit.MUTED) -> Label:
	var l: = UiKit.label(t, size, col)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 380
	_body.add_child(l)
	return l


func _field(label: String, secret: = false) -> LineEdit:
	_body.add_child(UiKit.label(label, 13, UiKit.TEXT, true))
	var e: = LineEdit.new()
	e.secret = secret
	e.max_length = 64 if secret else 20



	e.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_PASSWORD if secret else LineEdit.KEYBOARD_TYPE_URL
	e.custom_minimum_size = Vector2(380, 36)
	e.add_theme_font_size_override("font_size", 15)
	e.add_theme_color_override("font_color", UiKit.TEXT)
	e.add_theme_color_override("caret_color", UiKit.TEXT)
	for st in ["normal", "focus"]:
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color.WHITE
		sb.border_color = Color(0.45, 0.55, 0.85) if st == "focus" else Color(0.72, 0.76, 0.88)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(8)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		e.add_theme_stylebox_override(st, sb)
	if not secret:
		_body.add_child(e)
		return e

	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	_body.add_child(row)
	e.custom_minimum_size.x = 0
	e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(e)
	var eye: = UiKit.button(tr("Mostrar"))
	eye.custom_minimum_size = Vector2(84, 36)
	eye.focus_mode = Control.FOCUS_NONE
	eye.add_theme_font_size_override("font_size", 12)
	eye.pressed.connect( func():
		e.secret = not e.secret
		eye.text = tr("Mostrar") if e.secret else tr("Ocultar"))
	row.add_child(eye)
	row.custom_minimum_size.x = 380
	return e


func _go(text: String) -> Button:
	var b: = UiKit.button(text, true)
	b.custom_minimum_size = Vector2(380, 44)
	_body.add_child(b)
	return b


func _say(text: String, ok: = false) -> void :
	if _note != null and is_instance_valid(_note):
		_note.text = text
		_note.add_theme_color_override("font_color", GOOD if ok else BAD)




func _guest() -> void :
	_text(tr("Juegas como invitado: tu progreso vive solo en este dispositivo. Con una cuenta se guarda en la nube y puedes jugar en PC y celular, o recuperarlo si cambias de equipo."), 13, UiKit.TEXT)
	var b: = _go(tr("Seguir como invitado"))
	b.pressed.connect(close)


func _login() -> void :
	var u: = _field(tr("Usuario"))
	var p: = _field(tr("Contraseña"), true)
	_text(tr("Al entrar, si este dispositivo y la cuenta tienen progreso distinto, eliges cuál conservar."))
	var b: = _go(tr("Entrar"))
	var send: = func():
		if _busy:
			return
		if u.text.strip_edges() == "" or p.text == "":
			_say(tr("Escribe tu usuario y tu contraseña."))
			return
		_busy = true
		_say(tr("Conectando..."), true)
		cloud.login(u.text.strip_edges(), p.text, func(err: String):
			_busy = false
			if err != "":
				_say(err)
				return
			close())
	b.pressed.connect(send)
	p.text_submitted.connect( func(_t): send.call())
	var forgot: = UiKit.button(tr("¿Olvidaste tu contraseña?"))
	forgot.flat = true
	forgot.pressed.connect( func():
		tab = "recover"
		_build())
	_body.add_child(forgot)


func _create() -> void :
	var u: = _field(tr("Usuario"))
	var p: = _field(tr("Contraseña"), true)
	var p2: = _field(tr("Repite la contraseña"), true)
	_body.add_child(HSeparator.new())
	_body.add_child(UiKit.label(tr("Preguntas de seguridad (opcional)"), 14, INK, true))
	var want: = CheckBox.new()
	want.text = tr("Configurar preguntas para recuperar mi contraseña si la olvido")
	want.button_pressed = true
	for st in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		want.add_theme_color_override(st, UiKit.TEXT)
	want.add_theme_font_size_override("font_size", 12)
	want.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	want.custom_minimum_size.x = 380
	_body.add_child(want)
	_text(tr("Sin correo, si olvidas la contraseña estas 4 respuestas son la única forma de recuperar la cuenta. Recuérdalas o anótalas en un lugar seguro."))
	var picks: = _questions()
	want.toggled.connect( func(on: bool):
		for q in picks:
			(q as Button).disabled = not on)
	_text(tr("El progreso de este dispositivo (personajes, equipo, cartas...) se sube a la cuenta."), 12, UiKit.TEXT)
	var b: = _go(tr("Crear cuenta"))
	b.pressed.connect( func():
		if _busy:
			return
		var user_name: = u.text.strip_edges()
		if not RegEx.create_from_string(NAME_RE).search(user_name):
			_say(cloud.account_error("bad_name"))
			return
		if p.text.length() < 6:
			_say(cloud.account_error("bad_pass"))
			return
		if p.text != p2.text:
			_say(tr("Las contraseñas no coinciden."))
			return
		var answers: = ""
		if want.button_pressed:
			answers = _answers(picks)
			if answers == "":
				_say(tr("Elige una respuesta para cada pregunta (o desmarca las preguntas)."))
				return
		_busy = true
		_say(tr("Creando la cuenta..."), true)
		cloud.register(user_name, p.text, answers, func(err: String):
			_busy = false
			if err != "":
				_say(err)
				return
			_say(tr("¡Cuenta creada! Tu progreso se está subiendo."), true)
			get_tree().create_timer(1.2, true, false, true).timeout.connect(close)))


func _recover() -> void :
	_body.add_child(UiKit.label(tr("Recuperar la cuenta"), 14, INK, true))
	_text(tr("Responde tus 4 preguntas de seguridad y elige una contraseña nueva."))
	var u: = _field(tr("Usuario"))
	var picks: = _questions()
	var p: = _field(tr("Contraseña nueva"), true)
	var p2: = _field(tr("Repite la contraseña"), true)
	var b: = _go(tr("Recuperar y entrar"))
	b.pressed.connect( func():
		if _busy:
			return
		var answers: = _answers(picks)
		if u.text.strip_edges() == "" or answers == "":
			_say(tr("Escribe tu usuario y responde las 4 preguntas."))
			return
		if p.text.length() < 6:
			_say(cloud.account_error("bad_pass"))
			return
		if p.text != p2.text:
			_say(tr("Las contraseñas no coinciden."))
			return
		_busy = true
		_say(tr("Conectando..."), true)
		cloud.login(u.text.strip_edges(), p.text, func(err: String):
			_busy = false
			if err != "":
				_say(tr("Usuario o respuestas incorrectas.") if err == cloud.account_error("bad") else err)
				return
			close(), answers))
	var back: = UiKit.button(tr("Volver a Entrar"))
	back.flat = true
	back.pressed.connect( func():
		tab = "login"
		_build())
	_body.add_child(back)



func _account() -> void :
	_body.add_child(UiKit.label(tr("Sesión iniciada como %s") % cloud.user(), 15, UiKit.TEXT, true))
	var state: String = {"syncing": tr("Sincronizando..."), "ok": tr("Sincronizado"), "later": tr("Guardado aquí; se sube a la nube en unos minutos"), "offline": Leaderboard.offline_text(tr("Sin conexión (se reintenta solo)")), 
		"conflict": tr("Elige qué partida conservar"), "error": tr("La nube no reconoce este dispositivo"), 
		"too_big": tr("Tu partida es demasiado grande para la nube: escríbenos en Discord")}.get(cloud.status, tr("Activado"))
	_text(tr("Tu progreso se guarda en la nube: entra con este usuario en otro PC o celular para seguir.") + "\n" + state)
	var sync: = _go(tr("Sincronizar ahora"))
	sync.pressed.connect( func():
		cloud.sync_now(false)
		_say(tr("Sincronizando..."), true))


	for t in [["change_pass", tr("Cambiar contraseña")], ["change_q", tr("Cambiar preguntas de seguridad")]]:
		var id: String = t[0]
		var b: = UiKit.button(t[1])
		b.custom_minimum_size = Vector2(380, 36)
		b.pressed.connect( func():
			tab = id
			_build())
		_body.add_child(b)
	var out: = UiKit.button(tr("Cerrar sesión"))
	out.custom_minimum_size = Vector2(380, 36)
	out.add_theme_color_override("font_color", BAD)
	out.pressed.connect( func():
		cloud.logout()
		tab = "login"
		_build()
		_say(tr("Sesión cerrada: tu progreso se queda en este dispositivo y en la cuenta."), true))
	_body.add_child(out)




func _change(questions: bool) -> void :
	_body.add_child(UiKit.label(tr("Cambiar preguntas de seguridad") if questions else tr("Cambiar contraseña"), 14, INK, true))
	var cur: = _field(tr("Contraseña actual"), true)
	var p: LineEdit = null
	var p2: LineEdit = null
	var picks: Array = []
	if questions:
		_text(tr("Sin correo, si olvidas la contraseña estas 4 respuestas son la única forma de recuperar la cuenta. Recuérdalas o anótalas en un lugar seguro."))
		picks = _questions()
	else:
		p = _field(tr("Contraseña nueva"), true)
		p2 = _field(tr("Repite la contraseña"), true)
	var b: = _go(tr("Guardar"))
	b.pressed.connect( func():
		if _busy:
			return
		if cur.text == "":
			_say(tr("Escribe tu contraseña actual."))
			return
		var new_pass: = ""
		var answers: = ""
		if questions:
			answers = _answers(picks)
			if answers == "":
				_say(tr("Elige una respuesta para cada pregunta."))
				return
		else:
			if p.text.length() < 6:
				_say(cloud.account_error("bad_pass"))
				return
			if p.text != p2.text:
				_say(tr("Las contraseñas no coinciden."))
				return
			new_pass = p.text
		_busy = true
		_say(tr("Conectando..."), true)
		cloud.change(cur.text, new_pass, answers, func(err: String):
			_busy = false
			if err != "":
				_say(err)
				return
			tab = "account"
			_build()
			_say(tr("Preguntas guardadas.") if questions else tr("Contraseña cambiada."), true)))
	var back: = UiKit.button(tr("Volver"))
	back.flat = true
	back.pressed.connect( func():
		tab = "account"
		_build())
	_body.add_child(back)







func _questions() -> Array:
	var out: = []
	for q in _question_list():
		_body.add_child(UiKit.label(str(q[0]), 12, UiKit.TEXT, true))
		var pick: = Button.new()
		pick.custom_minimum_size = Vector2(380, 34)
		pick.alignment = HORIZONTAL_ALIGNMENT_LEFT
		pick.text = tr("Elegir...")
		pick.set_meta("id", "")
		pick.add_theme_font_size_override("font_size", 13)
		for st in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
			pick.add_theme_color_override(st, UiKit.TEXT)
		pick.add_theme_color_override("font_disabled_color", UiKit.MUTED)
		for st in ["normal", "hover", "pressed", "focus", "disabled"]:
			pick.add_theme_stylebox_override(st, _field_box(st))
		var kind: = str(q[1])
		var title: = str(q[0])
		pick.pressed.connect( func(): _search_list(pick, kind, title))
		_body.add_child(pick)
		out.append(pick)
	return out


static func _field_box(st: String) -> StyleBoxFlat:
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(0.94, 0.95, 0.98) if st == "disabled" else (Color(0.96, 0.97, 1.0) if st == "hover" else Color.WHITE)
	sb.border_color = Color(0.45, 0.55, 0.85) if st in ["focus", "hover"] else Color(0.72, 0.76, 0.88)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	return sb




func _search_list(target: Button, kind: String, title: String) -> void :
	var shade: = Control.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	var dim: = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.35)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.add_child(dim)
	dim.gui_input.connect( func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			shade.queue_free())
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.add_child(center)
	var panel: = PanelContainer.new()
	var box: = UiKit.panel_box(Color(0.97, 0.98, 1.0), Color(0.55, 0.65, 0.9), 12, 1)
	box.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel", box)
	center.add_child(panel)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	panel.add_child(col)
	var head: = HBoxContainer.new()
	col.add_child(head)
	var t: = UiKit.label(title, 14, INK, true)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(t)
	var x: = UiKit.button("×")
	x.custom_minimum_size = Vector2(32, 28)
	x.pressed.connect(shade.queue_free)
	head.add_child(x)
	var search: = LineEdit.new()
	search.placeholder_text = tr("Buscar...")
	search.custom_minimum_size = Vector2(360, 34)
	search.add_theme_font_size_override("font_size", 14)
	search.add_theme_color_override("font_color", UiKit.TEXT)
	search.add_theme_color_override("caret_color", UiKit.TEXT)
	search.add_theme_stylebox_override("normal", _field_box("normal"))
	search.add_theme_stylebox_override("focus", _field_box("focus"))
	col.add_child(search)
	var list: = ItemList.new()
	var view: = get_viewport().get_visible_rect().size
	list.custom_minimum_size = Vector2(360, minf(360.0, view.y * 0.55))
	list.add_theme_font_size_override("font_size", 14)
	list.add_theme_color_override("font_color", UiKit.TEXT)
	list.add_theme_color_override("font_hovered_color", UiKit.TEXT)
	list.add_theme_color_override("font_selected_color", Color.WHITE)
	var lb: = _field_box("normal")
	list.add_theme_stylebox_override("panel", lb)
	list.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	var sel: = StyleBoxFlat.new()
	sel.bg_color = Color(0.3, 0.45, 0.85)
	sel.set_corner_radius_all(6)
	list.add_theme_stylebox_override("selected", sel)
	list.add_theme_stylebox_override("selected_focus", sel)
	var hov: = StyleBoxFlat.new()
	hov.bg_color = Color(0.9, 0.93, 1.0)
	hov.set_corner_radius_all(6)
	list.add_theme_stylebox_override("hovered", hov)
	col.add_child(list)
	var all: = _options(kind)
	var fill: = func(q: String):
		list.clear()
		var want: = _plain(q)
		for pair in all:
			if want == "" or _plain(str(pair[1])).contains(want):
				list.add_item(str(pair[1]))
				list.set_item_metadata(list.item_count - 1, str(pair[0]))
	fill.call("")
	var take: = func(i: int):
		if i < 0 or i >= list.item_count:
			return
		target.text = list.get_item_text(i)
		target.set_meta("id", str(list.get_item_metadata(i)))
		shade.queue_free()
	search.text_changed.connect(fill)
	search.text_submitted.connect( func(_t): take.call(0))
	list.item_clicked.connect( func(i: int, _at: Vector2, _b: int): take.call(i))

	if not MouseWalk.touch():
		search.grab_focus.call_deferred()



static func _plain(t: String) -> String:
	var out: = t.to_lower().strip_edges()
	for pair in [["á", "a"], ["é", "e"], ["í", "i"], ["ó", "o"], ["ú", "u"], ["ü", "u"], ["ñ", "n"], ["ã", "a"], ["õ", "o"], ["ç", "c"], ["â", "a"], ["ê", "e"], ["ô", "o"]]:
		out = out.replace(pair[0], pair[1])
	return out



func _answers(picks: Array) -> String:
	var ids: = []
	for pick: Button in picks:
		var id: = str(pick.get_meta("id", ""))
		if id == "":
			return ""
		ids.append(id)
	return "|".join(ids)



static func _options(kind: String) -> Array:
	var out: = []
	var seen: = {}
	match kind:
		"monster", "mvp":
			for id in GameData.MONSTERS:
				var m: Dictionary = GameData.MONSTERS[id]
				var is_mvp: = bool(m.get("mvp", false))
				if (kind == "mvp") != is_mvp or (kind == "monster" and not m.has("card")):
					continue
				var n: = TranslationServer.translate(str(m.name))
				if not seen.has(n):
					seen[n] = true
					out.append([str(id), n])
		"job":
			for cid in GameData.CLASSES:
				var c: Dictionary = GameData.CLASSES[cid]
				for j in [c, c.get("job2", {}), c.get("job2_alt", {}), (c.get("job2", {}) as Dictionary).get("trans", {}), (c.get("job2_alt", {}) as Dictionary).get("trans", {})]:
					if (j as Dictionary).has("name"):
						var jid: = str(j.get("id", cid))
						var n: = TranslationServer.translate(str(j.name))
						if not seen.has(jid):
							seen[jid] = true
							out.append([jid, n])
		"pet":
			for id in GameData.PETS:
				out.append([str(id), TranslationServer.translate(str(GameData.PETS[id].name))])
	out.sort_custom( func(a, b): return str(a[1]).naturalnocasecmp_to(str(b[1])) < 0)
	return out


func close() -> void :
	closed.emit()
	queue_free()
