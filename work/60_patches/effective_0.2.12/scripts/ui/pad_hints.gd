extends Node











const SCAN_EVERY: = 0.6

var world: Node
var pad_on: = false

var style: = "xbox"
var _scan_t: = 0.0
var _cache: = {}
var _re_paren: RegEx
var _re_sep: RegEx
var _re_seg: RegEx
var _re_lead: RegEx
var _re_er: RegEx


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	var key: = "(?:Tab|TAB|Esc|ESC|Enter|ENTER|Espacio|Space|Espaço|Shift|Ctrl|Alt|Supr|F\\d{1,2}|WASD|[A-Z])"
	var sep: = "(?:\\s*/\\s*|\\s+(?:o|or|ou)\\s+)"
	_re_paren = RegEx.create_from_string("(\\s*)\\((" + key + "(?:" + sep + key + ")*)\\)")
	_re_sep = RegEx.create_from_string("\\s+·\\s+")
	var mouse: = "(?:(?:[Dd]oble|[Dd]ouble|[Dd]uplo|[Rr]ight)[ -])?(?:[Cc]lic|[Cc]lick|[Cc]lique)(?:[ -](?:derecho|direito|duplo|der\\.))?"
	var item: = "(?:" + key + "(?:\\s*\\+\\s*" + mouse + ")?|" + mouse + "|←/→|↑/↓|←→|↑↓|\\d-\\d)"
	_re_seg = RegEx.create_from_string("^(\\s*)(" + item + "(?:" + sep + item + ")*)(\\s*:)")
	_re_lead = RegEx.create_from_string("^(\\s*)(Esc|Enter|Tab)(\\s)")
	_re_er = RegEx.create_from_string("\\bC / V\\b")


func _process(delta: float) -> void :
	if not pad_on:
		return
	_scan_t -= delta
	if _scan_t > 0.0:
		return
	_scan_t = SCAN_EVERY
	for root in [world.get("hud") if world != null else null, world.get("menus") if world != null else null]:
		if root is Node and is_instance_valid(root):
			_convert_tree(root)



func set_pad(on: bool, pad_name: = "") -> void :
	var low: = pad_name.to_lower()
	var want: = "ps" if (low.contains("ps") or low.contains("playstation") or low.contains("dualsense") or low.contains("dualshock") or low.contains("sony")) else "xbox"
	if on == pad_on and ( not on or want == style):
		return
	if pad_on:
		_restore_tree(get_tree().root)
	pad_on = on
	style = want
	_cache.clear()
	if on:
		if not get_tree().node_added.is_connected(_on_added):
			get_tree().node_added.connect(_on_added)
		_convert_tree(get_tree().root)
		_scan_t = SCAN_EVERY
	elif get_tree().node_added.is_connected(_on_added):
		get_tree().node_added.disconnect(_on_added)


func _on_added(n: Node) -> void :
	if n is Label or n is Button or n is RichTextLabel:

		_convert_node.call_deferred(n)


func _convert_tree(root: Node) -> void :
	for t in ["Label", "Button", "RichTextLabel"]:
		for n in root.find_children("*", t, true, false):
			_convert_node(n)


func _restore_tree(root: Node) -> void :
	for t in ["Label", "Button", "RichTextLabel"]:
		for n in root.find_children("*", t, true, false):
			if n.has_meta("_pad_in"):
				if str(n.get("text")) == str(n.get_meta("_pad_out", "")):
					n.set("text", n.get_meta("_pad_in"))
				n.remove_meta("_pad_in")
				n.remove_meta("_pad_out")


func _convert_node(n: Node) -> void :
	if not pad_on or not is_instance_valid(n) or n.has_meta("no_pad"):
		return
	var t: = str(n.get("text"))
	if t == "" or (n.has_meta("_pad_out") and str(n.get_meta("_pad_out")) == t):
		return

	var out: = (str(n.get_meta("pad_ps" if style == "ps" else "pad_xbox")) if n.has_meta("pad_xbox") else convert_text(t))
	if out == t:
		return
	n.set_meta("_pad_in", t)
	n.set_meta("_pad_out", out)
	n.set("text", out)




func glyph(b: String) -> String:
	var ps: = style == "ps"
	match b:
		"A":
			return "×" if ps else "Ⓐ"
		"X":
			return "□" if ps else "Ⓧ"
	return b



func _button(tok: String, in_paren: bool) -> Variant:
	var ps: = style == "ps"
	match tok:
		"Esc", "ESC":
			return "○" if ps else "Ⓑ"
		"Enter", "ENTER":
			return "×" if ps else "Ⓐ"
		"Tab", "TAB", "C":
			return "Share" if ps else "View"
		"Q", "I":
			return "△" if ps else "Ⓨ"
		"F":
			return "□" if ps else "Ⓧ"
		"X":


			return ("□" if ps else "Ⓧ") if in_paren else ""
		"G":
			return "R3" if ps else "RS"
		"V":

			return "R2" if ps else "RT"
		"WASD":
			return "Ⓛ"
		"E", "R", "M", "O", "H", "P", "Espacio", "Space", "Espaço", "Shift", "Ctrl", "Alt", "Supr":
			return ""
	if tok.begins_with("F") and tok.length() <= 3 and tok.substr(1).is_valid_int():
		return ""
	return null



func convert_text(text: String) -> String:
	if _cache.has(text):
		return _cache[text]
	var out: = text

	var er: = "R2" if style == "ps" else "RT"
	out = _re_er.sub(out, er, true)
	out = _convert_parens(out)
	out = _convert_segments(out)

	if out.strip_edges() == "":
		out = text
	_cache[text] = out
	return out


func _split_tokens(s: String) -> Array:
	var parts: = []
	s = s.replace("←/→", "←→").replace("↑/↓", "↑↓")
	for chunk in s.split("/"):
		for piece in RegEx.create_from_string("\\s+(?:o|or|ou)\\s+").sub(chunk, "", true).split(""):
			if piece.strip_edges() != "":
				parts.append(piece.strip_edges())
	return parts


func _convert_parens(text: String) -> String:
	var out: = ""
	var at: = 0
	for m in _re_paren.search_all(text):
		var toks: = _split_tokens(m.get_string(2))
		var mapped: Array[String] = []
		var all_keys: = true
		for t in toks:
			var b = _button(t, true)
			if b == null:
				all_keys = false
				break
			if str(b) != "" and not mapped.has(str(b)):
				mapped.append(str(b))
		out += text.substr(at, m.get_start() - at)
		if not all_keys:
			out += m.get_string()
		elif not mapped.is_empty():
			out += m.get_string(1) + "(" + " / ".join(mapped) + ")"
		at = m.get_end()
	return out + text.substr(at)


func _convert_segments(text: String) -> String:
	var seps: = _re_sep.search_all(text)
	var pieces: Array[String] = []
	var glue: Array[String] = []
	var at: = 0
	for m in seps:
		pieces.append(text.substr(at, m.get_start() - at))
		glue.append(m.get_string())
		at = m.get_end()
	pieces.append(text.substr(at))
	var out: = ""
	var first: = true
	var changed: = false
	for i in pieces.size():
		var p: = _convert_segment(pieces[i])
		if p != pieces[i]:
			changed = true
		if p == DROP:
			continue
		if not first:
			out += glue[i - 1]
		out += p
		first = false
	return out if changed else text




const DROP: = "<drop>"




func _convert_segment(seg: String) -> String:
	var lead: = _re_lead.search(seg)
	if lead != null:
		var b = _button(lead.get_string(2), false)
		if b != null:
			if str(b) == "":
				return DROP
			return lead.get_string(1) + str(b) + lead.get_string(3) + seg.substr(lead.get_end())
	var m: = _re_seg.search(seg)
	if m == null:
		return seg
	var items: = _split_tokens(m.get_string(2))
	var out: Array[String] = []
	var any_key: = false
	for it in items:
		if it.contains("+"):

			any_key = true
			continue
		var b = _button(it, false)
		if b == null:
			out.append(it)
			continue
		any_key = true
		if str(b) != "" and not out.has(str(b)):
			out.append(str(b))
	if not any_key:
		return seg
	if out.is_empty():
		return DROP
	return m.get_string(1) + " / ".join(out) + m.get_string(3) + seg.substr(m.get_end())
