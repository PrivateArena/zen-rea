extends Node












signal changed

const FONT = preload("res://assets/ro/fonts/SCDream6.otf")
const TOLD: = "titles_told"

var world: Node

var _checked: = {}
static var _icons: = {}


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Leaderboard.enabled() and Save._name == "profile":
		fetch_special.call_deferred()

	var gifts: Node = (load("res://scripts/core/gifts.gd") as GDScript).new()
	gifts.set("world", world)
	add_child(gifts)





func owned() -> Array:
	return GameData.TITLES.keys().filter(has)


func has(id: String) -> bool:
	if not GameData.TITLES.has(id):
		return false
	var d: Dictionary = GameData.TITLES[id]
	match str(d.check):
		"special":
			return _special().has(id)
		"tower":
			return Save.tower_top() >= int(d.goal)
		"hel":
			return Save.hel_top() >= int(d.goal)
		"oath":
			return Save.oath_top() >= int(d.goal)
		"hell_classes":
			return Save.seen_count("title_hell_classes") >= int(d.goal)
		"hell_maps":
			return Save.seen_count("title_hell_maps") >= int(d.goal)
		"stat":
			return Save.stat(str(d.stat)) >= float(d.goal)
		"cosmetics":
			return _a_rarity_complete()
	return Save.has_seen("titles", id)



func _a_rarity_complete() -> bool:
	var owned: = Save.owned_cosmetics()
	for r in GameData.COSMETIC_RARITY:
		var ids: Array = GameData.COSMETICS.keys().filter( func(c): return str(GameData.COSMETICS[c].rarity) == r and bool(GameData.COSMETICS[c].get("gacha", true)))
		if not ids.is_empty() and ids.all( func(c): return owned.has(c)):
			return true
	return false



func mvp_feats(w: World) -> void :
	var p: Player = w.player
	if p == null or w.is_coop() or w.training or p.tampered or w.autopilot or p.downed:
		return
	if p.hp > 0.0 and p.hp < p.max_hp * GameData.TITLE_CLOSE_HP:
		Save.mark_seen("titles", "close_call")
	if p.equipment != null and p.equipment.slots.get("weapon") == null:
		Save.mark_seen("titles", "bare_hands")



func progress(id: String) -> String:
	var d: Dictionary = GameData.TITLES[id]
	match str(d.check):
		"tower":
			return "%d / %d" % [mini(Save.tower_top(), int(d.goal)), int(d.goal)]
		"hel":
			return "%d / %d" % [mini(Save.hel_top(), int(d.goal)), int(d.goal)]
		"oath":
			return "%d / %d" % [mini(Save.oath_top(), int(d.goal)), int(d.goal)]
		"hell_classes":
			return "%d / %d" % [mini(Save.seen_count("title_hell_classes"), int(d.goal)), int(d.goal)]
		"hell_maps":
			return "%d / %d" % [mini(Save.seen_count("title_hell_maps"), int(d.goal)), int(d.goal)]
		"stat":
			return "%d / %d" % [mini(int(Save.stat(str(d.stat))), int(d.goal)), int(d.goal)]
	return ""



func active() -> String:
	var id: = str(Save.setting("title", ""))
	return id if has(id) else ""


func set_active(id: String) -> void :
	Save.set_setting("title", id if has(id) else "")
	Save.flush()
	_push()
	changed.emit()



func _push() -> void :
	if not Leaderboard.enabled() or world == null or world.board == null:
		return
	var id: = active()
	world.board._call("set_title", {"p_player": Leaderboard.player_id(), "p_title": id}, func(ok: bool, d):
		if ok and d is Dictionary and bool(d.get("ok", false)):
			Save.set_setting("title_sent", id))




func _special() -> Array:
	var out: = []
	var got = Save.setting("titles_special", [])
	if got is Array:
		for g in got:

			if g is Dictionary and GameData.TITLES.has(str(g.get("title", ""))) and Player.special_title_live(g):
				out.append(str(g.title))
	return out


func proof(id: String) -> String:
	var got = Save.setting("titles_special", [])
	if got is Array:
		for g in got:
			if g is Dictionary and str(g.get("title", "")) == id:
				return str(g.get("proof", ""))
	return ""


var _special_tries: = 0
func fetch_special() -> void :
	if world == null or world.board == null:
		return


	world.board._call("my_titles", {"p_player": Leaderboard.player_id(), "p_secret": str(Save.setting("cloud_secret", ""))}, func(ok: bool, d):
		if not ok or not d is Array:


			_special_tries += 1
			if _special_tries <= 3 and is_inside_tree():
				get_tree().create_timer(20.0, true, false, true).timeout.connect(fetch_special)
			return
		var keep: = []
		for g in d:
			if g is Dictionary and GameData.TITLES.has(str(g.get("title", ""))) and str(GameData.TITLES[str(g.title)].check) == "special":
				keep.append({"title": str(g.title), "proof": str(g.get("proof", ""))})
		Save.set_setting("titles_special", keep)
		Save.flush()

		if str(Save.setting("title_sent", "")) != active():
			_push()
		if str(Save.setting("support_sent", "")) != str(Save.setting(SUPPORT_KEY, "")) + ("" if support_icon_on() else "|noicon"):
			_push_support()
		changed.emit())



func news() -> Array:
	var out: = []
	for id in owned():
		if not Save.has_seen(TOLD, id):
			Save.mark_seen(TOLD, id)
			out.append(id)
	if not out.is_empty():
		Save.flush()


	var ch = world.get("channel") if world != null else null
	if ch != null and ch.get("world_chat") != null:
		for id in out:
			ch.world_chat.feat(str(id))
	return out






func after_run(w: World, victory: bool) -> Array:
	var p: Player = w.player
	if p != null and not w.is_coop() and not w.training and w.tower == null and not w.festival_mode and not p.tampered\
	and w.run_mvps > 0 and GameData.STAGES.has(w.stage_id) and not w.autopilot:
		var hell: = GameData.hell_level(w.danger)
		if hell >= GameData.TITLE_HELL:
			Save.mark_seen("title_hell_classes", p.class_id)
			Save.mark_seen("title_hell_maps", w.stage_id)



			if victory and w.first_mvp_time >= 0.0 and w.first_mvp_time < GameData.TITLE_FAST:
				Save.mark_seen("titles", "lightning")
			if float(w.meter_stats.get("taken", 0.0)) < p.max_hp:
				Save.mark_seen("titles", "untouchable")
		if hell >= GameData.TITLE_HELL_TOP:
			Save.mark_seen("titles", "hell_15")
		if hell >= GameData.TITLE_BARE_HELL and p.falls == 0 and Save.loadout(p.class_id).is_empty():
			Save.mark_seen("titles", "bare")


		var oath: int = w.oath_points()
		if oath > 0:
			Save.oath_beat(w.stage_id, oath)
			if oath >= GameData.oath_max_points():
				Save.mark_seen("titles", "oath_max")

	if p != null and victory and not w.is_coop() and not w.training and not p.tampered and not w.autopilot\
	and p.falls >= GameData.TITLE_PHOENIX_FALLS:
		Save.mark_seen("titles", "phoenix")
	return news()



func after_festival(checks: int, party: bool) -> Array:
	if not party and checks >= GameData.TITLE_EMPERIUMS:
		Save.mark_seen("titles", "emperium")
	return news()






func shown_for(id: String, p_proof: String, tag: String) -> String:
	if not GameData.TITLES.has(id):
		return ""
	if str(GameData.TITLES[id].check) != "special":
		return id
	if p_proof == "" or world == null or world.board == null:
		return ""
	var key: = "%s|%s|%s" % [id, p_proof, tag]
	if _checked.has(key):
		return id if _checked[key] == true else ""
	_checked[key] = null
	world.board._call("title_ok", {"p_title": id, "p_proof": p_proof, "p_tag": tag}, func(ok: bool, d):


		if not ok:
			get_tree().create_timer(30.0, true).timeout.connect( func(): _checked.erase(key))
			return
		_checked[key] = d == true
		if _checked[key] and world.get("channel") != null and world.channel.has_method("_sync_town"):
			world.channel._sync_town())
	return ""











const SUPPORT: = ["golden_poring", "angeling"]
const SUPPORT_BRIGHT: = {"golden_poring": Color(1.0, 0.8, 0.12), "angeling": Color(1.0, 0.66, 0.88)}
const SUPPORT_INK: = {"golden_poring": Color(0.74, 0.5, 0.0), "angeling": Color(0.84, 0.28, 0.6)}




func supporter() -> String:
	var pick: = str(Save.setting(SUPPORT_KEY, ""))
	if pick == SUPPORT_NONE:
		return ""
	if SUPPORT.has(pick) and has(pick):
		return pick
	for s in SUPPORT:
		if has(s):
			return s
	return ""



func supports_owned() -> Array:
	return SUPPORT.filter( func(s): return has(s))




const SUPPORT_KEY: = "support_style"
const SUPPORT_NONE: = "none"


const ANGEL_AURA_KEY: = "angel_aura"
func angel_aura_on() -> bool:
	return bool(Save.setting(ANGEL_AURA_KEY, true))





func angel_aura_shown() -> bool:
	return has("angeling") and angel_aura_on()


func set_angel_aura(on: bool) -> void :
	Save.set_setting(ANGEL_AURA_KEY, on)
	Save.flush()
	changed.emit()




const SUPPORT_ICON_KEY: = "support_icon"
func support_icon_on() -> bool:
	return bool(Save.setting(SUPPORT_ICON_KEY, true))


func set_support_icon(on: bool) -> void :
	Save.set_setting(SUPPORT_ICON_KEY, on)
	Save.flush()
	_push_support()
	changed.emit()


func set_supporter(sup: String) -> void :
	Save.set_setting(SUPPORT_KEY, sup if SUPPORT.has(sup) or sup == SUPPORT_NONE else "")
	Save.flush()
	_push_support()
	changed.emit()


func _push_support() -> void :
	if not Leaderboard.enabled() or world == null or world.board == null:
		return
	var pick: = str(Save.setting(SUPPORT_KEY, ""))
	var sent: = pick + ("" if support_icon_on() else "|noicon")
	world.board._call("set_support", {"p_player": Leaderboard.player_id(), "p_sup": pick, "p_icon": support_icon_on()}, func(ok: bool, d):
		if ok and d is Dictionary and bool(d.get("ok", false)):
			Save.set_setting("support_sent", sent))


static func support_icon(sup: String) -> Texture2D:
	return _icon(str(GameData.TITLES.get(sup, {}).get("mob", ""))) if SUPPORT.has(sup) else null



static func support_color(sup: String, bright: = true) -> Color:
	if not SUPPORT.has(sup):
		return Color.WHITE
	if not bright:
		return SUPPORT_INK[sup]
	var c: Color = SUPPORT_BRIGHT[sup]
	return c.lightened(0.18 * (0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.004)))




static func draw_support_icon(ci: CanvasItem, left: Vector2, sup: String, h: float, alpha: = 1.0) -> void :
	var tex: = support_icon(sup)
	if tex == null:
		return
	var sz: = _icon_size(tex, h, float(GameData.TITLES[sup].get("icon_scale", 1.0)))
	sz *= 1.6
	ci.draw_texture_rect(tex, Rect2(left + Vector2( - sz.x - 3.0, - sz.y * 0.5), sz), false, Color(1, 1, 1, alpha))



static func support_badge(sup: String, side: = 16.0) -> Control:
	var ic: = UiKit.icon_rect(support_icon(sup), side)
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.mouse_filter = Control.MOUSE_FILTER_PASS
	ic.tooltip_text = name_of(sup)
	return ic


static func name_of(id: String) -> String:
	return TranslationServer.translate(str(GameData.TITLES[id].name)) if GameData.TITLES.has(id) else ""


static func _icon(mob: String) -> Texture2D:
	if mob == "":
		return null
	if not _icons.has(mob):
		_icons[mob] = StagePreview._cropped(mob)
	return _icons[mob]




static func title_icon(id: String) -> Texture2D:
	var d: Dictionary = GameData.TITLES.get(id, {})
	if d.has("job_icon"):
		var key: = "job:%d" % int(d.job_icon)
		if not _icons.has(key):
			var path: = "res://assets/ro/ui/skin/job_icons/%d.png" % int(d.job_icon)
			_icons[key] = load(path) as Texture2D if ResourceLoader.exists(path) else null
		return _icons[key]
	return _icon(str(d.get("mob", "")))





static func _icon_size(tex: Texture2D, h: float, scale: = 1.0) -> Vector2:
	if tex == null:
		return Vector2(h * 1.15, h * 1.15) * scale
	var aspect: = float(tex.get_width()) / maxf(1.0, float(tex.get_height()))
	var ih: = h * 1.15
	var iw: = ih * aspect
	if iw > h * 1.6:
		iw = h * 1.6
		ih = iw / aspect
	return Vector2(iw, ih) * scale




static func measure(id: String, fs: int, k: float, pill: bool) -> Vector2:
	var size: = int(fs * k)
	var h: = FONT.get_height(size)
	var w: = FONT.get_string_size(name_of(id), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x + 24.0 * k
	if str(GameData.TITLES.get(id, {}).get("tier", "")) == "especial":
		w += _icon_size(title_icon(id), h, float(GameData.TITLES[id].get("icon_scale", 1.0))).x + 3.0 * k
	if pill:
		w += 12.0 * k
	return Vector2(ceilf(w), ceilf(h + (6.0 * k if pill else 0.0)))





static func draw_title(ci: CanvasItem, center: Vector2, id: String, fs: int, k: float, alpha: = 1.0, pill: = false) -> void :
	if not GameData.TITLES.has(id):
		return
	var d: Dictionary = GameData.TITLES[id]
	var tier: = str(d.tier)
	var t: = Time.get_ticks_msec() / 1000.0
	var size: = int(fs * k)
	var text: = name_of(id)
	var tw: = FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var h: = FONT.get_height(size)
	var col: Color = d.color

	if d.get("rainbow", false):
		col = Color.from_hsv(fmod(t * 0.12, 1.0), 0.45, 1.0)
	var pulse: = 0.5 + 0.5 * sin(t * 3.0)
	var tex: Texture2D = title_icon(id) if tier == "especial" else null
	var isz: = _icon_size(tex, h, float(d.get("icon_scale", 1.0)))
	var icon_w: = isz.x + 3.0 * k if tier == "especial" else 0.0
	var total: = icon_w + tw
	var left: = center.x - total * 0.5

	var band: = Rect2(left - 13.0 * k, center.y - h * 0.5 - 3.0 * k, total + 26.0 * k, h + 6.0 * k)
	var hel: bool = d.get("hel", false)
	if pill:
		var plate: = StyleBoxFlat.new()
		plate.bg_color = Color(0.1, 0.11, 0.2, 0.94 * alpha)

		if hel:
			plate.bg_color = Color(0.13, 0.01, 0.03, 0.96 * alpha)
			plate.border_color = Color(col.lerp(Color(1.0, 0.55, 0.3), 0.35 * pulse), alpha)
			plate.set_border_width_all(maxi(1, int(1.5 * k)))
			plate.set_corner_radius_all(int(band.size.y * 0.5))
			ci.draw_style_box(plate, band)
			plate = null
		if plate != null:
			plate.border_color = Color(col.darkened(0.15), alpha)
			plate.set_border_width_all(maxi(1, int(k)))
			plate.set_corner_radius_all(int(band.size.y * 0.5))
			ci.draw_style_box(plate, band)
	if hel:
		_draw_hel_embers(ci, band, k, t, alpha)
	if tier == "especial":
		var halo: = StyleBoxFlat.new()
		halo.bg_color = Color(col, (0.16 + 0.16 * pulse) * alpha)
		halo.set_corner_radius_all(int(band.size.y * 0.5 + 3.0 * k))
		ci.draw_style_box(halo, band.grow(2.0 * k + 2.0 * k * pulse))

	for side in [-1.0, 1.0]:
		var at: = Vector2(center.x + side * (total * 0.5 + 6.0 * k), center.y)
		if hel:

			var fl: = 0.75 + 0.25 * sin(t * 9.0 + side * 2.0)
			var fh: = 5.5 * k * fl
			var fw: = 2.6 * k
			ci.draw_colored_polygon(PackedVector2Array([at + Vector2(0, - fh), at + Vector2(fw, fh * 0.15), at + Vector2(0, fh * 0.55), at + Vector2( - fw, fh * 0.15)]), 
				Color(1.0, 0.3, 0.12, alpha))
			ci.draw_colored_polygon(PackedVector2Array([at + Vector2(0, - fh * 0.5), at + Vector2(fw * 0.5, fh * 0.15), at + Vector2(0, fh * 0.4), at + Vector2( - fw * 0.5, fh * 0.15)]), 
				Color(1.0, 0.85, 0.5, alpha))
			continue
		if tier == "gloria":
			var s: = 2.5 * k
			ci.draw_colored_polygon(PackedVector2Array([at + Vector2(0, - s), at + Vector2(s, 0), at + Vector2(0, s), at + Vector2( - s, 0)]), 
				Color(col, 0.9 * alpha))
		else:
			var tw2: = 0.5 + 0.5 * sin(t * 4.2 + side * 1.7)
			var s: = (1.5 + 2.5 * tw2) * k
			var sc: = Color(col.lerp(Color.WHITE, 0.6), (0.5 + 0.5 * tw2) * alpha)
			ci.draw_line(at - Vector2(s, 0), at + Vector2(s, 0), sc, maxf(1.0, k))
			ci.draw_line(at - Vector2(0, s), at + Vector2(0, s), sc, maxf(1.0, k))
	if tex != null:

		var bob: = sin(t * 2.6) * 0.08 * h
		ci.draw_texture_rect(tex, Rect2(Vector2(left, center.y - isz.y * 0.5 + bob).floor(), isz), false, Color(1, 1, 1, alpha))
	var tc: = col.lerp(Color.WHITE, 0.32 * pulse) if tier != "gloria" else col
	tc.a = alpha
	var p: = Vector2(left + icon_w, center.y - h * 0.5 + FONT.get_ascent(size)).floor()
	ci.draw_string_outline(FONT, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, int(3 * k), Color(0, 0, 0, 0.85 * alpha))
	if hel:

		var x: = p.x
		for ch in UiKit.letters(text):
			var cw: = FONT.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
			var u: = (x - left) / maxf(1.0, total)
			var sweep: = clampf(1.0 - absf(fmod(t * 0.45, 1.6) - 0.3 - u) * 4.0, 0.0, 1.0)
			var lc: = col.lerp(Color(1.0, 0.72, 0.45), 0.85 * sweep)
			ci.draw_string(FONT, Vector2(x, p.y), ch, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(lc, alpha))
			x += cw
		return
	ci.draw_string(FONT, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, tc)




const HEL_EMBERS: = 16


static func _draw_hel_embers(ci: CanvasItem, band: Rect2, k: float, t: float, alpha: float) -> void :
	for i in HEL_EMBERS:
		var seed: = float(i) * 1.618
		var life: = 1.4 + fmod(seed * 0.7, 0.9)
		var u: = fmod(t / life + seed, 1.0)
		var x: = band.position.x + band.size.x * (0.08 + 0.84 * fmod(seed * 0.377, 1.0)) + sin(t * 2.0 + seed * 3.0) * 2.0 * k
		var y: = band.position.y + band.size.y * 0.5 - u * (band.size.y + 12.0 * k)
		var a: = sin(u * PI) * alpha
		var r: = (1.1 + 1.2 * (1.0 - u)) * k

		ci.draw_circle(Vector2(x, y), r * 2.2, Color(1.0, 0.2, 0.1, a * 0.25))
		ci.draw_circle(Vector2(x, y), r, Color(1.0, 0.45 + 0.4 * (1.0 - u), 0.2, a))



func chip(id: String, fs: = 10) -> Control:
	var c: = Chip.new()
	c.drawer = self
	c.id = id
	c.fs = fs
	return c


class Chip extends Control:
	var drawer: Object
	var id: = ""
	var fs: = 10

	func _ready() -> void :
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size = drawer.measure(id, fs, 1.0, true)
		size_flags_vertical = Control.SIZE_SHRINK_CENTER

	func _process(_delta: float) -> void :
		if str(GameData.TITLES.get(id, {}).get("tier", "gloria")) != "gloria" and is_visible_in_tree():
			queue_redraw()

	func _draw() -> void :
		drawer.draw_title(self, size * 0.5, id, fs, 1.0, 1.0, true)
