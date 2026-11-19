extends RefCounted
















const MARK: = "user://render_start.mark"
const TRIED: = "user://render_tried.txt"
const SAFE_SECS: = 15.0

const CHAIN: = {"opengl3": "opengl3_angle", "opengl3_angle": "d3d12", "d3d12": "vulkan", "vulkan": "opengl3_angle"}
const NAMES: = {"opengl3": "OpenGL", "opengl3_angle": "OpenGL (ANGLE)", "d3d12": "DirectX 12", "vulkan": "Vulkan"}

const OLD_MARK: = "user://d3d12_start.mark"


static func _on() -> bool:
	return OS.get_name() == "Windows" and not OS.has_feature("editor") and DisplayServer.get_name() != "headless"


static func _driver() -> String:
	return RenderingServer.get_current_rendering_driver_name()




static func early() -> bool:
	if not _on():
		return false
	var driver: = _driver()
	var dead: = ""
	for path in [MARK, OLD_MARK]:
		if not FileAccess.file_exists(path):
			continue
		var text: = FileAccess.get_file_as_string(path)
		var pid: = text.get_slice("|", 1).to_int()
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

		if pid > 0 and pid != OS.get_process_id() and OS.is_process_running(pid):
			continue
		var was: = text.get_slice("|", 2)
		dead = was if CHAIN.has(was) else (driver if path == MARK else "d3d12")
	if dead != "" and _move_on(dead):
		return true
	var f: = FileAccess.open(MARK, FileAccess.WRITE)
	if f != null:
		f.store_string("%s|%d|%s" % [Time.get_datetime_string_from_system(), OS.get_process_id(), driver])
		f.close()
	return false




static func safe() -> void :
	if not _on():
		return
	for path in [MARK, OLD_MARK, TRIED]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))




static func _move_on(dead: String) -> bool:
	var tried: Array = []
	if FileAccess.file_exists(TRIED):
		tried = Array(FileAccess.get_file_as_string(TRIED).split(",", false))
	if not tried.has(dead):
		tried.append(dead)
	var next: = str(CHAIN.get(dead, ""))
	var guard: = 0
	while next != "" and tried.has(next) and guard < CHAIN.size():
		next = str(CHAIN.get(next, ""))
		guard += 1



	var asked: = next if next != "" and not tried.has(next) else ""
	var f: = FileAccess.open(TRIED, FileAccess.WRITE)
	if f != null:
		f.store_string(",".join(tried + ([asked] if asked != "" else [])))
		f.close()
	if next == "" or tried.has(next):
		OS.alert(TranslationServer.translate("El juego se cerró al abrirse con todos los renderizadores (DirectX 12, Vulkan y OpenGL). Actualiza el controlador de tu tarjeta gráfica y vuelve a intentarlo, o escríbenos en Discord con tu tarjeta gráfica."), 
			"Midgard Survivors")

		DirAccess.remove_absolute(ProjectSettings.globalize_path(TRIED))
		return false
	var path: = OS.get_executable_path().get_base_dir().path_join("override.cfg")
	var cfg: = ConfigFile.new()
	cfg.load(path)
	if next.begins_with("opengl3"):
		cfg.set_value("rendering", "renderer/rendering_method", "gl_compatibility")
		cfg.set_value("rendering", "gl_compatibility/driver.windows", next)
	else:
		cfg.set_value("rendering", "renderer/rendering_method", "mobile")
		cfg.set_value("rendering", "rendering_device/driver.windows", next)
	if cfg.save(path) != OK:
		OS.alert(TranslationServer.translate("El juego se cerró al abrirse con %s. No pudimos cambiar de renderizador solos (¿carpeta protegida?): abre el juego con un acceso directo que termine en --rendering-driver vulkan o --rendering-driver opengl3.") % NAMES.get(dead, dead), 
			"Midgard Survivors")
		return false
	print("Renderer: the last start died on %s, now %s (override.cfg), starting again" % [dead, next])
	OS.alert(TranslationServer.translate("El juego se cerró al abrirse con %s. Ahora se abrirá con %s. Puedes cambiarlo cuando quieras en Opciones > Renderizador.") % [NAMES.get(dead, dead), NAMES.get(next, next)], 
		"Midgard Survivors")


	OS.create_process(OS.get_executable_path(), OS.get_cmdline_args())
	OS.kill(OS.get_process_id())
	return true
