extends HBoxContainer





















var menus: Menus
var world: World

const STAGE: = Vector2(320, 448)

const MACHINE_H: = 300.0
const MACHINE_TOP: = 40.0

const LAND: = Vector2(160, 390)

const RESULT_H: = 122.0
const RANKS: = ["common", "rare", "epic", "legendary", "unique"]




static var banner: = ""
const XMAS: = "christmas"

const GACHA_MANY: = 5
const RARITY_SOUND: = {"common": "drop_green", "rare": "drop_blue", "epic": "drop_purple", "legendary": "drop_yellow", "unique": "drop_yellow"}

static var force_rarity: = ""

var _stage: Control

var _layer: Control
var _floor_style: StyleBoxFlat
var _machine: TextureRect

var _machine_glow: TextureRect
var _machine_mid: = Vector2.ZERO
var _chute: = Vector2.ZERO
var _halo: TextureRect
var _rays: TextureRect
var _ray_speed: = 0.0
var _capsule: Control
var _prize: Control
var _flash: ColorRect
var _sprite: RoSprite
var _frame: = 0
var _frame_t: = 0.0
var _rainbow: = false
var _rainbow_t: = 0.0
var _info: VBoxContainer
var _result_box: VBoxContainer
var _spin_coins: Button
var _spin_zeny: Button

var _spin_coins5: Button
var _spin_zeny5: Button

var _pity_label: Label
var _head: Label
var _coins_label: Label
var _zeny_label: Label
var _busy: = false
var _skip: = false
var _skip_btn: Button
var _music_before: = ""

var _last: = {}


var _tweens: Array[Tween] = []
var _spin_n: = 0

var _hd: = {}
var _complete: Label


func _ready() -> void :
	add_theme_constant_override("separation", 16)
	_build_stage()
	_build_info()
	_refresh()

	if world != null:
		_music_before = str(world.get("_music_track"))
		world.play_music_map("gacha")


func _exit_tree() -> void :
	if world == null or not is_instance_valid(world):
		return


	if str(world.get("_music_track")) != "map:gacha":
		return
	if _music_before.begins_with("map:"):
		world.play_music_map(_music_before.trim_prefix("map:"))
	elif _music_before == "login":
		world.play_music("login")


func _process(delta: float) -> void :
	if _rays != null:
		_rays.rotation += delta * _ray_speed
	if _rainbow and _machine_glow != null:
		_rainbow_t += delta
		var hue: = Color.from_hsv(fmod(_rainbow_t * 0.45, 1.0), 0.65, 1.0)
		_machine_glow.modulate = Color(hue, _machine_glow.modulate.a)
		_halo.self_modulate = hue

	if _sprite == null or _machine == null:
		return
	_frame_t += delta
	var step: = maxf(0.05, _sprite.frame_delay(0))
	if _frame_t >= step:
		_frame_t = 0.0
		_frame = (_frame + 1) % maxi(1, _sprite.frame_count(0))
		_machine.texture = _hd_frame(_frame)
		_machine_glow.texture = _machine.texture


func _on_stage_input(event: InputEvent) -> void :


	if not _busy and _prize.visible and event is InputEventMouseButton and event.pressed:
		menus.ui_click()
		_reset_stage()



func _input(event: InputEvent) -> void :
	if not _busy or not is_visible_in_tree():
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
		_skip = true






static func _column_mid(img: Image, u: Rect2i) -> float:
	var sum: = 0.0
	var n: = 0
	for y in range(u.position.y + int(u.size.y * 0.45), u.end.y):
		var left: = -1
		var right: = -1
		for x in range(u.position.x, u.end.x):
			if img.get_pixel(x, y).a > 0.5:
				if left < 0:
					left = x
				right = x
		if left >= 0:
			sum += (left + right + 1) * 0.5
			n += 1
	return sum / n if n > 0 else u.position.x + u.size.x * 0.5

func _build_stage() -> void :
	_stage = Control.new()
	_stage.custom_minimum_size = STAGE
	_stage.clip_contents = true
	_stage.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.gui_input.connect(_on_stage_input)
	add_child(_stage)
	var floor_box: = Panel.new()
	_floor_style = StyleBoxFlat.new()
	_floor_style.bg_color = Color(1.0, 0.95, 0.97)
	_floor_style.border_color = Color(1.0, 0.7, 0.82)
	_floor_style.set_border_width_all(1)
	_floor_style.set_corner_radius_all(14)
	floor_box.add_theme_stylebox_override("panel", _floor_style)
	floor_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	floor_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(floor_box)
	_layer = Control.new()
	_layer.size = STAGE
	_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_layer)
	_sprite = RoAssets.sprite(["npc_gacha_machine"])


	var scale: = 2.0
	var used: = Rect2(Vector2.ZERO, Vector2(80, 150))
	var mid_x: = 40.0
	if _sprite != null:
		var img: = _sprite.compose_image(0, 0)
		var u: = img.get_used_rect() if img != null else Rect2i()
		if u.size.y > 0:
			used = Rect2(u)
			mid_x = _column_mid(img, u)
		scale = clampf(MACHINE_H / used.size.y, 1.5, 3.5)


	var top_left: = Vector2(STAGE.x * 0.5 - mid_x * scale, MACHINE_TOP - used.position.y * scale)
	_machine_mid = top_left + Vector2(mid_x, used.position.y + used.size.y * 0.45) * scale

	_chute = top_left + Vector2(mid_x, used.position.y + used.size.y * 0.94) * scale
	_rays = UiKit.rays(Color(1, 1, 1, 0), 440)
	_rays.position = _machine_mid - Vector2(220, 220)
	_rays.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_rays)
	_halo = UiKit.glow(Color(1.0, 1.0, 1.0, 0.55), 300)
	_halo.position = _machine_mid - Vector2(150, 150)
	_halo.pivot_offset = Vector2(150, 150)
	_halo.self_modulate = Color(1.0, 0.6, 0.8)
	_halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_halo)
	var pulse: = _halo.create_tween().set_loops()
	pulse.tween_property(_halo, "modulate:a", 0.55, 1.2).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(_halo, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE)
	_machine = TextureRect.new()


	_machine.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_machine.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_machine.stretch_mode = TextureRect.STRETCH_SCALE
	_machine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _sprite != null:
		_machine.size = Vector2(_sprite.canvas_size) * scale
		_machine.position = top_left
		_machine.pivot_offset = _chute - top_left
		_machine.texture = _hd_frame(0)
	_layer.add_child(_machine)
	_machine_glow = TextureRect.new()
	_machine_glow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_machine_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_machine_glow.stretch_mode = TextureRect.STRETCH_SCALE
	_machine_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_machine_glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_machine_glow.texture = _machine.texture
	var add: = CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_machine_glow.material = add
	_machine_glow.modulate = Color(1, 1, 1, 0)
	_machine.add_child(_machine_glow)
	_capsule = load("res://scripts/ui/gacha_capsule.gd").new()
	_capsule.visible = false
	_layer.add_child(_capsule)
	_prize = VBoxContainer.new()
	_prize.visible = false
	_prize.alignment = BoxContainer.ALIGNMENT_CENTER
	_prize.add_theme_constant_override("separation", 0)
	_prize.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_prize)

	_skip_btn = menus._ro_button(tr("Saltar  ▸▸"), func():
		_skip = true)
	_skip_btn.visible = false
	_skip_btn.position = Vector2(STAGE.x - 92.0, 8.0)
	_skip_btn.z_index = 5
	_stage.add_child(_skip_btn)
	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 1, 0)
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_flash)







func _hd_frame(f: int) -> Texture2D:
	if _hd.has(f):
		return _hd[f]
	var img: = _sprite.compose_image(0, f)
	if img == null:
		return null
	img.convert(Image.FORMAT_RGBA8)
	if not Menus.touch_ui() and not OS.has_feature("web"):
		img = _scale2x(_scale2x(img))
	img.generate_mipmaps()
	var tex: = ImageTexture.create_from_image(img)
	_hd[f] = tex
	return tex


static func _scale2x(src: Image) -> Image:
	var w: = src.get_width()
	var h: = src.get_height()
	var p: = src.get_data().to_int32_array()
	var o: = PackedInt32Array()
	o.resize(w * h * 4)
	var ow: = w * 2
	for y in h:
		var up: = maxi(y - 1, 0) * w
		var row: = y * w
		var dn: = mini(y + 1, h - 1) * w
		for x in w:
			var e: = p[row + x]
			var a: = p[up + x]
			var d: = p[dn + x]
			var c: = p[row + maxi(x - 1, 0)]
			var b: = p[row + mini(x + 1, w - 1)]
			var i: = (y * 2) * ow + x * 2
			o[i] = a if c == a and c != d and a != b else e
			o[i + 1] = b if a == b and a != c and b != d else e
			o[i + ow] = c if d == c and d != b and c != a else e
			o[i + ow + 1] = d if b == d and b != a and d != c else e
	return Image.create_from_data(ow, h * 2, false, Image.FORMAT_RGBA8, o.to_byte_array())




func _build_info() -> void :
	_info = VBoxContainer.new()
	_info.add_theme_constant_override("separation", 8)
	_info.custom_minimum_size.x = 330
	add_child(_info)
	var head: = menus._ro_text(tr("Cosméticos de la suerte"), 15, Color(0.75, 0.25, 0.5), true)
	_head = head
	_info.add_child(head)
	var refunds: Array = []
	for r in GameData.GACHA.dupe_coins:
		refunds.append("%s %d" % [tr(str(GameData.COSMETIC_RARITY[r].name)), GameData.gacha_refund(r)])
	var note: = menus._ro_text(tr("Solo cambian cómo te ves, nunca tus estadísticas. Cada giro da un cosmético; si ya lo tienes, te devuelve Poring Coins según su rareza: %s.") % ", ".join(refunds), 
		10, Color(0.28, 0.3, 0.4))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size.x = 320
	_info.add_child(note)

	var wallet: = HBoxContainer.new()
	wallet.add_theme_constant_override("separation", 6)
	_info.add_child(wallet)
	wallet.add_child(UiKit.icon_rect(Achievements.coin_icon(), 22))
	_coins_label = menus._ro_text("", 13, Color(0.55, 0.32, 0.0), true)
	wallet.add_child(_coins_label)
	var gap: = Control.new()
	gap.custom_minimum_size.x = 14
	wallet.add_child(gap)
	_zeny_label = menus._ro_text("", 13, Color(0.15, 0.17, 0.3), true)
	wallet.add_child(_zeny_label)


	var coins_row: = HBoxContainer.new()
	coins_row.add_theme_constant_override("separation", 6)
	_info.add_child(coins_row)
	_spin_coins = menus._ro_button(tr("Girar  ·  %d Poring Coins") % int(GameData.GACHA.coins), _spin.bind("coins"))
	_spin_coins.custom_minimum_size = Vector2(196, 38)
	coins_row.add_child(_spin_coins)
	_spin_coins5 = menus._ro_button(tr("x5  ·  %d") % (int(GameData.GACHA.coins) * GACHA_MANY), _spin.bind("coins", GACHA_MANY))
	_spin_coins5.custom_minimum_size = Vector2(118, 38)
	_spin_coins5.tooltip_text = tr("Cinco giros de una vez: %d Poring Coins.") % (int(GameData.GACHA.coins) * GACHA_MANY)
	coins_row.add_child(_spin_coins5)
	var zeny_row: = HBoxContainer.new()
	zeny_row.add_theme_constant_override("separation", 6)
	_info.add_child(zeny_row)
	_spin_zeny = menus._ro_button(tr("Girar  ·  %s z") % RoBasicWindow._thousands(int(GameData.GACHA.zeny)), _spin.bind("zeny"))
	_spin_zeny.custom_minimum_size = Vector2(196, 32)
	zeny_row.add_child(_spin_zeny)
	_spin_zeny5 = menus._ro_button(tr("x5  ·  %sM z") % str(int(GameData.GACHA.zeny) * GACHA_MANY / 1000000), _spin.bind("zeny", GACHA_MANY))
	_spin_zeny5.custom_minimum_size = Vector2(118, 32)
	_spin_zeny5.tooltip_text = tr("Cinco giros de una vez: %s z.") % RoBasicWindow._thousands(int(GameData.GACHA.zeny) * GACHA_MANY)
	zeny_row.add_child(_spin_zeny5)
	_pity_label = menus._ro_text("", 11, Color(0.8, 0.5, 0.05), true)
	_info.add_child(_pity_label)
	_complete = menus._ro_text(tr("¡Colección completa! Ya tienes todos los cosméticos de la máquina."), 10, Color(0.15, 0.5, 0.2), true)
	_complete.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_complete.custom_minimum_size.x = 320
	_complete.visible = false
	_info.add_child(_complete)

	var odds: = VBoxContainer.new()
	odds.add_theme_constant_override("separation", 2)
	_info.add_child(odds)
	odds.add_child(menus._ro_text(tr("Probabilidades"), 12, Color(0.12, 0.25, 0.75), true))
	for r in RANKS:
		var rar: Dictionary = GameData.COSMETIC_RARITY[r]
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		odds.add_child(row)
		var dot: = ColorRect.new()
		dot.color = rar.color
		dot.custom_minimum_size = Vector2(10, 10)
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(dot)
		var nm: = menus._ro_text(tr(str(rar.name)), 11, rar.color, true)
		nm.custom_minimum_size.x = 90
		row.add_child(nm)
		var pct: = float(GameData.GACHA.odds[r]) * 100.0
		var pl: = menus._ro_text(("%.1f%%" % pct) if pct < 10.0 else ("%d%%" % roundi(pct)), 11, Color(0.15, 0.17, 0.3), true)
		pl.custom_minimum_size.x = 50
		row.add_child(pl)
		var have: = menus._ro_text("", 10, Color(0.28, 0.3, 0.4))
		have.set_meta("rarity", r)
		row.add_child(have)


	_result_box = VBoxContainer.new()
	_result_box.add_theme_constant_override("separation", 4)
	_result_box.custom_minimum_size.y = RESULT_H
	_info.add_child(_result_box)
	var fill: = Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_info.add_child(fill)
	var bottom: = HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 6)
	bottom.alignment = BoxContainer.ALIGNMENT_END
	_info.add_child(bottom)
	var tryon: = menus._ro_button(tr("Armario"), func():
		var cid: = _class_id()
		if cid != "":
			menus.ui_click()
			menus.show_closet(cid))
	tryon.icon = menus._item_icon("wardrobe")
	bottom.add_child(tryon)
	bottom.add_child(menus._ro_button(tr("Cerrar"), func(): menus._back_to_hub()))


func _class_id() -> String:
	if world != null and world.get("town") != null and is_instance_valid(world.town):
		return str(world.town.class_id)
	return ""


func _refresh() -> void :
	_coins_label.text = tr("%d Poring Coins") % Save.coins()
	_zeny_label.text = tr("Zeny : %s") % RoBasicWindow._thousands(Save.zeny())
	var owned: = Save.owned_cosmetics()
	var pool: Array = GameData.COSMETICS.keys().filter( func(id): return in_pool(str(id)))
	if _head != null:
		_head.text = tr("Cosméticos de Navidad") if banner == XMAS else tr("Cosméticos de la suerte")
	var full: = pool.all( func(id): return owned.has(id))
	_spin_coins.disabled = _busy or full or Save.coins() < int(GameData.GACHA.coins)
	_spin_zeny.disabled = _busy or full or Save.zeny() < int(GameData.GACHA.zeny)
	_spin_coins5.disabled = _busy or full or Save.coins() < int(GameData.GACHA.coins) * GACHA_MANY
	var left: = pity_left()
	var eleft: = maxi(1, int(GameData.GACHA.epic_pity) - int(Save.data.get("gacha_pity_epic", 0)))
	_pity_label.text = (tr("¡El próximo giro es Legendario asegurado!") if left <= 1 else tr("Legendario asegurado en %d giros") % left)\
	+ "\n" + (tr("¡El próximo giro es Épico o mejor asegurado!") if eleft <= 1 else tr("Épico o mejor asegurado en %d giros") % eleft)
	_spin_zeny5.disabled = _busy or full or Save.zeny() < int(GameData.GACHA.zeny) * GACHA_MANY
	_complete.visible = full
	for row in _info.find_children("*", "Label", true, false):
		if not row.has_meta("rarity"):
			continue
		var r: = str(row.get_meta("rarity"))
		var ids: Array = GameData.COSMETICS.keys().filter( func(id): return str(GameData.COSMETICS[id].rarity) == r and in_pool(str(id)))
		var got: = ids.filter( func(id): return owned.has(id)).size()
		row.text = tr("tienes %d de %d") % [got, ids.size()]







static func has_art(id: String) -> bool:
	var d: Dictionary = GameData.COSMETICS.get(id, {})
	if not bool(d.get("gacha", true)):
		return false
	return art_ok(id)



static func art_ok(id: String) -> bool:
	var d: Dictionary = GameData.COSMETICS.get(id, {})
	if str(d.get("slot", "")) == "back":
		return RoAssets.has_sprite("robe_%s_swordsman" % str(d.get("view", "")))
	return RoAssets.has_sprite(str(d.get("view", "")))




static func in_pool(id: String, b: String = banner) -> bool:
	if b == "":
		return has_art(id)
	var d: Dictionary = GameData.COSMETICS.get(id, {})


	return (str(d.get("event", "")) == b or (d.get("also", []) as Array).has(b)) and art_ok(id)



static func pity_left() -> int:
	return maxi(1, int(GameData.GACHA.pity) - int(Save.data.get("gacha_pity", 0)))




static func roll(sure: = "") -> Dictionary:
	var odds: Dictionary = GameData.GACHA.odds
	var x: = randf()
	var rarity: = "common"
	for r in ["unique", "legendary", "epic", "rare", "common"]:
		if x < float(odds[r]):
			rarity = r
			break
		x -= float(odds[r])
	if force_rarity != "":
		rarity = force_rarity


	if sure != "" and RANKS.find(sure) > RANKS.find(rarity):
		rarity = sure
	var pool: Array = GameData.COSMETICS.keys().filter( func(id): return str(GameData.COSMETICS[id].rarity) == rarity and in_pool(str(id)))
	if pool.is_empty():
		pool = GameData.COSMETICS.keys().filter( func(id): return in_pool(str(id)))
	var id: = str(pool.pick_random())
	return {"id": id, "rarity": str(GameData.COSMETICS[id].rarity)}


func _spin(pay: String, n: = 1) -> void :
	if _busy:
		return
	var paid: = Save.spend_coins(int(GameData.GACHA.coins) * n) if pay == "coins" else Save.spend(int(GameData.GACHA.zeny) * n)
	if not paid:
		return


	var prizes: Array = []
	var best: = {}
	for i in n:


		var pity: = int(Save.data.get("gacha_pity", 0))


		var epity: = int(Save.data.get("gacha_pity_epic", 0))
		var sure: = "legendary" if pity >= int(GameData.GACHA.pity) - 1 else ("epic" if epity >= int(GameData.GACHA.epic_pity) - 1 else "")
		var prize: = roll(sure)
		Save.data["gacha_pity"] = 0 if str(prize.rarity) == "legendary" else pity + 1
		Save.data["gacha_pity_epic"] = 0 if str(prize.rarity) in ["epic", "legendary", "unique"] else epity + 1
		var fresh: = Save.add_cosmetic(str(prize.id))

		prize["refund"] = 0 if fresh else GameData.gacha_refund(str(prize.rarity))
		if not fresh:
			Save.add_coins(int(prize.refund))
		prize["new"] = fresh
		Save.bump("gacha_spins")
		prizes.append(prize)
		if best.is_empty() or RANKS.find(str(prize.rarity)) > RANKS.find(str(best.rarity)):
			best = prize
	Save.mark_dirty()
	Save.flush()
	_last = best
	_busy = true
	_skip = false
	_skip_btn.visible = true
	_refresh()
	for c in _result_box.get_children():
		c.queue_free()
	await _play(best)


	for prize in prizes:
		if bool(prize.new) and str(prize.rarity) in ["legendary", "unique"] and world != null and is_instance_valid(world) and world.get("channel") != null:
			world.channel.feat("gacha", str(prize.id), 4)
	if not is_inside_tree():
		return
	_busy = false
	_skip_btn.visible = false
	_refresh()
	if prizes.size() == 1:
		_show_result(best)
	else:
		_show_results(prizes)




func _show_results(prizes: Array) -> void :
	for c in _result_box.get_children():
		c.queue_free()
	var sorted: = prizes.duplicate()
	sorted.sort_custom( func(a, b): return RANKS.find(str(a.rarity)) > RANKS.find(str(b.rarity)))
	var best: Dictionary = GameData.COSMETIC_RARITY[str(sorted[0].rarity)]
	var card: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(best.color, 0.08)
	sb.border_color = best.color
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(6)
	card.add_theme_stylebox_override("panel", sb)
	_result_box.add_child(card)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	card.add_child(col)
	var outfit: = false
	for prize in sorted:
		var d: Dictionary = GameData.COSMETICS[str(prize.id)]
		var rar: Dictionary = GameData.COSMETIC_RARITY[str(prize.rarity)]
		outfit = outfit or (str(d.slot) == "body" and bool(prize.new))
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

		row.mouse_filter = Control.MOUSE_FILTER_STOP
		row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		row.tooltip_text = tr("Clic: verlo puesto")
		var shown_prize: Dictionary = prize
		row.gui_input.connect( func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT and not _busy:
				menus.ui_click()
				_reset_stage()
				_show_prize(shown_prize))
		col.add_child(row)
		var ic: = TextureRect.new()
		ic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.custom_minimum_size = Vector2(22, 17)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ic.texture = _picture(str(prize.id))
		row.add_child(ic)
		var nm: = menus._ro_text(tr(str(d.name)), 11, rar.color.darkened(0.25), true)
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.clip_text = true
		row.add_child(nm)
		row.add_child(menus._ro_text(tr("¡Nuevo!") if bool(prize.new) else "+%d PC" % int(prize.get("refund", 0)), 10, 
			Color(0.15, 0.5, 0.2) if bool(prize.new) else Color(0.55, 0.32, 0.0), true))
	if outfit:
		col.add_child(menus._ro_text(tr("Elígelo en tu Perfil, en «Te ven como»."), 10, Color(0.12, 0.45, 0.6), true))



func _tw() -> Tween:
	var t: = create_tween()
	_tweens = _tweens.filter( func(x): return x != null and x.is_valid())
	_tweens.append(t)
	return t


func _sound(key: String, db: = 0.0, pitch: = -1.0) -> void :
	if world != null:
		world.play_sound(key, 0.0, db, pitch, false, true)


func _wait(t: float) -> void :
	var left: = t
	while left > 0.0 and not _skip and is_inside_tree():
		await get_tree().process_frame
		if not is_inside_tree():
			return
		left -= get_process_delta_time()



func _play(prize: Dictionary) -> void :
	var rank: = RANKS.find(str(prize.rarity))
	_reset_stage()


	_sound("coin1")
	await _shake_machine(0.5, 3.0)
	if not is_inside_tree():
		return
	_tier(0, false)
	await _wait(0.3)

	for t in range(1, rank + 1):
		if _skip or not is_inside_tree():
			break

		_sound("coin2", -4.0, 0.9 + 0.2 * t)
		_gather(_tint(t), 6 + 4 * t)
		await _shake_machine(0.25 + 0.12 * t, 2.0 + 2.5 * t)
		if _skip or not is_inside_tree():
			break
		_tier(t, true)
		await _wait(0.4 + 0.2 * t)
	if not is_inside_tree():
		return
	if _skip:
		_tier(rank, false)
	await _wait(0.2)
	if not is_inside_tree():
		return

	await _capsule_out(prize, rank)
	if not is_inside_tree():
		return

	_open(prize, rank)
	await _wait(0.5)
	if is_inside_tree():
		_capsule.visible = false


func _tint(t: int) -> Color:
	return GameData.COSMETIC_RARITY[RANKS[clampi(t, 0, RANKS.size() - 1)]].color



func _reset_stage() -> void :
	_spin_n += 1
	for t in _tweens:
		if t != null and t.is_valid():
			t.kill()
	_tweens.clear()
	_capsule.set("open", 0.0)
	_capsule.set("glow", 0.0)
	_capsule.scale = Vector2.ONE
	_capsule.rotation = 0.0
	_machine_glow.modulate = Color(1, 1, 1, 0)
	_flash.color = Color(1, 1, 1, 0)
	_prize.scale = Vector2.ONE
	_prize.visible = false
	_capsule.visible = false
	_rainbow = false
	_machine.modulate.a = 1.0
	_machine.scale = Vector2.ONE
	_machine_glow.modulate = Color(1, 1, 1, 0)
	_rays.modulate = Color(1, 1, 1, 0)
	_ray_speed = 0.0
	_halo.self_modulate = Color(1.0, 0.6, 0.8)
	_halo.scale = Vector2.ONE
	_floor_style.bg_color = Color(1.0, 0.95, 0.97)
	_layer.position = Vector2.ZERO



func _shake_machine(time: float, power: float) -> void :
	var base: = _machine.position
	var left: = time
	var tick: = 0
	while left > 0.0 and not _skip and is_inside_tree():
		_machine.position = base + Vector2(randf_range( - power, power), randf_range( - power * 0.5, power * 0.3))
		_machine.rotation = deg_to_rad(randf_range(-1.0, 1.0) * power * 0.4)


		if bool(Save.setting("screen_shake", false)):
			_layer.position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * power * 0.35
		if tick % 4 == 0:
			_sound("coin2", -12.0, 0.8 + 0.05 * tick)
		tick += 1
		await _wait(0.05)
		left -= 0.05
	if is_inside_tree():
		_machine.position = base
		_machine.rotation = 0.0
		_layer.position = Vector2.ZERO





func _tier(t: int, burst: bool) -> void :
	var col: = _tint(t)
	var k: = float(t) / 3.0
	var tw: = _tw().set_parallel()
	tw.tween_property(_machine_glow, "modulate", Color(col.lightened(0.15), 0.3 + 0.55 * k), 0.25)
	tw.tween_property(_halo, "self_modulate", col.lightened(0.2), 0.3)
	tw.tween_property(_halo, "scale", Vector2.ONE * (1.0 + 0.35 * t), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_floor_style, "bg_color", Color(1.0, 0.95, 0.97).lerp(col.lightened(0.35), 0.3 + 0.35 * k), 0.4)
	if t > 0:
		tw.tween_property(_rays, "modulate", Color(col.lightened(0.3), minf(1.0, 0.35 + 0.25 * t)), 0.3)
		_ray_speed = 0.4 + 0.9 * t
	if not burst:
		if t >= 3:
			_rainbow = true
		return

	_flash.color = Color(col.lightened(0.6), 0.35 + 0.18 * t)
	_tw().tween_property(_flash, "color:a", 0.0, 0.35 + 0.1 * t)
	_shockwave(col, 1.0 + 0.6 * t)
	if t >= 2:
		var n: = _spin_n
		get_tree().create_timer(0.12, false).timeout.connect( func(): if is_inside_tree() and n == _spin_n: _shockwave(col.lightened(0.4), 1.4 + 0.6 * t))
	_sparks(_machine_mid, col, 14 + 10 * t, 70.0 + 30.0 * t)
	var pop: = _tw()
	pop.tween_property(_machine, "scale", Vector2.ONE * (1.06 + 0.03 * t), 0.08)
	pop.tween_property(_machine, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_sound(str(RARITY_SOUND[RANKS[t]]), -2.0 + t, 1.0 + 0.08 * t)
	if t >= 2:
		_sound("angelus", -6.0)
	if t >= 3:

		_rainbow = true
		_sound("levelup", 0.0)
		var n2: = _spin_n
		get_tree().create_timer(0.25, false).timeout.connect( func():
			if not is_inside_tree() or n2 != _spin_n:
				return
			_flash.color = Color(1.0, 0.95, 0.7, 0.7)
			_tw().tween_property(_flash, "color:a", 0.0, 0.6)
			_sparks(_machine_mid, Color(1.0, 0.85, 0.4), 40, 160.0))



func _shockwave(col: Color, size: float) -> void :
	var ring: = Panel.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = col.lightened(0.3)
	sb.set_border_width_all(4 + 2 * int(size))
	sb.set_corner_radius_all(100)
	sb.anti_aliasing = true
	ring.add_theme_stylebox_override("panel", sb)
	ring.size = Vector2(200, 200)
	ring.pivot_offset = Vector2(100, 100)
	ring.position = _machine_mid - Vector2(100, 100)
	ring.scale = Vector2.ONE * 0.2
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(ring)
	var t: = ring.create_tween().set_parallel()
	t.tween_property(ring, "scale", Vector2.ONE * size, 0.55).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(ring, "modulate:a", 0.0, 0.55).set_ease(Tween.EASE_IN)
	t.chain().tween_callback(ring.queue_free)



func _gather(col: Color, n: int) -> void :
	for i in n:
		var s: = ColorRect.new()
		s.color = col.lightened(randf_range(0.2, 0.6))
		s.size = Vector2.ONE * randf_range(3.0, 5.0)
		s.rotation = PI * 0.25
		s.position = _machine_mid + Vector2.from_angle(randf() * TAU) * randf_range(110.0, 170.0)
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		s.modulate.a = 0.0
		_layer.add_child(s)
		var t: = s.create_tween().set_parallel()
		t.tween_property(s, "modulate:a", 1.0, 0.15)
		t.tween_property(s, "position", _machine_mid, randf_range(0.35, 0.55)).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(randf() * 0.15)
		t.chain().tween_callback(s.queue_free)


func _sparks(at: Vector2, color: Color, n: int, reach: = 120.0) -> void :
	for i in n:
		var s: = ColorRect.new()
		s.color = color.lightened(randf_range(0.0, 0.5))
		s.size = Vector2.ONE * randf_range(3.0, 6.0)
		s.rotation = randf() * TAU
		s.position = at
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_layer.add_child(s)
		var to: = s.position + Vector2.from_angle(randf() * TAU) * randf_range(reach * 0.45, reach)
		var t: = s.create_tween().set_parallel()
		t.tween_property(s, "position", to, randf_range(0.5, 0.9)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		t.tween_property(s, "modulate:a", 0.0, 0.9).set_delay(0.3)
		t.chain().tween_callback(s.queue_free)



func _capsule_out(prize: Dictionary, rank: int) -> void :
	var col: = _tint(rank)
	_capsule.set("rarity", str(prize.rarity))
	_capsule.set("tint", col)
	_capsule.set("inside", _picture(str(prize.id)))
	_capsule.set("glow", 0.35 + 0.2 * rank)
	_capsule.set("open", 0.0)
	var box: Vector2 = _capsule.custom_minimum_size

	var ball: = box * 0.5 + Vector2(0, box.x * 0.25 * 0.35)
	_capsule.visible = true
	_capsule.rotation = 0.0
	_capsule.pivot_offset = ball
	_capsule.position = _chute - ball
	_capsule.scale = Vector2.ONE * 0.45
	_sound("coin3", -2.0)
	if not _skip:
		var drop: = _tw().set_parallel()
		drop.tween_property(_capsule, "position", LAND - ball, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		drop.tween_property(_capsule, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		drop.tween_property(_capsule, "rotation", PI, 0.6).set_ease(Tween.EASE_OUT)
		await _wait(0.65)
		if not is_inside_tree():
			return
	_capsule.position = LAND - ball
	_capsule.scale = Vector2.ONE
	_capsule.rotation = 0.0

	for k in 1 + mini(rank, 2):
		if _skip:
			break
		var w: = _tw()
		w.tween_property(_capsule, "rotation", deg_to_rad(14), 0.08)
		w.tween_property(_capsule, "rotation", deg_to_rad(-14), 0.13)
		w.tween_property(_capsule, "rotation", 0.0, 0.08)
		_sound("coin2", -6.0, 1.0 + 0.15 * k)
		await _wait(0.36)
		if not is_inside_tree():
			return
	_capsule.rotation = 0.0



func _open(prize: Dictionary, rank: int) -> void :
	var col: = _tint(rank)
	var ot: = _tw()
	ot.tween_property(_capsule, "open", 1.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_flash.color = Color(col.lightened(0.6), 0.5 + 0.12 * rank)
	_tw().tween_property(_flash, "color:a", 0.0, 0.5)
	_shockwave(col, 1.6 + 0.4 * rank)
	_sparks(LAND, col, 16 + rank * 8, 130.0)
	_sound("chest_open")
	_sound(str(RARITY_SOUND.get(str(prize.rarity), "drop_green")), 0.0)
	_show_prize(prize)


func _show_prize(prize: Dictionary) -> void :
	for c in _prize.get_children():
		c.queue_free()
	var rar: Dictionary = GameData.COSMETIC_RARITY[str(prize.rarity)]
	var d: Dictionary = GameData.COSMETICS[str(prize.id)]

	_prize.add_child(_wearing(str(prize.id)))

	var ribbon: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.92)
	sb.border_color = rar.color
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 3
	sb.content_margin_bottom = 4
	sb.shadow_color = Color(rar.color, 0.35)
	sb.shadow_size = 6
	ribbon.add_theme_stylebox_override("panel", sb)
	ribbon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ribbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prize.add_child(ribbon)
	var lines: = VBoxContainer.new()
	lines.add_theme_constant_override("separation", 0)
	ribbon.add_child(lines)
	var tag: = menus._ro_text(tr(str(rar.name)).to_upper(), 11 if not str(prize.rarity) in ["legendary", "unique"] else 12, rar.color, true)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lines.add_child(tag)
	var nm: = menus._ro_text(tr(str(d.name)), 15, Color(0.15, 0.17, 0.3), true)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if nm.get_minimum_size().x > STAGE.x - 60.0:
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		nm.custom_minimum_size.x = STAGE.x - 60.0
	lines.add_child(nm)


	_prize.custom_minimum_size = Vector2(STAGE.x, 0)
	_prize.size = Vector2(STAGE.x, STAGE.y - 24.0)
	_prize.position = Vector2(0, 12)
	_prize.visible = true
	_prize.pivot_offset = Vector2(STAGE.x * 0.5, STAGE.y - 80.0)
	_prize.scale = Vector2(0.3, 0.3)
	_prize.modulate.a = 0.0
	var t: = _tw().set_parallel()
	t.tween_property(_prize, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(_prize, "modulate:a", 1.0, 0.2)

	_tw().tween_property(_machine, "modulate:a", 0.15, 0.3)



func _wearing(id: String) -> Control:
	var cid: = _class_id()
	if cid == "":
		cid = "swordsman"
	var look: = Save.look(cid)
	var shown: Dictionary = GameData.shown_job(cid, look)
	var lo: = Save.loadout(cid)
	var items: = {}
	for slot in lo:
		items[slot] = Save.storage_item(str(lo[slot]))
	var cos: = Save.worn_cosmetics(cid).duplicate()
	var body: = str(shown.body)
	var weapon: = str(shown.weapon)
	if str(GameData.COSMETICS[id].slot) == "body":

		var as_outfit: = look.duplicate()
		as_outfit["show"] = id
		look = as_outfit
		body = str(GameData.COSMETICS[id].view)
		weapon = ""
	else:
		cos[str(GameData.COSMETICS[id].slot)] = id
	var views: = Equipment.views_of(items, cid, cos, look)
	var preview: VBoxContainer = load("res://scripts/ui/look_preview.gd").new()
	preview.set("stage_size", Vector2(260, 280))
	preview.set("auto_turn", true)
	preview.set("show_controls", false)
	preview.call("setup", body, weapon, look, views.head, views.extras)
	preview.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return preview



func _picture(id: String) -> Texture2D:
	var cid: = _class_id()
	var look: = Save.look(cid) if cid != "" else {}
	var body: = str(GameData.shown_job(cid, look).body) if cid != "" else "novice"
	return menus._cosmetic_picture(id, body, look)



func _show_result(prize: Dictionary) -> void :
	for c in _result_box.get_children():
		c.queue_free()
	var d: Dictionary = GameData.COSMETICS[str(prize.id)]
	var rar: Dictionary = GameData.COSMETIC_RARITY[str(prize.rarity)]
	var card: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(rar.color, 0.1)
	sb.border_color = rar.color
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(8)
	card.add_theme_stylebox_override("panel", sb)
	_result_box.add_child(card)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	card.add_child(col)
	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	col.add_child(top)
	var ic: = TextureRect.new()
	ic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.custom_minimum_size = Vector2(32, 26)
	ic.texture = _picture(str(prize.id))
	top.add_child(ic)
	top.add_child(menus._ro_text(tr(str(d.name)), 14, rar.color.darkened(0.2), true))
	top.add_child(menus._ro_text(tr(str(rar.name)), 11, rar.color, true))
	var what: = (tr("¡Nuevo! Ya es tuyo.") if str(d.slot) == "body" else tr("¡Nuevo! Ya es tuyo: póntelo cuando quieras.")) if bool(prize.new)\
	else tr("Ya lo tenías: Poring Coin +%d.") % int(prize.get("refund", GameData.gacha_refund(str(prize.rarity))))
	col.add_child(menus._ro_text(what, 10, Color(0.15, 0.5, 0.2) if bool(prize.new) else Color(0.55, 0.32, 0.0)))
	col.add_child(menus._ro_text(tr("Va en: %s") % tr(str(GameData.COSMETIC_SLOT_NAMES[d.slot])), 10, Color(0.28, 0.3, 0.4)))
	if str(d.slot) == "body":

		col.add_child(menus._ro_text(tr("Elígelo en tu Perfil, en «Te ven como»."), 11, Color(0.12, 0.45, 0.6), true))
		return
	var cid: = _class_id()
	if cid != "":
		var worn: = Save.worn_cosmetics(cid)
		if str(worn.get(str(d.slot), "")) != str(prize.id):
			var wear: = menus._ro_button(tr("Ponérmelo"), func():
				Save.wear_cosmetic(cid, str(d.slot), str(prize.id))
				menus.ui_click()
				if world.town != null and is_instance_valid(world.town):
					world.town.refresh_hero()
				_show_result(prize))
			col.add_child(wear)
		else:
			col.add_child(menus._ro_text(tr("Lo llevas puesto."), 10, Color(0.15, 0.5, 0.2), true))
