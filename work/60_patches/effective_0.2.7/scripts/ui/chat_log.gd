extends PanelContainer







const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")
const TownChannel = preload("res://scripts/net/town_channel.gd")
const EmotePicker = preload("res://scripts/ui/emote_picker.gd")

const HEAD_BUTTON: = Vector2(24, 22)
const HEIGHT: = 150.0
const ALL_COLOR: = Color(1.0, 1.0, 1.0)
const PARTY_COLOR: = Color(0.6, 0.88, 1.0)
const SYS_COLOR: = Color(1.0, 0.88, 0.45)

const TIME_COLOR: = Color(0.7, 0.72, 0.78)
const WHISPER_COLOR: = Color(1.0, 1.0, 0.25)

const FEAT_COLOR: = Color(1.0, 0.72, 0.3)

const WORLD_COLOR: = Color(0.6, 1.0, 0.75)

const SHOW_TIME: = 8.0
const FADE_TIME: = 0.6

var world: World
var crowd: TownCrowd
var _min_button: Button
var _seen_t: = 0.0
var _shown: = true

var _tab: = "world"
var _tabs: = {}
var _where: Label
var _text: RichTextLabel
var _invites: VBoxContainer

var emotes: Control


func setup(p_world: World, width: float, p_crowd: TownCrowd) -> void :
	world = p_world
	crowd = p_crowd
	custom_minimum_size = Vector2(width, 0)

	mouse_filter = Control.MOUSE_FILTER_PASS
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0, 0, 0, 0.5)
	box.set_corner_radius_all(3)
	box.set_content_margin_all(6)
	add_theme_stylebox_override("panel", box)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	add_child(col)
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 4)
	col.add_child(head)


	for t in [["world", tr("Mundo")], ["all", tr("Canal")], ["party", tr("Party")]]:
		var b: = Button.new()
		b.text = t[1]
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_override("font", World.RO_UI_FONT)
		b.add_theme_font_size_override("font_size", 11)
		b.custom_minimum_size = Vector2(58, 20)
		b.pressed.connect(_show_tab.bind(t[0]))
		head.add_child(b)
		_tabs[t[0]] = b
	_where = _label("", 11, SYS_COLOR)
	_where.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_where.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	head.add_child(_where)

	var gap: = Control.new()
	gap.custom_minimum_size.x = 10
	head.add_child(gap)

	if MouseWalk.touch():
		var write: = Button.new()
		write.text = tr("Escribir")
		write.focus_mode = Control.FOCUS_NONE
		write.add_theme_font_override("font", World.RO_UI_FONT)
		write.add_theme_font_size_override("font_size", 11)
		write.custom_minimum_size = Vector2(0, HEAD_BUTTON.y)
		write.pressed.connect( func():
			if crowd != null:
				crowd.open_chat())
		head.add_child(write)
	var sit: = Button.new()
	sit.text = tr("Sentarse")
	sit.tooltip_text = tr("Sentarte o levantarte (X)")
	sit.focus_mode = Control.FOCUS_NONE
	sit.add_theme_font_override("font", World.RO_UI_FONT)
	sit.add_theme_font_size_override("font_size", 11)
	sit.custom_minimum_size = Vector2(0, HEAD_BUTTON.y)
	sit.pressed.connect( func():
		var town = crowd.town if crowd != null else null
		if town != null and is_instance_valid(town):
			town.toggle_sit())
	head.add_child(sit)

	var friends: = Button.new()
	friends.focus_mode = Control.FOCUS_NONE
	friends.add_theme_font_override("font", World.RO_UI_FONT)
	friends.add_theme_font_size_override("font_size", 11)
	friends.custom_minimum_size = Vector2(0, HEAD_BUTTON.y)
	friends.pressed.connect( func(): world.menus.open_friends())
	head.add_child(friends)
	var count_friends: = func():
		if not is_instance_valid(friends) or world.friends == null:
			return
		var fr = world.friends
		friends.text = tr("Amigos") + ("  %d" % fr.online if fr.online > 0 else "")
		friends.add_theme_color_override("font_color", Color(1.0, 0.82, 0.3) if fr.requests > 0 else Color.WHITE)
		var tip: = tr("Tus amigos: dónde están y su canal")
		if fr.requests > 0:
			tip = tr_n("%d solicitud de amistad", "%d solicitudes de amistad", fr.requests) % fr.requests
		friends.tooltip_text = tip
	count_friends.call()
	if world.friends != null:
		world.friends.changed.connect(count_friends)
		tree_exiting.connect( func(): world.friends.changed.disconnect(count_friends))
	emotes = EmotePicker.new()
	emotes.tooltip_text = tr("Emociones")
	emotes.custom_minimum_size = HEAD_BUTTON
	emotes.size_flags_vertical = Control.SIZE_FILL
	if crowd != null:
		emotes.picked.connect(crowd.send_emote)
	head.add_child(emotes)
	_min_button = Button.new()
	_min_button.focus_mode = Control.FOCUS_NONE
	_min_button.add_theme_font_override("font", World.RO_UI_FONT)
	_min_button.add_theme_font_size_override("font_size", 12)
	_min_button.custom_minimum_size = HEAD_BUTTON
	_min_button.tooltip_text = tr("Minimizar / mostrar el chat")
	_min_button.pressed.connect( func():
		Save.set_setting("chat_min", not bool(Save.setting("chat_min", false)))
		_apply_min())
	head.add_child(_min_button)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true


	_text.meta_underlined = true
	_text.meta_clicked.connect( func(meta):
		if crowd == null:
			return

		if str(meta).begins_with("w:"):
			var m: = str(meta).substr(2)
			_world_menu(m.get_slice("|", 0).uri_decode(), m.get_slice("|", 1))
			return
		crowd.open_chat("/w %s " % str(meta).uri_decode()))
	_text.scroll_following = true

	_text.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_text.custom_minimum_size = Vector2(0, HEIGHT)
	_text.add_theme_font_override("normal_font", World.RO_UI_FONT)
	_text.add_theme_font_size_override("normal_font_size", 12)
	_text.add_theme_constant_override("outline_size", 3)
	_text.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	col.add_child(_text)
	_invites = VBoxContainer.new()
	_invites.add_theme_constant_override("separation", 3)
	col.add_child(_invites)
	world.channel.logged.connect( func():
		_seen_t = 0.0

		if not world.channel.lines.is_empty() and str(world.channel.lines[-1][0]) == "whisper":
			restore()
		_refresh())
	world.channel.changed.connect(_refresh)
	_show_tab("world")
	_apply_min()



func _world_menu(who: String, id: String) -> void :
	var wc: Node = world.channel.world_chat
	if wc == null:
		return
	var menu: = PopupMenu.new()
	menu.add_theme_font_override("font", World.RO_UI_FONT)
	menu.add_item((tr("Dejar de silenciar a %s") if wc.muted(who) else tr("Silenciar a %s")) % who, 0)
	if id != "":
		menu.add_item(tr("Reportar este mensaje"), 1)
	menu.id_pressed.connect( func(i: int):
		if i == 0:
			wc.set_muted(who, not wc.muted(who))
		elif i == 1:
			wc.report(id)
		menu.queue_free())
	menu.popup_hide.connect(menu.queue_free)
	add_child(menu)
	menu.popup(Rect2i(Vector2i(get_global_mouse_position()), Vector2i.ZERO))



func restore() -> void :
	if bool(Save.setting("chat_min", false)):
		Save.set_setting("chat_min", false)
		_apply_min()


func _apply_min() -> void :
	var small: = bool(Save.setting("chat_min", false))
	_text.visible = not small
	_invites.visible = not small or not world.channel.invites.is_empty()
	_min_button.text = "+" if small else "–"


	if grow_vertical == Control.GROW_DIRECTION_END:
		offset_bottom = offset_top
	else:
		offset_top = offset_bottom





func _process(delta: float) -> void :
	if not visible:
		return
	_seen_t += delta
	var wanted: bool = _seen_t < SHOW_TIME or not world.channel.invites.is_empty() or get_global_rect().has_point(get_global_mouse_position()) or (crowd != null and crowd.typing())\
	or (emotes != null and emotes.is_open())
	modulate.a = move_toward(modulate.a, 1.0 if wanted else 0.0, delta / FADE_TIME)
	var shown: = modulate.a > 0.05
	if shown != _shown:
		_shown = shown
		_take_mouse(self, shown)


func _take_mouse(c: Control, on: bool) -> void :
	if not c.has_meta("mouse"):
		c.set_meta("mouse", c.mouse_filter)
	c.mouse_filter = int(c.get_meta("mouse")) if on else Control.MOUSE_FILTER_IGNORE
	for k in c.get_children():
		if k is Control:
			_take_mouse(k, on)


func _label(text: String, size: int, color: Color) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", World.RO_UI_FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_constant_override("outline_size", 3)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	return l



func _my_class() -> String:
	var town = crowd.town if crowd != null else null
	return str(town.class_id) if town != null and is_instance_valid(town) else ""


func _show_tab(tab: String) -> void :
	_tab = tab
	for k in _tabs:
		_tabs[k].button_pressed = k == tab
	_refresh()


func _refresh() -> void :
	var ch: TownChannel = world.channel
	if ch.state == "lost":
		_where.text = tr("Reconectando...")
	elif ch.is_in():
		_where.text = tr("Canal %d  ·  %d / %d") % [ch.number, ch.members.size(), TownChannel.MAX_PLAYERS]
	else:
		_where.text = tr("Party") if world.net.mode != "" else ""
	var out: = PackedStringArray()
	for l in ch.lines:
		var kind: = str(l[0])

		if _tab == "party" and not kind in ["party", "whisper"]:
			continue
		if _tab == "all" and kind in ["world", "wfeat"]:
			continue
		var col: Color = {"party": PARTY_COLOR, "sys": SYS_COLOR, "whisper": WHISPER_COLOR, "feat": FEAT_COLOR, 
			"world": WORLD_COLOR, "wfeat": FEAT_COLOR}.get(kind, ALL_COLOR)
		var text: = str(l[1]).replace("[", "[lb]")


		if kind in ["world", "wfeat"]:
			var wsaid: = text.get_slice(" : ", 0)
			var wid: = str(l[5]) if l.size() > 5 else ""
			if " : " in text and wsaid != Save.char_name(_my_class()):
				text = "[url=w:%s|%s]%s[/url]%s" % [wsaid.uri_encode(), wid, wsaid, text.substr(wsaid.length())]
			var wat: = ("[color=#%s]%s[/color] " % [TIME_COLOR.to_html(false), str(l[2])]) if l.size() > 2 else ""
			out.append(wat + "[color=#%s][lb]%s] %s[/color]" % [col.to_html(false), tr("Mundo"), text])
			continue

		if kind != "sys" and NameFilter.dev_line(str(l[1])):
			col = NameFilter.DEV_COLOR
			text = "Dev · " + text

		var at: = ("[color=#%s]%s[/color] " % [TIME_COLOR.to_html(false), str(l[2])]) if l.size() > 2 else ""

		if kind in ["all", "party", "feat"] and " : " in text:
			var who: = text.get_slice(" : ", 0)
			var bare: = who.trim_prefix("Dev · ")
			if bare != Save.char_name(_my_class()) and not bare.contains("[") and bare.strip_edges() != "":
				text = "[url=%s]%s[/url]%s" % [bare.uri_encode(), who, text.substr(who.length())]

		var sup: = str(l[4]) if l.size() > 4 else ""
		if sup != "" and " : " in text:
			var sname: = text.get_slice(" : ", 0)
			text = "[b][color=#%s]%s[/color][/b]%s" % [world.titles.support_color(sup, true).to_html(false), sname, text.substr(sname.length())]

		var title: = str(l[3]) if l.size() > 3 else ""
		if title != "" and GameData.TITLES.has(title):
			at += "[color=#%s][lb]%s][/color] " % [Color(GameData.TITLES[title].color).to_html(false), world.titles.name_of(title)]
		out.append(at + "[color=#%s]%s[/color]" % [col.to_html(false), text])
	_text.text = "\n".join(out)
	for c in _invites.get_children():
		c.queue_free()
	_invites.visible = not bool(Save.setting("chat_min", false)) or not ch.invites.is_empty()
	for inv in ch.invites:
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		_invites.add_child(row)
		var what: = _label(tr("%s te invita a su party") % str(inv.name), 12, PARTY_COLOR)
		what.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		what.clip_text = true
		row.add_child(what)
		var from: = int(inv.from)
		row.add_child(_small_button(tr("Aceptar"), func(): ch.answer_invite(from, true)))
		row.add_child(_small_button(tr("Rechazar"), func(): ch.answer_invite(from, false)))


func _small_button(text: String, call: Callable) -> Button:
	var b: = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	UiStyles.apply_button(b)
	b.add_theme_font_size_override("font_size", 11)
	b.custom_minimum_size = Vector2(64, 20)
	b.pressed.connect(call)
	return b
