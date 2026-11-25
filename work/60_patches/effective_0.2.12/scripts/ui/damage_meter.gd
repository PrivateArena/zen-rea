class_name DamageMeter
extends Control






const ELEMENT_COLORS: = {
	"neutral": Color(0.62, 0.68, 0.8), "water": Color(0.45, 0.68, 0.98), "earth": Color(0.72, 0.58, 0.38), 
	"fire": Color(0.98, 0.55, 0.32), "wind": Color(0.66, 0.85, 0.4), "poison": Color(0.62, 0.78, 0.35), 
	"holy": Color(0.98, 0.88, 0.45), "shadow": Color(0.62, 0.48, 0.82), "ghost": Color(0.78, 0.72, 0.95), 
	"undead": Color(0.55, 0.55, 0.6), 
}

var world: World

var compact: = true


var mode: = "damage"
var max_rows: = 6
var row_height: = 15.0

var data: Array = []
var _timer: = 0.0
var _font: Font = preload("res://assets/ro/fonts/SCDream4.otf")
var _font_bold: Font = preload("res://assets/ro/fonts/SCDream6.otf")
var _icons: = {}


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = RoAssets.ui_filter()
	_resize()


func _process(delta: float) -> void :
	if not compact or world == null:
		return
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = 0.25
	data = world.meter_rows("damage" if mode == "dps" else mode)
	if mode == "party":
		_icons.clear()
	_resize()
	queue_redraw()


func _resize() -> void :
	custom_minimum_size.y = row_height * maxi(1, mini(max_rows, data.size()))




const SHORT_UNITS: = [[1.0000000000000001e+33, "Dc"], [9.999999999999999e+29, "No"], [1e+27, "Oc"], [1e+24, "Sp"], [1e+21, "Sx"], [1e+18, "Qi"], [1e+15, "Q"], 
	[1000000000000.0, "T"], [1000000000.0, "B"], [1000000.0, "M"]]


static func short(v: float) -> String:


	if v >= 9.9995e+35:
		var e: = floori(log(v) / log(10.0))
		var m: = v / pow(10.0, e)
		if m >= 9.95:
			m /= 10.0
			e += 1
		return "%.1fe%d" % [m, e]

	for u in SHORT_UNITS:
		if v >= float(u[0]) * 0.99995:
			return "%.1f%s" % [v / float(u[0]), u[1]]
	if v >= 10000.0:
		return "%dk" % roundi(v / 1000.0)
	if v >= 1000.0:
		return "%.1fk" % (v / 1000.0)
	return str(roundi(v))


func _row_label(tag: String) -> String:
	match mode:
		"taken":
			return world.taken_label(tag)
		"heal":
			return world.heal_label(tag)
	return world.meter_label(tag)


func _icon(tag: String) -> Texture2D:
	var key: = mode + ":" + tag
	if not _icons.has(key):
		if mode == "taken":
			var id: = tag.trim_prefix("mechanics:")
			_icons[key] = StagePreview._cropped(id) if GameData.MONSTERS.has(id) else null
		else:
			_icons[key] = world.meter_icon(tag) if world != null else null
	return _icons[key]


func _draw() -> void :
	if data.is_empty():
		draw_string(_font, Vector2(2, row_height - 4), tr("Sin daño todavía"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, 
			Color(0.28, 0.3, 0.4))
		return
	var top: float = data[0].dmg
	var total: = 0.0
	for r in data:
		total += float(r.dmg)
	var w: = size.x
	var fs: = 10 if compact else 12
	for i in mini(max_rows, data.size()):
		var r: Dictionary = data[i]
		var y: = i * row_height
		var bar: = Rect2(0, y + 1, w, row_height - 2)
		draw_rect(bar, Color(0.9, 0.92, 0.96))
		var c: Color = ELEMENT_COLORS.get(r.el, ELEMENT_COLORS.neutral)
		if r.has("slot"):
			c = World.PARTY_COLORS[int(r.slot) % World.PARTY_COLORS.size()]
		draw_rect(Rect2(bar.position, Vector2(w * float(r.dmg) / maxf(top, 1.0), bar.size.y)), Color(c, 0.85))
		var x: = 2.0
		var icon: = _icon(r.tag)
		if icon != null:
			var s: = row_height - 3.0
			draw_texture_rect(icon, Rect2(x, y + 1.5, s, s), false)
			x += s + 3.0
		var value: = (short(r.dmg) if mode != "dps" else "%s/s" % short(float(r.dmg) / world.meter_time())) if compact else "%s  (%d%%)" % [short(r.dmg), roundi(100.0 * float(r.dmg) / maxf(total, 1.0))]
		var vw: = (_font_bold if compact else _font).get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var dps_w: = 0.0
		if not compact or mode == "party":
			var dps: = "%s/s" % short(float(r.dmg) / maxf(1.0, world.time - float(r.first)))
			if compact:

				dps_w = 44.0
				draw_string(_font_bold, Vector2(w - vw - dps_w - 6, y + row_height - 4), value, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.BLACK)
				draw_string(_font, Vector2(w - dps_w, y + row_height - 4), dps, HORIZONTAL_ALIGNMENT_RIGHT, dps_w - 3, fs, 
					Color(0.25, 0.27, 0.35))
				var nw: = w - x - vw - dps_w - 12.0
				draw_string(_font, Vector2(x, y + row_height - 4), _fit("%d. %s" % [i + 1, world.meter_label(r.tag)], nw, fs), 
					HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.08, 0.1, 0.18))
				continue
			dps_w = 64.0
			draw_string(_font, Vector2(w - vw - dps_w - 8, y + row_height - 4), value, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.BLACK)
			draw_string(_font, Vector2(w - dps_w, y + row_height - 4), dps, HORIZONTAL_ALIGNMENT_RIGHT, dps_w - 3, fs, 
				Color(0.25, 0.27, 0.35))
		else:
			draw_string(_font_bold, Vector2(w - vw - 3, y + row_height - 4), value, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.BLACK)
		var name_w: = w - x - vw - dps_w - 12.0
		draw_string(_font, Vector2(x, y + row_height - 4), _fit("%d. %s" % [i + 1, _row_label(r.tag)], name_w, fs), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.08, 0.1, 0.18))



func _fit(text: String, width: float, fs: int) -> String:
	if _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x <= width:
		return text
	while text.length() > 1 and _font.get_string_size(text + "...", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > width:
		text = text.substr(0, text.length() - 1)
	return text.strip_edges() + "..."
