class_name Lang
extends RefCounted














const SOURCE: = "es"

const SETTING: = "language"

const NATIVE_NAMES: = {
	"es": "Español", 
	"en": "English", 
	"pt": "Português", 
	"fr": "Français", 
	"de": "Deutsch", 
	"it": "Italiano", 
	"ru": "Русский", 
	"zh_TW": "繁體中文", 
	"th": "ไทย", 
}



const RUNTIME_CATALOGS: = ["res://locale/ru.po", "res://locale/de.po", "res://locale/zh_TW.po", "res://locale/fr.po", "res://locale/th.po"]



static func available() -> PackedStringArray:
	var out: = PackedStringArray([SOURCE])
	for code in TranslationServer.get_loaded_locales():
		var lang: = TranslationServer.standardize_locale(code)
		if not out.has(lang):
			out.append(lang)
	return out



static func current() -> String:
	var locale: = TranslationServer.get_locale()
	var best: = SOURCE
	var best_score: = 0
	for code in available():
		var score: = TranslationServer.compare_locales(locale, code)
		if score > best_score:
			best = code
			best_score = score
	return best


static func display_name(code: String) -> String:
	return NATIVE_NAMES.get(code, TranslationServer.get_locale_name(code))



const DEFAULT: = "en"





static func apply_saved() -> void :
	_reload_catalogs()
	var args: = OS.get_cmdline_user_args()
	var code: = str(Save.setting(SETTING, ""))
	if "--lang" in args and args.find("--lang") + 1 < args.size():
		code = args[args.find("--lang") + 1]
	if not available().has(code):
		code = OS.get_locale_language()

	if code == "zh" and available().has("zh_TW"):
		code = "zh_TW"
	if not available().has(code):
		code = DEFAULT
	if not available().has(code):
		code = SOURCE
	TranslationServer.set_locale(code)





static func _reload_catalogs() -> void :
	var paths: = Array(ProjectSettings.get_setting("internationalization/locale/translations", PackedStringArray()))
	for path in RUNTIME_CATALOGS:
		if not paths.has(path) and ResourceLoader.exists(path):
			paths.append(path)
	for path in paths:
		var fresh: = ResourceLoader.load(str(path), "", ResourceLoader.CACHE_MODE_REPLACE) as Translation
		if fresh == null:
			continue
		var stale: = TranslationServer.get_translation_object(fresh.locale)
		for i in 4:
			if stale == null or stale == fresh:
				break
			TranslationServer.remove_translation(stale)
			stale = TranslationServer.get_translation_object(fresh.locale)
		TranslationServer.add_translation(fresh)

	if MouseWalk.touch():
		load("res://scripts/ui/touch_scroll.gd").strip_key_hints()






static func ui_tex(path: String) -> Texture2D:
	var code: = current()
	if code != SOURCE and path.begins_with(SKIN_ROOT):
		for c in [code, code.left(2)]:
			var local: String = LOCALE_ROOT + str(c) + "/" + path.substr(SKIN_ROOT.length())
			if ResourceLoader.exists(local):
				return load(local) as Texture2D
	return load(path) as Texture2D if ResourceLoader.exists(path) else null
const SKIN_ROOT: = "res://assets/ro/ui/skin/"
const LOCALE_ROOT: = "res://assets/ro/ui/locale/"


static func set_language(code: String) -> void :
	Save.set_setting(SETTING, code)
	TranslationServer.set_locale(code)



static func next() -> String:
	var all: = available()
	return all[(all.find(current()) + 1) % all.size()]
