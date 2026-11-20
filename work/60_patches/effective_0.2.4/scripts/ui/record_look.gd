class_name RecordLook
extends Control








const ROOT: = "res://assets/ro/ui/skin/login_interface/"


const SLOT: = Rect2(56, 39, 139, 144)
const FEET: = Vector2(65 + 5, 160 - 39)
const ZOOM: = 2.0

var _sprite: RoSprite
var _frame: = 0
var _time: = 0.0
var _stage: Control
var _front: Control
var _aura: RebirthAura.Preview
var _bg: Texture2D
var _box: Texture2D

static var _key_re: RegEx



static func _key(v) -> String:
	if _key_re == null:
		_key_re = RegEx.create_from_string("^[a-z0-9_]{1,48}$")
	var s: = str(v) if v != null else ""
	return s if _key_re.search(s) != null else ""


func _init(look, class_id: String) -> void :
	custom_minimum_size = SLOT.size * ZOOM
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var d: Dictionary = GameData.CLASSES.get(class_id, {})
	var l: Dictionary = look if look is Dictionary else {}
	var body: = _key(l.get("b", d.get("body", "")))
	if body == "":
		body = str(d.get("body", ""))
	var extras: Array = []
	for x in (l.get("x", []) as Array if l.get("x", []) is Array else []) + (l.get("cos", []) as Array if l.get("cos", []) is Array else []):
		var k: = _key(x)
		if k != "" and extras.size() < 8:
			extras.append(k)
	var appearance: = {"gender": "f" if str(l.get("g", "m")) == "f" else "m", "hair": clampi(int(l.get("hr", 2)), 1, 40), 
		"hair_color": clampi(int(l.get("hc", 0)), 0, 20), "cloth": clampi(int(l.get("c", 0)), 0, 20)}
	if body != "":
		_sprite = RoAssets.styled_character(body, _key(l.get("w", d.get("weapon", ""))), _key(l.get("wf", d.get("weapon_fx", ""))), 
			[int(d.get("attack", RoVisual.PC_ATTACK))], _key(l.get("h", "")), appearance, _key(l.get("s", "")), extras)
		if _sprite == null:

			_sprite = RoAssets.styled_character(str(d.get("body", "")), str(d.get("weapon", "")), str(d.get("weapon_fx", "")), 
				[int(d.get("attack", RoVisual.PC_ATTACK))], "", appearance, "", [])


	for n in ["win_select2"]:
		var path: String = ROOT + n + ".png"
		var t: Texture2D = Lang.ui_tex(path)
		if n == "win_select2" and t != null:
			var a: = AtlasTexture.new()
			a.atlas = t
			a.region = SLOT
			_bg = a
		elif t != null:
			_box = t

	_stage = Control.new()
	_stage.size = SLOT.size
	_stage.scale = Vector2(ZOOM, ZOOM)
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.texture_filter = RoAssets.ui_filter()
	_stage.draw.connect(_draw_slot)
	add_child(_stage)
	if bool(l.get("a", false)):

		_aura = RebirthAura.Preview.new()
		_stage.add_child(_aura)
		var r: = TextureRect.new()
		r.texture = _aura.get_texture()
		r.material = _aura.ui_material()
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var clip: = Control.new()
		clip.clip_contents = true
		clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip.position = Vector2(7, 6)
		clip.size = Vector2(126, 133)
		_stage.add_child(clip)
		r.position = (FEET - RebirthAura.Preview.FEET).floor() - clip.position
		clip.add_child(r)
	_front = Control.new()
	_front.size = SLOT.size
	_front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_front.texture_filter = RoAssets.ui_filter()
	_front.draw.connect(_draw_hero)
	_stage.add_child(_front)


func _process(delta: float) -> void :
	if _sprite == null:
		return

	var action: = RoVisual.PC_WALK * RoSprite.DIRS
	_time += delta
	var delay: = _sprite.frame_delay(action)
	if _time >= delay:
		_time -= delay
		_frame = (_frame + 1) % maxi(1, _sprite.frame_count(action))
		_front.queue_redraw()


func _draw_slot() -> void :


	var slot: = StyleBoxFlat.new()
	slot.bg_color = Color(0.9, 0.93, 1.0)
	slot.border_color = Color(0.3, 0.42, 0.78)
	slot.set_border_width_all(2)
	slot.set_corner_radius_all(8)
	slot.anti_aliasing = true
	_stage.draw_style_box(slot, Rect2(Vector2(5, 4), Vector2(130, 137)))
	_stage.draw_set_transform(FEET, 0.0, Vector2(1.0, 0.42))
	_stage.draw_circle(Vector2.ZERO, 24.0, Color(0.2, 0.25, 0.4, 0.16))
	_stage.draw_circle(Vector2.ZERO, 16.0, Color(0.2, 0.25, 0.4, 0.14))
	_stage.draw_set_transform(Vector2.ZERO)


func _draw_hero() -> void :
	if _sprite == null:
		return
	var tex: = _sprite.get_frame(RoVisual.PC_WALK * RoSprite.DIRS, _frame)
	if tex != null:
		_front.draw_texture(tex, (FEET - Vector2(_sprite.origin)).floor())
