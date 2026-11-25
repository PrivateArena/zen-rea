extends Node














const LIST_W: = 212.0
const DETAIL_W: = 346.0
const LIST_H: = 432.0
const ROW_H: = 28.0
const PORTRAIT: = 22.0



const SKIP: = ["training_dummy", "training_dummy_mvp", "woodbox", "steelbox", "naght_echo_fire", "naght_echo_ice", 
	"morroc_incarnation_1", "morroc_incarnation_2", "morroc_incarnation_3", "morroc_incarnation_4", 
	"peco_egg", "mob_tomb", "randgris"]
const KIND_COLORS: = {"mvp": Color(0.75, 0.16, 0.22), "boss": Color(0.5, 0.28, 0.78), "elite": Color(0.85, 0.48, 0.08), 
	"normal": Color(0.36, 0.4, 0.52), "special": Color(0.72, 0.55, 0.05)}
const DARK: = Color(0.05, 0.05, 0.1, 0.85)
const INK: = Color(0.15, 0.17, 0.26)
const HEAD: = Color(0.15, 0.3, 0.72)



static var _index: Array = []

static var query: = ""
static var kind_filter: = ""
static var map_filter: = ""
static var picked: = ""

static var jump_mechanics: = false

var menus
var _rows: Array = []
var _queue: Array = []
var _known_n: = 0
const FIRST_ROWS: = 24
var _row_of: = {}
var _lit: Button
var _pending: Array = []

const ROWS_US: = 1500

const AHEAD_ROWS: = 4
var _scroll: ScrollContainer


const READS: = 3
var _loading: Array = []
var _detail: VBoxContainer
var _detail_scroll: ScrollContainer
var _list: VBoxContainer
var _count: Label
var _empty: Label
var _cleared_any: = false



static func build(m) -> Control:
	var b = load("res://scripts/ui/bestiary.gd").new()
	b.menus = m
	return b._build()





static func stage_order() -> Array:
	var ids: Array = GameData.STAGES.keys()
	var at: = {}
	for i in ids.size():
		at[ids[i]] = i
	ids.sort_custom( func(a, b):
		var ta: = int(GameData.STAGES[a].get("tier", 0))
		var tb: = int(GameData.STAGES[b].get("tier", 0))
		return ta < tb if ta != tb else int(at[a]) < int(at[b]))
	return ids



static func fight_mobs(mvp: String) -> Array:
	var out: = []
	for ab in GameData.RAIDS.get(mvp, {}).get("abilities", []):
		for key in ["mob", "egg", "hatch"]:
			var v = ab.get(key, "")
			for m in (v if v is Array else [v]):
				if str(m) != "" and not out.has(str(m)):
					out.append(str(m))
	return out


static func kind_of(id: String) -> String:
	var def: Dictionary = GameData.MONSTERS[id]
	if id == "item_emperium" or id == str(GameData.RUNNER.mob):
		return "special"
	if def.get("mvp", false):
		return "mvp"
	if def.has("boss"):
		return "boss"
	if def.get("elite", false):
		return "elite"
	return "normal"


static func index() -> Array:
	if not _index.is_empty():
		return _index
	var by: = {}
	var order: Array = []
	var add: = func(id: String, p: Dictionary) -> void :
		if not GameData.MONSTERS.has(id) or SKIP.has(id):
			return
		if not by.has(id):
			by[id] = {"id": id, "kind": kind_of(id), "el": GameData.monster_element(id), "places": [], "stages": []}
			order.append(id)
		var e: Dictionary = by[id]

		for q in e.places:
			if q.k == p.k and str(q.get("stage", "")) == str(p.get("stage", "")) and str(q.get("by", "")) == str(p.get("by", ""))\
			and str(q.get("mvp", "")) == str(p.get("mvp", "")) and str(q.get("route", "")) == str(p.get("route", "")):
				if p.has("t"):
					if p.k == "spawn":
						q.t = minf(float(q.t), float(p.t))
					elif not (q.times as Array).has(float(p.t)):
						q.times.append(float(p.t))
						(q.times as Array).sort()
				return
		if p.has("t") and p.k != "spawn":
			p["times"] = [float(p.t)]
		e.places.append(p)
		if p.has("stage") and not (e.stages as Array).has(str(p.stage)):
			e.stages.append(str(p.stage))
	for sid in stage_order():
		var st: Dictionary = GameData.STAGES[sid]
		var mvp: = str(st.get("mvp", ""))
		var mvp_at: = float(st.get("mvp_time", GameData.MVP_TIME))
		for s in st.get("spawns", []):
			add.call(str(s.mob), {"k": "spawn", "stage": sid, "t": float(s.get("from", 0.0))})
		for ev in st.get("events", []):
			var mob: = str(ev.get("mob", ""))
			var t: = str(ev.get("type", ""))
			if t == "boss" and mob == mvp:
				mvp_at = float(ev.at)
			elif t == "ring":
				add.call(mob, {"k": "ring", "stage": sid, "t": float(ev.at)})
			elif t in ["elite", "boss"]:
				add.call(mob, {"k": "event", "stage": sid, "t": float(ev.at)})
		if mvp != "":
			add.call(mvp, {"k": "mvp", "stage": sid, "t": mvp_at})
			for m in fight_mobs(mvp):
				add.call(m, {"k": "fight", "stage": sid, "mvp": mvp})

	for r in GameData.KARMA_ROUTES:
		var v: = str(GameData.KARMA_ROUTES[r].mvp)
		add.call(v, {"k": "route", "route": r})
		for m in fight_mobs(v):
			add.call(m, {"k": "fight", "mvp": v, "route": r})
	add.call(str(GameData.MORROC.mob), {"k": "morroc"})
	add.call(str(GameData.MORROC_FINALE.mob), {"k": "finale"})
	add.call(str(GameData.MORROC_FINALE.adult), {"k": "finale"})
	add.call(str(GameData.RUNNER.mob), {"k": "runner"})
	add.call("item_emperium", {"k": "emperium"})
	add.call(GameData.TOWER_LORD, {"k": "lord"})
	for m in fight_mobs(GameData.TOWER_LORD):
		add.call(m, {"k": "fight", "mvp": GameData.TOWER_LORD})

	for id in order.duplicate():
		var sm = GameData.MONSTERS[id].get("summon", [])
		for s in (sm if sm is Array else [sm]):
			if by.has(str(s)) and str(s) != id:
				add.call(str(s), {"k": "summon", "by": id})

	for i in GameData.TOWER_TIERS.size():
		var sid: = str(GameData.TOWER_TIERS[i])
		var first: = i * GameData.TOWER_TIER_FLOORS + 1
		for id in order:
			if (by[id].stages as Array).has(sid) and by[id].places.any( func(q): return str(q.get("stage", "")) == sid and q.k != "fight"):
				add.call(id, {"k": "tower", "a": first, "b": first + GameData.TOWER_TIER_FLOORS - 1})
	for id in order:
		_index.append(by[id])
	return _index





func known(e: Dictionary) -> bool:
	var id: = str(e.id)
	var def: Dictionary = GameData.MONSTERS[id]
	if e.kind == "special" or Save.has_card(str(def.get("card", ""))) or Save.has_pet(id):
		return true
	for p in e.places:
		match str(p.k):
			"spawn", "ring", "event", "mvp":
				if Save.entered(str(p.stage)):
					return true
			"fight":
				if p.has("stage") and Save.entered(str(p.stage)):
					return true
				if p.has("route") and _cleared_any:
					return true
				if str(p.get("mvp", "")) == GameData.TOWER_LORD and Save.tower_top() >= GameData.TOWER_FLOORS:
					return true
			"tower":
				if Save.tower_top() >= int(p.a):
					return true
			"lord":
				if Save.tower_top() >= GameData.TOWER_FLOORS:
					return true
			"route":
				if _cleared_any:
					return true
			"morroc":
				if Save.max_danger() >= int(GameData.MORROC.min_danger) or Save.stat("satan_morroc") > 0.0:
					return true
			"finale":
				if Save.stat("morroc_finale") > 0.0:
					return true
	return false





static func pct(v: float) -> String:
	var t: = String.num(v * 100.0, 4).trim_suffix(".0")
	if TranslationServer.get_locale().substr(0, 2) in ["es", "pt", "ru", "de", "fr"]:
		t = t.replace(".", ",")
	return t + "%"


static func mult(v: float) -> String:
	var t: = String.num(v, 2)
	return t.replace(".", ",") if TranslationServer.get_locale().substr(0, 2) in ["es", "pt", "ru", "de", "fr"] else t


func kind_name(kind: String) -> String:
	match kind:
		"mvp":
			return "MVP"
		"boss":
			return tr("Jefe")
		"elite":
			return tr("Élite")
		"special":
			return tr("Especial")
	return tr("Normal")


func _name(id: String) -> String:
	return tr(str(GameData.MONSTERS[id].name))





var _known_of: = {}


func _known_name(id: String) -> String:
	if not _known_of.has(id):
		var yes: = true
		for e in index():
			if str(e.id) == id:
				yes = known(e)
				break
		_known_of[id] = yes
	return _name(id) if _known_of[id] else "???"


func _stage_name(sid: String) -> String:
	return tr(str(GameData.STAGES[sid].name)) if GameData.STAGES.has(sid) else sid


func _times(p: Dictionary) -> String:
	var out: = []
	for t in p.get("times", []):
		out.append(UiKit.time_text(float(t)))
	return ", ".join(out)



func place_text(p: Dictionary) -> String:
	match str(p.k):
		"spawn":
			return tr("%s: a partir de %s") % [_stage_name(str(p.stage)), UiKit.time_text(float(p.t))]
		"ring":
			return tr("%s: en oleadas a las %s") % [_stage_name(str(p.stage)), _times(p)]
		"event":
			return tr("%s: llega a las %s") % [_stage_name(str(p.stage)), _times(p)]
		"mvp":
			return tr("%s: MVP a las %s") % [_stage_name(str(p.stage)), _times(p)]
		"fight":
			var where: = _stage_name(str(p.stage)) if p.has("stage") else (tr(str(GameData.KARMA_ROUTES[p.route].name)) if p.has("route") else tr("Endless Tower"))
			return tr("%s: en la pelea contra %s") % [where, _known_name(str(p.mvp))]
		"summon":
			return tr("Lo invoca: %s") % _known_name(str(p.by))
		"tower":
			return tr("Endless Tower: pisos %d-%d") % [int(p.a), int(p.b)]
		"lord":
			return tr("Endless Tower: piso %d; también en la Torre de Hel") % GameData.TOWER_FLOORS
		"route":
			return tr("%s: un portal tras vencer al MVP de un mapa, según tu karma") % tr(str(GameData.KARMA_ROUTES[p.route].name))
		"morroc":
			return tr("Cualquier mapa desde %s: puede llegar pasados los %s") % [GameData.danger_name(int(GameData.MORROC.min_danger)), 
				UiKit.time_text(float(GameData.MORROC.from))]
		"finale":
			return tr("Modo infinito: el final, a los %s") % UiKit.time_text(float(GameData.MORROC_FINALE.at))
		"runner":
			return tr("Cualquier mapa: a veces pasa corriendo, desde %s") % UiKit.time_text(float(GameData.RUNNER.from))
		"emperium":
			return tr("Endless Tower: la Prueba del Emperium") + "\n" + tr("Emperium Festival")
	return ""


func _search_text(e: Dictionary) -> String:
	var parts: = [_name(str(e.id)), str(e.id), kind_name(str(e.kind)), tr(str(GameData.ELEMENT_NAMES.get(e.el, "Neutral")))]
	for sid in e.stages:
		parts.append(_stage_name(str(sid)))
	return menus._fold(" ".join(parts))




func _build() -> Control:
	_cleared_any = GameData.STAGES.keys().any( func(s): return Save.is_stage_cleared(str(s)))
	var root: = VBoxContainer.new()
	root.add_theme_constant_override("separation", 6)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(self)

	var bar: = HBoxContainer.new()
	bar.add_theme_constant_override("separation", 6)
	root.add_child(bar)
	var find: = LineEdit.new()
	find.placeholder_text = tr("Buscar...")
	find.text = query
	find.clear_button_enabled = true
	find.custom_minimum_size.x = 150
	find.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	find.add_theme_font_override("font", UiKit.FONT_BODY)
	find.add_theme_font_size_override("font_size", 11)
	find.add_theme_color_override("font_color", Color.BLACK)
	find.add_theme_color_override("font_placeholder_color", Color(0.42, 0.44, 0.52))
	find.add_theme_color_override("caret_color", Color.BLACK)
	for st in ["normal", "focus"]:
		var fb: = StyleBoxFlat.new()
		fb.bg_color = Color.WHITE
		fb.border_color = Color(0.3, 0.42, 0.78) if st == "focus" else Color(0.66, 0.72, 0.88)
		fb.set_border_width_all(1)
		fb.set_corner_radius_all(10)
		fb.content_margin_left = 10
		fb.content_margin_right = 6
		fb.content_margin_top = 2
		fb.content_margin_bottom = 3
		find.add_theme_stylebox_override(st, fb)
	find.text_changed.connect( func(text: String):
		query = text
		_refilter())
	bar.add_child(find)
	var kinds: = [["", tr("Todos")], ["mvp", "MVP"], ["boss", tr("Jefes")], ["elite", tr("Élites")], ["normal", tr("Normales")], 
		["special", tr("Especiales")]]
	bar.add_child(_select(kinds, kind_filter, func(v: String): kind_filter = v))
	var maps: = [["", tr("Todos los mapas")]]
	for sid in stage_order():
		maps.append([sid, _stage_name(sid)])
	maps.append(["tower", tr("Endless Tower")])
	maps.append(["other", tr("Otros")])
	var map_pick: = _select(maps, map_filter, func(v: String): map_filter = v)
	map_pick.custom_minimum_size.x = 150
	map_pick.fit_to_longest_item = false
	map_pick.clip_text = true
	bar.add_child(map_pick)

	var main: = HBoxContainer.new()
	main.add_theme_constant_override("separation", 8)
	root.add_child(main)
	var left: = VBoxContainer.new()
	left.add_theme_constant_override("separation", 2)
	main.add_child(left)
	_count = UiKit.label("", 10, UiKit.MUTED, true)
	left.add_child(_count)
	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(LIST_W, LIST_H)
	left.add_child(scroll)
	_scroll = scroll

	scroll.get_v_scroll_bar().value_changed.connect( func(_v: float): set_process(true))
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 1)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list)
	_empty = UiKit.label(tr("Ningún monstruo con estos filtros."), 10, UiKit.MUTED)
	_empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_empty.custom_minimum_size.x = LIST_W - 16
	_empty.visible = false
	_list.add_child(_empty)
	var panel: = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiKit.panel_box(Color(0.975, 0.98, 1.0), Color(0.8, 0.84, 0.93), 8, 1))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.add_child(panel)
	_detail_scroll = ScrollContainer.new()
	_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_detail_scroll.custom_minimum_size = Vector2(DETAIL_W, 100)
	panel.add_child(_detail_scroll)
	_detail = VBoxContainer.new()
	_detail.add_theme_constant_override("separation", 6)
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_scroll.add_child(_detail)


	var all: = index()
	var upto: = FIRST_ROWS
	for i in all.size():
		if known(all[i]):
			_known_n += 1
		if str(all[i].id) == picked:
			upto = maxi(upto, i + 1)


	if _filtered():
		upto = all.size()
	for i in all.size():
		if i < upto:
			_rows.append(_row(all[i]))
		else:
			_queue.append(all[i])
	_refilter()
	set_process(true)
	return root



func _select(opts: Array, current: String, pick: Callable) -> OptionButton:
	var at: = 0
	for i in opts.size():
		if str(opts[i][0]) == current:
			at = i
	var o: OptionButton = menus._album_select(opts.map( func(x): return str(x[1])), at, func(i: int):
		pick.call(str(opts[i][0]))
		_refilter())
	o.add_theme_font_size_override("font_size", 10)
	return o


func _row(e: Dictionary) -> Dictionary:
	var id: = str(e.id)
	var is_known: = known(e)
	var b: = Button.new()
	b.custom_minimum_size = Vector2(LIST_W - 12.0, ROW_H)
	b.focus_mode = Control.FOCUS_ALL
	b.mouse_filter = Control.MOUSE_FILTER_PASS
	_row_style(b, false)
	b.visible = _matches_entry(e, is_known, "")
	var line: = HBoxContainer.new()
	line.add_theme_constant_override("separation", 5)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	line.offset_left = 4
	line.offset_right = -4
	b.add_child(line)
	var pic: = UiKit.icon_rect(null, PORTRAIT)
	pic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if not is_known:
		pic.modulate = DARK
	line.add_child(pic)
	var name_l: = UiKit.label(_name(id) if is_known else "???", 10, INK if is_known else UiKit.MUTED, true)
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_l.custom_minimum_size.x = 60
	line.add_child(name_l)
	UiKit.fit_dots(name_l)

	if e.kind != "normal" and is_known:
		var k: = UiKit.label(kind_name(str(e.kind)), 9, KIND_COLORS[e.kind], true)
		k.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line.add_child(k)
	b.pressed.connect(_pick.bind(id))

	b.focus_entered.connect( func():
		if picked != id:
			_pick(id))
	_list.add_child(b)
	var row: = {"e": e, "button": b, "pic": pic, "known": is_known, "find": _search_text(e) if is_known else "", 
		"built": Engine.get_process_frames()}
	if query.strip_edges() != "":
		b.visible = _matches(row)
	_pending.append(row)
	_row_of[id] = row
	return row



static var _styles: = {}


func _row_style(b: Button, on: bool) -> void :
	if _styles.is_empty():
		for st in ["normal", "hover", "pressed", "focus"]:
			var pair: = []
			for lit in [false, true]:
				var sb: = StyleBoxFlat.new()
				sb.set_corner_radius_all(4)
				if lit:
					sb.bg_color = Color(0.74, 0.81, 0.95)
					sb.border_color = Color(0.3, 0.42, 0.78)
					sb.set_border_width_all(1)
				elif st == "hover":
					sb.bg_color = Color(0.9, 0.93, 0.99)
				elif st == "focus":
					sb.draw_center = false
					sb.border_color = Color(0.3, 0.42, 0.78)
					sb.set_border_width_all(1)
				else:
					sb.bg_color = Color(0, 0, 0, 0)
				pair.append(sb)
			_styles[st] = pair
	for st in _styles:
		b.add_theme_stylebox_override(st, _styles[st][1 if on else 0])








func _process(_dt: float) -> void :
	var added: = false
	var rows_until: = Time.get_ticks_usec() + ROWS_US
	while not _queue.is_empty() and Time.get_ticks_usec() < rows_until:
		_rows.append(_row(_queue.pop_front()))
		added = true
	if added:
		_refilter(false)
	_portrait_step()
	if _loading.is_empty() and _queue.is_empty() and _next_portrait() < 0:
		set_process(false)




func _next_portrait() -> int:
	var top: = _scroll.scroll_vertical - AHEAD_ROWS * ROW_H
	var bottom: = _scroll.scroll_vertical + _scroll.size.y + AHEAD_ROWS * ROW_H
	var now: = Engine.get_process_frames()
	for i in _pending.size():
		var p: Dictionary = _pending[i]
		if not is_instance_valid(p.pic):
			return i
		if not p.has("button"):
			return i
		var b: Button = p.button

		if int(p.built) < now and b.is_visible_in_tree() and b.position.y + b.size.y >= top and b.position.y <= bottom:
			return i
	return -1


func _portrait_step() -> void :

	var cropped: = false
	for i in _loading.size():
		var done: Dictionary = _loading[i]
		if WorkerThreadPool.is_task_completed(int(done.task)):
			WorkerThreadPool.wait_for_task_completion(int(done.task))
			_loading.remove_at(i)
			_show(done)
			cropped = true
			break
	while true:
		var at: = _next_portrait()
		if at < 0:
			return
		var p: Dictionary = _pending[at]
		if not is_instance_valid(p.pic):
			_pending.remove_at(at)
			continue
		var id: = str(p.e.id)
		var look: = look_of(id)

		if id == "item_emperium" or StagePreview._crops.has(look):
			_pending.remove_at(at)
			_show(p)
			continue
		var had: = RoAssets._cached(look)
		if not had and not OS.has_feature("web"):
			if _loading.size() >= READS:
				return
			_pending.remove_at(at)
			p["had"] = false
			p["task"] = WorkerThreadPool.add_task(RoAssets.sprite.bind([look]))
			_loading.append(p)
			continue
		if cropped:
			return
		_pending.remove_at(at)
		p["had"] = had
		_show(p)
		return


func _show(p: Dictionary) -> void :
	var id: = str(p.e.id)
	var tex: = _crop(look_of(id), not bool(p.had)) if p.has("had") and id != "item_emperium" else portrait(id)
	if is_instance_valid(p.pic):
		(p.pic as TextureRect).texture = tex


func _exit_tree() -> void :
	for p in _loading:
		WorkerThreadPool.wait_for_task_completion(int(p.task))
		RoAssets.forget_sprite([look_of(str(p.e.id))])
	_loading.clear()


static func look_of(id: String) -> String:
	return str(GameData.MONSTERS[id].get("sprite_of", id))




static func portrait(id: String) -> Texture2D:
	if id == "item_emperium":
		var path: = "res://assets/ro/ui/skin/item_icons/gem_emperium.png"
		return load(path) as Texture2D if ResourceLoader.exists(path) else null
	var look: = look_of(id)
	return _crop(look, not StagePreview._crops.has(look) and not RoAssets._cached(look))



static func _crop(look: String, release: bool) -> Texture2D:
	var tex: = StagePreview._cropped(look)
	if release:
		RoAssets.forget_sprite([look])
	return tex


func _matches(row: Dictionary) -> bool:
	return _matches_entry(row.e, bool(row.known), str(row.find))


func _matches_entry(e: Dictionary, is_known: bool, find: String) -> bool:
	if kind_filter != "" and e.kind != kind_filter:
		return false
	if map_filter == "tower":
		if not e.places.any( func(p): return p.k in ["tower", "lord", "emperium"] or str(p.get("mvp", "")) == GameData.TOWER_LORD):
			return false
	elif map_filter == "other":
		if not (e.stages as Array).is_empty():
			return false
	elif map_filter != "" and not (e.stages as Array).has(map_filter):
		return false
	var q: String = menus._fold(query.strip_edges())
	if q != "":

		if not is_known:
			return false
		for w in q.split(" ", false):
			if not find.contains(w):
				return false
	return true




func _refilter(full: = true) -> void :

	if full and not _queue.is_empty() and _filtered():
		while not _queue.is_empty():
			_rows.append(_row(_queue.pop_front()))
	var shown: = 0
	var first: = ""
	var pick_shown: = false
	for row in _rows:
		var on: bool = _matches(row) if full else (row.button as Button).visible
		(row.button as Button).visible = on
		if on:
			shown += 1
			if first == "":
				first = str(row.e.id)
			if str(row.e.id) == picked:
				pick_shown = true
	_empty.visible = shown == 0 and _queue.is_empty()

	set_process(true)
	var total: = _rows.size() + _queue.size()
	_count.text = tr("Conocidos: %d/%d") % [_known_n, total] + ("  ·  %d" % shown if _filtered() else "")
	if not pick_shown and first != "" and (full or _lit == null):
		_pick(first)
	elif picked == "" or _detail.get_child_count() == 0:
		_pick(picked if pick_shown else first)


func _filtered() -> bool:
	return query.strip_edges() != "" or kind_filter != "" or map_filter != ""


func _pick(id: String) -> void :
	picked = id
	if _lit != null and is_instance_valid(_lit):
		_row_style(_lit, false)
	_lit = null
	for c in _detail.get_children():
		c.queue_free()
	_detail_scroll.scroll_vertical = 0
	if not _row_of.has(id):
		return
	var row: Dictionary = _row_of[id]
	_lit = row.button
	_row_style(_lit, true)
	_fill(row.e, bool(row.known))




func _section(text: String) -> void :
	_detail.add_child(UiKit.label(text, 11, HEAD, true))


func _text(text: String, size: = 10, color: = INK) -> Label:
	var l: = UiKit.label(text, size, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = DETAIL_W - 32.0
	return l


func _fill(e: Dictionary, is_known: bool) -> void :
	var id: = str(e.id)
	var def: Dictionary = GameData.MONSTERS[id]
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	_detail.add_child(head)


	var look: = str(def.get("sprite_of", id))
	var pic: = UiKit.icon_rect(portrait(id) if id == "item_emperium" or StagePreview._crops.has(look) else null, 64)
	if pic.texture == null:
		_pending.push_front({"e": e, "pic": pic})
		set_process(true)
	if not is_known:
		pic.modulate = DARK
	head.add_child(pic)
	var hc: = VBoxContainer.new()
	hc.add_theme_constant_override("separation", 3)
	hc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hc.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_child(hc)
	var nl: = UiKit.label(_name(id) if is_known else "???", 14, INK, true)
	nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nl.custom_minimum_size.x = DETAIL_W - 110.0
	hc.add_child(nl)
	if is_known:
		var tags: = HBoxContainer.new()
		tags.add_theme_constant_override("separation", 6)
		hc.add_child(tags)
		tags.add_child(UiKit.tag(kind_name(str(e.kind)), KIND_COLORS[e.kind], 10))
		tags.add_child(UiKit.element_tag(str(e.el), false, 10))
	if not is_known:
		var hint: = _text(tr("Entra en uno de sus mapas para conocerlo.") if not (e.stages as Array).is_empty() else tr("Aún no lo has encontrado."), 10, UiKit.MUTED)
		hint.custom_minimum_size.x = DETAIL_W - 110.0
		hc.add_child(hint)
	elif id == "item_emperium":
		var note: = _text(tr("No se mueve ni ataca, pero tocarlo quema. En el Emperium Festival cuenta como jefe y MVP para tus bonus."), 10, UiKit.MUTED)
		note.custom_minimum_size.x = DETAIL_W - 110.0
		hc.add_child(note)
	if is_known:
		_elements(str(e.el))
	_section(tr("Dónde aparece"))
	for p in e.places:

		if p.k == "ring" and e.places.any( func(q): return q.k == "spawn" and str(q.stage) == str(p.stage)):
			continue
		var t: = place_text(p)
		if t != "":
			_detail.add_child(_text("· " + t.replace("\n", "\n· ")))


	if is_known and GameData.RAIDS.has(id):
		_mechanics(id)

	jump_mechanics = false
	if is_known:
		_section(tr("Qué suelta"))
		_drops(e, def)




func _mechanics(id: String) -> void :
	_section(tr("Sus mecánicas"))
	if jump_mechanics:
		jump_mechanics = false
		_jump_to.call_deferred(_detail.get_child(_detail.get_child_count() - 1))
	var list: Array = GameData.RAIDS[id].get("abilities", [])
	for ab in list:
		var name: = tr(str(ab.get("name", "")))
		if name == "":
			continue
		var bits: Array[String] = []
		var ph: Array = ab.get("phases", [])
		if ph.size() >= 3 or ph.is_empty():
			bits.append(tr("Toda la pelea"))
		else:
			bits.append(tr("Fases: %s") % ", ".join(ph.map( func(x): return str(int(x) + 1))))
		if float(ab.get("every", 0.0)) > 0.0:
			bits.append(tr("cada %d s") % roundi(float(ab.every)))
		var head: = HBoxContainer.new()
		head.add_theme_constant_override("separation", 6)
		_detail.add_child(head)
		head.add_child(UiKit.label("· " + name, 10, INK, true))
		head.add_child(UiKit.label("  ".join(bits), 9, UiKit.MUTED))
		if bool(ab.get("lethal", false)):
			head.add_child(UiKit.tag(tr("Mortal si fallas"), Color(0.75, 0.16, 0.22), 9))

		var what: = tr(str(ab.get("alert", ""))).trim_prefix(name + ": ")
		if what != "":
			_detail.add_child(_text("   " + what, 9, Color(0.3, 0.32, 0.42)))



func _jump_to(head: Control) -> void :
	await get_tree().process_frame
	if is_instance_valid(head) and is_instance_valid(_detail_scroll):
		_detail_scroll.scroll_vertical = int(head.position.y) - 4



func _elements(el: String) -> void :
	var weak: = []
	var strong: = []
	for a in GameData.ELEMENT_ORDER:
		var m: = GameData.element_mult(str(a), el)
		if m > 1.001:
			weak.append([str(a), m])
		elif m < 0.999:
			strong.append([str(a), m])
	weak.sort_custom( func(x, y): return x[1] > y[1])
	strong.sort_custom( func(x, y): return x[1] < y[1])
	for part in [[tr("Recibe más daño de"), weak], [tr("Recibe menos daño de"), strong]]:
		_section(str(part[0]))
		var flow: = HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 6)
		flow.add_theme_constant_override("v_separation", 4)
		flow.custom_minimum_size.x = DETAIL_W - 32.0
		_detail.add_child(flow)
		if (part[1] as Array).is_empty():
			flow.add_child(UiKit.label(tr("Ninguno"), 10, UiKit.MUTED))
		for w in part[1]:
			var chip: = HBoxContainer.new()
			chip.add_theme_constant_override("separation", 2)
			chip.add_child(UiKit.element_tag(str(w[0]), false, 10))
			var good: bool = float(w[1]) > 1.0
			chip.add_child(UiKit.label("%d%%" % roundi(float(w[1]) * 100.0), 10, Color(0.15, 0.5, 0.15) if good else Color(0.65, 0.2, 0.15), true))
			flow.add_child(chip)



func _drop(icon: Texture2D, text: String, chance: String, note: = "", hover: = Callable()) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_PASS if hover.is_valid() else Control.MOUSE_FILTER_IGNORE
	_detail.add_child(row)
	var ic: = UiKit.icon_rect(icon, 24)
	ic.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(ic)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(col)
	var l: = _text(text, 10, INK)
	l.add_theme_font_override("font", UiKit.FONT_TITLE)
	l.custom_minimum_size.x = DETAIL_W - 110.0
	col.add_child(l)
	if note != "":
		var n: = _text(note, 9, UiKit.MUTED)
		n.custom_minimum_size.x = DETAIL_W - 110.0
		col.add_child(n)
	if chance != "":
		var c: = UiKit.label(chance, 11, Color(0.12, 0.42, 0.2), true)
		c.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		row.add_child(c)
	if hover.is_valid():
		row.mouse_entered.connect(hover.bind(row))
		row.mouse_exited.connect(menus._hide_item_hover)


func _icon(id: String) -> Texture2D:
	return menus._item_icon(id)


func _card_drop(card: String, chance: String, note: String) -> void :
	if not GameData.CARDS.has(card):
		return
	var c: Dictionary = GameData.CARDS[card]
	var text: = tr(str(c.name)) + ("  ✓" if Save.has_card(card) else "")
	var desc: = tr(str(c.get("desc", "")))
	_drop(RoAssets.card_art(card), text, chance, desc if note == "" else note + "\n" + desc)


func _unique_drop(uid: String, chance: String, note: String) -> void :
	if not GameData.ITEMS.has(uid):
		return
	var it: Dictionary = GameData.ITEMS[uid]
	_drop(_icon(str(it.get("icon", uid))), tr(str(it.name)) + ("  ✓" if Save.has_seen("uniques", uid) else ""), chance, note, 
		func(anchor: Control): menus._show_item_hover(Equipment.make(uid, 0), anchor))


func _pet_drop(id: String) -> void :
	if not GameData.PETS.has(id):
		return
	var pet: Dictionary = GameData.PETS[id]
	if str(pet.get("tame", "")) == "" or float(pet.get("drop", 0.0)) <= 0.0:
		return
	var note: = tr("Mascota: %s") % tr(str(pet.name)) + "  ·  " + tr("domar: %s") % pct(float(pet.get("rate", 1.0)))
	if not pet.get("mvp", false):
		note += "\n" + tr("Solo en su propio mapa.")
	_drop(_icon(str(pet.tame)), tr(str(pet.item)) + ("  ✓" if Save.has_pet(id) else ""), pct(float(pet.drop)), note)



func _stage_uniques(sid: String) -> Array:

	var out: = GameData.stage_shared_uniques(sid)
	for uid in GameData.ITEMS:
		var it: Dictionary = GameData.ITEMS[uid]
		if it.get("unique", false) and str(it.get("stage", "")) == sid and not (it.get("job", []) as Array).is_empty() and not out.has(uid):
			out.append(uid)
	return out




func _shared_count(sid: String, uid: String) -> float:
	var pool: = GameData.stage_roll_pool(sid)
	return float(pool.size()) if pool.has(uid) and pool.size() > 1 else 1.0


func _always(parts: Array) -> void :
	var flow: = HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 10)
	flow.add_theme_constant_override("v_separation", 4)
	flow.custom_minimum_size.x = DETAIL_W - 32.0
	_detail.add_child(flow)
	flow.add_child(UiKit.label(tr("Siempre:"), 10, HEAD, true))
	for p in parts:
		var chip: = HBoxContainer.new()
		chip.add_theme_constant_override("separation", 3)
		chip.add_child(UiKit.icon_rect(p[0], 20))
		var l: = UiKit.label(str(p[1]), 10, INK, true)
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		chip.add_child(l)
		flow.add_child(chip)


func _drops(e: Dictionary, def: Dictionary) -> void :
	var id: = str(e.id)
	var card: = str(def.get("card", ""))
	var hell: = tr("x%s en Infierno, más desde Infierno %d") % [mult(GameData.UNIQUE_HELL_MULT), GameData.HELL_PAYS_FROM]
	var stages: = []
	for p in e.places:
		if p.k == "mvp":
			stages.append(str(p.stage))
	var route: = ""
	for p in e.places:
		if p.k == "route":
			route = str(p.route)
	match str(e.kind):
		"mvp":
			_card_drop(card, pct(GameData.MVP_CARD_CHANCE), "")
			for sid in stages:
				var uniqs: = _stage_uniques(sid)
				for uid in uniqs:
					_unique_drop(uid, pct(GameData.UNIQUE_MVP_CHANCE / _shared_count(sid, uid)), tr("Única del mapa") + "  ·  " + hell)
			if route != "":
				_unique_drop(str(GameData.KARMA_ROUTES[route].unique), pct(GameData.KARMA_UNIQUE_CHANCE), hell)
			_pet_drop(id)
			var fight: = []
			for m in fight_mobs(id):
				var fc: = str(GameData.MONSTERS.get(m, {}).get("card", ""))
				if GameData.CARDS.has(fc) and not fight.has(fc):
					fight.append(fc)
			if not fight.is_empty():
				var names: = fight.map( func(c): return tr(str(GameData.CARDS[c].name)))
				_drop(RoAssets.card_art(str(fight[0])), tr("Una carta de los monstruos de su pelea"), pct(GameData.MVP_FIGHT_CARD_CHANCE), 
					", ".join(names))
			_drop(_icon("star_crumb"), tr("Star Crumb"), pct(GameData.STAR_CRUMB_MVP))
			if GameData.RAIDS.has(id):
				_drop(_icon("poring_coin"), tr("+1 Poring Coin"), pct(GameData.MVP_COIN_CHANCE))
				_drop(_icon("hd_oridecon"), "%s / %s" % [tr("HD Oridecon"), tr("HD Elunium")], pct(GameData.MVP_HD_CHANCE))
			var always: = []
			if id == GameData.TOWER_LORD:
				always.append([_icon("chest"), tr("Tesoro de la Torre: %d legendarios") % GameData.MAX_CHEST_ROLLS])
			elif id == str(GameData.MORROC.mob):
				always.append([_icon("chest"), tr("Treasure Box: %d objetos") % int(GameData.MORROC.chest)])
			elif id == str(GameData.MORROC_FINALE.mob) or id == str(GameData.MORROC_FINALE.adult):
				always.append([_icon("chest"), tr("Treasure Box: %d objetos") % int(GameData.MORROC_FINALE.chest)])
				always.append([_icon("poring_coin"), tr("%d Poring Coins") % int(GameData.MORROC_FINALE.poring_coins)])
			else:
				always.append([_icon("chest"), tr("Treasure Box: %d objetos") % int(GameData.CHEST_ROLLS.boss)])
			if GameData.RAIDS.has(id):
				always.append([_icon("enriched_oridecon"), "%dx %s / %s" % [GameData.MVP_ENRICHED, tr("Enriched Oridecon"), tr("Enriched Elunium")]])
				always.append([_icon("ymir_fragment"), tr("Fragmento de Ymir")])
			_always(always)
		"boss":
			_card_drop(card, pct(GameData.BOSS_CARD_CHANCE), tr("Segura tras %d sin ella") % GameData.BOSS_CARD_PITY)
			_pet_drop(id)
			_drop(_icon("enriched_oridecon"), "%s / %s" % [tr("Enriched Oridecon"), tr("Enriched Elunium")], pct(GameData.BOSS_ENRICHED_CHANCE), 
				tr("Más con el peligro"))
			_map_unique_box(e)
			_always([[_icon("chest"), tr("Treasure Box: %d objetos") % int(GameData.CHEST_ROLLS.boss)], 
				[_icon("oridecon"), tr("%d Oridecon o Elunium") % 3]])
		"elite":
			_card_drop(card, pct(GameData.ELITE_CARD_CHANCE), "")
			_pet_drop(id)
			_map_unique_box(e)
			_always([[_icon("chest"), tr("Treasure Box: un objeto") if int(GameData.CHEST_ROLLS.elite) == 1 else tr("Treasure Box: %d objetos") % int(GameData.CHEST_ROLLS.elite)], 
				[_icon("oridecon"), tr("%d Oridecon o Elunium") % 1]])
		"special":
			if id == str(GameData.RUNNER.mob):
				_always([[_icon("chest"), tr("Treasure Box: %d objetos") % int(GameData.CHEST_ROLLS.golden_poring)], 
					[_icon("gold_coin"), tr("Su tesoro: +%d zeny") % int(GameData.RUNNER.catch_zeny)]])
			else:
				_detail.add_child(_text(tr("Endless Tower: un cofre de diamante de %s objetos, según cuántas pruebas superas.") % "/".join(
					GameData.TOWER_EMPERIUM_PRIZES.map( func(n): return str(n)))))
		_:
			var fight: bool = e.places.any( func(p): return p.k == "fight") and not e.places.any( func(p): return p.k in ["spawn", "ring", "event"])
			_card_drop(card, pct(GameData.CARD_DROP_CHANCE), tr("Segura tras %d sin ella") % GameData.MVP_SUMMON_CARD_PITY if fight
				else tr("SUE y la probabilidad de cartas la suben"))
			_pet_drop(id)
	var foot: = _text(tr("Son las de base: la «probabilidad de drop» (Potencial estelar, rasgo Afortunada) sube cartas, huevos, minerales y monedas; en Infierno las únicas salen más."), 9, UiKit.MUTED)
	_detail.add_child(foot)



func _map_unique_box(e: Dictionary) -> void :
	var seen: = []
	for sid in e.stages:
		for uid in _stage_uniques(str(sid)):
			if not seen.has(uid):
				seen.append(uid)
				_unique_drop(uid, pct(GameData.UNIQUE_BOSS_CHANCE / _shared_count(str(sid), uid)), tr("En su Treasure Box"))
