class_name NameFilter
extends RefCounted








const CONTAINS: = [

	"niger", "niga", "nigr", "nibba", "negrata", "fagot", "faget", "fagit", "kike", "chink", "wetback", 
	"sudaca", "tranny", "retard", "hitler", "nazi", "heil", 

	"fuck", "fuk", "shit", "bitch", "cunt", "whore", "slut", "pusy", "porn", "penis", "vagina", "pedo", "rapist", 
	"violador", "maricon", "mariquita", "hijodeputa", "hdp", "mierda", "conchetu", "conchesu", "culiao", "culiado", 
	"culia", "pendej", "gilipol", "chupal", "chupame", "malparid", "hijueputa", "cabron", "sidoso", 

	"caralh", "buceta", "filhodaputa", "filhadaputa", "arrombad", "punheta", 
	"xoxota", "piroca", "foder", "fodase", "cuzao", "desgracad", "vagabunda", "traveco", "sapatao", 
]
const WORDS: = [
	"puta", "puto", "putas", "putos", "marica", "maraco", "zorra", "perra", "verga", "pija", "polla", "coño", "cono", 
	"culo", "ctm", "csm", "ql", "weon", "huevon", "mongolo", "negro", "negra", "nig", "fag", "cock", "dick", "sex", 
	"anal", "anus", "rape", "cum", "tits", "ass", "asshole", "lesbo", "dyke", "spic", "kkk", 
	"cu", "fdp", "pqp", "vsf", "vtnc", "tnc", "krl", "crl", "corno", "bicha", "macaco", "piranha", "otario", 
	"merda", "bosta", "viado", "viados", "boquete", "porra", 
]
const LEET: = {"0": "o", "1": "i", "!": "i", "|": "i", "3": "e", "4": "a", "@": "a", "5": "s", "$": "s", 
	"7": "t", "8": "b", "9": "g", "6": "g", "2": "z", "+": "t"}
const ACCENTS: = {"á": "a", "à": "a", "ä": "a", "â": "a", "é": "e", "è": "e", "ë": "e", "ê": "e", "í": "i", 
	"ì": "i", "ï": "i", "î": "i", "ó": "o", "ò": "o", "ö": "o", "ô": "o", "ú": "u", "ù": "u", "ü": "u", 
	"û": "u", "ñ": "n", "ç": "c", "ý": "y"}





const RESERVED: = "nearq"
const DEV_TAG: = "nearQ"


const DEV_COLOR: = Color(1.0, 0.55, 0.95)


static func reserved(text: String) -> bool:
	return RESERVED in _merge("".join(_fold(text)))



static func dev_name(text: String) -> bool:
	return DEV_TAG in text



static func dev_line(line: String) -> bool:
	return line.contains(" : ") and dev_name(line.get_slice(" : ", 0))




static func shown(text: String) -> String:
	return "" if reserved(text) and not dev_name(text) else text




static var _contains_merged: = PackedStringArray()
static var _words: = {}
static var _words_single: = {}


static func _lists() -> void :
	if not _words.is_empty():
		return
	for w in CONTAINS:
		_contains_merged.append(_merge(w))
	for bad in WORDS:
		_words[bad] = true
		if _merge(bad) == bad:
			_words_single[bad] = true



static func allowed(text: String) -> bool:
	_lists()
	var words: = _fold(text)
	var squashed: = _merge("".join(words))
	for w in _contains_merged:
		if w in squashed:
			return false

	var glued: = "".join(words)
	for w in Array(words) + [glued]:
		if _is_bad_word(w):
			return false
	return true




static func _is_bad_word(w: String) -> bool:
	for form in [w, w.trim_suffix("s"), w.trim_suffix("es")]:


		var merged: = _merge(form)
		if _words.has(_runs(form, 2)) or _words_single.has(merged):
			return true
		if merged == "k" and form.length() >= 3 and _words.has("kkk"):
			return true
	return false



static func _runs(s: String, n: int) -> String:
	var out: = ""
	var run: = 0
	for i in s.length():
		run = run + 1 if i > 0 and s[i] == s[i - 1] else 1
		if run <= n:
			out += s[i]
	return out



static func clean(text: String) -> String:
	if allowed(text):
		return text
	var out: = PackedStringArray()
	for part in text.split(" ", false):
		out.append(part if allowed(part) else "*".repeat(part.length()))
	var joined: = " ".join(out)
	return joined if allowed(joined) else "*".repeat(text.length())



static func _fold(text: String) -> PackedStringArray:
	var s: = text.to_lower()
	var buf: = ""
	for ch in s:
		if ACCENTS.has(ch):
			ch = ACCENTS[ch]
		elif LEET.has(ch):
			ch = LEET[ch]
		buf += ch if (ch >= "a" and ch <= "z") else " "
	return buf.split(" ", false)



static func _merge(s: String) -> String:
	var out: = ""
	for ch in s:
		if out == "" or out[out.length() - 1] != ch:
			out += ch
	return out
