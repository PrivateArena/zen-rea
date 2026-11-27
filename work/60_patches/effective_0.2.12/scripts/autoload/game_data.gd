extends Node




const PIXEL_SIZE: = 0.027


func _init() -> void :


	preload("res://scripts/core/boot_guard.gd").early()


const MVP_TIME: = 480.0













const TOWER_GATE: = {"map": "e_tower", "center": Vector2i(76, 100), "radius": 40.0, "hero_cell": Vector2i(76, 86), 
	"portal_cell": Vector2i(80, 80), 
	"npcs": [{"id": "tower", "sprite": "npc_lucile", "name": "Lucile", "title": "Endless Tower", "cell": Vector2i(76, 95), "nudge": Vector2(-0.5, 0.0), "dir": 0, 
		"color": Color(0.55, 0.45, 1.0), 
		"lines": ["¡Subamos juntos! Yo te cuido la espalda.", "Cada piso que superes, te espera un regalo."]}]}


const TOWER_PIN: = Vector2(1176, 440)
const TOWER_STAGE: = {"region": "tower", "tier": 10, "bgm": "Endless Tower", "name": "Endless Tower", "map": "1@tower", 
	"mvp_time": 1000000000.0, "spawns": [], "events": [], "mvp": "", "desc": "La torre sin fin"}
const TOWER_TIERS: = ["prontera", "culvert", "payon", "pyramid", "orc", "clock_tower", "glast", "niflheim", "thanatos", "biolab"]
const TOWER_TIER_FLOORS: = 10
const TOWER_FLOORS: = 100


const TOWER_GEAR_TOP: = 200
const TOWER_KILLS: = 30
const TOWER_KILLS_STEP: = 1.0




const TOWER_KILLS_TOP: = 120
const TOWER_HP_STEP: = 1.06









const TOWER_FLOOR_TIME: = 5.0




const TOWER_BOSS_FLOOR_TIME: = 15.0
const TOWER_DMG_STEP: = 1.035
const TOWER_SPEED_STEP: = 0.004
const TOWER_SPEED_MAX: = 0.5





const TOWER_CROWD: = 32
const TOWER_CROWD_MAX: = 80
const TOWER_SPAWN_EVERY: = 0.35
const TOWER_SPAWN_BATCH: = 4
const TOWER_OPENING: = 14
const TOWER_SPAWN_NEAR: = Vector2(10.0, 14.0)

const TOWER_REST: = 3.0




const TOWER_STAIRS_DIST: = 5.0
const TOWER_STAIRS_REACH: = 1.4


const TOWER_STAIRS_HOLD: = 1.5
const TOWER_WIND_TIME: = 20.0
const TOWER_UP_PAUSE: = 1.0

const TOWER_CAMP_REACH: = 2.2
const TOWER_REST_HEAL: = 0.3



const TOWER_BUILD_MIN_LEVEL: = 80



const TOWER_UNLOCK_DANGER: = DANGER_HELL_FROM



const TOWER_REWARDS: = {10: "power", 20: "legend", 30: "power", 40: "legend", 50: "power", 
	60: "legend", 70: "power", 80: "legend", 90: "power", 100: "legend"}
const TOWER_POWER: = 0.1




const TOWER_FLOOR_DMG: = 1.02










const HEL_TOWER_FROM: = 100



const HEL_TOWER_OPENS_AT: = 1795024800
const HEL_TOWER_PACE: = 5.0

const HEL_TOWER_STAGE: = "hel_tower"



const HEL_TOWER_RULE_EVERY: = 10
const HEL_TOWER_RULES: = {
	"shadows": {"name": "Sombras de los MVP", "desc": "En el piso 9 de cada tramo llega la sombra del MVP que te espera en el 10, con una de sus mecánicas", 
		"icon": "cloaking", "color": Color(0.72, 0.55, 1.0)}, 
	"elites": {"name": "Élites con Aguante", "desc": "Las élites tienen barra de Aguante, como los jefes: llénala con estados para aturdirlas", 
		"icon": "status_combo", "color": Color(1.0, 0.7, 0.3)}, 
	"profane": {"name": "Altares profanados", "desc": "Rezar en un altar despierta a su guardián, que te persigue hasta que lo vences", 
		"icon": "demon_bane", "color": Color(1.0, 0.4, 0.4)}, 
	"fog": {"name": "La niebla se cierra", "desc": "La luz de Yggdrasil se achica hacia la salida mientras cumples la cuota: fuera de ella pierdes vida", 
		"icon": "sanctuary", "color": Color(0.75, 0.55, 1.0)}, 
	"portals": {"name": "Portales de Niflheim", "desc": "Portales que sueltan monstruos: párate encima para cerrarlos, cada uno cuenta para la cuota", 
		"icon": "call_spirits", "color": Color(0.55, 0.9, 1.0)}, 
}


const HEL_FOG_FROM: = 24.0
const HEL_FOG_TO: = 7.0





const HEL_PORTALS: = 2
const HEL_PORTALS_MORE: = 50
const HEL_PORTAL_EVERY: = 2.5
const HEL_PORTAL_BATCH: = 2
const HEL_PORTAL_REACH: = 1.8
const HEL_PORTAL_CLOSE: = 3.0
const HEL_PORTAL_SHARE: = 0.15
const HEL_PORTAL_DIST: = Vector2(7.0, 13.0)


const HEL_TOWER_FEROZ: = 30.0

const HEL_TOWER_NO_OATHS: = ["hellfire"]




const HEL_TOWER_CRUMB: = 0.0013
const HEL_TOWER_CRUMB_STEP: = 2e-05


const HEL_TOWER_CRUMB_OATH: = 1.3e-05



const HEL_TOWER_REWARDS: = {
	10: {"crumbs": 5}, 20: {"coins": 3}, 30: {"crumbs": 10}, 40: {"tears": 1}, 50: {"cosmetic": 1}, 
	60: {"crumbs": 15}, 70: {"coins": 5}, 80: {"crumbs": 20}, 90: {"crumbs": 20}, 100: {"title": "hel_tower", "tears": 3}, 
}
const HEL_TOWER_COSMETIC_TEARS: = 2






const HEL_TOWER_REPEAT: = {
	10: {"crumbs": 3}, 20: {"coins": 2}, 30: {"crumbs": 6}, 40: {"tears_chance": 0.5}, 50: {"tears": 1}, 
	60: {"crumbs": 9}, 70: {"coins": 3}, 80: {"crumbs": 12}, 90: {"crumbs": 12}, 100: {"tears": 2}, 
}








const HEL_NAGHT: = {"soul_first": 8.0, "soul_every": [14.0, 12.0, 10.0, 8.0], "soul_count": [3, 3, 4, 5], 
	"soul_speed": 1.4, "soul_block": 1.3, "soul_heal": 0.03, "soul_dmg": 0.06, "soul_dmg_max": 10, 
	"judge_from": 1, "judge_first": 20.0, "judge_every": 32.0, "judge_time": 5.0, "judge_pct": 0.45, 



	"ward_max": 0.15, "ward_full": 0.05, "ward_window": 3.0}



const LOADING_TIPS: = [
	["Renacer da 1 hueco más de legendaria, y la Endless Tower otro en los pisos 20, 40, 60, 80 y 100.", ""], 
	["Cambia de mascota en Álbum > Mascotas.", ""], 
	["Tu build se guarda sola al terminar cada partida (las 10 últimas). Entrar a la Endless Tower la gasta.", ""], 
	["Crea una cuenta y entra con ella en tu otro PC o celular: tu progreso es el mismo en todos.", ""], 
	["Para no salir en los récords: Opciones > Juego > Datos > Récords del mes.", ""], 
	["C / V cambian el tipo de munición (o haz clic en el Carcaj).", "pc"], 
	["Toca el Carcaj para cambiar el tipo de munición.", "touch"], 
	["Cambia nombre y apariencia con el botón Perfil en la selección de personaje (cada 8 horas).", ""], 
	["En el inventario, marca las rarezas que no quieres: se venden solas al recogerlas.", ""], 
	["Lo que pongas en el Equipo inicial (Almacén Kafra) lo llevas cada partida y nunca se pierde.", ""], 
	["Los únicos y lo que encuentras en la Endless Tower van directo a tu Almacén Kafra: no se pierden al terminar la partida.", ""], 
	["¿Sin Engarzador ni Refinador? Lee los carteles de SE BUSCA en Prontera: dicen dónde rescatarlos.", ""], 
	["¿Pocos FPS? En Opciones > Gráficos baja la «Cantidad de efectos» o la opacidad de tus efectos (también en la pausa).", ""], 
	["¿Demasiados números en pantalla? Redúcelos o quítalos en Opciones > Juego > Combate > Números de daño.", ""], 
	["Invocaciones (Pickies, Tarous, plantas...): crecen con el nivel de su habilidad, la stat de esa habilidad y el «Daño de invocaciones». Los Homúnculos, con el ATK de tu arma y tu INT.", ""], 
	["Lo que lanzan cartas y equipo (procs) crece con tu Base Lv y tu FUE: en sus textos lo marca «×Lv».", ""], 
	["Las habilidades físicas suben con FUE y las mágicas con INT; algunas mezclan vida, AGI o SUE. Lo dice su descripción, en «Sube con».", ""], 
	["Estados: crecen con el golpe que los aplica. El veneno se acumula y crece con cada carga (ideal contra jefes y MVP), el fuego salta entre monstruos y el sangrado estalla a los 5 cortes.", ""], 
]


const TOWN_DOING: = {"refiner": "Refinando...", "star_smith": "Con Altair", "gacha": "Girando la máquina gacha", "socket": "Engarzando...", "kafra": "Con la Kafra", "sage": "Con el Sabio", 
	"pacts": "Pactando con Gray", "chef": "Cocinando con Klaws", "equipment": "Revisando su equipo", 
	"status": "Revisando su equipo", "loadout": "Eligiendo equipo", "coop": "Con Lydia", "class_select": "Eligiendo personaje", 
	"server_select": "Eligiendo mapa", "prep": "Preparándose", "album": "Mirando su álbum", "rebirth": "Renaciendo", "rebirth_lv": "Con la Valkyrie", 
	"char_make": "Repartiendo puntos", "pause": "En pausa", "teleporter": "Con nearQ", "inspect": "Mirando un equipo", 
	"valkyrie": "Con la Valkyrie", "hero_pick": "Con la Valkyrie", "hero_sheet": "Revisando su equipo"}


const TOWER_EVENT_AT: = 5
const TOWER_EVENT_FROM: = 5
const TOWER_TREASURE_TIME: = 30.0



const TOWER_TREASURE_DPS_SECS: = 2.5
const TOWER_TREASURE_HITS: = 2.0

const TOWER_EVENT_SIGN: = 2.0
const TOWER_AMBUSH_WAVES: = 3








const TOWER_TOUGH_TANK: = 10.0
const TOWER_AMBUSH_WAVE_TIME: = 14.0


const TOWER_AMBUSH_STUCK: = 30.0
const TOWER_SURVIVE_TIME: = 20.0
const TOWER_EVENTS: = {
	"treasure": {"name": "¡Piso del tesoro!", "hint": "Atrapa a los Poring Dorados antes de que acabe el tiempo", "color": Color(1.0, 0.82, 0.25)}, 
	"ambush": {"name": "¡Emboscada!", "hint": "El círculo se cierra: acaba con cada oleada", "color": Color(1.0, 0.35, 0.25)}, 
	"duel": {"name": "¡Duelo!", "hint": "Un MVP te reta aquí mismo, sin arena", "color": Color(1.0, 0.55, 0.3)}, 
	"survive": {"name": "¡Sobrevive!", "hint": "Encerrado 20 segundos: esquiva todo lo que te lancen", "color": Color(0.5, 0.8, 1.0)}, 
	"wheel": {"name": "¡La ruleta de Lucile!", "hint": "Tres giros: bendiciones, maldiciones... y algo enorme", "color": Color(0.95, 0.55, 1.0)}, 
	"emperium": {"name": "¡Prueba del Emperium!", "hint": "Destrúyelo a tiempo: renace más fuerte, y cada prueba mejora el premio", "color": Color(1.0, 0.86, 0.3)}, 
}




const TOWER_EMPERIUM_TIME: = 10.0
const TOWER_EMPERIUM_DPS: = 7.0
const TOWER_EMPERIUM_GROW: = 1.7
const TOWER_EMPERIUM_CHECKS: = 5
const TOWER_EMPERIUM_PRIZES: = [3, 4, 5, 7, 10]









const FESTIVAL_NUM_LIFT: = 1.8
const FESTIVAL_STAGE: = {"region": "festival", "tier": 1, "bgm": "Comodo", "name": "Emperium Festival", "map": "comodo", 
	"mvp_time": 1000000000.0, "spawns": [], "events": [], "mvp": "", "desc": "El festival del Emperium"}

const FESTIVAL_CELL: = Vector2i(190, 165)

const FESTIVAL_EMPERIUM_CELL: = Vector2i(189, 152)
const FESTIVAL_PREP: = 120.0
const FESTIVAL_COUNT: = 5
const FESTIVAL_TIME: = 60.0









const WB_TIME: = 180.0


const WB_BOARD_ROWS: = 100
const WB_SCALE: = 3.0




const WB_RADIUS: = 2.6
const WB_SPEED: = 1.6
const WB_EVERY: = 0.65
const WB_CAST_TIME: = 0.8
const WB_GROWTH: = 1.5
const WB_DMG_GROWTH: = 1.15
const WB_LAYERS: = 100
const WB_WEAK: = 1.5
const WB_FAVOR: = 2.0
const WB_UNFAVOR: = 0.5
const WB_SCORE_STEP: = 0.1
const WB_BASE_HP: = 5e+21
const WB_DANGER: = 25



const WB_SYNC: = 10.0
const WB_SYNC_FIRST: = 4.0




const WB_OPENS: = 1795392000




func wb_locked(state: Dictionary) -> bool:
	if has_meta("wb_fake"):
		return false
	var now: = int(state.get("now", 0))
	if now <= 0:
		now = int(Time.get_unix_time_from_system())
	return now < WB_OPENS




const WB_ARENA: = "prt_are01"
const WB_ARENA_RADIUS: = 22.0

const WB_ARENA_TITLE: = "Coliseo del Jefe del Mundo"



const WB_PORTAL_CELL: = Vector2i(173, 179)
const WB_PORTAL_NUDGE: = Vector3(-0.8, 0, -4.05)






const WB_CHESTS: = {
	"valhalla": {"coins": 2.0, "star_crumb": 15.0, "legend_coin": 3.0, "hd": 1.0, "zeny": 5000000.0}, 
	"gold": {"coins": 1.3, "star_crumb": 11.0, "legend_coin": 2.0, "hd": 0.6, "zeny": 3000000.0}, 
	"silver": {"coins": 0.7, "star_crumb": 6.0, "legend_coin": 1.2, "hd": 0.3, "zeny": 1200000.0}, 
	"bronze": {"coins": 0.35, "star_crumb": 3.0, "legend_coin": 0.6, "enriched": 3.0, "zeny": 600000.0}, 
	"wood": {"coins": 0.2, "star_crumb": 2.0, "enriched": 2.0, "zeny": 300000.0}, 
	"joined": {"coins": 0.15, "star_crumb": 1.0, "enriched": 1.5, "zeny": 150000.0}, 
}
const WB_CHEST_MULT: = [0.5, 1.0, 3.0, 6.0, 10.0, 15.0, 17.0, 18.5, 19.5, 20.0, 21.0]




const WB_CHEST_PAST: = 1.5



static func wb_chest_mult(kills: int) -> float:
	var top: = WB_CHEST_MULT.size() - 1
	if kills <= top:
		return float(WB_CHEST_MULT[maxi(0, kills)])
	return float(WB_CHEST_MULT[top]) + WB_CHEST_PAST * sqrt(float(kills - top))


const WB_CHEST_TEARS: = {"valhalla": [0, 3, 5, 8], "gold": [3, 5, 8], "silver": [5]}
const WB_CHEST_NAMES: = {"valhalla": "Cofre de Valhalla", "gold": "Cofre de oro", "silver": "Cofre de plata", 
	"bronze": "Cofre de bronce", "wood": "Cofre de madera", "joined": "Cofre de participación"}
const WB_CHEST_COLORS: = {"valhalla": Color(0.78, 0.5, 0.98), "gold": Color(0.95, 0.75, 0.3), "silver": Color(0.72, 0.78, 0.9), 
	"bronze": Color(0.92, 0.5, 0.25), "wood": Color(0.62, 0.62, 0.68), "joined": Color(0.4, 0.68, 0.95)}

const WB_CHEST_SPRITES: = {"valhalla": "chest_wb_valhalla", "gold": "chest_wb_gold", "silver": "chest_wb_silver", 
	"bronze": "chest_wb_bronze", "wood": "chest_wb_wood", "joined": "chest_wb_joined"}




static func wb_chest_items(tier: String, kills: int) -> Array:
	var base: Dictionary = WB_CHESTS.get(tier, {})
	var m: = wb_chest_mult(kills)
	var out: Array = []
	var add: = func(id: String, n: int):
		if n > 0:
			out.append([id, n])
	add.call("coins", roundi(float(base.get("coins", 0.0)) * m))
	add.call("star_crumb", roundi(float(base.get("star_crumb", 0.0)) * m))
	add.call("legend_coin", roundi(float(base.get("legend_coin", 0.0)) * m))
	var hd: = roundi(float(base.get("hd", 0.0)) * m)
	add.call("hd_oridecon", ceili(hd * 0.5))
	add.call("hd_elunium", hd / 2)
	var en: = roundi(float(base.get("enriched", 0.0)) * m)
	add.call("enriched_oridecon", ceili(en * 0.5))
	add.call("enriched_elunium", en / 2)
	var tears: = 0
	for at in WB_CHEST_TEARS.get(tier, []):
		if kills >= int(at):
			tears += 1
	add.call("hel_tear", tears)
	add.call("zeny", roundi(float(base.get("zeny", 0.0)) * m))
	return out







const FESTIVAL_DAILY_MAX_E: = 150
const FESTIVAL_DAILY_ZENY: = 50000
const FESTIVAL_DAILY_ORE: = 3
const FESTIVAL_DAILY_ENRICHED_PER: = 7
const FESTIVAL_DAILY_HD_PER: = 50
const FESTIVAL_BASE_HP: = 6000.0
const FESTIVAL_GROW: = 1.4

const FESTIVAL_SIZE: = 1.0
const FESTIVAL_SIZE_STEP: = 0.12
const FESTIVAL_SIZE_MAX: = 3.0


const TOWER_WHEEL_SPINS: = 4


const TOWER_WHEEL_TURN_WAIT: = 25.0
const TOWER_WHEEL: = [
	{"id": "fury", "icon": "bash", "kind": "buff", "w": 12.0, "short": "+20% daño", "name": "Furia de Lucile", "desc": "+20% de daño durante toda la subida", "color": Color(0.82, 0.2, 0.22), "mods": {"dmg": 0.2}}, 
	{"id": "curse_dull", "icon": "stone_curse", "kind": "curse", "w": 8.0, "floors": 3, "short": "-20% daño", "name": "Filo mellado", "desc": "-20% de daño durante 3 pisos", "color": Color(0.24, 0.1, 0.34), "mods": {"dmg": -0.2}}, 
	{"id": "iron", "icon": "auto_guard", "kind": "buff", "w": 12.0, "short": "+20% vida", "name": "Corazón de hierro", "desc": "+20% de vida máxima durante toda la subida", "color": Color(0.16, 0.6, 0.36), "mods": {"max_hp_pct": 0.2}}, 
	{"id": "curse_frail", "icon": "signum_crucis", "kind": "curse", "w": 8.0, "floors": 4, "short": "-20% vida", "name": "Carne frágil", "desc": "-20% de vida máxima durante 4 pisos", "color": Color(0.3, 0.09, 0.26), "mods": {"max_hp_pct": -0.2}}, 
	{"id": "swift", "icon": "adrenaline_rush", "kind": "buff", "w": 12.0, "short": "+15% ASPD", "name": "Pulso veloz", "desc": "+15% de velocidad de ataque durante toda la subida", "color": Color(0.92, 0.5, 0.1), "mods": {"aspd": 0.15}}, 
	{"id": "super", "icon": "magnificat", "kind": "super", "w": 3.0, "short": "SUPER", "name": "¡GRACIA DE LUCILE!", "desc": "+50% de daño, +40% de vida, +25% de velocidad de ataque y +15% de movimiento durante toda la subida", "color": Color(1.0, 0.78, 0.1), "mods": {"dmg": 0.5, "max_hp_pct": 0.4, "aspd": 0.25, "move": 0.15}}, 
	{"id": "curse_heavy", "icon": "quagmire", "kind": "curse", "w": 8.0, "floors": 4, "short": "-15% mov.", "name": "Pies de plomo", "desc": "-15% de velocidad de movimiento durante 4 pisos", "color": Color(0.17, 0.13, 0.36), "mods": {"move": -0.15}}, 
	{"id": "luck", "icon": "owls_eye", "kind": "buff", "w": 12.0, "short": "+10% crít.", "name": "Suerte de la torre", "desc": "+10% de crítico y +20% de daño crítico durante toda la subida", "color": Color(0.2, 0.42, 0.92), "mods": {"crit": 0.1, "crit_dmg": 0.2}}, 
	{"id": "curse_slow", "icon": "dissonance", "kind": "curse", "w": 8.0, "floors": 3, "short": "+25% rec.", "name": "Mente nublada", "desc": "Recargas de habilidades un 25% más largas durante 3 pisos", "color": Color(0.28, 0.1, 0.3), "mods": {"haste": -0.2}}, 
	{"id": "wind", "icon": "increase_agi", "kind": "buff", "w": 12.0, "short": "+10% mov.", "name": "Viento a favor", "desc": "+10% de velocidad de movimiento durante toda la subida", "color": Color(0.1, 0.66, 0.72), "mods": {"move": 0.1}}, 
]

const TOWER_DUEL_HP: = 0.4




const TOWER_TRAP_FROM: = 5
const TOWER_TRAP_EVERY: = 8.0
const TOWER_TRAP_EVERY_STEP: = 0.1
const TOWER_TRAP_EVERY_MIN: = 3.5
const TOWER_TRAP_PCT: = 0.05
const TOWER_TRAP_PCT_STEP: = 0.0015
const TOWER_TRAP_PCT_MAX: = 0.16






const TOWER_PAST_MECH: = 0.01
const TOWER_PAST_TRAP_EVERY_STEP: = 0.015
const TOWER_PAST_TRAP_EVERY_MIN: = 2.0
const TOWER_PAST_TRAP_PCT_STEP: = 0.0014
const TOWER_PAST_TRAP_PCT_MAX: = 0.3
const TOWER_PAST_DOUBLE: = 150
const TOWER_PAST_TRIPLE: = 250



func tower_past(f: int) -> int:
	return maxi(0, f - TOWER_FLOORS)



func tower_mech_mult(f: int) -> float:
	return 1.0 + TOWER_PAST_MECH * tower_past(f)


const TOWER_TRAPS: = [
	{"id": "bolts", "from": 5, "name": "¡Trampas de la torre!", "hint": "Rayos: sal del círculo azul antes de que caiga", "color": Color(0.55, 0.75, 1.0)}, 
	{"id": "beam", "from": 12, "name": "Vigas arcanas", "hint": "Sal de la franja antes de que se encienda", "color": Color(0.8, 0.45, 1.0)}, 
	{"id": "spikes", "from": 20, "name": "Púas en espiral", "hint": "Brotan desde tus pies hacia afuera: cruza la espiral", "color": Color(0.85, 0.6, 0.3)}, 
	{"id": "boulder", "from": 28, "name": "¡Rocas ardientes!", "hint": "Cruzan el piso por la franja marcada", "color": Color(1.0, 0.55, 0.25)}, 
]

const TOWER_CAMP_LINES: = [
	"¡Uf, un respiro! Siéntate un momento, que yo vigilo.", 
	"Diez pisos más... ¡vas mucho mejor de lo que pensaba!", 
	"Bebe algo, revisa tu equipo. Arriba no esperan.", 
	"Desde aquí ya se ve más cielo que suelo. ¿Seguimos?", 
]






const WEATHER_DAY: = 130.0
const WEATHER_DUSK: = 25.0
const WEATHER_NIGHT: = 70.0
const WEATHER_DAWN: = 20.0
const WEATHER_EVERY: = [70.0, 130.0]
const WEATHER_FADE: = 6.0
const WEATHER_FLASH: = [5.0, 11.0]
const WEATHER_BATS: = [9.0, 18.0]

const WEATHER_AREA: = Vector2(28.0, 22.0)
const WEATHER_NIGHT_TINT: = Color(0.5, 0.56, 0.82)
const WEATHER_DUSK_TINT: = Color(1.0, 0.8, 0.66)


const WEATHER_GLOW: = 0.85
const WEATHER_GLOW_R: = 240.0

const WEATHER_GREY: = {"rain": 0.45, "storm": 0.7, "clouds": 0.2, "fog": 0.35, "snow": 0.3}
const WEATHER: = {

	"festival": {"kinds": ["clear"], "always_night": true}, 
	"prontera": {"kinds": ["clear", "clear", "clouds", "rain", "leaves"]}, 
	"payon": {"kinds": ["clear", "leaves", "leaves", "fog", "rain"]}, 
	"orc": {"kinds": ["clear", "clear", "clouds", "rain", "storm"]}, 
	"glast": {"kinds": ["fog", "fog", "clouds", "storm", "rain"], "night_k": 1.3, "bats": true}, 
	"nameless": {"kinds": ["fog", "clouds", "rain", "storm"], "night_k": 1.15, "bats": true}, 
	"niflheim": {"kinds": ["fog", "snow", "clear"], "always_night": true, "grey_snow": true, "bats": true}, 
	"juperos": {"kinds": ["clear", "clouds", "storm", "storm"]}, 
}

const LUCILE_INTRO: = [
	"¡Hola, hola! Soy Lucile, la guía de la Endless Tower.", 
	"Nadie ha visto su cima... dicen que no tiene. Cada piso es más duro que el anterior.", 
	"Trae una build guardada de tus partidas y subimos juntos. Yo te cuido la espalda.", 
	"Y cada diez pisos te tengo un regalo. ¿Empezamos?", 
]


const HEL_LUCILE_ASK: = [
	"¿La Torre de Hel...? Espera. Eso no sube: baja, hasta Niflheim.", 
	"Allí abajo no hay puntos de control. Si caes, volvemos a empezar desde el piso 1.", 
	"Y cada diez pisos Hel cambia las reglas... ¿De verdad quieres bajar?", 
]
const HEL_LUCILE_LINES: = ["No te separes de mí. La niebla de abajo no perdona.", 
	"Hel guarda lo que cae en su reino... y a veces lo devuelve, si bajas lo bastante.", 
	"Huele a ceniza y a hielo. Ya estamos cerca de Niflheim.", 
	"Cuanto más bajamos, más brillan las Star Crumbs. Y más frío hace."]
const HEL_CAMP_LINES: = ["Respira un poco... Aquí abajo hasta el silencio pesa.", 
	"Mira esas llamas azules. Son almas que no encontraron el camino.", 
	"Todavía puedo oír la escalera crujir. Sigamos, despacio."]
const LUCILE_LINES: = ["¡Llegaste! Hoy siento que vamos a llegar más alto que nunca.", 
	"Dicen que Naght Sieger espera en el piso 100... ¿le damos una visita?", 
	"Yo me encargo de las trampas. Tú encárgate de todo lo demás, ¿sí?", 
	"Cada diez pisos te tengo un regalito. ¡No te los pierdas!", 
	"Si te caes, te levanto. Para eso estoy aquí."]



const TOWER_MAPS: = [[25, "1@tower"], [50, "2@tower"], [75, "3@tower"], [99, "4@tower"]]


const TOWER_LORD: = "naght_sieger"


const TOWER_MVP_HP_STEP: = 1.035
const TOWER_MVP_DMG_STEP: = 1.025


const TOWER_CYCLE_SPEED: = 0.1
const TOWER_CYCLE_CROWD: = 8





const TOWER_RULE_FLOORS: = [3, 7]
const TOWER_RULES: = {
	"horde": {"name": "Horda", "desc": "El doble de monstruos, con menos vida", "color": Color(1.0, 0.7, 0.35), 
		"crowd": 2.0, "hp": 0.55, "kills": 1.6}, 
	"fury": {"name": "Furia", "desc": "Monstruos más rápidos y más fuertes", "color": Color(1.0, 0.35, 0.3), 
		"speed": 1.3, "dmg": 1.3}, 
	"gold": {"name": "Fiebre de oro", "desc": "Triple de zeny y doble de EXP en este piso", "color": Color(1.0, 0.85, 0.3), 
		"loot": 2.0, "xp": 1.0}, 
	"elites": {"name": "Élites", "desc": "Cuatro élites te esperan", "color": Color(0.85, 0.5, 1.0), 
		"elites": 4, "kills": 0.7}, 
	"giants": {"name": "Gigantes", "desc": "Pocos monstruos, enormes y duros", "color": Color(0.6, 0.9, 0.6), 
		"crowd": 0.45, "hp": 3.2, "dmg": 1.4, "kills": 0.45, "scale": 1.6}, 
}


const TOWER_BLESS_FLOOR: = 5
const TOWER_BLESSINGS: = {
	"might": {"name": "Filo de Lucile", "desc": "+10% de daño", "icon": "bash", "mods": {"dmg": 0.1}}, 
	"vigor": {"name": "Vigor", "desc": "+12% de vida máxima", "icon": "hp_recovery", "mods": {"max_hp_pct": 0.12}}, 
	"haste": {"name": "Prisa", "desc": "+8% de velocidad de ataque", "icon": "adrenaline_rush", "mods": {"aspd": 0.08}}, 
	"wind": {"name": "Viento", "desc": "+6% de velocidad de movimiento", "icon": "increase_agi", "mods": {"move": 0.06}}, 
	"eye": {"name": "Ojo de halcón", "desc": "+5% de crítico y +10% de daño crítico", "icon": "owls_eye", "mods": {"crit": 0.05, "crit_dmg": 0.1}}, 
	"echo": {"name": "Eco", "desc": "-6% de recarga de habilidades", "icon": "improve_concentration", "mods": {"haste": 0.06}}, 
	"guard": {"name": "Guardia", "desc": "+2 de defensa y +1 vida/s", "icon": "auto_guard", "mods": {"armor": 2.0, "regen": 1.0}}, 
	"area": {"name": "Expansión", "desc": "+10% de área", "icon": "magnum_break", "mods": {"area": 0.1}}, 
}





const TOWER_FACE_CHANCE: = 0.12
const TOWER_FACE_STEP: = 0.003

const TOWER_FACE_LEGEND: = 0.025
const TOWER_FACE_LEGEND_STEP: = 0.0025
const TOWER_FACE_LEGEND_MAX: = 0.22

const TOWER_FACE_LEGEND_FROM: = 21


const TOWER_LIVES_MULT: = 2


const FACE_SLOTS: = ["mid", "low"]




const LOADOUT_FREE_SLOTS: = ["mid", "low", "wings", "soul"]

const CLASSES: = {
	"swordsman": {
		"name": "Swordsman", 
		"desc": "Cuerpo a cuerpo y supervivencia. Mucha vida, golpes en arco.", 
		"body": "swordsman", "head": "head_m", 
		"color": Color(0.85, 0.35, 0.3), 
		"hp": 170.0, "speed": 4.4, "armor": 2.0, 
		"start": "bash", 


		"basic": {"aspd": 146.0, "atk": 15.0, "range": 2.2, "ranged": false, "sound": "sword_hit"}, 


		"weapon": "weapon_sword", "weapon_fx": "weapon_sword_slash", "attack": 10, 
		"stats": {"str": 2, "vit": 2}, 


		"skills": ["bash", "magnum_break", "endure", "first_aid", "provoke"], 
		"passives": ["sword_mastery", "shield_mastery"], 
		"job2": {"id": "knight", "name": "Knight", "body": "knight", 
			"weapon": "weapon_knight_sword", "weapon_fx": "weapon_knight_slash", "attack": 10, 
			"start": "charge_attack", "skills": ["charge_attack", "spear_boomerang", "bowling_bash"], "passives": ["peco_riding", "cavalier_mastery", "auto_counter"], 
			"hp_bonus": 0.3, "dmg_bonus": 0.1, 
			"desc": "Caballero de Prontera: jinete del Peco Peco que pega en movimiento, carga contra el enemigo, lanza su lanza y barre a la horda con Bowling Bash.", 
			"trans": {"id": "lord_knight", "name": "Lord Knight", "body": "lord_knight", 
				"start": "spiral_pierce", "skills": ["charge_attack", "spear_boomerang", "spiral_pierce", "bowling_bash", "ignition_break"], "passives": ["peco_riding", "cavalier_mastery", "auto_counter", "aura_blade", "parrying"], 



				"hp_bonus": 0.5, "dmg_bonus": 0.25, "dmg_more": 2.1, 
				"desc": "Lord Knight: su lanza taladra a los jefes con Spiral Pierce y su espada brilla con Aura Blade."}}, 

		"job2_alt": {"id": "crusader", "name": "Crusader", "body": "crusader", 
			"weapon": "weapon_crusader_sword", "weapon_fx": "weapon_crusader_slash", "attack": 10, 
			"start": "grand_cross", "skills": ["grand_cross", "holy_cross"], "passives": ["faith", "auto_guard", "peco_riding", "reflect_shield", "demon_bane"], 
			"hp_bonus": 0.45, "dmg_bonus": 0.06, 
			"desc": "Cruzado: fe y escudo. Grand Cross castiga con luz sagrada a su alrededor.", 
			"trans": {"id": "paladin", "name": "Paladin", "body": "paladin", 


				"start": "gospel", "skills": ["grand_cross", "holy_cross", "gospel", "martyrs_reckoning", "shield_chain"], "passives": ["faith", "auto_guard", "peco_riding", "reflect_shield", "demon_bane"], 


				"hp_bonus": 0.65, "dmg_bonus": 0.2, "dmg_more": 1.2, 
				"desc": "Paladin: canta el Gospel en medio de la horda y convierte su vida en daño con Martyr's Reckoning."}}, 
	}, 
	"mage": {
		"name": "Mage", 
		"desc": "Proyectiles mágicos y daño en área. Frágil pero devastador.", 
		"body": "mage", "head": "head_m", 
		"color": Color(0.45, 0.4, 0.9), 
		"hp": 100.0, "speed": 4.2, "armor": 0.0, 
		"start": "fire_bolt", 
		"basic": {"aspd": 136.0, "atk": 11.0, "range": 2.0, "ranged": false, "sound": "rod_attack"}, 
		"weapon": "weapon_rod", "attack": 10, "cast": 12, 
		"stats": {"int": 2, "dex": 1}, 




		"skills": ["fire_bolt", "cold_bolt", "soul_strike", "fire_wall", "thunder_storm", "energy_coat", "stone_curse", "first_aid"], 
		"passives": ["sp_recovery", "spell_breaker"], 
		"job2": {"id": "wizard", "name": "Wizard", "body": "wizard", 
			"weapon": "weapon_wizard_rod", "attack": 10, "cast": 12, 
			"start": "storm_gust", "skills": ["storm_gust", "lord_of_vermilion", "jupitel_thunder", "quagmire"], "passives": ["soul_drain", "mystical_amplification", "recognized_spell"], 
			"hp_bonus": 0.2, "dmg_bonus": 0.15, 
			"desc": "Mago de Geffen: sus hechizos de fuego, agua, viento y tierra marcan a los monstruos y otro elemento los detona en reacciones en cadena.", 
			"trans": {"id": "high_wizard", "name": "High Wizard", "body": "high_wizard", 
				"start": "meteor_storm", "skills": ["storm_gust", "lord_of_vermilion", "jupitel_thunder", "quagmire", "meteor_storm", "gravitation_field"], "passives": ["soul_drain", "mystical_amplification", "recognized_spell"], 

				"hp_bonus": 0.35, "dmg_bonus": 0.3, "dmg_more": 1.3, 
				"desc": "High Wizard: Meteor Storm y Gravitation Field, que arrastra a la horda a un punto para detonarla."}}, 
		"job2_alt": {"id": "sage", "name": "Sage", "body": "sage", 
			"weapon": "weapon_sage_rod", "attack": 11, "cast": 12, 
			"start": "heavens_drive", "skills": ["heavens_drive", "earth_spike", "volcano"], "passives": ["advanced_book", "double_casting", "hindsight"], 
			"hp_bonus": 0.25, "dmg_bonus": 0.8, 
			"desc": "Sabio de Juno: la tierra misma se alza contra la horda.", 
			"trans": {"id": "professor", "name": "Professor", "body": "professor", 
				"start": "spider_web", "skills": ["heavens_drive", "earth_spike", "volcano", "spider_web"], "passives": ["advanced_book", "double_casting", "hindsight", "dragonology"], 



				"extra_passives": 1, 



				"hp_bonus": 0.4, "dmg_bonus": 1.4, "dmg_more": 2.3, 
				"desc": "Professor: telarañas que atrapan a la horda y la dejan a merced del fuego."}}, 
	}, 
	"archer": {
		"name": "Archer", 
		"desc": "Ataques a distancia rápidos. Gran velocidad de ataque.", 
		"body": "archer", "head": "head_m", 
		"color": Color(0.35, 0.75, 0.35), 
		"hp": 135.0, "speed": 4.8, "armor": 1.0, 
		"start": "double_strafe", 
		"basic": {"aspd": 140.0, "atk": 21.0, "range": 9.0, "ranged": true, "sound": "bow", "hit_sound": "arrow_hit"}, 
		"weapon": "weapon_bow", "attack": 10, "ammo": "arrows", 
		"stats": {"str": 1, "dex": 1, "agi": 1}, 
		"skills": ["double_strafe", "arrow_shower", "charge_arrow", "improve_concentration", "first_aid"], 


		"passives": ["owls_eye", "vultures_eye"], 
		"job2": {"id": "hunter", "name": "Hunter", "body": "hunter", "falcon": true, 
			"weapon": "weapon_hunter_bow", "attack": 11, 
			"start": "falcon_assault", "skills": ["falcon_assault", "land_mine", "sandman", "ankle_snare"], "passives": ["blitz_beat", "beast_bane", "steel_crow"], 
			"hp_bonus": 0.25, "dmg_bonus": 0.12, 
			"desc": "Cazador de Payon: su halcón y sus trampas no fallan.", 
			"trans": {"id": "sniper", "name": "Sniper", "body": "sniper", 
				"start": "sharp_shooting", "skills": ["falcon_assault", "land_mine", "sandman", "ankle_snare", "sharp_shooting"], "passives": ["blitz_beat", "beast_bane", "steel_crow"], 



				"hp_bonus": 0.4, "dmg_bonus": 0.28, "dmg_more": 1.3, 
				"desc": "Sniper: un disparo certero que no se detiene."}}, 




		"job2_alt": {"id": "bard", "name": "Bard", "name_f": "Dancer", "body": "bard", 
			"weapon": "weapon_bard_bow", "attack": 11, 
			"start": "musical_strike", "skills": ["musical_strike", "dissonance", "poem_of_bragi", "assassin_cross_sunset"], "passives": ["music_lessons"], 
			"skills_dance": ["musical_strike", "dissonance", "service_for_you", "scream"], 
			"hp_bonus": 0.25, "dmg_bonus": 0.12, 
			"desc": "Bardo / Bailarina: canciones o danzas a compás, el Bis cada cuatro tiempos y conjuntos en grupo.", 
			"trans": {"id": "clown", "name": "Clown", "name_f": "Gypsy", "body": "clown", 
				"start": "arrow_vulcan", "skills": ["musical_strike", "dissonance", "poem_of_bragi", "arrow_vulcan", "assassin_cross_sunset"], "passives": ["music_lessons"], 
				"skills_dance": ["musical_strike", "dissonance", "service_for_you", "arrow_vulcan", "scream"], 

				"hp_bonus": 0.4, "dmg_bonus": 0.28, "dmg_more": 1.15, 
				"desc": "Clown / Gypsy: Arrow Vulcan, nueve flechas en un suspiro, y el Bis más fuerte."}}, 
	}, 
	"gunslinger": {
		"name": "Gunslinger", 
		"desc": "Pistolero: disparos rápidos y balas de todos los elementos. Sus habilidades de arma marcan a los monstruos con una mira roja y cada una que lanza hace estallar a los marcados (Dragon Tail).", 


		"no_rebirth": true, "unlock_cost": 20000, 
		"body": "gunslinger", "head": "head_m", 
		"color": Color(0.75, 0.6, 0.4), 
		"hp": 135.0, "speed": 4.7, "armor": 1.5, 
		"start": "tracking", 
		"basic": {"aspd": 152.0, "atk": 24.0, "range": 9.0, "ranged": true, "bullet": true, "sound": "gunfire"}, 
		"weapon": "weapon_revolver", "weapon_fx": "weapon_revolver_fx", "attack": 10, "ammo": "bullets", 
		"stats": {"str": 1, "dex": 1, "agi": 1}, 

		"skills": ["tracking", "desperado", "spread_attack", "gatling_fever", "first_aid"], 
		"passives": ["adjustment", "single_action", "snake_eye", "chain_action", "coin_flip"], 
		"job2": {"id": "rebellion", "name": "Rebellion", "body": "rebellion", 
			"weapon": "weapon_rebellion_revolver", "weapon_fx": "weapon_rebellion_revolver_fx", "attack": 10, 
			"start": "fire_rain", "skills": ["fire_rain", "banishing_buster", "hammer_of_god", "heat_barrel"], 











			"hp_bonus": 0.45, "dmg_bonus": 0.3, "dmg_more": 1.15, "extra_passives": 1, 
			"desc": "Rebellion: lluvia de fuego, balas que rebotan entre los monstruos y Hammer of God."}, 
	}, 
	"ninja": {
		"name": "Ninja", 
		"desc": "Ninja: shuriken, kunai de cada elemento y ninjutsu de fuego. Sus sombras reciben los golpes en su lugar.", 


		"no_rebirth": true, "unlock_cost": 30000, 
		"body": "ninja", "head": "head_m", 
		"color": Color(0.45, 0.35, 0.65), 
		"hp": 160.0, "speed": 4.9, "armor": 1.5, "dodge": 0.1, 
		"start": "throw_shuriken", 
		"basic": {"aspd": 152.0, "atk": 14.0, "range": 2.0, "ranged": false, "sound": "dagger_hit"}, 
		"weapon": "weapon_ninja_dagger", "weapon_fx": "weapon_ninja_slash", "attack": 10, "ammo": "kunai", 
		"stats": {"agi": 2, "dex": 1, "int": 1}, 







		"skills": ["throw_shuriken", "throw_huuma", "flaming_petals", "mirror_image", "ninja_aura", "first_aid"], 
		"passives": ["shuriken_training", "ninja_mastery", "cicada_skin_shed"], 
		"job2": {"id": "kagerou", "name": "Kagerou", "name_f": "Oboro", "body": "kagerou", 
			"weapon": "weapon_kagerou_dagger", "weapon_fx": "weapon_kagerou_slash", "attack": 10, 







			"start": "kunai_explosion", "skills": ["kunai_explosion", "kunai_splash", "cross_slash", "killing_strike", "exploding_dragon", "huuma_storm"], 

			"skills_f": ["kunai_explosion", "moonlight_fantasy", "cross_slash", "killing_strike", "exploding_dragon", "huuma_storm"], 

			"passives": ["meikyou_shisui", "right_hand_mastery", "left_hand_mastery"], 


			"hp_bonus": 0.45, "dmg_bonus": 0.3, "dmg_more": 1.2, "extra_passives": 1, 
			"desc": "Kagerou / Oboro: kunai que detonan, dagas que hacen sangrar, un tajo que crece con tu vida y fuego ninja."}, 
	}, 
	"taekwon": {
		"name": "Taekwon Kid", "name_f": "Taekwon Girl", 
		"desc": "Taekwon: patadas sin armas. Cada golpe puede ponerlo en una postura y la siguiente patada sale sola: tornados, talones al suelo y patadas giratorias.", 


		"no_rebirth": true, "unlock_cost": 30000, 
		"body": "taekwon", "head": "head_m", 
		"color": Color(0.95, 0.55, 0.35), 




		"hp": 175.0, "speed": 4.8, "armor": 2.0, "dodge": 0.06, 
		"start": "tornado_kick", 

		"basic": {"aspd": 154.0, "atk": 15.0, "range": 1.9, "ranged": false, "sound": "hit_fist"}, 
		"weapon": "", "attack": 11, "attack_poses": [11, 5, 10], "start_weapon": "fists", 
		"stats": {"agi": 2, "str": 1}, 
		"skills": ["tornado_kick", "heel_drop", "flying_kick", "mild_wind", "first_aid"], 
		"passives": ["sprint", "peaceful_break", "kihop"], 
		"job2": {"id": "star_gladiator", "name": "Star Gladiator", "body": "star_gladiator", "weapon_item": "star_fists", 
			"weapon": "", "attack": 11, "attack_poses": [11, 5, 10], "cast": 12, 
			"start": "warmth_sun", "skills": ["warmth_sun", "warmth_stars", "union"], 
			"passives": ["hatred_stars", "comfort_stars"], 



			"hp_bonus": 0.8, "dmg_bonus": 0.3, "dmg_more": 1.4, "extra_passives": 1, 
			"desc": "Star Gladiator: el calor del sol quema a la horda a su alrededor, las estrellas caen sobre ella y con la Unión del Sol, la Luna y las Estrellas vuela pateando sin parar."}, 
		"job2_alt": {"id": "soul_linker", "name": "Soul Linker", "body": "soul_linker", "weapon_item": "book_billows", 
			"weapon": "", "attack": 11, "attack_poses": [11, 5, 10], "cast": 12, 
			"start": "esma", "skills": ["estin", "esma", "eswoo", "kaite", "soul_link"], 
			"passives": ["kaahi"], 

			"hp_bonus": 0.35, "dmg_bonus": 0.3, "dmg_more": 1.4, "extra_passives": 1, 
			"desc": "Soul Linker: espíritus que golpean con el elemento de su Mild Wind y avivan su racha, Eswoo que ata el alma de los monstruos para todo el grupo, la barrera de Kaite y el Vínculo de Almas, que le presta (a él y a su grupo) el espíritu de otra clase."}, 
	}, 
	"doram": {
		"name": "Summoner", 
		"desc": "Doram: un gato que pelea con sus animales y los poderes de la naturaleza. Vida: Pickies, Tarous, Arclouses y Lunatics que pelean por él; Tierra: lanzas y meteoros de hierba gatera; Mar: atún y gambas que curan, protegen y potencian.", 


		"no_rebirth": true, "unlock_cost": 30000, 
		"body": "summoner", "head": "head_doram_m", 
		"color": Color(0.85, 0.75, 0.5), 
		"hp": 150.0, "speed": 4.8, "armor": 1.0, "dodge": 0.05, 
		"start": "picky_peck", 

		"basic": {"aspd": 152.0, "atk": 13.0, "range": 2.1, "ranged": false, "sound": "su_scratch"}, 
		"weapon": "weapon_summoner_foxtail", "attack": 10, "cast": 12, "start_weapon": "rod", 
		"stats": {"int": 2, "dex": 1}, 


		"skills": ["picky_peck", "scar_of_tarou", "silvervine_stem_spear", "catnip_meteor", "tuna_belly"], 
		"passives": ["power_of_life", "power_of_land", "power_of_sea"], 
		"job2": {"id": "spirit_handler", "name": "Spirit Handler", "body": "spirit_handler", 
			"weapon": "weapon_spirit_handler_foxtail", "attack": 10, "cast": 12, 
			"start": "arclouse_dash", "skills": ["arclouse_dash", "lunatic_carrot_beat", "silvervine_root_twist", "tuna_party", "bunch_of_shrimp"], 
			"passives": ["spirit_of_life", "spirit_of_land", "spirit_of_sea"], 




			"hp_bonus": 0.4, "dmg_bonus": 0.3, "dmg_more": 1.5, "extra_passives": 1, 
			"desc": "Spirit Handler: los espíritus de la Vida, la Tierra y el Mar. Arclouses que embisten, Lunatics que lanzan zanahorias, raíces que atrapan y un banquete de atún y gambas para todo el grupo."}, 
	}, 
	"thief": {
		"name": "Thief", 
		"desc": "Rápido y letal: ataques veloces, veneno y evasión.", 
		"body": "thief", "head": "head_m", 
		"color": Color(0.6, 0.45, 0.75), 

		"hp": 185.0, "speed": 4.9, "armor": 2.0, "dodge": 0.18, 
		"start": "envenom", 
		"basic": {"aspd": 152.0, "atk": 12.0, "range": 2.0, "ranged": false, "sound": "dagger_hit"}, 
		"weapon": "weapon_dagger", "weapon_fx": "weapon_dagger_slash", "attack": 10, 
		"stats": {"str": 1, "agi": 2, "vit": 1}, 
		"skills": ["envenom", "throw_stone", "steal", "first_aid"], 
		"passives": ["double_attack", "improve_dodge"], 
		"job2": {"id": "assassin", "name": "Assassin", "body": "assassin", "weapon_item": "katar", 


			"weapon": "weapon_katar", "weapon_fx": "weapon_katar_slash", "attack": 11, 
			"start": "sonic_blow", "skills": ["sonic_blow", "venom_dust", "cloaking"], 
			"passives": ["katar_mastery", "enchant_poison", "right_hand_mastery", "left_hand_mastery"], 
			"hp_bonus": 0.25, "dmg_bonus": 0.15, 
			"desc": "Asesino de Morroc: katares gemelos y veneno mortal.", 
			"trans": {"id": "assassin_cross", "name": "Assassin Cross", "body": "assassin_cross", 
				"start": "edp", "skills": ["sonic_blow", "venom_dust", "cloaking", "edp", "meteor_assault", "soul_breaker"], 
				"passives": ["katar_mastery", "enchant_poison", "right_hand_mastery", "left_hand_mastery"], 


				"hp_bonus": 0.4, "dmg_bonus": 0.3, "dmg_more": 1.4, 
				"desc": "Assassin Cross: Enchant Deadly Poison vuelve letal cada golpe."}}, 
		"job2_alt": {"id": "rogue", "name": "Rogue", "body": "rogue", 
			"weapon": "weapon_rogue_dagger", "weapon_fx": "weapon_rogue_slash", "attack": 10, 


			"start": "back_stab", "skills": ["back_stab", "raid", "double_strafe"], "passives": ["snatcher", "intimidate", "gangster_paradise", "vultures_eye"], 
			"hp_bonus": 0.28, "dmg_bonus": 0.13, 
			"desc": "Pícaro: puñaladas por la espalda, emboscadas y desarmes.", 
			"trans": {"id": "stalker", "name": "Stalker", "body": "stalker", 
				"start": "reject_sword", "skills": ["back_stab", "raid", "reject_sword", "full_strip", "double_strafe"], "passives": ["snatcher", "intimidate", "gangster_paradise", "preserve", "vultures_eye"], 


				"hp_bonus": 0.45, "dmg_bonus": 0.28, "dmg_more": 1.4, 
				"desc": "Stalker: Reject Sword desvía los golpes enemigos."}}, 
	}, 
	"acolyte": {
		"name": "Acolyte", 
		"desc": "Apoyo sagrado: se cura, se bendice y castiga con luz.", 
		"body": "acolyte", "head": "head_m", 
		"color": Color(0.95, 0.85, 0.5), 

		"hp": 140.0, "speed": 4.3, "armor": 2.0, "regen": 0.9, 
		"start": "holy_light", 
		"basic": {"aspd": 140.0, "atk": 12.0, "range": 2.1, "ranged": false, "sound": "mace_hit"}, 
		"weapon": "weapon_mace", "weapon_fx": "weapon_mace_slash", "attack": 10, "cast": 12, 
		"stats": {"int": 2, "vit": 1}, 
		"skills": ["holy_light", "heal", "blessing", "increase_agi", "signum_crucis", "ruwach"], 



		"passives": ["divine_judgment"], 
		"job2": {"id": "priest", "name": "Priest", "body": "priest", 
			"weapon": "weapon_priest_mace", "attack": 10, "cast": 12, 
			"start": "magnus_exorcismus", "skills": ["magnus_exorcismus", "sanctuary", "magnificat", "lex_aeterna"], "passives": ["mace_mastery", "aspersio"], 
			"hp_bonus": 0.3, "dmg_bonus": 0.12, 
			"desc": "Sacerdote de Prontera: Magnus Exorcismus purifica hordas.", 
			"trans": {"id": "high_priest", "name": "High Priest", "body": "high_priest", 
				"start": "assumptio", "skills": ["magnus_exorcismus", "sanctuary", "magnificat", "assumptio", "lex_aeterna"], "passives": ["mace_mastery", "aspersio"], 
				"hp_bonus": 0.5, "dmg_bonus": 0.25, 
				"desc": "High Priest: Assumptio lo protege de casi todo."}}, 
		"job2_alt": {"id": "monk", "name": "Monk", "body": "monk", 
			"weapon": "weapon_monk_knuckle", "weapon_fx": "weapon_monk_slash", "attack": 10, 
			"start": "triple_attack", "skills": ["asura_strike", "critical_explosion", "investigate", "steel_body"], 


			"passives": ["call_spirits", "triple_attack", "iron_hand", "chain_combo", "combo_finish"], 
			"hp_bonus": 0.3, "dmg_bonus": 0.15, 
			"desc": "Monje de San Darmon: puños de ki y el temido Asura Strike.", 
			"trans": {"id": "champion", "name": "Champion", "body": "champion", 
				"start": "triple_attack", "skills": ["asura_strike", "critical_explosion", "investigate", "chain_crush", "steel_body"], 
				"passives": ["call_spirits", "triple_attack", "iron_hand", "chain_combo", "combo_finish"], 
				"hp_bonus": 0.45, "dmg_bonus": 0.3, "dmg_more": 1.3, 
				"desc": "Champion: Chain Crush Combo, una ráfaga de puños sin fin."}}, 
	}, 
	"merchant": {
		"name": "Merchant", 
		"desc": "Comerciante de Alberta: hacha, carro y zeny. Mammonite convierte el dinero en golpes, y pega más cuanto más zeny tienes guardado.", 
		"body": "merchant", "head": "head_m", 
		"color": Color(0.8, 0.6, 0.3), 

		"hp": 215.0, "speed": 4.5, "armor": 3.5, "cart": true, 
		"start": "mammonite", 
		"basic": {"aspd": 144.0, "atk": 17.0, "range": 2.5, "ranged": false, "sound": "axe_hit"}, 
		"weapon": "weapon_axe", "weapon_fx": "weapon_axe_slash", "attack": 10, 
		"stats": {"str": 2, "vit": 1, "dex": 1}, 
		"skills": ["mammonite", "cart_revolution", "loud_exclamation", "first_aid"], 


		"passives": ["discount", "pushcart"], 


		"job2": {"id": "blacksmith", "name": "Blacksmith", "body": "blacksmith", 
			"weapon": "weapon_blacksmith_axe", "weapon_fx": "weapon_blacksmith_slash", "attack": 11, 
			"start": "axe_tornado", "skills": ["axe_tornado", "cart_cannon", "hammer_fall", "adrenaline_rush", "over_thrust"], 
			"passives": ["weaponry_research", "skin_tempering", "weapon_perfection"], 
			"hp_bonus": 0.3, "dmg_bonus": 0.14, 
			"desc": "Herrero de Einbroch: cada golpe calienta su arma y la forja más allá de lo seguro, hasta que estalla y la templa en el elemento que más daña. Quiebre de forja: los jefes que rompe con Hammer Fall quedan aturdidos más tiempo y reciben x5 de sus golpes.", 
			"trans": {"id": "whitesmith", "name": "Whitesmith", "body": "whitesmith", 
				"start": "cart_cannon", "skills": ["axe_tornado", "cart_cannon", "hammer_fall", "adrenaline_rush", "over_thrust", "cart_termination", "meltdown"], 
				"passives": ["weaponry_research", "skin_tempering", "weapon_perfection", "oridecon_research"], 





				"hp_bonus": 0.45, "dmg_bonus": 0.28, "dmg_more": 1.5, 
				"desc": "Whitesmith: maestro refinador, forja hasta +20 y su arma se rompe menos; Meltdown funde la armadura. Quiebre de forja: los jefes que rompe con Hammer Fall quedan aturdidos más tiempo y reciben x5 de sus golpes."}}, 
		"job2_alt": {"id": "alchemist", "name": "Alchemist", "body": "alchemist", 
			"weapon": "weapon_alchemist_axe", "weapon_fx": "weapon_alchemist_slash", "attack": 11, 
			"start": "demonstration", "skills": ["acid_terror", "demonstration", "bio_cannibalize", "potion_pitcher", "chemical_protection"], 
			"passives": ["axe_mastery", "learning_potion", "call_homunculus", "bioethics"], 
			"hp_bonus": 0.25, "dmg_bonus": 0.12, 
			"desc": "Alquimista de Al De Baran: ácido y fuego en el suelo, pociones para el grupo y Homúnculos que pelean por él.", 
			"trans": {"id": "creator", "name": "Creator", "body": "creator", 
				"start": "acid_demonstration", "skills": ["acid_terror", "demonstration", "bio_cannibalize", "potion_pitcher", "chemical_protection", "acid_demonstration"], 
				"passives": ["axe_mastery", "learning_potion", "call_homunculus", "bioethics"], 

				"hp_bonus": 0.4, "dmg_bonus": 0.27, "dmg_more": 1.4, 
				"desc": "Creator: Acid Demonstration (ácido y fuego a la vez) y dos Homúnculos a su lado."}}, 
	}, 
	"super_novice": {
		"name": "Super Novice", 
		"desc": "El aprendiz que no eligió: arma su propio set con las habilidades de todas las clases base, sin segundo oficio.", 




		"custom": true, "no_rebirth": true, "unlock_cost": 25000, 
		"body": "super_novice", "head": "head_m", 
		"color": Color(0.95, 0.75, 0.35), 
		"hp": 150.0, "speed": 4.6, "armor": 2.0, 
		"start": "", 
		"basic": {"aspd": 150.0, "atk": 14.0, "range": 2.1, "ranged": false, "sound": "dagger_hit"}, 
		"weapon": "weapon_sn_dagger", "weapon_fx": "weapon_sn_dagger_slash", "attack": 10, "cast": 12, 
		"start_weapon": "knife", 
		"stats": {"str": 1, "agi": 1, "dex": 1, "int": 1}, 
		"skills": [], "passives": [], 
		"max_skills": 6, "max_passives": 6, 


		"looks": [{"id": "hyper_novice", "name": "Hyper Novice", "body": "hyper_novice", "weapon": "weapon_hn_dagger", 
			"weapon_fx": "weapon_hn_dagger_slash", "attack": 10, "level": 20}], 
	}, 
}





const FIRST_AID_SHIELD_MAX: = 0.35







const BOW_JOBS: = ["rogue", "stalker"]

const BOW_JOB_SKILLS: = ["double_strafe", "double_strafe_x"]
const BOW_ROGUE_BASIC: = {"aspd": 142.0, "atk": 18.0, "range": 9.0, "ranged": true, "sound": "bow", "hit_sound": "arrow_hit"}




const TOWN_MUSIC: = [["prontera", "Prontera"], ["prontera_xmas", "Prontera (Navidad)"], ["geffen", "Geffen"], ["payon", "Payon"], 
	["morocc", "Morroc"], ["alberta", "Alberta"], ["izlude", "Izlude"], ["aldebaran", "Al De Baran"], ["yuno", "Juno"], 
	["comodo", "Comodo"], ["niflheim", "Niflheim"], ["louyang", "Louyang"], ["amatsu", "Amatsu"], ["einbroch", "Einbroch"], 
	["hugel", "Hugel"], ["rachel", "Rachel"], ["brasilis", "Brasilis"]]
const SN_CLASSES: = ["swordsman", "mage", "archer", "thief", "acolyte", "merchant", "gunslinger", "ninja", "taekwon"]
const SN_MECHANICS: = {"archer": {"ammo": "arrows"}, "gunslinger": {"ammo": "bullets"}, "ninja": {"ammo": "kunai"}, 
	"merchant": {"cart": true}}



const SN_CART_SKILLS: = ["cart_revolution", "pushcart"]


const SN_DESCS: = {
	"owls_eye": "Pasiva: más daño de tu ataque básico, con cualquier arma.", 
	"snake_eye": "Pasiva: puntería: más daño de tu ataque básico, con cualquier arma.", 
	"single_action": "Pasiva: atacas más rápido y con más críticos, con cualquier arma.", 
	"chain_action": "Pasiva: a veces tu ataque básico golpea dos veces seguidas.", 
	"improve_concentration": "Concentración: atacas más rápido y con más fuerza, con cualquier arma.", 
	"gatling_fever": "Fiebre de combate: más velocidad de ataque y daño, con cualquier arma.", 
}



func skill_desc(id: String, custom: = false) -> String:
	if custom and SN_DESCS.has(id):
		return SN_DESCS[id]
	return str(SKILLS[id].get("desc", ""))



func sn_origin(id: String) -> String:
	for c in SN_CLASSES:
		if (CLASSES[c].skills as Array).has(id) or (CLASSES[c].passives as Array).has(id):
			return c
	return ""



func sn_pool(passive: bool) -> Array:
	var out: = []
	for c in SN_CLASSES:
		for id in (CLASSES[c].passives if passive else CLASSES[c].skills):
			if SKILLS.has(id) and not out.has(id):
				out.append(id)
	return out













const SN_MULT_MAX: = 2
const SN_MULT_FIELDS: = ["dmg", "basic_dmg", "skill_dmg", "crit_dmg", "double", "kick_fury", "vs_boss", "throw_dmg", 
	"arrow_dmg", "arrow_skill_dmg", "aura_blade", "melt"]


func sn_mult(id: String) -> bool:
	var s: Dictionary = SKILLS.get(id, {})
	for f in s.get("bonus", []):
		if f in SN_MULT_FIELDS:
			return true




	if s.has("vuln") or SKILLS.get(str((EVOLUTIONS.get(id, {}) as Dictionary).get("to", "")), {}).has("vuln"):
		return true
	return str(s.get("type", "")) == "signum"


func sn_mult_count(ids: Array) -> int:
	return ids.filter( func(id): return sn_mult(str(id))).size()




func sn_trim(build: Dictionary) -> Dictionary:
	var n: = 0
	var out: = {}
	for key in ["skills", "passives"]:
		var keep: = []
		for id in build.get(key, []):
			if sn_mult(str(id)):
				if n >= SN_MULT_MAX:
					continue
				n += 1
			keep.append(id)
		out[key] = keep
	return out



func sn_ammo(ids: Array) -> String:
	var ammo: = ""
	for id in ids:
		if not SKILLS.has(id) or not (SKILLS[id].get("uses_arrows", false) or id == "making_arrow"):
			continue
		var m: Dictionary = SN_MECHANICS.get(sn_origin(str(id)), {})
		if m.has("ammo"):
			if ammo != "" and ammo != str(m.ammo):
				return "conflict"
			ammo = str(m.ammo)
	return ammo



func sn_def(build: Dictionary) -> Dictionary:
	var d: Dictionary = CLASSES.super_novice.duplicate(true)
	build = sn_trim(build)
	var act: Array = (build.get("skills", []) as Array).filter( func(id): return SKILLS.has(id) and sn_pool(false).has(id))
	var pas: Array = (build.get("passives", []) as Array).filter( func(id): return SKILLS.has(id) and sn_pool(true).has(id))
	act = act.slice(0, int(d.max_skills))
	pas = pas.slice(0, int(d.max_passives))
	if act.is_empty():
		act = ["bash"]
	d.skills = act
	d.passives = pas
	d.start = act.filter( func(id): return not SKILLS[id].type in START_EXCLUDED_TYPES).front()\
	if act.any( func(id): return not SKILLS[id].type in START_EXCLUDED_TYPES) else act[0]
	var ammo: = sn_ammo(act + pas)
	if ammo != "" and ammo != "conflict":
		d["ammo"] = ammo
	for id in act + pas:
		if SN_CART_SKILLS.has(id):
			d["cart"] = true
	return d





const CLASS_MAX_LEVEL: = 30
const CLASS_LEVELS_PER_POINT: = 2
const PERM_STAT_MAX: = 5
const STAT_RESET_COST: = 400





const CLASS_XP_MULT: = 3.0


const CLASS_XP_MULT_RLV: = 1.8
func class_xp_to_next(level: int, rlv: = 0) -> int:
	return int(600.0 * (CLASS_XP_MULT_RLV if rlv > 0 else CLASS_XP_MULT) * pow(level, 1.3))









const REBIRTH_LV_MAX: = 10
const REBIRTH_LV_XP: = [1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0, 3.5, 4.0, 4.5]
const REBIRTH_LV_RUN_SHARE: = 0.24
const REBIRTH_LV_LOOKS: = [
	{"id": "sparkles", "name": "Destellos estelares", "desc": "Estrellas que titilan a tu alrededor."}, 
	{"id": "biolab", "name": "Luces de Bio Lab", "desc": "Las extrañas luces verdes del laboratorio de Lighthalzen flotan a tu alrededor."}, 
	{"id": "rays", "name": "Rayos de luz", "desc": "De vez en cuando brotan rayos de luz a tu alrededor."}, 
	{"id": "orbs", "name": "Llamas de Sight", "desc": "Dos llamas de Sight, el hechizo del Mago, giran a tu alrededor."}, 
	{"id": "trail", "name": "Estela", "desc": "Al caminar dejas una estela de tu silueta."}, 
	{"id": "gold", "name": "Aura dorada", "desc": "Tu aura de renacido se vuelve dorada."}, 
	{"id": "pillar", "name": "Pilar de luz", "desc": "Un pilar de luz se alza a tu alrededor de vez en cuando."}, 
	{"id": "halo", "name": "Halo", "desc": "Un anillo de luz flota sobre tu cabeza."}, 
	{"id": "crown", "name": "Corona de estrellas", "desc": "Estrellas que giran en corona sobre tu cabeza."}, 
	{"id": "valhalla", "name": "Luz de Valhalla", "desc": "Motas doradas suben de tu cuerpo y tu nombre brilla en oro."}, 
]

static func rebirth_name(rlv: int) -> String:
	return TranslationServer.translate("Rebirth %s") % roman(rlv)


static func roman(n: int) -> String:
	var out: = ""
	for pair in [[1000, "M"], [900, "CM"], [500, "D"], [400, "CD"], [100, "C"], [90, "XC"], [50, "L"], [40, "XL"], 
			[10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]]:
		while n >= int(pair[0]):
			out += str(pair[1])
			n -= int(pair[0])
	return out



const REBIRTH_LV_GOLD: = Color(1.0, 0.8, 0.25)









const HAIR_STYLES: = 43

const DORAM_HAIR_STYLES: = 10
const DORAM_BODIES: = ["summoner", "spirit_handler"]


static func is_doram_body(body: String) -> bool:
	return body.get_slice("@", 0).trim_suffix("_f") in DORAM_BODIES
const HAIR_COLORS: = 9
const CLOTH_DYES: = 32
const NAME_MAX: = 23
const DEFAULT_LOOK: = {"name": "", "gender": "m", "hair": 2, "hair_color": 0, "cloth": 0}





const ELEMENT_ORDER: = ["neutral", "water", "earth", "fire", "wind", "poison", "holy", "shadow", "ghost", "undead"]
const ELEMENT_NAMES: = {"neutral": "Neutral", "water": "Agua", "earth": "Tierra", "fire": "Fuego", 
	"wind": "Viento", "poison": "Veneno", "holy": "Sagrado", "shadow": "Sombra", "ghost": "Fantasma", 
	"undead": "No-muerto"}

const ELEMENT_WORD_EVERY: = 1.5

const ELEMENT_COLORS: = {
	"neutral": Color(0.62, 0.68, 0.8), "water": Color(0.45, 0.68, 0.98), "earth": Color(0.72, 0.58, 0.38), 
	"fire": Color(0.98, 0.55, 0.32), "wind": Color(0.66, 0.85, 0.4), "poison": Color(0.62, 0.78, 0.35), 
	"holy": Color(0.98, 0.88, 0.45), "shadow": Color(0.62, 0.48, 0.82), "ghost": Color(0.78, 0.72, 0.95), 
	"undead": Color(0.55, 0.55, 0.6), 
}
const ELEMENT_TABLE: = {
	"neutral": [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.25, 1.0], 
	"water": [1.0, 0.25, 1.0, 1.5, 0.5, 1.0, 0.75, 1.0, 1.0, 1.0], 
	"earth": [1.0, 1.0, 0.25, 0.5, 1.5, 1.0, 0.75, 1.0, 1.0, 1.0], 
	"fire": [1.0, 0.5, 1.5, 0.25, 1.0, 1.0, 0.75, 1.0, 1.0, 1.25], 
	"wind": [1.0, 1.75, 0.5, 1.0, 0.25, 1.0, 0.75, 1.0, 1.0, 1.0], 
	"poison": [1.0, 1.0, 1.25, 1.25, 1.25, 0.0, 0.75, 0.5, 1.0, 0.5], 
	"holy": [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.25, 1.0, 1.5], 
	"shadow": [1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.25, 0.0, 1.0, 0.5], 
	"ghost": [0.25, 1.0, 1.0, 1.0, 1.0, 0.5, 0.75, 0.75, 1.25, 1.0], 
	"undead": [1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 0.0, 1.0, 0.0], 
}

const MONSTER_ELEMENTS: = {
	"poring": "water", "lunatic": "neutral", "fabre": "earth", "willow": "earth", "mastering": "water", 
	"eclipse": "neutral", "elder_willow": "fire", "angeling": "holy", "baphomet": "shadow", 
	"spore": "water", "poporing": "poison", "smokie": "earth", "wolf": "earth", "bigfoot": "earth", 
	"vagabond_wolf": "earth", "eddga": "fire", 
	"orc_baby": "earth", "ork_warrior": "earth", "orc_lady": "earth", "orc_archer": "earth", 
	"orc_zombie": "undead", "high_orc": "fire", "skel_soldier": "undead", "munak": "undead", 
	"bon_gun": "undead", "sohee": "water", "horong": "fire", "nine_tail": "fire", 
	"skeleton_general": "undead", "moonlight": "fire", "zenorc": "shadow", "orc_skeleton": "undead", 
	"drainliar": "shadow", "orc_lord": "earth", "ork_hero": "earth", 
	"zombie": "undead", "ghoul": "undead", "whisper": "ghost", "wraith": "undead", "skeleton": "undead", 
	"evil_druid": "undead", "skel_archer": "undead", "raydric": "shadow", "khalitzburg": "undead", "bloody_knight": "shadow", 
	"dark_lord": "undead", 
	"satan_morroc": "shadow", "morroc_incarnation_1": "shadow", "morroc_incarnation_2": "shadow", 
	"morroc_incarnation_3": "shadow", "morroc_incarnation_4": "shadow", "morroc_kid": "shadow", "morroc_adult": "shadow", 
	"ragged_zombie": "undead", "zombie_slaughter": "undead", "hell_poodle": "shadow", "banshee": "shadow", 
	"flame_skull": "ghost", "necromancer": "undead", "banshee_master": "shadow", "fallen_bishop": "shadow", 
	"disguise": "earth", "gibbet": "shadow", "rideword": "neutral", "dark_priest": "undead", 
	"bloody_murderer": "shadow", "dullahan": "undead", "hunter_fly": "wind", "beelzebub": "shadow", 
	"thief_bug": "shadow", "thief_bug_male": "shadow", "tarou": "shadow", "plankton": "water", "cramp": "poison", "thara_frog": "water", "toad": "water", "thief_bug_egg": "shadow", "golden_bug": "fire", "kukre": "water", "vadon": "water", "marina": "water", "hydra": "water", "marse": "water", "obeaune": "water", "strouf": "water", "kraken": "water", "solider": "earth", "permeter": "earth", "freezer": "water", "heater": "fire", "turtle_knight": "earth", "turtle_champion": "earth", "turtle_general": "earth", "mimic": "neutral", "mummy": "undead", "isis": "shadow", "matyr": "shadow", "minorous": "fire", "marduk": "fire", "ancient_mummy": "undead", "osiris": "undead", "andre": "earth", "piere": "earth", "deniro": "earth", "vitata": "earth", "argiope": "poison", "giant_spider": "poison", "maya": "earth", "skel_worker": "undead", "steel_chocho": "wind", "iron_fist": "neutral", "hornet": "wind", "argos": "wind", "giant_hornet": "wind", "golem": "neutral", "mistress": "wind", "clock": "earth", "alarm": "neutral", "punk": "wind", "owl_duke": "neutral", "owl_baron": "neutral", "quve": "ghost", "loli_ruri": "shadow", "hylozoist": "shadow", "lord_of_death": "shadow", "venatu": "neutral", "venatu_1": "fire", "dimik": "neutral", "dimik_1": "water", "dimik_2": "wind", "archdam": "neutral", "apocalips": "neutral", 

	"cookie": "neutral", "cookie_xmas": "holy", "cruiser": "neutral", "mystcase": "neutral", "marionette": "ghost", 
	"garm_baby": "water", "garm": "water", "knight_of_windstorm": "wind", 
	"solace": "holy", "observation": "neutral", "retribution": "shadow", "shelter": "holy", "zherlthsh": "shadow", 
	"tha_odium": "shadow", "thanatos": "ghost", "reginleif": "holy", "randgris_fallen": "shadow", 
	"ygnizem": "fire", "whikebain": "poison", "armaia": "earth", "erend": "holy", "kavac": "wind", "rawrel": "ghost", 
	"seyren": "fire", "eremes": "poison", "magaleta": "holy", "shecil": "wind", "katrinn": "ghost", "harword": "water", 
	"l_seyren": "fire", 

	"magmaring": "fire", "imp": "fire", "blazer": "fire", "explosion": "fire", "salamander": "fire", "kasa": "fire", 
	"lava_golem": "fire", "ifrit": "fire", 
	"agav": "neutral", "echio": "neutral", "isilla": "neutral", "seeker": "wind", "vanberk": "neutral", "hodremlin": "shadow", 
	"gremlin": "shadow", "beholder": "wind", "beholder_master": "wind", "gloom": "ghost", 
	"siroma": "water", "snowier": "water", "gazeti": "water", "iceicle": "water", "ice_titan": "water", 
	"furious_snowier": "water", "ktullanux": "water", 
}


const STATUS_ELEMENT: = {"freeze": "water", "stone": "earth"}


const STATUS_COMBO: = {"freeze": "wind", "stone": "fire"}



const BLIND_MISS: = 0.5
const BLIND_MISS_BOSS: = 0.3
const STATUS_NAMES: = {"freeze": "Congelado", "stone": "Piedra", "stun": "Aturdido", "sleep": "Dormido"}


const EMOTES: = {"omg": 23, "money": 9, "heh": 18, "sweat": 5, "idea": 6, "love": 3, "love2": 4, 
	"sorry": 17, "wah": 16, "surprise": 0, "grats": 43, "no1": 21, 
	"question": 1, "music": 2, "hmm": 20, "go": 27, "ok": 33, "help": 26, "cry": 28, "quest": 80}





const PETS: = {
	"poring": {"name": "Poring", "tame": "tame_poring", "item": "Unripe Apple", "drop": 0.004, "rate": 0.5, 
		"mods": {"loot": 0.2, "magnet": 0.15}, "desc": "+20% zeny y +15% radio para recoger"}, 
	"lunatic": {"name": "Lunatic", "tame": "tame_lunatic", "item": "Rainbow Carrot", "drop": 0.004, "rate": 0.45, 
		"mods": {"card": 0.3}, "desc": "+30% probabilidad de cartas"}, 
	"spore": {"name": "Spore", "tame": "tame_spore", "item": "Dew Laden Moss", "drop": 0.004, "rate": 0.45, 
		"mods": {"xp": 0.12}, "desc": "+12% EXP"}, 
	"smokie": {"name": "Smokie", "tame": "tame_smokie", "item": "Sweet Potato", "drop": 0.004, "rate": 0.4, 
		"mods": {"move": 0.1, "dodge": 0.02}, "desc": "+10% velocidad de movimiento, +2% evasión"}, 

	"sohee": {"name": "Sohee", "tame": "tame_sohee", "item": "Silver Knife of Chastity", "drop": 0.004, "rate": 0.35, 
		"mods": {"max_hp_pct": 0.12}, "desc": "+12% vida máxima"}, 
	"ork_warrior": {"name": "Orc Warrior", "tame": "tame_ork_warrior", "item": "Orc Trophy", "drop": 0.004, "rate": 0.35, 
		"mods": {"dmg": 0.08}, "desc": "+8% de todo el daño"}, 
	"drainliar": {"name": "Drainliar", "tame": "tame_drainliar", "item": "Bat Cage", "drop": 0.004, "rate": 0.35, 
		"mods": {}, "effects": {"lifesteal": 0.03}, "desc": "El ataque básico te cura el 3% del daño que hace"}, 
	"whisper": {"name": "Whisper", "tame": "tame_whisper", "item": "Ghost Bandana", "drop": 0.004, "rate": 0.3, 
		"mods": {"dodge": 0.07}, "desc": "+7% evasión"}, 
	"hell_poodle": {"name": "Hell Poodle", "tame": "tame_hell_poodle", "item": "Puppy Love", "drop": 0.004, "rate": 0.3, 
		"mods": {"crit": 0.08}, "desc": "+8% probabilidad de crítico"}, 
	"hunter_fly": {"name": "Hunter Fly", "tame": "tame_hunter_fly", "item": "Monster Juice", "drop": 0.004, "rate": 0.3, 
		"mods": {"aspd": 0.1}, "desc": "+10% velocidad de ataque (ASPD)"}, 



	"tarou": {"name": "Tarou", "tame": "tame_tarou", "item": "Cheese", "drop": 0.004, "rate": 0.45, 
		"mods": {"magnet": 0.45}, "desc": "+45% radio para recoger botín"}, 
	"marina": {"name": "Marina", "tame": "tame_marina", "item": "Clam Flesh", "drop": 0.004, "rate": 0.4, 
		"mods": {"regen": 1.5}, "desc": "+1.5 vida por segundo"}, 
	"permeter": {"name": "Permeter", "tame": "tame_permeter", "item": "Delicious Fish", "drop": 0.004, "rate": 0.4, 
		"mods": {"armor": 3.0}, "desc": "+3 defensa"}, 
	"isis": {"name": "Isis", "tame": "tame_isis", "item": "Armlet of Obedience", "drop": 0.004, "rate": 0.35, 
		"mods": {"crit_dmg": 0.25}, "desc": "+25% daño de los golpes críticos"}, 
	"andre": {"name": "Andre", "tame": "tame_andre", "item": "Candy", "drop": 0.004, "rate": 0.35, 
		"mods": {"basic_dmg": 0.12}, "desc": "+12% daño del ataque básico"}, 
	"steel_chocho": {"name": "Steel Chonchon", "tame": "tame_steel_chocho", "item": "Rusty Iron", "drop": 0.004, "rate": 0.3, 
		"mods": {}, "effects": {"stun_hit": 0.05}, "desc": "El ataque básico tiene un 5% de aturdir"}, 
	"alarm": {"name": "Alarm", "tame": "tame_alarm", "item": "Spring", "drop": 0.004, "rate": 0.3, 
		"mods": {"haste": 0.08}, "desc": "-8% recarga de habilidades"}, 
	"loli_ruri": {"name": "Loli Ruri", "tame": "tame_loli_ruri", "item": "Very Red Juice", "drop": 0.004, "rate": 0.3, 
		"mods": {}, "effects": {"kill_heal": 0.005}, "desc": "Cada monstruo que matas te cura el 0.5% de la vida"}, 
	"dimik": {"name": "Dimik", "tame": "tame_dimik", "item": "Cogwheel", "drop": 0.004, "rate": 0.25, 
		"mods": {"skill_dmg": 0.1}, "desc": "+10% daño de habilidades"}, 



	"antonio": {"name": "Antonio", "tame": "tame_antonio", "item": "Candy Cane", "drop": 0.04, "rate": 0.35, "season": true, 
		"mods": {"loot": 0.2, "card": 0.15}, "desc": "+20% zeny y +15% probabilidad de cartas"}, 
	"cookie_xmas": {"name": "Christmas Cookie", "tame": "tame_cookie_xmas", "item": "Gift Box", "drop": 0.004, "rate": 0.3, 
		"mods": {}, "effects": {"heal_power": 0.15}, "desc": "+15% curación de tus habilidades"}, 
	"observation": {"name": "Observation", "tame": "tame_observation", "item": "Flower", "drop": 0.004, "rate": 0.25, 
		"mods": {"crit": 0.05, "card": 0.1}, "desc": "+5% crítico y +10% probabilidad de cartas"}, 
	"kavac": {"name": "Kavac Icarus", "tame": "tame_kavac", "item": "Lab Pass", "drop": 0.004, "rate": 0.25, 
		"mods": {"aspd": 0.06, "move": 0.04}, "desc": "+6% velocidad de ataque y +4% de movimiento"}, 
	"magmaring": {"name": "Magmaring", "tame": "tame_magmaring", "item": "Burning Heart", "drop": 0.004, "rate": 0.25, 
		"mods": {}, "effects": {"burn_power": 0.15}, "desc": "Tus quemaduras pegan un 15% más"}, 
	"isilla": {"name": "Isilla", "tame": "tame_isilla", "item": "Light Granule", "drop": 0.004, "rate": 0.25, 
		"mods": {"duration": 0.1, "haste": 0.04}, "desc": "+10% duración de habilidades y -4% recarga"}, 
	"siroma": {"name": "Siroma", "tame": "tame_siroma", "item": "Ice Crystal", "drop": 0.004, "rate": 0.3, 
		"mods": {"max_hp_pct": 0.06, "armor": 2.0}, "desc": "+6% vida máxima y +2 defensa"}, 

	"bon_gun": {"name": "Bongun", "tame": "", "item": "", "drop": 0.0, "rate": 0.0, "quest": "pay_cave", 
		"mods": {"duration": 0.15, "area": 0.06}, "desc": "+15% duración y +6% área de habilidades"}, 
	"baphomet_jr": {"name": "Baphomet Jr.", "tame": "", "item": "", "drop": 0.0, "rate": 0.0, "quest": "abbey", 
		"mods": {"dmg": 0.06, "crit": 0.04, "area": 0.08}, "desc": "+6% daño, +4% crítico y +8% área"}, 


















	"baphomet": {"name": "Baphomet", "mvp": true, "tame": "egg_shadow", "item": "Huevo de Baphomet", "drop": 0.03, "rate": 0.75, 
		"mods": {"dmg": 0.08, "area": 0.12}, 
		"skill": {"kind": "nova", "every": 7.0, "dmg": 220.0, "radius": 5.0, "element": "shadow", "pull": 7.0, "fx": "brandish", "name": "Brandish Spear"}, 
		"desc": "+8% daño y +12% área. Cada 7 s barre con Brandish Spear a tu alrededor y arrastra a los monstruos hacia ti: junta la horda para tus habilidades de área"}, 
	"eddga": {"name": "Eddga", "mvp": true, "tame": "egg_fire", "item": "Huevo de Eddga", "drop": 0.03, "rate": 0.75, 
		"mods": {"basic_dmg": 0.12, "aspd": 0.08}, "effects": {"burn_hit": 0.1, "burn_power": 0.25}, 
		"skill": {"kind": "nova", "every": 8.0, "dmg": 190.0, "radius": 4.0, "element": "fire", "fx": "black_hammerfall", "status": "stun", "status_time": 1.2, "dot": "burn", "name": "Hammer Fall"}, 
		"desc": "+12% daño básico y +8% ASPD; tu básico quema un 10% de las veces y tus quemaduras pegan un 25% más. Cada 8 s un Hammer Fall aturde y prende fuego a todo a tu alrededor"}, 
	"moonlight": {"name": "Moonlight Flower", "mvp": true, "tame": "egg_fire", "item": "Huevo de Moonlight Flower", "drop": 0.03, "rate": 0.75, 
		"mods": {"loot": 0.15, "move": 0.1}, 
		"skill": {"kind": "power", "every": 11.0, "power": "pet_moonlight", "time": 6.0, "radius": 7.0, "tex_fx": "agi_up", "name": "Increase AGI", 
			"extra": {"kind": "strikes", "count": 4, "dmg": 130.0, "range": 8.0, "element": "fire", "fx": "firepillar"}}, 
		"desc": "+15% zeny y +10% velocidad. Cada 11 s te da Increase AGI a ti y a tu grupo (+25% ASPD y +20% velocidad durante 6 s) y cuatro fuegos de zorro caen sobre los monstruos"}, 
	"ork_hero": {"name": "Orc Hero", "mvp": true, "tame": "egg_earth", "item": "Huevo de Orc Hero", "drop": 0.03, "rate": 0.75, 
		"mods": {"max_hp_pct": 0.12, "armor": 4.0}, 
		"skill": {"kind": "shield", "every": 12.0, "pct": 0.12, "radius": 7.0, "fx": "loud", "name": "Grito de guerra", 
			"extra": {"kind": "power", "power": "pet_war_cry", "time": 6.0, "radius": 7.0}}, 
		"desc": "+12% vida y +4 defensa. Cada 12 s su grito de guerra da a tu grupo una barrera del 12% de la vida y +20% de daño durante 6 s"}, 
	"orc_lord": {"name": "Orc Lord", "mvp": true, "tame": "egg_earth", "item": "Huevo de Orc Lord", "drop": 0.03, "rate": 0.75, 
		"mods": {"dmg": 0.05, "crit_dmg": 0.15}, "effects": {"summon_dmg": 0.3, "homun_power": 0.25}, 
		"skill": {"kind": "nova", "every": 8.0, "dmg": 190.0, "radius": 5.0, "element": "earth", "fx": "quagmire", "status": "stun", "status_time": 1.0, "name": "Terremoto"}, 
		"desc": "+5% daño y +15% daño crítico; tus invocaciones pegan un 30% más y tu homúnculo un 25%. Cada 8 s un terremoto aturde a todo a tu alrededor"}, 
	"dark_lord": {"name": "Dark Lord", "mvp": true, "tame": "egg_undead", "item": "Huevo de Dark Lord", "drop": 0.03, "rate": 0.75, 
		"mods": {"skill_dmg": 0.1}, "effects": {"double_cast": 0.08}, 
		"skill": {"kind": "strikes", "every": 8.0, "count": 4, "dmg": 200.0, "range": 9.0, "element": "fire", "fx": "meteor1", "dot": "burn", "name": "Meteor Storm"}, 
		"desc": "+10% daño de habilidades y un 8% de doble lanzamiento. Cada 8 s cuatro meteoros caen sobre los monstruos y los dejan ardiendo"}, 
	"fallen_bishop": {"name": "Fallen Bishop", "mvp": true, "tame": "egg_shadow", "item": "Huevo de Fallen Bishop", "drop": 0.03, "rate": 0.75, 
		"mods": {"skill_dmg": 0.06}, "effects": {"vs_boss": 0.12}, 
		"skill": {"kind": "strikes", "every": 7.0, "count": 4, "dmg": 150.0, "range": 9.0, "element": "shadow", "target": "tough", "mark": 2.0, "fx": "lord", "name": "Réquiem oscuro"}, 
		"desc": "+6% daño de habilidades y +12% daño a jefes. Cada 7 s golpea a los cuatro monstruos más duros y los marca con Lex Aeterna: tu siguiente golpe a cada uno hace el doble"}, 
	"beelzebub": {"name": "Beelzebub", "mvp": true, "tame": "egg_shadow", "item": "Huevo de Beelzebub", "drop": 0.03, "rate": 0.75, 
		"mods": {"aspd": 0.1}, "effects": {"lifesteal": 0.02, "poison_dmg": 0.25}, 
		"skill": {"kind": "nova", "every": 7.0, "dmg": 170.0, "radius": 5.5, "element": "poison", "fx": "venomdust", "dot": "poison", "name": "Plaga de moscas"}, 
		"desc": "+10% ASPD, el básico te cura el 2% y tu veneno pega un 25% más. Cada 7 s una plaga de moscas envenena a todo a tu alrededor (suma dosis al veneno que ya tengan)"}, 
	"golden_bug": {"name": "Golden Thief Bug", "mvp": true, "tame": "egg_fire", "item": "Huevo de Golden Thief Bug", "drop": 0.03, "rate": 0.75, 
		"mods": {"loot": 0.3, "card": 0.15}, "effects": {"zeny_discount": 0.3}, 
		"skill": {"kind": "strikes", "every": 7.0, "count": 5, "dmg": 150.0, "range": 8.0, "element": "fire", "fx": "steal_coin", "coins": 1.0, "name": "Robo dorado"}, 
		"desc": "+30% zeny y +15% cartas; Mammonite y Cart Termination te cuestan un 30% menos. Cada 7 s golpea a cinco monstruos y les arranca monedas de zeny"}, 
	"kraken": {"name": "Kraken", "mvp": true, "tame": "egg_water", "item": "Huevo de Kraken", "drop": 0.03, "rate": 0.75, 
		"mods": {"area": 0.1}, "effects": {"status_time": 0.3, "status_vuln": 0.12}, 
		"skill": {"kind": "strikes", "every": 8.0, "count": 5, "dmg": 130.0, "range": 8.0, "element": "water", "fx": "icecrash", "status": "freeze", "status_time": 2.0, "name": "Tentáculo helado"}, 
		"desc": "+10% área; tus estados duran un 30% más y los monstruos con un estado reciben un 12% más de daño. Cada 8 s cinco tentáculos helados congelan monstruos (el viento les hace mucho más)"}, 
	"turtle_general": {"name": "Turtle General", "mvp": true, "tame": "egg_earth", "item": "Huevo de Turtle General", "drop": 0.03, "rate": 0.75, 
		"mods": {"armor": 6.0, "max_hp_pct": 0.1}, "effects": {"reflect": 0.3}, 
		"skill": {"kind": "shield", "every": 10.0, "pct": 0.18, "radius": 7.0, "fx": "kyrie", "name": "Caparazón", 
			"extra": {"kind": "nova", "dmg": 170.0, "radius": 3.5, "element": "earth", "push": 7.0, "fx": "earthhit"}}, 
		"desc": "+6 defensa, +10% vida y reflejas el 30% del daño. Cada 10 s un caparazón da a tu grupo una barrera del 18% de la vida y aparta de un golpe a los monstruos pegados a ti"}, 
	"osiris": {"name": "Osiris", "mvp": true, "tame": "egg_undead", "item": "Huevo de Osiris", "drop": 0.03, "rate": 0.75, 
		"mods": {}, "effects": {"kill_heal": 0.004, "heal_power": 0.2}, 
		"skill": {"kind": "heal", "every": 9.0, "pct": 0.12, "radius": 7.0, "fx": "sanctuary", "name": "Bendición del faraón", 
			"extra": {"kind": "strikes", "count": 3, "dmg": 150.0, "range": 8.0, "element": "shadow", "fx": "stonecurse", "status": "stone", "status_time": 2.0}}, 
		"desc": "Cada muerte te cura 0.4% y tus curas curan un 20% más. Cada 9 s cura a tu grupo el 12% de la vida y convierte en piedra a tres monstruos (el fuego les hace mucho más)"}, 
	"maya": {"name": "Maya", "mvp": true, "tame": "egg_earth", "item": "Huevo de Maya", "drop": 0.03, "rate": 0.75, 
		"mods": {"dodge": 0.06}, "effects": {"stun_hit": 0.05, "status_chance": 0.1}, 
		"skill": {"kind": "strikes", "every": 7.0, "count": 4, "dmg": 160.0, "range": 8.0, "element": "earth", "fx": "quagmire", "status": "stun", "status_time": 1.2, "name": "Golpe de la reina"}, 
		"desc": "+6% evasión; tu básico aturde un 5% de las veces y tus habilidades ponen sus estados un 10% más a menudo. Cada 7 s aplasta a cuatro monstruos y los aturde"}, 
	"mistress": {"name": "Mistress", "mvp": true, "tame": "egg_wind", "item": "Huevo de Mistress", "drop": 0.03, "rate": 0.75, 
		"mods": {"aspd": 0.12}, "effects": {"bleed_hit": 0.08, "bleed_power": 0.2}, 
		"skill": {"kind": "strikes", "every": 6.0, "count": 6, "dmg": 90.0, "range": 8.0, "element": "wind", "fx": "lightning", "dot": "bleed", "name": "Aguijones"}, 
		"desc": "+12% ASPD; tu básico hace sangrar un 8% de las veces y cada corte guarda un 20% más de sangre. Cada 6 s seis aguijones hacen sangrar a los monstruos"}, 
	"owl_baron": {"name": "Owl Baron", "mvp": true, "tame": "egg_neutral", "item": "Huevo de Owl Baron", "drop": 0.03, "rate": 0.75, 
		"mods": {"haste": 0.1}, "effects": {"arrow_dmg": 0.15, "falcon_dmg": 0.3}, 
		"skill": {"kind": "strikes", "every": 7.0, "count": 5, "dmg": 140.0, "range": 9.0, "element": "wind", "fx": "thunderstorm", "name": "Tormenta de rayos"}, 
		"desc": "-10% recarga; tus flechas pegan un 15% más y tu halcón un 30%. Cada 7 s una tormenta de rayos sobre cinco monstruos"}, 
	"lord_of_death": {"name": "Lord of Death", "mvp": true, "tame": "egg_shadow", "item": "Huevo de Lord of Death", "drop": 0.03, "rate": 0.75, 
		"mods": {"dmg": 0.05, "crit_dmg": 0.2}, 
		"skill": {"kind": "nova", "every": 8.0, "dmg": 200.0, "radius": 5.5, "element": "shadow", "fx": "hell_in", "execute": 0.2, "name": "Juicio del infierno"}, 
		"desc": "+5% daño y +20% daño crítico. Cada 8 s el juicio del infierno arrasa a tu alrededor y remata a los que queden por debajo del 20% de su vida (no a los jefes)"}, 
	"apocalips": {"name": "Vesper", "mvp": true, "tame": "egg_neutral", "item": "Huevo de Vesper", "drop": 0.03, "rate": 0.75, 
		"mods": {"armor": 3.0, "dmg": 0.06}, "effects": {"trap_vuln": 0.25}, 
		"skill": {"kind": "strikes", "every": 6.0, "count": 3, "dmg": 260.0, "range": 9.0, "element": "neutral", "fx": "earthhit", "push": 8.0, "name": "Puño de acero"}, 
		"desc": "+3 defensa y +6% daño; los monstruos atrapados en trampas reciben ×1,25 de daño. Cada 6 s tres puñetazos de acero enormes que lanzan lejos a los monstruos"}, 
	"knight_of_windstorm": {"name": "Stormy Knight", "mvp": true, "tame": "egg_wind", "item": "Huevo de Stormy Knight", "drop": 0.03, "rate": 0.75, 
		"mods": {"move": 0.06, "aspd": 0.06}, "effects": {"weak_bonus": 0.2}, 
		"skill": {"kind": "nova", "every": 8.0, "dmg": 180.0, "radius": 5.0, "element": "water", "fx": "stormgust", "status": "freeze", "status_time": 1.5, "name": "Storm Gust"}, 
		"desc": "+6% movimiento y ASPD; tus golpes a un elemento débil (y a congelados o petrificados con su elemento) hacen un 20% más. Cada 8 s un Storm Gust congela a todo a tu alrededor"}, 
	"thanatos": {"name": "Memory of Thanatos", "mvp": true, "tame": "egg_shadow", "item": "Huevo de Thanatos", "drop": 0.03, "rate": 0.75, 
		"mods": {"dmg": 0.06, "haste": 0.06}, 
		"skill": {"kind": "echo", "every": 9.0, "count": 2, "fx": "hell_in", "name": "Memoria de Thanatos"}, 
		"desc": "+6% daño y -6% recarga. Cada 9 s la memoria de Thanatos lanza otra vez dos de tus habilidades de ataque que apuntan solas, a su nivel (no las que te mueven: Asura Strike, patadas, saltos)"}, 
	"l_seyren": {"name": "Lord Knight Seyren", "mvp": true, "tame": "egg_fire", "item": "Huevo de Lord Knight Seyren", "drop": 0.03, "rate": 0.75, 
		"mods": {"dmg": 0.08, "max_hp_pct": 0.08, "basic_dmg": 0.08}, 
		"skill": {"kind": "strikes", "every": 6.0, "count": 3, "dmg": 220.0, "range": 9.0, "element": "fire", "fx": "bowling", "splash": 2.0, "push": 5.0, "name": "Bowling Bash"}, 
		"desc": "+8% daño, +8% daño básico y +8% vida. Cada 6 s tres Bowling Bash de fuego que estallan alrededor de cada objetivo y lo lanzan lejos"}, 
	"ifrit": {"name": "Ifrit", "mvp": true, "tame": "egg_fire", "item": "Huevo de Ifrit", "drop": 0.03, "rate": 0.75, 
		"mods": {"skill_dmg": 0.06, "area": 0.08}, "effects": {"burn_power": 0.3}, 
		"skill": {"kind": "nova", "every": 8.0, "dmg": 210.0, "radius": 5.5, "element": "fire", "fx": "firepillar", "dot": "burn", "push": 4.0, "name": "Erupción"}, 
		"desc": "+6% daño de habilidades y +8% área; tus quemaduras pegan un 30% más. Cada 8 s una erupción a tu alrededor prende fuego a todos los monstruos y los aparta"}, 
	"gloom": {"name": "Gloom Under Night", "mvp": true, "tame": "egg_shadow", "item": "Huevo de Gloom Under Night", "drop": 0.03, "rate": 0.75, 
		"mods": {"dmg": 0.06, "duration": 0.1}, "effects": {"vs_boss": 0.1}, 
		"skill": {"kind": "strikes", "every": 7.0, "count": 4, "dmg": 170.0, "range": 9.0, "element": "ghost", "target": "tough", "frail": 0.12, "fx": "hell_in", "name": "Noche de Gloom"}, 
		"desc": "+6% daño, +10% duración y +10% daño a jefes. Cada 7 s la noche cae sobre los cuatro monstruos más duros: reciben ×1,12 de daño de todos durante 5 s"}, 
	"ktullanux": {"name": "Ktullanux", "mvp": true, "tame": "egg_water", "item": "Huevo de Ktullanux", "drop": 0.03, "rate": 0.75, 
		"mods": {"max_hp_pct": 0.08, "armor": 2.0}, "effects": {"status_time": 0.2}, 
		"skill": {"kind": "nova", "every": 9.0, "dmg": 190.0, "radius": 5.5, "element": "water", "fx": "icecrash", "status": "freeze", "status_time": 2.0, "name": "Aliento glacial", 
			"extra": {"kind": "shield", "pct": 0.1, "radius": 7.0, "fx": "kyrie"}}, 
		"desc": "+8% vida, +2 defensa y tus estados duran un 20% más. Cada 9 s su aliento glacial congela a todo a tu alrededor (el viento les hace mucho más) y da a tu grupo una barrera del 10% de la vida"}, 

	"reginleif": {"name": "Valkyrie Reginleif", "mvp": true, "tame": "egg_neutral", "item": "Huevo de Reginleif", "drop": 0.03, "rate": 0.75, 
		"mods": {"max_hp_pct": 0.08, "armor": 2.0}, "effects": {"vs_undead": 0.2, "judgment": 5.0}, 
		"skill": {"kind": "strikes", "every": 7.0, "count": 5, "dmg": 190.0, "range": 9.0, "element": "holy", "fx": "holyhit", "target": "tough", "judge": 3, "name": "Juicio de Valhalla", 
			"extra": {"kind": "heal", "pct": 0.05, "radius": 7.0, "fx": "angelus"}}, 
		"desc": "+8% vida, +2 defensa y +20% daño a no-muertos; tu daño sagrado deja marcas de Juicio (5 más de tope, cada una +3% de daño sagrado). Cada 7 s cinco lanzas sagradas caen sobre los monstruos más duros, les dejan 3 marcas cada una y curan a tu grupo un 5%"}, 
	"randgris_fallen": {"name": "Randgris Caída", "mvp": true, "tame": "egg_shadow", "item": "Huevo de Randgris Caída", "drop": 0.03, "rate": 0.75, 
		"mods": {"dmg": 0.1, "crit_dmg": 0.1}, 
		"skill": {"kind": "nova", "every": 8.0, "dmg": 210.0, "radius": 5.5, "element": "shadow", "fx": "hell_in", "frail": 0.15, "name": "Lanza de Hel"}, 
		"desc": "+10% daño y +10% daño crítico. Cada 8 s la lanza de Hel arrasa a tu alrededor y deja a los monstruos malditos: reciben ×1,15 de daño de todos durante 5 s"}, 
}






const COSMETIC_SLOTS: = ["top", "mid", "low", "back"]


const COSMETIC_HIDE: = "hide"
const COSMETIC_SLOT_NAMES: = {"top": "Arriba", "mid": "Medio", "low": "Abajo", "back": "Espalda", "body": "Cuerpo completo"}
const COSMETIC_RARITY: = {
	"common": {"name": "Común", "color": Color(0.45, 0.5, 0.58)}, 
	"rare": {"name": "Raro", "color": Color(0.25, 0.5, 0.95)}, 
	"epic": {"name": "Épico", "color": Color(0.62, 0.32, 0.9)}, 
	"legendary": {"name": "Legendario", "color": Color(0.95, 0.62, 0.15)}, 

	"unique": {"name": "Único", "color": Color(0.2, 0.78, 0.92)}, 
}














# [MOD] Cosmetic gacha rarity table. Shipped (0.2.11): common .69 / rare .22 / epic .075 / legendary .01 /
# unique .005. The cut comes out of common, redistributed up the ladder (common alone was 69% of
# spins). Must keep summing to 1.00: gacha_panel.gd roll() walks unique->common subtracting each
# weight from randf(), so a sum above 1 makes the lower tiers unreachable and a sum below 1 leaks
# the remainder into common. Both the roll and the "Probabilidades" list read this one dict, so the
# UI always shows the real odds. pity/epic_pity/dupe_coins untouched (0.2.11 turned dupe_coins into a
# per-rarity refund table): with legendary at 10% the 12-spin hard-pity and the 5-spin epic pity are
# now rarely the reason a good item drops.
const GACHA: = {"coins": 5, "zeny": 20000000, "pity": 12, "epic_pity": 5, 
	"dupe_coins": {"common": 1, "rare": 2, "epic": 3, "legendary": 5, "unique": 5}, 
	"odds": {"common": 0.40, "rare": 0.30, "epic": 0.15, "legendary": 0.10, "unique": 0.05}}



static func gacha_refund(rarity: String) -> int:
	return int(GACHA.dupe_coins.get(rarity, 1))
const COSMETICS: = {
	"poring_hat": {"name": "Poring Hat", "slot": "top", "view": "hat_c_poring_hat", "rarity": "common"}, 
	"lunatic_hat": {"name": "Lunatic Hat", "slot": "top", "view": "hat_c_lunatic_hat", "rarity": "common"}, 
	"kitty_band": {"name": "Kitty Band", "slot": "top", "view": "hat_c_kitty_band", "rarity": "common"}, 
	"bunny_band": {"name": "Bunny Band", "slot": "top", "view": "hat_c_bunny_band", "rarity": "common"}, 
	"feather_beret": {"name": "Feather Beret", "slot": "top", "view": "hat_c_feather_beret", "rarity": "common"}, 
	"sakkat": {"name": "Sakkat", "slot": "top", "view": "hat_c_sakkat", "rarity": "common"}, 
	"teddy_hat": {"name": "Teddy Bear Hat", "slot": "top", "view": "hat_c_teddy_hat", "rarity": "rare"}, 
	"fox_hat": {"name": "Fox Hat", "slot": "top", "view": "hat_c_fox_hat", "rarity": "rare"}, 
	"witch_hat": {"name": "Witch Hat", "slot": "top", "view": "hat_c_witch_hat", "rarity": "rare"}, 
	"rudolph": {"name": "Rudolph Hairband", "slot": "top", "view": "hat_c_rudolph", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"drooping_bunny": {"name": "Drooping Bunny", "slot": "top", "view": "hat_c_drooping_bunny", "rarity": "epic"}, 
	"drooping_cat": {"name": "Drooping Cat", "slot": "top", "view": "hat_c_drooping_cat", "rarity": "epic"}, 
	"angeling_hat": {"name": "Angeling Hat", "slot": "top", "view": "hat_c_angeling_hat", "rarity": "epic"}, 
	"tiara": {"name": "Tiara", "slot": "top", "view": "hat_c_tiara", "rarity": "epic"}, 
	"magestic_goat": {"name": "Magestic Goat", "slot": "top", "view": "hat_c_magestic_goat", "rarity": "legendary"}, 
	"baphomet_horns": {"name": "Baphomet Horns", "slot": "top", "view": "hat_c_baphomet_horns", "rarity": "legendary"}, 
	"butterfly_mask": {"name": "Butterfly Mask", "slot": "mid", "view": "hat_c_butterfly_mask", "rarity": "rare"}, 
	"fox_mask": {"name": "Fox Mask", "slot": "mid", "view": "hat_c_fox_mask", "rarity": "epic"}, 
	"poring_pipe": {"name": "Poring Bubble Pipe", "slot": "low", "view": "hat_c_poring_pipe", "rarity": "rare"}, 
	"poring_bag": {"name": "Poring Bag", "slot": "back", "view": "c_poring_bag", "rarity": "rare"}, 
	"adventurer_backpack": {"name": "Adventurer's Backpack", "slot": "back", "view": "c_adventurer_backpack", "rarity": "rare"}, 
	"devil_wings": {"name": "Little Devil Wings", "slot": "back", "view": "c_devil_wings", "rarity": "epic"}, 
	"nine_tails": {"name": "Nine Tails", "slot": "back", "view": "c_nine_tails", "rarity": "epic"}, 
	"angel_wings": {"name": "Angel Wings", "slot": "back", "view": "c_angel_wings", "rarity": "legendary"}, 
	"fallen_angel_wings": {"name": "Fallen Angel Wings", "slot": "back", "view": "c_fallen_angel_wings", "rarity": "legendary"}, 

	"singing_bird": {"name": "Singing Bird", "slot": "top", "view": "hat_c_singing_bird", "rarity": "common"}, 
	"rain_cloud": {"name": "Rain Cloud", "slot": "top", "view": "hat_c_rain_cloud", "rarity": "common"}, 
	"spore_hat": {"name": "Spore Hat", "slot": "top", "view": "hat_c_spore_hat", "rarity": "common"}, 
	"frog_hat": {"name": "Frog Hat", "slot": "top", "view": "hat_c_frog_hat", "rarity": "common"}, 
	"cowboy_hat": {"name": "Cowboy Hat", "slot": "top", "view": "hat_c_cowboy_hat", "rarity": "common"}, 
	"chick_hat": {"name": "Chick Hat", "slot": "top", "view": "hat_c_chick_hat", "rarity": "common"}, 
	"captain_hat": {"name": "Captain's Hat", "slot": "top", "view": "hat_c_captain_hat", "rarity": "common"}, 
	"vacation_hat": {"name": "Vacation Hat", "slot": "top", "view": "hat_c_vacation_hat", "rarity": "common"}, 
	"santa_poring_hat": {"name": "Santa Poring Hat", "slot": "top", "view": "hat_c_santa_poring_hat", "rarity": "common", "gacha": false, "event": "christmas"}, 
	"afro_wig": {"name": "Afro Wig", "slot": "top", "view": "hat_c_afro_wig", "rarity": "common"}, 
	"detective_hat": {"name": "Detective Hat", "slot": "top", "view": "hat_c_detective_hat", "rarity": "common"}, 
	"bee_hat": {"name": "Bee Hat", "slot": "top", "view": "hat_c_bee_hat", "rarity": "common"}, 
	"straw_hat": {"name": "Straw Hat", "slot": "top", "view": "hat_c_straw_hat", "rarity": "common"}, 
	"duck_hat": {"name": "Pingu Cap", "slot": "top", "view": "hat_c_duck_hat", "rarity": "common"}, 
	"santa_hat": {"name": "Santa Hat", "slot": "top", "view": "hat_c_santa_hat", "rarity": "common", "gacha": false, "event": "christmas"}, 
	"poporing_hat": {"name": "Poporing Hat", "slot": "top", "view": "hat_c_poporing_hat", "rarity": "common"}, 
	"chicken_hat": {"name": "Chicken Hat", "slot": "top", "view": "hat_c_chicken_hat", "rarity": "common"}, 
	"snowman_hat": {"name": "Snowman Hat", "slot": "top", "view": "hat_c_snowman_hat", "rarity": "common", "gacha": false, "event": "christmas"}, 
	"cactus_hat": {"name": "Cactus Hat", "slot": "top", "view": "hat_c_cactus_hat", "rarity": "common"}, 
	"sombrero": {"name": "Sombrero", "slot": "top", "view": "hat_c_sombrero", "rarity": "common"}, 
	"popcorn_hat": {"name": "Popcorn Hat", "slot": "top", "view": "hat_c_popcorn_hat", "rarity": "common"}, 
	"gryphon_hat": {"name": "Gryphon Hat", "slot": "top", "view": "hat_c_gryphon_hat", "rarity": "rare"}, 
	"full_moon": {"name": "Full Moon", "slot": "top", "view": "hat_c_full_moon", "rarity": "rare"}, 
	"super_novice_hat": {"name": "Super Novice Hat", "slot": "top", "view": "hat_c_super_novice_hat", "rarity": "rare"}, 
	"piggy_bank_hat": {"name": "Piggy Bank Hat", "slot": "top", "view": "hat_c_piggy_bank_hat", "rarity": "rare"}, 
	"triple_poring_hat": {"name": "Triple Poring Hat", "slot": "top", "view": "hat_c_triple_poring_hat", "rarity": "rare"}, 
	"neko_kafra": {"name": "Neko Mimi Kafra", "slot": "top", "view": "hat_c_neko_kafra", "rarity": "rare"}, 
	"sleeping_cat_hat": {"name": "Sleeping Cat Hat", "slot": "top", "view": "hat_c_sleeping_cat_hat", "rarity": "rare"}, 
	"laurel_wreath": {"name": "Laurel Wreath", "slot": "top", "view": "hat_c_laurel_wreath", "rarity": "rare"}, 
	"succubus_horns": {"name": "Succubus Horns", "slot": "top", "view": "hat_c_succubus_horns", "rarity": "rare"}, 
	"mini_tree": {"name": "Mini Christmas Tree", "slot": "top", "view": "hat_c_mini_tree", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"alpaca_hood": {"name": "Alpaca Hood", "slot": "top", "view": "hat_c_alpaca_hood", "rarity": "rare"}, 
	"jolly_roger": {"name": "Jolly Roger Hat", "slot": "top", "view": "hat_c_jolly_roger", "rarity": "rare"}, 
	"deviruchi_headphones": {"name": "Deviruchi Headphones", "slot": "top", "view": "hat_c_deviruchi_headphones", "rarity": "rare"}, 
	"pumpkin_head": {"name": "Pumpkin Head", "slot": "top", "view": "hat_c_pumpkin_head", "rarity": "rare"}, 
	"steampunk_hat": {"name": "Steampunk Hat", "slot": "top", "view": "hat_c_steampunk_hat", "rarity": "rare"}, 
	"elephant_hat": {"name": "Elephant Hat", "slot": "top", "view": "hat_c_elephant_hat", "rarity": "rare"}, 
	"deviruchi_balloon": {"name": "Deviruchi Balloon", "slot": "top", "view": "hat_c_deviruchi_balloon", "rarity": "rare"}, 
	"hungry_fish_hat": {"name": "Hungry Fish Hat", "slot": "top", "view": "hat_c_hungry_fish_hat", "rarity": "rare"}, 
	"rainbow_poring_hat": {"name": "Rainbow Poring Hat", "slot": "top", "view": "hat_c_rainbow_poring_hat", "rarity": "epic"}, 
	"drooping_nine_tail": {"name": "Drooping Nine Tail", "slot": "top", "view": "hat_c_drooping_nine_tail", "rarity": "epic"}, 
	"arch_angeling_hat": {"name": "Arch Angeling Hat", "slot": "top", "view": "hat_c_arch_angeling_hat", "rarity": "epic"}, 
	"unicorn_helm": {"name": "Unicorn Helm", "slot": "top", "view": "hat_c_unicorn_helm", "rarity": "epic"}, 
	"angel_helm": {"name": "Angel Helm", "slot": "top", "view": "hat_c_angel_helm", "rarity": "epic"}, 
	"mini_baphomet": {"name": "Mini Baphomet", "slot": "top", "view": "hat_c_mini_baphomet", "rarity": "epic"}, 
	"vanargand_helm": {"name": "Vanargand Helm", "slot": "top", "view": "hat_c_vanargand_helm", "rarity": "legendary"}, 
	"dragon_skull": {"name": "Dragon Skull", "slot": "top", "view": "hat_c_dragon_skull", "rarity": "legendary"}, 
	"demon_king_helm": {"name": "Demon King's Bone Helm", "slot": "top", "view": "hat_c_demon_king_helm", "rarity": "legendary"}, 
	"jewel_crown": {"name": "Jewel Crown", "slot": "top", "view": "hat_c_jewel_crown", "rarity": "epic"}, 
	"kriemhild_crown": {"name": "Kriemhild's Crown", "slot": "top", "view": "hat_c_kriemhild_crown", "rarity": "legendary"}, 
	"mermaid_headphones": {"name": "Mermaid Headphones", "slot": "mid", "view": "hat_c_mermaid_headphones", "rarity": "rare"}, 
	"robo_eye": {"name": "Robo Eye", "slot": "mid", "view": "hat_c_robo_eye", "rarity": "rare"}, 
	"poring_sunglasses": {"name": "Poring Sunglasses", "slot": "mid", "view": "hat_c_poring_sunglasses", "rarity": "rare"}, 
	"little_aquarium": {"name": "Little Aquarium", "slot": "mid", "view": "hat_c_little_aquarium", "rarity": "epic"}, 
	"vampire_familiar": {"name": "Vampire Familiar", "slot": "mid", "view": "hat_c_vampire_familiar", "rarity": "epic"}, 
	"scout_drone": {"name": "Scout Drone", "slot": "mid", "view": "hat_c_scout_drone", "rarity": "epic"}, 
	"little_deviling": {"name": "Little Deviling", "slot": "mid", "view": "hat_c_little_deviling", "rarity": "epic"}, 

	"morroc_minions": {"name": "Morroc's Minions", "slot": "mid", "view": "hat_c_morroc_minions", "rarity": "legendary", "gacha": false}, 
	"clown_nose": {"name": "Clown Nose", "slot": "low", "view": "hat_c_clown_nose", "rarity": "common", "also": ["christmas"]}, 
	"lollipop": {"name": "Lollipop", "slot": "low", "view": "hat_c_lollipop", "rarity": "common"}, 
	"clover_in_mouth": {"name": "Four Leaf Clover", "slot": "low", "view": "hat_c_clover_in_mouth", "rarity": "common"}, 
	"crimson_rose": {"name": "Crimson Rose", "slot": "low", "view": "hat_c_crimson_rose", "rarity": "rare"}, 
	"jack_castle_bat": {"name": "Jack Castle Bat", "slot": "low", "view": "hat_c_jack_castle_bat", "rarity": "rare"}, 
	"flying_galapago": {"name": "Flying Galapago", "slot": "low", "view": "hat_c_flying_galapago", "rarity": "rare"}, 
	"happy_parrot": {"name": "Happy Parrot", "slot": "low", "view": "hat_c_happy_parrot", "rarity": "rare"}, 
	"warg_in_mouth": {"name": "Warg in Mouth", "slot": "low", "view": "hat_c_warg_in_mouth", "rarity": "epic"}, 
	"spirit_aura": {"name": "Spirit Aura", "slot": "low", "view": "hat_c_spirit_aura", "rarity": "epic"}, 
	"floating_ice": {"name": "Floating Ice", "slot": "low", "view": "hat_c_floating_ice", "rarity": "epic", "also": ["christmas"]}, 
	"ifrit_breath": {"name": "Ifrit's Breath", "slot": "low", "view": "hat_c_ifrit_breath", "rarity": "epic"}, 
	"balloon_wings": {"name": "Balloon Wings", "slot": "back", "view": "c_balloon_wings", "rarity": "common"}, 
	"teddy_bear_bag": {"name": "Teddy Bear Bag", "slot": "back", "view": "c_teddy_bear_bag", "rarity": "common"}, 
	"poring_basket": {"name": "Poring Basket", "slot": "back", "view": "c_poring_basket", "rarity": "common"}, 
	"ribbon_bell": {"name": "Ribbon Bell", "slot": "back", "view": "c_ribbon_bell", "rarity": "common"}, 
	"giant_cat_bag": {"name": "Giant Cat Bag", "slot": "back", "view": "c_giant_cat_bag", "rarity": "rare"}, 
	"black_cat_bag": {"name": "Black Cat Bag", "slot": "back", "view": "c_black_cat_bag", "rarity": "rare"}, 
	"deviruchi_bag": {"name": "Deviruchi Bag", "slot": "back", "view": "c_deviruchi_bag", "rarity": "rare"}, 
	"halloween_poring_bag": {"name": "Halloween Poring Bag", "slot": "back", "view": "c_halloween_poring_bag", "rarity": "rare"}, 
	"big_fox_tail": {"name": "Big Fox Tail", "slot": "back", "view": "c_big_fox_tail", "rarity": "rare"}, 
	"sakura_wings": {"name": "Sakura Wings", "slot": "back", "view": "c_sakura_wings", "rarity": "rare"}, 
	"giant_shark": {"name": "Giant Shark", "slot": "back", "view": "c_giant_shark", "rarity": "rare"}, 
	"white_rabbit_bag": {"name": "White Rabbit Bag", "slot": "back", "view": "c_white_rabbit_bag", "rarity": "rare"}, 
	"pink_butterfly_wings": {"name": "Pink Butterfly Wings", "slot": "back", "view": "c_pink_butterfly_wings", "rarity": "epic"}, 
	"gold_butterfly_wings": {"name": "Golden Butterfly Wings", "slot": "back", "view": "c_gold_butterfly_wings", "rarity": "epic"}, 
	"ice_wings": {"name": "Ice Wings", "slot": "back", "view": "c_ice_wings", "rarity": "epic"}, 
	"evil_scythe": {"name": "Evil Scythe", "slot": "back", "view": "c_evil_scythe", "rarity": "epic"}, 
	"spider_legs": {"name": "Spider Legs", "slot": "back", "view": "c_spider_legs", "rarity": "epic"}, 
	"thanatos_sword": {"name": "Thanatos Sword", "slot": "back", "view": "c_thanatos_sword", "rarity": "legendary"}, 
	"gabriel_wings": {"name": "Wings of Gabriel", "slot": "back", "view": "c_gabriel_wings", "rarity": "legendary"}, 
	"valkyrie_wings": {"name": "Valkyrie Wings", "slot": "back", "view": "c_valkyrie_wings", "rarity": "legendary"}, 
	"great_devil_wings": {"name": "Great Devil Wings", "slot": "back", "view": "c_great_devil_wings", "rarity": "legendary"}, 
	"lucifer_wings": {"name": "Wings of Lucifer", "slot": "back", "view": "c_lucifer_wings", "rarity": "legendary"}, 

	"golden_halo": {"name": "Golden Halo", "slot": "top", "view": "hat_c_golden_halo", "rarity": "rare"}, 
	"spirit_halo": {"name": "Spirit Halo", "slot": "top", "view": "hat_c_spirit_halo", "rarity": "epic"}, 
	"celestial_circle": {"name": "Celestial Circle", "slot": "top", "view": "hat_c_celestial_circle", "rarity": "epic"}, 
	"spell_circuit": {"name": "Aesir Spell Circle", "slot": "top", "view": "hat_c_spell_circuit", "rarity": "legendary"}, 
	"crimson_aura": {"name": "Crimson Spirit Aura", "slot": "low", "view": "hat_c_crimson_aura", "rarity": "legendary"}, 
	"violet_halo": {"name": "Violet Halo", "slot": "back", "view": "c_violet_halo", "rarity": "legendary"}, 
	"crescent_moon_glow": {"name": "Crescent Moon Glow", "slot": "back", "view": "c_crescent_moon_glow", "rarity": "epic"}, 
	"butterfly_wing_ears": {"name": "Butterfly Wing Ears", "slot": "mid", "view": "hat_c_butterfly_wing_ears", "rarity": "rare"}, 
	"reginleif_wings": {"name": "Reginleif's Wing Ears", "slot": "mid", "view": "hat_c_reginleif_wings", "rarity": "epic"}, 
	"ice_wing_ears": {"name": "Ice Wing Ears", "slot": "mid", "view": "hat_c_ice_wing_ears", "rarity": "rare", "also": ["christmas"]}, 
	"bragi_wing_ears": {"name": "Bragi's Wing Ears", "slot": "mid", "view": "hat_c_bragi_wing_ears", "rarity": "epic"}, 
	"darkness_eyes": {"name": "Beholder's Eye", "slot": "mid", "view": "hat_c_darkness_eyes", "rarity": "rare"}, 
	"balor_evil_eye": {"name": "Balor's Evil Eye", "slot": "mid", "view": "hat_c_balor_evil_eye", "rarity": "epic"}, 
	"falling_leaves": {"name": "Falling Leaves", "slot": "mid", "view": "hat_c_falling_leaves", "rarity": "rare"}, 
	"chatty_crow": {"name": "Chatty Crow", "slot": "mid", "view": "hat_c_chatty_crow", "rarity": "rare"}, 
	"devil_whisper": {"name": "Devil's Whisper", "slot": "mid", "view": "hat_c_devil_whisper", "rarity": "rare"}, 
	"winged_glasses": {"name": "Winged Glasses", "slot": "mid", "view": "hat_c_winged_glasses", "rarity": "common"}, 
	"smart_glasses": {"name": "Smart Glasses", "slot": "mid", "view": "hat_c_smart_glasses", "rarity": "common"}, 
	"black_frame_glasses": {"name": "Black Frame Glasses", "slot": "mid", "view": "hat_c_black_frame_glasses", "rarity": "common"}, 
	"blue_rose": {"name": "Blue Rose", "slot": "low", "view": "hat_c_blue_rose", "rarity": "rare"}, 
	"sakura_branch": {"name": "Cherry Blossom Branch", "slot": "low", "view": "hat_c_sakura_branch", "rarity": "common"}, 
	"fan_in_mouth": {"name": "Fan in Mouth", "slot": "low", "view": "hat_c_fan_in_mouth", "rarity": "common"}, 
	"pencil_in_mouth": {"name": "Pencil in Mouth", "slot": "low", "view": "hat_c_pencil_in_mouth", "rarity": "common"}, 
	"syringe_in_mouth": {"name": "Syringe in Mouth", "slot": "low", "view": "hat_c_syringe_in_mouth", "rarity": "common"}, 
	"lantern_in_mouth": {"name": "Fairy Lantern", "slot": "low", "view": "hat_c_lantern_in_mouth", "rarity": "rare"}, 
	"wind_god_fan": {"name": "Wind God's Fan", "slot": "low", "view": "hat_c_wind_god_fan", "rarity": "epic"}, 
	"ribbon_muffler": {"name": "Big Ribbon Muffler", "slot": "low", "view": "hat_c_ribbon_muffler", "rarity": "rare"}, 
	"flaming_muffler": {"name": "Flaming Muffler", "slot": "low", "view": "hat_c_flaming_muffler", "rarity": "epic"}, 
	"sealing_scroll": {"name": "Sealing Scroll", "slot": "low", "view": "hat_c_sealing_scroll", "rarity": "rare"}, 
	"survival_orbs": {"name": "Survival Orbs", "slot": "low", "view": "hat_c_survival_orbs", "rarity": "epic"}, 
	"dung_hat": {"name": "Dung Hat", "slot": "top", "view": "hat_c_dung_hat", "rarity": "common"}, 
	"roof_hat": {"name": "Roof Hat", "slot": "top", "view": "hat_c_roof_hat", "rarity": "common"}, 
	"paradise_birdcage": {"name": "Paradise Birdcage", "slot": "top", "view": "hat_c_paradise_birdcage", "rarity": "epic"}, 
	"poring_rider": {"name": "Wild Poring Rider", "slot": "top", "view": "hat_c_poring_rider", "rarity": "epic"}, 
	"piggyback_kid": {"name": "Piggyback Kid", "slot": "top", "view": "hat_c_piggyback_kid", "rarity": "rare"}, 



	"outfit_wedding": {"name": "Wedding Outfit", "slot": "body", "view": "outfit_wedding", "rarity": "unique"}, 
	"outfit_tuxedo": {"name": "Tuxedo", "slot": "body", "view": "outfit_tuxedo", "rarity": "unique"}, 
	"outfit_summer": {"name": "Summer Outfit", "slot": "body", "view": "outfit_summer", "rarity": "unique"}, 
	"outfit_beach": {"name": "Beach Outfit", "slot": "body", "view": "outfit_beach", "rarity": "unique"}, 
	"outfit_hanbok": {"name": "Hanbok", "slot": "body", "view": "outfit_hanbok", "rarity": "unique"}, 
	"outfit_oktoberfest": {"name": "Oktoberfest Outfit", "slot": "body", "view": "outfit_oktoberfest", "rarity": "unique"}, 
	"outfit_santa": {"name": "Santa Outfit", "slot": "body", "view": "outfit_santa", "rarity": "unique", "gacha": false, "event": "christmas"}, 




	"rudolph_santa_hat": {"name": "Rudolph Santa Hat", "slot": "top", "view": "hat_c_rudolph_santa_hat", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"twin_santa_hat": {"name": "Twin Pompom Santa Hat", "slot": "top", "view": "hat_c_twin_santa_hat", "rarity": "common", "gacha": false, "event": "christmas"}, 
	"blue_twin_santa_hat": {"name": "Blue Twin Pompom Santa Hat", "slot": "top", "view": "hat_c_blue_twin_santa_hat", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"santa_doll_band": {"name": "Santa Doll Hairband", "slot": "top", "view": "hat_c_santa_doll_band", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"shining_santa_poring": {"name": "Shining Santa Poring", "slot": "top", "view": "hat_c_shining_santa_poring", "rarity": "epic", "gacha": false, "event": "christmas"}, 
	"santa_cat_hat": {"name": "Santa Cat Hat", "slot": "top", "view": "hat_c_santa_cat_hat", "rarity": "epic", "gacha": false, "event": "christmas"}, 
	"xmas_polar_bear_hat": {"name": "Christmas Polar Bear Hat", "slot": "top", "view": "hat_c_xmas_polar_bear_hat", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"xmas_wreath": {"name": "Christmas Wreath", "slot": "top", "view": "hat_c_xmas_wreath", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"bell_ribbon": {"name": "Bell Ribbon", "slot": "top", "view": "hat_c_bell_ribbon", "rarity": "common", "gacha": false, "event": "christmas"}, 
	"santa_beard": {"name": "Santa Beard", "slot": "low", "view": "hat_c_santa_beard", "rarity": "common", "gacha": false, "event": "christmas"}, 
	"candy_cane_mouth": {"name": "Candy Cane in Mouth", "slot": "low", "view": "hat_c_candy_cane_mouth", "rarity": "common", "gacha": false, "event": "christmas"}, 
	"santa_poring_balloon": {"name": "Santa Poring Balloon", "slot": "low", "view": "hat_c_santa_poring_balloon", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"xmas_angeling_balloon": {"name": "Christmas Angeling Balloon", "slot": "low", "view": "hat_c_xmas_angeling_balloon", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"xmas_poring_balloon": {"name": "Christmas Poring Balloon", "slot": "low", "view": "hat_c_xmas_poring_balloon", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"santa_bag": {"name": "Santa's Bag", "slot": "back", "view": "c_santa_bag", "rarity": "epic", "gacha": false, "event": "christmas"}, 
	"santa_teddy_bear": {"name": "Santa Teddy Bear", "slot": "back", "view": "c_santa_teddy_bear", "rarity": "legendary", "gacha": false, "event": "christmas"}, 


	"antonio_bag": {"name": "Antonio's Bag", "slot": "back", "view": "c_antonio_bag", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"let_it_snow": {"name": "Let It Snow", "slot": "top", "view": "hat_c_let_it_snow", "rarity": "legendary", "gacha": false, "event": "christmas"}, 
	"snowflake_tiara": {"name": "Snowflake Tiara", "slot": "top", "view": "hat_c_snowflake_tiara", "rarity": "epic", "gacha": false, "event": "christmas"}, 
	"polar_bear_hood": {"name": "Polar Bear Hood", "slot": "top", "view": "hat_c_polar_bear_hood", "rarity": "epic", "gacha": false, "event": "christmas"}, 
	"snow_rabbit_wig": {"name": "Snow Rabbit Wig", "slot": "top", "view": "hat_c_snow_rabbit_wig", "rarity": "epic", "gacha": false, "event": "christmas"}, 
	"snow_head": {"name": "Snowball Head", "slot": "top", "view": "hat_c_snow_head", "rarity": "epic", "gacha": false, "event": "christmas"}, 
	"crushed_snowman": {"name": "Crushed Snowman", "slot": "top", "view": "hat_c_crushed_snowman", "rarity": "epic", "gacha": false, "event": "christmas"}, 
	"snow_fox": {"name": "Snow Fox", "slot": "mid", "view": "hat_c_snow_fox", "rarity": "epic", "gacha": false, "event": "christmas"}, 
	"snow_rabbit_knit": {"name": "Snow Rabbit Knit Hat", "slot": "top", "view": "hat_c_snow_rabbit_knit", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"angeling_knit_hat": {"name": "Angeling Knit Hat", "slot": "top", "view": "hat_c_angeling_knit_hat", "rarity": "rare", "gacha": false, "event": "christmas"}, 
	"winter_hat": {"name": "Winter Hat", "slot": "top", "view": "hat_c_winter_hat", "rarity": "common", "gacha": false, "event": "christmas"}, 
	"fur_hat": {"name": "Fur Hat", "slot": "top", "view": "hat_c_fur_hat", "rarity": "common", "gacha": false, "event": "christmas"}, 
	"blue_fur_hat": {"name": "Blue Fur Hat", "slot": "top", "view": "hat_c_blue_fur_hat", "rarity": "common", "gacha": false, "event": "christmas"}, 
	"pink_fur_hat": {"name": "Pink Fur Hat", "slot": "top", "view": "hat_c_pink_fur_hat", "rarity": "common", "gacha": false, "event": "christmas"}, 
}



const MVP_PET_LEVEL_DMG: = 0.06
const MVP_PET_DMG: = 1.6
const MVP_PET_SCALE: = 0.6




const PET_MARK_TIME: = 6.0
const PET_FRAIL_TIME: = 5.0
const PET_COIN_CHANCE: = 0.6
const PET_DOT_POISON_TIME: = 5.0
const PET_ECHO_TYPES: = ["aoe_target", "projectile", "aoe_self", "bolt", "line", "radial", "jupitel", "sightrasher", "ground", "melee_arc", "soul_strike"]


const PET_POWERS: = {
	"pet_moonlight": {"name": "Increase AGI de Moonlight Flower", "mods": {"aspd": 0.25, "move": 0.2}, "color": Color(1.0, 0.75, 0.85), "icon_skill": "increase_agi"}, 
	"pet_war_cry": {"name": "Grito de guerra de Orc Hero", "mods": {"dmg": 0.2}, "color": Color(1.0, 0.55, 0.3), "icon_skill": "provoke"}, 
}





const TOWN_PROPS: = [

	{"npc": "refiner", "model": "anvil_02", "cell": Vector2(146.3, 189.9), "h": 1.3, "rot": 70.0}, 
	{"npc": "refiner", "model": "orc_brazier", "cell": Vector2(141.4, 191.3), "h": 2.3, "rot": 0.0, "fire": true}, 
	{"npc": "refiner", "model": "weapon_rack_2", "cell": Vector2(143.0, 193.0), "h": 2.7, "rot": 25.0}, 
	{"npc": "refiner", "model": "armor_02", "cell": Vector2(146.2, 192.5), "h": 2.3, "rot": 35.0}, 
	{"npc": "refiner", "model": "tong_01", "cell": Vector2(140.6, 189.5), "h": 1.6, "rot": 30.0}, 
	{"npc": "refiner", "model": "barrel_s_01", "cell": Vector2(140.2, 192.5), "h": 1.5, "rot": 0.0}, 
	{"npc": "refiner", "model": "woodbox_01", "cell": Vector2(147.6, 191.3), "h": 1.1, "rot": 10.0}, 


	{"npc": "socket", "model": "table_01", "cell": Vector2(165.7, 189.9), "h": 1.1, "rot": -70.0}, 
	{"npc": "socket", "model": "cupboard_j", "cell": Vector2(170.6, 192.1), "h": 1.6, "rot": -20.0}, 
	{"npc": "socket", "model": "shelf_02", "cell": Vector2(168.6, 193.1), "h": 2.0, "rot": -10.0}, 
	{"npc": "socket", "model": "desk_h_02", "cell": Vector2(165.6, 192.5), "h": 1.2, "rot": -35.0}, 
	{"npc": "socket", "model": "storage_s_01", "cell": Vector2(171.6, 189.7), "h": 1.8, "rot": -30.0}, 
	{"npc": "socket", "model": "woodbox_s_01", "cell": Vector2(164.4, 191.3), "h": 0.9, "rot": -10.0}, 
	{"npc": "socket", "model": "stand_h_01", "cell": Vector2(172.0, 191.7), "h": 1.7, "rot": 0.0, "lamp": true}, 
]



const ENDLESS_EVERY: = 40.0
const ENDLESS_MVP_EVERY: = 4



const ENDLESS_SPEED_STEP: = 0.05
const ENDLESS_HP_GROWTH: = 1.24
const ENDLESS_DMG_GROWTH: = 1.14

const ENDLESS_MOB_SPEED_STEP: = 0.09
const ENDLESS_MOB_HP_GROWTH: = 1.36
const ENDLESS_MOB_DMG_GROWTH: = 1.22

const ENDLESS_RATE_STEP: = 0.1


const ENDLESS_MVP_GROWTH: = 1.3

const ENDLESS_MVP_LATER_HP: = 0.5

const MVP_RAID_HP: = 1.3

const RAID_HP_BASE: = 6.75


const RAID_TANK: = 45.0













const FOCUS_CAP: = 3.0
const FOCUS_GAP: = 0.5
const FOCUS_MIN_S: = 10.0

const RAID_FLAT_STEP: = 1.2
const MVP_RAID_DMG: = 1.15

const AREA_MAX: = 2.5


const DURATION_MAX: = 1.5



const ZONE_FX_FULL: = 6
const ZONE_FX_TILES: = 12
const ZONE_FX_MAX: = 20


const SEP_BACK_CUT: = 0.85
const SEP_MAX_SHARE: = 1.2



const RANGED_MISS_WALK: = 2

const RAID_ENRAGE_DMG: = 1.2
const ENDLESS_MIX_EVERY: = 1.1






const SPAWN_FAIR_FPS: = 60.0
const SPAWN_CATCHUP_MAX: = 3.0
const SPAWN_DEBT_MAX: = 3.0




const SCHED_BUDGET_MS: = 7.0
const SCHED_LATE_MAX: = 0.25


const FAST_PACE: = 2.0



const DEAD_BRANCH_CHANCE: = 0.0025
const BLOODY_BRANCH_CHANCE: = 0.0003
const ELITE_BLOODY_CHANCE: = 0.12
const DEAD_BRANCH_COUNT: = 12
const BLOODY_BOSSES: = ["angeling", "vagabond_wolf", "bloody_knight"]





const ARROWS: = {
	"arrow": {"name": "Arrow", "element": "neutral"}, 
	"fire_arrow": {"name": "Fire Arrow", "element": "fire"}, 
	"silver_arrow": {"name": "Silver Arrow", "element": "holy"}, 
	"crystal_arrow": {"name": "Crystal Arrow", "element": "water"}, 
	"wind_arrow": {"name": "Arrow of Wind", "element": "wind"}, 
	"stone_arrow": {"name": "Stone Arrow", "element": "earth"}, 
	"immaterial_arrow": {"name": "Immaterial Arrow", "element": "ghost"}, 
	"rusty_arrow": {"name": "Rusty Arrow", "element": "poison"}, 
	"shadow_arrow": {"name": "Shadow Arrow", "element": "shadow"}, 




	"sharp_arrow": {"name": "Sharp Arrow", "element": "neutral", "dot": "bleed"}, 
	"poison_arrow": {"name": "Poison Arrow", "element": "neutral", "dot": "poison"}, 
	"flaming_arrow": {"name": "Flaming Arrow", "element": "neutral", "dot": "burn"}, 
}

const BULLETS: = {
	"bullet": {"name": "Bullet", "element": "neutral"}, 
	"blaze_bullet": {"name": "Blaze Bullet", "element": "fire"}, 
	"purification_bullet": {"name": "Purification Bullet", "element": "holy"}, 
	"freezing_bullet": {"name": "Freezing Bullet", "element": "water"}, 
	"lightning_bullet": {"name": "Lightning Bullet", "element": "wind"}, 
	"magic_stone_bullet": {"name": "Magic Stone Bullet", "element": "earth"}, 
	"poison_sphere": {"name": "Poison Sphere", "element": "poison"}, 
	"blind_sphere": {"name": "Blind Sphere", "element": "shadow"}, 
	"bloody_shell": {"name": "Bloody Shell", "element": "neutral", "dot": "bleed"}, 
	"poison_bullet": {"name": "Poison Bullet", "element": "neutral", "dot": "poison"}, 
	"flare_sphere": {"name": "Flare Sphere", "element": "neutral", "dot": "burn"}, 
}

const KUNAI: = {
	"shuriken": {"name": "Shuriken", "element": "neutral"}, 
	"heat_wave_kunai": {"name": "Heat Wave Kunai", "element": "fire"}, 
	"icicle_kunai": {"name": "Icicle Kunai", "element": "water"}, 
	"high_wind_kunai": {"name": "High Wind Kunai", "element": "wind"}, 
	"black_earth_kunai": {"name": "Black Earth Kunai", "element": "earth"}, 
	"fell_poison_kunai": {"name": "Fell Poison Kunai", "element": "poison"}, 
	"thorn_needle_shuriken": {"name": "Thorn Needle Shuriken", "element": "neutral", "dot": "bleed"}, 
	"rusty_shuriken": {"name": "Rusty Shuriken", "element": "neutral", "dot": "poison"}, 
	"bomb_kunai": {"name": "Explosive Kunai", "element": "neutral", "dot": "burn"}, 
}






const AMMO_DOT: = {"bleed": 0.2, "burn": 0.25, "poison": 0.3}

const AMMO_POISON: = 0.03


const AMMO_DOT_NAMES: = {"bleed": "Sangrado", "burn": "Quemadura", "poison": "Veneno"}




func ammo_kind(a: Dictionary) -> String:
	var s: = TranslationServer.translate(str(ELEMENT_NAMES[str(a.get("element", "neutral"))]))
	var dot: = str(a.get("dot", ""))
	if dot != "":
		s += " · " + TranslationServer.translate(str(AMMO_DOT_NAMES[dot]))
	return s

const AMMO: = {"arrows": ARROWS, "bullets": BULLETS, "kunai": KUNAI}
const AMMO_NAMES: = {"arrows": "Carcaj", "bullets": "Balas", "kunai": "Kunai"}


const CHEST_ARROW_CHANCE: = 0.45


const MIN_ELEMENT_MULT: = 0.1



const POISON_DPS: = 0.3










const POISON_MAX_STACKS: = 40
const POISON_GROWTH: = 1.066


const POISON_GROW_MAX: = 12.0
const POISON_GROW_PER_CAP: = 0.5





const POISON_BURST_GROW_MAX: = 4.0
const POISON_CORRODE: = 0.01
const POISON_SPILL_RANGE: = 3.5
const POISON_SPILL_MAX: = 2



const POISON_JUMP_RANGE: = 4.5
const POISON_PASS: = 0.5







const POISON_FLAT: = 4.0


const POISON_BURST_FLAT: = 2.0


const POISON_HIT_TIME: = 6.0


const CHAIN_CUT_MAX: = 0.35




const POISON_FUME_AT: = 8

















const BURN_IGNITE: = 1.0


const BURN_ONCE: = 2.4
const BURN_MAGIC: = 0.6
const BURN_HEAT: = 0.03





const BURN_HEAT_EVERY: = 0.1
const BURN_HEAT_EVERY_PER: = 0.01



const BURN_HEAT_PUSH: = 0.25
const BURN_HEAT_HASTE: = 3.0
const WEB_HEAT_EVERY: = 0.5
const BURN_PASS: = 0.5
const BURN_TIME: = 4.0
const BURN_JUMPS: = 4
const BURN_JUMP_RANGE: = 4.5



const BURN_CROWD: = 0.04
const BURN_CROWD_MAX: = 2.0
const BURN_SPREAD_EVERY: = 0.25
const BURN_SPREAD_N: = 6
const BURN_SPREAD_RANGE: = 2.5
const BURN_BLAST: = 3.0
const BURN_BLAST_RANGE: = 2.5
const BURN_COLOR: = Color(1.0, 0.55, 0.15)

const BURN_EMBER: = 0.22







const BLEED_STORE: = 0.45
const BLEED_BURST_AT: = 5
const BLEED_BURST_MULT: = 2.0
const BLEED_TIME: = 4.0
const BLEED_SPLASH: = 0.5
const BLEED_SPLASH_RANGE: = 2.4
const BLEED_COLOR: = Color(1.0, 0.22, 0.22)

const BLEED_CHAIN_SHARE: = 0.25


const COUNTER_DMG: = 2.0
const HINDSIGHT_SKILLS: = ["fire_bolt", "cold_bolt", "soul_strike", "heavens_drive", "earth_spike", "frost_diver"]

const HINDSIGHT_CD: = 0.25


const SAGE_DOUBLE_SKILLS: = ["fire_bolt", "cold_bolt", "frost_diver", "earth_spike", "heavens_drive", "thunder_storm", "spider_web"]


const SAGE_DOUBLE_PROF: = 2.0



const DRAGON_HASTE_DMG: = 1.0



const ZONE_MERGE_TIME: = 1.0
const ZONE_MERGE_DIST: = 0.4


const WEB_FIRE: = 2.0
const WEB_FIRE_TIME: = 6.0
const WEB_ELEMENTS: = ["fire", "water", "earth", "wind"]
const COMBO_GAP: = 0.25






const TOGGLE_SKILLS: = ["flying_kick", "asura_strike", "back_stab", "shadow_slash", "charge_attack"]
const HOLD_SKILLS: = []
const STILL_SKILLS: = ["heat_barrel"]

const BLINK_GAP: = 0.11



const BACKSTAB_X_GROWTH: = 1.3
const BACKSTAB_X_CRIT: = 0.1
const BACKSTAB_X_CRIT_DMG: = 1.12



const STANCE_BEAT: = 0.16
const STANCE_REST: = 0.15

const UNION_DRAIN: = 0.012


const KAIZEL_HP: = 0.4
const KAAHI_CD: = 1.0


const SOUL_SPIRITS: = ["knight", "wizard", "priest", "hunter", "assassin", "monk", "crusader", "sage", "rogue", 
	"blacksmith", "alchemist", "bard", "star"]
const SOUL_LINK_RANGE: = 8.0


const SOUL_BOND_MAX: = 10


const SOUL_SPIRIT_DIM: = 0.6
const SOUL_BOND_DMG: = 0.03

const KAAHI_PARTY: = 1.0

const SHRINK_SIZE: = 0.55

const SOUL_SPIRIT_CASTS: = {"knight": "bowling_bash", "wizard": "storm_gust", "priest": "magnus_exorcismus", "hunter": "arrow_shower", 
	"assassin": "sonic_blow", "monk": "investigate", "crusader": "grand_cross", "sage": "heavens_drive", "rogue": "raid", 
	"blacksmith": "hammer_fall", "alchemist": "acid_terror", "bard": "musical_strike", "star": "meteor_storm"}
const SOUL_SPIRIT_BODIES: = {"star": "star_gladiator"}

const COMBO_REACH: = 4.0













const COMBO_CHARGE_MAX: = 30
const COMBO_CHARGE_KEEP: = 2.5
const COMBO_CHARGE_DMG: = 0.04
const COMBO_CRUSH_AT: = 12
const COMBO_CRUSH_PER: = 0.08
const COMBO_CRUSH_AREA: = 0.015
const RAGING_LINE: = 4.5
const RAGING_LINE_WIDTH: = 1.2
const RAGING_LINE_SHARE: = 0.6
const COMBO_ASPD_START: = 0.5



const COMBO_SWING_POW: = 0.7




const SATAN_LEGEND_CHANCE: = 0.06


const VALKYRIE_LEGEND_CHANCE: = 0.017
const AUTO_BLITZ_LUK: = 0.005
const COIN_DMG: = 0.02



const BLITZ_GAP: = 0.35






const BLITZ_SAVED_MAX: = 16
const FALCONS_MAX: = 2







const AMP_AREA_MAX: = 2.0
const AMP_OVERFLOW_DMG: = 1.0



const HOMUN_PER_LEVEL: = 0.25


const TRAINING_STAGE: = "prontera"
const TRAINING_DUMMY_HP: = 1e+15
const TRAINING_GROUP: = 20


const AOE_FX_MAX: = 1.4








const COMBO_JOBS: = ["wizard", "high_wizard"]



const COMBO_ELEMENTS: = ["fire", "water", "wind", "earth"]
const COMBO_LAVA: = 1.1
const COMBO_SIDE: = 0.8
const COMBO_MUD_SLOW: = 2.5
const COMBO_SAND_BLIND: = 3.0
const COMBO_MARK_TIME: = 4.0




const COMBO_MULT: = 1.35
const COMBO_AREA: = 2.4
const COMBO_SPREAD: = 2.6
const COMBO_CHAIN: = 4
const COMBO_CHAIN_RANGE: = 4.5
const COMBO_CAP: = 10





const SOUL_COMBO_MULT: = 0.6
const SOUL_COMBO_GAP: = 0.5
const SOUL_POSSESS_TIME: = 3.0
const SOUL_POSSESS_DMG: = 0.25


const SOUL_COMBO_KIND: = {"fire": "blaze", "water": "vapor", "wind": "conduct", "earth": "mud"}




const KUNAI_JOBS: = ["kagerou"]
const KUNAI_MAX: = 6
const KUNAI_TIME: = 6.0
const CHARM_MAX: = 3
const CHARM_DMG: = 0.1
const CHARM_TRIPLE: = 1.6









const FORGE_JOBS: = ["blacksmith", "whitesmith"]
const FORGE_HEAT_BASIC: = 0.09
const FORGE_HEAT_SKILL: = 0.06
const FORGE_HIT_GAP: = 0.12
const FORGE_HEAT_GROWTH: = 0.08
const FORGE_BREAK: = 0.06
const FORGE_BREAK_WS: = 0.045
const FORGE_MAX: = 15
const FORGE_MAX_WS: = 20
const FORGE_SKILL: = 0.03
const FORGE_BLAST: = 3.0
const FORGE_BLAST_PER: = 0.8
const FORGE_BLAST_AREA: = 3.0



const FORGE_TEMP_FULL: = 5.0





const TEMPER_TIME: = 20.0
const TEMPER_ELEMENTS: = ["fire", "water", "wind", "earth"]
const TEMPER_RANGE: = 16.0
const TEMPER_BOSS: = 12.0
const TEMPER_ELITE: = 3.0



const AT_HEAT_AREA: = 0.4
const AT_HEAT_PACE: = 1.0
const AT_HEAT_HITS: = 2




const MPT_MIN: = 3.0
const MPT_PER: = 0.125
const MPT_CAP: = 8.0
const MPT_TIME: = 15.0
const MPT_BREAK: = 0.5






const MOLTEN_TIME: = 5.0
const MOLTEN_RADIUS: = 2.6
const MOLTEN_IGNITE: = 1.0
const MOLTEN_PER: = 0.15
const MOLTEN_STAGGER: = 2.0


const SMITH_REFINE_LUCK: = 0.15


const ORI_MATS: = 0.2



const ORI_CHANCE: = 0.05

const MELT_TIME: = 3.0



const MUTATION_POWER: = 0.3
const MUTATION_PACK: = 0.15
const MUTATION_AURA: = 1.5
const MUTATION_SPECIAL: = 7.0
const HOMUNCULI: = {






	"homun_lif": {"every": 2.2, "dmg": 0.5, "range": 8.0, "heal": 0.05, "heal_every": 4.0, "heal_range": 8.0, 
		"aura": {"regen": 1.0, "heal_power": 0.15}}, 


	"homun_amistr": {"every": 1.9, "dmg": 1.5, "range": 7.0, "area": 2.5, "knock": 4.0, "stun": 0.25, 
		"aura": {"armor": 3.0, "max_hp_pct": 0.08}}, 
	"homun_filir": {"every": 0.75, "dmg": 0.5, "range": 8.0, "hits": 3, 
		"aura": {"aspd": 0.12, "basic_dmg": 0.08}}, 
	"homun_vanilmirth": {"every": 1.6, "dmg": 1.1, "range": 9.0, "area": 3.0, "puddle": 2.5, 
		"aura": {"area": 0.1, "skill_dmg": 0.08}}, 
}




const ROGUE_JOBS: = ["rogue", "stalker"]



const COPY_JOBS: = ["rogue", "stalker", "assassin", "assassin_cross"]





const PARTY_BUFFS: = {"chemical_protection": 1.0, "blessing": 1.0, "increase_agi": 1.0, "angelus": 1.0, "magnificat": 1.0, 
	"poem_of_bragi": 1.0, "assassin_cross_sunset": 1.0, "adrenaline_rush": 0.66, "over_thrust": 0.5, "over_thrust_x": 0.5, "bunch_of_shrimp": 1.0, "bunch_of_shrimp_x": 1.0, "ninja_aura": 1.0, "ninja_aura_x": 1.0}
const PARTY_BUFF_RANGE: = 10.0









const SONG_PARTY_RANGE: = 6.0
const SONG_LINGER: = 3.0
const SONG_ORDER: = ["dissonance", "poem_of_bragi", "assassin_cross_sunset", "service_for_you", "scream"]
const SONG_AURAS: = {
	"dissonance": {"color": Color(0.8, 0.45, 1.0), "key": "mvp_hexa", "spin": -1.4, "notes": "melody_a", "glow": Color(0.55, 0.2, 0.85)}, 
	"poem_of_bragi": {"color": Color(0.55, 0.75, 1.0), "key": "mvp_rune", "spin": 0.5, "notes": "melody_b", "glow": Color(0.35, 0.5, 1.0)}, 
	"assassin_cross_sunset": {"color": Color(1.0, 0.62, 0.3), "key": "mvp_seal", "spin": 0.9, "notes": "melody_b", "glow": Color(1.0, 0.45, 0.15)}, 
	"service_for_you": {"color": Color(1.0, 0.55, 0.85), "key": "mvp_rune", "spin": -0.7, "notes": "melody_b", "glow": Color(0.95, 0.35, 0.7)}, 
	"scream": {"color": Color(0.7, 0.92, 1.0), "key": "mvp_seal", "spin": 1.6, "notes": "melody_a", "glow": Color(0.4, 0.7, 1.0)}, 
}
const BEAT_TIME: = 0.5
const BIS_EVERY: = 4
const BIS_TIME: = 0.5
const BIS_MULT: = 2.0

const CHORUS_DMG: = 0.3



const TAROT_CARDS: = {

	"hanged_man": {"name": "El Colgado", "w": 22.0, "color": Color(0.55, 0.85, 1.0), "say": "¡Congela a los que te rodean!", "glyph": "freeze"}, 
	"tower": {"name": "La Torre", "w": 22.0, "color": Color(1.0, 0.55, 0.3), "say": "¡Se derrumba sobre el más fuerte!", "glyph": "tower"}, 
	"temperance": {"name": "La Templanza", "w": 16.0, "color": Color(0.7, 1.0, 0.6), "say": "¡Confunde a los que te rodean!", "glyph": "swirl"}, 
	"devil": {"name": "El Diablo", "w": 20.0, "color": Color(0.85, 0.25, 0.45), "say": "¡Maldición: reciben más daño!", "glyph": "curse"}, 
	"sun": {"name": "El Sol", "w": 14.0, "color": Color(1.0, 0.88, 0.4), "say": "¡Más daño para tu grupo!", "glyph": "sun"}, 
	"wheel": {"name": "La Rueda de la Fortuna", "w": 6.0, "color": Color(0.95, 0.75, 1.0), "say": "¡Dos cartas más!", "glyph": "wheel"}, 
}
const TAROT_REACH: = 6.0
const TAROT_FREEZE: = 2.5
const TAROT_TOWER_DMG: = 5.0
const TAROT_TOWER_AREA: = 2.6
const TAROT_CONFUSE: = 4.0
const TAROT_DEVIL_DMG: = 2.0
const TAROT_DEVIL_FRAIL: = 0.3
const TAROT_DEVIL_TIME: = 6.0
const TAROT_SUN_TIME: = 6.0




const ENS_ORDER: = ["ens_eternal_chaos", "ens_nibelungen", "ens_drum", "ens_siegfried"]
const ENS_PAIR_RANGE: = 7.0
const ENS_RADIUS: = 6.0
const ENS_TIME: = 10.0
const ENS_GAP: = 3.0

const ENS_LOST: = 2.0


const ENS_CHAOS_DMG: = 0.4
const ENS_CHAOS_FILL: = 2.0

const ENS_NIBEL_SKILL: = 1.5


const ENS_DRUM_KILL: = 0.4
const ENS_DRUM_MAX: = 8.0

const ENS_SIEG_MECH: = 0.5



const LG_LYRE_CUT: = 1.0
const LG_LYRE_PROCS: = 2.0



const LG_WHIP_BIS: = 0.25
const LG_WHIP_AREA: = 2.2
const LG_WHIP_AREA_PER: = 0.6
const LG_WHIP_KNOCK: = 2.5
const PARTY_BUFF_GRACE: = 3.0
const PARTY_HEAL_SKILLS: = ["heal", "potion_pitcher", "tuna_belly", "tuna_belly_x"]
const PARTY_SHIELD_SKILLS: = ["kyrie_eleison", "assumptio", "tuna_party", "assumptio_x", "tuna_party_x", "kaite", "kaite_x"]

const SEA_WAVE_RADIUS: = 3.2
const PARTY_HEAL_RANGE: = 7.0


const COOP_REVIVE_HEALER: = 3.0
const COOP_REVIVE_HEALER_HP: = 0.5
const PLAGIARISM_ACTIVE: = 3
const PLAGIARISM_ANY: = 1

const PLAGIARISM_SWAPS: = {"cart_termination": "weapon_perfection", "sightrasher": "aura_blade", "charge_attack": "double_attack", "hammer_fall": "over_thrust", "earth_spike": "adrenaline_rush", "pressure": "auto_guard", "holy_cross": "reflect_shield", "spiral_pierce": "soul_drain", "lord_of_vermilion": "mystical_amplification", "cold_bolt": "hindsight", "heavens_drive": "enchant_poison", "thunder_storm": "magnificat", "acid_terror": "meltdown", "holy_light": "blessing", "brandish_spear": "edp", "bowling_bash": "gangster_paradise", "jupitel_thunder": "assassin_cross_sunset", "falcon_assault": "poem_of_bragi", "volcano": "faith", "freezing_spear": "chemical_protection", 

	"frost_diver": "double_casting"}



const PLAGIARISM: = {
	"vagabond_wolf": "increase_agi", "eddga": "magnum_break", "angeling": ["blessing", "heal"], "baphomet": "edp", 
	"bloody_knight": "gangster_paradise", "banshee_master": "double_casting", "fallen_bishop": "lex_aeterna", 
	"dullahan": "soul_drain", "beelzebub": "mystical_amplification", "dark_lord": "meteor_storm", 

	"orc_lord": "adrenaline_rush", "ork_hero": "over_thrust", "skeleton_general": "sonic_blow", 
	"moonlight": "fire_bolt", "golden_bug": ["envenom", "mammonite"], "strouf": "assassin_cross_sunset", "kraken": "storm_gust", 
	"turtle_champion": "reflect_shield", "turtle_general": "auto_guard", "ancient_mummy": ["venom_dust", "venom_splasher"], 
	"osiris": "sanctuary", "giant_spider": "spider_web", "maya": "enchant_poison", "golem": "stone_curse", 
	"mistress": "magnificat", "owl_duke": "poem_of_bragi", "owl_baron": "hindsight", "lord_of_death": ["grand_cross", "power_of_life"], 
	"archdam": "meltdown", "apocalips": "faith", 
	"garm": "chemical_protection", "knight_of_windstorm": ["double_attack", "bash"], "tha_odium": "gravitation_field", 
	"thanatos": "cross_slash", "harword": "weapon_perfection", "l_seyren": "aura_blade", 
	"lava_golem": ["endure", "endow_blaze"], "ifrit": "fire_wall", "beholder_master": "signum_crucis", "gloom": "soul_strike", 
	"furious_snowier": "quagmire", "ktullanux": "energy_coat", 
	"reginleif": "magnus_exorcismus", "randgris_fallen": "spear_boomerang", 
}
const COIN_CRIT: = 0.01



static func plagiarism_pairs() -> Array:
	var out: = []
	for boss in PLAGIARISM:
		var v = PLAGIARISM[boss]
		for sid in (v if v is Array else [v]):
			out.append([boss, str(sid)])
	return out



const MONSTERS: = {



	"item_emperium": {"name": "Emperium", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, "touch": 1.0, 
		"radius": 0.7, "color": Color(1.0, 0.86, 0.3), "size_px": 60, "static": true, "model": "altar_emperium", "model_h": 4.0}, 
	"training_dummy": {"name": "Muñeco de práctica", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.55, "color": Color(0.85, 0.7, 0.5), "size_px": 70, "static": true, "dummy": true}, 


	"training_dummy_mvp": {"name": "Muñeco MVP", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.7, "color": Color(1.0, 0.55, 0.75), "size_px": 90, "static": true, "dummy": true, "mvp": true, 
		"sprite_of": "training_dummy"}, 
	"poring": {"name": "Poring", "hp": 14.0, "speed": 1.9, "damage": 4.0, "xp": 1, 
		"radius": 0.35, "color": Color(1.0, 0.6, 0.72), "size_px": 34, "card": "poring_card"}, 

	"gold_poring": {"name": "Poring Dorado", "hp": 400.0, "speed": 3.5, "damage": 0.0, "xp": 20, 
		"radius": 0.42, "color": Color(1.0, 0.85, 0.3), "size_px": 38}, 
	"lunatic": {"name": "Lunatic", "hp": 20.0, "speed": 2.7, "damage": 5.0, "xp": 2, 
		"radius": 0.35, "color": Color(0.95, 0.95, 0.95), "size_px": 34, "card": "lunatic_card"}, 
	"fabre": {"name": "Fabre", "hp": 32.0, "speed": 1.6, "damage": 6.0, "xp": 2, 
		"radius": 0.35, "color": Color(0.55, 0.85, 0.35), "size_px": 30, "card": "fabre_card"}, 
	"willow": {"name": "Willow", "hp": 75.0, "speed": 1.5, "damage": 10.0, "xp": 5, 
		"radius": 0.5, "color": Color(0.55, 0.4, 0.25), "size_px": 60, "card": "willow_card"}, 

	"mastering": {"name": "Mastering", "hp": 420.0, "speed": 2.0, "damage": 10.0, "xp": 25, 
		"radius": 0.6, "color": Color(1.0, 0.55, 0.7), "size_px": 60, "card": "mastering_card", "elite": true}, 
	"eclipse": {"name": "Eclipse", "hp": 650.0, "speed": 2.9, "damage": 12.0, "xp": 30, 
		"radius": 0.5, "color": Color(0.95, 0.95, 1.0), "size_px": 50, "card": "eclipse_card", "elite": true}, 
	"elder_willow": {"name": "Elder Willow", "hp": 1000.0, "speed": 1.7, "damage": 18.0, "xp": 50, 
		"ranged": {"kind": "fire_bolt", "range": 8.0, "every": 3.2}, 
		"radius": 0.65, "color": Color(0.6, 0.35, 0.2), "size_px": 70, "card": "elder_willow_card", "elite": true}, 

	"spore": {"name": "Spore", "card": "spore_card", "hp": 15.0, "speed": 1.7, "damage": 5.0, "xp": 2, 
		"radius": 0.4, "color": Color(0.9, 0.55, 0.35), "size_px": 34}, 
	"poporing": {"name": "Poporing", "hp": 20.0, "speed": 2.0, "damage": 6.0, "xp": 2, 
		"radius": 0.38, "color": Color(0.6, 0.85, 0.4), "size_px": 34, "card": "poporing_card"}, 
	"smokie": {"name": "Smokie", "hp": 24.0, "speed": 3.0, "damage": 6.0, "xp": 3, 
		"radius": 0.38, "color": Color(0.6, 0.45, 0.3), "size_px": 36, "card": "smokie_card"}, 
	"wolf": {"name": "Wolf", "hp": 45.0, "speed": 3.3, "damage": 9.0, "xp": 4, 
		"radius": 0.45, "color": Color(0.6, 0.6, 0.65), "size_px": 44, "card": "wolf_card"}, 
	"bigfoot": {"name": "Bigfoot", "hp": 100.0, "speed": 1.6, "damage": 14.0, "xp": 8, 
		"radius": 0.6, "color": Color(0.5, 0.35, 0.25), "size_px": 64, "card": "bigfoot_card"}, 
	"vagabond_wolf": {"name": "Vagabond Wolf", "hp": 3000.0, "speed": 3.0, "damage": 20.0, "xp": 90, 
		"radius": 0.6, "color": Color(0.55, 0.55, 0.6), "size_px": 60, "card": "vagabond_wolf_card", 
		"boss": "summoner", "summon": "wolf", "heal": 0.0}, 
	"eddga": {"name": "Eddga", "hp": 16000.0, "speed": 2.6, "damage": 30.0, "xp": 0, 
		"radius": 1.0, "color": Color(0.9, 0.6, 0.2), "size_px": 110, "card": "eddga_card", 
		"boss": "mvp", "summon": ["wolf", "bigfoot"], "mvp": true}, 
	"angeling": {"name": "Angeling", "hp": 2200.0, "speed": 2.2, "damage": 14.0, "xp": 80, 
		"radius": 0.6, "color": Color(1.0, 0.9, 0.95), "size_px": 64, "card": "angeling_card", 
		"boss": "summoner", "summon": "poring", "heal": 0.04}, 
	"baphomet": {"name": "Baphomet", "hp": 12000.0, "speed": 2.4, "damage": 24.0, "xp": 0, 
		"radius": 1.0, "color": Color(0.35, 0.2, 0.3), "size_px": 110, "card": "baphomet_card", 
		"boss": "mvp", "summon": ["lunatic", "willow"], "mvp": true}, 

	"zombie": {"name": "Zombie", "hp": 30.0, "speed": 1.5, "damage": 7.0, "xp": 3, 
		"radius": 0.4, "color": Color(0.5, 0.6, 0.45), "size_px": 44, "card": "zombie_card"}, 
	"ghoul": {"name": "Ghoul", "hp": 50.0, "speed": 1.7, "damage": 10.0, "xp": 4, 
		"radius": 0.45, "color": Color(0.45, 0.5, 0.4), "size_px": 48, "card": "ghoul_card"}, 
	"whisper": {"name": "Whisper", "hp": 20.0, "speed": 3.1, "damage": 6.0, "xp": 3, 
		"radius": 0.38, "color": Color(0.9, 0.9, 1.0), "size_px": 40, "card": "whisper_card"}, 
	"skeleton": {"name": "Skeleton", "hp": 36.0, "speed": 2.0, "damage": 8.0, "xp": 4, 
		"radius": 0.4, "color": Color(0.9, 0.88, 0.8), "size_px": 46, "card": "skeleton_card"}, 
	"wraith": {"name": "Wraith", "hp": 70.0, "speed": 2.3, "damage": 12.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.4, 0.35, 0.5), "size_px": 56, "card": "wraith_card"}, 
	"evil_druid": {"name": "Evil Druid", "hp": 110.0, "speed": 1.7, "damage": 14.0, "xp": 9, 
		"radius": 0.55, "color": Color(0.35, 0.45, 0.3), "size_px": 60, "card": "evil_druid_card"}, 
	"raydric": {"name": "Raydric", "hp": 900.0, "speed": 2.4, "damage": 18.0, "xp": 30, 
		"radius": 0.6, "color": Color(0.3, 0.3, 0.4), "size_px": 64, "card": "raydric_card", "elite": true}, 
	"khalitzburg": {"name": "Khalitzburg", "hp": 1300.0, "speed": 2.1, "damage": 22.0, "xp": 40, 
		"radius": 0.65, "color": Color(0.85, 0.85, 0.8), "size_px": 70, "card": "khalitzburg_card", "elite": true}, 
	"bloody_knight": {"name": "Bloody Knight", "hp": 5000.0, "speed": 2.6, "damage": 26.0, "xp": 90, 
		"radius": 0.7, "color": Color(0.6, 0.1, 0.15), "size_px": 80, "card": "bloody_knight_card", 
		"boss": "summoner", "summon": "raydric", "heal": 0.0}, 

	"ragged_zombie": {"name": "Ragged Zombie", "hp": 42.0, "speed": 1.8, "damage": 9.0, "xp": 4, 
		"radius": 0.45, "color": Color(0.5, 0.45, 0.4), "size_px": 50, "card": "ragged_zombie_card"}, 
	"zombie_slaughter": {"name": "Zombie Slaughter", "hp": 72.0, "speed": 1.6, "damage": 13.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.45, 0.35, 0.35), "size_px": 60, "card": "zombie_slaughter_card"}, 
	"hell_poodle": {"name": "Hell Poodle", "hp": 30.0, "speed": 3.3, "damage": 8.0, "xp": 4, 
		"radius": 0.4, "color": Color(0.3, 0.25, 0.3), "size_px": 44, "card": "hell_poodle_card"}, 
	"banshee": {"name": "Banshee", "hp": 52.0, "speed": 2.5, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.7, 0.7, 0.85), "size_px": 54, "card": "banshee_card"}, 
	"flame_skull": {"name": "Flame Skull", "hp": 22.0, "speed": 3.5, "damage": 7.0, "xp": 3, 
		"radius": 0.38, "color": Color(1.0, 0.5, 0.2), "size_px": 40, "card": "flame_skull_card"}, 
	"necromancer": {"name": "Necromancer", "hp": 1150.0, "speed": 1.9, "damage": 20.0, "xp": 36, 
		"radius": 0.55, "color": Color(0.35, 0.3, 0.45), "size_px": 62, "card": "necromancer_card", "elite": true, 
		"ranged": {"kind": "fire_bolt", "range": 8.0, "every": 3.4}}, 
	"banshee_master": {"name": "Banshee Master", "hp": 5600.0, "speed": 2.7, "damage": 28.0, "xp": 95, 
		"radius": 0.65, "color": Color(0.55, 0.5, 0.75), "size_px": 76, "card": "banshee_master_card", 
		"boss": "summoner", "summon": "banshee", "heal": 0.0}, 
	"fallen_bishop": {"name": "Fallen Bishop Hibram", "hp": 26000.0, "speed": 2.5, "damage": 40.0, "xp": 0, 
		"radius": 0.9, "color": Color(0.3, 0.15, 0.3), "size_px": 110, "card": "fallen_bishop_card", 
		"boss": "mvp", "summon": ["ragged_zombie", "banshee"], "mvp": true, 
		"slam_fx": "holyhit", "slam_sound": "holy_light"}, 

	"disguise": {"name": "Disguise", "hp": 48.0, "speed": 2.6, "damage": 10.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.6, 0.3, 0.3), "size_px": 52, "card": "disguise_card"}, 
	"gibbet": {"name": "Gibbet", "hp": 62.0, "speed": 1.9, "damage": 12.0, "xp": 5, 
		"radius": 0.5, "color": Color(0.4, 0.35, 0.3), "size_px": 58, "card": "gibbet_card"}, 
	"rideword": {"name": "Rideword", "hp": 26.0, "speed": 3.4, "damage": 8.0, "xp": 3, 
		"radius": 0.38, "color": Color(0.5, 0.35, 0.25), "size_px": 40, "card": "rideword_card"}, 
	"dark_priest": {"name": "Dark Priest", "hp": 70.0, "speed": 1.8, "damage": 13.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.3, 0.2, 0.35), "size_px": 60, "card": "dark_priest_card", 
		"ranged": {"kind": "fire_bolt", "range": 7.5, "every": 3.6}}, 
	"bloody_murderer": {"name": "Bloody Murderer", "hp": 1300.0, "speed": 2.4, "damage": 22.0, "xp": 40, 
		"radius": 0.6, "color": Color(0.6, 0.15, 0.15), "size_px": 70, "card": "bloody_murderer_card", "elite": true}, 
	"dullahan": {"name": "Dullahan", "hp": 6200.0, "speed": 2.6, "damage": 30.0, "xp": 100, 
		"radius": 0.65, "color": Color(0.3, 0.3, 0.35), "size_px": 78, "card": "dullahan_card", 
		"boss": "summoner", "summon": "gibbet", "heal": 0.0}, 
	"hunter_fly": {"name": "Hunter Fly", "hp": 18.0, "speed": 3.8, "damage": 7.0, "xp": 2, 
		"radius": 0.35, "color": Color(0.5, 0.5, 0.3), "size_px": 36, "card": "hunter_fly_card"}, 
	"beelzebub": {"name": "Beelzebub", "hp": 28000.0, "speed": 2.6, "damage": 44.0, "xp": 0, 
		"radius": 1.0, "color": Color(0.25, 0.2, 0.15), "size_px": 120, "card": "beelzebub_card", 
		"boss": "mvp", "summon": ["hunter_fly", "rideword"], "mvp": true, 
		"slam_fx": "firepillar", "slam_sound": "fire_hit1"}, 

	"randgris": {"name": "Valkyrie Randgris", "hp": 30000.0, "speed": 2.6, "damage": 40.0, "xp": 0, 
		"radius": 1.0, "color": Color(0.9, 0.85, 0.5), "size_px": 110, "card": "randgris_card"}, 



	"reginleif": {"name": "Valkyrie Reginleif", "card": "reginleif_card", "hp": 26000.0, "speed": 2.6, "damage": 38.0, "xp": 0, 
		"radius": 1.1, "color": Color(1.0, 0.9, 0.55), "size_px": 130, "boss": "mvp", "mvp": true, "summon": ["raydric", "bloody_knight"], 
		"slam_fx": "holyhit", "slam_sound": "magnus"}, 
	"randgris_fallen": {"name": "Randgris Caída", "card": "randgris_fallen_card", "hp": 26000.0, "speed": 2.7, "damage": 40.0, "xp": 0, 
		"radius": 1.1, "color": Color(0.75, 0.12, 0.15), "size_px": 130, "boss": "mvp", "mvp": true, "summon": ["dark_priest", "whisper"], 
		"tint": Color(0.62, 0.32, 0.38), "corrupt_aura": true, "slam_fx": "hell_in", "slam_sound": "earth_quake"}, 
	"dark_lord": {"name": "Dark Lord", "hp": 24000.0, "speed": 2.4, "damage": 36.0, "xp": 0, 
		"radius": 1.0, "color": Color(0.25, 0.1, 0.2), "size_px": 120, "card": "dark_lord_card", 
		"boss": "mvp", "summon": ["zombie", "ghoul", "wraith"], "mvp": true, 
		"slam_fx": "meteor1", "slam_sound": "meteor"}, 



	"satan_morroc": {"name": "Satan Morroc", "hp": 30000.0, "speed": 3.0, "damage": 40.0, "xp": 0, 
		"radius": 1.2, "color": Color(0.55, 0.2, 0.18), "size_px": 200, "card": "satan_morroc_card", 
		"boss": "mvp", "mvp": true}, 


	"morroc_kid": {"name": "Morroc Niño", "hp": 30000.0, "speed": 3.2, "damage": 40.0, "xp": 0, 
		"radius": 1.0, "color": Color(0.5, 0.3, 0.75), "size_px": 150, "boss": "mvp", "mvp": true}, 
	"morroc_adult": {"name": "Morroc Renacido", "hp": 30000.0, "speed": 3.6, "damage": 40.0, "xp": 0, 
		"radius": 1.2, "color": Color(0.7, 0.2, 0.25), "size_px": 180, "boss": "mvp", "mvp": true}, 


	"naght_sieger": {"name": "Naght Sieger", "hp": 34000.0, "speed": 3.2, "damage": 46.0, "xp": 0, 
		"radius": 1.2, "color": Color(1.0, 0.4, 0.3), "size_px": 170, "boss": "mvp", "mvp": true, 
		"slam_fx": "firepillar", "slam_sound": "fire_pillar"}, 
	"naght_echo_fire": {"name": "Eco de la Espada Ígnea", "hp": 1.0, "speed": 3.4, "damage": 40.0, "xp": 0, 
		"radius": 0.9, "color": Color(1.0, 0.45, 0.25), "size_px": 130, "boss": "mvp", 
		"slam_fx": "firepillar", "slam_sound": "fire_pillar"}, 
	"naght_echo_ice": {"name": "Eco de la Espada Helada", "hp": 1.0, "speed": 3.4, "damage": 40.0, "xp": 0, 
		"radius": 0.9, "color": Color(0.5, 0.8, 1.0), "size_px": 130, "boss": "mvp", 
		"slam_fx": "icecrash"}, 
	"morroc_incarnation_1": {"name": "Encarnación de Morroc", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.7, "color": Color(0.8, 0.6, 0.65), "size_px": 90, "static": true, "boss": "summoner"}, 
	"morroc_incarnation_2": {"name": "Encarnación de Morroc", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.6, "color": Color(0.45, 0.3, 0.25), "size_px": 70, "static": true, "boss": "summoner"}, 
	"morroc_incarnation_3": {"name": "Encarnación de Morroc", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.6, "color": Color(0.7, 0.55, 0.5), "size_px": 50, "static": true, "boss": "summoner"}, 
	"morroc_incarnation_4": {"name": "Encarnación de Morroc", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.6, "color": Color(0.8, 0.8, 0.9), "size_px": 80, "static": true, "boss": "summoner"}, 

	"orc_baby": {"name": "Orc Baby", "hp": 18.0, "speed": 2.1, "damage": 5.0, "xp": 2, 
		"radius": 0.35, "color": Color(0.5, 0.65, 0.35), "size_px": 34, "card": "orc_baby_card"}, 
	"ork_warrior": {"name": "Orc Warrior", "hp": 44.0, "speed": 2.1, "damage": 8.0, "xp": 4, 
		"radius": 0.45, "color": Color(0.4, 0.6, 0.3), "size_px": 50, "card": "orc_warrior_card"}, 
	"orc_lady": {"name": "Orc Lady", "hp": 42.0, "speed": 2.7, "damage": 8.0, "xp": 4, 
		"radius": 0.42, "color": Color(0.55, 0.65, 0.4), "size_px": 48, "card": "orc_lady_card"}, 
	"orc_archer": {"name": "Orc Archer", "hp": 34.0, "speed": 1.9, "damage": 5.0, "xp": 4, 
		"radius": 0.42, "color": Color(0.45, 0.55, 0.3), "size_px": 48, "card": "orc_archer_card", 
		"ranged": {"kind": "arrow", "range": 7.5, "every": 3.0, "speed": 10.0}}, 
	"orc_zombie": {"name": "Orc Zombie", "hp": 60.0, "speed": 1.6, "damage": 10.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.45, 0.5, 0.4), "size_px": 50, "card": "orc_zombie_card"}, 
	"high_orc": {"name": "High Orc", "hp": 950.0, "speed": 2.3, "damage": 18.0, "xp": 35, 
		"radius": 0.6, "color": Color(0.35, 0.5, 0.25), "size_px": 64, "card": "high_orc_card", "elite": true}, 
	"orc_lord": {"name": "Orc Lord", "hp": 21000.0, "speed": 2.5, "damage": 32.0, "xp": 0, 
		"radius": 1.0, "color": Color(0.3, 0.45, 0.2), "size_px": 110, "card": "orc_lord_card", 
		"boss": "mvp", "summon": ["orc_zombie", "orc_skeleton", "zenorc"], "mvp": true}, 
	"ork_hero": {"name": "Orc Hero", "hp": 19000.0, "speed": 2.5, "damage": 30.0, "xp": 0, 
		"radius": 1.0, "color": Color(0.35, 0.5, 0.25), "size_px": 110, "card": "orc_hero_card", 
		"boss": "mvp", "summon": ["ork_warrior", "orc_lady", "orc_archer"], "mvp": true}, 

	"skel_soldier": {"name": "Soldier Skeleton", "hp": 46.0, "speed": 2.0, "damage": 9.0, "xp": 4, 
		"radius": 0.42, "color": Color(0.85, 0.82, 0.75), "size_px": 48, "card": "skel_soldier_card"}, 
	"munak": {"name": "Munak", "hp": 44.0, "speed": 1.8, "damage": 9.0, "xp": 4, 
		"radius": 0.42, "color": Color(0.5, 0.6, 0.8), "size_px": 46, "card": "munak_card"}, 
	"bon_gun": {"name": "Bongun", "hp": 50.0, "speed": 1.9, "damage": 10.0, "xp": 5, 
		"radius": 0.42, "color": Color(0.45, 0.4, 0.6), "size_px": 46, "card": "bongun_card"}, 
	"sohee": {"name": "Sohee", "hp": 62.0, "speed": 2.4, "damage": 11.0, "xp": 6, 
		"radius": 0.42, "color": Color(0.9, 0.85, 0.85), "size_px": 48, "card": "sohee_card"}, 
	"horong": {"name": "Horong", "hp": 26.0, "speed": 3.3, "damage": 7.0, "xp": 3, 
		"radius": 0.38, "color": Color(1.0, 0.6, 0.3), "size_px": 36, "card": "horong_card"}, 
	"nine_tail": {"name": "Nine Tail", "hp": 900.0, "speed": 2.8, "damage": 17.0, "xp": 30, 
		"radius": 0.6, "color": Color(1.0, 0.85, 0.5), "size_px": 64, "card": "nine_tail_card", "elite": true}, 
	"skeleton_general": {"name": "Skeleton General", "hp": 4600.0, "speed": 2.3, "damage": 22.0, "xp": 95, 
		"radius": 0.7, "color": Color(0.85, 0.8, 0.7), "size_px": 80, "card": "skeleton_general_card", 
		"boss": "summoner", "summon": "skel_soldier", "heal": 0.0}, 
	"moonlight": {"name": "Moonlight Flower", "hp": 17000.0, "speed": 2.8, "damage": 28.0, "xp": 0, 
		"radius": 0.9, "color": Color(1.0, 0.8, 0.5), "size_px": 100, "card": "moonlight_card", 
		"boss": "mvp", "summon": ["horong", "sohee"], "mvp": true}, 

	"zenorc": {"name": "Zenorc", "hp": 46.0, "speed": 2.6, "damage": 9.0, "xp": 4, 
		"radius": 0.42, "color": Color(0.35, 0.3, 0.4), "size_px": 46, "card": "zenorc_card"}, 
	"orc_skeleton": {"name": "Orc Skeleton", "hp": 60.0, "speed": 2.0, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.85, 0.82, 0.75), "size_px": 50, "card": "orc_skeleton_card"}, 
	"drainliar": {"name": "Drainliar", "hp": 30.0, "speed": 3.4, "damage": 7.0, "xp": 3, 
		"radius": 0.38, "color": Color(0.4, 0.3, 0.4), "size_px": 36, "card": "drainliar_card"}, 
	"skel_archer": {"name": "Archer Skeleton", "hp": 30.0, "speed": 1.8, "damage": 6.0, "xp": 4, 
		"radius": 0.4, "color": Color(0.9, 0.88, 0.8), "size_px": 46, "card": "archer_skeleton_card", 
		"ranged": {"kind": "arrow", "range": 7.5, "every": 3.0, "speed": 10.0}}, 


	"baphomet_jr": {"name": "Baphomet Jr.", "hp": 150.0, "speed": 2.9, "damage": 14.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.5, 0.3, 0.35), "size_px": 56, "card": "baphomet_jr_card"}, 
	"bomb_poring": {"name": "Bomb Poring", "card": "bomb_poring_card", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.55, "color": Color(0.25, 0.2, 0.3), "size_px": 44, "static": true}, 
	"marine_sphere": {"name": "Marine Sphere", "card": "marine_sphere_card", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.5, "color": Color(1.0, 0.6, 0.6), "size_px": 36, "static": true}, 
	"peco_egg": {"name": "Peco Peco Egg", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.45, "color": Color(0.95, 0.85, 0.6), "size_px": 28, "static": true, "card": "peco_egg_card"}, 
	"thief_bug_egg": {"name": "Thief Bug Egg", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.45, "color": Color(0.7, 0.55, 0.4), "size_px": 28, "static": true, "card": "thief_bug_egg_card"}, 
	"mob_tomb": {"name": "Tumba maldita", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.6, "color": Color(0.5, 0.5, 0.5), "size_px": 50, "static": true}, 

	"orc_shaman": {"name": "Chamán orca", "card": "orc_shaman_card", "hp": 1.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.5, "color": Color(0.5, 0.75, 0.35), "size_px": 40, "static": true}, 


	"woodbox": {"name": "Wooden Box", "hp": 30.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.5, "color": Color(0.7, 0.5, 0.3), "size_px": 30, "static": true, "prop": "woodbox"}, 
	"steelbox": {"name": "Steel Box", "hp": 90.0, "speed": 0.0, "damage": 0.0, "xp": 0, 
		"radius": 0.55, "color": Color(0.6, 0.62, 0.7), "size_px": 32, "static": true, "prop": "steelbox"}, 


	"thief_bug_male": {"name": "Male Thief Bug", "hp": 3000.0, "speed": 3.0, "damage": 20.0, "xp": 90, 
		"radius": 0.6, "color": Color(0.5, 0.35, 0.3), "size_px": 60, "card": "thief_bug_male_card", 
		"boss": "summoner", "summon": "thief_bug", "heal": 0.0}, 
	"thief_bug": {"name": "Thief Bug", "card": "thief_bug_card", "hp": 18.0, "speed": 2.8, "damage": 5.0, "xp": 2, 
		"radius": 0.36, "color": Color(0.45, 0.35, 0.25), "size_px": 32}, 
	"tarou": {"name": "Tarou", "card": "tarou_card", "hp": 16.0, "speed": 3.2, "damage": 4.0, "xp": 2, 
		"radius": 0.34, "color": Color(0.5, 0.45, 0.4), "size_px": 30}, 
	"plankton": {"name": "Plankton", "card": "plankton_card", "hp": 22.0, "speed": 1.4, "damage": 5.0, "xp": 2, 
		"radius": 0.36, "color": Color(0.6, 0.85, 0.7), "size_px": 32}, 
	"cramp": {"name": "Cramp", "card": "cramp_card", "hp": 24.0, "speed": 3.0, "damage": 6.0, "xp": 3, 
		"radius": 0.38, "color": Color(0.5, 0.4, 0.5), "size_px": 34}, 
	"thara_frog": {"name": "Thara Frog", "card": "thara_frog_card", "hp": 40.0, "speed": 2.0, "damage": 8.0, "xp": 4, 
		"radius": 0.45, "color": Color(0.4, 0.6, 0.4), "size_px": 42}, 
	"toad": {"name": "Toad", "card": "toad_card", "hp": 700.0, "speed": 2.2, "damage": 13.0, "xp": 30, 
		"radius": 0.55, "color": Color(0.4, 0.55, 0.35), "size_px": 56, "elite": true}, 
	"golden_bug": {"name": "Golden Thief Bug", "card": "golden_bug_card", "hp": 16000.0, "speed": 2.8, "damage": 28.0, "xp": 0, 
		"radius": 0.95, "color": Color(1.0, 0.85, 0.3), "size_px": 96, "boss": "mvp", "mvp": true, "summon": ["thief_bug", "cramp"], "slam_fx": "firepillar", "slam_sound": "fire_hit1"}, 
	"kukre": {"name": "Kukre", "card": "kukre_card", "hp": 18.0, "speed": 2.2, "damage": 5.0, "xp": 2, 
		"radius": 0.36, "color": Color(0.55, 0.6, 0.8), "size_px": 32}, 
	"vadon": {"name": "Vadon", "card": "vadon_card", "hp": 24.0, "speed": 1.8, "damage": 6.0, "xp": 3, 
		"radius": 0.4, "color": Color(0.85, 0.4, 0.3), "size_px": 36}, 
	"marina": {"name": "Marina", "card": "marina_card", "hp": 22.0, "speed": 1.4, "damage": 6.0, "xp": 3, 
		"radius": 0.38, "color": Color(0.85, 0.85, 1.0), "size_px": 34}, 
	"hydra": {"name": "Hydra", "card": "hydra_card", "hp": 30.0, "speed": 0.9, "damage": 7.0, "xp": 3, 
		"radius": 0.4, "color": Color(0.8, 0.5, 0.7), "size_px": 36}, 
	"marse": {"name": "Marse", "card": "marse_card", "hp": 34.0, "speed": 2.6, "damage": 8.0, "xp": 4, 
		"radius": 0.42, "color": Color(0.5, 0.45, 0.7), "size_px": 40}, 
	"obeaune": {"name": "Obeaune", "card": "obeaune_card", "hp": 750.0, "speed": 2.4, "damage": 14.0, "xp": 30, 
		"radius": 0.55, "color": Color(0.4, 0.6, 0.85), "size_px": 56, "elite": true}, 
	"strouf": {"name": "Strouf", "card": "strouf_card", "hp": 3100.0, "speed": 2.6, "damage": 18.0, "xp": 90, 
		"radius": 0.65, "color": Color(0.5, 0.55, 0.85), "size_px": 70, "boss": "summoner", "heal": 0.0, "summon": "marse"}, 
	"kraken": {"name": "Kraken", "card": "kraken_card", "hp": 18000.0, "speed": 1.8, "damage": 30.0, "xp": 0, 
		"radius": 1.1, "color": Color(0.55, 0.3, 0.55), "size_px": 130, "boss": "mvp", "mvp": true, "summon": ["marina", "hydra"], "slam_fx": "stormgust", "slam_sound": "frost_hit"}, 
	"solider": {"name": "Solider", "card": "solider_card", "hp": 40.0, "speed": 2.0, "damage": 9.0, "xp": 4, 
		"radius": 0.45, "color": Color(0.45, 0.6, 0.35), "size_px": 46}, 
	"permeter": {"name": "Permeter", "card": "permeter_card", "hp": 34.0, "speed": 2.6, "damage": 8.0, "xp": 4, 
		"radius": 0.42, "color": Color(0.6, 0.55, 0.35), "size_px": 42}, 
	"freezer": {"name": "Freezer", "card": "freezer_card", "hp": 36.0, "speed": 2.4, "damage": 9.0, "xp": 4, 
		"radius": 0.44, "color": Color(0.55, 0.7, 0.9), "size_px": 44}, 
	"heater": {"name": "Heater", "card": "heater_card", "hp": 36.0, "speed": 2.4, "damage": 9.0, "xp": 4, 
		"radius": 0.44, "color": Color(0.9, 0.5, 0.3), "size_px": 44}, 
	"turtle_knight": {"name": "Turtle Knight", "card": "turtle_knight_card", "hp": 820.0, "speed": 2.4, "damage": 15.0, "xp": 32, 
		"radius": 0.58, "color": Color(0.65, 0.6, 0.35), "size_px": 62, "elite": true}, 
	"turtle_champion": {"name": "Turtle Champion", "card": "turtle_champion_card", "hp": 3300.0, "speed": 2.2, "damage": 19.0, "xp": 95, 
		"radius": 0.66, "color": Color(0.5, 0.65, 0.35), "size_px": 76, "boss": "summoner", "heal": 0.0, "summon": "solider"}, 
	"turtle_general": {"name": "Turtle General", "card": "turtle_general_card", "hp": 19000.0, "speed": 2.4, "damage": 32.0, "xp": 0, 
		"radius": 1.05, "color": Color(0.5, 0.6, 0.3), "size_px": 120, "boss": "mvp", "mvp": true, "summon": ["solider", "permeter"], "slam_fx": "quagmire"}, 
	"mimic": {"name": "Mimic", "card": "mimic_card", "hp": 800.0, "speed": 2.8, "damage": 15.0, "xp": 32, 
		"radius": 0.5, "color": Color(0.7, 0.5, 0.3), "size_px": 50, "elite": true}, 
	"mummy": {"name": "Mummy", "card": "mummy_card", "hp": 38.0, "speed": 1.6, "damage": 9.0, "xp": 4, 
		"radius": 0.45, "color": Color(0.85, 0.8, 0.65), "size_px": 46}, 
	"isis": {"name": "Isis", "card": "isis_card", "hp": 34.0, "speed": 2.4, "damage": 8.0, "xp": 4, 
		"radius": 0.45, "color": Color(0.75, 0.6, 0.3), "size_px": 50}, 
	"matyr": {"name": "Matyr", "card": "matyr_card", "hp": 26.0, "speed": 3.4, "damage": 7.0, "xp": 3, 
		"radius": 0.4, "color": Color(0.3, 0.3, 0.35), "size_px": 38}, 
	"minorous": {"name": "Minorous", "card": "minorous_card", "hp": 46.0, "speed": 2.2, "damage": 10.0, "xp": 5, 
		"radius": 0.5, "color": Color(0.6, 0.35, 0.25), "size_px": 54}, 
	"marduk": {"name": "Marduk", "card": "marduk_card", "hp": 800.0, "speed": 2.2, "damage": 15.0, "xp": 32, 
		"radius": 0.55, "color": Color(0.85, 0.5, 0.3), "size_px": 56, "elite": true, "ranged": {"kind": "fire_bolt", "range": 8.0, "every": 3.4}}, 
	"ancient_mummy": {"name": "Ancient Mummy", "card": "ancient_mummy_card", "hp": 3300.0, "speed": 2.0, "damage": 19.0, "xp": 95, 
		"radius": 0.62, "color": Color(0.85, 0.8, 0.6), "size_px": 70, "boss": "summoner", "heal": 0.0, "summon": "mummy"}, 
	"osiris": {"name": "Osiris", "card": "osiris_card", "hp": 19000.0, "speed": 2.4, "damage": 32.0, "xp": 0, 
		"radius": 1.0, "color": Color(0.9, 0.75, 0.4), "size_px": 110, "boss": "mvp", "mvp": true, "summon": ["mummy", "isis"], "slam_fx": "meteor1", "slam_sound": "meteor"}, 
	"andre": {"name": "Andre", "card": "andre_card", "hp": 30.0, "speed": 2.2, "damage": 7.0, "xp": 3, 
		"radius": 0.4, "color": Color(0.6, 0.45, 0.3), "size_px": 36}, 
	"piere": {"name": "Piere", "card": "piere_card", "hp": 32.0, "speed": 2.4, "damage": 8.0, "xp": 3, 
		"radius": 0.4, "color": Color(0.35, 0.45, 0.3), "size_px": 36}, 
	"deniro": {"name": "Deniro", "card": "deniro_card", "hp": 34.0, "speed": 2.0, "damage": 8.0, "xp": 4, 
		"radius": 0.42, "color": Color(0.55, 0.35, 0.25), "size_px": 38}, 
	"vitata": {"name": "Vitata", "card": "vitata_card", "hp": 40.0, "speed": 1.8, "damage": 9.0, "xp": 4, 
		"radius": 0.44, "color": Color(0.8, 0.7, 0.4), "size_px": 40}, 
	"argiope": {"name": "Argiope", "card": "argiope_card", "hp": 850.0, "speed": 2.2, "damage": 16.0, "xp": 34, 
		"radius": 0.58, "color": Color(0.35, 0.3, 0.25), "size_px": 60, "elite": true}, 
	"giant_spider": {"name": "Giant Spider", "card": "giant_spider_card", "hp": 3400.0, "speed": 2.4, "damage": 20.0, "xp": 95, 
		"radius": 0.65, "color": Color(0.4, 0.35, 0.3), "size_px": 74, "boss": "summoner", "heal": 0.0, "summon": "andre"}, 
	"maya": {"name": "Maya", "card": "maya_card", "hp": 20000.0, "speed": 2.2, "damage": 33.0, "xp": 0, 
		"radius": 1.05, "color": Color(0.75, 0.6, 0.35), "size_px": 120, "boss": "mvp", "mvp": true, "summon": ["andre", "vitata"]}, 
	"skel_worker": {"name": "Skeleton Worker", "card": "skel_worker_card", "hp": 36.0, "speed": 2.0, "damage": 8.0, "xp": 4, 
		"radius": 0.42, "color": Color(0.8, 0.8, 0.7), "size_px": 44}, 
	"steel_chocho": {"name": "Steel Chonchon", "card": "steel_chocho_card", "hp": 24.0, "speed": 3.4, "damage": 7.0, "xp": 3, 
		"radius": 0.36, "color": Color(0.6, 0.6, 0.65), "size_px": 34}, 
	"iron_fist": {"name": "Iron Fist", "card": "iron_fist_card", "hp": 40.0, "speed": 2.2, "damage": 9.0, "xp": 4, 
		"radius": 0.45, "color": Color(0.55, 0.5, 0.45), "size_px": 44}, 
	"hornet": {"name": "Hornet", "card": "hornet_card", "hp": 22.0, "speed": 3.2, "damage": 7.0, "xp": 3, 
		"radius": 0.34, "color": Color(0.9, 0.75, 0.2), "size_px": 32}, 
	"argos": {"name": "Argos", "card": "argos_card", "hp": 44.0, "speed": 2.2, "damage": 10.0, "xp": 5, 
		"radius": 0.48, "color": Color(0.4, 0.35, 0.3), "size_px": 48}, 
	"giant_hornet": {"name": "Giant Hornet", "card": "giant_hornet_card", "hp": 850.0, "speed": 3.0, "damage": 16.0, "xp": 34, 
		"radius": 0.55, "color": Color(0.95, 0.75, 0.2), "size_px": 56, "elite": true}, 
	"golem": {"name": "Golem", "card": "golem_card", "hp": 3500.0, "speed": 1.8, "damage": 21.0, "xp": 100, 
		"radius": 0.7, "color": Color(0.55, 0.5, 0.45), "size_px": 78, "boss": "summoner", "heal": 0.0, "summon": "skel_worker"}, 
	"mistress": {"name": "Mistress", "card": "mistress_card", "hp": 20000.0, "speed": 2.8, "damage": 33.0, "xp": 0, 
		"radius": 1.0, "color": Color(0.95, 0.8, 0.3), "size_px": 110, "boss": "mvp", "mvp": true, "summon": ["hornet", "giant_hornet"]}, 
	"clock": {"name": "Clock", "card": "clock_card", "hp": 46.0, "speed": 1.8, "damage": 10.0, "xp": 5, 
		"radius": 0.48, "color": Color(0.75, 0.6, 0.4), "size_px": 50}, 
	"alarm": {"name": "Alarm", "card": "alarm_card", "hp": 40.0, "speed": 2.4, "damage": 10.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.85, 0.7, 0.4), "size_px": 46}, 
	"punk": {"name": "Punk", "card": "punk_card", "hp": 30.0, "speed": 3.0, "damage": 9.0, "xp": 4, 
		"radius": 0.4, "color": Color(0.6, 0.75, 0.5), "size_px": 38}, 
	"owl_duke": {"name": "Owl Duke", "card": "owl_duke_card", "hp": 3600.0, "speed": 2.4, "damage": 22.0, "xp": 100, 
		"radius": 0.68, "color": Color(0.55, 0.45, 0.6), "size_px": 76, "boss": "summoner", "heal": 0.0, "summon": "punk"}, 
	"owl_baron": {"name": "Owl Baron", "card": "owl_baron_card", "hp": 21000.0, "speed": 2.6, "damage": 34.0, "xp": 0, 
		"radius": 1.0, "color": Color(0.5, 0.4, 0.6), "size_px": 110, "boss": "mvp", "mvp": true, "summon": ["alarm", "punk"]}, 
	"quve": {"name": "Quve", "card": "quve_card", "hp": 40.0, "speed": 2.4, "damage": 10.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.7, 0.75, 0.9), "size_px": 44}, 
	"loli_ruri": {"name": "Loli Ruri", "card": "loli_ruri_card", "hp": 52.0, "speed": 2.6, "damage": 12.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.6, 0.3, 0.45), "size_px": 54}, 
	"hylozoist": {"name": "Hylozoist", "card": "hylozoist_card", "hp": 46.0, "speed": 2.0, "damage": 11.0, "xp": 5, 
		"radius": 0.48, "color": Color(0.75, 0.65, 0.55), "size_px": 48}, 
	"lord_of_death": {"name": "Lord of the Dead", "card": "lord_of_death_card", "hp": 23000.0, "speed": 2.4, "damage": 36.0, "xp": 0, 
		"radius": 1.1, "color": Color(0.25, 0.2, 0.3), "size_px": 130, "boss": "mvp", "mvp": true, "summon": ["quve", "loli_ruri"], "slam_fx": "meteor1", "slam_sound": "meteor"}, 
	"venatu": {"name": "Venatu", "card": "venatu_card", "hp": 46.0, "speed": 2.4, "damage": 11.0, "xp": 5, 
		"radius": 0.48, "color": Color(0.55, 0.6, 0.7), "size_px": 48}, 
	"venatu_1": {"name": "Venatu Rojo", "card": "red_venatu_card", "hp": 48.0, "speed": 2.4, "damage": 11.0, "xp": 5, 
		"radius": 0.48, "color": Color(0.8, 0.4, 0.35), "size_px": 48}, 
	"dimik": {"name": "Dimik", "card": "dimik_card", "hp": 52.0, "speed": 2.0, "damage": 12.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.55, 0.6, 0.65), "size_px": 54}, 
	"dimik_1": {"name": "Dimik Azul", "card": "blue_dimik_card", "hp": 54.0, "speed": 2.0, "damage": 12.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.4, 0.5, 0.85), "size_px": 54, "ranged": {"kind": "arrow", "range": 8.0, "every": 3.0}}, 
	"dimik_2": {"name": "Dimik Verde", "card": "green_dimik_card", "hp": 950.0, "speed": 2.2, "damage": 17.0, "xp": 36, 
		"radius": 0.55, "color": Color(0.45, 0.8, 0.45), "size_px": 60, "elite": true}, 
	"archdam": {"name": "Archdam", "card": "archdam_card", "hp": 3800.0, "speed": 2.2, "damage": 23.0, "xp": 105, 
		"radius": 0.75, "color": Color(0.5, 0.5, 0.55), "size_px": 84, "boss": "summoner", "heal": 0.0, "summon": "venatu"}, 


	"apocalips": {"name": "Vesper", "card": "apocalips_card", "hp": 23000.0, "speed": 2.2, "damage": 36.0, "xp": 0, 
		"radius": 1.1, "color": Color(0.45, 0.45, 0.5), "size_px": 130, "boss": "mvp", "mvp": true, "summon": ["venatu_1", "dimik_1"]}, 

	"cookie": {"name": "Cookie", "card": "cookie_card", "hp": 44.0, "speed": 2.4, "damage": 10.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.85, 0.65, 0.4), "size_px": 44}, 

	"antonio": {"name": "Antonio", "hp": 200.0, "speed": 2.6, "damage": 12.0, "xp": 40, 
		"radius": 0.5, "color": Color(0.85, 0.2, 0.2), "size_px": 52}, 
	"cookie_xmas": {"name": "Christmas Cookie", "card": "cookie_xmas_card", "hp": 46.0, "speed": 2.4, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.9, 0.4, 0.35), "size_px": 46}, 
	"cruiser": {"name": "Cruiser", "card": "cruiser_card", "hp": 50.0, "speed": 2.0, "damage": 11.0, "xp": 6, 
		"radius": 0.48, "color": Color(0.6, 0.65, 0.8), "size_px": 50, "ranged": {"kind": "arrow", "range": 8.0, "every": 3.0}}, 
	"mystcase": {"name": "Myst Case", "card": "mystcase_card", "hp": 56.0, "speed": 2.0, "damage": 12.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.85, 0.5, 0.7), "size_px": 54}, 
	"garm_baby": {"name": "Hatii Baby", "card": "garm_baby_card", "hp": 48.0, "speed": 2.8, "damage": 11.0, "xp": 5, 
		"radius": 0.48, "color": Color(0.75, 0.85, 1.0), "size_px": 50}, 
	"marionette": {"name": "Marionette", "card": "marionette_card", "hp": 950.0, "speed": 2.2, "damage": 17.0, "xp": 36, 
		"radius": 0.55, "color": Color(0.8, 0.6, 0.85), "size_px": 60, "elite": true}, 
	"garm": {"name": "Hatii", "card": "garm_card", "hp": 3800.0, "speed": 2.4, "damage": 23.0, "xp": 105, 
		"radius": 0.8, "color": Color(0.7, 0.85, 1.0), "size_px": 90, "boss": "summoner", "heal": 0.0, "summon": "garm_baby"}, 
	"knight_of_windstorm": {"name": "Stormy Knight", "card": "knight_of_windstorm_card", "hp": 23000.0, "speed": 2.4, "damage": 36.0, "xp": 0, 
		"radius": 1.1, "color": Color(0.6, 0.8, 1.0), "size_px": 130, "boss": "mvp", "mvp": true, "summon": ["garm_baby", "mystcase"], 
		"slam_fx": "stormgust", "slam_sound": "frost_diver"}, 

	"solace": {"name": "Solace", "card": "solace_card", "hp": 48.0, "speed": 2.4, "damage": 11.0, "xp": 5, 
		"radius": 0.48, "color": Color(0.9, 0.85, 0.7), "size_px": 50}, 
	"observation": {"name": "Observation", "card": "observation_card", "hp": 46.0, "speed": 2.6, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.7, 0.75, 0.9), "size_px": 46, "ranged": {"kind": "fire_bolt", "range": 8.0, "every": 3.4}}, 
	"retribution": {"name": "Retribution", "card": "retribution_card", "hp": 54.0, "speed": 2.4, "damage": 12.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.55, 0.4, 0.6), "size_px": 54}, 
	"shelter": {"name": "Shelter", "card": "shelter_card", "hp": 58.0, "speed": 2.0, "damage": 12.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.85, 0.8, 0.95), "size_px": 54}, 
	"zherlthsh": {"name": "Zherlthsh", "card": "zherlthsh_card", "hp": 950.0, "speed": 2.4, "damage": 17.0, "xp": 36, 
		"radius": 0.55, "color": Color(0.45, 0.35, 0.55), "size_px": 64, "elite": true}, 
	"tha_odium": {"name": "Odium of Thanatos", "card": "tha_odium_card", "hp": 3800.0, "speed": 2.4, "damage": 23.0, "xp": 105, 
		"radius": 0.8, "color": Color(0.5, 0.3, 0.55), "size_px": 90, "boss": "summoner", "heal": 0.0, "summon": "retribution"}, 
	"thanatos": {"name": "Memory of Thanatos", "card": "thanatos_card", "hp": 23000.0, "speed": 2.4, "damage": 36.0, "xp": 0, 
		"radius": 1.1, "color": Color(0.4, 0.25, 0.5), "size_px": 130, "boss": "mvp", "mvp": true, "summon": ["retribution", "solace"], 
		"slam_fx": "hell_in", "slam_sound": "earth_quake"}, 

	"ygnizem": {"name": "Egnigem Cenia", "card": "ygnizem_card", "hp": 50.0, "speed": 2.4, "damage": 12.0, "xp": 6, 
		"radius": 0.45, "color": Color(0.9, 0.5, 0.35), "size_px": 48}, 
	"whikebain": {"name": "Wickebine Tres", "card": "whikebain_card", "hp": 46.0, "speed": 2.8, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.55, 0.75, 0.45), "size_px": 48}, 
	"armaia": {"name": "Armeyer Dinze", "card": "armaia_card", "hp": 58.0, "speed": 2.0, "damage": 12.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.75, 0.6, 0.4), "size_px": 50}, 
	"erend": {"name": "Errende Ebecee", "card": "erend_card", "hp": 48.0, "speed": 2.2, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.95, 0.9, 0.7), "size_px": 48}, 
	"kavac": {"name": "Kavac Icarus", "card": "kavac_card", "hp": 46.0, "speed": 2.4, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.6, 0.85, 0.6), "size_px": 48, "ranged": {"kind": "arrow", "range": 8.0, "every": 3.0}}, 
	"rawrel": {"name": "Laurell Weinder", "card": "rawrel_card", "hp": 46.0, "speed": 2.2, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.7, 0.55, 0.85), "size_px": 48, "ranged": {"kind": "fire_bolt", "range": 8.0, "every": 3.4}}, 
	"seyren": {"name": "Seyren Windsor", "card": "seyren_card", "hp": 950.0, "speed": 2.4, "damage": 17.0, "xp": 36, 
		"radius": 0.55, "color": Color(0.9, 0.45, 0.35), "size_px": 60, "elite": true}, 
	"eremes": {"name": "Eremes Guile", "card": "eremes_card", "hp": 950.0, "speed": 2.8, "damage": 17.0, "xp": 36, 
		"radius": 0.55, "color": Color(0.55, 0.75, 0.45), "size_px": 60, "elite": true}, 
	"magaleta": {"name": "Margaretha Sorin", "card": "magaleta_card", "hp": 950.0, "speed": 2.2, "damage": 16.0, "xp": 36, 
		"radius": 0.55, "color": Color(0.95, 0.9, 0.7), "size_px": 60, "elite": true}, 
	"shecil": {"name": "Cecil Damon", "card": "shecil_card", "hp": 950.0, "speed": 2.4, "damage": 16.0, "xp": 36, 
		"radius": 0.55, "color": Color(0.6, 0.85, 0.6), "size_px": 60, "elite": true, "ranged": {"kind": "arrow", "range": 9.0, "every": 2.4}}, 
	"katrinn": {"name": "Kathryne Keyron", "card": "katrinn_card", "hp": 950.0, "speed": 2.2, "damage": 16.0, "xp": 36, 
		"radius": 0.55, "color": Color(0.7, 0.55, 0.85), "size_px": 60, "elite": true, "ranged": {"kind": "fire_bolt", "range": 9.0, "every": 2.8}}, 
	"harword": {"name": "Howard Alt-Eisen", "card": "harword_card", "hp": 3800.0, "speed": 2.2, "damage": 23.0, "xp": 105, 
		"radius": 0.8, "color": Color(0.55, 0.65, 0.85), "size_px": 84, "boss": "summoner", "heal": 0.0, "summon": "armaia"}, 
	"l_seyren": {"name": "Lord Knight Seyren", "card": "l_seyren_card", "hp": 23000.0, "speed": 2.6, "damage": 36.0, "xp": 0, 
		"radius": 1.0, "color": Color(1.0, 0.45, 0.3), "size_px": 110, "boss": "mvp", "mvp": true, "summon": ["ygnizem", "whikebain"], 
		"slam_fx": "firepillar", "slam_sound": "fire_pillar"}, 

	"magmaring": {"name": "Magmaring", "card": "magmaring_card", "hp": 46.0, "speed": 2.2, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(1.0, 0.45, 0.2), "size_px": 44}, 
	"imp": {"name": "Imp", "card": "imp_card", "hp": 48.0, "speed": 2.8, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.85, 0.3, 0.25), "size_px": 48, "ranged": {"kind": "fire_bolt", "range": 8.0, "every": 3.4}}, 
	"blazer": {"name": "Blazer", "card": "blazer_card", "hp": 50.0, "speed": 2.4, "damage": 12.0, "xp": 6, 
		"radius": 0.48, "color": Color(1.0, 0.6, 0.2), "size_px": 50}, 
	"explosion": {"name": "Explosion", "card": "explosion_card", "hp": 54.0, "speed": 2.6, "damage": 12.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.95, 0.4, 0.15), "size_px": 52}, 
	"salamander": {"name": "Salamander", "card": "salamander_card", "hp": 950.0, "speed": 2.6, "damage": 17.0, "xp": 36, 
		"radius": 0.55, "color": Color(1.0, 0.35, 0.2), "size_px": 64, "elite": true}, 
	"kasa": {"name": "Kasa", "card": "kasa_card", "hp": 950.0, "speed": 2.4, "damage": 17.0, "xp": 36, 
		"radius": 0.55, "color": Color(1.0, 0.5, 0.25), "size_px": 64, "elite": true, "ranged": {"kind": "fire_bolt", "range": 9.0, "every": 2.8}}, 
	"lava_golem": {"name": "Lava Golem", "card": "lava_golem_card", "hp": 3800.0, "speed": 2.0, "damage": 23.0, "xp": 105, 
		"radius": 0.8, "color": Color(0.9, 0.35, 0.15), "size_px": 90, "boss": "summoner", "heal": 0.0, "summon": "magmaring"}, 
	"ifrit": {"name": "Ifrit", "card": "ifrit_card", "hp": 23000.0, "speed": 2.4, "damage": 36.0, "xp": 0, 
		"radius": 1.1, "color": Color(1.0, 0.4, 0.15), "size_px": 130, "boss": "mvp", "mvp": true, "summon": ["imp", "blazer"], 
		"slam_fx": "firepillar", "slam_sound": "fire_pillar"}, 


	"agav": {"name": "Agav", "card": "agav_card", "hp": 48.0, "speed": 2.4, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.85, 0.75, 0.6), "size_px": 48}, 
	"echio": {"name": "Echio", "card": "echio_card", "hp": 50.0, "speed": 2.6, "damage": 12.0, "xp": 6, 
		"radius": 0.48, "color": Color(0.7, 0.6, 0.5), "size_px": 50}, 
	"isilla": {"name": "Isilla", "card": "isilla_card", "hp": 46.0, "speed": 2.2, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.95, 0.8, 0.85), "size_px": 46, "ranged": {"kind": "fire_bolt", "range": 8.0, "every": 3.4}}, 
	"seeker": {"name": "Seeker", "card": "seeker_card", "hp": 46.0, "speed": 2.4, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.6, 0.75, 0.9), "size_px": 46, "ranged": {"kind": "arrow", "range": 8.0, "every": 3.0}}, 
	"vanberk": {"name": "Vanberk", "card": "vanberk_card", "hp": 56.0, "speed": 2.2, "damage": 12.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.6, 0.55, 0.65), "size_px": 54}, 
	"hodremlin": {"name": "Hodremlin", "card": "hodremlin_card", "hp": 52.0, "speed": 2.6, "damage": 12.0, "xp": 6, 
		"radius": 0.48, "color": Color(0.45, 0.35, 0.55), "size_px": 50}, 
	"gremlin": {"name": "Gremlin", "card": "gremlin_card", "hp": 950.0, "speed": 2.6, "damage": 17.0, "xp": 36, 
		"radius": 0.55, "color": Color(0.5, 0.4, 0.6), "size_px": 60, "elite": true}, 
	"beholder": {"name": "Beholder", "card": "beholder_card", "hp": 950.0, "speed": 2.2, "damage": 16.0, "xp": 36, 
		"radius": 0.55, "color": Color(0.55, 0.7, 0.9), "size_px": 60, "elite": true, "ranged": {"kind": "fire_bolt", "range": 9.0, "every": 2.8}}, 
	"beholder_master": {"name": "Beholder Master", "card": "beholder_master_card", "hp": 3800.0, "speed": 2.2, "damage": 23.0, "xp": 105, 
		"radius": 0.8, "color": Color(0.5, 0.65, 0.95), "size_px": 84, "boss": "summoner", "heal": 0.0, "summon": "seeker"}, 
	"gloom": {"name": "Gloom Under Night", "card": "gloom_card", "hp": 23000.0, "speed": 2.4, "damage": 36.0, "xp": 0, 
		"radius": 1.1, "color": Color(0.35, 0.25, 0.5), "size_px": 130, "boss": "mvp", "mvp": true, "summon": ["hodremlin", "seeker"], 
		"slam_fx": "hell_in", "slam_sound": "earth_quake"}, 

	"siroma": {"name": "Siroma", "card": "siroma_card", "hp": 44.0, "speed": 2.6, "damage": 10.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.75, 0.9, 1.0), "size_px": 44}, 
	"snowier": {"name": "Snowier", "card": "snowier_card", "hp": 52.0, "speed": 2.2, "damage": 12.0, "xp": 6, 
		"radius": 0.5, "color": Color(0.85, 0.92, 1.0), "size_px": 54}, 
	"gazeti": {"name": "Gazeti", "card": "gazeti_card", "hp": 48.0, "speed": 2.4, "damage": 11.0, "xp": 5, 
		"radius": 0.45, "color": Color(0.6, 0.8, 1.0), "size_px": 48, "ranged": {"kind": "arrow", "range": 8.0, "every": 3.0}}, 
	"iceicle": {"name": "Iceicle", "hp": 40.0, "speed": 0.9, "damage": 10.0, "xp": 5, 
		"radius": 0.4, "color": Color(0.7, 0.9, 1.0), "size_px": 40}, 
	"ice_titan": {"name": "Ice Titan", "card": "ice_titan_card", "hp": 950.0, "speed": 2.0, "damage": 18.0, "xp": 36, 
		"radius": 0.6, "color": Color(0.65, 0.85, 1.0), "size_px": 70, "elite": true}, 
	"furious_snowier": {"name": "Furious Snowier", "card": "furious_snowier_card", "hp": 3800.0, "speed": 2.4, "damage": 23.0, "xp": 105, 
		"radius": 0.8, "color": Color(0.8, 0.9, 1.0), "size_px": 84, "boss": "summoner", "heal": 0.0, "summon": "snowier", 
		"look_scale": 1.6, "tint": Color(1.0, 0.72, 0.78)}, 
	"ktullanux": {"name": "Ktullanux", "card": "ktullanux_card", "hp": 23000.0, "speed": 2.2, "damage": 36.0, "xp": 0, 
		"radius": 1.2, "color": Color(0.55, 0.8, 1.0), "size_px": 130, "boss": "mvp", "mvp": true, "summon": ["iceicle", "siroma"], 
		"slam_fx": "icecrash", "slam_sound": "frost_diver"}, 
}



const SKILLS: = {


	"bash": {"status": "stun", "status_chance": 0.12, "status_time": 1.5, "name": "Bash", "type": "melee_arc", "desc": "Golpe en arco frente a ti que puede aturdir.", 
		"cooldown": 0.75, "damage": 30.0, "range": 3.5, "arc": 220.0, "knock": 3.5, "bash_fx": true, 
		"color": Color(1, 0.9, 0.6), "sound": "bash", 
		"per_level": {"status_chance": 0.04, "damage": 10.0, "range": 0.25, "cooldown": -0.07}}, 
	"magnum_break": {"burn_chance": 1.0, "element": "fire", "name": "Magnum Break", "fx": "firehit1", "fx_size": 2.2, "type": "aoe_self", "desc": "Explosión de fuego a tu alrededor que empuja enemigos.", 
		"cooldown": 4.0, "damage": 30.0, "range": 3.2, "knock": 9.0, 
		"color": Color(1, 0.45, 0.1), "sound": "magnum", 
		"per_level": {"damage": 12.0, "range": 0.35, "cooldown": -0.3}}, 
	"endure": {"tex_fx": "endure", "tex_count": 1, "name": "Endure", "type": "shield", "desc": "Cada pocos segundos obtienes un escudo que absorbe daño.", 
		"cooldown": 9.0, "amount": 25.0, "sound": "endure", "color": Color(1, 0.85, 0.3), 
		"per_level": {"amount": 12.0, "cooldown": -0.8}}, 
	"endure_x": {"tex_fx": "endure", "tex_count": 1, "name": "Endure EX", "type": "shield", "evolved": true, 
		"desc": "Un escudo enorme según tu vida máxima. Mientras dura, devuelves mucho más daño y tus autocasts al recibir golpes salen el doble; al romperse, estalla con todo lo que absorbió.", 
		"cooldown": 4.0, "amount": 150.0, "amount_hp": 0.2, "sound": "endure", "color": Color(1, 0.85, 0.3)}, 
	"energy_coat_x": {"name": "Energy Coat EX", "type": "shield", "evolved": true, "fx": "energycoat", 
		"desc": "Un escudo de energía enorme según tu vida máxima. Al romperse, estalla en energía con todo lo que absorbió.", 
		"cooldown": 4.0, "amount": 120.0, "amount_hp": 0.15, "color": Color(0.5, 0.7, 1)}, 
	"assumptio_x": {"name": "Assumptio EX", "type": "shield", "evolved": true, "fx": "asum", "fx_size": 1.4, "ring_fx": true, "sound": "assumptio", "sound_db": 0.0, 
		"desc": "El mayor escudo sagrado, según la vida máxima (al aliado que más lo necesite). Al romperse, cura un 20% de vida y estalla en luz.", 
		"cooldown": 4.0, "amount": 250.0, "amount_hp": 0.3, "color": Color(1, 0.95, 0.7)}, 
	"kaite_x": {"name": "Kaite EX", "type": "shield", "evolved": true, "spr_fx": "fx_sl_3", "sound": "sl_reflect", 
		"desc": "Barrera de espíritus según tu vida máxima. Mientras dura, devuelves el 150% del daño que te hacen de cerca y te tragas proyectiles y mecánicas de MVP como Kaite; con 5 cargas, una onda de espíritus mayor.", 
		"cooldown": 4.5, "amount": 150.0, "amount_hp": 0.2, "wave": 320.0, "color": Color(0.8, 0.85, 1.0)}, 
	"tuna_party_x": {"name": "Tuna Party EX", "type": "shield", "evolved": true, "spr_fx": "fx_tuna_party", "sound": "su_meowmeow", 
		"desc": "Una gran fiesta de atún según la vida máxima (al aliado que más la necesite). Al romperse, cura un 10% de vida y estalla.", 
		"cooldown": 4.5, "amount": 150.0, "amount_hp": 0.2, "color": Color(0.6, 0.85, 1.0)}, 
	"reject_sword_x": {"name": "Reject Sword EX", "type": "shield", "evolved": true, "fx": "guardian", "sound": "endure", 
		"desc": "Desvías todo: un gran escudo según tu vida máxima que devuelve el 100% del daño de cerca y, al romperse, estalla.", 
		"cooldown": 3.5, "amount": 180.0, "amount_hp": 0.2, "color": Color(0.85, 0.85, 1.0)}, 
	"fire_bolt": {"element": "fire", "name": "Fire Bolt", "magic": true, "type": "bolt", "desc": "Rayos de fuego caen del cielo sobre el enemigo.", 
		"cooldown": 1.0, "damage": 23.0, "count": 2.0, "range": 10.0, 
		"bolt_tex": "bolt_fire", "bolt_blend": "add", "bolt_axis": Vector2(0, -1), "bolt_scale": 0.42, "bolt_stretch": 1.35, "bolt_time": 0.3, 
		"impact_tex": "impact_fire", "color": Color(1, 0.45, 0.15), 
		"sound": "fire_cast", "hit_sound": "fire_hit", "hit_sound_variants": 3, 
		"per_level": {"damage": 5.8, "count": 1.0, "cooldown": -0.04}}, 



	"cold_bolt": {"element": "water", "status": "freeze", "status_chance": 0.2, "status_time": 2.0, "name": "Cold Bolt", "magic": true, "type": "bolt", "desc": "Fragmentos de hielo caen del cielo: ralentizan y a veces congelan.", 
		"cooldown": 1.2, "damage": 21.2, "count": 2.0, "range": 10.0, "slow": 1.5, 
		"bolt_tex": "bolt_icearrow", "bolt_blend": "mix", "bolt_axis": Vector2(-0.99, -0.14), "bolt_scale": 0.55, "bolt_time": 0.3, 
		"color": Color(0.5, 0.85, 1), 
		"sound": "cold_cast", "hit_sound": "cold_hit", "hit_sound_variants": 3, 
		"per_level": {"damage": 5.3, "count": 1.0, "cooldown": -0.05}}, 





	"soul_strike": {"element": "ghost", "name": "Soul Strike", "magic": true, "type": "soul_strike", 
		"desc": "Espíritus fantasma vuelan hacia el monstruo más fuerte cerca (jefes y MVP primero). Wizard y High Wizard: un espíritu que golpea una marca elemental la detona sola (más débil que un combo de dos elementos).", 
		"cooldown": 1.0, "damage": 34.0, "count": 2.0, "range": 10.0, "missile_gap": 0.08, "flight": 0.42, 
		"color": Color(1.0, 0.97, 0.88), "sound": "soul_strike", 
		"per_level": {"damage": 6.0, "count": 0.75, "cooldown": -0.05}}, 


	"fire_wall": {"burn_chance": 1.0, "element": "fire", "name": "Fire Wall", "magic": true, "type": "ground", "wall": true, 
		"fx": "firewall", "fx_size": 0.7, "desc": "Levanta un muro de fuego frente a los monstruos: los quema y los empuja hacia atrás.", 
		"shape": "line", "arm": 1, "cooldown": 4.0, "damage": 20.7, "count": 1.0, "range": 7.0, "area": 1.5, 
		"duration": 4.0, "tick": 0.35, "knock": 4.0, "color": Color(1, 0.5, 0.2), "sound": "fire_wall", 
		"per_level": {"damage": 6.9, "count": 0.25, "cooldown": -0.1}}, 
	"thunder_storm": {"fx_lead": 0.25, "element": "wind", "name": "Thunder Storm", "magic": true, "fx": "thunderstorm", "type": "aoe_target", "desc": "Rayos caen sobre enemigos cercanos.", 
		"cooldown": 3.2, "damage": 39.1, "count": 2.0, "range": 10.0, "area": 1.8, 
		"color": Color(1, 1, 0.5), "sound": "thunder", 
		"per_level": {"damage": 11.5, "count": 1.0, "area": 0.2}}, 
	"energy_coat": {"name": "Energy Coat", "fx": "energycoat", "type": "shield", "desc": "Escudo de energía que se recarga.", 
		"cooldown": 8.0, "amount": 20.0, "color": Color(0.5, 0.7, 1), 
		"per_level": {"amount": 10.0, "cooldown": -0.6}}, 

	"double_strafe": {"cast_fx": "flash", "hitscan": true, "air_hit": true, "uses_arrows": true, "name": "Double Strafe", "sound_cd": 0.4, "sound_db": -3.0, "sound_twice": 0.12, "hit_sound": "arrow_hit", "type": "projectile", "desc": "Dos flechas rápidas al enemigo más cercano.", 
		"cooldown": 0.6, "damage": 14.0, "count": 2.0, "speed": 20.0, "pierce": 1.0, "range": 9.5, 
		"size": 0.22, "same_target": true, "arrow": true, "color": Color(0.95, 0.9, 0.75), "sound": "bow", 
		"per_level": {"damage": 4.0, "count": 0.5, "cooldown": -0.04}}, 





	"arrow_shower": {"uses_arrows": true, "name": "Arrow Shower", "type": "bolt", "rain": 0.0, "desc": "Una lluvia de flechas cae sobre el grupo más denso: cada flecha hiere donde cae y empuja un poco hacia afuera.", 
		"cooldown": 2.6, "damage": 17.0, "count": 8.0, "range": 10.0, "area": 2.6, "hit_radius": 0.9, "max_hits": 2, "knock": 5.0, 
		"rain_span": 0.35, "bolt_tex": "arrow", "bolt_blend": "mix", "bolt_axis": Vector2(-0.7071, 0.7071), "bolt_scale": 1.7, 
		"bolt_time": 0.22, "streak_len": 2.4, "color": Color(1.0, 0.88, 0.55), 
		"sound": "arrowshower", "hit_sound": "arrow_hit", 
		"per_level": {"damage": 6.0, "count": 2.0, "area": 0.2, "cooldown": -0.08}}, 


	"charge_arrow": {"hit_fx": "hit", "impact": 1.0, "trail_tint": Color(1.0, 0.85, 0.55), "uses_arrows": true, "name": "Charge Arrow", "hit_sound": "arrow_hit", "type": "projectile", "desc": "Flecha cargada y pesada: pega fuerte, lanza lejos a los monstruos, puede aturdirlos y rebota a otros.", 
		"status": "stun", "status_chance": 0.2, "status_time": 1.2, 
		"cooldown": 1.8, "damage": 58.0, "count": 1.0, "speed": 18.0, "pierce": 4.0, "range": 11.0, 
		"size": 0.55, "knock": 10.0, "arrow": true, "streak": Color(1.0, 0.8, 0.55), "color": Color(1, 0.8, 0.4), "sound": "bow", 
		"per_level": {"damage": 16.0, "pierce": 1.0, "cooldown": -0.12, "status_chance": 0.04}}, 







	"bowling_bash": {"name": "Bowling Bash", "fx": "bowling", "type": "melee_arc", "bowl": true, 
		"desc": "Golpe circular que lanza a los monstruos como bolos: los que salen volando golpean a los que encuentran, y a los amontonados les pega dos veces.", 
		"cooldown": 1.8, "damage": 68.0, "range": 3.8, "arc": 360.0, "knock": 12.0, 
		"color": Color(1, 0.85, 0.5), "sound": "bowling", 
		"per_level": {"damage": 20.0, "range": 0.2, "cooldown": -0.1}}, 







	"ignition_break": {"burn_chance": 1.0, "burn_long": 2.5, "element": "fire", "ignition": true, "name": "Ignition Break", "type": "aoe_self", 
		"desc": "Estallido de fuego a tu alrededor. Sus llamas arden mucho más tiempo y con más fuego que las normales: deja a la horda ardiendo.", 
		"cooldown": 4.0, "damage": 35.0, "range": 3.6, "knock": 4.0, 
		"color": Color(1, 0.45, 0.1), "sound": "magnum", 
		"per_level": {"damage": 13.0, "range": 0.25, "cooldown": -0.25}}, 
	"brandish_spear": {"bleed_chance": 0.6, "name": "Brandish Spear", "lance": true, "fx": "brandish", "type": "melee_arc", "desc": "Barrido largo en abanico frente a ti.", 
		"cooldown": 2.4, "damage": 85.0, "range": 5.8, "arc": 80.0, "knock": 7.0, 
		"color": Color(0.85, 0.9, 1), "sound": "brandish", 
		"per_level": {"damage": 25.0, "range": 0.3, "cooldown": -0.12}}, 
	"storm_gust": {"fx_lead": 0.25, "element": "water", "status": "freeze", "status_chance": 0.3, "status_time": 3.0, "name": "Storm Gust", "magic": true, "fx": "stormgust", "fx_intensity": 0.32, "type": "aoe_target", "desc": "Ventisca que congela y daña a un grupo.", 
		"cooldown": 5.0, "damage": 46.0, "count": 1.0, "range": 10.0, "area": 3.6, "slow": 3.0, 
		"color": Color(0.6, 0.85, 1), "sound": "stormgust", 
		"per_level": {"status_chance": 0.04, "damage": 16.1, "area": 0.35, "cooldown": -0.3}}, 
	"lord_of_vermilion": {"fx_lead": 0.35, "element": "wind", "name": "Lord of Vermilion", "magic": true, "fx": "lord", "fx_intensity": 0.3, "type": "aoe_self", "desc": "Rayos sobre toda la zona a tu alrededor.", 
		"cooldown": 7.0, "damage": 86.2, "range": 6.5, "knock": 2.0, 
		"color": Color(1, 0.95, 0.5), "sound": "thunder", 
		"per_level": {"damage": 25.3, "range": 0.4, "cooldown": -0.45}}, 



	"jupitel_thunder": {"element": "wind", "name": "Jupitel Thunder", "magic": true, "type": "jupitel", "desc": "Una bola de rayos golpea varias veces al objetivo, lo empuja y lo aturde.", 
		"cooldown": 1.6, "damage": 27.6, "hits": 3.0, "count": 1.0, "range": 9.0, "knock": 6.0, "stun_time": 1.0, 
		"color": Color(0.7, 0.8, 1), "sound": "jupitel", "sound_db": -2.0, 
		"per_level": {"damage": 6.9, "hits": 1.0}}, 



	"blitz_beat": {"over_dmg_step": 0.6, "name": "Blitz Beat", "type": "passive", "falcon_passive": true, 
		"desc": "Pasiva: cuando disparas, a veces tu halcón se lanza solo sobre varios monstruos. Con más SUE, más seguido.", 
		"bonus": ["auto_blitz"], "auto_blitz": 0.08, "damage": 30.0, "count": 3.0, "range": 10.0, "area": 1.3, 
		"color": Color(1, 0.75, 0.35), "sound": "blitz", 
		"per_level": {"auto_blitz": 0.03, "damage": 9.0, "count": 1.0}}, 


	"falcon_assault": {"name": "Falcon Assault", "type": "falcon_assault", "tour_wait": 0.3, 
		"desc": "Tu halcón se lanza con todo sobre el enemigo más fuerte cercano: un golpe enorme que también alcanza a los de alrededor.", 
		"cooldown": 5.0, "damage": 260.0, "count": 1.0, "range": 11.0, "area": 1.6, 
		"color": Color(1, 0.8, 0.4), "sound": "blitz", 
		"per_level": {"damage": 80.0, "cooldown": -0.25}}, 
	"land_mine": {"over_dmg_step": 0.75, "element": "earth", "status": "stun", "status_chance": 0.5, "status_time": 2.0, "name": "Land Mine", "fx": "landmine", "type": "aoe_target", "trap": "trap_magenta", "desc": "Entierra minas en el camino de los monstruos: estallan cuando las pisan.", 
		"cooldown": 3.4, "damage": 190.0, "count": 2.0, "range": 8.0, "area": 2.1, 
		"color": Color(0.85, 0.6, 0.3), "sound": "landmine", 
		"per_level": {"damage": 55.0, "count": 0.5, "area": 0.2}}, 





	"charge_attack": {"name": "Charge Attack", "lance": true, "type": "charge", 
		"desc": "Cargas contra el enemigo más fuerte hacia donde vas, arrollando a los que haya en medio. Pega más cuanto más lejos venías.", 
		"cooldown": 3.0, "damage": 128.0, "range": 9.0, "width": 1.2, "knock": 10.0, "path_share": 0.4, 
		"color": Color(1, 0.9, 0.6), "sound": "charge_attack", 
		"per_level": {"damage": 48.0, "range": 0.4, "cooldown": -0.15}}, 


	"spear_boomerang": {"name": "Spear Boomerang", "lance": true, "type": "boomerang", 
		"desc": "Lanzas tu lanza girando hacia donde vas: atraviesa a todos y vuelve a tu mano golpeando otra vez.", 
		"cooldown": 1.6, "damage": 68.0, "range": 8.0, "width": 1.0, "count": 1.0, "knock": 2.0, 
		"color": Color(0.85, 0.9, 1.0), "sound": "spear_boomerang", 
		"per_level": {"damage": 22.0, "range": 0.4, "cooldown": -0.06}}, 


	"spiral_pierce": {"bleed_chance": 1.0, "name": "Spiral Pierce", "lance": true, "type": "drill", 
		"desc": "Clavas la lanza en el enemigo más fuerte y lo taladras cinco veces seguidas sin dejarlo moverse. Contra jefes y MVP pega más.", 
		"cooldown": 2.2, "damage": 81.0, "hits": 5.0, "range": 6.5, "boss_mult": 1.5, "knock": 6.0, 
		"color": Color(1, 0.95, 0.8), "sound": "spiral_drill", 
		"per_level": {"damage": 24.0, "cooldown": -0.1}}, 

	"aura_blade": {"name": "Aura Blade", "type": "passive", 
		"desc": "Pasiva: tu arma brilla con aura y multiplica tu ataque básico (aparte de los +% de daño básico; crece con el nivel).", 



		"bonus": ["aura_blade"], "aura_blade": 0.2, "color": Color(0.6, 0.8, 1.0), 
		"per_level": {"aura_blade": 0.05}}, 





	"meteor_storm": {"fx_lead": 0.55, "burn_chance": 1.0, "element": "fire", "name": "Meteor Storm", "magic": true, "type": "aoe_target", "fx": "meteor1", "fx_intensity": 0.55, "desc": "Meteoros que caen sobre los monstruos.", 


		"cooldown": 4.2, "damage": 174.7, "count": 3.0, "range": 10.0, "area": 2.6, 
		"color": Color(1, 0.5, 0.2), "sound": "meteor", 
		"per_level": {"damage": 45.9, "count": 0.5, "cooldown": -0.2}}, 
	"sharp_shooting": {"boss_dmg": 2.0, "archer_arrow": true, "uses_arrows": true, "name": "Sharp Shooting", "hit_sound": "arrow_hit", "type": "line", "desc": "Un disparo certero que atraviesa en línea recta a todos los monstruos con una ráfaga de viento y los hace sangrar; doble de daño a jefes y MVP. Tus trampas que cruza estallan al instante con el doble de daño.", 
		"cooldown": 1.8, "damage": 165.0, "count": 1.0, "width": 1.4, "range": 12.0, "bleed_chance": 0.5, "bleed_stacks": 2, 
		"knock": 3.0, "color": Color(0.85, 0.95, 0.9), "sound": "sharp_shooting", 
		"per_level": {"damage": 44.0, "cooldown": -0.1}}, 








	"throw_stone": {"thrown": true, "name": "Throw Stone", "type": "projectile", "proj_image": "pebble", "proj_scale": 0.4, "spin": 11.0, 
		"trail_tint": Color(0.75, 0.6, 0.42), "rock": true, "hit_sound": "earth_spike", "impact": 1.1, 
		"desc": "Lanzas una piedra que rebota de monstruo en monstruo y puede aturdirlos.", 
		"cooldown": 1.1, "damage": 22.0, "count": 1.0, "speed": 16.0, "pierce": 2.0, "range": 8.0, 
		"size": 0.34, "knock": 1.5, "status": "stun", "status_chance": 0.12, "status_time": 1.2, 
		"color": Color(0.85, 0.8, 0.7), "sound": "throw_stone", "sound_cd": 0.15, "sound_db": -4.0, "tour_wait": 0.1, 
		"per_level": {"damage": 7.0, "pierce": 0.5, "count": 0.25, "status_chance": 0.03, "cooldown": -0.05}}, 
	"envenom": {"element": "poison", "name": "Envenom", "type": "melee_arc", "venom_fx": true, "desc": "Golpe envenenado: daña y envenena a los enemigos frente a ti.", 
		"cooldown": 0.8, "damage": 49.6, "range": 3.8, "arc": 200.0, "knock": 2.0, "poison": 4.0, 
		"color": Color(0.6, 0.9, 0.4), "sound": "envenom", 
		"per_level": {"damage": 12.0, "poison": 0.75, "cooldown": -0.06}}, 
	"double_attack": {"name": "Double Attack", "type": "passive", "desc": "Pasiva: el ataque básico puede golpear dos veces. Pasado 100% suma más golpes: 150% es doble seguro y 50% de triple, 250% triple seguro y 50% de cuádruple.", 
		"bonus": ["double"], "double": 0.15, "color": Color(0.9, 0.9, 0.9), 
		"per_level": {"double": 0.07}}, 
	"improve_dodge": {"name": "Improve Dodge", "type": "passive", "desc": "Pasiva: más evasión y velocidad de movimiento.", 
		"bonus": ["dodge", "move"], "dodge": 0.04, "move": 0.02, "color": Color(0.8, 0.9, 1), 
		"per_level": {"dodge": 0.025, "move": 0.02}}, 
	"steal": {"name": "Steal", "type": "steal", "fx": "steal_coin", "desc": "Le robas zeny a un monstruo cercano.", 
		"cooldown": 4.0, "damage": 10.0, "range": 3.0, "zeny": 4.0, 
		"color": Color(1, 0.85, 0.3), "sound": "steal", 
		"per_level": {"zeny": 3.0, "damage": 4.0, "cooldown": -0.3}}, 
	"sonic_blow": {"bleed_chance": 1.0, "name": "Sonic Blow", "type": "melee_arc", "fx": "sonicblow", "desc": "Ocho tajos fulminantes de katar frente a ti.", 
		"cooldown": 1.6, "damage": 90.0, "range": 3.6, "arc": 90.0, "knock": 2.0, 
		"color": Color(1, 0.9, 0.8), "sound": "sonic_blow", 
		"per_level": {"damage": 26.0, "range": 0.2, "cooldown": -0.08}}, 



	"venom_dust": {"element": "poison", "name": "Venom Dust", "type": "aoe_target", "fx": "venomdust", "desc": "Nubes de polvo venenoso bajo los monstruos que se quedan unos segundos: dañan y vuelven a envenenar a quien siga dentro.", 
		"cooldown": 3.5, "damage": 22.0, "count": 2.0, "range": 8.0, "area": 2.2, "poison": 5.0, 
		"cloud": 4.0, "cloud_dmg": 0.2, "tick": 0.5, "shape": "square", "fx_center": true, "fx_size": 0.8, "fx_intensity": 0.7, "bubbles": true, 
		"color": Color(0.42, 0.72, 0.22), "sound": "venom_dust", 
		"per_level": {"damage": 7.0, "count": 0.5, "area": 0.2}}, 
	"cloaking": {"name": "Cloaking", "type": "buff", "cloak": 3.0, "desc": "Te ocultas en las sombras: más evasión y velocidad.", 
		"cooldown": 10.0, "bonus": ["dodge", "move"], "dodge": 0.06, "move": 0.08, 
		"color": Color(0.5, 0.5, 0.7), "sound": "cloaking", 
		"per_level": {"dodge": 0.02, "move": 0.02}}, 




	"meteor_assault": {"name": "Meteor Assault", "type": "meteor", "status": "stun", "status_chance": 0.15, "status_time": 1.5, 
		"blind_chance": 0.15, "blind_time": 3.0, "bleed_chance": 0.35, 
		"desc": "Estallas en una onda de energía oscura a tu alrededor: puede aturdir, cegar y hacer sangrar, y revienta la sangre de los que ya sangraban.", 
		"cooldown": 4.5, "damage": 80.0, "range": 3.4, "knock": 6.0, 
		"color": Color(1.0, 0.3, 0.85), "sound": "magnum", 
		"per_level": {"damage": 26.0, "range": 0.15, "status_chance": 0.04, "blind_chance": 0.04, "cooldown": -0.2}}, 
	"edp": {"name": "Enchant Deadly Poison", "type": "buff", "fx": "poison", "desc": "Más daño y tus ataques básicos envenenan. Assassin Cross: críticos letales desde daño crítico ×3.5 y más seguidos; algunos son Asesinatos (×3 y la sombra salta a 2 monstruos más).", 
		"cooldown": 10.0, "bonus": ["dmg", "poison_hit"], "dmg": 0.2, "poison_hit": 0.5, 
		"color": Color(0.6, 0.3, 0.8), "sound": "edp", 
		"per_level": {"dmg": 0.06, "poison_hit": 0.1}}, 

	"holy_light": {"hitscan": true, "element": "holy", "name": "Holy Light", "magic": true, "type": "projectile", "hit_fx": "holyhit", "desc": "Rayo de luz sagrada contra el enemigo más cercano.", 


		"cooldown": 0.8, "damage": 38.0, "count": 1.0, "speed": 18.0, "pierce": 1.0, "range": 9.0, 
		"size": 0.35, "color": Color(1, 1, 0.8), "sound": "beginspell", "sound_cd": 1.5, "sound_db": -8.0, 
		"per_level": {"damage": 8.4, "count": 0.3, "pierce": 0.3, "cooldown": -0.03}}, 
	"blessing": {"name": "Blessing", "type": "buff", "spr_fx": "fx_blessing", "desc": "Bendición: más daño de todo lo que haces, ataque básico y habilidades (y de los aliados cercanos).", 
		"cooldown": 12.0, "bonus": ["dmg"], "dmg": 0.08, 
		"color": Color(1, 0.95, 0.6), "sound": "blessing", 
		"per_level": {"dmg": 0.04}}, 


	"improve_concentration": {"name": "Improve Concentration", "type": "buff", "fx": "ac_concentration", 
		"desc": "Concentración: disparas más rápido y con más fuerza.", 
		"cooldown": 12.0, "bonus": ["aspd", "dmg"], "aspd": 0.08, "dmg": 0.04, 
		"color": Color(0.6, 1, 0.6), "sound": "concentration", 
		"per_level": {"aspd": 0.04, "dmg": 0.02}}, 
	"increase_agi": {"tex_fx": "agi_up", "tex_count": 3, "ring_fx": true, "sound_cd": 0.5, "sound_db": 0.0, "name": "Increase AGI", "type": "buff", "desc": "Más velocidad de movimiento y de ataque básico (también para los aliados cercanos).", 
		"cooldown": 12.0, "bonus": ["move", "aspd"], "move": 0.06, "aspd": 0.05, 
		"color": Color(0.6, 1, 0.7), "sound": "increase_agi", 
		"per_level": {"move": 0.02, "aspd": 0.03}}, 
	"angelus": {"name": "Angelus", "type": "buff", "fx": "angelus", "desc": "Los ángeles te protegen: más defensa (también a los aliados cercanos).", 
		"cooldown": 12.0, "bonus": ["armor"], "armor": 1.5, 
		"color": Color(1, 1, 0.85), "sound": "angelus", 
		"per_level": {"armor": 1.0}}, 






	"lex_aeterna": {"element": "holy", "name": "Lex Aeterna", "type": "lex", 
		"desc": "Marcas con la ley eterna a los enemigos más fuertes cerca de ti: la próxima habilidad que los golpea hace ×2 de daño (+0,1 por nivel). Con Aspersio, cada 4 golpes de tu ataque básico marcan al monstruo, y las explosiones de Aspersio también gastan la marca.", 
		"cooldown": 5.0, "count": 1.0, "range": 8.0, "mult": 2.0, "duration": 8.0, "color": Color(1, 0.95, 0.7), "sound": "lex_aeterna", 
		"over_add": {"count": 1.0}, "over_never": ["duration"], 
		"per_level": {"count": 0.5, "mult": 0.1, "cooldown": -0.3}}, 
	"signum_crucis": {"element": "holy", "name": "Signum Crucis", "type": "signum", 
		"desc": "La señal de la cruz debilita a los monstruos cercanos (una cruz sobre ellos): reciben más daño, y los no-muertos y demonios el doble.", 
		"cooldown": 6.0, "range": 5.0, "frail": 0.12, "duration": 4.5, "color": Color(1, 0.92, 0.55), "sound": "signum_crucis", 
		"per_level": {"frail": 0.04, "range": 0.4}}, 


	"ruwach": {"element": "holy", "name": "Ruwach", "magic": true, "type": "orbit", "sprite": "fx_sight", 
		"desc": "Llama sagrada que gira a tu alrededor y quema a los monstruos que toca.", 
		"cooldown": 1.8, "damage": 26.0, "range": 2.0, "knock": 3.0, "count": 1.0, "hit_every": 0.6, 
		"orbit_speed": 3.2, "color": Color(0.6, 0.8, 1), "sound": "ruwach", 
		"per_level": {"damage": 6.0, "range": 0.15, "count": 0.25}}, 



	"magnus_exorcismus": {"element": "holy", "name": "Magnus Exorcismus", "magic": true, "type": "ground", "fx_center": true, "fx": "magnus", 
		"desc": "Cruz sagrada en el suelo que purifica una y otra vez a los monstruos que la pisan.", 
		"shape": "cross", "fx_size": 0.55, "cooldown": 5.5, "damage": 24.0, "count": 1.0, "range": 9.0, "area": 3.2, 
		"duration": 3.2, "tick": 0.6, "color": Color(1, 1, 0.8), "sound": "magnus", 
		"per_level": {"damage": 8.4, "count": 0.4, "area": 0.25}}, 
	"sanctuary": {"element": "holy", "name": "Sanctuary", "magic": true, "type": "ground", "fx_center": true, "fx": "sanctuary", "on_self": true, 
		"desc": "Suelo sagrado: mientras estés dentro te cura, y daña a los monstruos que lo pisan.", 
		"shape": "square", "fx_size": 0.5, "cooldown": 7.0, "damage": 12.6, "area": 3.0, "heal_amount": 3.0, 
		"duration": 5.0, "tick": 0.7, "color": Color(0.7, 1, 0.8), "sound": "sanctuary", 
		"per_level": {"damage": 4.2, "area": 0.2, "heal_amount": 1.2}}, 
	"kyrie_eleison": {"name": "Kyrie Eleison", "type": "shield", "fx": "kyrie", "desc": "Barrera sagrada que absorbe daño (al aliado que más la necesite).", 
		"cooldown": 8.0, "amount": 35.0, "color": Color(0.8, 0.9, 1), "sound": "kyrie", 
		"per_level": {"amount": 14.0, "cooldown": -0.5}}, 
	"magnificat": {"name": "Magnificat", "type": "buff", "fx": "providence", "desc": "Cántico sagrado: tus habilidades y las de los aliados cercanos se recargan más rápido.", 
		"cooldown": 12.0, "bonus": ["haste"], "haste": 0.1, 
		"color": Color(1, 0.95, 0.8), "sound": "magnificat", 
		"per_level": {"haste": 0.04}}, 
	"assumptio": {"name": "Assumptio", "sound": "assumptio", "type": "shield", "fx": "asum", "fx_size": 1.2, "ring_fx": true, "sound_db": 0.0, "desc": "Gran escudo sagrado que se renueva a menudo (al aliado que más lo necesite).", 
		"cooldown": 7.0, "amount": 80.0, "color": Color(1, 0.95, 0.7), 
		"per_level": {"amount": 25.0, "cooldown": -0.4}}, 

	"frost_diver": {"element": "water", "status": "freeze", "status_chance": 0.5, "status_time": 3.0, 
		"name": "Frost Diver", "magic": true, "type": "ice_trail", "desc": "Cristales de hielo avanzan por el suelo y congelan.", 
		"cooldown": 1.8, "damage": 27.6, "count": 1.0, "range": 9.0, 
		"color": Color(0.6, 0.9, 1), "sound": "frost_diver", "hit_sound": "frost_hit", 
		"per_level": {"damage": 8.0, "count": 0.5, "status_chance": 0.08}}, 
	"stone_curse": {"element": "earth", "status": "stone", "status_chance": 0.6, "status_time": 4.0, 
		"name": "Stone Curse", "magic": true, "type": "aoe_target", "fx": "stonecurse", "desc": "Convierte en piedra a varios monstruos.", 
		"cooldown": 4.0, "damage": 6.0, "count": 2.0, "range": 8.0, "area": 0.9, 
		"color": Color(0.7, 0.7, 0.65), "sound": "stone_curse", 
		"per_level": {"count": 0.5, "status_chance": 0.06, "damage": 3.0}}, 
	"ankle_snare": {"over_dmg_step": 0.75, "name": "Ankle Snare", "type": "aoe_target", "trap": "trap_snare", "trap_size": 1.7, "jaws": "trap_snare", "snare": 3.0, "bleed_stacks": 3, "catch": 3.0, 
		"desc": "Trampa de osos en el camino de los monstruos: el que la pisa queda atrapado sin poder moverse y se desangra. No atrapa a jefes ni MVPs (la evolucionada sí).", 
		"cooldown": 4.0, "damage": 30.0, "count": 2.0, "range": 8.0, "area": 1.4, 
		"color": Color(0.75, 0.75, 0.8), "sound": "ankle_snare", 
		"per_level": {"damage": 12.0, "snare": 0.4, "catch": 0.5, "count": 0.3}}, 
	"sandman": {"over_dmg_step": 0.75, "status": "sleep", "status_chance": 0.7, "status_time": 4.0, 
		"name": "Sandman", "type": "aoe_target", "fx": "sandman", "trap": "trap_blue", "desc": "Trampa de arena que duerme al grupo que la pisa. Un monstruo dormido aguanta 3 golpes sin despertar y cada uno es un crítico con +60% de daño crítico.", 
		"cooldown": 5.0, "damage": 10.0, "count": 1.0, "range": 8.0, "area": 2.6, 
		"color": Color(0.95, 0.85, 0.6), "sound": "sandman", 
		"per_level": {"area": 0.25, "status_chance": 0.05, "damage": 4.0}}, 

	"throw_stone_x": {"thrown": true, "name": "Throw Stone EX", "type": "projectile", "proj_image": "pebble_hot", "proj_scale": 0.45, "spin": 13.0, "evolved": true, 
		"trail_tint": Color(1.0, 0.55, 0.25), "rock": true, "rock_hot": true, "hit_sound": "earth_spike", "impact": 1.7, "splash": 1.5, 
		"desc": "Una lluvia de rocas ardientes que rebotan por la horda, estallan al golpear y aturden a menudo.", 
		"cooldown": 0.8, "damage": 58.0, "count": 3.0, "speed": 18.0, "pierce": 6.0, "range": 9.0, 
		"size": 0.42, "knock": 2.0, "status": "stun", "status_chance": 0.3, "status_time": 1.4, 
		"color": Color(0.85, 0.8, 0.7), "sound": "throw_stone", "sound_cd": 0.15, "sound_db": -4.0, "tour_wait": 0.1}, 
	"envenom_x": {"element": "poison", "name": "Envenom EX", "type": "melee_arc", "evolved": true, "venom_fx": true, 
		"desc": "Golpe venenoso en arco amplio con un veneno muy duradero. Hace estallar el veneno que ya tienen: 2 tics de golpe, sin quitarles las cargas.", 





		"cooldown": 0.75, "damage": 108.0, "range": 4.4, "arc": 220.0, "knock": 1.5, "poison": 7.0, "poison_burst": 2.0, 
		"color": Color(0.6, 0.9, 0.4), "sound": "envenom"}, 
	"holy_light_x": {"hitscan": true, "element": "holy", "name": "Holy Light EX", "magic": true, "type": "projectile", "evolved": true, "hit_fx": "holyhit", 
		"desc": "Cuatro rayos sagrados que rebotan entre los monstruos.", 
		"cooldown": 0.75, "damage": 67.0, "count": 3.0, "speed": 20.0, "pierce": 2.0, "range": 10.0, 
		"size": 0.4, "color": Color(1, 1, 0.8), "sound": "beginspell", "sound_cd": 1.5, "sound_db": -8.0}, 
	"bash_x": {"status": "stun", "status_chance": 0.4, "status_time": 2.0, "name": "Bash EX", "type": "melee_arc", "evolved": true, 
		"desc": "Bash al máximo: golpe enorme en arco amplio que derriba a la horda.", 
		"cooldown": 0.55, "damage": 170.0, "range": 4.6, "arc": 260.0, "knock": 8.0, "bash_fx": true, 
		"color": Color(1, 0.9, 0.6), "sound": "bash"}, 
	"magnum_break_x": {"burn_chance": 1.0, "element": "fire", "name": "Magnum Break EX", "type": "aoe_self", "evolved": true, "fx": "firehit1", "fx_size": 3.4, 
		"desc": "Explosión de fuego gigante cada pocos segundos.", 
		"cooldown": 2.4, "damage": 190.0, "range": 6.0, "knock": 12.0, 
		"color": Color(1, 0.45, 0.1), "sound": "magnum"}, 



	"fire_bolt_x": {"over_dmg_step": BOLT_EX_STEP, "burn_chance": 0.5, "element": "fire", "name": "Fire Bolt EX", "magic": true, "type": "bolt", "evolved": true, 
		"desc": "Diez rayos de fuego caen del cielo.", 
		"cooldown": 1.2, "damage": 39.1, "count": 10.0, "range": 11.0, "bolt_gap": 0.07, 
		"bolt_tex": "bolt_fire", "bolt_blend": "add", "bolt_axis": Vector2(0, -1), "bolt_scale": 0.42, "bolt_stretch": 1.35, "bolt_time": 0.3, 
		"impact_tex": "impact_fire", "color": Color(1, 0.45, 0.15), 
		"sound": "fire_cast", "hit_sound": "fire_hit", "hit_sound_variants": 3}, 
	"cold_bolt_x": {"over_dmg_step": BOLT_EX_STEP, "element": "water", "status": "freeze", "status_chance": 0.3, "status_time": 2.5, "name": "Cold Bolt EX", "magic": true, "type": "bolt", "evolved": true, 
		"desc": "Diez fragmentos de hielo que frenan casi por completo y congelan más seguido.", 
		"cooldown": 1.2, "damage": 34.5, "count": 10.0, "range": 11.0, "slow": 3.5, "bolt_gap": 0.07, 
		"bolt_tex": "bolt_icearrow", "bolt_blend": "mix", "bolt_axis": Vector2(-0.99, -0.14), "bolt_scale": 0.55, "bolt_time": 0.3, 
		"color": Color(0.5, 0.85, 1), "sound": "cold_cast", "hit_sound": "cold_hit", "hit_sound_variants": 3}, 


	"soul_strike_x": {"over_dmg_step": BOLT_EX_STEP, "element": "ghost", "name": "Soul Strike EX", "magic": true, "type": "soul_strike", "evolved": true, "possess": true, 
		"desc": "El doble de espíritus fantasma. Wizard y High Wizard: el monstruo cuya marca detonan queda poseído 3 s y la siguiente reacción sobre él hace ×1,25 de daño.", 
		"cooldown": 0.8, "damage": 30.0, "count": 10.0, "range": 11.0, "missile_gap": 0.05, "flight": 0.42, 
		"color": Color(1.0, 0.97, 0.88), "sound": "soul_strike"}, 
	"fire_wall_x": {"burn_chance": 1.0, "element": "fire", "name": "Fire Wall EX", "magic": true, "type": "ground", "wall": true, "evolved": true, 
		"fx": "firewall", "fx_size": 0.7, "desc": "Tres muros de fuego más largos que arden más y empujan más lejos.", 
		"shape": "line", "arm": 2, "cooldown": 3.2, "damage": 55.2, "count": 3.0, "range": 8.0, "area": 2.5, 
		"duration": 5.0, "tick": 0.35, "knock": 5.0, "color": Color(1, 0.5, 0.2), "sound": "fire_wall"}, 
	"double_strafe_x": {"over_dmg_step": 1.0, "archer_arrow": true, "cast_fx": "flash", "hitscan": true, "air_hit": true, "uses_arrows": true, "name": "Double Strafe EX", "type": "projectile", "evolved": true, 
		"desc": "Cuatro flechas de golpe que rebotan.", 
		"cooldown": 0.45, "damage": 36.0, "count": 4.0, "speed": 24.0, "pierce": 2.0, "range": 10.0, 
		"size": 0.24, "same_target": true, "arrow": true, "color": Color(0.95, 0.9, 0.75), 
		"sound": "bow", "sound_cd": 2.5, "sound_db": -6.0, "hit_sound": "arrow_hit"}, 


	"arrow_shower_x": {"over_dmg_step": 1.0, "archer_arrow": true, "uses_arrows": true, "name": "Arrow Shower EX", "type": "bolt", "evolved": true, "rain": 0.5, "waves": 2, 
		"desc": "Una tormenta de flechas: dos andanadas seguidas sobre los grupos más densos, con más flechas, más grandes y en un área mucho mayor.", 
		"cooldown": 2.0, "damage": 44.0, "count": 22.0, "range": 11.0, "area": 4.0, "hit_radius": 1.1, "max_hits": 2, "knock": 6.5, 
		"rain_span": 0.45, "bolt_tex": "arrow", "bolt_blend": "mix", "bolt_axis": Vector2(-0.7071, 0.7071), "bolt_scale": 2.0, 
		"bolt_time": 0.22, "streak_len": 3.0, "color": Color(1.0, 0.88, 0.55), 
		"sound": "arrowshower", "hit_sound": "arrow_hit"}, 
	"tracking_x": {"hitscan": true, "hit_sprite": "fx_tracking", "uses_arrows": true, "name": "Tracking EX", "type": "projectile", "evolved": true, 
		"hunt": true, "same_target": true, 
		"desc": "Dos disparos certeros al monstruo más fuerte a tu alcance (jefes y MVP primero); cada uno pega con todo.", 
		"cooldown": 1.1, "damage": 1100.0, "count": 2.0, "speed": 34.0, "pierce": 0.0, "range": 12.0, 
		"size": 0.2, "color": Color(1, 0.95, 0.7), "sound": "gun_rifle"}, 
	"desperado_x": {"uses_arrows": true, "spr_fx": "fx_desperado", "hit_sprite": "fx_triple", "name": "Desperado EX", "type": "aoe_self", "evolved": true, "grenades": true, 
		"desc": "Una ráfaga enorme de disparos en todas direcciones.", 
		"cooldown": 1.6, "damage": 105.0, "range": 7.0, "knock": 4.0, 
		"color": Color(1, 0.85, 0.5), "sound": "desperado"}, 
	"bowling_bash_x": {"name": "Bowling Bash EX", "fx": "bowling", "type": "melee_arc", "evolved": true, "bowl": true, 
		"desc": "Un golpe circular gigante: los monstruos lanzados derriban a otros, y esos a los siguientes; a los amontonados les pega dos veces.", 
		"cooldown": 1.0, "damage": 270.0, "range": 5.6, "arc": 360.0, "knock": 15.0, 
		"color": Color(1, 0.85, 0.5), "sound": "bowling"}, 
	"ignition_break_x": {"burn_chance": 1.0, "burn_long": 3.0, "element": "fire", "ignition": true, "name": "Ignition Break EX", "type": "aoe_self", "evolved": true, 
		"detonate": 0.25, "spread": 12, 
		"desc": "Los monstruos que ya arden estallan con parte de su fuego, sin apagarse, y el fuego salta a los de alrededor. Luego un gran estallido los vuelve a encender con llamas largas.", 
		"cooldown": 2.4, "damage": 160.0, "range": 5.8, "knock": 5.0, 
		"color": Color(1, 0.45, 0.1), "sound": "magnum"}, 
	"grand_cross_x": {"element": "holy", "name": "Grand Cross EX", "type": "ground", "on_self": true, "fx": "red_cross", "center_fx": "cross", "evolved": true, "tank_hp": 0.0105, "tank_def": 4.5, 
		"desc": "Una cruz sagrada enorme de casillas que golpea cuatro veces; arrasa con no-muertos y demonios. Su daño escala con tu vida y defensa.", 
		"shape": "gc", "arm": 3, "fx_size": 0.45, "cooldown": 1.6, "damage": 85.0, "area": 5.6, "duration": 1.2, "tick": 0.3, 
		"color": Color(1, 0.95, 0.7), "sound": "grand_cross"}, 
	"quagmire_x": {"element": "earth", "name": "Quagmire EX", "magic": true, "type": "ground", "evolved": true, "fx": "quagmire", "fx_size": 1.0, 
		"desc": "Un pantano enorme y más duradero: atrapa a todos, los debilita mucho más y los deja mojados para tus combos.", 
		"shape": "square", "cooldown": 4.0, "damage": 60.0, "count": 2.0, "range": 9.0, "area": 4.0, "duration": 7.0, "tick": 0.4, 
		"zone_slow": 1.0, "combo_mark": "water", "acid": 0.4, "color": Color(0.6, 0.5, 0.35), "sound": "quagmire"}, 
	"storm_gust_x": {"fx_lead": 0.25, "element": "water", "status": "freeze", "status_chance": 0.7, "status_time": 3.5, "name": "Storm Gust EX", "magic": true, "fx": "stormgust", "fx_intensity": 0.3, "type": "aoe_target", "evolved": true, 
		"desc": "Dos ventiscas a la vez que congelan casi seguro.", 


		"cooldown": 3.0, "damage": 380.0, "count": 2.0, "range": 11.0, "area": 6.0, "slow": 3.5, 
		"color": Color(0.6, 0.85, 1), "sound": "stormgust"}, 
	"heavens_drive_x": {"impact_fx": true, "element": "earth", "name": "Heaven's Drive EX", "magic": true, "type": "aoe_target", "fx": "earthhit", "evolved": true, 
		"desc": "Picos de roca brotan bajo seis grupos de monstruos a la vez.", 
		"cooldown": 1.8, "damage": 201.2, "count": 6.0, "range": 11.0, "area": 3.8, 
		"color": Color(0.75, 0.6, 0.4), "sound": "earth_spike"}, 
	"falcon_assault_x": {"over_dmg_step": 1.0, "name": "Falcon Assault EX", "type": "falcon_assault", "evolved": true, "tour_wait": 0.4, 
		"desc": "Tu halcón se lanza tres veces seguidas sobre los enemigos más fuertes, con golpes aún mayores: ×1,5 contra jefes y MVP.", 
		"cooldown": 2.5, "damage": 820.0, "count": 3.0, "range": 12.0, "area": 2.0, 
		"color": Color(1, 0.8, 0.4), "sound": "blitz"}, 



	"blitz_beat_x": {"over_dmg_step": 0.6, "name": "Blitz Beat EX", "type": "passive", "falcon_passive": true, "evolved": true, 
		"desc": "Pasiva: tu halcón no para: se lanza solo mucho más seguido, sobre diez monstruos y con picadas más fuertes. Con más SUE, más seguido.", 
		"bonus": ["auto_blitz"], "auto_blitz": 0.3, "damage": 120.0, "count": 10.0, "range": 11.0, "area": 1.8, 
		"color": Color(1, 0.75, 0.35), "sound": "blitz"}, 
	"musical_strike_x": {"uses_arrows": true, "name": "Musical Strike EX", "type": "projectile", "evolved": true, 
		"desc": "Tres flechas musicales que rebotan entre los monstruos. En cada Bis, otra andanada.", 
		"cooldown": 0.55, "damage": 135.0, "count": 3.0, "speed": 24.0, "pierce": 8.0, "range": 11.0, 
		"size": 0.27, "arrow": true, "streak": Color(1.0, 0.75, 0.95), "color": Color(0.95, 0.9, 0.75), "sound": "bow", "hit_sound": "arrow_hit"}, 
	"fire_rain_x": {"element": "fire", "name": "Fire Rain EX", "type": "aoe_target", "fx": "rl_fire_rain/fire_rain", "evolved": true, 
		"desc": "Una tormenta de balas de fuego sobre ocho grupos.", 
		"cooldown": 2.4, "damage": 215.0, "count": 8.0, "range": 10.0, "area": 2.6, 
		"color": Color(1, 0.5, 0.2), "sound": "fire_rain"}, 


	"meteor_assault_x": {"name": "Meteor Assault EX", "type": "meteor", "evolved": true, "status": "stun", "status_chance": 0.6, "status_time": 1.8, 
		"blind_chance": 0.6, "blind_time": 3.5, "bleed_chance": 1.0, "bleed_stacks": 2, 
		"aftershock": 0.35, "aftershock_range": 1.5, "aftershock_dmg": 0.7, 
		"desc": "Dos ondas: la primera aturde, ciega y siempre hace sangrar; un instante después la réplica, más amplia, golpea de nuevo y revienta toda esa sangre.", 
		"cooldown": 2.4, "damage": 360.0, "range": 5.0, "knock": 7.0, 
		"color": Color(1.0, 0.3, 0.85), "sound": "magnum"}, 
	"sonic_blow_x": {"bleed_chance": 1.0, "name": "Sonic Blow EX", "type": "melee_arc", "fx": "sonicblow", "evolved": true, 
		"desc": "Tajos fulminantes de katar en un arco amplio.", 
		"cooldown": 1.0, "damage": 350.0, "range": 4.4, "arc": 130.0, "knock": 4.0, 
		"color": Color(1, 0.9, 0.8), "sound": "sonic_blow"}, 
	"back_stab_x": {"bleed_chance": 1.0, "name": "Back Stab EX", "type": "backstab", "evolved": true, "escalate": true, 
		"desc": "Una cadena de ocho espaldas hacia donde caminas: cada salto multiplica el daño, la probabilidad de crítico y el daño crítico. La SUE puede sumar más saltos, sin límite, cada uno menos probable.", 
		"cooldown": 1.8, "damage": 290.0, "count": 8.0, "range": 9.0, "area": 1.8, "knock": 2.0, 
		"color": Color(0.9, 0.8, 1.0), "sound": "back_stab"}, 
	"magnus_exorcismus_x": {"element": "holy", "name": "Magnus Exorcismus EX", "magic": true, "type": "ground", "fx_center": true, "fx": "magnus", "evolved": true, 
		"desc": "Cuatro cruces sagradas que purifican el suelo durante más tiempo.", 
		"shape": "cross", "fx_size": 0.55, "cooldown": 4.5, "damage": 100.0, "count": 4.0, "range": 10.0, "area": 4.8, 
		"duration": 4.5, "tick": 0.55, "color": Color(1, 1, 0.8), "sound": "magnus"}, 
	"investigate_x": {"name": "Occult Impaction EX", "type": "line", "line_fx": "investigate", "evolved": true, 
		"desc": "Golpes de ki que atraviesan al enemigo y arrasan con todo lo que hay detrás, más lejos y más ancho.", 
		"cooldown": 0.65, "damage": 340.0, "count": 1.0, "range": 5.0, "length": 10.0, "width": 2.0, "knock": 6.0, 
		"color": Color(1, 0.95, 0.7), "sound": "hit_fist"}, 

	"triple_action": {"hitscan": true, "hit_sprite": "fx_triple", "uses_arrows": true, "name": "Triple Action", "type": "projectile", "desc": "Tres disparos rápidos al enemigo más cercano.", 
		"cooldown": 0.7, "damage": 15.0, "count": 3.0, "speed": 28.0, "pierce": 0.0, "range": 9.5, 
		"size": 0.12, "same_target": true, "color": Color(1, 0.9, 0.55), "sound": "triple_action", "sound_cd": 0.25, "sound_db": -8.0, 
		"per_level": {"damage": 4.0, "count": 0.5, "cooldown": -0.03}}, 
	"desperado": {"uses_arrows": true, "spr_fx": "fx_desperado", "hit_sprite": "fx_triple", "name": "Desperado", "type": "aoe_self", "grenades": true, "desc": "Disparos en todas direcciones alrededor tuyo.", 
		"cooldown": 3.0, "damage": 26.0, "range": 4.2, "knock": 3.0, 
		"color": Color(1, 0.85, 0.5), "sound": "desperado", 
		"per_level": {"damage": 8.0, "range": 0.3, "cooldown": -0.15}}, 
	"tracking": {"hitscan": true, "hit_sprite": "fx_tracking", "uses_arrows": true, "name": "Tracking", "type": "projectile", 
		"hunt": true, "desc": "Disparo certero y potente al monstruo más fuerte a tu alcance (jefes y MVP primero).", 
		"cooldown": 2.0, "damage": 150.0, "count": 1.0, "speed": 32.0, "pierce": 0.0, "range": 11.0, 
		"size": 0.18, "color": Color(1, 0.95, 0.7), "sound": "gun_rifle", 
		"per_level": {"damage": 40.0, "cooldown": -0.1}}, 
	"spread_attack": {"uses_arrows": true, "spr_fx": "fx_spread", "spr_dir": true, "hit_sprite": "fx_triple", "name": "Spread Attack", "type": "aoe_target", "desc": "Perdigones de escopeta sobre un grupo.", 
		"cooldown": 2.8, "damage": 30.0, "count": 2.0, "range": 8.0, "area": 2.5, 
		"color": Color(1, 0.8, 0.45), "sound": "gun_shotgun", 
		"per_level": {"damage": 8.0, "count": 0.5, "area": 0.2}}, 
	"gatling_fever": {"name": "Gatling Fever", "type": "buff", "desc": "Fiebre de metralla: más velocidad de ataque y daño.", 
		"cooldown": 12.0, "bonus": ["aspd", "dmg"], "aspd": 0.1, "dmg": 0.04, "color": Color(1, 0.6, 0.3), "sound": "gun_gatling", 
		"spr_fx": "fx_desperado", "spr_size": 0.6, 
		"per_level": {"aspd": 0.04, "dmg": 0.02}}, 




	"heat_barrel": {"name": "Heat Barrel", "type": "heat", "fx": "rl_heat_barrel/htb", 
		"desc": "Quieto, el cañón se pone al rojo: disparas cada vez más rápido y fuerte (más con monedas). Al moverte se enfría.", 
		"aspd": 0.12, "dmg": 0.1, "coin_aspd": 0.012, "coin_dmg": 0.015, 
		"range": 10.0, "color": Color(1.0, 0.45, 0.2), "sound": "gun_gatling", 
		"per_level": {"aspd": 0.04, "dmg": 0.03}}, 
	"fire_rain": {"element": "fire", "name": "Fire Rain", "type": "aoe_target", "fx": "rl_fire_rain/fire_rain", "desc": "Lluvia de balas de fuego sobre la horda.", 
		"cooldown": 3.5, "damage": 55.0, "count": 3.0, "range": 9.0, "area": 2.0, 
		"color": Color(1, 0.5, 0.2), "sound": "fire_rain", 
		"per_level": {"damage": 16.0, "count": 0.5}}, 
	"banishing_buster": {"hitscan": true, "uses_arrows": true, "name": "Banishing Buster", "type": "projectile", "hit_fx": "rl_banishing_buster/vanishing1", 
		"pierce_line": true, "knock": 2.5, 
		"desc": "Bala que atraviesa en línea recta a todos los monstruos y los empuja.", 
		"cooldown": 2.5, "damage": 110.0, "count": 1.0, "speed": 30.0, "pierce": 30.0, "range": 12.0, 
		"size": 0.3, "color": Color(0.8, 0.9, 1), "sound": "banishing_buster", 
		"per_level": {"damage": 30.0, "cooldown": -0.12}}, 
	"slug_shot": {"hitscan": true, "uses_arrows": true, "name": "Slug Shot", "type": "projectile", "hit_fx": "rl_slugshot/slug", 
		"desc": "Disparo pesado que empuja y rebota a varios.", 
		"cooldown": 2.0, "damage": 90.0, "count": 1.0, "speed": 24.0, "pierce": 3.0, "range": 10.0, 
		"size": 0.28, "knock": 10.0, "color": Color(1, 0.85, 0.6), "sound": "slug_shot", 
		"per_level": {"damage": 26.0, "pierce": 0.5}}, 
	"hammer_of_god": {"fx_lead": 0.55, "status": "stun", "status_chance": 0.5, "status_time": 2.0, 
		"name": "Hammer of God", "type": "aoe_target", "fx": "rl_hamer_god/hogg", "desc": "Un martillo divino de balas aplasta un área enorme.", 
		"cooldown": 5.0, "damage": 160.0, "count": 1.0, "range": 10.0, "area": 3.6, 
		"color": Color(1, 0.95, 0.7), "sound": "hammer_of_god", 
		"per_level": {"damage": 45.0, "area": 0.2}}, 
	"making_arrow": {"name": "Making Arrow", "type": "passive", 
		"desc": "Fabrica todas las flechas elementales para el carcaj y te deja cambiarlas en combate con C / V. Con una flecha elemental, +5% de daño por nivel a todo lo que disparas (ataque básico y habilidades con flechas).", 
		"bonus": ["arrow_dmg"], "arrow_dmg": 0.05, "color": Color(0.9, 0.85, 0.6), 
		"per_level": {"arrow_dmg": 0.05}}, 


	"throw_shuriken": {"hit_fx": "hit", "impact": 0.55, "trail_tint": Color(0.7, 0.8, 1.0), "thrown": true, "uses_arrows": true, "ammo_sprite": true, "name": "Throw Shuriken", "type": "projectile", "proj_sprite": "item_shuriken", "spin": 24.0, 
		"desc": "Lanzas shuriken giratorios a los enemigos más cercanos. Con un kunai equipado lanzas kunai de su elemento (C / V).", 
		"cooldown": 0.65, "damage": 18.0, "count": 2.0, "speed": 18.0, "pierce": 0.0, "range": 9.0, 
		"size": 0.3, "knock": 1.0, "color": Color(0.85, 0.9, 1), "sound": "ninja_throw", "sound_cd": 0.2, "sound_db": -6.0, "tour_wait": 0.08, 
		"per_level": {"damage": 6.0, "count": 0.5, "cooldown": -0.03}}, 
	"throw_kunai": {"hit_fx": "hit", "impact": 0.55, "trail_tint": Color(0.7, 0.8, 1.0), "thrown": true, "uses_arrows": true, "ammo_sprite": true, "name": "Throw Kunai", "type": "projectile", 
		"proj_sprite": "item_heat_wave_kunai", "spin": 18.0, 
		"desc": "Tres kunai seguidos al mismo enemigo, del elemento del kunai que llevas. Cámbialo con C / V.", 
		"cooldown": 1.0, "damage": 18.0, "count": 3.0, "speed": 22.0, "pierce": 0.0, "range": 9.5, "same_target": true, "shot_gap": 0.07, 
		"size": 0.26, "knock": 1.0, "color": Color(1, 0.9, 0.8), "sound": "ninja_throw", "sound_cd": 0.2, "sound_db": -6.0, "tour_wait": 0.08, 
		"per_level": {"damage": 6.0, "cooldown": -0.05}}, 
	"throw_huuma": {"huuma_form": {"dmg": 1.5, "splash": 1.5, "size": 1.25}, "flair": {"ring": 2.0}, "hit_fx": "hit", "impact": 1.4, "trail_tint": Color(0.7, 0.8, 1.0), "thrown": true, "name": "Throw Huuma Shuriken", "type": "projectile", "proj_sprite": "item_huuma", "spin": 16.0, 
		"sprite_scale": 2.0, "splash": 1.6, 
		"desc": "Lanzas un enorme Huuma Shuriken que rebota a varios y golpea a los de alrededor. Con una Huuma equipada pega más, abarca más y usa su elemento.", 
		"cooldown": 2.2, "damage": 55.0, "count": 1.0, "speed": 13.0, "pierce": 3.0, "range": 9.0, 
		"size": 0.6, "knock": 4.0, "color": Color(1, 0.85, 0.7), "sound": "ninja_throw", "sound_db": -3.0, "tour_wait": 0.1, 
		"per_level": {"damage": 16.0, "pierce": 0.5, "cooldown": -0.1}}, 

	"kraken_huuma": {"hit_fx": "hit", "impact": 2.2, "trail_tint": Color(0.7, 0.8, 1.0), "thrown": true, "element": "water", "name": "Huuma Kraken", "type": "projectile", "proj_sprite": "item_huuma", "spin": 18.0, 
		"sprite_scale": 2.2, "status": "freeze", "status_chance": 0.15, "status_time": 2.5, 
		"desc": "Huuma de agua del Kraken: salta entre muchos monstruos y puede congelarlos.", 
		"cooldown": 1.0, "damage": 60.0, "count": 1.0, "speed": 15.0, "pierce": 8.0, "range": 10.0, 
		"size": 0.6, "knock": 2.0, "color": Color(0.45, 0.75, 1.0), "sound": "ninja_throw", "sound_db": -6.0, 
		"per_level": {"damage": 15.0, "status_chance": 0.03}}, 
	"throw_zeny": {"name": "Throw Zeny", "type": "projectile", "proj_sprite": "fx_coin", "zeny_cost": 8.0, 
		"desc": "Lanzas un puñado de zeny de la partida: daño enorme a un enemigo. Sin zeny pega mucho menos.", 
		"cooldown": 1.6, "damage": 90.0, "count": 1.0, "speed": 20.0, "pierce": 0.0, "range": 9.0, 
		"size": 0.35, "knock": 2.0, "color": Color(1, 0.9, 0.4), "sound": "throw_zeny", "sound_extra": "coin2", "hit_fx": "steal_coin", "tour_wait": 0.1, 
		"per_level": {"damage": 28.0, "zeny_cost": 4.0, "cooldown": -0.06}}, 
	"flaming_petals": {"element": "fire", "magic": true, "ninjutsu": true, "name": "Flaming Petals", "type": "projectile", "proj_sprite": "fx_kaensin", 
		"desc": "Pétalos de fuego vuelan hacia varios enemigos.", 
		"cooldown": 1.2, "damage": 16.0, "count": 3.0, "speed": 14.0, "pierce": 0.0, "range": 9.0, 
		"size": 0.3, "knock": 1.0, "color": Color(1, 0.55, 0.2), "sound": "fire_cast", "sound_db": -6.0, "hit_fx": "firehit1", "hit_fx_intensity": 0.6, 
		"hit_sounds": ["fire_hit1", "fire_hit2", "fire_hit3"], "tour_wait": 0.1, 
		"per_level": {"damage": 5.0, "count": 1.0, "cooldown": -0.04}}, 
	"freezing_spear": {"hit_fx": "hit", "impact": 0.8, "trail_tint": Color(0.55, 0.85, 1.0), "element": "water", "magic": true, "ninjutsu": true, "name": "Freezing Spear", "type": "projectile", "proj_tex": "ice_spear", "proj_frames": 1, 
		"proj_blend": "mix", "proj_scale": 1.6, 
		"desc": "Lanzas de hielo seguidas contra un enemigo: rebotan y ralentizan.", 
		"cooldown": 1.1, "damage": 24.0, "count": 2.0, "speed": 20.0, "pierce": 1.0, "range": 9.0, "same_target": true, "shot_gap": 0.06, 
		"size": 0.3, "slow": 1.2, "knock": 1.0, "color": Color(0.6, 0.9, 1), "sound": "cold_cast", "sound_db": -6.0, "hit_sounds": ["cold_hit1", "cold_hit2", "cold_hit3"], 
		"per_level": {"damage": 7.0, "count": 0.5, "cooldown": -0.04}}, 
	"lightning_crash": {"element": "wind", "magic": true, "ninjutsu": true, "status": "stun", "status_chance": 0.1, "status_time": 1.2, 
		"name": "Lightning Crash", "type": "aoe_self", "fx": "thunderstorm", "fx_size": 0.9, 
		"desc": "Rayos caen a tu alrededor y pueden aturdir.", 
		"cooldown": 2.6, "damage": 42.0, "range": 3.2, "knock": 3.0, "color": Color(1, 1, 0.55), "sound": "lightning_crash", 
		"per_level": {"damage": 13.0, "range": 0.25, "status_chance": 0.02, "cooldown": -0.1}}, 
	"shadow_slash": {"name": "Shadow Slash", "type": "backstab", "hit_sprite": "fx_kirikage", "hit_sound_bs": "shadow_slash", 
		"desc": "Saltas de sombra en sombra hacia donde caminas, cortando a cada monstruo a su espalda. Se puede apagar.", 
		"cooldown": 2.6, "damage": 95.0, "count": 3.0, "range": 7.0, "area": 1.2, "knock": 2.0, 
		"color": Color(0.7, 0.6, 1.0), "sound": "shadow_slash", 
		"per_level": {"damage": 32.0, "range": 0.4, "cooldown": -0.08}}, 
	"ninja_aura": {"name": "Ninja Aura", "type": "buff", "flair": {"ring": 3.0, "rays": 1.0}, 
		"desc": "Concentras tu aura: más Fuerza e Inteligencia para ti y los aliados cercanos.", 
		"cooldown": 12.0, "bonus": ["aura_stats"], "aura_stats": 4.0, "color": Color(0.75, 0.6, 1.0), "sound": "mist_slash", "sound_db": -4.0, 
		"per_level": {"aura_stats": 3.0}}, 
	"ninja_aura_x": {"name": "Ninja Aura EX", "type": "buff", "evolved": true, "flair": {"ring": 4.0, "rays": 1.4}, 
		"desc": "Un aura desbordante: mucha más Fuerza e Inteligencia para ti y los aliados cercanos.", 
		"cooldown": 9.0, "bonus": ["aura_stats"], "aura_stats": 30.0, "color": Color(0.75, 0.6, 1.0), "sound": "mist_slash", "sound_db": -4.0}, 
	"mirror_image_x": {"flair": {"ring": 4.0, "rays": 1.4, "column": true}, "name": "Mirror Image EX", "type": "mirror", "evolved": true, 
		"desc": "Más sombras, más seguido, y pelean contigo: cada sombra repite tus ataques básicos (solo los básicos, no las habilidades) con un 20% de su daño, y un poco más con cada nivel pasado el máximo.", 


		"cooldown": 4.5, "count": 5.0, "mult": SHADOW_STRIKE, "color": Color(0.6, 0.6, 1.0), "sound": "mist_slash", "sound_db": -4.0}, 
	"mirror_image": {"flair": {"ring": 3.0, "rays": 1.0, "column": true}, "name": "Mirror Image", "type": "mirror", 
		"desc": "Creas sombras de ti mismo a tu alrededor: cada una recibe un golpe por ti y desaparece.", 
		"cooldown": 9.0, "count": 2.0, "color": Color(0.6, 0.6, 1.0), "sound": "mist_slash", "sound_db": -4.0, 
		"per_level": {"count": 0.5, "cooldown": -0.8}}, 
	"cross_slash": {"flair": {"ring": 3.0, "shake": 0.15}, "bleed_chance": 1.0, "name": "Cross Slash", "type": "melee_arc", "fx": "jyumonjikiri", "fx_size": 1.0, "fx_y": -2.2, "hit_sprite": "fx_kirikage", 
		"desc": "Corte en cruz con tus dagas: daño enorme frente a ti y hace sangrar.", 
		"cooldown": 1.1, "damage": 90.0, "range": 3.4, "arc": 160.0, "knock": 3.0, 
		"color": Color(1, 0.85, 0.85), "sound": "shadow_slash", 
		"per_level": {"damage": 26.0, "range": 0.15, "cooldown": -0.05}}, 
	"kunai_splash": {"huuma_form": {"dmg": 2.5, "count": 0.4, "size": 2.2, "scale": 2.0, "pierce": 99}, "flair": {"ring": 4.0, "rays": 1.0}, "thrown": true, "uses_arrows": true, "ammo_sprite": true, "name": "Kunai Splash", "type": "radial", 
		"proj_sprite": "item_heat_wave_kunai", "spin": 18.0, 
		"desc": "Lanzas kunai en todas direcciones, del elemento del kunai que llevas. Con una Huuma equipada lanzas menos, pero son Huumas gigantes que lo atraviesan todo.", 
		"cooldown": 2.0, "damage": 34.0, "count": 8.0, "speed": 16.0, "pierce": 1.0, "range": 7.0, 
		"size": 0.28, "knock": 2.0, "color": Color(1, 0.9, 0.8), "sound": "ninja_throw", 
		"per_level": {"damage": 10.0, "count": 1.0, "cooldown": -0.1}}, 
	"exploding_dragon": {"impact_fx": true, "element": "fire", "magic": true, "ninjutsu": true, "name": "Exploding Dragon", "type": "aoe_target", "fx": "firehit1", "hit_sprite": "fx_kaensin", "hit_sprites": 5, "hit_sprite_size": 0.9, 
		"desc": "Un dragón de fuego estalla sobre grupos de enemigos.", 
		"cooldown": 3.2, "damage": 80.0, "count": 2.0, "range": 9.0, "area": 2.2, 
		"color": Color(1, 0.45, 0.15), "sound": "exploding_dragon", 
		"per_level": {"damage": 24.0, "count": 0.5, "area": 0.15}}, 
	"killing_strike": {"tank_hp": 0.3, "tank_def": 25.0, "name": "Final Strike", "type": "issen", "spr_fx": "fx_issen", 
		"desc": "Sacrificas parte de tu vida para un único tajo devastador. Pega más cuanta más vida y defensa tienes.", 
		"cooldown": 5.0, "damage": 220.0, "hp_power": 0.5, "hp_cost": 0.1, "range": 6.0, "area": 1.4, "knock": 6.0, 
		"color": Color(0.85, 0.85, 1.0), "sound": "final_strike", 
		"per_level": {"damage": 60.0, "hp_power": 0.15, "cooldown": -0.3}}, 
	"izayoi": {"name": "Izayoi", "type": "buff", "fx": "ac_concentration", 
		"desc": "Bajo la luna creciente tus habilidades pegan más y se recargan antes.", 
		"cooldown": 14.0, "bonus": ["skill_dmg", "haste"], "skill_dmg": 0.06, "haste": 0.04, "color": Color(0.8, 0.8, 1.0), "sound": "mist_slash", 
		"per_level": {"skill_dmg": 0.03, "haste": 0.02}}, 
	"right_hand_mastery": {"name": "Right Hand Mastery", "type": "passive", 
		"desc": "Pasiva: la daga de tu mano derecha pega más fuerte en el ataque básico y puede hacer sangrar.", 
		"bonus": ["basic_dmg", "bleed_hit"], "basic_dmg": 0.1, "bleed_hit": 0.1, "color": Color(0.9, 0.8, 0.85), "per_level": {"basic_dmg": 0.08, "bleed_hit": 0.05}}, 
	"left_hand_mastery": {"name": "Left Hand Mastery", "type": "passive", 
		"desc": "Pasiva: tu ataque básico puede golpear dos veces y el sangrado revienta más fuerte (con cualquier arma, también katar). Con dos armas, la de la mano izquierda pega y aporta más.", 
		"bonus": ["double", "offhand", "bleed_dmg"], "double": 0.12, "offhand": 0.1, "bleed_dmg": 0.1, "color": Color(0.85, 0.8, 0.9), 
		"per_level": {"double": 0.06, "offhand": 0.06, "bleed_dmg": 0.1}}, 
	"shuriken_training": {"name": "Shuriken Training", "type": "passive", 
		"desc": "Pasiva: tus shuriken, kunai y Huuma pegan más fuerte.", 
		"bonus": ["throw_dmg"], "throw_dmg": 0.1, "color": Color(0.85, 0.9, 1), "per_level": {"throw_dmg": 0.06}}, 
	"ninja_mastery": {"name": "Ninja Mastery", "type": "passive", 
		"desc": "Pasiva: dominas el ninjutsu: tus habilidades se recargan antes y tus quemaduras arden más.", 
		"bonus": ["haste", "burn_power"], "haste": 0.04, "burn_power": 0.1, "color": Color(0.7, 0.6, 1), "per_level": {"haste": 0.055, "burn_power": 0.1}}, 
	"cicada_skin_shed": {"name": "Cicada Skin Shed", "type": "passive", 
		"desc": "Pasiva: cada pocos segundos esquivas del todo un golpe, dejas tu piel atrás y saltas hacia atrás. También tienes más vida máxima.", 
		"bonus": ["cicada", "max_hp_pct"], "cicada": 5.0, "max_hp_pct": 0.04, "color": Color(0.8, 0.9, 0.7), "per_level": {"cicada": 1.75, "max_hp_pct": 0.04}}, 

	"throw_shuriken_x": {"hit_fx": "hit", "impact": 0.8, "trail_tint": Color(0.7, 0.8, 1.0), "thrown": true, "uses_arrows": true, "ammo_sprite": true, "name": "Throw Shuriken EX", "type": "projectile", "proj_sprite": "item_shuriken", "spin": 26.0, "evolved": true, 
		"desc": "Una ráfaga de shuriken, o de kunai de tu elemento, contra el monstruo más duro: cada golpe seguido pega más.", 
		"cooldown": 0.5, "damage": 48.0, "count": 6.0, "speed": 20.0, "pierce": 0.0, "range": 10.0, "hunt": true, 
		"size": 0.32, "knock": 1.5, "color": Color(0.85, 0.9, 1), "sound": "ninja_throw", "sound_cd": 0.2, "sound_db": -6.0, "tour_wait": 0.08}, 
	"throw_kunai_x": {"hit_fx": "hit", "impact": 0.8, "trail_tint": Color(0.7, 0.8, 1.0), "thrown": true, "uses_arrows": true, "ammo_sprite": true, "name": "Throw Kunai EX", "type": "projectile", "evolved": true, 
		"proj_sprite": "item_heat_wave_kunai", "spin": 20.0, 
		"desc": "Cinco kunai a la vez que rebotan, del elemento del kunai que llevas.", 
		"cooldown": 0.8, "damage": 60.0, "count": 5.0, "speed": 24.0, "pierce": 1.0, "range": 10.0, 
		"size": 0.28, "knock": 1.5, "color": Color(1, 0.9, 0.8), "sound": "ninja_throw", "sound_cd": 0.2, "sound_db": -6.0, "tour_wait": 0.08}, 
	"throw_huuma_x": {"huuma_form": {"dmg": 1.5, "splash": 1.5, "size": 1.25}, "boomerang": true, "flair": {"ring": 3.0, "rays": 1.0}, "hit_fx": "hit", "impact": 1.9, "trail_tint": Color(0.7, 0.8, 1.0), "thrown": true, "name": "Throw Huuma Shuriken EX", "type": "projectile", "proj_sprite": "item_huuma", "spin": 18.0, "evolved": true, 
		"sprite_scale": 2.6, "splash": 2.2, 
		"desc": "Un Huuma Shuriken gigante atraviesa todo en línea, vuelve a tu mano y golpea otra vez, estallando en cada monstruo. Con una Huuma equipada pega más y usa su elemento.", 
		"cooldown": 1.8, "damage": 150.0, "count": 1.0, "speed": 12.0, "pierce": 99.0, "range": 12.0, 
		"size": 0.8, "knock": 5.0, "color": Color(1, 0.85, 0.7), "sound": "ninja_throw", "sound_db": -3.0, "tour_wait": 0.1}, 
	"throw_zeny_x": {"name": "Throw Zeny EX", "type": "projectile", "proj_sprite": "fx_coin", "zeny_cost": 24.0, "evolved": true, "splash": 1.6, 
		"desc": "Dos puñados de zeny que estallan en monedas alrededor del golpe. Sin zeny pega mucho menos.", 
		"cooldown": 1.3, "damage": 330.0, "count": 2.0, "speed": 22.0, "pierce": 0.0, "range": 10.0, 
		"size": 0.38, "knock": 3.0, "color": Color(1, 0.9, 0.4), "sound": "throw_zeny", "sound_extra": "coin2", "hit_fx": "steal_coin", "tour_wait": 0.1}, 
	"flaming_petals_x": {"impact_fx": true, "element": "fire", "magic": true, "ninjutsu": true, "name": "Flaming Petals EX", "type": "petal_rain", "evolved": true, 
		"desc": "Una lluvia de pétalos de fuego cae sobre el grupo más grande: siempre queman y dejan el suelo ardiendo.", 
		"hit_sprite": "fx_kaensin", "hit_sprites": 1, "burn_chance": 1.0, "cell_sprite": "fx_demonstration", "shape": "square", 
		"cooldown": 1.8, "damage": 60.0, "count": 10.0, "range": 10.0, "area": 3.0, "hit_area": 1.4, "duration": 4.0, "tick": 0.5, 
		"color": Color(1, 0.55, 0.2), "sound": "fire_cast", "sound_db": -6.0, "tour_wait": 0.1}, 
	"freezing_spear_x": {"hit_fx": "hit", "impact": 1.2, "trail_tint": Color(0.55, 0.85, 1.0), "element": "water", "magic": true, "ninjutsu": true, "status": "freeze", "status_chance": 0.15, "status_time": 1.5, 
		"name": "Freezing Spear EX", "type": "projectile", "proj_tex": "ice_spear", "proj_frames": 1, "proj_blend": "mix", "proj_scale": 1.8, "evolved": true, 
		"desc": "Lanzas de hielo que rebotan entre los monstruos, ralentizan y pueden congelar.", 
		"cooldown": 0.9, "damage": 34.0, "count": 6.0, "speed": 22.0, "pierce": 3.0, "range": 10.0, 
		"size": 0.32, "slow": 2.0, "knock": 1.0, "color": Color(0.6, 0.9, 1), "sound": "cold_cast", "sound_db": -6.0, "hit_sounds": ["cold_hit1", "cold_hit2", "cold_hit3"]}, 
	"lightning_crash_x": {"element": "wind", "magic": true, "ninjutsu": true, "status": "stun", "status_chance": 0.2, "status_time": 1.4, 
		"name": "Lightning Crash EX", "type": "aoe_self", "fx": "thunderstorm", "fx_size": 1.3, "evolved": true, 
		"desc": "Una tormenta de rayos a tu alrededor que aturde a la horda.", 
		"cooldown": 2.2, "damage": 90.0, "range": 5.0, "knock": 4.0, "color": Color(1, 1, 0.55), "sound": "lightning_crash"}, 
	"shadow_slash_x": {"name": "Shadow Slash EX", "type": "backstab", "hit_sprite": "fx_kirikage", "hit_sound_bs": "shadow_slash", "evolved": true, 
		"desc": "Una danza de seis sombras hacia donde caminas, cada corte más letal.", 
		"cooldown": 2.0, "damage": 230.0, "count": 6.0, "range": 9.0, "area": 1.6, "knock": 2.0, 
		"color": Color(0.7, 0.6, 1.0), "sound": "shadow_slash"}, 
	"huuma_storm": {"name": "Huuma Storm", "type": "huuma_storm", "impact_fx": true, "huuma_form": {"dmg": 1.5, "count": 1.4}, 
		"desc": "Huumas gigantes caen del cielo sobre el grupo más grande. Con una Huuma equipada caen más y pegan más fuerte.", 
		"cooldown": 7.0, "damage": 70.0, "count": 6.0, "range": 10.0, "area": 3.0, "hit_area": 1.8, 
		"color": Color(0.85, 0.9, 1.0), "sound": "ninja_throw", "tour_wait": 1.0, 
		"per_level": {"damage": 20.0, "count": 0.5, "cooldown": -0.25}}, 
	"huuma_storm_x": {"name": "Huuma Storm EX", "type": "huuma_storm", "impact_fx": true, "evolved": true, "huuma_form": {"dmg": 1.5, "count": 1.4}, 
		"desc": "Una tormenta interminable de Huumas gigantes cae sobre la horda. Con una Huuma equipada caen más y pegan más fuerte.", 
		"cooldown": 4.5, "damage": 240.0, "count": 14.0, "range": 11.0, "area": 3.6, "hit_area": 2.2, 
		"color": Color(0.85, 0.9, 1.0), "sound": "ninja_throw"}, 
	"cross_slash_x": {"flair": {"ring": 4.5, "shake": 0.2}, "bleed_chance": 1.0, "bleed_stacks": 2, "name": "Cross Slash EX", "type": "melee_arc", "fx": "jyumonjikiri", "fx_size": 1.4, "fx_y": -2.6, "hit_sprite": "fx_kirikage", "evolved": true, 
		"desc": "Cortes en cruz a tu alrededor que hacen sangrar: nada queda en pie.", 
		"cooldown": 0.9, "damage": 300.0, "range": 4.2, "arc": 360.0, "knock": 4.0, 
		"color": Color(1, 0.85, 0.85), "sound": "shadow_slash"}, 
	"kunai_splash_x": {"huuma_form": {"dmg": 2.5, "count": 0.4, "size": 2.2, "scale": 2.0, "pierce": 99}, "flair": {"ring": 4.0, "rays": 1.0}, "thrown": true, "uses_arrows": true, "ammo_sprite": true, "name": "Kunai Splash EX", "type": "radial", "evolved": true, 
		"proj_sprite": "item_heat_wave_kunai", "spin": 20.0, 
		"desc": "Dos anillos de kunai en todas direcciones que rebotan por la horda. Con una Huuma equipada, anillos de Huumas gigantes que lo atraviesan todo.", 
		"cooldown": 1.6, "damage": 85.0, "count": 16.0, "speed": 17.0, "pierce": 3.0, "range": 8.0, 
		"size": 0.3, "knock": 2.0, "color": Color(1, 0.9, 0.8), "sound": "ninja_throw"}, 
	"exploding_dragon_x": {"impact_fx": true, "element": "fire", "magic": true, "ninjutsu": true, "name": "Exploding Dragon EX", "type": "aoe_target", "fx": "firehit1", "hit_sprite": "fx_kaensin", "hit_sprites": 7, "hit_sprite_size": 1.0, "evolved": true, 
		"desc": "Cuatro dragones de fuego estallan sobre la horda.", 
		"cooldown": 2.8, "damage": 210.0, "count": 4.0, "range": 10.0, "area": 3.0, 
		"color": Color(1, 0.45, 0.15), "sound": "exploding_dragon"}, 
	"killing_strike_x": {"tank_hp": 0.84, "tank_def": 60.0, "name": "Final Strike EX", "type": "issen", "spr_fx": "fx_issen", "evolved": true, 
		"desc": "Un tajo que parte a la horda: cuanta más vida y defensa tienes, más devastador.", 
		"cooldown": 3.5, "damage": 600.0, "hp_power": 1.4, "hp_cost": 0.08, "range": 7.0, "area": 2.4, "knock": 8.0, 
		"color": Color(0.85, 0.85, 1.0), "sound": "final_strike"}, 






	"tornado_kick": {"name": "Tornado Kick", "type": "kick", "kick": "tornado", "stance": true, "ready": "tk_ready_storm", 
		"desc": "Postura del Tornado: a veces tras un golpe giras sobre ti mismo pateando a todos a tu alrededor y los empujas.", 
		"cooldown": 1.0, "stance_chance": 0.4, "damage": 70.0, "range": 2.8, "knock": 6.0, 
		"color": Color(0.75, 0.9, 1.0), "sound": "tk_tornado", "pose": 11, 
		"per_level": {"stance_chance": 0.05, "damage": 22.0, "range": 0.15}}, 
	"heel_drop": {"name": "Heel Drop", "type": "kick", "kick": "heel", "stance": true, "ready": "tk_ready_down", 
		"status": "stun", "status_chance": 0.4, "status_time": 1.6, 
		"desc": "Postura del Talón: a veces tras un golpe saltas y dejas caer el talón sobre el monstruo; la onda aturde a los de alrededor.", 
		"cooldown": 1.0, "stance_chance": 0.32, "damage": 120.0, "range": 2.6, "area": 1.8, "knock": 1.0, 
		"color": Color(1.0, 0.8, 0.5), "sound": "tk_heel", "pose": 10, 
		"per_level": {"stance_chance": 0.04, "damage": 35.0, "area": 0.12, "status_chance": 0.05}}, 
	"roundhouse_kick": {"name": "Roundhouse Kick", "type": "kick", "kick": "round", "stance": true, "ready": "tk_ready_turn", 
		"desc": "Postura Giratoria: a veces tras un golpe una patada giratoria barre lo que tienes delante y lo lanza lejos.", 
		"cooldown": 1.0, "stance_chance": 0.34, "damage": 80.0, "range": 3.2, "arc": 210.0, "knock": 13.0, 
		"color": Color(1.0, 0.65, 0.45), "sound": "tk_round", "pose": 11, 
		"per_level": {"stance_chance": 0.04, "damage": 24.0, "range": 0.15}}, 
	"counter_kick": {"name": "Counter Kick", "type": "kick", "kick": "counter", "stance": true, "on_hit": true, "ready": "tk_ready_counter", 
		"desc": "Postura de Contraataque: cuando te golpean, a veces respondes al instante con una patada crítica.", 
		"cooldown": 1.0, "stance_chance": 0.3, "damage": 95.0, "range": 2.6, "knock": 5.0, 
		"color": Color(1.0, 0.95, 0.6), "sound": "tk_counter", "pose": 5, 
		"per_level": {"stance_chance": 0.05, "damage": 28.0}}, 
	"flying_kick": {"name": "Flying Side Kick", "type": "flying_kick", 
		"desc": "Te lanzas por el aire con una patada voladora hacia donde caminas (quieto: al monstruo más lejano), golpeando a todos en el camino. F la apaga y la enciende.", 
		"cooldown": 5.0, "damage": 60.0, "range": 8.0, "area": 1.3, "knock": 4.0, 
		"color": Color(1.0, 0.85, 0.55), "sound": "tk_flying", 
		"per_level": {"damage": 18.0, "range": 0.4, "cooldown": -0.4}}, 
	"mild_wind": {"name": "Mild Wind", "type": "mild_wind", 
		"desc": "Envuelve tus patadas en el elemento que más daño hace a los monstruos cercanos (Tierra, Viento, Agua, Fuego, Fantasma, Sombra o Sagrado).", 
		"cooldown": 16.0, "duration": 10.0, "range": 9.0, "color": Color(0.7, 1.0, 0.85), "sound": "tk_wind", 
		"per_level": {"duration": 1.5, "cooldown": -1.0}}, 
	"leap": {"name": "Leap", "type": "leap", 
		"desc": "Rodeado y herido, saltas lejos de la horda y caes con una onda que la empuja.", 
		"cooldown": 12.0, "range": 5.0, "damage": 35.0, "area": 2.2, "knock": 8.0, 
		"color": Color(0.85, 0.95, 1.0), "sound": "tk_jump", 
		"per_level": {"range": 0.35, "damage": 12.0, "cooldown": -0.9}}, 
	"tumbling": {"name": "Tumbling", "type": "passive", "desc": "Pasiva: más evasión.", 
		"bonus": ["dodge"], "dodge": 0.05, "color": Color(0.85, 0.95, 1.0), 
		"per_level": {"dodge": 0.025}}, 
	"sprint": {"name": "Sprint", "type": "passive", "desc": "Pasiva: corres más y tu Flying Side Kick pega más fuerte.", 
		"bonus": ["move", "sprint"], "move": 0.04, "sprint": 0.2, "color": Color(1.0, 0.85, 0.6), 
		"per_level": {"move": 0.02, "sprint": 0.12}}, 
	"peaceful_break": {"name": "Taekwon Mission", "type": "passive", "desc": "Pasiva: cada patada de postura (y cada hechizo de Soul Linker) suma una racha de daño (hasta 20; 30 con los Puños y como Soul Linker), que se pierde tras 6 s sin sumar. Contra jefes y MVP vale el doble.", 
		"bonus": ["kick_fury"], "kick_fury": 0.02, "color": Color(1.0, 0.6, 0.3), 
		"per_level": {"kick_fury": 0.006}}, 
	"kihop": {"name": "Kihop", "type": "passive", "desc": "Pasiva: el grito del Taekwon. Tus posturas llegan más seguido y tus habilidades pegan más.", 
		"bonus": ["stance", "skill_dmg"], "stance": 0.03, "skill_dmg": 0.04, "color": Color(1.0, 0.75, 0.5), 
		"per_level": {"stance": 0.015, "skill_dmg": 0.03}}, 

	"warmth_sun": {"element": "fire", "name": "Warmth of the Sun", "type": "warmth", "aura": "sun", 
		"desc": "El calor del sol te rodea unos segundos: quema y empuja sin parar a los monstruos que se te acercan.", 
		"cooldown": 16.0, "duration": 7.0, "damage": 24.0, "range": 2.6, "every": 0.35, "knock": 3.5, 
		"color": Color(1.0, 0.55, 0.25), "sound": "sg_warm", 
		"per_level": {"damage": 8.0, "duration": 0.6, "range": 0.15, "cooldown": -0.8}}, 
	"warmth_stars": {"element": "holy", "name": "Warmth of the Stars", "type": "warmth", "aura": "stars", 
		"desc": "Unos segundos en que las estrellas caen una tras otra sobre los monstruos que te rodean.", 
		"cooldown": 14.0, "duration": 6.0, "damage": 55.0, "range": 7.0, "area": 1.5, "every": 0.45, 
		"color": Color(1.0, 0.95, 0.6), "sound": "sg_comfort", 
		"per_level": {"damage": 17.0, "duration": 0.5, "area": 0.1, "cooldown": -0.6}}, 
	"union": {"name": "Union of the Sun, Moon and Stars", "type": "union", 
		"desc": "Te fundes con el sol, la luna y las estrellas: vuelas, atacas mucho más rápido y fuerte y cada golpe sale con una patada de postura. Te cuesta un poco de vida mientras dura.", 
		"cooldown": 34.0, "duration": 9.0, "color": Color(1.0, 0.85, 0.4), "sound": "sg_union", 
		"per_level": {"duration": 1.0, "cooldown": -2.0}}, 
	"hatred_stars": {"name": "Hatred of the Stars", "type": "passive", "desc": "Pasiva: más daño contra jefes, MVPs y mini jefes.", 
		"bonus": ["vs_boss"], "vs_boss": 0.1, "color": Color(1.0, 0.6, 0.4), 
		"per_level": {"vs_boss": 0.06}}, 
	"comfort_stars": {"name": "Comfort of the Stars", "type": "passive", "desc": "Pasiva: más defensa y evasión.", 
		"bonus": ["armor", "dodge"], "armor": 1.0, "dodge": 0.03, "color": Color(0.8, 0.85, 1.0), 
		"per_level": {"armor": 0.6, "dodge": 0.015}}, 

	"estin": {"name": "Estin", "type": "aoe_target", "kick_element": true, "magic": true, "soul_spell": true, "missile": true, 
		"desc": "Lanzas espíritus rápidos que estallan sobre los monstruos cercanos. Potenciada por Mild Wind.", 
		"cooldown": 1.1, "damage": 40.0, "count": 2.0, "range": 8.0, "area": 1.1, 
		"hit_sprite": "fx_sl_6", "hit_sprites": 1, "hit_sprite_size": 0.85, "hit_ring": true, 
		"color": Color(0.75, 0.8, 1.0), "sound": "sl_energy", "sound_db": -8.0, 
		"per_level": {"damage": 12.0, "count": 0.5, "cooldown": -0.05}}, 
	"esma": {"name": "Esma", "type": "aoe_target", "kick_element": true, "magic": true, "soul_spell": true, 
		"desc": "Un vórtice de espíritus cae sobre varios monstruos y estalla en una columna de luz. Potenciada por Mild Wind.", 
		"cooldown": 2.6, "damage": 70.0, "count": 2.0, "range": 9.0, "area": 1.8, 
		"hit_sprite": "fx_sl_4", "hit_sprites": 1, "hit_sprite_size": 0.8, "gather": true, "hit_column": true, 
		"color": Color(0.7, 0.65, 1.0), "sound": "sl_shoot", 
		"per_level": {"damage": 21.0, "count": 0.5, "area": 0.1, "cooldown": -0.12}}, 
	"eswoo": {"name": "Eswoo", "type": "aoe_target", "magic": true, "slow": 2.5, "shrink": true, "soul_spell": true, 
		"mark": 0.15, "weak": 0.25, "mark_time": 4.0, 
		"desc": "Atas el alma de los monstruos cercanos: les haces daño, caminan mucho más lento un momento y, por 4 s, reciben un 15% más de daño de todo el grupo y pegan un 25% menos (también los MVP).", 
		"cooldown": 5.0, "damage": 27.0, "count": 3.0, "range": 8.0, "area": 1.6, 
		"hit_sprite": "fx_sl_7", "hit_sprites": 1, "hit_sprite_size": 0.8, "hit_ring": true, 
		"color": Color(0.8, 0.95, 1.0), "sound": "sl_support", 
		"per_level": {"damage": 8.0, "count": 1.0, "cooldown": -0.3}}, 
	"kaite": {"name": "Kaite", "type": "shield", "spr_fx": "fx_sl_3", 
		"desc": "Barrera de espíritus que absorbe daño. Mientras dura se traga entero cada proyectil y cada mecánica de un MVP (la mecánica la rompe) y guarda una carga por cada uno (dos por una mecánica); con 5 cargas suelta una onda de espíritus a tu alrededor. En grupo va al aliado con menos barrera.", 
		"cooldown": 9.0, "amount": 40.0, "wave": 80.0, "color": Color(0.8, 0.85, 1.0), "sound": "sl_reflect", 
		"per_level": {"amount": 15.0, "cooldown": -0.5, "wave": 25.0}}, 
	"soul_link": {"name": "Soul Link", "type": "soul_link", 
		"desc": "Rueda de almas: cada 12 s te presta, por turnos, el espíritu de otra clase (Mago, Caballero, Sacerdote, Asesino, Cazador y Cruzado). Mientras dura, lanzas gratis su habilidad más famosa (Storm Gust, Bowling Bash, Magnus Exorcismus, Sonic Blow, Arrow Shower, Grand Cross) al nivel de Soul Link, y tú y los aliados cercanos recibís su poder. Cada Soul Link deja un Vínculo para toda la partida (hasta 10, +3% de daño cada uno), también en los aliados que alcanza.", 
		"cooldown": 12.0, "duration": 12.0, "color": Color(0.85, 0.75, 1.0), "sound": "sl_soul"}, 
	"kaizel": {"name": "Kaizel", "type": "passive", "desc": "Pasiva: si caes, el espíritu te levanta con parte de tu vida (una vez cada cierto tiempo).", 
		"bonus": ["kaizel"], "kaizel": 120.0, "color": Color(1.0, 0.95, 0.8), 
		"per_level": {"kaizel": -15.0}}, 
	"kaahi": {"name": "Kaahi y Kaizel", "type": "passive", "desc": "Pasiva: cada golpe de tus espíritus te cura un poco; cuando te golpean recuperas algo más de vida (y los aliados cercanos también) y, si caes, el espíritu te levanta con parte de tu vida (una vez cada cierto tiempo).", 
		"bonus": ["kaahi", "kaizel"], "kaahi": 0.015, "kaizel": 120.0, "color": Color(0.7, 1.0, 0.8), "over_never": ["kaizel"], 
		"per_level": {"kaahi": 0.007, "kaizel": -15.0}}, 







	"picky_peck": {"name": "Picky Peck", "type": "doram", "doram": "picky", "magic": true, "over_step": 0.15, 
		"desc": "Llamas a unos Pickies que les lanzan plumas a los monstruos desde lejos; al irse estallan en llamas. Atacan más rápido con tu velocidad de ataque.", 

		"cooldown": 6.0, "damage": 34.3, "count": 2.0, "range": 9.0, "duration": 9.0, "tick": 0.7, "area": 1.7, "burst": 3.0, 
		"color": Color(1.0, 0.85, 0.4), "sound": "su_pickypeck", "tour_wait": 2.0, 
		"per_level": {"damage": 10.9, "count": 0.75, "duration": 0.6, "cooldown": -0.25}}, 
	"scar_of_tarou": {"name": "Scar of Tarou", "type": "doram", "doram": "tarou", "magic": true, "over_step": 0.15, 
		"desc": "Sueltas Tarous que le lanzan garras al monstruo más duro sin parar; el primer golpe lo aturde. Atacan más rápido con tu velocidad de ataque.", 
		"cooldown": 7.0, "damage": 22.8, "count": 1.0, "range": 9.0, "duration": 8.0, "tick": 0.4, "stun": 0.7, "speed": 9.0, 
		"color": Color(0.7, 0.6, 0.5), "sound": "su_scaroftarou", "tour_wait": 2.0, 
		"per_level": {"damage": 7.2, "count": 0.5, "duration": 0.6}}, 
	"arclouse_dash": {"name": "Arclouse Dash", "type": "doram", "doram": "arclouse", "magic": true, "over_step": 0.15, 
		"desc": "Una carga de Arclouses arrasa en línea todo lo que encuentra. Pegan más fuerte y corren más rápido con tu velocidad de movimiento.", 
		"cooldown": 3.4, "damage": 50.4, "count": 2.0, "range": 9.0, "width": 0.9, "speed": 16.0, 
		"color": Color(0.6, 0.75, 0.5), "sound": "su_powerofflock", 
		"per_level": {"damage": 14.4, "count": 0.5, "cooldown": -0.12}}, 
	"lunatic_carrot_beat": {"name": "Lunatic Carrot Beat", "type": "doram", "doram": "lunatic", "magic": true, "over_step": 0.15, 
		"desc": "Los Lunatics rodean al grupo más grande y le llueven zanahorias; pueden aturdir.", 
		"cooldown": 6.0, "damage": 55.2, "count": 5.0, "range": 10.0, "area": 2.6, "hit_area": 1.4, "stun_chance": 0.12, 
		"color": Color(1.0, 0.7, 0.35), "sound": "su_nyanggrass", 
		"per_level": {"damage": 15.6, "count": 1.0, "cooldown": -0.25}}, 

	"silvervine_stem_spear": {"name": "Silvervine Stem Spear", "type": "aoe_target", "magic": true, 
		"elements": ["earth", "fire", "water", "wind", "ghost"], "fx": "su_sv_stemspear/su_sv_stemspear", 
		"desc": "Lanzas de silvervine se clavan en los monstruos; cada vez de un elemento distinto (Tierra, Fuego, Agua, Viento o Fantasma).", 
		"cooldown": 1.4, "damage": 30.0, "count": 2.0, "range": 10.0, "area": 1.3, 
		"color": Color(0.6, 0.85, 0.45), "sound": "su_stemspear", 
		"per_level": {"damage": 9.0, "count": 0.5, "cooldown": -0.05}}, 
	"catnip_meteor": {"fx_lead": 0.55, "name": "Catnip Meteor", "type": "aoe_target", "magic": true, "fx": "su_cn_meteor/su_cn_meteor0", "catnip": true, 
		"desc": "Bolsas gigantes de hierba gatera caen del cielo sobre los monstruos.", 
		"cooldown": 4.8, "damage": 70.0, "count": 3.0, "range": 10.0, "area": 2.6, 
		"color": Color(0.75, 0.95, 0.5), "sound": "su_cn_powdering", 
		"per_level": {"damage": 18.0, "count": 0.4, "cooldown": -0.2}}, 
	"silvervine_root_twist": {"element": "earth", "name": "Silvervine Root Twist", "type": "aoe_target", "magic": true, 
		"hit_sprite": "fx_root_twist", 
		"desc": "Raíces de silvervine brotan bajo varios grupos: los atrapan, los frenan y los aprietan.", 
		"cooldown": 4.4, "damage": 38.0, "count": 2.0, "range": 9.0, "area": 2.2, "slow": 3.0, 
		"color": Color(0.55, 0.8, 0.4), "sound": "su_roottwist", 
		"per_level": {"damage": 11.0, "count": 0.4, "area": 0.12, "cooldown": -0.15}}, 

	"tuna_belly": {"name": "Tuna Belly", "type": "heal", "fx": "su_tunabelly/su_tunabelly", 
		"desc": "Un buen trozo de atún: te cura a ti o al aliado más herido.", 
		"cooldown": 9.0, "amount": 22.0, "color": Color(1.0, 0.7, 0.6), "sound": "su_tunabelly", "sound_db": -2.0, 
		"per_level": {"amount": 11.0, "cooldown": -0.6}}, 
	"tuna_party": {"name": "Tuna Party", "type": "shield", "spr_fx": "fx_tuna_party", 
		"desc": "Una fiesta de atún te rodea: una barrera que absorbe daño (al aliado que más la necesite).", 
		"cooldown": 8.5, "amount": 40.0, "color": Color(0.6, 0.85, 1.0), "sound": "su_meowmeow", 
		"per_level": {"amount": 15.0, "cooldown": -0.4}}, 
	"bunch_of_shrimp": {"name": "Bunch of Shrimp", "type": "buff", "fx": "su_bunchofshrimp/su_bunchofshrimp", 
		"desc": "Gambas para todos: más daño para ti, tus invocaciones y los aliados cercanos.", 
		"cooldown": 12.0, "bonus": ["dmg"], "dmg": 0.1, "color": Color(1.0, 0.6, 0.5), "sound": "su_shrimp", 
		"per_level": {"dmg": 0.04}}, 

	"power_of_life": {"name": "Power of Life", "type": "passive", "desc": "Pasiva: tus invocaciones pegan más fuerte, sean tus animales, tu equipo o tus homúnculos.", 
		"bonus": ["summon_dmg"], "summon_dmg": 0.15, "color": Color(1.0, 0.85, 0.4), 
		"per_level": {"summon_dmg": 0.07}}, 
	"power_of_land": {"name": "Power of Land", "type": "passive", "desc": "Pasiva: más daño de habilidades y más daño a jefes y MVP.", 
		"bonus": ["skill_dmg", "vs_boss"], "skill_dmg": 0.06, "vs_boss": 0.05, "color": Color(0.6, 0.85, 0.45), 
		"per_level": {"skill_dmg": 0.08, "vs_boss": 0.05}}, 
	"power_of_sea": {"name": "Power of Sea", "type": "passive", "desc": "Pasiva: curas y barreras más fuertes, y más vida máxima.", 
		"bonus": ["heal_power", "max_hp_pct"], "heal_power": 0.12, "max_hp_pct": 0.04, "color": Color(0.5, 0.8, 1.0), 
		"per_level": {"heal_power": 0.06, "max_hp_pct": 0.035}}, 
	"spirit_of_life": {"name": "Spirit of Life", "type": "passive", "desc": "Pasiva: llega un animal más con cada llamada (cuatro al máximo) y tus invocaciones pegan más.", 
		"bonus": ["summon_count", "summon_dmg"], "summon_count": 1.0, "summon_dmg": 0.1, "color": Color(1.0, 0.9, 0.5), 
		"over_never": ["summon_count"], "per_level": {"summon_count": 0.75, "summon_dmg": 0.05}}, 
	"spirit_of_land": {"name": "Spirit of Land", "type": "passive", "desc": "Pasiva: +1 a todo lo que lanzas o invocas (+2 al máximo).", 
		"bonus": ["count"], "count": 1.0, "color": Color(0.65, 0.9, 0.5), 
		"over_never": ["count"], "per_level": {"count": 0.25}}, 
	"spirit_of_sea": {"name": "Spirit of Sea", "type": "passive", "desc": "Pasiva: tus curas y barreras estallan en una ola de mar que daña a los monstruos de alrededor.", 
		"bonus": ["sea_wave"], "sea_wave": 0.8, "color": Color(0.45, 0.8, 1.0), 
		"per_level": {"sea_wave": 0.25}}, 
	"scar_of_tarou_x": {"name": "Scar of Tarou EX", "type": "doram", "doram": "tarou", "magic": true, "over_step": 0.15, "evolved": true, 
		"desc": "Una jauría de Tarous: más, más rápidos, y cada 5 golpes le abren al monstruo una gran herida que daña a su alrededor y aturde. Atacan más rápido con tu velocidad de ataque.", 
		"cooldown": 5.0, "damage": 69.6, "count": 4.0, "range": 10.0, "duration": 12.0, "tick": 0.32, "stun": 1.0, "speed": 10.0, 
		"area": 2.2, "scar": 5, "scar_dmg": 4.0, 
		"color": Color(0.7, 0.6, 0.5), "sound": "su_scaroftarou"}, 
	"arclouse_dash_x": {"name": "Arclouse Dash EX", "type": "doram", "doram": "arclouse", "magic": true, "over_step": 0.15, "evolved": true, 
		"desc": "Una estampida de Arclouses: más anchos, más seguido, y al final de la carga dan la vuelta y arrasan de nuevo. Pegan más fuerte y corren más rápido con tu velocidad de movimiento.", 
		"cooldown": 2.2, "damage": 138.0, "count": 6.0, "range": 10.0, "width": 1.2, "speed": 17.0, "back": true, 
		"color": Color(0.6, 0.75, 0.5), "sound": "su_powerofflock"}, 
	"lunatic_carrot_beat_x": {"name": "Lunatic Carrot Beat EX", "type": "doram", "doram": "lunatic", "magic": true, "over_step": 0.15, "evolved": true, 
		"desc": "Un diluvio de zanahorias: más Lunatics, una zona más grande y aturden más seguido.", 
		"cooldown": 3.8, "damage": 150.0, "count": 14.0, "range": 11.0, "area": 3.3, "hit_area": 1.8, "stun_chance": 0.25, 
		"color": Color(1.0, 0.7, 0.35), "sound": "su_nyanggrass"}, 
	"silvervine_stem_spear_x": {"name": "Silvervine Stem Spear EX", "type": "aoe_target", "magic": true, "evolved": true, 
		"elements": ["earth", "fire", "water", "wind", "ghost"], "fx": "su_sv_stemspear/su_sv_stemspear", 
		"desc": "Un bosque de lanzas de silvervine: más lanzas, más grandes y más seguido, cada vez de un elemento distinto.", 
		"cooldown": 0.9, "damage": 88.0, "count": 7.0, "range": 11.0, "area": 1.7, 
		"color": Color(0.6, 0.85, 0.45), "sound": "su_stemspear"}, 
	"silvervine_root_twist_x": {"element": "earth", "name": "Silvervine Root Twist EX", "type": "aoe_target", "magic": true, "evolved": true, 
		"hit_sprite": "fx_root_twist", 
		"desc": "Raíces gigantes brotan bajo más grupos: los atrapan más tiempo y los aprietan más fuerte.", 
		"cooldown": 2.8, "damage": 108.0, "count": 5.0, "range": 10.0, "area": 3.2, "slow": 4.5, 
		"color": Color(0.55, 0.8, 0.4), "sound": "su_roottwist"}, 
	"bunch_of_shrimp_x": {"name": "Bunch of Shrimp EX", "type": "buff", "fx": "su_bunchofshrimp/su_bunchofshrimp", "evolved": true, 
		"desc": "Un festín de gambas: mucho más daño para ti y los aliados cercanos, y tus invocaciones pegan aún más.", 
		"cooldown": 9.0, "bonus": ["dmg", "summon_dmg"], "dmg": 0.4, "summon_dmg": 0.25, "color": Color(1.0, 0.6, 0.5), "sound": "su_shrimp"}, 
	"picky_peck_x": {"name": "Picky Peck EX", "type": "doram", "doram": "picky", "magic": true, "over_step": 0.15, "evolved": true, 
		"desc": "Una bandada de Pickies: más, más fuertes, y su estallido final arrasa. Atacan más rápido con tu velocidad de ataque.", 
		"cooldown": 4.5, "damage": 96.7, "count": 6.0, "range": 10.0, "duration": 11.0, "tick": 0.55, "area": 2.3, "burst": 4.0, 
		"color": Color(1.0, 0.85, 0.4), "sound": "su_pickypeck"}, 
	"catnip_meteor_x": {"fx_lead": 0.55, "name": "Catnip Meteor EX", "type": "aoe_target", "magic": true, "fx": "su_cn_meteor/su_cn_meteor0", "evolved": true, "catnip": true, 
		"desc": "Una lluvia de hierba gatera: más meteoros, más grandes y más seguido.", 
		"cooldown": 3.2, "damage": 210.0, "count": 6.0, "range": 11.0, "area": 3.3, 
		"color": Color(0.75, 0.95, 0.5), "sound": "su_cn_powdering"}, 
	"tuna_belly_x": {"name": "Tuna Belly EX", "type": "heal", "fx": "su_tunabelly/su_tunabelly", "evolved": true, 
		"desc": "Un banquete de atún: cura mucho más y más seguido.", 
		"cooldown": 5.0, "amount": 110.0, "color": Color(1.0, 0.7, 0.6), "sound": "su_tunabelly", "sound_db": -2.0}, 
	"tornado_kick_x": {"name": "Tornado Kick EX", "type": "kick", "kick": "tornado", "stance": true, "ready": "tk_ready_storm", "evolved": true, 
		"desc": "El tornado al máximo: giras dos veces y la horda entera sale volando.", 




		"cooldown": 1.0, "stance_chance": 0.42, "damage": 165.0, "range": 3.8, "knock": 6.0, "twice": true, 
		"color": Color(0.75, 0.9, 1.0), "sound": "tk_tornado", "pose": 11}, 
	"flying_kick_x": {"name": "Flying Side Kick EX", "type": "flying_kick", "evolved": true, 
		"desc": "Patada voladora al máximo: más lejos, más ancha y rebota hacia otro monstruo al caer.", 
		"cooldown": 2.6, "damage": 190.0, "range": 11.0, "area": 1.8, "knock": 6.0, "rebound": true, 
		"color": Color(1.0, 0.85, 0.55), "sound": "tk_flying"}, 
	"warmth_sun_x": {"element": "fire", "name": "Warmth of the Sun EX", "type": "warmth", "aura": "sun", "evolved": true, 
		"desc": "El sol en persona: un aura de calor mayor, más larga y que quema más.", 
		"cooldown": 9.0, "duration": 11.0, "damage": 70.0, "range": 3.8, "every": 0.3, "knock": 4.5, 
		"color": Color(1.0, 0.55, 0.25), "sound": "sg_warm"}, 
	"esma_x": {"name": "Esma EX", "type": "aoe_target", "kick_element": true, "magic": true, "evolved": true, "soul_spell": true, 
		"desc": "Esma al máximo: muchos más vórtices de espíritus, más grandes y seguidos. Potenciada por Mild Wind.", 
		"cooldown": 1.6, "damage": 190.0, "count": 5.0, "range": 10.0, "area": 2.4, 
		"hit_sprite": "fx_sl_4", "hit_sprites": 1, "hit_sprite_size": 1.0, "gather": true, "hit_column": true, 
		"color": Color(0.7, 0.65, 1.0), "sound": "sl_shoot"}, 

	"first_aid": {"name": "First Aid", "type": "heal", "desc": "Primeros auxilios: te curas cada pocos segundos y te vendas: una barrera que aguanta una parte de tu vida máxima.", 
		"cooldown": 7.0, "amount": 30.0, "color": Color(0.6, 1, 0.6), "sound": "heal", "sound_db": -8.0, 


		"shield_hp": 0.08, 
		"per_level": {"amount": 15.0, "cooldown": -0.5, "shield_hp": 0.03}}, 






	"sword_mastery": {"name": "Sword Mastery", "type": "passive", "desc": "Pasiva: más daño en el ataque básico, y tus golpes cuerpo a cuerpo barren más lejos, a un monstruo más y con más daño.", 
		"bonus": ["basic_dmg", "cleave_extra", "cleave_reach", "cleave_dmg"], "basic_dmg": 0.08, "cleave_extra": 1.0, "cleave_reach": 0.3, "cleave_dmg": 0.08, 
		"color": Color(0.9, 0.7, 0.6), "per_level": {"basic_dmg": 0.08, "cleave_reach": 0.3, "cleave_dmg": 0.08}, 
		"over_never": ["cleave_extra", "cleave_reach", "cleave_dmg"]}, 



	"gangster_paradise": {"name": "Gangster's Paradise", "type": "passive", 
		"desc": "Pasiva: tus cartas y equipo se lanzan mucho más seguido, al atacar y al recibir golpes, y todo lo que lanzan solos (también Preserve) pega más fuerte.", 
		"bonus": ["proc_chance", "hit_proc", "proc_power"], "proc_chance": 0.15, "hit_proc": 0.1, "proc_power": 0.15, "color": Color(0.85, 0.6, 1.0), 
		"per_level": {"proc_chance": 0.07, "hit_proc": 0.05, "proc_power": 0.08}}, 



	"intimidate": {"name": "Intimidate", "type": "passive", 
		"desc": "Pasiva: tus habilidades pegan más fuerte, y cada monstruo que apuñalas con Back Stab queda intimidado unos segundos: recibe más daño de todas tus habilidades.", 
		"bonus": ["skill_dmg", "intimidate"], "skill_dmg": 0.08, "intimidate": 0.1, "color": Color(0.9, 0.55, 0.7), 
		"per_level": {"skill_dmg": 0.04, "intimidate": 0.05}}, 
	"preserve": {"name": "Preserve", "type": "passive", 
		"desc": "Pasiva: tus ataques básicos a veces lanzan solos una de tus habilidades de ataque copiadas con Plagiarism (descansa 0,4 s); su daño crece con tu ataque básico. Los bufos copiados no los lanza: están siempre activos con su valor normal.", 
		"bonus": ["plag_proc"], "plag_proc": 0.08, "color": Color(0.7, 0.85, 1.0), 
		"per_level": {"plag_proc": 0.03}}, 
	"shield_mastery": {"name": "Shield Mastery", "type": "passive", "needs_shield": true, 
		"desc": "Pasiva: con escudo, más vida máxima, defensa y bloqueo, y al bloquear te curas un poco (como mucho dos veces por segundo).", 
		"bonus": ["max_hp_pct", "armor", "block", "block_heal"], "max_hp_pct": 0.04, "armor": 1.5, "block": 0.03, "block_heal": 0.006, 
		"color": Color(0.75, 0.85, 1.0), "per_level": {"max_hp_pct": 0.02, "armor": 0.75, "block": 0.01, "block_heal": 0.002}}, 
	"peco_riding": {"name": "Peco Peco Ride", "type": "passive", "desc": "Pasiva: subes a tu Peco Peco. Corres más y tus lanzadas pegan ×1,2. El Crusader monta un Grand Peco.", 
		"bonus": ["move"], "move": 0.1, "color": Color(1, 0.9, 0.5), "per_level": {"move": 0.025}}, 
	"cavalier_mastery": {"name": "Cavalier Mastery", "type": "passive", "mounted": true, "needs": "peco_riding", "desc": "Pasiva: tu ataque básico va más rápido montado en tu Peco Peco.", 
		"bonus": ["aspd"], "aspd": 0.04, "color": Color(0.9, 0.8, 0.6), "per_level": {"aspd": 0.04}}, 


	"spell_breaker": {"name": "Spell Breaker", "type": "passive", "desc": "Pasiva: tu magia rompe las defensas de los grandes: más daño contra jefes, MVPs y mini jefes.", 
		"bonus": ["vs_boss"], "vs_boss": 0.1, "color": Color(0.75, 0.55, 1.0), 
		"per_level": {"vs_boss": 0.06}}, 
	"sp_recovery": {"name": "Increase SP Recovery", "type": "passive", "desc": "Pasiva: las habilidades se recargan más rápido, y cada una que lanzas recorta la recarga de las demás.", 
		"bonus": ["haste", "chain_cast"], "haste": 0.04, "chain_cast": 0.12, "color": Color(0.6, 0.7, 1), "per_level": {"haste": 0.045, "chain_cast": 0.03}}, 






	"recognized_spell": {"name": "Recognized Spell", "type": "passive", "desc": "Pasiva del Wizard: casi toda tu velocidad de recarga deja de acortar las recargas y se vuelve daño de habilidades. Con mucha recarga (Archmage, Freya) pega mucho más; con poca, mejor SP Recovery.", 












		"bonus": ["spell_focus", "focus_dmg"], "spell_focus": 0.6, "focus_dmg": 0.7, "color": Color(0.55, 0.45, 1.0), 
		"per_level": {"spell_focus": 0.05, "focus_dmg": 0.05}, "over_never": ["spell_focus"], "over_step": 0.04}, 
	"soul_drain": {"name": "Soul Drain", "type": "passive", "desc": "Pasiva: cada monstruo derrotado te devuelve vida y tus combos elementales pegan más.", 
		"bonus": ["kill_heal", "combo_dmg"], "kill_heal": 0.002, "combo_dmg": 0.15, "color": Color(0.7, 0.5, 1), 
		"per_level": {"kill_heal": 0.0012, "combo_dmg": 0.1}}, 

	"quagmire": {"element": "earth", "name": "Quagmire", "magic": true, "type": "ground", "fx": "quagmire", "fx_size": 0.75, 
		"desc": "Un pantano de barro frena a los monstruos, los debilita y los deja mojados para tus combos.", 
		"shape": "square", "cooldown": 6.0, "damage": 8.0, "count": 1.0, "range": 8.0, "area": 2.3, "duration": 5.0, "tick": 0.5, 
		"zone_slow": 1.0, "combo_mark": "water", "acid": 0.08, "color": Color(0.6, 0.5, 0.35), "sound": "quagmire", 
		"per_level": {"damage": 3.0, "area": 0.15, "acid": 0.03, "cooldown": -0.3}}, 

	"sightrasher": {"burn_chance": 1.0, "element": "fire", "name": "Sightrasher", "magic": true, "type": "sightrasher", 
		"desc": "Un anillo de fuego estalla a tu alrededor y lanza lejos a los monstruos.", 
		"cooldown": 3.6, "damage": 48.3, "range": 3.2, "knock": 7.0, "color": Color(1.0, 0.5, 0.2), "sound": "sightrasher", 
		"per_level": {"damage": 14.9, "range": 0.2, "cooldown": -0.15}}, 

	"gravitation_field": {"name": "Gravitation Field", "magic": true, "type": "gravity", "fx": "hyper_novice/hn_ground_gravitation/ground_gravitation", 
		"desc": "Un campo de gravedad en medio de la horda la arrastra a su centro y la aplasta sin parar.", 
		"cooldown": 7.0, "damage": 25.3, "range": 9.0, "area": 3.0, "duration": 3.0, "pull": 5.0, 
		"color": Color(0.6, 0.4, 0.9), "sound": "gravitation_field", 
		"per_level": {"damage": 8.0, "area": 0.15, "cooldown": -0.3}}, 

	"kunai_explosion": {"name": "Kunai Explosion", "type": "kunai_boom", "min_kunai": 3.0, 
		"desc": "Detonas todos los kunai clavados en los monstruos: cada uno estalla con el elemento de tu kunai.", 
		"cooldown": 2.4, "damage": 22.0, "range": 10.0, "color": Color(1.0, 0.7, 0.4), "sound": "kunai_explosion", 
		"per_level": {"damage": 7.0, "cooldown": -0.1}}, 
	"kaihou": {"name": "Kaihou", "type": "kaihou", 
		"desc": "Con tres sellos de ninjutsu los liberas a la vez: fuego en anillo, lanzas de hielo y rayos. Con los tres elementos distintos pega mucho más.", 
		"cooldown": 1.0, "damage": 70.0, "range": 5.0, "color": Color(0.9, 0.8, 1.0), 
		"per_level": {"damage": 20.0}}, 
	"moonlight_fantasy": {"huuma_form": {"dmg": 2.0, "count": 0.5, "range": 1.3, "speed": 0.7, "px": 2.4}, "flair": {"ring": 3.0, "rays": 0.8}, "thrown": true, "name": "Moonlight Fantasy", "type": "orbit", "sprite": "item_heat_wave_kunai", "raw_frames": true, "sprite_px": 1.0, "tint": Color(0.8, 0.85, 1.25), 
		"desc": "Kunai bajo la luna giran a tu alrededor: cortan a todo lo que tocan y se le quedan clavados. Con una Huuma equipada son Huumas grandes, más lentas y letales.", 
		"cooldown": 6.0, "damage": 20.0, "count": 3.0, "range": 1.8, "hit_every": 0.5, "orbit_speed": 4.0, "knock": 1.0, 
		"color": Color(0.85, 0.85, 1.0), "sound": "moonlight_fantasy", 
		"per_level": {"damage": 6.0, "count": 0.5}}, 
	"meikyou_shisui": {"name": "Meikyou Shisui", "type": "passive", 
		"desc": "Pasiva: alma serena: Kunai Explosion pega más y cada sello de ninjutsu potencia más tus ninjutsu.", 
		"bonus": ["kunai_dmg", "charm_dmg"], "kunai_dmg": 0.1, "charm_dmg": 0.04, "color": Color(0.85, 0.85, 1.0), 
		"per_level": {"kunai_dmg": 0.06, "charm_dmg": 0.02}}, 
	"owls_eye": {"name": "Owl's Eye", "type": "passive", "desc": "Pasiva: más daño del ataque básico y de tus habilidades de flecha EX (Double Strafe, Arrow Shower, Charge Arrow) y Sharp Shooting con cualquier flecha, y con una flecha elemental más daño de todo lo que disparas.", 
		"bonus": ["basic_dmg", "arrow_dmg", "arrow_skill_dmg"], "basic_dmg": 0.06, "arrow_dmg": 0.05, "arrow_skill_dmg": 0.1, "color": Color(0.9, 0.85, 0.6), 
		"per_level": {"basic_dmg": 0.08, "arrow_dmg": 0.05, "arrow_skill_dmg": 0.1}}, 
	"vultures_eye": {"name": "Vulture's Eye", "type": "passive", "desc": "Pasiva: tu ojo certero da más críticos y más fuertes.", 
		"bonus": ["crit", "crit_dmg"], "crit": 0.03, "crit_dmg": 0.1, "color": Color(0.8, 0.9, 0.7), 
		"per_level": {"crit": 0.012, "crit_dmg": 0.08}}, 
	"beast_bane": {"name": "Trap Research", "type": "passive", "desc": "Pasiva: tus trampas hacen más daño, y los monstruos que las pisan quedan marcados 4 s (no los inmoviliza): reciben más daño de todo. Sniper: tu halcón hace estallar tus trampas cercanas al doble y se rearman una vez.", 
		"bonus": ["trap_vuln", "trap_dmg"], "trap_vuln": 0.2, "trap_dmg": 0.5, "color": Color(0.8, 0.7, 0.5), "per_level": {"trap_vuln": 0.05, "trap_dmg": 0.3}}, 
	"steel_crow": {"name": "Steel Crow", "type": "passive", "desc": "Pasiva: tu halcón pega más fuerte y se lanza solo más seguido cuando disparas. Sniper: cada golpe del halcón suma una carga de Presa al monstruo (hasta 10): +12% de todo tu daño contra él.", 
		"bonus": ["falcon_dmg", "auto_blitz"], "falcon_dmg": 0.25, "auto_blitz": 0.05, "color": Color(0.7, 0.8, 0.9), 
		"per_level": {"falcon_dmg": 0.15, "auto_blitz": 0.02}}, 
	"katar_mastery": {"name": "Katar Mastery", "type": "passive", "needs_weapon": "katar", 
		"desc": "Pasiva: más daño del ataque básico con un katar equipado.", 
		"bonus": ["basic_dmg"], "basic_dmg": 0.08, "color": Color(0.8, 0.6, 0.9), "per_level": {"basic_dmg": 0.08}}, 
	"divine_protection": {"name": "Divine Protection", "type": "passive", 
		"desc": "Pasiva: más defensa y los no-muertos y demonios te hieren menos.", 
		"bonus": ["armor", "undead_guard"], "armor": 1.0, "undead_guard": 0.08, "color": Color(1, 0.95, 0.7), 
		"per_level": {"armor": 0.6, "undead_guard": 0.05}}, 





	"divine_judgment": {"name": "Judgment of Asgard", "type": "passive", 
		"desc": "Pasiva: más defensa; los no-muertos y demonios te hieren menos y reciben mucho más daño de ti. Tu daño sagrado deja marcas de Juicio en los monstruos (como mucho 2 por segundo): cada una les hace recibir +3% de daño sagrado. Se borran tras 6 s sin luz.", 
		"bonus": ["armor", "undead_guard", "vs_undead", "judgment"], "armor": 1.0, "undead_guard": 0.08, "vs_undead": 0.12, "judgment": 13.0, 
		"color": Color(1.0, 0.85, 0.4), "per_level": {"armor": 0.6, "undead_guard": 0.05, "vs_undead": 0.07, "judgment": 3.0}}, 



	"demon_bane": {"name": "Demon Bane", "type": "passive", "desc": "Pasiva: más defensa; los no-muertos y demonios te hieren menos y reciben mucho más daño de ti.", 
		"bonus": ["armor", "undead_guard", "vs_undead"], "armor": 1.0, "undead_guard": 0.08, "vs_undead": 0.12, "color": Color(1, 0.9, 0.6), 
		"per_level": {"armor": 0.6, "undead_guard": 0.05, "vs_undead": 0.07}}, 
	"mace_mastery": {"name": "Mace Mastery", "type": "passive", "desc": "Pasiva: más daño con la maza. Tu ataque básico y lo que lanza usan tu INT en vez de tu FUE, si es mayor.", 
		"bonus": ["basic_dmg"], "basic_dmg": 0.08, "color": Color(0.9, 0.85, 0.7), "per_level": {"basic_dmg": 0.08}}, 
	"single_action": {"name": "Single Action", "type": "passive", "desc": "Pasiva: disparas más rápido y más preciso.", 
		"bonus": ["aspd", "crit"], "aspd": 0.04, "crit": 0.01, "color": Color(1, 0.85, 0.6), 
		"per_level": {"aspd": 0.04, "crit": 0.01}}, 
	"snake_eye": {"name": "Snake Eye", "type": "passive", "desc": "Pasiva: puntería: más daño de las balas.", 
		"bonus": ["basic_dmg"], "basic_dmg": 0.06, "color": Color(0.8, 1, 0.7), "per_level": {"basic_dmg": 0.08}}, 
	"chain_action": {"name": "Chain Action", "type": "passive", "desc": "Pasiva: a veces disparas dos veces seguidas. Pasado 100% suma más disparos: 150% son dos seguros y 50% de un tercero, 250% tres seguros y 50% de un cuarto.", 
		"bonus": ["double"], "double": 0.12, "color": Color(1, 0.8, 0.5), "per_level": {"double": 0.06}}, 
	"heal": {"name": "Heal", "type": "heal", "desc": "Cada pocos segundos te cura a ti o al aliado más herido.", 
		"cooldown": 10.0, "amount": 18.0, "color": Color(0.5, 1, 0.6), "sound": "heal", "sound_db": 1.0, "sound_cd": 0.3, 
		"per_level": {"amount": 10.0, "cooldown": -0.8}}, 

	"grand_cross": {"element": "holy", "name": "Grand Cross", "type": "ground", "on_self": true, "fx": "red_cross", "center_fx": "cross", 
		"desc": "Una gran cruz de casillas sagradas bajo tus pies golpea tres veces; hiere más a no-muertos y demonios.", 
		"shape": "gc", "arm": 2, "fx_size": 0.45, "cooldown": 2.4, "damage": 36.0, "area": 3.6, "duration": 1.0, "tick": 0.33, 
		"color": Color(1, 0.85, 0.6), "sound": "grand_cross", 
		"per_level": {"damage": 12.0, "area": 0.25, "cooldown": -0.12}}, 
	"holy_cross": {"element": "holy", "status": "stun", "status_chance": 0.08, "status_time": 1.2, 
		"name": "Holy Cross", "type": "melee_arc", "fx": "holy_cross", "desc": "Dos tajos en cruz bañados en luz sagrada; si no hay nadie cerca, la cruz vuela hasta el monstruo más cercano.", 
		"cooldown": 1.3, "damage": 70.0, "range": 3.4, "arc": 70.0, "knock": 4.0, "wave_range": 8.0, 
		"color": Color(1, 1, 0.8), "sound": "holy_cross", 
		"per_level": {"damage": 22.0, "range": 0.2, "cooldown": -0.07, "status_chance": 0.02}}, 
	"shield_boomerang": {"name": "Shield Boomerang", "type": "projectile", "boomerang": true, "spin": 22.0, "shield_scale": 0.1, 
		"desc": "Lanzas tu propio escudo girando: atraviesa monstruos a la ida y a la vuelta. Pega más con un escudo mejor y más refinado.", 
		"cooldown": 1.3, "damage": 78.0, "count": 1.0, "speed": 15.0, "pierce": 4.0, "range": 9.0, 
		"size": 0.45, "knock": 6.0, "color": Color(0.8, 0.85, 0.95), "sound": "shield_boomerang", "proj_sprite": "item_guard", "tour_wait": 0.08, 
		"per_level": {"damage": 22.0, "pierce": 0.5, "cooldown": -0.07}}, 
	"pressure": {"element": "holy", "status": "stun", "status_chance": 0.35, "status_time": 2.0, 
		"name": "Pressure", "type": "aoe_target", "fx": "cross", "fx_intensity": 0.8, "desc": "El juicio divino aplasta y aturde a los monstruos de una zona.", 
		"cooldown": 4.5, "damage": 170.0, "count": 1.0, "range": 10.0, "area": 3.0, 
		"color": Color(1, 0.95, 0.75), "sound": "pressure", 
		"per_level": {"damage": 48.0, "area": 0.2}}, 




	"heavens_drive": {"impact_fx": true, "element": "earth", "name": "Heaven's Drive", "magic": true, "type": "aoe_target", "fx": "earthhit", 
		"desc": "Picos de roca brotan bajo un grupo de monstruos.", 
		"cooldown": 3.0, "damage": 48.3, "count": 2.0, "range": 10.0, "area": 2.6, 
		"color": Color(0.75, 0.6, 0.4), "sound": "earth_spike", 
		"per_level": {"damage": 16.1, "count": 0.3, "area": 0.15, "cooldown": -0.15}}, 
	"earth_spike": {"impact": 1.0, "trail_tint": Color(0.75, 0.6, 0.42), "hitscan": true, "element": "earth", "name": "Earth Spike", "magic": true, "type": "projectile", "hit_fx": "earthhit", 
		"desc": "Lanzas de roca que rebotan entre los enemigos.", 


		"cooldown": 1.0, "damage": 27.6, "count": 3.0, "speed": 18.0, "pierce": 1.0, "range": 12.0, "spread_bounce": true, 
		"size": 0.35, "same_target": true, "color": Color(0.7, 0.55, 0.35), "sound": "earth_spike", "sound_cd": 1.0, 
		"per_level": {"damage": 9.2, "count": 0.5, "cooldown": -0.04}}, 
	"volcano": {"element": "fire", "name": "Volcano", "magic": true, "type": "ground", "fx": "fire", "on_self": true, 
		"desc": "Tierra volcánica a tu alrededor que quema a los monstruos que la pisan.", 
		"shape": "square", "fx_size": 0.5, "cooldown": 7.0, "damage": 16.1, "area": 3.2, 
		"duration": 5.0, "tick": 0.6, "color": Color(1, 0.5, 0.2), "sound": "magnum", 
		"per_level": {"damage": 5.8, "area": 0.2}}, 
	"spider_web": {"name": "Spider Web", "type": "aoe_target", "hit_sprite": "fx_wideweb", "web_fire": true, 
		"desc": "Telarañas que atrapan y frenan a los monstruos de varias zonas. Los atrapados reciben el doble de daño de Fuego, Agua, Tierra y Viento.", 
		"cooldown": 4.0, "damage": 34.5, "count": 3.0, "range": 9.0, "area": 2.0, "slow": 4.0, 
		"color": Color(0.9, 0.9, 0.95), "sound": "earth_spike", 
		"per_level": {"damage": 10.3, "count": 0.4, "area": 0.12}}, 

	"musical_strike": {"uses_arrows": true, "name": "Musical Strike", "type": "projectile", "desc": "Una flecha cargada de música que rebota entre los monstruos. En cada Bis dispara otra andanada.", 
		"cooldown": 0.9, "damage": 34.0, "count": 1.0, "speed": 22.0, "pierce": 3.0, "range": 10.0, 
		"size": 0.25, "arrow": true, "streak": Color(1.0, 0.75, 0.95), "color": Color(0.95, 0.9, 0.75), "sound": "bow", "hit_sound": "arrow_hit", 
		"per_level": {"damage": 10.0, "pierce": 0.5, "cooldown": -0.05}}, 




	"dissonance": {"name": "Dissonance", "type": "aoe_self", "fx": "shockwave", "fx_size": 0.35, "fx_intensity": 0.45, "tex_fx": "melody_a", "desc": "Canción o danza: mientras tocas, una melodía disonante hiere sin parar a los monstruos cercanos; +30% por cada otra canción o danza que suene. En el Bis, otro golpe del doble.", 
		"cooldown": 1.5, "damage": 50.0, "range": 4.0, "knock": 1.5, 
		"color": Color(0.85, 0.6, 1.0), "sound": "musical", "song": true, 
		"per_level": {"damage": 16.0, "range": 0.3, "cooldown": -0.06}}, 
	"poem_of_bragi": {"name": "A Poem of Bragi", "type": "buff", "tex_fx": "melody_b", "tex_count": 3, "desc": "Canción: mientras tocas, tus habilidades y las de tu grupo dentro de su aura se recargan más rápido; el doble en el Bis.", 
		"cooldown": 12.0, "bonus": ["haste"], "haste": 0.08, 
		"color": Color(0.8, 0.7, 1.0), "sound": "song_bragi", "song": true, 
		"per_level": {"haste": 0.03}}, 
	"assassin_cross_sunset": {"name": "Assassin Cross of Sunset", "type": "buff", "tex_fx": "melody_b", "tex_count": 3, 
		"desc": "Canción: mientras tocas, tú y tu grupo dentro de su aura atacan más rápido; el doble en el Bis.", 
		"cooldown": 12.0, "bonus": ["aspd"], "aspd": 0.1, "color": Color(1.0, 0.7, 0.45), "sound": "song_sunset", "song": true, 
		"per_level": {"aspd": 0.04}}, 
	"service_for_you": {"name": "Service for You", "type": "buff", "tex_fx": "melody_b", "tex_count": 3, 
		"desc": "Danza: a cada compás adelanta las recargas de tus habilidades y las de tu grupo dentro de su aura; el doble en el Bis.", 
		"cooldown": 12.0, "bonus": [], "relief": 0.04, "color": Color(1.0, 0.6, 0.85), "sound": "musical", "song": true, "dance": true, 
		"per_level": {"relief": 0.012}}, 
	"scream": {"name": "Scream", "type": "aoe_self", "fx": "shockwave", "fx_size": 0.35, "fx_intensity": 0.45, "desc": "Danza: mientras bailas, un grito aturde a los monstruos de alrededor (a los MVP les llena el Aguante). En el Bis, un grito del doble.", 
		"cooldown": 2.8, "damage": 36.0, "range": 4.2, "knock": 0.8, "status": "stun", "status_chance": 0.3, "status_time": 1.2, 
		"color": Color(0.75, 0.9, 1.0), "sound": "scream", "song": true, "dance": true, 
		"per_level": {"damage": 13.0, "range": 0.25, "status_chance": 0.07, "cooldown": -0.1}}, 
	"arrow_vulcan": {"impact": 0.5, "trail_tint": Color(1.0, 0.85, 0.55), "uses_arrows": true, "name": "Arrow Vulcan", "type": "projectile", "same_target": true, 
		"desc": "Nueve flechas en crescendo contra un solo enemigo: cada una pega más que la anterior y la última estalla en un fortissimo alrededor. Con Bragi o Assassin Cross of Sunset sonando: ×1,4 de daño y una flecha más por canción (×1,8 con las dos).", 
		"crescendo": 0.08, "finale": 1.5, "finale_area": 2.6, 
		"cooldown": 2.2, "damage": 40.0, "count": 9.0, "speed": 24.0, "pierce": 1.0, "range": 10.0, 
		"size": 0.22, "arrow": true, "streak": Color(1.0, 0.7, 0.75), "color": Color(0.95, 0.9, 0.75), "sound": "arrow_vulcan", "hit_sound": "arrow_hit", 
		"per_level": {"damage": 12.0, "cooldown": -0.1}}, 




	"soul_breaker": {"name": "Soul Destroyer", "type": "soul_breaker", "souls_max": 5, 
		"desc": "Una hoja de alma al monstruo más fuerte a tu alcance (jefes primero) que estalla en área. Cada monstruo que matas cerca y cada hoja en un jefe te dan un alma; con 5, el siguiente las libera: una hoja más por alma, al 50%. FUE e INT.", 
		"cooldown": 2.6, "damage": 190.0, "range": 9.0, "area": 1.8, "count": 1.0, 
		"color": Color(0.7, 0.32, 1.0), "sound": "soul_strike", 
		"per_level": {"damage": 60.0, "area": 0.08, "cooldown": -0.12}}, 
	"soul_breaker_x": {"name": "Soul Destroyer EX", "type": "soul_breaker", "evolved": true, "souls": 3, "souls_max": 8, 
		"desc": "Tres hojas de alma a los más fuertes a tu alcance (todas al mismo si está solo). El alma de cada monstruo que matan salta al siguiente, hasta 3 veces. Con 8 almas, el siguiente suma 8 hojas al 50%.", 
		"cooldown": 1.5, "damage": 900.0, "range": 11.0, "area": 2.6, "count": 3.0, 
		"color": Color(0.7, 0.32, 1.0), "sound": "soul_strike"}, 
	"full_strip": {"name": "Full Strip", "type": "full_strip", "loot_max": 8, "knock": 2.0, 
		"desc": "Desarmas a los monstruos a tu alrededor: reciben más daño de todos y fallan más. Cada uno te da una carga de Botín: más daño, hasta 8 cargas.", 
		"cooldown": 5.0, "damage": 40.0, "range": 3.4, "duration": 5.0, "strip_taken": 0.15, 
		"color": Color(1.0, 0.78, 0.32), "sound": "strip", 
		"per_level": {"damage": 14.0, "range": 0.15, "duration": 0.3, "strip_taken": 0.015, "cooldown": -0.25}}, 
	"full_strip_x": {"name": "Full Strip EX", "type": "full_strip", "evolved": true, "strip_boss": true, "loot_max": 15, "knock": 3.0, 
		"desc": "Desarmas a todo a tu alrededor, jefes y MVP incluidos: reciben mucho más daño de todos y fallan más. Botín llega hasta 15 cargas.", 
		"cooldown": 2.4, "damage": 220.0, "range": 5.5, "duration": 8.0, "strip_taken": 0.35, 
		"color": Color(1.0, 0.78, 0.32), "sound": "strip"}, 
	"back_stab": {"name": "Back Stab", "type": "backstab", "desc": "Saltas de espalda en espalda hacia donde caminas, apuñalando a cada monstruo cada vez más fuerte. Se puede apagar.", 
		"cooldown": 2.4, "damage": 120.0, "count": 3.0, "range": 7.0, "area": 1.4, "knock": 2.0, 
		"color": Color(0.9, 0.8, 1.0), "sound": "back_stab", 
		"per_level": {"damage": 42.0, "range": 0.4, "cooldown": -0.07}}, 


	"raid": {"status": "stun", "status_chance": 0.25, "status_time": 1.5, "blind_chance": 0.3, "blind_time": 3.0, 
		"name": "Raid", "type": "aoe_self", "fx": "hit", "desc": "Sales de las sombras: golpeas, aturdes y cegas a todos a tu alrededor (sus ataques fallan más).", 
		"cooldown": 3.0, "damage": 45.0, "range": 3.0, "knock": 5.0, 
		"color": Color(0.7, 0.6, 0.9), "sound": "sonic_blow", 
		"per_level": {"damage": 14.0, "range": 0.2, "status_chance": 0.04, "blind_chance": 0.05, "cooldown": -0.15}}, 
	"reject_sword": {"name": "Reject Sword", "type": "shield", "fx": "guardian", "desc": "Desvías las espadas: un escudo que absorbe daño a menudo.", 
		"cooldown": 7.0, "amount": 60.0, "sound": "endure", "color": Color(0.85, 0.85, 1.0), 
		"per_level": {"amount": 20.0, "cooldown": -0.5}}, 

	"asura_strike": {"name": "Asura Strike", "type": "asura", "needs": "call_spirits", 
		"desc": "Saltas al enemigo más fuerte y estallas arrasando la zona. Gasta tus esferas: con las 5 pega con todo.", 
		"cooldown": 14.0, "damage": 520.0, "range": 5.5, "knock": 14.0, 
		"color": Color(0.75, 0.85, 1.0), "sound": "asura", 
		"per_level": {"damage": 170.0, "range": 0.3, "cooldown": -0.6}}, 






	"critical_explosion": {"name": "Critical Explosion", "type": "fury", 
		"desc": "爆氣: estallas en ki dorado unos segundos: +10% de crítico, +30% de daño crítico (+10% por nivel) y cada crítico tiene un 15% (+5% por nivel) de encadenar un golpe de ki al monstruo más cercano con la mitad de su daño. Ganas esferas espirituales el doble de rápido.", 
		"cooldown": 20.0, "duration": 8.0, "crit": 0.1, "crit_dmg": 0.3, "ki_chain": 0.15, "color": Color(1.0, 0.85, 0.35), "sound": "critical_explosion", 
		"per_level": {"crit_dmg": 0.1, "ki_chain": 0.05, "duration": 0.5, "cooldown": -1.0}}, 

	"finger_offensive": {"name": "Finger Offensive", "type": "finger", "needs": "call_spirits", "desc": "Lanzas una tras otra tus esferas espirituales contra un enemigo.", 
		"cooldown": 1.6, "damage": 36.0, "speed": 26.0, "pierce": 1.0, "range": 9.0, 
		"size": 0.22, "color": Color(1, 1, 1), "sound": "finger_offensive", "hit_sound": "hit_fist", 
		"proj_tex": "spirit_ball", "proj_frames": 1, "proj_blend": "mix", "proj_scale": 1.0, "shot_gap": 0.12, "tour_wait": 0.12, 
		"per_level": {"damage": 10.0, "cooldown": -0.06}}, 



	"investigate": {"name": "Occult Impaction", "type": "line", "line_fx": "investigate", 
		"desc": "Un golpe de ki que atraviesa al enemigo y golpea a todos los que están detrás.", 
		"cooldown": 1.1, "damage": 100.0, "count": 1.0, "range": 4.5, "length": 7.0, "width": 1.4, "knock": 2.5, 
		"color": Color(1, 0.95, 0.7), "sound": "hit_fist", 
		"per_level": {"damage": 26.0, "cooldown": -0.06}}, 




	"steel_body": {"name": "Steel Body", "type": "steel_body", 
		"desc": "Tu cuerpo se vuelve de acero unos segundos: recibes mucho menos daño, caminas lento y tus cartas al recibir golpes salen el doble. Mientras dura, lo que lanzan solos tus cartas y tu equipo hace un 5% más de daño por nivel (×1,25 en Nv5).", 
		"cooldown": 16.0, "duration": 6.0, "guard": 0.5, "proc_power": 0.05, "color": Color(0.7, 0.78, 0.9), "sound": "steel_body", 
		"per_level": {"guard": 0.04, "proc_power": 0.05, "duration": 0.4, "cooldown": -0.8}}, 
	"chain_crush": {"name": "Chain Crush Combo", "type": "melee_arc", "fx": "bowling", "combo_only": true, "needs": "combo_finish", 
		"desc": "Cuarto golpe del combo del Monk: con 12 cargas de combo o más, tras Raging Thrust, una ráfaga de puños que golpea todo a tu alrededor y gasta las cargas: +8% de daño y +1,5% de alcance por cada una.", 
		"cooldown": 1.8, "damage": 225.0, "range": 3.6, "arc": 360.0, "knock": 8.0, 
		"color": Color(1, 0.9, 0.6), "sound": "chain_combo", 
		"per_level": {"damage": 63.0, "range": 0.2, "cooldown": -0.1}}, 

	"auto_guard": {"name": "Auto Guard", "type": "passive", "needs_shield": true, 
		"desc": "Pasiva: con escudo, a veces bloqueas un golpe por completo. Cada refinamiento del escudo suma bloqueo.", 
		"bonus": ["block"], "block": 0.08, "color": Color(0.75, 0.85, 1.0), 
		"per_level": {"block": 0.025}}, 



	"gospel": {"element": "holy", "name": "Gospel", "type": "gospel", 
		"desc": "Cantas el Gospel en medio de la horda: cada pocos segundos un verso te cura, te fortalece o castiga con luz sagrada a los monstruos de alrededor. Mientras cantas, tus cartas que se lanzan al recibir un golpe salen más seguido.", 
		"cooldown": 24.0, "duration": 9.0, "damage": 60.0, "range": 6.0, "every": 1.5, "color": Color(1.0, 0.92, 0.6), "sound": "magnificat", 
		"per_level": {"damage": 20.0, "duration": 1.0, "range": 0.3, "cooldown": -1.0}}, 


	"martyrs_reckoning": {"name": "Martyr's Reckoning", "type": "sacrifice", 
		"desc": "Sacrificas parte de tu vida y por unos segundos tus ataques básicos golpean con un porcentaje de tu vida máxima en vez de tu ataque: con mucha vida pegas más que con fuerza.", 
		"cooldown": 14.0, "duration": 6.0, "hp_cost": 0.09, "hp_dmg": 0.08, "color": Color(1.0, 0.75, 0.55), "sound": "grand_cross", 
		"per_level": {"hp_dmg": 0.02, "duration": 0.5}}, 



	"provoke": {"name": "Provoke", "type": "taunt", 
		"desc": "Provocas a todos los monstruos alrededor, MVP y Satan Morroc incluidos: te persiguen a ti, dirigen sus mecánicas a ti y mientras dura tienes más defensa.", 
		"cooldown": 12.0, "duration": 4.0, "damage": 30.0, "range": 6.5, "color": Color(1.0, 0.45, 0.3), "sound": "provoke", 
		"per_level": {"damage": 12.0, "duration": 0.4, "range": 0.4, "cooldown": -0.7}}, 
	"provoke_x": {"name": "Provoke EX", "type": "taunt", "evolved": true, "pulse": 1.5, "vuln": 0.15, "tank_hp": 0.063, "tank_def": 12.0, 
		"desc": "Un desafío enorme: renueva la provocación mientras dura, tienes mucha más defensa y los provocados reciben ×1,15 de daño de todos. Su daño escala con tu vida y defensa.", 
		"cooldown": 7.0, "duration": 7.0, "damage": 160.0, "range": 11.0, "color": Color(1.0, 0.45, 0.3), "sound": "provoke"}, 
	"gospel_x": {"element": "holy", "name": "Gospel EX", "type": "gospel", "evolved": true, "tank_hp": 0.0255, "tank_def": 9.0, 
		"desc": "Un Gospel más amplio, largo y frecuente. Su daño escala con tu vida y defensa.", 
		"cooldown": 15.0, "duration": 16.0, "damage": 260.0, "range": 8.5, "every": 1.2, "color": Color(1.0, 0.92, 0.6), "sound": "magnificat"}, 




	"shield_chain": {"name": "Shield Chain", "type": "shield_chain", "shield_scale": 0.1, 
		"desc": "Lanzas tu escudo en una cadena de golpes que salta entre los monstruos más fuertes cerca, jefes y MVP primero; si no queda otro, vuelve al mismo. Pega más con un escudo mejor y más refinado.", 
		"cooldown": 3.2, "damage": 64.0, "count": 4.0, "range": 8.0, "color": Color(1.0, 0.88, 0.5), "sound": "shield_boomerang", 
		"per_level": {"damage": 22.0, "cooldown": -0.14, "count": 0.12}}, 
	"shield_chain_x": {"name": "Shield Chain EX", "type": "shield_chain", "evolved": true, "shield_scale": 0.1, "tank_hp": 0.018, "tank_def": 7.5, 
		"desc": "Una cadena más larga y rápida. Cada golpe que bloqueas o devuelves guarda un salto más para la próxima (hasta 5) y el último salto estalla en luz sagrada alrededor. Su daño escala con tu vida y defensa.", 
		"cooldown": 1.7, "damage": 300.0, "count": 6.0, "range": 9.5, "color": Color(1.0, 0.88, 0.5), "sound": "shield_boomerang"}, 
	"martyrs_reckoning_x": {"name": "Martyr's Reckoning EX", "type": "sacrifice", "evolved": true, "tank_def_pct": 0.003, 
		"desc": "Cuesta menos vida y dura más; tus básicos golpean con más % de tu vida máxima, y cada punto de defensa lo sube.", 
		"cooldown": 11.0, "duration": 9.0, "hp_cost": 0.07, "hp_dmg": 0.26, "color": Color(1.0, 0.75, 0.55), "sound": "grand_cross"}, 
	"faith": {"name": "Faith", "type": "passive", "desc": "Pasiva: más vida máxima y defensa, y tus cartas que se lanzan al recibir un golpe salen más seguido.", 
		"bonus": ["max_hp_pct", "armor", "hit_proc"], "max_hp_pct": 0.05, "armor": 1.0, "hit_proc": 0.1, "color": Color(1, 0.95, 0.7), 
		"per_level": {"max_hp_pct": 0.04, "armor": 0.5, "hit_proc": 0.05}}, 
	"advanced_book": {"name": "Advanced Book", "type": "passive", "desc": "Pasiva: más daño de habilidades y recargas más rápidas.", 
		"bonus": ["skill_dmg", "haste"], "skill_dmg": 0.08, "haste": 0.03, "color": Color(0.8, 0.7, 0.5), 
		"per_level": {"skill_dmg": 0.14, "haste": 0.03}}, 
	"music_lessons": {"name": "Music Lessons", "type": "passive", "desc": "Pasiva: más velocidad de ataque y de movimiento.", 
		"bonus": ["aspd", "move"], "aspd": 0.04, "move": 0.02, "color": Color(0.8, 0.7, 1.0), 
		"per_level": {"aspd": 0.04, "move": 0.03}}, 
	"snatcher": {"name": "Snatcher", "type": "passive", "desc": "Pasiva: más zeny y a veces golpeas dos veces.", 
		"bonus": ["loot", "double"], "loot": 0.06, "double": 0.06, "color": Color(0.9, 0.85, 0.5), 
		"per_level": {"loot": 0.04, "double": 0.03}}, 




	"call_spirits": {"name": "Summon Spirit Sphere", "type": "passive", 
		"desc": "Pasiva: hasta 5 esferas espirituales giran a tu alrededor y se cargan con cada golpe que das. Cada esfera que tienes da daño del ataque básico (más con cada nivel) y velocidad de ataque. Asura Strike las gasta para pegar con todo.", 
		"bonus": ["spheres", "sphere_power"], "spheres": 5.0, "sphere_power": 0.03, "color": Color(1, 1, 0.9), 
		"per_level": {"sphere_power": 0.01}}, 
	"triple_attack": {"name": "Raging Trifecta Blow", "type": "passive", "desc": "Pasiva: a veces tu puñetazo se vuelve un triple golpe y abre el combo del Monk (todo el combo es ataque básico y puede ser crítico). Cada golpe del combo es una carga (hasta 30): +4% de daño al combo.", 
		"bonus": ["triple"], "triple": 0.12, "color": Color(1, 0.9, 0.7), 
		"per_level": {"triple": 0.05}}, 
	"chain_combo": {"name": "Raging Quadruple Blow", "type": "passive", "needs": "triple_attack", "desc": "Pasiva: tras Raging Trifecta Blow encadenas cuatro puñetazos más fuertes.", 
		"bonus": ["chain_combo"], "chain_combo": 3.2, "color": Color(1, 0.8, 0.5), 
		"per_level": {"chain_combo": 0.7}}, 
	"combo_finish": {"name": "Raging Thrust", "type": "passive", "needs": "chain_combo", "desc": "Pasiva: tras Raging Quadruple Blow cierras el combo con un golpe que estalla alrededor del monstruo y lo lanza: todo lo que está en su camino recibe el 60%.", 
		"bonus": ["combo_finish"], "combo_finish": 8.0, "color": Color(1, 0.65, 0.35), 
		"per_level": {"combo_finish": 2.0}}, 
	"mystical_amplification": {"name": "Mystical Amplification", "type": "passive", 
		"desc": "Pasiva: tu bono de área no pasa de +200%, pero el poder mágico comprimido multiplica el daño de tus hechizos, y cada 1% de área por encima del tope es +1% de daño de habilidades.", 
		"bonus": ["amp"], "amp": 1.0, "color": Color(0.75, 0.6, 1.0), 
		"per_level": {"amp": 0.4}}, 
	"auto_counter": {"name": "Auto Counter", "type": "passive", "desc": "Pasiva: a veces devuelves el golpe que recibes con un crítico (como mucho uno cada 0,5 s). Pasado el 100% de probabilidad, lo que sobra se suma al daño del contraataque: cada 1% de más, +1% de daño.", 
		"bonus": ["auto_counter"], "auto_counter": 0.12, "color": Color(0.9, 0.9, 1.0), 
		"per_level": {"auto_counter": 0.03}}, 


	"parrying": {"name": "Parrying", "type": "passive", "desc": "Pasiva, solo con arma a dos manos: atraes a los monstruos cercanos y paras golpes, también de jefes. Cada parada da una carga de Filo (hasta 10): +2% de daño y −6% de daño recibido. Cada 4 paradas, Riposte: un tajo a tu alrededor que te cura un 2% de vida.", 
		"bonus": ["parry", "riposte"], "parry": 0.3, "riposte": 3.0, "over_never": ["parry"], "color": Color(0.75, 0.9, 1.0), 
		"per_level": {"parry": 0.05, "riposte": 0.5}}, 
	"reflect_shield": {"name": "Reflect Shield", "type": "passive", "needs_shield": true, 
		"desc": "Pasiva: con escudo, devuelves al atacante parte del daño que recibes, también el de las mecánicas de los MVP.", 
		"bonus": ["reflect"], "reflect": 0.3, "color": Color(0.8, 0.85, 1.0), 
		"per_level": {"reflect": 0.1}}, 


	"double_casting": {"name": "Double Casting", "type": "passive", "desc": "Pasiva: tus habilidades y los hechizos de Hindsight a veces se lanzan dos veces (Professor: más seguido), cada copia contra otro monstruo. Tu INT da doble lanzamiento sin el tope del 25%. Pasado el 100%: triple, luego cuádruple. Copiada con Plagio: la mitad de su bonus y tu INT conserva el tope del 25%. ×Lv", 
		"bonus": ["sage_double"], "sage_double": 0.1, "color": Color(0.85, 0.75, 1.0), 
		"per_level": {"sage_double": 0.03}}, 





	"dragonology": {"name": "Dragonology", "type": "passive", "desc": "Pasiva del Professor: más daño de todo, como un multiplicador aparte. Además, la velocidad de recarga que pierdes por su rendimiento decreciente se vuelve daño de habilidades. ×Lv", 
		"bonus": ["dragon"], "dragon": 0.15, "color": Color(0.55, 0.85, 0.5), 
		"per_level": {"dragon": 0.07}}, 
	"hindsight": {"name": "Hindsight", "type": "passive", "desc": "Pasiva: tu ataque básico a veces lanza solo un Fire Bolt, Cold Bolt, Frost Diver, Earth Spike o Heaven's Drive. ×Lv", 
		"bonus": ["hindsight"], "hindsight": 0.08, "color": Color(0.85, 0.75, 1.0), 
		"per_level": {"hindsight": 0.03}}, 
	"venom_splasher": {"name": "Venom Splasher", "type": "passive", "desc": "Pasiva: tu veneno, sangrado y quemadura hacen más daño.", 
		"bonus": ["poison_dmg", "bleed_dmg", "burn_power"], "poison_dmg": 0.1, "bleed_dmg": 0.1, "burn_power": 0.1, "color": Color(0.7, 0.45, 0.85), 
		"per_level": {"poison_dmg": 0.08, "bleed_dmg": 0.08, "burn_power": 0.08}}, 

	"endow_blaze": {"name": "Endow Blaze", "type": "passive", "desc": "Pasiva: tus habilidades pueden quemar aunque no sean de fuego, y tus quemaduras pegan más. ×Lv", 
		"bonus": ["skill_burn", "burn_power"], "skill_burn": 0.1, "burn_power": 0.1, "color": Color(1.0, 0.55, 0.2), 
		"per_level": {"skill_burn": 0.05, "burn_power": 0.1}}, 
	"enchant_poison": {"name": "Enchant Poison", "type": "passive", "desc": "Pasiva: tu arma envenena con cada golpe básico. El veneno se acumula.", 
		"bonus": ["poison_hit"], "poison_hit": 0.3, "color": Color(0.6, 0.9, 0.4), 
		"per_level": {"poison_hit": 0.1}}, 

	"aspersio": {"name": "Aspersio", "type": "passive", 
		"desc": "Pasiva: tu arma está bendita: tus ataques son de elemento Sagrado y pegan más a no-muertos y demonios. Lo que matas con el ataque básico estalla en luz sagrada y la luz rebota a otros monstruos: si los mata, también estallan.", 
		"bonus": ["holy_weapon", "vs_undead"], "holy_weapon": 1.0, "vs_undead": 0.1, "color": Color(0.9, 0.95, 1.0), 
		"asp_burst": 0.9, "asp_bounces": 2.0, 
		"per_level": {"vs_undead": 0.06, "asp_burst": 0.15, "asp_bounces": 0.5}}, 












	"oridecon_research": {"name": "Oridecon Research", "type": "passive", 
		"desc": "Pasiva: cada Oridecon y Elunium que recoges refina solo tu equipo, la pieza más baja primero; si falla, nunca baja ni se rompe. Hasta +12 (+2 por nivel: +20 a Nv5) en la partida y tu build guardada. Por nivel: +5% de éxito y +20% de materiales.", 
		"bonus": [], "color": Color(0.75, 0.6, 0.95)}, 
	"weapon_perfection": {"name": "Weapon Perfection", "type": "passive", "desc": "Pasiva: todos tus golpes (ataque básico y habilidades) pegan siempre su máximo y hacen más daño a jefes y MVP.", 
		"bonus": ["weapon_perfection"], "weapon_perfection": 0.1, "color": Color(1.0, 0.85, 0.6), 
		"per_level": {"weapon_perfection": 0.05}}, 
	"call_homunculus": {"name": "Call Homunculus", "type": "passive", 
		"desc": "Pasiva: llamas a tu Homúnculo, que pelea a tu lado y se hace más fuerte con cada nivel. La primera vez eliges cuál. Pega con el ATK de tu arma y tu INT, tu crítico y el daño de invocaciones.", 
		"bonus": [], "color": Color(0.8, 0.9, 1.0)}, 

	"call_homunculus_x": {"name": "Call Homunculus EX", "type": "passive", "evolved": true, 
		"desc": "Mutación: tus Homúnculos pasan a su forma S, más grandes y fuertes. Te acompaña uno más, cada uno lanza su habilidad especial cada 7 s (menos con tu reducción de recarga), sus auras valen un 50% más y pegan más cuantos más te acompañan.", 
		"bonus": [], "color": Color(0.85, 1.0, 0.9)}, 

	"homun_lif": {"name": "Lif", "type": "passive", "bonus": [], "color": Color(0.7, 1.0, 0.7), 
		"desc": "Apoyo: cura al más herido del grupo cada pocos segundos. Mientras está contigo regeneras vida y tus curas curan más."}, 
	"homun_amistr": {"name": "Amistr", "type": "passive", "bonus": [], "color": Color(0.9, 0.8, 0.6), 
		"desc": "Cuerpo a cuerpo: golpes lentos y muy fuertes alrededor del objetivo que aturden. Mientras está contigo tienes más defensa y vida."}, 
	"homun_filir": {"name": "Filir", "type": "passive", "bonus": [], "color": Color(1.0, 0.7, 0.5), 
		"desc": "Ataque básico: picotazos de tres golpes muy seguidos. Mientras está contigo atacas más rápido y tu básico pega más."}, 
	"homun_vanilmirth": {"name": "Vanilmirth", "type": "passive", "bonus": [], "color": Color(0.85, 0.75, 1.0), 
		"desc": "Suelo: estallidos de fuego, agua o viento que dejan un charco de su elemento. Mientras está contigo tus habilidades tienen más área y daño."}, 



	"adjustment": {"name": "Adjustment", "type": "passive", "early": true, 
		"desc": "Pasiva: ajuste de pistolero. Mientras te mueves recibes menos daño y cada monstruo que matas te cura un poco de vida.", 
		"bonus": ["adjust", "kill_heal"], "adjust": 0.2, "kill_heal": 0.004, "color": Color(0.85, 0.8, 0.6), 
		"per_level": {"adjust": 0.03, "kill_heal": 0.0007}}, 
	"coin_flip": {"name": "Coin Flip", "type": "passive", "desc": "Pasiva: matando y con críticos juntas monedas, cada una +2% de daño y +1% de crítico. Un golpe te hace perder una.", 
		"bonus": ["coins"], "coins": 4.0, "color": Color(1.0, 0.85, 0.3), 
		"per_level": {"coins": 1.5}}, 
	"iron_hand": {"name": "Iron Fists", "type": "passive", "desc": "Pasiva: más daño de tus puños en el ataque básico.", 
		"bonus": ["basic_dmg"], "basic_dmg": 0.08, "color": Color(0.85, 0.8, 0.7), 
		"per_level": {"basic_dmg": 0.08}}, 



	"mammonite": {"name": "Mammonite", "type": "melee_arc", "fx": "maemor", 
		"desc": "Golpe de hacha pagado con zeny de la partida: daño enorme frente a ti, el doble en los primeros niveles. Sin zeny pega mucho menos.", 
		"cooldown": 1.1, "damage": 84.0, "range": 3.3, "arc": 170.0, "knock": 3.0, "zeny_cost": 1.0, 
		"color": Color(1, 0.85, 0.35), "sound": "mammonite", "sound_extra": "coin2", 
		"per_level": {"damage": 27.0, "zeny_cost": 1.0, "cooldown": -0.05}}, 
	"cart_revolution": {"name": "Cart Revolution", "type": "aoe_self", "fx": "cartrevolution", "fx_size": 0.8, 
		"desc": "Giras el carro a tu alrededor y lanzas lejos a los monstruos.", 
		"cooldown": 2.6, "damage": 38.0, "range": 3.6, "knock": 7.0, 
		"color": Color(0.9, 0.75, 0.5), "sound": "cart_revolution", 
		"per_level": {"damage": 12.5, "range": 0.3, "cooldown": -0.12}}, 
	"loud_exclamation": {"name": "Loud Exclamation", "type": "buff", "fx": "loud", 
		"desc": "¡Grito de guerra! Más daño de todo lo que haces: ataque básico y habilidades.", 
		"cooldown": 12.0, "bonus": ["dmg"], "dmg": 0.05, 
		"color": Color(1, 0.7, 0.4), "sound": "loud_exclamation", 
		"per_level": {"dmg": 0.03}}, 


	"discount": {"name": "Discount", "type": "passive", "desc": "Pasiva: regateas y vendes más caro: Mammonite y Cart Termination cuestan menos zeny y el botín da más zeny.", 
		"bonus": ["zeny_discount", "loot"], "zeny_discount": 0.12, "loot": 0.08, "color": Color(1, 0.85, 0.4), 
		"per_level": {"zeny_discount": 0.06, "loot": 0.05}}, 


	"overcharge": {"name": "Overcharge", "type": "passive", "desc": "Pasiva: vendes más caro: más zeny del botín.", 
		"bonus": ["loot"], "loot": 0.08, "color": Color(1, 0.8, 0.3), 
		"per_level": {"loot": 0.05}}, 
	"pushcart": {"name": "Pushcart", "type": "passive", "desc": "Pasiva: el carro ya no te frena y te cubre: más velocidad y defensa. Al rodar atropella a los monstruos que toca: daño con FUE y los empuja.", 
		"bonus": ["move", "armor"], "move": 0.03, "armor": 0.5, "color": Color(0.85, 0.7, 0.5), 
		"per_level": {"move": 0.03, "armor": 0.4}}, 

	"hammer_fall": {"status": "stun", "status_chance": 0.3, "status_time": 2.0, 
		"name": "Hammer Fall", "type": "aoe_self", "fx": "black_hammerfall", 
		"desc": "Golpeas el suelo con el hacha: daña y aturde a todos a tu alrededor. Llena mucho el Aguante de jefes y MVP; si tú lo rompes (Quiebre de forja), quedan aturdidos más tiempo y les pegas x5.", 


		"cooldown": 4.0, "damage": 40.0, "range": 3.0, "knock": 1.0, "stagger_fill": 7.0, 
		"color": Color(1, 0.8, 0.5), "sound": "hammer_fall", 
		"per_level": {"damage": 13.0, "range": 0.25, "status_chance": 0.06, "cooldown": -0.2, "stagger_fill": 1.0}}, 
	"adrenaline_rush": {"name": "Adrenaline Rush", "type": "buff", "fx": "adrenaline", 
		"desc": "Adrenalina: tu ataque básico va mucho más rápido (el de tus aliados cercanos, algo más).", 
		"cooldown": 12.0, "bonus": ["aspd"], "aspd": 0.1, 
		"color": Color(1, 0.5, 0.4), "sound": "adrenaline_rush", 
		"per_level": {"aspd": 0.04}}, 


	"over_thrust": {"name": "Over Thrust", "type": "buff", 
		"desc": "Fuerza descomunal: más daño de todo lo que haces, ataque básico y habilidades (algo más a tus aliados cercanos).", 
		"cooldown": 12.0, "bonus": ["dmg"], "dmg": 0.08, 
		"color": Color(1, 0.55, 0.3), "sound": "over_thrust", 
		"per_level": {"dmg": 0.04}}, 
	"cart_termination": {"status": "stun", "status_chance": 0.1, "status_time": 1.5, 
		"name": "Cart Termination", "type": "melee_arc", "fx": "cartrevolution", "fx_size": 1.3, "zeny_cost": 6.0, "zeny_power": true, 
		"desc": "Embistes con el carro cargado: golpe brutal que crece con el zeny ganado en la partida (cuesta zeny).", 
		"cooldown": 2.2, "damage": 190.0, "range": 3.4, "arc": 90.0, "knock": 9.0, 
		"color": Color(1, 0.85, 0.5), "sound": "mammonite", "sound_extra": "coin2", 
		"per_level": {"damage": 55.0, "zeny_cost": 2.0, "cooldown": -0.1}}, 
	"weaponry_research": {"name": "Weaponry Research", "type": "passive", "desc": "Pasiva: conoces cada arma: más daño del ataque básico, y aún más por cada nivel de refinado del arma.", 
		"bonus": ["basic_dmg", "forge_basic"], "basic_dmg": 0.05, "forge_basic": 0.01, "color": Color(0.85, 0.75, 0.6), 
		"per_level": {"basic_dmg": 0.06, "forge_basic": 0.004}}, 


	"axe_tornado": {"name": "Axe Tornado", "type": "axe_tornado", "fx": "mineffect/new_axetornado/new_axetornado/new_axetornado", "hits": 2.0, 
		"desc": "Giras el hacha como un torbellino: dos golpes a todos a tu alrededor, incluso caminando. Cuanto más refinada está tu arma, más grande el torbellino, y cuanto más caliente está la forja, más grande y rápido gira (hasta 4 golpes).", 
		"cooldown": 1.8, "damage": 26.0, "range": 2.4, "knock": 1.2, "forge_area": 0.03, 
		"color": Color(1.0, 0.75, 0.45), "sound": "axe_tornado", 
		"per_level": {"damage": 9.0, "range": 0.12, "cooldown": -0.08}}, 


	"cart_cannon": {"name": "Cart Cannon", "type": "cart_cannon", 
		"desc": "El carro dispara su cañón al monstruo más fuerte a tu alcance: la bala cae y estalla en área. Cuanto más refinada está tu arma, mayor la explosión.", 
		"cooldown": 2.6, "damage": 62.0, "range": 10.0, "area": 1.9, "count": 1.0, "knock": 4.0, "forge_area": 0.03, 
		"color": Color(1.0, 0.6, 0.3), "sound": "cart_cannon", 
		"per_level": {"damage": 20.0, "area": 0.1, "cooldown": -0.1}}, 

	"meltdown": {"name": "Meltdown", "type": "buff", "fx": "melt", 
		"desc": "Tus golpes funden el metal: cada golpe básico hace que el monstruo reciba más daño de todo durante 3 s.", 
		"cooldown": 12.0, "bonus": ["melt"], "melt": 0.08, "color": Color(1.0, 0.5, 0.3), "sound": "meltdown", 
		"per_level": {"melt": 0.03}}, 

	"wiz_combo": {"name": "Elemental Combo", "type": "passive", "bonus": [], "color": Color(0.8, 0.85, 1.0), 
		"desc": "Las reacciones entre elementos de tus hechizos."}, 

	"ka_kaite": {"name": "Ka-Kaite", "type": "passive", "magic": true, "bonus": [], "color": Color(0.75, 0.65, 1.0), 
		"desc": "Estin, Esma y Eswoo seguidos en 3 s: una explosión de espíritus del elemento de Mild Wind."}, 
	"kaite_wave": {"name": "Onda de Kaite", "type": "passive", "magic": true, "bonus": [], "color": Color(0.8, 0.85, 1.0), 
		"desc": "Lo que Kaite se tragó sale en una onda de espíritus."}, 
	"soul_chain": {"name": "Cadena de almas", "type": "passive", "magic": true, "bonus": [], "color": Color(0.7, 0.65, 1.0), 
		"desc": "El alma de un monstruo atado salta como un Esma gratis al más cercano y lo ata."}, 




	"dragon_tail": {"name": "Dragon Tail", "type": "passive", "bonus": [], "color": Color(1.0, 0.35, 0.2), 
		"desc": "Lo que marcan las habilidades de arma del Gunslinger estalla al lanzar la siguiente."}, 
	"status_combo": {"name": "Combo de estado", "type": "passive", "bonus": [], "color": Color(1.0, 0.75, 0.45), 
		"desc": "El daño extra del viento a lo congelado y del fuego a lo petrificado."}, 


	"forge_blast": {"name": "Blast Forge", "type": "passive", "bonus": [], "color": Color(1.0, 0.45, 0.2), 
		"desc": "Tu arma estalla al romperse en la forja."}, 


	"molten_metal": {"name": "Metal fundido", "type": "passive", "bonus": [], "color": Color(1.0, 0.5, 0.12), 
		"desc": "El metal fundido que deja tu forja al estallar: quema a los monstruos que lo pisan.", 
		"shape": "square", "arm": 1, "tick": 0.5, "element": "fire", "molten": true, 
		"fx": "firehit1", "fx_size": 0.4, "fx_intensity": 0.7}, 
	"skin_tempering": {"name": "Skin Tempering", "type": "passive", "desc": "Pasiva: piel curtida en la forja: más defensa y vida máxima.", 
		"bonus": ["armor", "max_hp_pct"], "armor": 1.0, "max_hp_pct": 0.03, "color": Color(0.9, 0.6, 0.45), 
		"per_level": {"armor": 0.6, "max_hp_pct": 0.035}}, 








	"acid_terror": {"name": "Acid Terror", "type": "acid_terror", "fx": "poisonzone", "fx_size": 0.55, 
		"desc": "Lanzas un frasco de ácido al monstruo más fuerte: estalla y el ácido lo corroe en varios golpes seguidos. Al final lo marca (recibe más daño de todo) y deja un charquito que corroe alrededor.", 
		"shape": "square", "cooldown": 3.2, "damage": 30.0, "hits": 3.0, "count": 1.0, "range": 8.0, "area": 1.3, 
		"duration": 2.0, "tick": 0.5, "puddle_dmg": 0.3, "acid": 0.15, "acid_time": 4.0, "hit_gap": 0.13, 
		"color": Color(0.6, 1.0, 0.4), "sound": "acid_terror", "sound_db": -6.0, 
		"per_level": {"damage": 4.0, "hits": 0.5, "count": 0.5, "area": 0.1, "acid": 0.03}}, 


	"chemical_protection": {"name": "Chemical Protection", "type": "buff", "fx": "cure", 
		"desc": "Recubres a tu grupo de protección química: más defensa y regeneración (también a tus aliados en co-op).", 
		"bonus": ["armor", "regen"], "armor": 2.0, "regen": 0.6, "cooldown": 6.0, "color": Color(0.7, 0.9, 1.0), "sound": "heal", "sound_db": -8.0, 
		"per_level": {"armor": 1.0, "regen": 0.3}}, 

	"bioethics": {"name": "Bioethics", "type": "passive", 
		"desc": "Pasiva: tus Homúnculos y tus plantas carnívoras pegan más fuerte.", 
		"bonus": ["homun_power"], "homun_power": 0.25, "color": Color(0.7, 1.0, 0.8), 
		"per_level": {"homun_power": 0.15}}, 

	"demonstration": {"element": "fire", "name": "Demonstration", "type": "ground", "cell_sprite": "fx_demonstration", 
		"desc": "Un frasco incendiario deja el suelo en llamas bajo los monstruos.", 
		"shape": "square", "cooldown": 5.5, "damage": 15.0, "count": 1.0, "range": 8.0, "area": 2.2, 
		"duration": 4.0, "tick": 0.5, "color": Color(1, 0.45, 0.15), "sound": "demonstration", 
		"per_level": {"damage": 5.0, "count": 0.25, "area": 0.2}}, 


	"bio_cannibalize": {"name": "Bio Cannibalize", "type": "summon", 
		"plants": ["mandragora", "hydra", "flora", "parasite", "geographer"], 
		"desc": "Siembras plantas carnívoras que disparan a los monstruos cercanos. Mejores plantas con cada nivel.", 
		"cooldown": 8.0, "damage": 20.0, "count": 1.0, "range": 4.0, "duration": 9.0, "tick": 1.0, 
		"color": Color(0.5, 0.85, 0.4), "sound": "bio_cannibalize", "tour_wait": 1.5, 
		"per_level": {"damage": 7.5, "count": 0.25, "duration": 1.0}}, 
	"potion_pitcher": {"name": "Potion Pitcher", "type": "heal", "fx": "빨간포션", 
		"desc": "Lanzas una poción a ti o al aliado más herido cada pocos segundos.", 
		"cooldown": 9.0, "amount": 22.0, "color": Color(1, 0.5, 0.5), "sound": "heal", "sound_db": -8.0, 
		"per_level": {"amount": 10.0, "cooldown": -0.5}}, 
	"acid_demonstration": {"element": "fire", "name": "Acid Demonstration", "type": "ground", "cell_sprite": "fx_demonstration", 
		"desc": "Ácido y fuego a la vez: dos zonas en llamas que queman y corroen, y los monstruos dentro reciben más daño de todo.", 
		"shape": "square", "cooldown": 4.0, "damage": 55.0, "count": 2.0, "range": 9.0, "area": 2.4, 
		"duration": 4.5, "tick": 0.5, "acid": 0.2, "color": Color(0.8, 1, 0.5), "sound": "acid_terror", 
		"per_level": {"damage": 16.0, "count": 0.25, "area": 0.12}}, 
	"axe_mastery": {"name": "Axe Mastery", "type": "passive", "desc": "Pasiva: dominas el hacha: más daño y velocidad del ataque básico.", 
		"bonus": ["basic_dmg", "aspd"], "basic_dmg": 0.06, "aspd": 0.02, "color": Color(0.85, 0.75, 0.6), 
		"per_level": {"basic_dmg": 0.06, "aspd": 0.015}}, 
	"learning_potion": {"name": "Potion Research", "type": "passive", "desc": "Pasiva: tus pociones curan más y regeneras vida.", 
		"bonus": ["heal_power", "regen"], "heal_power": 0.15, "regen": 0.3, "color": Color(1, 0.6, 0.6), 
		"per_level": {"heal_power": 0.1, "regen": 0.2}}, 



	"mammonite_x": {"name": "Mammonite EX", "type": "melee_arc", "evolved": true, "fx": "maemor", "zeny_cost": 8.0, 
		"bank_power": true, "coin_rain": true, 
		"desc": "Lluvia de monedas: un golpe enorme pagado con zeny que crece con el zeny que tienes guardado fuera de la partida (x1,5 con 100k, x2 con 1M, hasta x3).", 
		"cooldown": 0.8, "damage": 350.0, "range": 3.7, "arc": 165.0, "knock": 4.0, 
		"color": Color(1, 0.85, 0.35), "sound": "mammonite", "sound_extra": "coin2"}, 


	"cart_revolution_x": {"name": "Cart Revolution EX", "type": "aoe_self", "evolved": true, "fx": "cartrevolution", "fx_size": 1.4, 
		"speed_dmg": 0.25, 
		"desc": "El carro gira como un huracán y barre todo a tu alrededor; pega más cuanto más rápido te mueves.", 
		"cooldown": 1.4, "damage": 220.0, "range": 5.5, "knock": 12.0, 
		"color": Color(0.9, 0.75, 0.5), "sound": "cart_revolution"}, 
	"axe_tornado_x": {"name": "Axe Tornado EX", "type": "axe_tornado", "evolved": true, "fx": "mineffect/new_axetornado/new_axetornado/new_axetornado", "hits": 2.0, 
		"storm": 3.0, "storm_every": 0.3, 
		"desc": "El torbellino no se detiene: gira a tu alrededor 3 s y te sigue, golpeando sin parar. Con la forja al rojo es más grande y golpea el doble de rápido.", 
		"cooldown": 3.2, "damage": 55.0, "range": 3.0, "knock": 1.2, "forge_area": 0.03, 
		"color": Color(1.0, 0.75, 0.45), "sound": "axe_tornado"}, 
	"cart_cannon_x": {"name": "Cart Cannon EX", "type": "cart_cannon", "evolved": true, "burn": 2.5, 
		"desc": "Tres cañonazos a los tres monstruos más fuertes; cada explosión deja el suelo ardiendo.", 
		"cooldown": 2.0, "damage": 210.0, "range": 11.0, "area": 2.5, "count": 3.0, "knock": 4.0, "forge_area": 0.03, 
		"color": Color(1.0, 0.6, 0.3), "sound": "cart_cannon"}, 
	"sightrasher_x": {"burn_chance": 1.0, "element": "fire", "name": "Sightrasher EX", "magic": true, "type": "sightrasher", "evolved": true, "waves": 2.0, 
		"desc": "Dos anillos de fuego, uno tras otro y cada vez más lejos.", 
		"cooldown": 3.0, "damage": 109.2, "range": 4.2, "knock": 8.0, "color": Color(1.0, 0.5, 0.2), "sound": "sightrasher"}, 
	"gravitation_field_x": {"name": "Gravitation Field EX", "magic": true, "type": "gravity", "evolved": true, "fx": "hyper_novice/hn_ground_gravitation/ground_gravitation", "implode": 4.0, 
		"desc": "Un campo más grande y largo que al terminar implosiona sobre todo lo que atrapó.", 
		"cooldown": 7.0, "damage": 46.0, "range": 10.0, "area": 3.8, "duration": 4.5, "pull": 6.0, 
		"color": Color(0.6, 0.4, 0.9), "sound": "gravitation_field"}, 
	"kunai_explosion_x": {"name": "Kunai Explosion EX", "type": "kunai_boom", "evolved": true, "min_kunai": 3.0, "splash": 1.8, 
		"desc": "Cada kunai detonado estalla también sobre los monstruos de alrededor.", 
		"cooldown": 2.0, "damage": 50.0, "range": 11.0, "color": Color(1.0, 0.7, 0.4), "sound": "kunai_explosion"}, 
	"moonlight_fantasy_x": {"huuma_form": {"dmg": 2.0, "count": 0.5, "range": 1.3, "speed": 0.7, "px": 2.4}, "flair": {"ring": 3.0, "rays": 0.8}, "thrown": true, "name": "Moonlight Fantasy EX", "type": "orbit", "evolved": true, "sprite": "item_heat_wave_kunai", "raw_frames": true, "sprite_px": 1.0, "tint": Color(0.8, 0.85, 1.25), 
		"desc": "Seis kunai lunares giran a tu alrededor en un círculo más amplio. Con una Huuma equipada son Huumas grandes, más lentas y letales.", 
		"cooldown": 6.0, "damage": 45.0, "count": 6.0, "range": 2.5, "hit_every": 0.4, "orbit_speed": 4.5, "knock": 1.0, 
		"color": Color(0.85, 0.85, 1.0), "sound": "moonlight_fantasy"}, 
	"hammer_fall_x": {"status": "stun", "status_chance": 0.8, "status_time": 2.5, 
		"name": "Hammer Fall EX", "type": "aoe_self", "evolved": true, "fx": "black_hammerfall", "fx_size": 1.6, 
		"desc": "El suelo tiembla: daño y aturdimiento casi seguro en un área enorme. Llena muchísimo el Aguante de jefes y MVP; si tú lo rompes (Quiebre de forja), quedan aturdidos más tiempo y les pegas x5.", 
		"cooldown": 2.0, "damage": 150.0, "range": 5.5, "knock": 2.0, "stagger_fill": 20.0, 
		"color": Color(1, 0.8, 0.5), "sound": "hammer_fall"}, 



	"over_thrust_x": {"name": "Maximum Power-Thrust", "type": "buff", "evolved": true, "forge_vent": true, 
		"desc": "Fuerza descomunal: más daño de todo lo que haces. Con la forja caliente (3 niveles o más) la vacía de golpe: hasta x2 de todo tu daño durante 15 s según el calor que soltó, el arma se templa y mientras dure se rompe la mitad.", 
		"cooldown": 12.0, "bonus": ["dmg"], "dmg": 0.3, 
		"color": Color(1, 0.55, 0.3), "sound": "over_thrust"}, 
	"acid_terror_x": {"name": "Acid Terror EX", "type": "projectile", "evolved": true, "proj_sprite": "item_acid_bottle", "spin": 14.0, 
		"desc": "Cuatro frascos de ácido que rebotan entre los monstruos.", 
		"cooldown": 1.0, "damage": 260.0, "count": 4.0, "speed": 17.0, "pierce": 3.0, "range": 10.0, 
		"size": 0.45, "knock": 3.0, "sound": "acid_terror", "sound_db": -8.0, "color": Color(0.7, 1, 0.5), 

		"acid": 0.27, "acid_time": 4.0}, 

	"thunder_storm_x": {"fx_lead": 0.25, "element": "wind", "name": "Thunder Storm EX", "magic": true, "fx": "thunderstorm", "type": "aoe_target", "evolved": true, "desc": "Una tormenta eléctrica sobre más grupos de monstruos a la vez.", 
		"cooldown": 2.56, "damage": 152.9, "count": 6.0, "range": 11.0, "area": 3.25, 
		"color": Color(1, 1, 0.5), "sound": "thunder"}, 
	"frost_diver_x": {"element": "water", "status": "freeze", "status_chance": 0.9, "status_time": 3.0, 
		"name": "Frost Diver EX", "magic": true, "type": "ice_trail", "evolved": true, "desc": "Un sendero de hielo más largo que congela casi seguro.", 
		"cooldown": 1.44, "damage": 86.2, "count": 3.0, "range": 10.0, 
		"color": Color(0.6, 0.9, 1), "sound": "frost_diver", "hit_sound": "frost_hit"}, 
	"stone_curse_x": {"element": "earth", "status": "stone", "status_chance": 0.9, "status_time": 4.0, 
		"name": "Stone Curse EX", "magic": true, "type": "aoe_target", "evolved": true, "fx": "stonecurse", "desc": "Petrifica a más monstruos a la vez y durante más tiempo.", 
		"cooldown": 3.2, "damage": 32.0, "count": 5.0, "range": 9.0, "area": 1.12, 
		"color": Color(0.7, 0.7, 0.65), "sound": "stone_curse"}, 
	"lord_of_vermilion_x": {"fx_lead": 0.35, "element": "wind", "name": "Lord of Vermilion EX", "magic": true, "fx": "lord", "fx_intensity": 0.3, "type": "aoe_self", "evolved": true, "desc": "Rayos del cielo en un círculo enorme, una y otra vez.", 

		"cooldown": 4.16, "damage": 540.0, "range": 9.1, "knock": 2.0, 
		"color": Color(1, 0.95, 0.5), "sound": "thunder"}, 
	"jupitel_thunder_x": {"element": "wind", "name": "Jupitel Thunder EX", "magic": true, "type": "jupitel", "evolved": true, "desc": "Tres bolas de rayos a la vez, cada una golpea diez veces, empuja más lejos y aturde más.", 
		"cooldown": 1.28, "damage": 71.3, "hits": 10.0, "count": 3.0, "range": 11.0, "knock": 9.0, "stun_time": 1.5, 
		"color": Color(0.7, 0.8, 1), "sound": "jupitel", "sound_db": -2.0}, 
	"meteor_storm_x": {"fx_lead": 0.55, "burn_chance": 1.0, "element": "fire", "name": "Meteor Storm EX", "magic": true, "type": "aoe_target", "evolved": true, "fx": "meteor1", "fx_intensity": 0.55, "desc": "Una lluvia de meteoros sobre más zonas y con más área.", 

		"cooldown": 2.72, "damage": 742.0, "count": 6.0, "range": 11.0, "area": 3.25, 
		"color": Color(1, 0.5, 0.2), "sound": "meteor"}, 
	"earth_spike_x": {"impact": 1.5, "trail_tint": Color(0.75, 0.6, 0.42), "hitscan": true, "element": "earth", "name": "Earth Spike EX", "magic": true, "type": "projectile", "evolved": true, "hit_fx": "earthhit", 
		"desc": "Picos de tierra más fuertes que rebotan a varios monstruos.", 

		"cooldown": 0.67, "damage": 97.7, "count": 6.0, "speed": 18.0, "pierce": 2.0, "range": 13.0, "spread_bounce": true, 
		"size": 0.35, "same_target": true, "color": Color(0.7, 0.55, 0.35), "sound": "earth_spike", "sound_cd": 1.0}, 
	"volcano_x": {"element": "fire", "name": "Volcano EX", "magic": true, "type": "ground", "evolved": true, "fx": "fire", "on_self": true, 
		"desc": "Un campo de lava más grande que dura más.", 
		"shape": "square", "fx_size": 0.5, "cooldown": 5.6, "damage": 70.1, "area": 5.0, 
		"duration": 6.5, "tick": 0.6, "color": Color(1, 0.5, 0.2), "sound": "magnum"}, 
	"spider_web_x": {"name": "Spider Web EX", "type": "aoe_target", "evolved": true, "hit_sprite": "fx_wideweb", "web_fire": true, 
		"desc": "Telarañas sobre más monstruos que los inmovilizan más tiempo. Los atrapados reciben el doble de daño de Fuego, Agua, Tierra y Viento.", 
		"cooldown": 3.2, "damage": 136.8, "count": 5.6, "range": 10.0, "area": 3.1, "slow": 4.0, 
		"color": Color(0.9, 0.9, 0.95), "sound": "earth_spike"}, 
	"charge_arrow_x": {"over_dmg_step": 1.0, "archer_arrow": true, "hit_fx": "hit", "impact": 1.5, "trail_tint": Color(1.0, 0.85, 0.55), "uses_arrows": true, "name": "Charge Arrow EX", "hit_sound": "arrow_hit", "type": "projectile", "evolved": true, "desc": "Dos flechas cargadas que rebotan, lanzan lejos y aturden.", 
		"status": "stun", "status_chance": 0.4, "status_time": 1.5, 
		"cooldown": 1.1, "damage": 220.0, "count": 2.0, "speed": 18.0, "pierce": 10.0, "range": 12.0, 
		"size": 0.55, "knock": 12.0, "arrow": true, "streak": Color(1.0, 0.8, 0.55), "color": Color(1, 0.8, 0.4), "sound": "bow"}, 
	"land_mine_x": {"over_dmg_step": 0.75, "element": "earth", "status": "stun", "status_chance": 0.7, "status_time": 2.0, "name": "Land Mine EX", "fx": "landmine", "type": "aoe_target", "trap": "trap_magenta", "evolved": true, "desc": "Más minas, más grandes y más dañinas.", 
		"cooldown": 2.72, "damage": 760.0, "count": 5.0, "range": 9.0, "area": 3.63, 
		"color": Color(0.85, 0.6, 0.3), "sound": "landmine"}, 
	"ankle_snare_x": {"over_dmg_step": 0.75, "name": "Ankle Snare EX", "type": "aoe_target", "trap": "trap_snare", "trap_size": 1.7, "jaws": "trap_snare", "snare": 5.0, "bleed_stacks": 4, "catch": 6.0, "evolved": true, 
		"snare_boss": 0.4, "pull": 4.0, 
		"desc": "Trampas de osos que arrastran a los de alrededor hacia sus fauces, atrapan incluso a jefes y MVPs y los desangran.", 
		"cooldown": 3.2, "damage": 150.0, "count": 3.0, "range": 9.0, "area": 2.6, 
		"color": Color(0.75, 0.75, 0.8), "sound": "ankle_snare"}, 
	"sandman_x": {"over_dmg_step": 0.75, "status": "sleep", "status_chance": 0.9, "status_time": 4.0, 
		"name": "Sandman EX", "type": "aoe_target", "trap": "trap_blue", "evolved": true, "fx": "sandman", "desc": "Más trampas de arena somnífera: los grupos duermen casi seguro y reciben críticos devastadores.", 
		"cooldown": 4.0, "damage": 47.0, "count": 3.0, "range": 9.0, "area": 4.5, 
		"color": Color(0.95, 0.85, 0.6), "sound": "sandman"}, 
	"sharp_shooting_x": {"boss_dmg": 2.0, "archer_arrow": true, "uses_arrows": true, "name": "Sharp Shooting EX", "hit_sound": "arrow_hit", "type": "line", "evolved": true, "desc": "Dos ráfagas certeras, más anchas, que atraviesan en línea recta a todos los monstruos y los hacen sangrar; doble de daño a jefes y MVP. Tus trampas que cruza estallan al instante con el doble de daño.", 
		"cooldown": 1.12, "damage": 610.0, "count": 2.0, "width": 2.1, "range": 13.0, "bleed_chance": 0.7, "bleed_stacks": 3, 
		"knock": 3.0, "color": Color(0.85, 0.95, 0.9), "sound": "sharp_shooting"}, 
	"dissonance_x": {"name": "Dissonance EX", "type": "aoe_self", "evolved": true, "fx": "shockwave", "fx_size": 0.35, "fx_intensity": 0.45, "tex_fx": "melody_a", "tarot": true, 
		"desc": "Canción o danza: una melodía discordante más amplia y más dañina (+30% por cada otra que suene). En cada Bis echa una carta del Tarot del Destino: El Colgado congela, La Torre derrumba un gran golpe, La Templanza confunde, El Diablo maldice (+30% de daño recibido), El Sol os da +40% de daño y La Rueda de la Fortuna saca dos.", 
		"cooldown": 1.0, "damage": 200.0, "range": 6.2, "knock": 1.5, 
		"color": Color(0.85, 0.6, 1.0), "sound": "musical", "song": true}, 
	"service_for_you_x": {"name": "Service for You EX", "type": "buff", "evolved": true, "tex_fx": "melody_b", "tex_count": 3, 
		"desc": "Danza: a cada compás adelanta mucho más las recargas tuyas y de tu grupo, en un aura más amplia; el doble en el Bis.", 
		"cooldown": 12.0, "bonus": [], "relief": 0.2, "party_range": 9.0, "color": Color(1.0, 0.6, 0.85), "sound": "musical", "song": true, "dance": true}, 
	"scream_x": {"name": "Scream EX", "type": "aoe_self", "evolved": true, "fx": "shockwave", "fx_size": 0.35, "fx_intensity": 0.45, "desc": "Danza: un grito más amplio que aturde casi seguro a los monstruos de alrededor. En el Bis, un grito del doble.", 
		"cooldown": 1.9, "damage": 170.0, "range": 6.0, "knock": 1.2, "status": "stun", "status_chance": 0.85, "status_time": 1.6, 
		"color": Color(0.75, 0.9, 1.0), "sound": "scream", "song": true, "dance": true}, 


	"ens_eternal_chaos": {"name": "Eternal Chaos", "type": "buff", "ensemble": true, "bonus": [], 
		"desc": "Conjunto: los monstruos dentro del círculo pierden toda defensa (sin resistencias de elemento, nada falla) y reciben +40% de daño de todo el grupo. Los MVP llenan su Aguante el doble de rápido.", 
		"color": Color(0.8, 0.35, 1.0), "sound": "ens_chaos"}, 
	"ens_nibelungen": {"name": "Ring of Nibelungen", "type": "buff", "ensemble": true, "bonus": [], 
		"desc": "Conjunto: las habilidades del grupo dentro del círculo hacen +50% de daño.", 
		"color": Color(1.0, 0.8, 0.3), "sound": "ens_nibelungen"}, 
	"ens_drum": {"name": "Drum on the Battlefield", "type": "buff", "ensemble": true, "bonus": ["dmg", "armor"], "dmg": 0.25, "armor": 10.0, 
		"desc": "Conjunto: el grupo dentro del círculo hace +25% de daño y gana +10 de defensa. Cada monstruo que cae dentro lo alarga.", 
		"color": Color(1.0, 0.5, 0.3), "sound": "song_sunset"}, 
	"ens_siegfried": {"name": "Invulnerable Siegfried", "type": "buff", "ensemble": true, "bonus": [], 
		"desc": "Conjunto: el grupo dentro del círculo recibe la mitad de daño de las mecánicas de los MVP, y cada héroe se salva una vez de caer mientras suena.", 
		"color": Color(0.55, 0.85, 1.0), "sound": "song_bragi"}, 

	"tarot_card": {"name": "El Sol", "type": "buff", "ensemble": true, "bonus": ["dmg"], "dmg": 0.4, 
		"desc": "Tarot del Destino: +40% de daño unos segundos.", "color": Color(1.0, 0.88, 0.4)}, 
	"arrow_vulcan_x": {"impact": 0.7, "trail_tint": Color(1.0, 0.85, 0.55), "uses_arrows": true, "name": "Arrow Vulcan EX", "type": "projectile", "evolved": true, "same_target": true, 
		"desc": "Diez flechas en crescendo más rápido: cada una pega más que la anterior y el fortissimo final estalla más fuerte y más ancho. Con Bragi o Assassin Cross of Sunset sonando: ×1,4 de daño y una flecha más por canción (×1,8 con las dos).", 
		"crescendo": 0.1, "finale": 2.0, "finale_area": 3.2, 
		"cooldown": 1.44, "damage": 158.0, "count": 10.0, "speed": 24.0, "pierce": 3.0, "range": 11.0, 
		"size": 0.22, "arrow": true, "streak": Color(1.0, 0.7, 0.75), "color": Color(0.95, 0.9, 0.75), "sound": "arrow_vulcan", "hit_sound": "arrow_hit"}, 
	"triple_action_x": {"hitscan": true, "hit_sprite": "fx_triple", "uses_arrows": true, "name": "Triple Action EX", "type": "projectile", "evolved": true, "desc": "Cuatro disparos rápidos que rebotan.", 
		"cooldown": 0.46, "damage": 56.0, "count": 6.0, "speed": 28.0, "pierce": 2.0, "range": 10.5, 
		"size": 0.12, "same_target": true, "color": Color(1, 0.9, 0.55), "sound": "triple_action", "sound_cd": 0.25, "sound_db": -8.0}, 
	"spread_attack_x": {"uses_arrows": true, "spr_fx": "fx_spread", "spr_dir": true, "hit_sprite": "fx_triple", "name": "Spread Attack EX", "type": "aoe_target", "evolved": true, "desc": "Disparos en abanico sobre más zonas a la vez.", 
		"cooldown": 2.24, "damage": 112.0, "count": 5.0, "range": 9.0, "area": 4.12, 
		"color": Color(1, 0.8, 0.45), "sound": "gun_shotgun"}, 
	"banishing_buster_x": {"hitscan": true, "uses_arrows": true, "name": "Banishing Buster EX", "type": "projectile", "evolved": true, "hit_fx": "rl_banishing_buster/vanishing1", 
		"pierce_line": true, "knock": 3.0, "line_width": 1.6, 
		"desc": "Dos balas que atraviesan a la horda en línea recta y la barren hacia atrás.", 
		"cooldown": 1.62, "damage": 414.0, "count": 2.0, "speed": 30.0, "pierce": 32.0, "range": 13.0, 
		"size": 0.3, "color": Color(0.8, 0.9, 1), "sound": "banishing_buster"}, 
	"slug_shot_x": {"hitscan": true, "uses_arrows": true, "name": "Slug Shot EX", "type": "projectile", "evolved": true, "hit_fx": "rl_slugshot/slug", 
		"desc": "Balas pesadas que empujan y rebotan.", 
		"cooldown": 1.6, "damage": 349.0, "count": 2.0, "speed": 24.0, "pierce": 7.0, "range": 11.0, 
		"size": 0.28, "knock": 10.0, "color": Color(1, 0.85, 0.6), "sound": "slug_shot"}, 
	"hammer_of_god_x": {"fx_lead": 0.55, "status": "stun", "status_chance": 0.7, "status_time": 2.0, 
		"name": "Hammer of God EX", "type": "aoe_target", "evolved": true, "fx": "rl_hamer_god/hogg", "desc": "Un rayo divino más grande que cae más seguido.", 
		"cooldown": 4.0, "damage": 612.0, "count": 2.0, "range": 11.0, "area": 5.5, 
		"color": Color(1, 0.95, 0.7), "sound": "hammer_of_god"}, 
	"brandish_spear_x": {"bleed_chance": 0.6, "name": "Brandish Spear EX", "lance": true, "fx": "brandish", "type": "melee_arc", "evolved": true, "desc": "Un barrido de lanza enorme frente a ti.", 
		"cooldown": 1.54, "damage": 250.0, "range": 8.0, "arc": 80.0, "knock": 7.0, 
		"color": Color(0.85, 0.9, 1), "sound": "brandish"}, 
	"spiral_pierce_x": {"bleed_chance": 1.0, "name": "Spiral Pierce EX", "lance": true, "type": "drill", "evolved": true, 
		"desc": "Ocho taladros seguidos sobre el enemigo más fuerte, y el último atraviesa a todos los que están detrás.", 
		"cooldown": 1.4, "damage": 202.0, "hits": 8.0, "range": 8.0, "boss_mult": 1.6, "knock": 8.0, "pierce_line": 7.0, 
		"color": Color(1, 0.95, 0.8), "sound": "spiral_drill"}, 
	"charge_attack_x": {"name": "Charge Attack EX", "lance": true, "type": "charge", "evolved": true, 
		"desc": "Tu carga no se detiene: arrolla a su objetivo y vuelve a cargar contra otros dos enemigos fuertes.", 
		"cooldown": 2.0, "damage": 512.0, "range": 11.0, "width": 1.5, "knock": 12.0, "path_share": 0.5, "chain": 2.0, 
		"color": Color(1, 0.9, 0.6), "sound": "charge_attack"}, 
	"spear_boomerang_x": {"name": "Spear Boomerang EX", "lance": true, "type": "boomerang", "evolved": true, 
		"desc": "Tres lanzas en abanico que atraviesan a todos y vuelven a tu mano. Contra un jefe, MVP, élite o un monstruo solo, las tres van a él.", 
		"cooldown": 1.1, "damage": 216.0, "range": 11.0, "width": 1.2, "count": 3.0, "knock": 3.0, 
		"color": Color(0.85, 0.9, 1.0), "sound": "spear_boomerang"}, 
	"holy_cross_x": {"element": "holy", "status": "stun", "status_chance": 0.36, "status_time": 1.2, 
		"name": "Holy Cross EX", "type": "melee_arc", "evolved": true, "tank_hp": 0.0255, "tank_def": 9.0, "fx": "holy_cross", "desc": "Cruces sagradas más amplias que ciegan a los no-muertos. Su daño escala con tu vida y defensa.", 
		"cooldown": 0.82, "damage": 284.0, "range": 5.2, "arc": 70.0, "knock": 4.0, "wave_range": 9.5, 
		"color": Color(1, 1, 0.8), "sound": "holy_cross"}, 
	"shield_boomerang_x": {"name": "Shield Boomerang EX", "type": "projectile", "evolved": true, "boomerang": true, "spin": 22.0, "shield_scale": 0.1, 
		"desc": "Dos escudos girando que atraviesan filas a la ida y a la vuelta.", 
		"cooldown": 0.85, "damage": 300.0, "count": 2.0, "speed": 15.0, "pierce": 9.0, "range": 10.0, 
		"size": 0.45, "knock": 6.0, "color": Color(0.8, 0.85, 0.95), "sound": "shield_boomerang", "proj_sprite": "item_guard", "tour_wait": 0.08}, 
	"pressure_x": {"element": "holy", "status": "stun", "status_chance": 0.55, "status_time": 2.0, 
		"name": "Pressure EX", "type": "aoe_target", "evolved": true, "fx": "cross", "fx_intensity": 0.8, "desc": "Juicio divino sobre más monstruos a la vez.", 
		"cooldown": 3.6, "damage": 652.0, "count": 2.0, "range": 11.0, "area": 4.75, 
		"color": Color(1, 0.95, 0.75), "sound": "pressure"}, 
	"venom_dust_x": {"element": "poison", "name": "Venom Dust EX", "type": "aoe_target", "evolved": true, "fx": "venomdust", "desc": "Nubes de veneno más grandes y duraderas sobre más grupos: el veneno se sigue acumulando mientras estén dentro.", 
		"cooldown": 2.8, "damage": 92.0, "count": 5.0, "range": 9.0, "area": 3.75, "poison": 6.5, 
		"cloud": 6.0, "cloud_dmg": 0.22, "tick": 0.5, "shape": "square", "fx_center": true, "fx_size": 1.1, "fx_intensity": 0.7, "bubbles": true, 
		"color": Color(0.42, 0.72, 0.22), "sound": "venom_dust"}, 
	"raid_x": {"status": "stun", "status_chance": 0.61, "status_time": 1.5, "blind_chance": 0.7, "blind_time": 4.0, "blind_boss": true, 
		"name": "Raid EX", "type": "aoe_self", "evolved": true, "fx": "hit", 
		"desc": "Un asalto más amplio que aturde y ciega a más monstruos; ciega incluso a jefes y MVP.", 
		"cooldown": 1.92, "damage": 182.0, "range": 4.8, "knock": 5.0, 
		"color": Color(0.7, 0.6, 0.9), "sound": "sonic_blow"}, 



	"signum_crucis_x": {"element": "holy", "name": "Signum Crucis EX", "type": "signum", "evolved": true, 
		"desc": "Una señal de la cruz enorme: los monstruos reciben mucho más daño, y alcanza a los MVP y jefes aunque estén lejos, debilitándolos aún más.", 
		"cooldown": 5.0, "range": 7.5, "frail": 0.4, "duration": 6.0, "boss_reach": 16.0, "boss_frail": 1.5, 
		"color": Color(1, 0.95, 0.6), "sound": "signum_crucis"}, 
	"ruwach_x": {"element": "holy", "name": "Ruwach EX", "magic": true, "type": "orbit", "evolved": true, "sprite": "fx_sight", 
		"desc": "Más llamas sagradas giran a tu alrededor, más rápidas.", 
		"cooldown": 1.44, "damage": 90.0, "range": 3.6, "knock": 3.0, "count": 3.0, "hit_every": 0.6, 
		"orbit_speed": 3.2, "color": Color(0.6, 0.8, 1), "sound": "ruwach"}, 
	"sanctuary_x": {"element": "holy", "name": "Sanctuary EX", "magic": true, "type": "ground", "fx_center": true, "evolved": true, "fx": "sanctuary", "on_self": true, 
		"desc": "Un santuario más grande que cura y quema más tiempo.", 
		"shape": "square", "fx_size": 0.5, "cooldown": 5.6, "damage": 53.0, "area": 4.75, "heal_amount": 7.8, 
		"duration": 6.5, "tick": 0.7, "color": Color(0.7, 1, 0.8), "sound": "sanctuary"}, 
	"asura_strike_x": {"name": "Asura Strike EX", "type": "asura", "evolved": true, 
		"desc": "Asura Strike definitivo: más daño, más alcance y menos recarga, y pega más cuanta más vida máxima tengas (×2,1 con 700, ×3,7 con 2500, ×10 con 15000, ×18,5 con 40000, ×98 con 500000).", 
		"cooldown": 9.28, "damage": 2160.0, "range": 7.7, "knock": 14.0, 
		"color": Color(0.75, 0.85, 1.0), "sound": "asura"}, 
	"finger_offensive_x": {"name": "Finger Offensive EX", "type": "finger", "evolved": true, "desc": "Ráfaga de esferas espirituales que rebotan entre los monstruos.", 
		"cooldown": 1.09, "damage": 137.0, "speed": 26.0, "pierce": 3.0, "range": 10.0, 
		"size": 0.22, "color": Color(1, 1, 1), "sound": "finger_offensive", "hit_sound": "hit_fist", 
		"proj_tex": "spirit_ball", "proj_frames": 1, "proj_blend": "mix", "proj_scale": 1.0, "shot_gap": 0.12, "tour_wait": 0.12}, 
	"chain_crush_x": {"name": "Chain Crush Combo EX", "type": "melee_arc", "evolved": true, "fx": "bowling", "combo_only": true, 
		"desc": "Cuarto golpe del combo, aún más devastador a tu alrededor.", 
		"cooldown": 1.12, "damage": 590.0, "range": 5.4, "arc": 360.0, "knock": 8.0, 
		"color": Color(1, 0.9, 0.6), "sound": "chain_combo"}, 
	"cart_termination_x": {"status": "stun", "status_chance": 0.3, "status_time": 1.5, 
		"name": "Cart Termination EX", "type": "melee_arc", "evolved": true, "fx": "cartrevolution", "fx_size": 1.3, "zeny_cost": 14.0, "zeny_power": true, 
		"desc": "El carro arrasa con toda la fuerza del zeny ganado.", 
		"cooldown": 1.44, "damage": 738.0, "range": 4.4, "arc": 90.0, "knock": 9.0, 
		"color": Color(1, 0.85, 0.5), "sound": "mammonite", "sound_extra": "coin2"}, 
	"demonstration_x": {"element": "fire", "name": "Demonstration EX", "type": "ground", "evolved": true, "cell_sprite": "fx_demonstration", 
		"desc": "Fuego de botellas en una zona más grande que arde más.", 
		"shape": "square", "cooldown": 4.4, "damage": 50.0, "count": 3.0, "range": 9.0, "area": 3.75, 
		"duration": 5.2, "tick": 0.5, "color": Color(1, 0.45, 0.15), "sound": "demonstration"}, 
	"bio_cannibalize_x": {"name": "Bio Cannibalize EX", "type": "summon", "evolved": true, 
		"plants": ["mandragora", "hydra", "flora", "parasite", "geographer"], 
		"desc": "Más plantas, más fuertes y que viven más.", 
		"cooldown": 6.4, "damage": 72.0, "count": 3.0, "range": 5.0, "duration": 16.9, "tick": 1.0, 
		"color": Color(0.5, 0.85, 0.4), "sound": "bio_cannibalize", "tour_wait": 1.5}, 


	"acid_demonstration_x": {"element": "fire", "name": "Acid Demonstration EX", "type": "ground", "evolved": true, "cell_sprite": "fx_demonstration", 
		"desc": "Ácido y fuego en zonas más grandes, y el ácido se acumula: el monstruo dentro recibe ×1,20 de daño de todo y cada golpe de la zona le suma un 4%, hasta ×1,40 (×1,60 jefes y MVP).", 
		"shape": "square", "cooldown": 3.2, "damage": 150.0, "count": 4.0, "range": 10.0, "area": 3.2, 
		"duration": 5.0, "tick": 0.5, "acid": 0.2, "acid_stack": 0.04, "color": Color(0.8, 1, 0.5), "sound": "acid_terror"}, 
}



const OVERLEVEL_STEP: = 0.1



const BOLT_EX_STEP: = 0.3


const OVERLEVEL_FULL: = 5
const OVERLEVEL_HALF: = 145
const OVERLEVEL_FIELDS: = ["damage", "amount", "heal_amount", "frail", "crit", "crit_dmg", "proc_power", "aspd", "dmg", "hp_dmg", "duration", "mult"]


const OVERLEVEL_NEVER: = ["spheres", "coins", "count", "pierce", "guard", "status_chance", "kaizel"]

const OVERLEVEL_SHRINK: = ["kaizel"]

const OVERLEVEL_WEIGHT: = 0.7
const MAX_SKILL_LEVEL: = 5


const STATUS_MAX_TIME: = 4.0


const SLEEP_HITS: = 3
const SLEEP_CRIT_DMG: = 0.6



const TRAP_LIFE: = 20.0
const TRAP_TRIGGER: = 0.9
const TRAP_MAX: = 14


const TRAPPED_TIME: = 4.0



const HUNTER_MARK_TIME: = 4.0
const HUNTER_MARK_DMG: = 0.4








const PREY_MAX: = 10
const PREY_TIME: = 6.0
const PREY_DMG: = 0.12

const PREY_WORD_GAP: = 4.0
const DETONATOR_RADIUS: = 4.0
const DETONATOR_MULT: = 2.0


static func sniper_falconer(p: Player) -> bool:
	return p != null and str(p.job2.get("id", "")) == "sniper" and p.skills.has("steel_crow")


static func sniper_trapper(p: Player) -> bool:
	return p != null and str(p.job2.get("id", "")) == "sniper" and p.skills.has("beast_bane")
const TRAP_LEVEL_SHARE: = 1.0


















const TOWER_CARRY_COLLECT: = ["xp", "loot", "ore", "card", "tame"]


const DROP_BEAMS_MAX: = 8



const TRAP_DMG_MULT: = 1.8

const BRANCH_XP_EVERY: = 120.0


const BRANCH_BOSS_NEAR: = 9.0
const BRANCH_BOSS_FAR: = 11.0
const BRANCH_BOSS_WARN: = 1.2
const STATUS_RESIST_TIME: = 3.0





const CC_DR: = [1.0, 0.5, 0.25, 0.0]
const CC_DR_RESET: = 18.0



const CC_DR_RESET_SNARE: = 8.0
const STATUS_SHATTER: = 1.3

const SIGNUM_UNDEAD: = 2.0

const START_EXCLUDED_TYPES: = ["passive", "shield", "heal", "buff", "steal"]




const EVOLUTIONS: = {

	"tornado_kick": {"to": "tornado_kick_x", "passive": "kihop"}, 

	"picky_peck": {"to": "picky_peck_x", "passive": "power_of_life"}, 
	"scar_of_tarou": {"to": "scar_of_tarou_x", "passive": "power_of_life"}, 
	"arclouse_dash": {"to": "arclouse_dash_x", "passive": "spirit_of_life"}, 
	"lunatic_carrot_beat": {"to": "lunatic_carrot_beat_x", "passive": "spirit_of_life"}, 
	"silvervine_stem_spear": {"to": "silvervine_stem_spear_x", "passive": "power_of_land"}, 
	"silvervine_root_twist": {"to": "silvervine_root_twist_x", "passive": "spirit_of_land"}, 
	"bunch_of_shrimp": {"to": "bunch_of_shrimp_x", "passive": "spirit_of_sea"}, 
	"catnip_meteor": {"to": "catnip_meteor_x", "passive": "power_of_land"}, 
	"tuna_belly": {"to": "tuna_belly_x", "passive": "power_of_sea"}, 
	"flying_kick": {"to": "flying_kick_x", "passive": "sprint"}, 
	"warmth_sun": {"to": "warmth_sun_x", "passive": "hatred_stars"}, 
	"esma": {"to": "esma_x", "passive": "kaahi"}, 

	"bash": {"to": "bash_x", "passive": "sword_mastery"}, 
	"magnum_break": {"to": "magnum_break_x", "passive": "shield_mastery"}, 
	"endure": {"to": "endure_x", "passive": "shield_mastery"}, 
	"energy_coat": {"to": "energy_coat_x", "passive": "sp_recovery"}, 
	"assumptio": {"to": "assumptio_x", "passive": "mace_mastery"}, 
	"kaite": {"to": "kaite_x", "passive": "kaahi"}, 
	"tuna_party": {"to": "tuna_party_x", "passive": "spirit_of_sea"}, 
	"reject_sword": {"to": "reject_sword_x", "passive": "snatcher"}, 
	"fire_bolt": {"to": "fire_bolt_x", "passive": "sp_recovery"}, 
	"cold_bolt": {"to": "cold_bolt_x", "passive": "sp_recovery"}, 
	"soul_strike": {"to": "soul_strike_x", "passive": "sp_recovery"}, 
	"sightrasher": {"to": "sightrasher_x", "passive": "sp_recovery"}, 
	"frost_diver": {"to": "frost_diver_x", "passive": "sp_recovery"}, 
	"fire_wall": {"to": "fire_wall_x", "passive": "sp_recovery"}, 
	"double_strafe": {"to": "double_strafe_x", "passive": "vultures_eye"}, 
	"arrow_shower": {"to": "arrow_shower_x", "passive": "owls_eye"}, 
	"tracking": {"to": "tracking_x", "passive": "snake_eye"}, 
	"desperado": {"to": "desperado_x", "passive": "chain_action"}, 
	"envenom": {"to": "envenom_x", "passive": "double_attack"}, 
	"throw_stone": {"to": "throw_stone_x", "passive": "improve_dodge"}, 
	"holy_light": {"to": "holy_light_x", "passive": "divine_judgment"}, 
	"signum_crucis": {"to": "signum_crucis_x", "passive": "divine_judgment"}, 

	"bowling_bash": {"to": "bowling_bash_x", "passive": "cavalier_mastery"}, 
	"ignition_break": {"to": "ignition_break_x", "passive": "aura_blade"}, 
	"grand_cross": {"to": "grand_cross_x", "passive": "faith"}, 
	"provoke": {"to": "provoke_x", "passive": "shield_mastery"}, 
	"gospel": {"to": "gospel_x", "passive": "faith"}, 
	"martyrs_reckoning": {"to": "martyrs_reckoning_x", "passive": "reflect_shield"}, 
	"shield_chain": {"to": "shield_chain_x", "passive": "auto_guard"}, 
	"storm_gust": {"to": "storm_gust_x", "passive": "soul_drain"}, 
	"quagmire": {"to": "quagmire_x", "passive": "soul_drain"}, 
	"heavens_drive": {"to": "heavens_drive_x", "passive": "advanced_book"}, 
	"falcon_assault": {"to": "falcon_assault_x", "passive": "steel_crow"}, 
	"musical_strike": {"to": "musical_strike_x", "passive": "music_lessons"}, 
	"fire_rain": {"to": "fire_rain_x", "passive": "single_action"}, 
	"slug_shot": {"to": "slug_shot_x", "passive": "single_action"}, 
	"sonic_blow": {"to": "sonic_blow_x", "passive": "katar_mastery"}, 
	"meteor_assault": {"to": "meteor_assault_x", "passive": "left_hand_mastery"}, 


	"back_stab": {"to": "back_stab_x", "passive": "intimidate"}, 
	"soul_breaker": {"to": "soul_breaker_x", "passive": "right_hand_mastery"}, 
	"full_strip": {"to": "full_strip_x", "passive": "gangster_paradise"}, 
	"magnus_exorcismus": {"to": "magnus_exorcismus_x", "passive": "mace_mastery"}, 
	"investigate": {"to": "investigate_x", "passive": "iron_hand"}, 

	"mammonite": {"to": "mammonite_x", "passive": "discount"}, 
	"cart_revolution": {"to": "cart_revolution_x", "passive": "pushcart"}, 
	"hammer_fall": {"to": "hammer_fall_x", "passive": "weaponry_research"}, 
	"over_thrust": {"to": "over_thrust_x", "passive": "skin_tempering"}, 
	"gravitation_field": {"to": "gravitation_field_x", "passive": "mystical_amplification"}, 
	"kunai_explosion": {"to": "kunai_explosion_x", "passive": "shuriken_training"}, 
	"moonlight_fantasy": {"to": "moonlight_fantasy_x", "passive": "cicada_skin_shed"}, 
	"axe_tornado": {"to": "axe_tornado_x", "passive": "weapon_perfection"}, 
	"cart_cannon": {"to": "cart_cannon_x", "passive": "pushcart"}, 
	"acid_terror": {"to": "acid_terror_x", "passive": "learning_potion"}, 

	"thunder_storm": {"to": "thunder_storm_x", "passive": "sp_recovery"}, 
	"stone_curse": {"to": "stone_curse_x", "passive": "sp_recovery"}, 
	"lord_of_vermilion": {"to": "lord_of_vermilion_x", "passive": "soul_drain"}, 
	"jupitel_thunder": {"to": "jupitel_thunder_x", "passive": "soul_drain"}, 
	"meteor_storm": {"to": "meteor_storm_x", "passive": "soul_drain"}, 
	"earth_spike": {"to": "earth_spike_x", "passive": "advanced_book"}, 
	"volcano": {"to": "volcano_x", "passive": "advanced_book"}, 
	"spider_web": {"to": "spider_web_x", "passive": "advanced_book"}, 
	"charge_arrow": {"to": "charge_arrow_x", "passive": "owls_eye"}, 
	"blitz_beat": {"to": "blitz_beat_x", "passive": "steel_crow"}, 
	"land_mine": {"to": "land_mine_x", "passive": "beast_bane"}, 
	"sandman": {"to": "sandman_x", "passive": "beast_bane"}, 
	"ankle_snare": {"to": "ankle_snare_x", "passive": "beast_bane"}, 
	"sharp_shooting": {"to": "sharp_shooting_x", "passive": "vultures_eye"}, 
	"dissonance": {"to": "dissonance_x", "passive": "music_lessons"}, 
	"service_for_you": {"to": "service_for_you_x", "passive": "music_lessons"}, 
	"scream": {"to": "scream_x", "passive": "music_lessons"}, 
	"arrow_vulcan": {"to": "arrow_vulcan_x", "passive": "music_lessons"}, 
	"triple_action": {"to": "triple_action_x", "passive": "single_action"}, 
	"spread_attack": {"to": "spread_attack_x", "passive": "chain_action"}, 
	"banishing_buster": {"to": "banishing_buster_x", "passive": "snake_eye"}, 
	"hammer_of_god": {"to": "hammer_of_god_x", "passive": "snake_eye"}, 
	"brandish_spear": {"to": "brandish_spear_x", "passive": "peco_riding"}, 
	"spiral_pierce": {"to": "spiral_pierce_x", "passive": "auto_counter"}, 
	"charge_attack": {"to": "charge_attack_x", "passive": "peco_riding"}, 
	"spear_boomerang": {"to": "spear_boomerang_x", "passive": "cavalier_mastery"}, 
	"holy_cross": {"to": "holy_cross_x", "passive": "auto_guard"}, 
	"shield_boomerang": {"to": "shield_boomerang_x", "passive": "auto_guard"}, 
	"pressure": {"to": "pressure_x", "passive": "faith"}, 
	"venom_dust": {"to": "venom_dust_x", "passive": "improve_dodge"}, 
	"raid": {"to": "raid_x", "passive": "improve_dodge"}, 
	"ruwach": {"to": "ruwach_x", "passive": "divine_judgment"}, 
	"sanctuary": {"to": "sanctuary_x", "passive": "divine_judgment"}, 
	"asura_strike": {"to": "asura_strike_x", "passive": "call_spirits"}, 
	"chain_crush": {"to": "chain_crush_x", "passive": "triple_attack"}, 
	"cart_termination": {"to": "cart_termination_x", "passive": "discount"}, 
	"demonstration": {"to": "demonstration_x", "passive": "axe_mastery"}, 
	"bio_cannibalize": {"to": "bio_cannibalize_x", "passive": "axe_mastery"}, 
	"acid_demonstration": {"to": "acid_demonstration_x", "passive": "learning_potion"}, 
	"call_homunculus": {"to": "call_homunculus_x", "passive": "bioethics"}, 

	"throw_shuriken": {"to": "throw_shuriken_x", "passive": "shuriken_training"}, 
	"throw_kunai": {"to": "throw_kunai_x", "passive": "shuriken_training"}, 
	"throw_huuma": {"to": "throw_huuma_x", "passive": "shuriken_training"}, 
	"throw_zeny": {"to": "throw_zeny_x", "passive": "ninja_mastery"}, 
	"flaming_petals": {"to": "flaming_petals_x", "passive": "ninja_mastery"}, 
	"freezing_spear": {"to": "freezing_spear_x", "passive": "ninja_mastery"}, 
	"lightning_crash": {"to": "lightning_crash_x", "passive": "ninja_mastery"}, 
	"shadow_slash": {"to": "shadow_slash_x", "passive": "cicada_skin_shed"}, 
	"cross_slash": {"to": "cross_slash_x", "passive": "right_hand_mastery"}, 
	"kunai_splash": {"to": "kunai_splash_x", "passive": "shuriken_training"}, 
	"ninja_aura": {"to": "ninja_aura_x", "passive": "ninja_mastery"}, 
	"mirror_image": {"to": "mirror_image_x", "passive": "cicada_skin_shed"}, 
	"huuma_storm": {"to": "huuma_storm_x", "passive": "shuriken_training"}, 
	"exploding_dragon": {"to": "exploding_dragon_x", "passive": "ninja_mastery"}, 
	"killing_strike": {"to": "killing_strike_x", "passive": "cicada_skin_shed"}, 
}










const MIN_ATTACK_DELAY: = 0.08



const MAX_SWING_HITS: = 2





const SWING_SOFT_FROM: = 20.0
const SWING_SOFT_POW: = 0.7

const PROC_POWER_CASTS_MAX: = 12


const BASIC_STR_ATK: = 0.72
const RO_STAT_PER_PICK: = 6

const JOB_ASPD_BONUS: = {"job2": 4.0, "trans": 7.0}
const MAX_SKILLS: = 5

const MAX_PASSIVES: = 2
const JOB_EXTRA_PASSIVES: = 1


const EARLY_PASSIVE_LEVEL: = 6

const ADJUST_MAX: = 0.5





const REBIRTH_FRAGMENTS: = 4
const REBIRTH_CLASS_LEVEL: = CLASS_MAX_LEVEL
const REBIRTH_CLASS_MAX_LEVEL: = 50
const REBIRTH_CARD: = "randgris_card"
const REBIRTH_STAT_BONUS: = 2

const TRANS_EXTRA_SKILLS: = 0
const TRANS_EXTRA_PASSIVES: = 1


const JOB_ICON_IDS: = {"Novice": 0, "Swordsman": 1, "Mage": 2, "Archer": 3, "Acolyte": 4, "Merchant": 5, "Thief": 6, 
	"Knight": 7, "Priest": 8, "Wizard": 9, "Blacksmith": 10, "Hunter": 11, "Assassin": 12, "Crusader": 14, "Monk": 15, 
	"Sage": 16, "Rogue": 17, "Alchemist": 18, "Bard": 19, "Dancer": 20, "Super Novice": 23, "Gunslinger": 24, "Ninja": 25, 
	"High Swordsman": 4002, "High Mage": 4003, "High Archer": 4004, "High Acolyte": 4005, "High Merchant": 4006, 
	"High Thief": 4007, "Lord Knight": 4008, "High Priest": 4009, "High Wizard": 4010, "Whitesmith": 4011, "Sniper": 4012, 
	"Assassin Cross": 4013, "Paladin": 4015, "Champion": 4016, "Professor": 4017, "Stalker": 4018, "Creator": 4019, 
	"Clown": 4020, "Gypsy": 4021, "Taekwon Kid": 4046, "Taekwon Girl": 4046, "Star Gladiator": 4047, "Soul Linker": 4049, 
	"Kagerou": 4211, "Oboro": 4212, "Rebellion": 4215, "Summoner": 4218, "Spirit Handler": 4218}
const HIGH_NAMES: = {"swordsman": "High Swordsman", "mage": "High Mage", "archer": "High Archer", 
	"thief": "High Thief", "acolyte": "High Acolyte", "merchant": "High Merchant"}


const JOB_CHANGE_LEVEL: = 20

const JOB_EXTRA_SKILLS: = 1
const MAX_STAT: = 10






const STR_DMG: = 0.07


const INT_SKILL_DMG: = 0.15









const SKILL_DMG_MULT: = 0.5
const SKILL_DMG_FULL: = 1.0
static func skill_dmg_amp(sd: float) -> float:
	if sd <= 0.0:
		return maxf(0.1, 1.0 + sd)
	return 1.0 + minf(sd, SKILL_DMG_FULL) + maxf(0.0, sd - SKILL_DMG_FULL) * SKILL_DMG_MULT

const INT_AREA: = 0.06


const INT_DOUBLE: = 0.004
const INT_DOUBLE_MAX: = 0.25





const MULTI_CAST_TRIPLE_AT: = 1.0
const MULTI_CAST_MAX: = 3


const MULTI_CAST_MAX_PROF: = 4

const SAGE_DOUBLE_COPIED: = 0.5







const PROC_ZONE_STACK: = 2





const DOT_SWING_POW: = 0.75
const INT_DOUBLE_DELAY: = 0.2

const INTIMIDATE_TIME: = 4.0
const DEX_HASTE: = 0.035




const HASTE_SOFT: = 4.0


func soft_haste(h: float) -> float:
	return h / (1.0 + maxf(0.0, h) / HASTE_SOFT)


const AGI_SKILL_HASTE: = 0.02



const HP_STAT_POW: = 0.43
const HP_STAT_DIV: = 2.6






const ASP_RADIUS: = 2.4
const ASP_BOUNCE_RANGE: = 7.0
const ASP_BOUNCE_RADIUS: = 1.4
const ASP_BOUNCE_DMG: = 0.7
const ASP_BOUNCE_DELAY: = 0.09
const ASP_PER_S: = 6.0
const ASP_TOKENS_MAX: = 10.0

const ASP_COLOR: = Color(1.0, 0.72, 0.22)


const LEX_BASIC_EVERY: = 4


const JUDGMENT_PER: = 0.03
const JUDGMENT_RATE: = 2.0
const JUDGMENT_FADE: = 6.0
const JUDGMENT_COLOR: = Color(1.0, 0.82, 0.3)



const SKILL_SCALE: = {







	"grand_cross": {"str": 0.5, "hp": 1.0}, "holy_cross": {"str": 0.5, "hp": 1.0}, 
	"gospel": {"str": 0.5, "hp": 1.0}, "provoke": {"str": 0.5, "hp": 1.0}, "shield_chain": {"str": 0.5, "hp": 1.0}, 

	"soul_link": {"int": 1.0}, 
	"asura_strike": {"str": 0.5, "int": 0.5}, "cart_cannon": {"str": 0.5, "int": 0.5}, 
	"falcon_assault": {"str": 0.5, "int": 0.5}, "blitz_beat": {"str": 0.5, "int": 0.5}, 
	"land_mine": {"str": 0.5, "int": 0.5}, "ankle_snare": {"str": 0.5, "int": 0.5}, "sandman": {"str": 0.5, "int": 0.5}, 
	"shield_boomerang": {"str": 0.5, "hp": 0.5}, "pressure": {"str": 0.5, "hp": 0.5}, "u_bulwark": {"str": 0.5, "hp": 0.5}, 
	"martyrs_reckoning": {"str": 0.5, "hp": 1.0}, "magnum_break": {"str": 0.5, "hp": 0.5}, 






	"reflect_shield": {"str": 1.0, "hp": 0.5}, 
	"investigate": {"str": 0.5, "hp": 0.5}, 
	"acid_demonstration": {"int": 0.5, "hp": 0.5}, 
	"mammonite": {"str": 0.5, "luk": 0.5}, "throw_zeny": {"str": 0.5, "luk": 0.5}, "desperado": {"str": 0.5, "luk": 0.5}, 
	"sonic_blow": {"str": 0.5, "agi": 0.5}, "cross_slash": {"str": 0.5, "agi": 0.5}, 

	"soul_breaker": {"str": 0.5, "int": 0.5}, 
	"flying_kick": {"str": 0.5, "agi": 0.5}, "tornado_kick": {"str": 0.5, "agi": 0.5}, 
	"spider_web": {"int": 1.0}, 


	"call_homunculus": {"int": 1.0}, 




	"wiz_combo": {"int": 1.0}, "spirit_of_sea": {"int": 1.0}, 





	"heal": {"int": 1.0}, "energy_coat": {"int": 1.0}, "assumptio": {"int": 1.0}, "tuna_party": {"int": 1.0}, 
}


const MAGIC_TAGS: = ["wiz_combo", "spirit_of_sea", "u_volcano"]




const AUTOCAST_MAGIC_TAGS: = ["u_queen", "u_kraken", "u_moon"]

const HYBRID_TAGS: = ["u_shatter", "u_ankh", "u_bishop"]






const HIGHER_STAT_SKILLS: = ["falcon_assault", "blitz_beat", "land_mine", "ankle_snare", "sandman", "bio_cannibalize", 
	"picky_peck", "scar_of_tarou", "arclouse_dash", "lunatic_carrot_beat"]






const DORAM_SPEAR_METEOR_GAP: = 0.9
const DORAM_PICKY_HATCH: = 0.6
const DORAM_PICKY_GENS: = 2
const DORAM_CARROT_RAIN: = 3
const DORAM_CARROT_RAINS_MAX: = 4
const DORAM_POWDER_TIME: = 3.0
const DORAM_POWDER_TICK: = 0.5
const DORAM_POWDER_DMG: = 0.1



const AV_SONGS: = ["poem_of_bragi", "assassin_cross_sunset", "service_for_you", "scream"]
const AV_SONG_DMG: = 0.4
const _SCALE_PHYS: = {"str": 1.0}
const _SCALE_MAGIC: = {"int": 1.0}

const SCALE_NAMES: = {"str": "FUE", "int": "INT", "agi": "AGI", "luk": "SUE", "hp": "Vida"}
const DEX_SUPPORT: = 0.05



const STEEL_GUARD_MAX: = 0.75






const BUFF_POWER_DMG_KEYS: = ["dmg", "aspd", "aura_stats", "poison_hit", "skill_dmg", "summon_dmg", "melt", "basic_dmg", "crit", "crit_dmg", "frail"]
const BUFF_POWER_DMG_SHARE: = 0.25





const BUFF_DEX_DMG_SHARE: = 0.5
const DEX_DURATION: = 0.04
const VIT_HP_PCT: = 0.03


const VIT_FLAT_HP: = 50.0


const VIT_SHIELD: = 0.005
const VIT_HEAL: = 0.03
const VIT_DMG_CUT: = 0.005
const VIT_DMG_CUT_MAX: = 0.25
const LUK_CRIT_DMG: = 0.025

const LUK_CRIT: = 0.03


const AGI_ASPD_DIV: = 35.0






const AGI_ASPD_PER_POINT: = 8.0

const SUPPORT_TYPES: = ["buff", "heal", "shield"]

const CRIT_OVERFLOW_DMG: = 1.0


const AREA_OVERFLOW_DMG: = 0.5



const ULTRA_CRIT_AT: = 2.5
const ULTRA_CRIT_BONUS: = 1.25
const ULTRA_CRIT_COLOR: = Color(1.0, 0.55, 0.2)




const LETHAL_CRIT_AT: = 5.0
const LETHAL_CRIT_CHANCE: = 0.25
const LETHAL_CRIT_BONUS: = 1.5
const LETHAL_SPLASH: = 0.4
const LETHAL_SPLASH_RADIUS: = 2.5
const LETHAL_CRIT_COLOR: = Color(1.0, 0.25, 0.2)

const LETHAL_FX_CD: = 0.25










const ASSASSIN_LETHAL_AT: = 3.5
const ASSASSIN_LETHAL_CHANCE: = 0.4
const ASSASSINATE_BASE: = 0.1
const ASSASSINATE_PER_X: = 0.05
const ASSASSINATE_MAX: = 0.4
const ASSASSINATE_BONUS: = 3.0
const ASSASSINATE_JUMPS: = 2
const ASSASSINATE_RANGE: = 4.0
const ASSASSINATE_COLOR: = Color(0.78, 0.38, 1.0)

const ASSASSINATE_DIGITS: = Color(1.0, 0.88, 1.0)
const ASSASSINATE_BURST: = Color(0.5, 0.18, 0.75)

const ASSASSINATE_WORD_GAP: = 1.2


static func assassin_crit(p: Player) -> bool:
	return p != null and str(p.job2.get("id", "")) == "assassin_cross" and p.skills.has("edp")



static func lethal_at(p: Player) -> float:
	return ASSASSIN_LETHAL_AT if assassin_crit(p) else LETHAL_CRIT_AT


static func lethal_chance(p: Player) -> float:
	return ASSASSIN_LETHAL_CHANCE if assassin_crit(p) else LETHAL_CRIT_CHANCE



static func assassinate_chance(p: Player) -> float:
	if not assassin_crit(p):
		return 0.0
	return clampf(ASSASSINATE_BASE + ASSASSINATE_PER_X * maxf(0.0, p.crit_dmg - ASSASSIN_LETHAL_AT), 0.0, ASSASSINATE_MAX)


const OVERSTAT_EFF: = 0.5

const STAT_HARD_CAP: = 999



const MOUNT_LANCE: = 1.2

const SPEAR_LANCE: = 1.2


const GUNGNIR_MULT: = 1.5
const GUNGNIR_RADIUS: = 3.0

const GUNGNIR_SEEK: = 1.4



const SPEAR_FAN: = 0.35
const SPEAR_FOCUS: = 0.04


const MOUNT_KNIGHT_KINDS: = {"spear": ["weapon_knight_peco_spear", "weapon_knight_peco_spear_slash", 11], 
	"sword2": ["weapon_knight_peco_sword2", "weapon_knight_peco_sword2_slash", 10]}
const MOUNT_CRUSADER_KINDS: = {"spear": ["weapon_crusader_peco_spear", "weapon_crusader_peco_spear_slash", 11], 
	"sword2": ["weapon_crusader_peco_sword2", "weapon_crusader_peco_sword2_slash", 10]}
const MOUNTS: = {
	"knight": {"body": "knight_peco", "weapon": "weapon_knight_peco_sword", "weapon_fx": "weapon_knight_peco_slash", "kinds": MOUNT_KNIGHT_KINDS}, 
	"lord_knight": {"body": "lord_knight_peco", "weapon": "weapon_knight_peco_sword", "weapon_fx": "weapon_knight_peco_slash", "kinds": MOUNT_KNIGHT_KINDS}, 
	"crusader": {"body": "crusader_peco", "weapon": "weapon_crusader_peco_sword", "weapon_fx": "weapon_crusader_peco_slash", "kinds": MOUNT_CRUSADER_KINDS}, 
	"paladin": {"body": "paladin_peco", "weapon": "weapon_crusader_peco_sword", "weapon_fx": "weapon_crusader_peco_slash", "kinds": MOUNT_CRUSADER_KINDS}, 
}


const DEF_K: = 30.0


const BOUNCE_RANGE: = 25.0

const PROJECTILES_DRAWN_MAX: = 150


const THROWN_BIG_DRAWN: = 14

const BOUNCE_DMG: = 0.85




const BOUNCE_MARK: = 3




const AGI_CLEAVE_EVERY: = 1
const AGI_CLEAVE_DMG: = 0.6
const AGI_CLEAVE_SWEEP: = 1.8


const REACH_RANGED: = 0.5
const REACH_MELEE: = 0.15
const REACH_SWEEP: = 0.4

const REACH_SUMMON: = 0.5



const AGI_BOUNCE_STEP: = 2




const AGI_FLEE: = 0.015
const FLEE_CAP: = 0.65
const BOSS_FLEE_IGNORE: = 0.5

const MVP_FLEE_IGNORE: = 0.9



const MVP_SHIELD_PIERCE: = 0.65



const MECH_BLOCK_MULT: = 0.35

const MVP_BLOCK_MULT: = 0.5







const HELL_BLOCK_MULT: = 0.25
const HELL_SHIELD_PIERCE: = 0.6
const HELL_STILL_DIST: = 2.5
const HELL_STILL_TIME: = 25.0
const HELL_STILL_STEP: = 0.5
const HELL_STILL_MAX: = 4






const SURVIVE_FROM: = 0.5
const SURVIVE_HP: = 0.01
const SURVIVE_GRACE: = 0.8
const SURVIVE_CD: = 4.0













const MOB_HIT_FROM: = 0.15
const MOB_HIT_MID: = 0.5
const MOB_HIT_TOUGH: = 1.5
const HIT_RESIST_VIT: = 0.01
const HIT_RESIST_MAX: = 0.5
const MOB_HIT_TOWER_FLOOR: = 100








const REFLECT_OVER_SOFT: = 8.0



static func reflect_over(over: float) -> float:
	var x: = maxf(0.0, over - 1.0)
	return 1.0 + x / (1.0 + x / REFLECT_OVER_SOFT)
const MOB_HIT_ENDLESS_STEP: = 0.025


const OATH_HIT_STEP: = 0.04


const HELL_HIT_STEP: = 0.1




func mob_hit_share(d: int) -> float:
	var h: = hell_level(d)
	if h <= 0:
		return lerpf(MOB_HIT_FROM, MOB_HIT_MID, clampf((d - 1) / float(DANGER_HELL_FROM - 2), 0.0, 1.0))
	return lerpf(MOB_HIT_MID, 1.0, clampf(h / float(DANGER_MAX - DANGER_HELL_FROM + 1), 0.0, 1.0))


const KNOCK_STACK: = 1.5
const KNOCK_MIN_CAP: = 3.0

const TAUNT_BOSS: = 0.75
const LUK_PERFECT_DODGE: = 0.01
const PERFECT_DODGE_CAP: = 0.25

const AGI_MOVE: = 0.03

const MOVE_SPEED_MAX: = 12.0

const MOVE_SPEED_MAX_MOUNTED: = 15.0






const PROC_LEVEL_DMG: = 0.025
const PROC_LEVEL_SOFT: = 100


const PROC_LEVEL_DMG_LATE: = 0.0075




const PROC_HIT_HP_ROOT: = 0.01



const BASIC_EXTRA_DMG: = 0.5

const PROC_DMG: = 1.25






const CARD_OWN_SKILL_DMG: = 6.0




const CARD_SKILL_CAST: = ["stone_curse"]




static func card_merges(id: String) -> bool:
	var s: Dictionary = SKILLS.get(id, {})
	if not s.has("damage") or CARD_SKILL_CAST.has(id):
		return false
	return not str(s.get("type", "")) in ["heal", "shield", "buff", "summon"]


const PROC_SKILL_DMG: = {"meteor_storm": 0.4}


const U_BASE: = 20.0


static func proc_level_mult(level: int) -> float:
	return 1.0 + PROC_LEVEL_DMG * (mini(level, PROC_LEVEL_SOFT) - 1) + PROC_LEVEL_DMG_LATE * maxi(0, level - PROC_LEVEL_SOFT)


const GOSPEL_HIT_PROC: = 0.5
const STEEL_HIT_PROC: = 1.0






const HIT_ICD: = 0.5



const TOUCH_EVERY: = 1.5



const FURY_CHAIN_DMG: = 0.5
const FURY_CHAIN_RANGE: = 4.0

const STEEL_MIN_SPHERES: = 3
const STEEL_PER_SPHERE: = 0.8

const AUTOCAST_TAGS: = ["hindsight", "u_owl", "u_kraken", "u_moon", "u_scythe", "u_quake", "u_tiger", "u_bone", "u_ankh", "u_maya", "u_flies", "u_queen"]

const AUTOCAST_INT_TAGS: = ["hindsight", "u_bone", "u_maya"]

const SUMMON_RANGE: = 7.0

const SUMMON_SHOTS: = {"picky": "item_shot_feather", "tarou": "item_shot_claw", "skeleton": "item_shot_bone", "skeleton_general": "item_shot_bone", "andre": "item_shot_jaw", 
	"mandragora": "item_shot_stem", "hydra": "item_shot_tentacle", "flora": "item_shot_petal", "parasite": "item_shot_seed", 
	"geographer": "item_shot_leaf"}
const SUMMON_SHOT_SPEED: = 22.0


const SUMMON_POWER: = 1.5




const SUMMON_ASPD_MIN: = 0.6

const SUMMON_MOVE_MAX: = 3.0



const SUMMON_HITS_POW: = 0.75

const HOMUN_POWER: = 1.95














const SUMMON_BOSS_DMG: = 0.5
const SUMMON_OVERFLOW_POW: = 0.35
const PLANT_CHAIN: = 1
const PLANT_CHAIN_SHARE: = 0.6
const PLANT_CHAIN_RANGE: = 4.0
const SUMMON_LEECH_PER_S: = 5.0

const SUMMON_TAGS: = ["bio_cannibalize", "bio_cannibalize_x", "picky_peck", "picky_peck_x", "scar_of_tarou", "scar_of_tarou_x", 
	"arclouse_dash", "arclouse_dash_x", "lunatic_carrot_beat", "lunatic_carrot_beat_x", 

	"u_maya", "u_bone"]


static func is_summon_tag(tag: String) -> bool:
	return tag.begins_with("homun_") or SUMMON_TAGS.has(tag)



const ACID_STACK_CAP: = 0.4
const ACID_STACK_CAP_BOSS: = 0.6
const ACID_STACK_KEEP: = 3.0


const PROJ_SPEED_BASE: = 1.5


const ORBIT_SIZE_POW: = 1.4

const ORBIT_SIZE_MAX: = 1.6
const PROJ_SPEED_MAX: = 1.8


const STATS: = {
	"str": {"name": "FUE", "full": "Fuerza", "desc": "Habilidades físicas: +15% de daño, +6% de área y +0.4% de que se repitan (máx. 25%). Además +7% de daño del ataque básico y de los procs de cartas y equipo."}, 
	"agi": {"name": "AGI", "full": "Agilidad", "desc": "-1.7% de tiempo entre ataques básicos (ASPD), -2% de recarga de las habilidades físicas, +1.5% de evasión, +3% velocidad de movimiento y el ataque básico alcanza más enemigos."}, 
	"vit": {"name": "VIT", "full": "Vitalidad", "desc": "+50 y +3% de vida máxima, más regeneración, -0.5% de daño recibido, +1% de resistencia a golpes normales, +3% de curación recibida y +0.5% a los escudos que recibes. Tus autocast al recibir un golpe crecen con la mayor de FUE y VIT."}, 
	"int": {"name": "INT", "full": "Inteligencia", "desc": "Habilidades mágicas: +15% de daño, +6% de área y +0.4% de que se lancen dos veces (máx. 25%)."}, 
	"dex": {"name": "DES", "full": "Destreza", "desc": "-3.5% recarga, +4% de duración de habilidades y +5% de efecto de las habilidades de Apoyo (buffs, curaciones y barreras; +2,5% en lo que tus buffs dan de daño)."}, 
	"luk": {"name": "SUE", "full": "Suerte", "desc": "+3% de crítico, +2.5% de daño crítico, +1% de esquiva perfecta y +2% de probabilidad de cartas. Con el crítico al máximo, lo que sobra se vuelve daño crítico. También mejora la rareza de las opciones al subir de nivel y el Blitz Beat automático del halcón."}, 
}



const CARDS: = {
	"poring_card": {"name": "Poring Card", "type": "armor", "desc": "+5% crítico, +3% evasión.", "mods": {"crit": 0.05, "dodge": 0.03}}, 
	"lunatic_card": {"name": "Lunatic Card", "type": "acc", "desc": "+12% velocidad de movimiento.", "mods": {"move": 0.12}}, 
	"fabre_card": {"name": "Fabre Card", "type": "weapon", "desc": "+12% daño de procs y autocast.", "mods": {"proc_dmg": 0.12}}, 
	"willow_card": {"name": "Willow Card", "type": "armor", "desc": "-8% tiempo de recarga.", "mods": {"haste": 0.08}}, 
	"angeling_card": {"name": "Angeling Card", "type": "armor", "desc": "+1 proyectil en tus habilidades que lanzan varios y +1 flecha / bala / golpe en tu ataque básico, al 50% de daño.", "mods": {"count": 1.0}}, 
	"ghostring_card": {"name": "Ghostring Card", "type": "armor", "desc": "No-muertos y demonios te hieren un 20% menos, +1 vida por segundo.", 
		"mods": {"regen": 1.0}, "effects": {"undead_guard": 0.2}}, 
	"poporing_card": {"name": "Poporing Card", "type": "weapon", "desc": "+10% daño de procs y autocast, +3% crítico.", "mods": {"proc_dmg": 0.1, "crit": 0.03}}, 
	"smokie_card": {"name": "Smokie Card", "type": "acc", "desc": "+5% de doble lanzamiento (tus habilidades de ataque se lanzan dos veces).", "mods": {}, "effects": {"double_cast": 0.05}}, 
	"wolf_card": {"name": "Wolf Card", "type": "weapon", "desc": "+6% de crítico, +25% daño de sangrado.", "mods": {"crit": 0.06}, "effects": {"bleed_dmg": 0.25}}, 
	"bigfoot_card": {"name": "Bigfoot Card", "type": "shield", "desc": "+3 de defensa, +6% de vida máxima, +20% daño de invocaciones.", "mods": {"armor": 3.0, "max_hp_pct": 0.06}, "effects": {"summon_dmg": 0.2}}, 
	"eddga_card": {"name": "Eddga Card", "type": "shoes", "desc": "+10% de daño. 15% con el ataque básico: quema al objetivo.", 
		"mods": {"dmg": 0.1}, "effects": {"burn_hit": 0.15}}, 

	"mastering_card": {"name": "Mastering Card", "type": "weapon", "desc": "8% con el ataque básico: lanza Heal ×Lv. +12% potencia de bufos.", 
		"mods": {}, "effects": {"buff_power": 0.12}, "proc": {"skill": "heal", "chance": 0.08}}, 
	"eclipse_card": {"name": "Eclipse Card", "type": "garment", "desc": "+8% de velocidad de ataque.", 
		"mods": {"aspd": 0.08}}, 
	"elder_willow_card": {"name": "Elder Willow Card", "type": "weapon", "desc": "10% con el ataque básico: lanza Fire Bolt ×Lv.", 
		"mods": {}, "proc": {"skill": "fire_bolt", "chance": 0.1}}, 
	"vagabond_wolf_card": {"name": "Vagabond Wolf Card", "type": "weapon", "desc": "10% con el ataque básico: tu halcón lanza Blitz Beat ×Lv.", 
		"mods": {}, "proc": {"skill": "blitz_beat", "chance": 0.1}}, 

	"zombie_card": {"name": "Zombie Card", "type": "armor", "desc": "+10% duración de tus habilidades, +4% vida máxima.", "mods": {"duration": 0.1, "max_hp_pct": 0.04}}, 
	"ghoul_card": {"name": "Ghoul Card", "type": "acc", "desc": "+5% daño, +8% daño de procs y autocast.", "mods": {"dmg": 0.05, "proc_dmg": 0.08}}, 
	"whisper_card": {"name": "Whisper Card", "type": "garment", "desc": "+5% de evasión, +20% daño de invocaciones.", "mods": {"dodge": 0.05}, "effects": {"summon_dmg": 0.2}}, 
	"skeleton_card": {"name": "Skeleton Card", "type": "weapon", "desc": "5% de aturdir con el ataque básico.", 
		"mods": {}, "effects": {"stun_hit": 0.05}}, 
	"wraith_card": {"name": "Wraith Card", "type": "armor", "desc": "+12% vida máxima. Llenas el Aguante de los jefes un 15% más rápido.", "mods": {"max_hp_pct": 0.12}, "effects": {"wing_fill": 0.15}}, 
	"evil_druid_card": {"name": "Evil Druid Card", "type": "armor", "desc": "+6% daño de habilidades, +8% duración de tus habilidades.", "mods": {"skill_dmg": 0.06, "duration": 0.08}}, 
	"archer_skeleton_card": {"name": "Archer Skeleton Card", "type": "weapon", "desc": "+8% daño de ataques básicos.", 
		"mods": {"basic_dmg": 0.08}}, 


	"skel_soldier_card": {"name": "Soldier Skeleton Card", "type": "weapon", "desc": "+5% crítico, +25% potencia de sangrado.", "mods": {"crit": 0.05}, "effects": {"bleed_power": 0.25}}, 
	"munak_card": {"name": "Munak Card", "type": "armor", "desc": "-5% recarga, +1 defensa.", "mods": {"haste": 0.05, "armor": 1.0}}, 
	"bongun_card": {"name": "Bongun Card", "type": "armor", "desc": "+12% duración de tus habilidades. Llenas el Aguante de los jefes un 15% más rápido.", "mods": {"duration": 0.12}, "effects": {"wing_fill": 0.15}}, 
	"sohee_card": {"name": "Sohee Card", "type": "armor", "desc": "-6% recarga, +5% daño de habilidades.", "mods": {"haste": 0.06, "skill_dmg": 0.05}}, 
	"horong_card": {"name": "Horong Card", "type": "head", "desc": "Al recibir un golpe: 8% de lanzar Fire Bolt ×Lv. Tus quemaduras duran un 30% más.", "mods": {}, "effects": {"burn_time": 0.3}, "proc_hit": {"skill": "fire_bolt", "chance": 0.08}}, 
	"nine_tail_card": {"name": "Nine Tail Card", "type": "garment", "desc": "+10% evasión, +15% potencia de bufos.", "mods": {"dodge": 0.1}, "effects": {"buff_power": 0.15}}, 
	"skeleton_general_card": {"name": "Skeleton General Card", "type": "weapon", "desc": "+10% ASPD. Llenas el Aguante de los jefes un 15% más rápido.", "mods": {"aspd": 0.1}, "effects": {"wing_fill": 0.15}}, 
	"moonlight_card": {"name": "Moonlight Flower Card", "type": "head", "desc": "+18% de daño de habilidades, +10% velocidad de movimiento.", "mods": {"skill_dmg": 0.18, "move": 0.1}}, 

	"zenorc_card": {"name": "Zenorc Card", "type": "weapon", "desc": "Tu ataque básico siempre envenena: un veneno con el 20% de su daño. +25% daño de veneno.", 
		"mods": {}, "effects": {"poison_hit": 0.2, "poison_dmg": 0.25}}, 
	"orc_skeleton_card": {"name": "Orc Skeleton Card", "type": "weapon", "desc": "+8% daño de habilidades.", "mods": {"skill_dmg": 0.08}}, 
	"drainliar_card": {"name": "Drainliar Card", "type": "weapon", "desc": "Roba vida con los ataques básicos.", 
		"mods": {}, "effects": {"lifesteal": 0.02}}, 
	"orc_baby_card": {"name": "Orc Baby Card", "type": "acc", "desc": "+8% EXP, +10% zeny.", "mods": {"xp": 0.08, "loot": 0.1}}, 
	"orc_warrior_card": {"name": "Orc Warrior Card", "type": "armor", "desc": "+5% velocidad de ataque, +2 defensa.", "mods": {"aspd": 0.05, "armor": 2.0}}, 
	"orc_lady_card": {"name": "Orc Lady Card", "type": "acc", "desc": "+4% crítico, +4% velocidad. Llenas el Aguante de los jefes un 15% más rápido.", "mods": {"crit": 0.04, "move": 0.04}, "effects": {"wing_fill": 0.15}}, 
	"orc_archer_card": {"name": "Orc Archer Card", "type": "weapon", "desc": "+7% daño de ataques básicos, +20% velocidad de proyectiles.", "mods": {"basic_dmg": 0.07, "proj_speed": 0.2}}, 
	"orc_zombie_card": {"name": "Orc Zombie Card", "type": "armor", "desc": "+10% daño de procs y autocast, +3% vida máxima.", "mods": {"proc_dmg": 0.1, "max_hp_pct": 0.03}}, 
	"high_orc_card": {"name": "High Orc Card", "type": "shoes", "desc": "+10% de daño.", "mods": {"dmg": 0.1}}, 

	"orc_lord_card": {"name": "Orc Lord Card", "type": "armor", "desc": "+3 defensa, +12% vida máxima, -10% recarga.", "mods": {"armor": 3.0, "max_hp_pct": 0.12, "haste": 0.1}}, 
	"orc_hero_card": {"name": "Orc Hero Card", "type": "head", "desc": "+18% vida máxima, +2 defensa. Llenas el Aguante de los jefes un 15% más rápido.", "mods": {"max_hp_pct": 0.18, "armor": 2.0}, "effects": {"wing_fill": 0.15}}, 
	"raydric_card": {"name": "Raydric Card", "type": "garment", "desc": "+4% evasión, -4% recarga.", "mods": {"dodge": 0.04, "haste": 0.04}}, 
	"khalitzburg_card": {"name": "Khalitzburg Card", "type": "shield", "desc": "No-muertos y demonios te hieren un 25% menos.", 
		"mods": {}, "effects": {"undead_guard": 0.25}}, 

	"thief_bug_male_card": {"name": "Male Thief Bug Card", "type": "weapon", "desc": "+8% daño del ataque básico, +5% velocidad de ataque. Llenas el Aguante de los jefes un 15% más rápido.", "mods": {"basic_dmg": 0.08, "aspd": 0.05}, "effects": {"wing_fill": 0.15}}, 

	"thief_bug_egg_card": {"name": "Thief Bug Egg Card", "type": "shield", "desc": "+12% de vida máxima. Llenas el Aguante de los jefes un 15% más rápido.", "mods": {"max_hp_pct": 0.12}, "effects": {"wing_fill": 0.15}}, 
	"peco_egg_card": {"name": "Peco Peco Egg Card", "type": "shield", "desc": "+2 defensa, +10% duración de tus habilidades. Llenas el Aguante de los jefes un 15% más rápido.", "mods": {"armor": 2.0, "duration": 0.1}, "effects": {"wing_fill": 0.15}}, 
	"baphomet_jr_card": {"name": "Baphomet Jr. Card", "type": "shield", "desc": "+6% de bloqueo con escudo (cualquier clase).", 
		"mods": {}, "effects": {"block": 0.06}}, 
	"bloody_knight_card": {"name": "Bloody Knight Card", "type": "garment", "desc": "2.5% con el ataque básico: lanza Meteor Storm ×Lv.", 
		"mods": {}, "proc": {"skill": "meteor_storm", "chance": 0.025}}, 
	"randgris_card": {"name": "Valkyrie Randgris Card", "type": "garment", 
		"desc": "Bendición de Valhalla: +10% daño, +10% vida máx., +5% vel. de ataque.", 
		"mods": {"dmg": 0.1, "max_hp_pct": 0.1, "aspd": 0.05}}, 
	"ragged_zombie_card": {"name": "Ragged Zombie Card", "type": "armor", "desc": "+12% daño crítico, +1 defensa.", "mods": {"crit_dmg": 0.12, "armor": 1.0}}, 
	"zombie_slaughter_card": {"name": "Zombie Slaughter Card", "type": "weapon", "desc": "+10% daño.", "mods": {"dmg": 0.1}}, 
	"hell_poodle_card": {"name": "Hell Poodle Card", "type": "shoes", "desc": "+12% velocidad de movimiento. Llenas el Aguante de los jefes un 15% más rápido.", "mods": {"move": 0.12}, "effects": {"wing_fill": 0.15}}, 
	"banshee_card": {"name": "Banshee Card", "type": "head", "desc": "Al recibir un golpe: 5% de lanzar Stone Curse ×Lv. +12% daño a enemigos con estado alterado.", "mods": {}, "effects": {"status_vuln": 0.12}, "proc_hit": {"skill": "stone_curse", "chance": 0.05}}, 
	"flame_skull_card": {"name": "Flame Skull Card", "type": "acc", "desc": "Al recibir un golpe: 6% de lanzar Heaven's Drive ×Lv.", "mods": {}, "proc_hit": {"skill": "heavens_drive", "chance": 0.06}}, 
	"necromancer_card": {"name": "Necromancer Card", "type": "garment", "desc": "+5% de evasión, +5% de doble lanzamiento.", "mods": {"dodge": 0.05}, "effects": {"double_cast": 0.05}}, 
	"banshee_master_card": {"name": "Banshee Master Card", "type": "acc", "desc": "-6% enfriamiento, +5% daño de habilidades.", "mods": {"haste": 0.06, "skill_dmg": 0.05}}, 
	"fallen_bishop_card": {"name": "Fallen Bishop Card", "type": "garment", "desc": "+15% daño, +10% vida máxima.", "mods": {"dmg": 0.15, "max_hp_pct": 0.1}}, 
	"disguise_card": {"name": "Disguise Card", "type": "armor", "desc": "+5% vida máxima. Al recibir un golpe: 6% de lanzar Holy Light ×Lv.", "mods": {"max_hp_pct": 0.05}, "proc_hit": {"skill": "holy_light", "chance": 0.06}}, 
	"gibbet_card": {"name": "Gibbet Card", "type": "garment", "desc": "Al recibir un golpe: 8% de lanzar Frost Diver ×Lv. +10% daño a enemigos con estado alterado.", "mods": {}, "effects": {"status_vuln": 0.1}, "proc_hit": {"skill": "frost_diver", "chance": 0.08}}, 
	"rideword_card": {"name": "Rideword Card", "type": "weapon", "desc": "5% con el ataque básico: lanza Jupitel Thunder ×Lv.", "mods": {}, "proc": {"skill": "jupitel_thunder", "chance": 0.05}}, 
	"dark_priest_card": {"name": "Dark Priest Card", "type": "head", "desc": "+9% de daño de habilidades, +5% de doble lanzamiento.", "mods": {"skill_dmg": 0.09}, "effects": {"double_cast": 0.05}}, 
	"bloody_murderer_card": {"name": "Bloody Murderer Card", "type": "weapon", "desc": "+12% daño.", "mods": {"dmg": 0.12}}, 
	"dullahan_card": {"name": "Dullahan Card", "type": "acc", "desc": "5% con el ataque básico: lanza Frost Diver ×Lv.", "mods": {}, "proc": {"skill": "frost_diver", "chance": 0.05}}, 
	"hunter_fly_card": {"name": "Hunter Fly Card", "type": "acc", "desc": "+5% velocidad de ataque, +8% daño de procs y autocast.", "mods": {"aspd": 0.05, "proc_dmg": 0.08}}, 
	"beelzebub_card": {"name": "Beelzebub Card", "type": "garment", "desc": "+12% velocidad de ataque. 30% con el ataque básico: sangrado (acumula y revienta).", 
		"mods": {"aspd": 0.12}, "effects": {"bleed_hit": 0.3}}, 
	"satan_morroc_card": {"name": "Satan Morroc Card", "type": "armor", "desc": "Alas de la desesperación: +20% daño de habilidades y +10% vida máxima.", 
		"mods": {"skill_dmg": 0.2, "max_hp_pct": 0.1}}, 


	"dark_lord_card": {"name": "Dark Lord Card", "type": "garment", "desc": "+12% vida máxima, +20% daño de procs y autocast. Al recibir un golpe: 5% de lanzar Meteor Storm ×Lv.", "mods": {"max_hp_pct": 0.12, "proc_dmg": 0.2}, "proc_hit": {"skill": "meteor_storm", "chance": 0.05}}, 
	"baphomet_card": {"name": "Baphomet Card", "type": "weapon", "desc": "+25% de área.", "mods": {"area": 0.25}}, 

	"spore_card": {"name": "Spore Card", "type": "head", "desc": "+10% EXP, +15% radio para recoger.", "mods": {"xp": 0.1, "magnet": 0.15}}, 
	"orc_shaman_card": {"name": "Orc Shaman Card", "type": "acc", "desc": "+6% de daño de habilidades, +4% de doble lanzamiento, +10% probabilidad de estados.", "mods": {"skill_dmg": 0.06}, "effects": {"double_cast": 0.04, "status_chance": 0.1}}, 
	"bomb_poring_card": {"name": "Bomb Poring Card", "type": "acc", "desc": "+10% de área, +10% probabilidad de estados.", "mods": {"area": 0.1}, "effects": {"status_chance": 0.1}}, 
	"marine_sphere_card": {"name": "Marine Sphere Card", "type": "garment", "desc": "Al recibir un golpe: 10% de estallar con Magnum Break ×Lv. +10% de daño a un jefe aturdido por el Aguante.", "mods": {}, "effects": {"wing_broken": 0.1}, "proc_hit": {"skill": "magnum_break", "chance": 0.1}}, 

	"thief_bug_card": {"name": "Thief Bug Card", "type": "shoes", "desc": "+8% velocidad de movimiento, +2% evasión, +15% curación de tus habilidades.", "mods": {"move": 0.08, "dodge": 0.02}, "effects": {"heal_power": 0.15}}, 
	"tarou_card": {"name": "Tarou Card", "type": "armor", "desc": "+4% crítico, +3% evasión.", "mods": {"crit": 0.04, "dodge": 0.03}}, 
	"plankton_card": {"name": "Plankton Card", "type": "acc", "desc": "+10% de duración de las habilidades, +3% de doble lanzamiento.", "mods": {"duration": 0.1}, "effects": {"double_cast": 0.03}}, 
	"cramp_card": {"name": "Cramp Card", "type": "weapon", "desc": "+5% crítico, +3% daño.", "mods": {"crit": 0.05, "dmg": 0.03}}, 
	"thara_frog_card": {"name": "Thara Frog Card", "type": "shield", "desc": "+2 defensa, +6% vida máxima, refleja el 16% del daño recibido.", "mods": {"armor": 2.0, "max_hp_pct": 0.06}, "effects": {"reflect": 0.16}}, 
	"toad_card": {"name": "Toad Card", "type": "acc", "desc": "+6% evasión, +15% zeny.", "mods": {"dodge": 0.06, "loot": 0.15}}, 
	"golden_bug_card": {"name": "Golden Thief Bug Card", "type": "shield", "desc": "Caparazón dorado: +4 defensa, +15% vida máxima.", "mods": {"armor": 4.0, "max_hp_pct": 0.15}}, 

	"kukre_card": {"name": "Kukre Card", "type": "shoes", "desc": "+5% velocidad de ataque.", "mods": {"aspd": 0.05}}, 
	"vadon_card": {"name": "Vadon Card", "type": "weapon", "desc": "6% con el ataque básico: lanza Cold Bolt ×Lv.", "mods": {}, "proc": {"skill": "cold_bolt", "chance": 0.06}}, 
	"marina_card": {"name": "Marina Card", "type": "weapon", "desc": "8% con el ataque básico: lanza Frost Diver ×Lv.", "mods": {}, "proc": {"skill": "frost_diver", "chance": 0.08}}, 
	"hydra_card": {"name": "Hydra Card", "type": "weapon", "desc": "+8% de daño, +25% daño de invocaciones.", "mods": {"dmg": 0.08}, "effects": {"summon_dmg": 0.25}}, 
	"marse_card": {"name": "Marse Card", "type": "armor", "desc": "+5% daño de habilidades, +5% área.", "mods": {"skill_dmg": 0.05, "area": 0.05}}, 
	"obeaune_card": {"name": "Obeaune Card", "type": "head", "desc": "+7% de daño de habilidades.", "mods": {"skill_dmg": 0.07}}, 
	"strouf_card": {"name": "Strouf Card", "type": "weapon", "desc": "+12% daño, +5% crítico.", "mods": {"dmg": 0.12, "crit": 0.05}}, 
	"kraken_card": {"name": "Kraken Card", "type": "garment", "desc": "+18% daño, +8% vida máxima.", "mods": {"dmg": 0.18, "max_hp_pct": 0.08}}, 

	"solider_card": {"name": "Solider Card", "type": "shield", "desc": "+5% vida máxima. Al recibir un golpe: 6% de lanzarte Kyrie Eleison ×Lv.", "mods": {"max_hp_pct": 0.05}, "proc_hit": {"skill": "kyrie_eleison", "chance": 0.06}}, 
	"permeter_card": {"name": "Permeter Card", "type": "armor", "desc": "+15% vida máxima.", "mods": {"max_hp_pct": 0.15}}, 
	"freezer_card": {"name": "Freezer Card", "type": "weapon", "desc": "10% con el ataque básico: lanza Cold Bolt ×Lv.", "mods": {}, "proc": {"skill": "cold_bolt", "chance": 0.1}}, 
	"heater_card": {"name": "Heater Card", "type": "weapon", "desc": "10% con el ataque básico: lanza Fire Bolt ×Lv. +25% potencia de quemadura.", "mods": {}, "effects": {"burn_power": 0.25}, "proc": {"skill": "fire_bolt", "chance": 0.1}}, 
	"turtle_knight_card": {"name": "Turtle Knight Card", "type": "armor", "desc": "+2 defensa, +10% daño de procs y autocast, +10% de daño a un jefe aturdido por el Aguante.", "mods": {"armor": 2.0, "proc_dmg": 0.1}, "effects": {"wing_broken": 0.1}}, 
	"turtle_champion_card": {"name": "Turtle Champion Card", "type": "shield", "desc": "+8% de bloqueo con escudo (cualquier clase).", "mods": {}, "effects": {"block": 0.08}}, 
	"turtle_general_card": {"name": "Turtle General Card", "type": "weapon", "desc": "+15% daño; 7% con el ataque básico: lanza Magnum Break ×Lv.", "mods": {"dmg": 0.15}, "proc": {"skill": "magnum_break", "chance": 0.07}}, 

	"mummy_card": {"name": "Mummy Card", "type": "armor", "desc": "+10% duración de tus habilidades, +4% daño de habilidades.", "mods": {"duration": 0.1, "skill_dmg": 0.04}}, 
	"isis_card": {"name": "Isis Card", "type": "armor", "desc": "+6% de daño, +3% de doble lanzamiento.", "mods": {"dmg": 0.06}, "effects": {"double_cast": 0.03}}, 
	"matyr_card": {"name": "Matyr Card", "type": "shoes", "desc": "+10% velocidad de movimiento, +15% daño de invocaciones.", "mods": {"move": 0.1}, "effects": {"summon_dmg": 0.15}}, 
	"minorous_card": {"name": "Minorous Card", "type": "weapon", "desc": "+10% daño de ataques básicos.", "mods": {"basic_dmg": 0.1}}, 
	"marduk_card": {"name": "Marduk Card", "type": "head", "desc": "+8% de daño de habilidades.", "mods": {"skill_dmg": 0.08}}, 
	"ancient_mummy_card": {"name": "Ancient Mummy Card", "type": "armor", "desc": "+3 defensa, +12% vida máxima.", "mods": {"armor": 3.0, "max_hp_pct": 0.12}}, 



	"osiris_card": {"name": "Osiris Card", "type": "garment", "desc": "Bendición de Osiris: +22% vida máxima, +2 vida por segundo, +40% daño de invocaciones.", "mods": {"max_hp_pct": 0.22, "regen": 2.0}, "effects": {"summon_dmg": 0.4}}, 



	"andre_card": {"name": "Andre Card", "type": "weapon", "desc": "+8% daño de ataques básicos; 8% con el ataque básico: lanza Heaven's Drive ×Lv.", "mods": {"basic_dmg": 0.08}, "proc": {"skill": "heavens_drive", "chance": 0.08}}, 
	"piere_card": {"name": "Piere Card", "type": "armor", "desc": "+6% daño de ataques básicos, +1 defensa, +20% daño de invocaciones.", "mods": {"basic_dmg": 0.06, "armor": 1.0}, "effects": {"summon_dmg": 0.2}}, 
	"deniro_card": {"name": "Deniro Card", "type": "acc", "desc": "+4% crítico, +3% daño, +20% daño de invocaciones.", "mods": {"crit": 0.04, "dmg": 0.03}, "effects": {"summon_dmg": 0.2}}, 
	"vitata_card": {"name": "Vitata Card", "type": "acc", "desc": "Al recibir un golpe: 8% de lanzarte Heal ×Lv. +15% potencia de bufos.", "mods": {}, "effects": {"buff_power": 0.15}, "proc_hit": {"skill": "heal", "chance": 0.08}}, 
	"argiope_card": {"name": "Argiope Card", "type": "weapon", "desc": "Envenena con el ataque básico, +4% velocidad de ataque, +30% cargas máximas de veneno.", "mods": {"aspd": 0.04}, "effects": {"poison_hit": 0.25, "poison_cap": 0.3}}, 
	"giant_spider_card": {"name": "Giant Spider Card", "type": "garment", "desc": "+8% evasión, +4% crítico.", "mods": {"dodge": 0.08, "crit": 0.04}}, 
	"maya_card": {"name": "Maya Card", "type": "shield", "desc": "Caparazón de la reina: +5 defensa, -10% recarga.", "mods": {"armor": 5.0, "haste": 0.1}}, 

	"skel_worker_card": {"name": "Skeleton Worker Card", "type": "armor", "desc": "-4% recarga, +6% daño de procs y autocast.", "mods": {"haste": 0.04, "proc_dmg": 0.06}}, 
	"steel_chocho_card": {"name": "Steel Chonchon Card", "type": "armor", "desc": "+10% daño de procs y autocast. Al recibir un golpe: 6% de lanzar Thunder Storm ×Lv.", "mods": {"proc_dmg": 0.1}, "proc_hit": {"skill": "thunder_storm", "chance": 0.06}}, 
	"iron_fist_card": {"name": "Iron Fist Card", "type": "weapon", "desc": "5% con el ataque básico: lanza Bash ×Lv.", "mods": {}, "proc": {"skill": "bash", "chance": 0.05}}, 
	"hornet_card": {"name": "Hornet Card", "type": "weapon", "desc": "6% con el ataque básico: lanza Envenom ×Lv. +20% daño de veneno.", "mods": {}, "effects": {"poison_dmg": 0.2}, "proc": {"skill": "envenom", "chance": 0.06}}, 
	"argos_card": {"name": "Argos Card", "type": "acc", "desc": "+5% daño, +2% crítico.", "mods": {"dmg": 0.05, "crit": 0.02}}, 
	"giant_hornet_card": {"name": "Giant Hornet Card", "type": "acc", "desc": "+8% velocidad de ataque.", "mods": {"aspd": 0.08}}, 
	"golem_card": {"name": "Golem Card", "type": "armor", "desc": "+4 defensa, +8% vida máxima.", "mods": {"armor": 4.0, "max_hp_pct": 0.08}}, 


	"mistress_card": {"name": "Mistress Card", "type": "head", "desc": "+20% daño de habilidades, -20% recarga.", "mods": {"haste": 0.2, "skill_dmg": 0.2}}, 

	"clock_card": {"name": "Clock Card", "type": "shield", "desc": "+2 defensa, +5% vida máxima, +4% de doble lanzamiento.", "mods": {"armor": 2.0, "max_hp_pct": 0.05}, "effects": {"double_cast": 0.04}}, 
	"alarm_card": {"name": "Alarm Card", "type": "acc", "desc": "+5% velocidad de movimiento, +4% de doble lanzamiento.", "mods": {"move": 0.05}, "effects": {"double_cast": 0.04}}, 
	"punk_card": {"name": "Punk Card", "type": "garment", "desc": "+5% evasión, +3% velocidad de movimiento.", "mods": {"dodge": 0.05, "move": 0.03}}, 
	"mimic_card": {"name": "Mimic Card", "type": "acc", "desc": "+20% zeny.", "mods": {"loot": 0.2}}, 
	"owl_duke_card": {"name": "Owl Duke Card", "type": "head", "desc": "+10% de daño de habilidades.", "mods": {"skill_dmg": 0.1}}, 
	"owl_baron_card": {"name": "Owl Baron Card", "type": "weapon", "desc": "+10% daño; 8% con el ataque básico: lanza Thunder Storm ×Lv.", "mods": {"dmg": 0.1}, "proc": {"skill": "thunder_storm", "chance": 0.08}}, 

	"quve_card": {"name": "Quve Card", "type": "acc", "desc": "-4% recarga, +8% duración de tus habilidades.", "mods": {"haste": 0.04, "duration": 0.08}}, 
	"loli_ruri_card": {"name": "Loli Ruri Card", "type": "armor", "desc": "+8% vida máxima, +8% daño de procs y autocast.", "mods": {"max_hp_pct": 0.08, "proc_dmg": 0.08}}, 
	"hylozoist_card": {"name": "Hylozoist Card", "type": "garment", "desc": "+6% de evasión, +3% de doble lanzamiento.", "mods": {"dodge": 0.06}, "effects": {"double_cast": 0.03}}, 
	"lord_of_death_card": {"name": "Lord of the Dead Card", "type": "weapon", "desc": "+20% daño, 5% de aturdir con el ataque básico.", "mods": {"dmg": 0.2}, "effects": {"stun_hit": 0.05}}, 

	"venatu_card": {"name": "Venatu Card", "type": "weapon", "desc": "+7% de daño; 10% con el ataque básico: lanza Earth Spike ×Lv.", "mods": {"dmg": 0.07}, "proc": {"skill": "earth_spike", "chance": 0.1}}, 
	"red_venatu_card": {"name": "Red Venatu Card", "type": "weapon", "desc": "+5% crítico, +4% daño.", "mods": {"crit": 0.05, "dmg": 0.04}}, 
	"dimik_card": {"name": "Dimik Card", "type": "armor", "desc": "+10% daño de procs y autocast, +1 defensa.", "mods": {"proc_dmg": 0.1, "armor": 1.0}}, 
	"blue_dimik_card": {"name": "Blue Dimik Card", "type": "garment", "desc": "+6% evasión, +2 defensa.", "mods": {"dodge": 0.06, "armor": 2.0}}, 
	"green_dimik_card": {"name": "Green Dimik Card", "type": "acc", "desc": "+7% velocidad de ataque.", "mods": {"aspd": 0.07}}, 
	"archdam_card": {"name": "Archdam Card", "type": "armor", "desc": "+4 defensa, +9% vida máxima.", "mods": {"armor": 4.0, "max_hp_pct": 0.09}}, 
	"apocalips_card": {"name": "Vesper Card", "type": "weapon", "desc": "+20% daño, +10% velocidad de ataque.", "mods": {"dmg": 0.2, "aspd": 0.1}}, 

	"cookie_card": {"name": "Cookie Card", "type": "garment", "desc": "+5% evasión, +3% de doble lanzamiento.", "mods": {"dodge": 0.05}, "effects": {"double_cast": 0.03}}, 
	"cookie_xmas_card": {"name": "Christmas Cookie Card", "type": "armor", "desc": "+2 defensa, +8% vida máxima, +10% curación de tus habilidades y +10% potencia de bufos.", "mods": {"armor": 2.0, "max_hp_pct": 0.08}, "effects": {"heal_power": 0.1, "buff_power": 0.1}}, 
	"cruiser_card": {"name": "Cruiser Card", "type": "weapon", "desc": "+5% velocidad de ataque, +3% crítico.", "mods": {"aspd": 0.05, "crit": 0.03}}, 
	"mystcase_card": {"name": "Myst Case Card", "type": "acc", "desc": "+15% zeny.", "mods": {"loot": 0.15}}, 
	"garm_baby_card": {"name": "Hatii Baby Card", "type": "shoes", "desc": "+6% velocidad de movimiento, +15% velocidad de proyectiles.", "mods": {"move": 0.06, "proj_speed": 0.15}}, 
	"marionette_card": {"name": "Marionette Card", "type": "head", "desc": "+8% daño de habilidades, +4% de doble lanzamiento.", "mods": {"skill_dmg": 0.08}, "effects": {"double_cast": 0.04}}, 
	"garm_card": {"name": "Hatii Card", "type": "weapon", "desc": "+10% daño; 6% con el ataque básico: lanza Frost Diver ×Lv.", "mods": {"dmg": 0.1}, "proc": {"skill": "frost_diver", "chance": 0.06}}, 
	"knight_of_windstorm_card": {"name": "Stormy Knight Card", "type": "weapon", "desc": "+15% daño; 5% con el ataque básico: lanza Storm Gust ×Lv.", "mods": {"dmg": 0.15}, "proc": {"skill": "storm_gust", "chance": 0.05}}, 

	"solace_card": {"name": "Solace Card", "type": "armor", "desc": "+9% vida máxima, +10% duración de tus habilidades.", "mods": {"max_hp_pct": 0.09, "duration": 0.1}}, 
	"observation_card": {"name": "Observation Card", "type": "head", "desc": "+6% crítico, +20% daño de invocaciones.", "mods": {"crit": 0.06}, "effects": {"summon_dmg": 0.2}}, 
	"retribution_card": {"name": "Retribution Card", "type": "weapon", "desc": "+8% daño, +10% daño crítico.", "mods": {"dmg": 0.08, "crit_dmg": 0.1}}, 
	"shelter_card": {"name": "Shelter Card", "type": "shield", "desc": "+3 defensa, +6% vida máxima, refleja el 20% del daño recibido.", "mods": {"armor": 3.0, "max_hp_pct": 0.06}, "effects": {"reflect": 0.2}}, 
	"zherlthsh_card": {"name": "Zherlthsh Card", "type": "garment", "desc": "+6% evasión, +2 defensa.", "mods": {"dodge": 0.06, "armor": 2.0}}, 
	"tha_odium_card": {"name": "Odium of Thanatos Card", "type": "acc", "desc": "+6% daño, +6% daño de habilidades.", "mods": {"dmg": 0.06, "skill_dmg": 0.06}}, 

	"reginleif_card": {"name": "Valkyrie Reginleif Card", "type": "armor", "desc": "+22% vida máxima, +3 defensa; al recibir un golpe: 6% de lanzar Magnus Exorcismus ×Lv.", "mods": {"max_hp_pct": 0.22, "armor": 3.0}, "proc_hit": {"skill": "magnus_exorcismus", "chance": 0.06}}, 
	"randgris_fallen_card": {"name": "Fallen Randgris Card", "type": "weapon", "desc": "+20% daño, +20% daño crítico, −5% vida máxima.", "mods": {"dmg": 0.2, "crit_dmg": 0.2, "max_hp_pct": -0.05}}, 
	"thanatos_card": {"name": "Memory of Thanatos Card", "type": "weapon", "desc": "+15% daño, +25% daño crítico; 5% con el ataque básico: lanza Lord of Vermilion ×Lv.", "mods": {"dmg": 0.15, "crit_dmg": 0.25}, "proc": {"skill": "lord_of_vermilion", "chance": 0.05}}, 

	"ygnizem_card": {"name": "Egnigem Cenia Card", "type": "armor", "desc": "+5% daño de habilidades, +4% vida máxima.", "mods": {"skill_dmg": 0.05, "max_hp_pct": 0.04}}, 
	"whikebain_card": {"name": "Wickebine Tres Card", "type": "weapon", "desc": "+6% daño, +4% crítico.", "mods": {"dmg": 0.06, "crit": 0.04}}, 
	"armaia_card": {"name": "Armeyer Dinze Card", "type": "shield", "desc": "+3 defensa, -4% recarga.", "mods": {"armor": 3.0, "haste": 0.04}}, 
	"erend_card": {"name": "Errende Ebecee Card", "type": "head", "desc": "+15% curación de tus habilidades, +3% vida máxima.", "effects": {"heal_power": 0.15}, "mods": {"max_hp_pct": 0.03}}, 
	"kavac_card": {"name": "Kavac Icarus Card", "type": "garment", "desc": "+5% evasión, +3% velocidad de ataque.", "mods": {"dodge": 0.05, "aspd": 0.03}}, 
	"rawrel_card": {"name": "Laurell Weinder Card", "type": "acc", "desc": "+7% daño de habilidades.", "mods": {"skill_dmg": 0.07}}, 
	"seyren_card": {"name": "Seyren Windsor Card", "type": "weapon", "desc": "+10% daño del ataque básico, +4% daño.", "mods": {"basic_dmg": 0.1, "dmg": 0.04}}, 
	"eremes_card": {"name": "Eremes Guile Card", "type": "weapon", "desc": "+6% crítico, +4% velocidad de ataque.", "mods": {"crit": 0.06, "aspd": 0.04}}, 
	"magaleta_card": {"name": "Margaretha Sorin Card", "type": "acc", "desc": "-6% recarga.", "mods": {"haste": 0.06}}, 
	"shecil_card": {"name": "Cecil Damon Card", "type": "garment", "desc": "+15% daño crítico.", "mods": {"crit_dmg": 0.15}}, 
	"katrinn_card": {"name": "Kathryne Keyron Card", "type": "head", "desc": "+1 proyectil en tus habilidades que lanzan varios y +1 flecha / bala / golpe en tu ataque básico, al 50% de daño.", "mods": {"count": 1.0}}, 
	"harword_card": {"name": "Howard Alt-Eisen Card", "type": "armor", "desc": "+3 defensa, +8% vida máxima.", "mods": {"armor": 3.0, "max_hp_pct": 0.08}}, 
	"l_seyren_card": {"name": "Lord Knight Seyren Card", "type": "weapon", "desc": "+15% daño; 8% con el ataque básico: lanza Bowling Bash ×Lv.", "mods": {"dmg": 0.15}, "proc": {"skill": "bowling_bash", "chance": 0.08}}, 

	"magmaring_card": {"name": "Magmaring Card", "type": "head", "desc": "Tus quemaduras pegan un 20% más.", "mods": {}, "effects": {"burn_power": 0.2}}, 
	"imp_card": {"name": "Imp Card", "type": "armor", "desc": "+3 defensa, +5% vida máxima.", "mods": {"armor": 3.0, "max_hp_pct": 0.05}}, 
	"blazer_card": {"name": "Blazer Card", "type": "acc", "desc": "+7% daño de habilidades.", "mods": {"skill_dmg": 0.07}}, 
	"explosion_card": {"name": "Explosion Card", "type": "weapon", "desc": "+8% daño; el ataque básico quema un 6% de las veces.", "mods": {"dmg": 0.08}, "effects": {"burn_hit": 0.06}}, 
	"salamander_card": {"name": "Salamander Card", "type": "weapon", "desc": "+10% daño; 6% con el ataque básico: lanza Fire Wall ×Lv.", "mods": {"dmg": 0.1}, "proc": {"skill": "fire_wall", "chance": 0.06}}, 
	"kasa_card": {"name": "Kasa Card", "type": "garment", "desc": "+5% evasión, +4% velocidad de ataque. 6% con el ataque básico: lanza Ignition Break ×Lv.", "mods": {"dodge": 0.05, "aspd": 0.04}, "proc": {"skill": "ignition_break", "chance": 0.06}}, 
	"lava_golem_card": {"name": "Lava Golem Card", "type": "armor", "desc": "+5 defensa, +6% vida máxima.", "mods": {"armor": 5.0, "max_hp_pct": 0.06}}, 
	"ifrit_card": {"name": "Ifrit Card", "type": "weapon", "desc": "+15% daño; 6% con el ataque básico: lanza Meteor Storm ×Lv.", "mods": {"dmg": 0.15}, "proc": {"skill": "meteor_storm", "chance": 0.06}}, 

	"agav_card": {"name": "Agav Card", "type": "head", "desc": "+15% potencia de sangrado, +15% daño de sangrado.", "mods": {}, "effects": {"bleed_power": 0.15, "bleed_dmg": 0.15}}, 
	"echio_card": {"name": "Echio Card", "type": "weapon", "desc": "+6% daño, +5% velocidad de ataque.", "mods": {"dmg": 0.06, "aspd": 0.05}}, 
	"isilla_card": {"name": "Isilla Card", "type": "acc", "desc": "-6% recarga, +3% daño de habilidades.", "mods": {"haste": 0.06, "skill_dmg": 0.03}}, 
	"seeker_card": {"name": "Seeker Card", "type": "garment", "desc": "+6% evasión, +20% daño de invocaciones.", "mods": {"dodge": 0.06}, "effects": {"summon_dmg": 0.2}}, 
	"vanberk_card": {"name": "Vanberk Card", "type": "weapon", "desc": "+4% daño y +10% daño a jefes y MVP.", "mods": {"dmg": 0.04}, "effects": {"vs_boss": 0.1}}, 
	"hodremlin_card": {"name": "Hodremlin Card", "type": "shoes", "desc": "+4% velocidad de movimiento. Tu ataque básico envenena: un veneno con el 10% de su daño. +20% daño de veneno.", "mods": {"move": 0.04}, "effects": {"poison_hit": 0.1, "poison_dmg": 0.2}}, 
	"gremlin_card": {"name": "Gremlin Card", "type": "armor", "desc": "+3 defensa, +2 regeneración.", "mods": {"armor": 3.0, "regen": 2.0}}, 
	"beholder_card": {"name": "Beholder Card", "type": "head", "desc": "+8% área, +6% duración de habilidades.", "mods": {"area": 0.08, "duration": 0.06}}, 
	"beholder_master_card": {"name": "Beholder Master Card", "type": "acc", "desc": "+8% daño de habilidades, -4% recarga.", "mods": {"skill_dmg": 0.08, "haste": 0.04}}, 
	"gloom_card": {"name": "Gloom Under Night Card", "type": "weapon", "desc": "+15% daño; 8% con el ataque básico: lanza Soul Strike ×Lv.", "mods": {"dmg": 0.15}, "proc": {"skill": "soul_strike", "chance": 0.08}}, 

	"siroma_card": {"name": "Siroma Card", "type": "acc", "desc": "Tus estados duran un 10% más.", "mods": {}, "effects": {"status_time": 0.1}}, 
	"snowier_card": {"name": "Snowier Card", "type": "armor", "desc": "+3 defensa, +6% vida máxima.", "mods": {"armor": 3.0, "max_hp_pct": 0.06}}, 
	"gazeti_card": {"name": "Gazeti Card", "type": "weapon", "desc": "+6% daño; 6% con el ataque básico: lanza Cold Bolt ×Lv.", "mods": {"dmg": 0.06}, "proc": {"skill": "cold_bolt", "chance": 0.06}}, 
	"ice_titan_card": {"name": "Ice Titan Card", "type": "garment", "desc": "+3 defensa, +5% vida máxima.", "mods": {"armor": 3.0, "max_hp_pct": 0.05}}, 
	"furious_snowier_card": {"name": "Furious Snowier Card", "type": "head", "desc": "+5% daño; 6% con el ataque básico: lanza Frost Diver ×Lv.", "mods": {"dmg": 0.05}, "proc": {"skill": "frost_diver", "chance": 0.06}}, 
	"ktullanux_card": {"name": "Ktullanux Card", "type": "garment", "desc": "+15% duración de tus habilidades. Llenas el Aguante de los jefes y MVP un 50% más rápido; +30% duración de estados.", "mods": {"duration": 0.15}, "effects": {"wing_fill": 0.5, "status_time": 0.3}}, 
}


const LOOT: = {
	"poring": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 6, "chance": 0.22}, 
	"lunatic": {"item": "carrot", "sprite": "loot_carrot", "name": "Carrot", "zeny": 8, "chance": 0.22}, 
	"fabre": {"item": "fluff", "sprite": "loot_fluff", "name": "Fluff", "zeny": 9, "chance": 0.22}, 
	"willow": {"item": "tree_root", "sprite": "loot_tree_root", "name": "Tree Root", "zeny": 15, "chance": 0.3}, 
	"angeling": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 60, "chance": 1.0, "count": 6}, 
	"mastering": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 40, "chance": 1.0, "count": 3}, 
	"eclipse": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 40, "chance": 1.0, "count": 3}, 
	"elder_willow": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 50, "chance": 1.0, "count": 4}, 
	"spore": {"item": "mushroom_spore", "sprite": "loot_mushroom_spore", "name": "Mushroom Spore", "zeny": 9, "chance": 0.22}, 
	"poporing": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 11, "chance": 0.22}, 
	"smokie": {"item": "raccoon_leaf", "sprite": "loot_raccoon_leaf", "name": "Raccoon Leaf", "zeny": 12, "chance": 0.22}, 
	"wolf": {"item": "wolf_claw", "sprite": "loot_wolf_claw", "name": "Wolf Claw", "zeny": 16, "chance": 0.25}, 
	"bigfoot": {"item": "bear_footskin", "sprite": "loot_bear_footskin", "name": "Bear's Footskin", "zeny": 24, "chance": 0.3}, 
	"vagabond_wolf": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"eddga": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"baphomet": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 120, "chance": 1.0, "count": 15}, 
	"skel_soldier": {"item": "skull", "sprite": "loot_skull", "name": "Skull", "zeny": 14, "chance": 0.25}, 
	"munak": {"item": "rotten_bandage", "sprite": "loot_rotten_bandage", "name": "Rotten Bandage", "zeny": 14, "chance": 0.25}, 
	"bon_gun": {"item": "rotten_bandage", "sprite": "loot_rotten_bandage", "name": "Rotten Bandage", "zeny": 15, "chance": 0.25}, 
	"sohee": {"item": "black_cloth", "sprite": "loot_black_cloth", "name": "Black Cloth", "zeny": 18, "chance": 0.25}, 
	"horong": {"item": "transparent_cloth", "sprite": "loot_transparent_cloth", "name": "Transparent Cloth", "zeny": 12, "chance": 0.22}, 
	"nine_tail": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 4}, 
	"skeleton_general": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 90, "chance": 1.0, "count": 7}, 
	"moonlight": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 160, "chance": 1.0, "count": 16}, 
	"zenorc": {"item": "orc_fang", "sprite": "loot_orc_fang", "name": "Orc Fang", "zeny": 16, "chance": 0.25}, 
	"orc_skeleton": {"item": "skull", "sprite": "loot_skull", "name": "Skull", "zeny": 18, "chance": 0.25}, 
	"drainliar": {"item": "black_cloth", "sprite": "loot_black_cloth", "name": "Black Cloth", "zeny": 12, "chance": 0.22}, 
	"orc_lord": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 180, "chance": 1.0, "count": 20}, 
	"orc_baby": {"item": "orc_claw", "sprite": "loot_orc_claw", "name": "Orc Claw", "zeny": 12, "chance": 0.22}, 
	"ork_warrior": {"item": "orc_voucher", "sprite": "loot_orc_voucher", "name": "Orcish Voucher", "zeny": 16, "chance": 0.25}, 
	"orc_lady": {"item": "orc_claw", "sprite": "loot_orc_claw", "name": "Orc Claw", "zeny": 15, "chance": 0.25}, 
	"orc_archer": {"item": "orc_fang", "sprite": "loot_orc_fang", "name": "Orc Fang", "zeny": 16, "chance": 0.25}, 
	"orc_zombie": {"item": "rotten_bandage", "sprite": "loot_rotten_bandage", "name": "Rotten Bandage", "zeny": 18, "chance": 0.25}, 
	"high_orc": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 4}, 
	"ork_hero": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 170, "chance": 1.0, "count": 18}, 
	"zombie": {"item": "rotten_bandage", "sprite": "loot_rotten_bandage", "name": "Rotten Bandage", "zeny": 14, "chance": 0.25}, 
	"ghoul": {"item": "rotten_bandage", "sprite": "loot_rotten_bandage", "name": "Rotten Bandage", "zeny": 18, "chance": 0.25}, 
	"whisper": {"item": "transparent_cloth", "sprite": "loot_transparent_cloth", "name": "Transparent Cloth", "zeny": 16, "chance": 0.25}, 
	"skel_archer": {"item": "skull", "sprite": "loot_skull", "name": "Skull", "zeny": 18, "chance": 0.25}, 
	"skeleton": {"item": "skull", "sprite": "loot_skull", "name": "Skull", "zeny": 16, "chance": 0.25}, 
	"wraith": {"item": "black_cloth", "sprite": "loot_black_cloth", "name": "Black Cloth", "zeny": 22, "chance": 0.3}, 
	"evil_druid": {"item": "skull", "sprite": "loot_skull", "name": "Skull", "zeny": 28, "chance": 0.3}, 
	"raydric": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 50, "chance": 1.0, "count": 4}, 
	"khalitzburg": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 60, "chance": 1.0, "count": 5}, 
	"bloody_knight": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 100, "chance": 1.0, "count": 8}, 
	"dark_lord": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 200, "chance": 1.0, "count": 20}, 
	"satan_morroc": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 260, "chance": 1.0, "count": 24}, 
	"morroc_kid": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 260, "chance": 1.0, "count": 24}, 
	"morroc_adult": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 300, "chance": 1.0, "count": 30}, 
	"ragged_zombie": {"item": "rotten_bandage", "sprite": "loot_rotten_bandage", "name": "Rotten Bandage", "zeny": 18, "chance": 0.25}, 
	"zombie_slaughter": {"item": "skull", "sprite": "loot_skull", "name": "Skull", "zeny": 24, "chance": 0.3}, 
	"hell_poodle": {"item": "black_cloth", "sprite": "loot_black_cloth", "name": "Black Cloth", "zeny": 18, "chance": 0.25}, 
	"banshee": {"item": "transparent_cloth", "sprite": "loot_transparent_cloth", "name": "Transparent Cloth", "zeny": 22, "chance": 0.3}, 
	"flame_skull": {"item": "skull", "sprite": "loot_skull", "name": "Skull", "zeny": 16, "chance": 0.25}, 
	"necromancer": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 55, "chance": 1.0, "count": 5}, 
	"banshee_master": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 110, "chance": 1.0, "count": 9}, 
	"fallen_bishop": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 230, "chance": 1.0, "count": 22}, 
	"disguise": {"item": "black_cloth", "sprite": "loot_black_cloth", "name": "Black Cloth", "zeny": 22, "chance": 0.25}, 
	"gibbet": {"item": "skull", "sprite": "loot_skull", "name": "Skull", "zeny": 24, "chance": 0.3}, 
	"rideword": {"item": "transparent_cloth", "sprite": "loot_transparent_cloth", "name": "Transparent Cloth", "zeny": 18, "chance": 0.25}, 
	"dark_priest": {"item": "rotten_bandage", "sprite": "loot_rotten_bandage", "name": "Rotten Bandage", "zeny": 26, "chance": 0.3}, 
	"bloody_murderer": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 60, "chance": 1.0, "count": 5}, 
	"dullahan": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 120, "chance": 1.0, "count": 9}, 
	"beelzebub": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 250, "chance": 1.0, "count": 24}, 
	"thief_bug_male": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"thief_bug": {"item": "black_cloth", "sprite": "loot_black_cloth", "name": "Black Cloth", "zeny": 14, "chance": 0.23}, 
	"tarou": {"item": "black_cloth", "sprite": "loot_black_cloth", "name": "Black Cloth", "zeny": 14, "chance": 0.23}, 
	"plankton": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 15, "chance": 0.23}, 
	"cramp": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 16, "chance": 0.23}, 
	"thara_frog": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 20, "chance": 0.23}, 
	"toad": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"thief_bug_egg": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"golden_bug": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"kukre": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 14, "chance": 0.23}, 
	"vadon": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 16, "chance": 0.23}, 
	"marina": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 15, "chance": 0.23}, 
	"hydra": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 17, "chance": 0.23}, 
	"marse": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 18, "chance": 0.23}, 
	"obeaune": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"strouf": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"kraken": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"solider": {"item": "tree_root", "sprite": "loot_tree_root", "name": "Tree Root", "zeny": 20, "chance": 0.23}, 
	"permeter": {"item": "tree_root", "sprite": "loot_tree_root", "name": "Tree Root", "zeny": 18, "chance": 0.23}, 
	"freezer": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 19, "chance": 0.23}, 
	"heater": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 19, "chance": 0.23}, 
	"turtle_knight": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"turtle_champion": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"turtle_general": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"mimic": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"mummy": {"item": "rotten_bandage", "sprite": "loot_rotten_bandage", "name": "Rotten Bandage", "zeny": 19, "chance": 0.23}, 
	"isis": {"item": "black_cloth", "sprite": "loot_black_cloth", "name": "Black Cloth", "zeny": 18, "chance": 0.23}, 
	"matyr": {"item": "black_cloth", "sprite": "loot_black_cloth", "name": "Black Cloth", "zeny": 16, "chance": 0.23}, 
	"minorous": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 21, "chance": 0.23}, 
	"marduk": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"ancient_mummy": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"osiris": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"andre": {"item": "tree_root", "sprite": "loot_tree_root", "name": "Tree Root", "zeny": 17, "chance": 0.23}, 
	"piere": {"item": "tree_root", "sprite": "loot_tree_root", "name": "Tree Root", "zeny": 18, "chance": 0.23}, 
	"deniro": {"item": "tree_root", "sprite": "loot_tree_root", "name": "Tree Root", "zeny": 18, "chance": 0.23}, 
	"vitata": {"item": "tree_root", "sprite": "loot_tree_root", "name": "Tree Root", "zeny": 20, "chance": 0.23}, 
	"argiope": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"giant_spider": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"maya": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"skel_worker": {"item": "rotten_bandage", "sprite": "loot_rotten_bandage", "name": "Rotten Bandage", "zeny": 19, "chance": 0.23}, 
	"steel_chocho": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 16, "chance": 0.23}, 
	"iron_fist": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 20, "chance": 0.23}, 
	"hornet": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 15, "chance": 0.23}, 
	"argos": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 21, "chance": 0.23}, 
	"giant_hornet": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"golem": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"mistress": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"clock": {"item": "tree_root", "sprite": "loot_tree_root", "name": "Tree Root", "zeny": 21, "chance": 0.23}, 
	"alarm": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 20, "chance": 0.23}, 
	"punk": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 17, "chance": 0.23}, 
	"owl_duke": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"owl_baron": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"quve": {"item": "transparent_cloth", "sprite": "loot_transparent_cloth", "name": "Transparent Cloth", "zeny": 20, "chance": 0.23}, 
	"loli_ruri": {"item": "black_cloth", "sprite": "loot_black_cloth", "name": "Black Cloth", "zeny": 23, "chance": 0.23}, 
	"hylozoist": {"item": "black_cloth", "sprite": "loot_black_cloth", "name": "Black Cloth", "zeny": 21, "chance": 0.23}, 
	"lord_of_death": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"venatu": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 21, "chance": 0.23}, 
	"venatu_1": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 22, "chance": 0.23}, 
	"dimik": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 23, "chance": 0.23}, 
	"dimik_1": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 23, "chance": 0.23}, 
	"dimik_2": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"archdam": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"apocalips": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"cookie": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"cookie_xmas": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"cruiser": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"mystcase": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 24, "chance": 0.23}, 
	"garm_baby": {"item": "fluff", "sprite": "loot_fluff", "name": "Fluff", "zeny": 24, "chance": 0.23}, 
	"solace": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"observation": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"retribution": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 24, "chance": 0.23}, 
	"shelter": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"ygnizem": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"whikebain": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"armaia": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 24, "chance": 0.23}, 
	"erend": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"kavac": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"rawrel": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"marionette": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"zherlthsh": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"seyren": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"eremes": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"magaleta": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"shecil": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"katrinn": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"garm": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"tha_odium": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"harword": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"knight_of_windstorm": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"thanatos": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"l_seyren": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"magmaring": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 24, "chance": 0.23}, 
	"imp": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"blazer": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"explosion": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"agav": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"echio": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"isilla": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"seeker": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"vanberk": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"hodremlin": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 24, "chance": 0.23}, 
	"siroma": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"snowier": {"item": "fluff", "sprite": "loot_fluff", "name": "Fluff", "zeny": 24, "chance": 0.23}, 
	"gazeti": {"item": "jellopy", "sprite": "loot_jellopy", "name": "Jellopy", "zeny": 24, "chance": 0.23}, 
	"iceicle": {"item": "sticky_mucus", "sprite": "loot_sticky_mucus", "name": "Sticky Mucus", "zeny": 24, "chance": 0.23}, 
	"salamander": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"kasa": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"gremlin": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"beholder": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"ice_titan": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 45, "chance": 1.0, "count": 3}, 
	"lava_golem": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"beholder_master": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"furious_snowier": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 80, "chance": 1.0, "count": 6}, 
	"ifrit": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"gloom": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
	"ktullanux": {"item": "gold_coin", "sprite": "loot_gold_coin", "name": "Gold Coin", "zeny": 150, "chance": 1.0, "count": 18}, 
}





const KAFRAS: = ["npc_kafra", "npc_kafra2", "npc_kafra3", "npc_kafra4", "npc_kafra5", "npc_kafra6", "npc_kafra7", "npc_kafra8", "npc_kafra9", "npc_kafra_goth"]







const KAFRA_SISTERS: = {"npc_kafra9": "npc_kafra_goth", "npc_kafra_goth": "npc_kafra9"}
const KAFRA_LINES: = {
	"npc_kafra_goth": {
		"walk": ["Shh... mi hermana mayor cree que estoy en el mostrador de Prontera. Tú no me viste, ¿sí?", 
			"La Corporación me deja los turnos de afuera. Mi hermana dice que asusto a los clientes... ¿tú te asustas?", 
			"Mi hermana te habría regalado una sonrisa. Yo te traigo algo mejor."], 
		"after_sister": "Mi hermana pasó antes por aquí, lo noto por su perfume. Siempre llega primero... pero yo traigo lo bueno.", 
		"talk": ["Bienvenido al turno de noche de la Corporación Kafra. Mi hermana tiene el de día.", 
			"¿Buscabas a mi hermana? Hoy atiendo yo. Prometo no morder."], 
		"pick": "¿Otra compañera? Llama a mi hermana si quieres a alguien más... alegre.", 
		"arrive": "Mi hermana me dijo que preguntaste por mí. Qué detalle.", 
	}, 
	"npc_kafra9": {
		"walk": ["¿Viste a una Kafra vestida de negro por aquí? Es mi hermanita... siempre se escapa de su puesto.", 
			"Si te cruzas con mi hermana menor, salúdala de mi parte. Parece seria, pero es un amor."], 
		"after_sister": "¡Ah, mi hermanita ya te atendió! Espero que te haya sonreído al menos una vez.", 
		"talk": ["¡Bienvenido! Mi hermana menor también trabaja para la Corporación Kafra, ¿la conoces?"], 
		"pick": "¿Prefieres a otra? Mi hermanita de negro también atiende... dile que la mando yo.", 
		"arrive": "¡Hola! Mi hermana me pasó el turno. ¿Te trató bien? A veces es un poco seca.", 
	}, 
}





const UPGRADES: = {
	"blessing": {"name": "Blessing", "desc": "+6% de daño por cada nivel de la mejora. Al máximo: +30%.", "max": 5, "cost": 2800, "mods": {"dmg": 0.06}}, 
	"increase_agi": {"name": "Increase AGI", "desc": "+4% de velocidad de movimiento por cada nivel de la mejora. Al máximo: +20%.", "max": 5, "cost": 2500, "mods": {"move": 0.04}}, 
	"angelus": {"name": "Angelus", "desc": "+1 de defensa por cada nivel de la mejora. Al máximo: +5.", "max": 5, "cost": 2800, "mods": {"armor": 1.0}}, 
	"yggdrasil_fruit": {"name": "Yggdrasil Berry", "desc": "+8% de vida máxima por cada nivel de la mejora. Al máximo: +40%.", "max": 5, "cost": 3200, "mods": {"max_hp_pct": 0.08}}, 
	"magnificat": {"name": "Magnificat", "desc": "-4% de tiempo de recarga por cada nivel de la mejora. Al máximo: -20%.", "max": 5, "cost": 3500, "mods": {"haste": 0.04}}, 
	"gloria": {"name": "Gloria", "desc": "+3% de probabilidad de crítico por cada nivel de la mejora. Al máximo: +15%.", "max": 5, "cost": 2800, "mods": {"crit": 0.03}}, 
	"battle_manual": {"name": "Battle Manual", "desc": "+6% de EXP por cada nivel de la mejora. Al máximo: +30%.", "max": 5, "cost": 3200, "mods": {"xp": 0.06}}, 
	"bubble_gum": {"name": "Bubble Gum", "desc": "+15% de zeny y +20% de probabilidad de cartas por cada nivel de la mejora. Al máximo: +75% de zeny y +100% de cartas.", "max": 5, "cost": 2800, "mods": {"loot": 0.15, "card": 0.2}}, 
	"yggdrasil_leaf": {"name": "Yggdrasil Leaf", "desc": "Resucitas una vez por partida por cada nivel de la mejora, con la mitad de la vida. Al máximo: 2 veces.", "max": 2, "cost": 15000, "mods": {"revive": 1.0}}, 
	"greed": {"name": "Greed", "desc": "+15% de radio para recoger botín por cada nivel de la mejora (la mitad para cartas, objetos y cofres). Al máximo: +150%.", "max": 10, "cost": 2500, "mods": {"magnet": 0.15}}, 
	"card_slot": {"name": "Card Album", "desc": "+1 ranura para equipar cartas del álbum en cada partida, por cada nivel de la mejora. Al máximo: 3 ranuras.", "max": 3, "cost": 6000, "mods": {}}, 
	"kafra_storage": {"name": "Kafra Storage", "desc": "+10 espacios en el almacén permanente por nivel.", "max": 48, "cost": 6000, "mods": {}}, 
	"kafra_cart": {"name": "Pushcart", "desc": "+1 pieza de equipo inicial por clase, por nivel.", "max": 6, "cost": 8000, "mods": {}}, 
	"kafra_area": {"name": "Yellow Gemstone", "desc": "+6% de área de todas las habilidades por cada nivel de la mejora. Al máximo: +30%.", "max": 5, "cost": 3500, "mods": {"area": 0.06}}, 
	"kafra_amount": {"name": "Red Gemstone", "desc": "+1 proyectil / golpe / objetivo en las habilidades que lanzan varios y +1 flecha / bala en el ataque básico a distancia (al 50% de daño), por cada nivel de la mejora. Al máximo: +2.", 
		"max": 2, "cost": 20000, "mods": {"count": 1.0}}, 
	"kafra_blow": {"name": "Blue Gemstone", "desc": "+1 golpe en el ataque básico cuerpo a cuerpo (al 50% de daño, con su golpe amplio), por cada nivel de la mejora. Al máximo: +2.", 
		"max": 2, "cost": 20000, "mods": {"melee_hits": 1.0}}, 
	"fury": {"name": "Fury", "desc": "+10% de daño de los golpes críticos por cada nivel de la mejora (de x1.5 a x2.0 al máximo). Con x2.5 de daño crítico, los críticos pasan a ser ultra críticos; con x5, algunos son letales.", 
		"max": 5, "cost": 3000, "mods": {"crit_dmg": 0.1}}, 
	"hp_recovery": {"name": "Increase HP Recovery", "desc": "+0.4 de vida por segundo por cada nivel de la mejora. Al máximo: +2 por segundo.", 
		"max": 5, "cost": 2800, "mods": {"regen": 0.4}}, 
	"vultures_eye": {"name": "Vulture's Eye", "desc": "+8% de velocidad de los proyectiles por cada nivel de la mejora. Al máximo: +40%.", 
		"max": 5, "cost": 2200, "mods": {"proj_speed": 0.08}}, 
	"kafra_summon": {"name": "Plant Bottle", "desc": "+12% de daño de invocaciones por cada nivel de la mejora. Al máximo: +60%.", 
		"max": 5, "cost": 3000, "mods": {"summon_dmg": 0.12}}, 
	"kafra_status": {"name": "Venom Knife", "desc": "+10% de daño de veneno, sangrado y quemadura por cada nivel de la mejora. Al máximo: +50%.", 
		"max": 5, "cost": 3000, "mods": {"status_dmg": 0.1}}, 
	"telescope": {"name": "Telescope", "desc": "Ataque básico: +0,5 de alcance a distancia por cada nivel de la mejora; cuerpo a cuerpo, un poco más de alcance y su golpe amplio llega más lejos. Al máximo: +3 a distancia. Tus invocaciones y Homúnculos también llegan +0,5 más lejos por nivel.", 
		"max": 6, "cost": 4500, "mods": {"reach": 1.0}}, 
	"memorize": {"name": "Memorize", "desc": "+8% de duración de las zonas, invocaciones y estados de tus habilidades y de los poderes que recoges, por cada nivel de la mejora. Al máximo: +40%.", 
		"max": 5, "cost": 3200, "mods": {"duration": 0.08}}, 
	"bloody_branch": {"name": "Bloody Branch", "desc": "Maldición: +10% de monstruos y +10% de vida de los monstruos, pero +7% de EXP y +20% de zeny, por cada nivel de la mejora. Desactívala cuando quieras.", 
		"max": 5, "cost": 2000, "mods": {"curse": 0.1}}, 



	"doom": {"name": "Sentencia de muerte", "icon": "bone_helm", "desc": "Maldición: el golpe de cualquier mecánica de un MVP te derriba al instante, tengas lo que tengas (solo tus resurrecciones te salvan), y sus zonas en el suelo y maldiciones te pegan el triple. A cambio: ×1,30 de daño a jefes y MVP, y el huevo del MVP cae el triple de veces. Desactívala cuando quieras.", 
		"max": 1, "cost": 1000000, "mods": {"doom": 1.0}}, 


	"mvp_pride": {"name": "Orgullo de los MVP", "icon": "ymir_fragment", "desc": "Maldición: los MVP (también los que vuelven en Infinito, las Valquirias, Satan Morroc y los de las torres) resisten tu daño a un solo objetivo: aguantan al menos 60 s de él y tu golpe más grande de la partida les quita como mucho el 10% de la vida. Ymir despierta a los 20 s (40 sin ella). A cambio: la carta del MVP cae el doble y +8% de probabilidad de drop. Desactívala cuando quieras.", 
		"max": 1, "cost": 300000, "mods": {"pride": 1.0}}, 
}






const PRIDE_TIME: = 60.0





const WORLD_FEAT_TITLES: = ["bare_hands", "close_call", "doomed_hel", "bare"]
const PRIDE_HIT: = 0.1
const PRIDE_MIN: = 0.01
const PRIDE_CARD: = 2.0
const PRIDE_DROP: = 0.08
const PRIDE_YMIR: = 20.0


const DOOM_BOSS_DMG: = 0.3
const DOOM_EGG: = 3.0

const DOOM_TOWER_FLOOR: = 100

const UPGRADE_SECTIONS: = [
	{"name": "Combate", "ids": ["blessing", "gloria", "fury", "telescope", "kafra_blow", "increase_agi", "angelus", "yggdrasil_fruit", "hp_recovery", "yggdrasil_leaf"]}, 
	{"name": "Habilidades", "ids": ["magnificat", "kafra_area", "kafra_amount", "memorize", "vultures_eye", "kafra_summon", "kafra_status"]}, 
	{"name": "Botín y EXP", "ids": ["battle_manual", "bubble_gum", "greed", "card_slot"]}, 
	{"name": "Servicios Kafra", "ids": ["kafra_storage", "kafra_cart"]}, 
	{"name": "Desafío", "ids": ["bloody_branch", "doom", "mvp_pride"]}, 
]

const NO_TOGGLE: = ["kafra_storage", "kafra_cart"]

const UPGRADE_EFFECTS: = {"summon_dmg": ["summon_dmg"], "status_dmg": ["poison_dmg", "bleed_dmg", "burn_power"]}



const STORAGE_BASE: = 20
const STORAGE_PER_LEVEL: = 10
const LOADOUT_BASE: = 2
const LOADOUT_MAX_LEGENDARY: = 1

const REBIRTH_LEGEND_SLOTS: = 1

const LOADOUT_MAX_UNIQUE: = 1


const KEEP_COST: = [0, 300, 700, 1500]
const KEEP_COST_LEGENDARY: = 4000


const KEEP_WIN: = 3
const KEEP_ZENY_SHARE: = [0.005, 0.005, 0.02, 0.04]
const KEEP_ZENY_SHARE_LEGENDARY: = 0.15
const KEEP_ZENY_SHARE_UNIQUE: = 0.25






const MATERIALS: = {
	"oridecon": {"name": "Oridecon", "icon": "oridecon", "for": "weapon", "kind": "normal", "buy": 2500}, 
	"elunium": {"name": "Elunium", "icon": "elunium", "for": "armor", "kind": "normal", "buy": 2000}, 
	"enriched_oridecon": {"name": "Enriched Oridecon", "icon": "enriched_oridecon", "for": "weapon", "kind": "enriched"}, 
	"enriched_elunium": {"name": "Enriched Elunium", "icon": "enriched_elunium", "for": "armor", "kind": "enriched"}, 
	"hd_oridecon": {"name": "HD Oridecon", "icon": "hd_oridecon", "for": "weapon", "kind": "hd"}, 
	"hd_elunium": {"name": "HD Elunium", "icon": "hd_elunium", "for": "armor", "kind": "hd"}, 

	"star_crumb": {"name": "Star Crumb", "icon": "star_crumb", "for": "potential", "kind": "potential"}, 

	"hel_tear": {"name": "Lágrima de Hel", "icon": "hel_tear", "for": "potential", "kind": "potential"}, 


	"hel_requiem": {"name": "Réquiem de Hel", "icon": "hel_requiem", "for": "wings", "kind": "wings", "bound": true}, 


	"legend_coin": {"name": "Moneda legendaria", "icon": "gold_coin", "for": "currency", "kind": "currency"}, 
}



const LEGEND_COINS: = {"legendary": 1, "unique": 3}






const POTENTIAL_TIERS: = [
	{"name": "Raro", "color": Color(0.35, 0.62, 1.0)}, 
	{"name": "Épico", "color": Color(0.72, 0.42, 1.0)}, 
	{"name": "Legendario", "color": Color(1.0, 0.74, 0.2)}, 
]
const POTENTIAL_UP: = [0.1, 0.04]
const POTENTIAL_SAME: = 0.2




const POTENTIAL_PERFECT: = 0.2

const POTENTIAL_LOCK_COST: = 3






const POTENTIAL_LINES: = {


	"stats": {"text": "+%s%% a todos los atributos", "mod": "all_pct", "vals": [0.02, 0.04, 0.05, 0.07]}, 
	"dmg": {"text": "+%s%% de daño", "mod": "dmg", "vals": [0.04, 0.06, 0.08, 0.1]}, 
	"boss": {"text": "+%s%% de daño a jefes y MVP", "fx": ["vs_boss"], "vals": [0.06, 0.1, 0.12, 0.15]}, 
	"skill": {"text": "+%s%% de daño de habilidades", "mod": "skill_dmg", "vals": [0.08, 0.12, 0.15, 0.18]}, 
	"basic": {"text": "+%s%% de daño del ataque básico", "mod": "basic_dmg", "vals": [0.1, 0.16, 0.2, 0.24]}, 
	"proc": {"text": "+%s%% de daño de procs (lo que lanzan cartas y equipo)", "mod": "proc_dmg", "vals": [0.1, 0.16, 0.2, 0.24]}, 
	"dot": {"text": "+%s%% de daño de quemaduras, sangrados y venenos", "fx": ["burn_power", "bleed_power", "poison_dmg"], "vals": [0.12, 0.2, 0.25, 0.3]}, 
	"crit_dmg": {"text": "+%s%% de daño crítico", "mod": "crit_dmg", "vals": [0.12, 0.2, 0.26, 0.32]}, 
	"double": {"text": "+%s%% de doble lanzamiento", "fx": ["double_cast"], "vals": [0.04, 0.06, 0.08, 0.1]}, 
	"summon": {"text": "+%s%% de daño de invocaciones y homúnculos", "fx": ["summon_dmg"], "vals": [0.12, 0.2, 0.25, 0.3]}, 
	"haste": {"text": "Recargas un %s%% más rápidas", "mod": "haste", "vals": [0.05, 0.08, 0.1, 0.12]}, 
	"hp": {"text": "+%s%% de vida máxima", "mod": "max_hp_pct", "vals": [0.06, 0.1, 0.12, 0.15]}, 
	"mech": {"text": "-%s%% de daño de las mecánicas de jefes", "mod": "grade_mech", "vals": [0.03, 0.05, 0.06, 0.08]}, 
	"heal": {"text": "+%s%% de curación", "fx": ["heal_power"], "vals": [0.1, 0.16, 0.2, 0.25]}, 
	"stagger": {"text": "Llenas el Aguante de los jefes un %s%% más rápido", "fx": ["wing_fill"], "vals": [0.1, 0.16, 0.2, 0.25]}, 
	"broken": {"text": "+%s%% de daño a un jefe aturdido por el Aguante", "fx": ["wing_broken"], "vals": [0.05, 0.08, 0.1, 0.12]}, 
	"zeny": {"text": "+%s%% de zeny", "mod": "loot", "vals": [0.08, 0.12, 0.18, 0.24]}, 


	"mats": {"text": "+%s%% de probabilidad de drop", "fx": ["drop_find"], "vals": [0.04, 0.06, 0.08, 0.1]}, 
}











const STAR_CRUMB_KILL: = 0.00085
const STAR_CRUMB_MVP: = 0.035
const STAR_CRUMB_HELL_FROM: = 10


const STAR_CRUMB_HELL: = 7.5e-05
const STAR_CRUMB_HELL_STEP: = 4e-05





const STAR_CRUMB_OATH_STEP: = 1.5e-05





const OATH_ZENY: = 0.02
const OATH_MATS: = 0.03
const STAR_CRUMB_FESTIVAL: = 0.02
const FESTIVAL_DAILY_COIN: = 0.01


const OATH_UNLUCKY_FLEE: = 0.5





const WEAPON_GRADES: = [
	{}, 





	{"name": "D", "dmg": 0.03, "ori": 40, "zeny": 200000, "chance": 0.9, "color": Color(0.45, 0.85, 0.45)}, 
	{"name": "C", "dmg": 0.06, "ori": 80, "zeny": 500000, "chance": 0.7, "color": Color(0.3, 0.65, 1.0)}, 
	{"name": "B", "dmg": 0.1, "ori": 150, "zeny": 1200000, "chance": 0.5, "color": Color(0.7, 0.4, 1.0)}, 
	{"name": "A", "dmg": 0.15, "ori": 250, "zeny": 3000000, "chance": 0.35, "hd": 1, "color": Color(1.0, 0.72, 0.2)}, 
	{"name": "S", "dmg": 0.2, "ori": 400, "zeny": 6000000, "chance": 0.25, "hd": 2, "color": Color(1.0, 0.3, 0.35)}, 
]
const GRADE_MIN_REFINE: = 10





const GEAR_GRADES: = {
	"armor": {"keys": ["grade_hp"], "vals": [0.0, 0.05, 0.1, 0.15, 0.22, 0.3]}, 
	"shield": {"keys": ["grade_mech"], "vals": [0.0, 0.03, 0.06, 0.09, 0.12, 0.15]}, 
	"garment": {"keys": ["grade_hit"], "vals": [0.0, 0.03, 0.06, 0.09, 0.12, 0.15]}, 
	"shoes": {"keys": ["move"], "vals": [0.0, 0.02, 0.04, 0.06, 0.08, 0.1]}, 
	"head": {"keys": ["grade_haste"], "vals": [0.0, 0.02, 0.04, 0.06, 0.08, 0.1]}, 
	"acc": {"keys": ["xp", "loot", "card"], "vals": [0.0, 0.05, 0.1, 0.15, 0.2, 0.25]}, 
}


const GEAR_GRADE_COST: = {"weapon": 1.0, "acc": 0.25}
const GEAR_GRADE_COST_DEFAULT: = 0.5





const GRADE_PITY: = 0.025
const GRADE_CHANCE_MAX: = 0.75
const GRADE_PITY_MAX: = 40
# [MOD] Grade success boost, one multiplier per TARGET tier (index 1..5 = D C B A S over
# WEAPON_GRADES[].chance = .90 / .70 / .50 / .35 / .25). Applied inside grade_chance() below, so the roll,
# the "% de éxito" label, the post-failure hint and the hover-card pity delta all move together. Result:
# D 90% (unchanged), C 80.5%, B 75%, A 70%, S 65% - still monotone, still paid for in ore and zeny, but the
# expected attempts for an S drop from ~3.3 to ~1.6. MOD_GRADE_CAP leaves headroom for the shipped pity.
const MOD_GRADE_MULT: = [1.0, 1.15, 1.5, 2.0, 2.6]
const MOD_GRADE_CAP: = 0.85







const HARMONY_SLOTS: = ["armor", "shield", "garment", "shoes", "head", "acc1", "acc2"]
const HARMONY_MIN_PIECES: = 5
const HARMONY_SHARE: = [0.0, 0.03, 0.06, 0.1, 0.15, 0.2]



static func grade_chance(g: int, pity: int) -> float:
	var base: = float(WEAPON_GRADES[clampi(g, 1, WEAPON_GRADES.size() - 1)].chance)
	# [MOD] boost the base BEFORE the shipped pity line; the outer maxf() below then uses the boosted value
	# as its floor, which is what lets the boost exceed GRADE_CHANCE_MAX (0.75) where the raw table was lower.
	base = maxf(base, minf(MOD_GRADE_CAP, base * float(MOD_GRADE_MULT[clampi(g, 1, MOD_GRADE_MULT.size()) - 1])))
	return maxf(base, minf(base + GRADE_PITY * clampi(pity, 0, GRADE_PITY_MAX), GRADE_CHANCE_MAX))




static func grade_value(kind: String, g: int) -> float:
	if g <= 0:
		return 0.0
	if kind == "weapon":
		return float(WEAPON_GRADES[mini(g, WEAPON_GRADES.size() - 1)].dmg)
	return float(GEAR_GRADES.get(kind, {}).get("vals", [0.0, 0.0, 0.0, 0.0, 0.0, 0.0])[mini(g, 5)])




static func grade_pct(v: float) -> String:
	var p: = v * 100.0
	return _grade_num(str(roundi(p)) if absf(p - roundi(p)) < 0.05 else "%.1f" % p)


static func _grade_num(s: String) -> String:
	return s.replace(".", ",") if TranslationServer.get_locale().substr(0, 2) in ["es", "pt", "ru", "de", "fr"] else s




static func grade_total_text(kind: String, v: float) -> String:
	match kind:
		"weapon", "armor", "head":
			return "x" + _grade_num("%.2f" % (1.0 + v))
		"shield", "garment":
			return "-%s%%" % grade_pct(v)
	return "+%s%%" % grade_pct(v)




static func grade_step_text(kind: String, g: int, share: = 0.0) -> String:
	var from: String = str(WEAPON_GRADES[g - 1].name) if g > 1 else str(TranslationServer.translate("sin grado"))
	var step: = (grade_value(kind, g) - grade_value(kind, g - 1)) * (1.0 + share)
	return TranslationServer.translate("%s → %s: +%s%% más · total %s") % [from, str(WEAPON_GRADES[g].name), grade_pct(step), 
		grade_total_text(kind, grade_value(kind, g) * (1.0 + share))]






static func grade_cost(kind: String, g: int) -> Dictionary:
	var base: Dictionary = WEAPON_GRADES[g]
	var k: = float(GEAR_GRADE_COST.get(kind, GEAR_GRADE_COST_DEFAULT))
	var hd: = int(base.get("hd", 0))
	var ore: = "oridecon" if kind == "weapon" else "elunium"
	return {"ore": ore, "hd_ore": "hd_" + ore, "ori": maxi(1, roundi(float(base.ori) * k)), "hd": maxi(1, roundi(hd * k)) if hd > 0 else 0, 
		"zeny": roundi(float(base.zeny) * k / 1000.0) * 1000, "chance": float(base.chance)}



static func grade_text(kind: String, g: int) -> String:
	if g <= 0:
		return ""
	if kind == "weapon":
		return TranslationServer.translate("todo el daño x%s") % _grade_num("%.2f" % (1.0 + float(WEAPON_GRADES[g].dmg)))
	var v: = float(GEAR_GRADES.get(kind, {}).get("vals", [0.0])[mini(g, 5)])
	var pct: = roundi(v * 100.0)
	match kind:
		"armor":
			return TranslationServer.translate("vida máxima x%s") % _grade_num("%.2f" % (1.0 + v))
		"shield":
			return TranslationServer.translate("-%d%% de daño de las mecánicas de los MVP") % pct
		"garment":
			return TranslationServer.translate("-%d%% de daño de golpes y proyectiles") % pct
		"shoes":
			return TranslationServer.translate("+%d%% de velocidad de movimiento") % pct
		"head":
			return TranslationServer.translate("recargas x%s más rápidas") % _grade_num("%.2f" % (1.0 + v))
		"acc":
			return TranslationServer.translate("+%d%% de EXP, zeny y probabilidad de carta") % pct
	return ""







const TRANSMUTE: = [
	{"from": "oridecon", "to": "enriched_oridecon", "n": 10}, 
	{"from": "elunium", "to": "enriched_elunium", "n": 10}, 
	{"from": "enriched_oridecon", "to": "hd_oridecon", "n": 5}, 
	{"from": "enriched_elunium", "to": "hd_elunium", "n": 5}, 


	{"from": "oridecon", "to": "elunium", "n": 1, "tab": "swap"}, 
	{"from": "elunium", "to": "oridecon", "n": 1, "tab": "swap"}, 
	{"from": "enriched_oridecon", "to": "oridecon", "n": 1, "out": 10, "tab": "down"}, 
	{"from": "enriched_elunium", "to": "elunium", "n": 1, "out": 10, "tab": "down"}, 
	{"from": "hd_oridecon", "to": "enriched_oridecon", "n": 1, "out": 5, "tab": "down"}, 
	{"from": "hd_elunium", "to": "enriched_elunium", "n": 1, "out": 5, "tab": "down"}, 
]


const HD_BONUS: = 0.55



const REFINE_RICH_FROM: = 7
const ENRICHED_BONUS: = 0.3




const REFINE_AUTO_MIN: = 0.5

const REFINE_FEE: = {"w1": 100, "w2": 300, "w3": 600, "w4": 1000, "armor": 500}



const REFINE_PROTECT_MULT: = 5.0



const REFINE_FEE_MULT: = 5.0
const REFINE_FEE_GROWTH: = 1.4

const BOSS_ENRICHED_CHANCE: = 0.15
const MVP_ENRICHED: = 1
const MVP_HD_CHANCE: = 0.05


const MVP_COIN_CHANCE: = 0.03



const MOB_COIN_CHANCE: = 4e-05
const MOB_COIN_MAX: = 3










const REROLL_REFILL_FROM: = 100
const REROLL_REFILL_EVERY: = 50
const SAGE_UPGRADES: = {
	"magnifier": {"name": "Magnifier", "desc": "+1 reroll por partida por cada nivel de la mejora: vuelve a tirar las opciones al subir de nivel (R). Al máximo: 5 rerolls. Pasado el nivel 100, cada 50 niveles vuelven a llegar.", 
		"max": 5, "cost": 3000}, 
	"sage_book": {"name": "Libro del Sabio", "desc": "+1 opción más para elegir en cada subida de nivel.", 
		"max": 1, "cost": 12000}, 
	"fly_wing": {"name": "Holy Water", "desc": "+1 destierro por partida por cada nivel de la mejora: quitas una opción y no vuelve en esa partida. Al máximo: 20 destierros.", 
		"max": 20, "cost": 3500}, 
	"sage_start": {"name": "Old Blue Box", "desc": "Empiezas cada partida eligiendo una mejora, como al subir de nivel; +1 elección por cada nivel de la mejora. Al máximo: 2 elecciones.", 
		"max": 2, "cost": 8000}, 
	"passive_slot": {"name": "Secreto de las Runas", "desc": "+1 hueco de pasiva en cada partida por cada nivel de la mejora. Al máximo: +2 pasivas.", 
		"max": 2, "cost": 15000}, 



	"kafra_walk": {"name": "Kafra ambulante", "icon": "kafra_cart", 
		"desc": "Nv 1: una Kafra aparece cada 4 min en el mapa y te ofrece 3 ayudas para la partida (elige una). Nv 2: +1 opción. Nv 3: cada 3 min. Nv 4: ayudas más fuertes. Nv 5: cada 2 min y medio.", 
		"max": 5, "cost": 9000}, 
	"sage_root": {"name": "Raíz de la Vida", "icon": "tree_root", 
		"desc": "Cada monstruo que derrotas te da +1 de vida máxima durante la partida, sin límite: +1 por muerte las primeras 250 por cada nivel de la mejora y después +3 cada 10. Al máximo: las primeras 1250.", 

		"max": 5, "cost": 4000, "per_level": 250, "slow_every": 10.0 / 3.0}, 
}






const RUN_FAV_MAX: = 2
const RUN_FAV_WEIGHT: = 2.0


func sage_cost(id: String, level: int) -> int:
	return int(round(SAGE_UPGRADES[id].cost * pow(level + 1, UPGRADE_COST_POW) / 10.0) * 10)














const PACTS: = {


	"frenzy": {"name": "Pacto de Furia", "icon": "pact_frenzy", "tab": "basic", 
		"desc": "+40% velocidad de ataque (ASPD) del ataque básico.", "mods": {"aspd": 0.4}}, 
	"might": {"name": "Pacto de Fuerza", "icon": "pact_might", "unlock": 3, "tab": "basic", 
		"desc": "+75% daño del ataque básico y de los procs de cartas y equipo.", "mods": {"basic_dmg": 0.75, "proc_dmg": 0.75}}, 

	"twin": {"name": "Pacto de los Gemelos", "icon": "pact_twin", "unlock": 5, "tab": "basic", 
		"desc": "+60% de probabilidad de golpe doble del ataque básico cuerpo a cuerpo y con armas de fuego; cada golpe extra también lanza los procs. Se suma a Double Attack: pasado el 100%, golpe triple.", 
		"effects": {"double": 0.6}}, 
	"solitude": {"name": "Pacto de Soledad", "icon": "pact_solitude", "unlock": 11, "tab": "basic", 
		"desc": "Por cada ranura sin habilidades de ataque, tu ataque básico golpea a 1 enemigo más, su área crece, pega un 12% más y tiene +4% de crítico. Los buffs, curas, escudos y apoyos (Lex Aeterna, Signum Crucis...) no ocupan su lugar.", 
		"per_free": {"targets": 1, "area": 0.5, "basic_dmg": 0.12, "crit": 0.04}}, 
	"echo": {"name": "Pacto del Eco", "icon": "pact_echo", "unlock": 1, "tab": "procs", 
		"desc": "Las habilidades que lanzan tus cartas y tu equipo con tu ataque básico salen un 60% más seguido (también Hindsight y Preserve).", 
		"effects": {"proc_chance": 0.6}}, 
	"overload": {"name": "Pacto de Sobrecarga", "icon": "pact_overload", "unlock": 9, "tab": "procs", 
		"desc": "Las habilidades que lanzan tus cartas y tu equipo por su cuenta, al atacar y al recibir golpes, pegan un 90% más.", 
		"effects": {"proc_power": 0.9}}, 
	"shepherd": {"name": "Pacto del Pastor", "icon": "pact_shepherd", "unlock": 1, "tab": "summon", 
		"desc": "Tus invocaciones (espíritus, homúnculos, plantas...) y tu halcón pegan un 120% más.", 
		"effects": {"summon_dmg": 1.2, "falcon_dmg": 1.2}}, 

	"bond": {"name": "Pacto del Vínculo", "icon": "pact_bond", "unlock": 5, "tab": "summon", 
		"desc": "Tus invocaciones (espíritus, homúnculos, plantas...) pegan un 60% más a jefes y élites, y cada golpe suyo te cura un 0,1% de tu vida máxima (hasta 5 veces por segundo).", 
		"effects": {"summon_boss": 0.6, "summon_leech": 0.001}}, 
	"pack": {"name": "Pacto de la Manada", "icon": "pact_pack", "unlock": 13, "tab": "summon", 
		"desc": "+1 espíritu a la vez (Doram), +1 homúnculo a la vez (Alquimista), el halcón se lanza solo un 15% más seguido (Hunter) y tus invocaciones y tu halcón pegan un 25% más.", 
		"effects": {"summon_count": 1.0, "homun_extra": 1.0, "auto_blitz": 0.15, "summon_dmg": 0.25, "falcon_dmg": 0.25}}, 
	"venom": {"name": "Pacto Venenoso", "icon": "pact_venom", "unlock": 2, "tab": "ills", 
		"desc": "Cada golpe de tu ataque básico envenena (un 30% de su daño, acumulable) y todo tu veneno pega un 40% más.", 
		"effects": {"poison_hit": 0.3, "poison_dmg": 0.4}}, 
	"blood": {"name": "Pacto de Sangre", "icon": "pact_blood", "unlock": 4, "tab": "ills", 
		"desc": "Tu ataque básico hace sangrar un 30% de las veces y tus sangrados pegan un 60% más.", 
		"effects": {"bleed_hit": 0.3, "bleed_power": 0.6}}, 
	"ashes": {"name": "Pacto de Cenizas", "icon": "pact_ashes", "unlock": 6, "tab": "ills", 
		"desc": "Tu ataque básico quema un 25% de las veces; tus quemaduras pegan un 60% más y duran un 30% más.", 
		"effects": {"burn_hit": 0.25, "burn_power": 0.6, "burn_time": 0.3}}, 

	"agony": {"name": "Pacto de la Agonía", "icon": "pact_agony", "unlock": 15, "tab": "ills", 
		"desc": "Todo tu daño (ataque básico, habilidades y procs) es un 12% mayor contra un monstruo por cada mal que sufre: envenenado, quemado o sangrando (hasta ×1,36).", 
		"per_ill": 0.12}, 

	"elements": {"name": "Pacto de los Elementos", "icon": "pact_elements", "unlock": 4, "tab": "elements", 
		"desc": "Tus habilidades mágicas de Fuego, Agua, Viento y Tierra combinan como las del Wizard: una marca al monstruo y un golpe de otro elemento la hace estallar. Las reacciones pegan un 25% más.", 
		"effects": {"combo_dmg": 0.25}}, 
	"affinity": {"name": "Pacto de la Afinidad", "icon": "pact_affinity", "unlock": 8, "tab": "elements", 
		"desc": "+50% de daño cuando tu elemento es fuerte contra el del monstruo (también con los combos de estado: congelado y Viento, petrificado y Fuego).", 
		"effects": {"weak_bonus": 0.5}}, 
	"glacial": {"name": "Pacto Glacial", "icon": "pact_glacial", "unlock": 10, "tab": "elements", 
		"desc": "+15% de probabilidad de que tus habilidades congelen, petrifiquen o aturdan, y esos estados duran un 50% más. +20% de daño a monstruos con un estado alterado.", 
		"effects": {"status_chance": 0.15, "status_time": 0.5, "status_vuln": 0.2}}, 
	"devotion": {"name": "Pacto de Devoción", "icon": "pact_devotion", "unlock": 3, "tab": "single", 
		"desc": "Por cada ranura sin habilidades de ataque, tus habilidades de ataque pegan un 20% más, recargan un 8% más rápido y su área crece un 10%. Los buffs, curas, escudos y apoyos (Lex Aeterna, Signum Crucis...) no ocupan su lugar.", 
		"per_free": {"skill_dmg": 0.2, "haste": 0.08, "area": 0.1}}, 
	"obsession": {"name": "Pacto de la Obsesión", "icon": "pact_obsession", "unlock": 12, "tab": "single", 
		"desc": "Si llevas una sola habilidad de ataque, un 40% de las veces se lanza dos veces.", 
		"double_cast": 0.4}, 
	"retaliation": {"name": "Pacto de Represalia", "icon": "pact_retaliation", "unlock": 7, "tab": "procs", 
		"desc": "Tus autocasts al recibir golpes salen un 60% más seguido y la vida máxima los potencia el doble (×1,5 con 700, ×2 con 2500, ×3,5 con 15000).", 
		"retaliate": {"chance": 0.6, "hp_root": 0.02}}, 



	"counter": {"name": "Pacto del Contraataque", "icon": "pact_counter", "unlock": 5, "tab": "retaliate", 
		"desc": "Un 25% de los golpes que recibes (la mitad de un MVP) no te hacen nada: tu arma responde al instante con un crítico seguro de 6 veces tu ataque básico (como mucho una vez cada 0,5 s).", 
		"effects": {"auto_counter": 0.25, "counter_dmg": 4.0}}, 


	"vengeance": {"name": "Pacto de Venganza", "icon": "pact_vengeance", "unlock": 14, "tab": "retaliate", 
		"desc": "Cada golpe que recibes (como mucho uno cada 0,5 s) te da un 8% más de daño durante 6 s, acumulable hasta ×1,80.", 
		"vengeance": {"per": 0.08, "time": 6.0, "max": 10}}, 




	"hammer": {"name": "Pacto del Martillo", "icon": "pact_hammer", "unlock": 6, "tab": "stagger", 
		"desc": "Cada golpe de tu ataque básico y de tus habilidades llena el Aguante 0,5 s (cada una como mucho cada 0,5 s): rompes jefes sin estados. Los élites tienen Aguante desde Peligro 1.", 
		"effects": {"stagger_hit": 0.5, "stagger_elites": 1.0}}, 
	"yoke": {"name": "Pacto del Yugo", "icon": "pact_yoke", "unlock": 9, "tab": "stagger", 
		"desc": "Llenas el Aguante un 60% más rápido, y tus debilitamientos también lo llenan, 2 s cada uno (como mucho cada 3 s en cada monstruo): Signum Crucis, Lex Aeterna y Provoke. Los élites tienen Aguante desde Peligro 1.", 
		"effects": {"wing_fill": 0.6, "stagger_debuff": 2.0, "stagger_elites": 1.0}}, 
	"rupture": {"name": "Pacto de la Ruptura", "icon": "pact_rupture", "unlock": 12, "tab": "stagger", 
		"desc": "Un jefe aturdido por el Aguante recibe un 50% más de tu daño (además del 30% de siempre), el aturdimiento dura 1 s más y cada vez que rompes un Aguante tus habilidades recuperan un 20% de su recarga. Los élites tienen Aguante desde Peligro 1.", 
		"effects": {"wing_broken": 0.5, "wing_stun": 1.0, "wing_break_cd": 0.2, "stagger_elites": 1.0}}, 



	"grace": {"name": "Pacto de la Gracia", "icon": "pact_grace", "unlock": 2, "tab": "support", 
		"desc": "Solo en las habilidades de tu clase o copiadas con Plagiarism: +40% potencia de bufos, +40% a sus curaciones y escudos, y sus debilitamientos son un 50% más fuertes: la debilidad de Signum Crucis, la marca de Lex Aeterna (lo que pasa de x1) y la vulnerabilidad de Provoke EX.", 
		"effects": {"grace_buff": 0.4, "grace_heal": 0.4, "grace_shield": 0.4, "grace_debuff": 0.5}}, 
	"chorus": {"name": "Pacto del Coro", "icon": "pact_chorus", "unlock": 7, "tab": "support", 
		"desc": "Tus canciones y danzas pegan un 80% más y su Bis llega cada 3 compases en vez de cada 4 (más Bis: más bufos de grupo y más gritos).", 
		"effects": {"song_dmg": 0.8, "bis_faster": 1.0}}, 
}

const PACT_TABS: = [
	{"id": "basic", "name": "Ataque básico", "desc": "Para quien pelea con su arma: más golpes, más rápidos y más fuertes."}, 
	{"id": "procs", "name": "Procs", "desc": "Para las cartas y el equipo que lanzan habilidades por su cuenta, al atacar o al recibir golpes."}, 
	{"id": "summon", "name": "Invocaciones", "desc": "Espíritus, homúnculos, plantas y halcones: que ellos peleen por ti."}, 
	{"id": "ills", "name": "Estados", "desc": "Veneno, sangrado y quemaduras: el daño que sigue cuando ya pasaste."}, 
	{"id": "elements", "name": "Elementos", "desc": "Combos elementales, debilidades y monstruos congelados o petrificados."}, 
	{"id": "single", "name": "Una habilidad", "desc": "Para quien juega con una sola habilidad de ataque y la lleva al límite."}, 
	{"id": "retaliate", "name": "Represalia", "desc": "Para los que aguantan: cada golpe que recibes se devuelve."}, 
	{"id": "stagger", "name": "Aguante", "desc": "Para romper jefes y élites: llena su Aguante, atúrdelos y golpéalos mientras caen."}, 
	{"id": "support", "name": "Apoyo", "desc": "Para los que cuidan y debilitan: bufos, curaciones, escudos, marcas y canciones."}, 
]






const SOLITUDE_FREE_TYPES: = ["buff", "heal", "shield", "steal", "mirror", "lex", "signum", "fury", "mild_wind", "steel_body", "union", "sacrifice", "heat"]


func pact_unlocked(id: String) -> bool:
	var need: = int(PACTS[id].get("unlock", 0))
	return need <= 0 or Save.max_danger() > need





const MAX_PACTS: = 3

const CARD_SELL_ZENY: = 120





const EQUIP_SLOTS: = ["head", "mid", "low", "armor", "weapon", "garment", "shoes", "acc1", "acc2", "shield", "wings", "soul"]
const SLOT_NAMES: = {"head": "Cabeza", "mid": "Cara superior", "low": "Cara inferior", "armor": "Armadura", "weapon": "Arma", "garment": "Prenda", 
	"shoes": "Calzado", "acc1": "Accesorio", "acc2": "Accesorio", "shield": "Escudo", "wings": "Alas", "soul": "Alma", 


	"acc": "Accesorio"}



const SHIELD_CLASSES: = ["swordsman", "mage", "thief", "acolyte", "merchant", "super_novice", "doram", "taekwon"]



const SHIELD_JOBS: = ["bard", "clown"]


const SHIELD_GEAR_CLASSES: = ["swordsman", "mage", "thief", "acolyte", "merchant", "super_novice", "doram", "taekwon", "archer"]





const DUAL_JOBS: = ["assassin", "assassin_cross", "kagerou"]
const OFFHAND_KINDS: = ["dagger", "sword", "axe"]

const TWO_HANDED_KINDS: = ["bow", "instrument", "gun", "katar", "huuma", "axe2", "sword2"]

const PRESERVE_CD: = 0.4



const WEAPON_KINDS: = {
	"sword": "sword", "blade": "sword", "cutlass": "sword", "fire_brand": "sword", "ice_falchion": "sword", 
	"excalibur": "sword", "sacred_excalibur": "sword2", "holy_avenger": "sword", "sucsamad": "sword", "crescent_scythe": "spear", 
	"pike": "spear", "trident": "spear", "glaive": "spear", "partizan": "spear", "gungnir": "spear", 
	"slayer": "sword2", "bastard_sword": "sword2", "two_handed_sword": "sword2", "dragon_slayer": "sword2", 
	"rod": "rod", "wand": "rod", "arc_wand": "rod", "staff": "rod", "wand_of_occult": "rod", "staff_of_destruction": "rod", "lich_wand": "rod", 
	"encyclopedia": "book", "bishop_bible": "book", "reaper_ledger": "book", "chained_souls": "book", "book_billows": "book", "book_gust": "book", 
	"book_earth": "book", "book_sun": "book", "book_dragon": "book", 
	"bow": "bow", "composite_bow": "bow", "gakkung_bow": "bow", "great_bow": "bow", "arbalest": "bow", "hunter_bow": "bow", "rudra_bow": "bow", "falken_blitz": "bow", 
	"storm_bow": "bow", "electric_guitar": "instrument", "bragi_lyre": "instrument", "dancer_whip": "whip", 
	"knife": "dagger", "stiletto": "dagger", "damascus": "dagger", "venom_knife": "dagger", "grimtooth": "dagger", 
	"assassin_dagger": "dagger", "moonlight_dagger": "dagger", "kagekiri": "ninja_dagger", "kamaitachi": "ninja_dagger", 
	"katar": "katar", "jur": "katar", "jamadhar": "katar", 
	"club": "mace", "mace": "mace", "morning_star": "mace", "chain": "mace", "stunner": "mace", "mjolnir": "mace", 
	"golden_mace": "mace", "paracelsus_mace": "mace", "hammer": "mace", "kaiser_knuckle": "knuckle", "hurricane_fury": "knuckle", "berserk_knuckle": "knuckle", 

	"mysteltainn": "sword", "mighty_staff": "rod", "ballista": "bow", "roguemaster_bow": "bow", "quadrille": "mace", "golden_axe": "axe", "dwarven_hammer": "mace", 
	"ginnungagap": "dagger", "murasame": "ninja_dagger", 
	"axe": "axe", "battle_axe": "axe", "tomahawk": "axe", "orcish_axe": "axe", 
	"buster": "axe2", "great_axe": "axe2", "bloody_axe": "axe2", 
}





const JOB_WEAPON_KINDS: = {

	"super_novice": ["dagger", "sword", "axe", "mace", "rod"], 
	"swordsman": ["sword", "sword2"], "knight": ["sword", "sword2", "spear"], "lord_knight": ["sword", "sword2", "spear"], 
	"crusader": ["sword", "sword2", "spear"], "paladin": ["sword", "sword2", "spear"], 
	"mage": ["rod"], "wizard": ["rod"], "high_wizard": ["rod"], 
	"sage": ["rod", "book"], "professor": ["rod", "book"], 
	"archer": ["bow"], "hunter": ["bow"], "sniper": ["bow"], 
	"bard": ["bow", "instrument", "whip"], "clown": ["bow", "instrument", "whip"], 
	"thief": ["dagger", "bow"], "assassin": ["katar", "dagger", "sword", "axe"], "assassin_cross": ["katar", "dagger", "sword", "axe"], 




	"rogue": ["dagger", "sword", "bow"], "stalker": ["dagger", "sword", "bow"], 
	"acolyte": ["mace"], "priest": ["mace"], "high_priest": ["mace"], 
	"monk": ["knuckle"], "champion": ["knuckle"], 
	"merchant": ["axe", "mace"], "blacksmith": ["axe", "axe2", "mace"], "whitesmith": ["axe", "axe2", "mace"], 
	"alchemist": ["axe", "mace"], "creator": ["axe", "mace"], 
	"gunslinger": ["gun"], "rebellion": ["gun"], 
	"ninja": ["dagger", "ninja_dagger", "huuma"], "kagerou": ["dagger", "ninja_dagger", "huuma"], 


	"taekwon": [], "star_gladiator": [], "soul_linker": ["book"], 

	"doram": ["rod"], "spirit_handler": ["rod"], 
}

const TAEKWON_WEAPON: = {"": "fists", "star_gladiator": "star_fists", "soul_linker": "book_billows"}


const WEAPON_KIND_ATTACK: = {
	"dagger": {"aspd": 6.0, "dmg": 0.9, "reach": -0.2}, 
	"ninja_dagger": {"aspd": 6.0, "dmg": 0.92, "reach": -0.2}, 
	"sword": {"aspd": 0.0, "dmg": 1.0, "reach": 0.0}, 
	"spear": {"aspd": -4.0, "dmg": 1.06, "reach": 0.9}, 
	"sword2": {"aspd": -8.0, "dmg": 1.2, "reach": 0.35}, 
	"axe": {"aspd": -5.0, "dmg": 1.12, "reach": 0.1}, 
	"axe2": {"aspd": -10.0, "dmg": 1.26, "reach": 0.3}, 
	"mace": {"aspd": -2.0, "dmg": 1.06, "reach": 0.0}, 
	"katar": {"aspd": 2.0, "dmg": 1.0, "reach": 0.0}, 
	"knuckle": {"aspd": 8.0, "dmg": 0.92, "reach": -0.3}, 
	"rod": {"aspd": 0.0, "dmg": 1.0, "reach": 0.0}, 
	"book": {"aspd": -3.0, "dmg": 1.1, "reach": 0.0}, 
	"instrument": {"aspd": 0.0, "dmg": 1.0, "reach": 0.0}, 
	"whip": {"aspd": 2.0, "dmg": 1.0, "reach": 0.0}, 
}








const JOB_WEAPON_SPRITES: = {
	"swordsman": {"sword2": ["weapon_sword2", "weapon_sword2_slash", 10]}, 
	"knight": {"spear": ["weapon_knight_spear", "weapon_knight_spear_slash", 11], "sword2": ["weapon_knight_sword2", "weapon_knight_sword2_slash", 10]}, 
	"crusader": {"spear": ["weapon_crusader_spear", "weapon_crusader_spear_slash", 11], "sword2": ["weapon_crusader_sword2", "weapon_crusader_sword2_slash", 10]}, 
	"sage": {"book": ["weapon_sage_book", "", 11]}, 
	"bard": {"instrument": ["weapon_bard_instrument", "", 10], "whip": ["weapon_bard_whip", "", 10]}, 
	"rogue": {"sword": ["weapon_rogue_sword", "weapon_rogue_sword_slash", 10], "bow": ["weapon_rogue_bow", "", 10]}, 
	"thief": {"bow": ["weapon_thief_bow", "", 10]}, 
	"merchant": {"mace": ["weapon_merchant_mace", "weapon_merchant_mace_slash", 10]}, 
	"blacksmith": {"axe": ["weapon_blacksmith_axe1", "weapon_blacksmith_axe1_slash", 11], "mace": ["weapon_blacksmith_mace", "", 11]}, 
	"alchemist": {"mace": ["weapon_alchemist_mace", "", 11]}, 
	"ninja": {"huuma": ["weapon_ninja_huuma", "", 11]}, 
	"kagerou": {"huuma": ["weapon_kagerou_huuma", "", 11]}, 
	"super_novice": {"sword": ["weapon_sn_sword", "weapon_sn_sword_slash", 11], "axe": ["weapon_sn_axe", "weapon_sn_axe_slash", 11], 
		"mace": ["weapon_sn_mace", "weapon_sn_mace_slash", 11], "rod": ["weapon_sn_rod", "weapon_sn_rod_slash", 11]}, 
	"hyper_novice": {"sword": ["weapon_hn_sword", "weapon_hn_sword_slash", 11], "axe": ["weapon_hn_axe", "weapon_hn_axe_slash", 11], 
		"mace": ["weapon_hn_mace", "weapon_hn_mace_slash", 11], "rod": ["weapon_hn_rod", "weapon_hn_rod_slash", 11]}, 
}





const GUN_LOOKS: = {"rifle": "rifle", "lever_action_rifle": "rifle", "juperos_railgun": "rifle", 
	"single_shotgun": "shotgun", "destroyer": "shotgun", "avenger_gatling": "gatling"}
const GUN_SOUNDS: = {"rifle": "gun_rifle", "shotgun": "gun_shotgun", "gatling": "gun_gatling"}
const TRANS_OF: = {"lord_knight": "knight", "paladin": "crusader", "professor": "sage", "clown": "bard", 
	"stalker": "rogue", "whitesmith": "blacksmith", "creator": "alchemist", "assassin_cross": "assassin", 
	"high_wizard": "wizard", "sniper": "hunter", "high_priest": "priest", "champion": "monk"}



func poison_grow_top(cap: float) -> float:
	return POISON_GROW_MAX * (1.0 + POISON_GROW_PER_CAP * cap)




const TWO_HANDED_BONUS: = 0.5


func two_handed(id: String) -> bool:
	return weapon_kind(id) in TWO_HANDED_KINDS



const WEAPON_KIND_NAMES: = {"sword": "Espada", "sword2": "Espada a dos manos", "dagger": "Daga", "axe": "Hacha", 
	"axe2": "Hacha a dos manos", "mace": "Maza", "rod": "Bastón", "book": "Libro", "spear": "Lanza", "katar": "Katar", 
	"knuckle": "Nudillos", "bow": "Arco", "instrument": "Instrumento", "whip": "Látigo", "ninja_dagger": "Daga ninja", "huuma": "Huuma", 
	"gun": "Arma de fuego"}





func weapon_class_words(id: String) -> Array:
	var d: Dictionary = ITEMS.get(id, {})
	if d.has("fists"):
		return ["Cuerpo a cuerpo", "Puños"]
	var k: = weapon_kind(id)
	if k == "gun":
		return ["Arma de fuego"]
	var ranged: = k in ["bow", "instrument", "whip"]
	if k == "" and CLASSES.has(str(d.get("class", ""))):
		ranged = bool(CLASSES[str(d. class )].basic.get("ranged", false))
	var out: = ["A distancia" if ranged else "Cuerpo a cuerpo"]
	if WEAPON_KIND_NAMES.has(k):
		out.append(WEAPON_KIND_NAMES[k])


	if not k in ["sword2", "axe2"]:

		out.append("Dos manos" if two_handed(id) or str(d.get("weapon_type", "")) == "katar" else "Una mano")
	return out


func weapon_kind(id: String) -> String:
	if WEAPON_KINDS.has(id):
		return WEAPON_KINDS[id]


	if str(ITEMS.get(id, {}).get("weapon_type", "")) == "katar":
		return "katar"
	return "huuma" if id.begins_with("huuma") else ("gun" if str(ITEMS.get(id, {}).get("class", "")) == "gunslinger" else "")





func weapon_allowed(class_id: String, job_id: String, id: String) -> bool:
	var d: Dictionary = ITEMS[id]
	if d.has("job") and not (d.job as Array).has(job_id):
		return false
	if (d.get("not_job", []) as Array).has(job_id):
		return false


	if str(d.get("class", "")) == class_id or (d.get("also_class", []) as Array).has(class_id):
		return true
	var who: = job_id if job_id != "" and JOB_WEAPON_KINDS.has(job_id) else class_id
	return (JOB_WEAPON_KINDS.get(who, []) as Array).has(weapon_kind(id))




func weapon_for_line(class_id: String, id: String) -> bool:
	if weapon_allowed(class_id, "", id):
		return true
	for path in job_paths(class_id):
		for job in [path, path.get("trans", {})]:
			if not (job as Dictionary).is_empty() and weapon_allowed(class_id, str(job.id), id):
				return true
	return false
const OFFHAND_SHARE: = 0.5


const SHIELD_NO_JOBS: = ["blacksmith", "whitesmith"]

const BLOCK_PER_REFINE: = 0.015
const BLOCK_MAX: = 0.6


const SHIELD_RANK_DMG: = 0.15

















const ITEMS: = {

	"sword": {"name": "Sword", "slot": "weapon", "class": "swordsman", "rank": 1, "icon": "sword", 
		"mods": {"dmg": 0.08}, "refine": {"dmg": 0.05}}, 
	"blade": {"name": "Blade", "slot": "weapon", "class": "swordsman", "rank": 2, "icon": "blade", 
		"mods": {"dmg": 0.12, "aspd": 0.06}, "refine": {"dmg": 0.05}}, 
	"cutlass": {"name": "Cutlass", "slot": "weapon", "class": "swordsman", "rank": 2, "icon": "cutlass", 
		"mods": {"dmg": 0.12, "crit": 0.05}, "refine": {"dmg": 0.05}}, 
	"fire_brand": {"element": "fire", "name": "Fire Brand", "slot": "weapon", "class": "swordsman", "rank": 3, "icon": "fire_brand", 
		"mods": {"dmg": 0.14}, "refine": {"dmg": 0.05}, 
		"proc": {"skill": "fire_bolt", "chance": 0.08}, 
		"desc": "Arma de Fuego. 8% con el ataque básico: lanza Fire Bolt ×Lv."}, 
	"ice_falchion": {"element": "water", "name": "Ice Falchion", "slot": "weapon", "class": "swordsman", "rank": 3, "icon": "ice_falchion", 
		"mods": {"dmg": 0.14}, "refine": {"dmg": 0.05}, 
		"proc": {"skill": "cold_bolt", "chance": 0.08}, 
		"desc": "Arma de Agua. 8% con el ataque básico: lanza Cold Bolt ×Lv."}, 


	"excalibur": {"name": "Masamune", "slot": "weapon", "class": "swordsman", "legendary": true, "icon": "masamune", 
		"mods": {"dmg": 0.3, "aspd": 0.15, "dodge": 0.08}, "refine": {"dmg": 0.05}, "effects": {"splash": 1.8, "lg_masamune": 1.0}, 
		"desc": "Legendaria: cada ataque básico golpea en área. La katana de la leyenda, rápida y esquiva: +15% de velocidad de ataque y +8% de evasión. Mente serena: cada golpe que esquivas responde al instante con un corte desenvainado a tu alrededor (250% de tu ataque básico, como mucho uno cada 0,3 s), y cada corte seguido sin recibir un golpe corta un 25% más, hasta +100%."}, 
	"sacred_excalibur": {"name": "Excalibur", "slot": "weapon", "class": "swordsman", "unique": true, "legendary": true, "stage": "glast", "icon": "excalibur", 
		"mods": {"dmg": 0.3}, "refine": {"dmg": 0.05}, "effects": {"splash": 1.8, "u_excalibur": 1.0}, 
		"desc": "Única del Dark Lord: cada ataque básico golpea en área. Tus habilidades juntan luz en la hoja: cada una que lanzas sube la carga (8 niveles, la espada dorada bajo tus pies) y guarda su golpe más fuerte. R la libera: Excaliblast, una ola de luz dorada que cruza el mapa abriéndose a su paso, hacia donde hay más monstruos (los MVP y los jefes primero), y descarga toda la luz en cada monstruo que alcanza: x1 con el nivel 1, hasta x10 con el 8. Y los deja ardiendo: una quemadura que los va derritiendo poco a poco."}, 


	"pike": {"name": "Pike", "slot": "weapon", "class": "swordsman", "job": ["knight", "lord_knight", "crusader", "paladin"], "rank": 2, "purple": true, "icon": "pike", 
		"mods": {"dmg": 0.13, "area": 0.06}, "refine": {"dmg": 0.05}, "desc": "Lanza: con ella en la mano, tus habilidades de lanza hacen ×1,2 de daño."}, 
	"trident": {"element": "water", "name": "Trident", "slot": "weapon", "class": "swordsman", "job": ["knight", "lord_knight", "crusader", "paladin"], "rank": 2, "purple": true, "icon": "trident", 
		"mods": {"dmg": 0.13, "crit": 0.05}, "refine": {"dmg": 0.05}, "desc": "Arma de Agua. Lanza: con ella en la mano, tus habilidades de lanza hacen ×1,2 de daño."}, 
	"glaive": {"name": "Glaive", "slot": "weapon", "class": "swordsman", "job": ["knight", "lord_knight", "crusader", "paladin"], "rank": 3, "purple": true, "icon": "glaive", 
		"mods": {"dmg": 0.16, "area": 0.08}, "refine": {"dmg": 0.05}, "desc": "Lanza: con ella en la mano, tus habilidades de lanza hacen ×1,2 de daño."}, 
	"partizan": {"name": "Partizan", "slot": "weapon", "class": "swordsman", "job": ["knight", "lord_knight", "crusader", "paladin"], "rank": 3, "purple": true, "icon": "partizan", 
		"mods": {"dmg": 0.16, "max_hp_pct": 0.06}, "refine": {"dmg": 0.05}, "desc": "Lanza: con ella en la mano, tus habilidades de lanza hacen ×1,2 de daño."}, 
	"slayer": {"name": "Slayer", "slot": "weapon", "class": "swordsman", "rank": 2, "purple": true, "icon": "slayer", 
		"mods": {"dmg": 0.15, "crit": 0.04}, "refine": {"dmg": 0.05}, "desc": "Espada a dos manos: pega más fuerte y más lejos, pero más lenta, y no deja usar escudo."}, 
	"bastard_sword": {"name": "Bastard Sword", "slot": "weapon", "class": "swordsman", "rank": 2, "purple": true, "icon": "bastard_sword", 
		"mods": {"dmg": 0.16, "max_hp_pct": 0.04}, "refine": {"dmg": 0.05}, "desc": "Espada a dos manos: pega más fuerte y más lejos, pero más lenta, y no deja usar escudo."}, 
	"two_handed_sword": {"name": "Two-Handed Sword", "slot": "weapon", "class": "swordsman", "rank": 3, "purple": true, "icon": "two_handed_sword", 
		"mods": {"dmg": 0.19, "area": 0.06}, "refine": {"dmg": 0.05}, "desc": "Espada a dos manos: pega más fuerte y más lejos, pero más lenta, y no deja usar escudo."}, 
	"dragon_slayer": {"name": "Dragon Slayer", "slot": "weapon", "class": "swordsman", "rank": 3, "purple": true, "icon": "dragon_slayer", 
		"mods": {"dmg": 0.19, "crit": 0.06}, "refine": {"dmg": 0.05}, "desc": "Espada a dos manos: pega más fuerte y más lejos, pero más lenta, y no deja usar escudo."}, 


	"gungnir": {"name": "Gungnir", "slot": "weapon", "class": "swordsman", "job": ["knight", "lord_knight"], "legendary": true, "icon": "gungnir", 
		"lg_skill": "spear_boomerang", "mods": {"dmg": 0.3, "aspd": 0.06}, "refine": {"dmg": 0.05}, "effects": {"lg_gungnir": 1.0}, 
		"desc": "Legendaria: la lanza de Odín. Spear Boomerang vuela solo hacia el monstruo más fuerte a su alcance y nunca falla: donde llega cae el Juicio de Odín, un rayo dorado que golpea a todos alrededor con x1,5 de daño (más grande con tu área), y la lanza vuelve a tu mano golpeando otra vez. Con Spiral Pierce, el Juicio de Odín cae sobre el monstruo que taladra."}, 

	"rod": {"name": "Rod", "slot": "weapon", "class": "mage", "rank": 1, "icon": "rod", 
		"mods": {"dmg": 0.08}, "refine": {"dmg": 0.05}}, 
	"wand": {"name": "Wand", "slot": "weapon", "class": "mage", "rank": 2, "icon": "wand", 
		"mods": {"skill_dmg": 0.12, "haste": 0.04}, "refine": {"skill_dmg": 0.04}}, 
	"arc_wand": {"name": "Arc Wand", "slot": "weapon", "class": "mage", "rank": 3, "icon": "arc_wand", 
		"mods": {"skill_dmg": 0.2, "area": 0.08}, "refine": {"skill_dmg": 0.04}, 
		"proc": {"skill": "thunder_storm", "chance": 0.06}, 
		"desc": "6% con el ataque básico: lanza Thunder Storm ×Lv."}, 
	"staff_of_destruction": {"name": "Staff of Destruction", "slot": "weapon", "class": "mage", "legendary": true, 
		"icon": "staff_of_destruction", "mods": {"skill_dmg": 0.4, "area": 0.2, "max_hp_pct": -0.1}, 
		"refine": {"skill_dmg": 0.04}, "desc": "Legendaria: +40% daño de habilidades a costa de vida."}, 

	"bow": {"name": "Bow", "slot": "weapon", "class": "archer", "rank": 1, "icon": "bow", 
		"mods": {"dmg": 0.08}, "refine": {"dmg": 0.05}}, 
	"composite_bow": {"name": "Composite Bow", "slot": "weapon", "class": "archer", "rank": 2, "icon": "composite_bow", 
		"mods": {"dmg": 0.1, "aspd": 0.08}, "refine": {"dmg": 0.05}}, 
	"gakkung_bow": {"name": "Gakkung Bow", "slot": "weapon", "class": "archer", "rank": 3, "icon": "gakkung_bow", 
		"mods": {"basic_dmg": 0.2, "aspd": 0.1}, "refine": {"dmg": 0.05}, 
		"proc": {"skill": "double_strafe", "chance": 0.1}, 
		"desc": "10% con el ataque básico: lanza Double Strafe ×Lv."}, 


	"rudra_bow": {"name": "Rudra Bow", "slot": "weapon", "class": "archer", "legendary": true, "icon": "rudra_bow", 
		"lg_skill": "arrow_shower", "mods": {"dmg": 0.25, "aspd": 0.1}, "refine": {"dmg": 0.05}, "effects": {"lifesteal": 0.03, "lg_rudra": 1.0}, 
		"proc": {"skill": "heal", "chance": 0.05, "level": 3}, 
		"desc": "Legendaria: Arrow Shower cae tres veces y es Sagrada (si tu flecha no tiene elemento); cada monstruo bajo la primera lluvia te cura un 0,6% de tu vida máxima (hasta 6). Tus ataques básicos roban vida y a veces lanzan Heal."}, 


	"falken_blitz": {"name": "Falken Blitz", "slot": "weapon", "class": "archer", "legendary": true, "icon": "falken_blitz", 
		"lg_skill": "sharp_shooting", "mods": {"dmg": 0.2, "aspd": 0.15}, "refine": {"dmg": 0.05}, "effects": {"bounce": 2.0, "lg_falken": 1.0}, 
		"desc": "Legendaria: Sharp Shooting dispara en abanico, tres líneas en vez de una (las de los lados con el 60% del daño) y cada una hace estallar las trampas que cruza. Cada flecha de tu ataque básico rebota a 2 monstruos más."}, 

	"knife": {"name": "Knife", "slot": "weapon", "class": "thief", "rank": 1, "icon": "knife", "weapon_type": "dagger", 
		"mods": {"dmg": 0.08}, "refine": {"dmg": 0.05}}, 
	"stiletto": {"name": "Stiletto", "slot": "weapon", "class": "thief", "rank": 2, "icon": "stiletto", "weapon_type": "dagger", 
		"mods": {"dmg": 0.1, "aspd": 0.08}, "refine": {"dmg": 0.05}}, 
	"damascus": {"name": "Damascus", "slot": "weapon", "class": "thief", "rank": 2, "icon": "damascus", "weapon_type": "dagger", 
		"mods": {"dmg": 0.12, "crit": 0.06}, "refine": {"dmg": 0.05}}, 
	"venom_knife": {"name": "Venom Knife", "slot": "weapon", "class": "thief", "rank": 3, "icon": "venom_knife", "weapon_type": "dagger", 
		"mods": {"dmg": 0.14, "basic_dmg": 0.06}, "refine": {"dmg": 0.05}, "effects": {"poison_hit": 0.3}, 
		"desc": "Los ataques básicos envenenan."}, 
	"grimtooth": {"name": "Grimtooth", "slot": "weapon", "class": "thief", "legendary": true, "icon": "grimtooth", "weapon_type": "dagger", 
		"mods": {"dmg": 0.3, "aspd": 0.1}, "refine": {"dmg": 0.05}, "effects": {"splash": 1.6, "poison_hit": 0.4}, 
		"desc": "Legendaria: los ataques básicos golpean en área y envenenan."}, 

	"assassin_dagger": {"name": "Assassin Dagger", "slot": "weapon", "class": "thief", "legendary": true, 
		"job": ["assassin", "assassin_cross"], "icon": "assassin_dagger", "weapon_type": "dagger", "offhand_full": true, "left_only": true, 
		"mods": {"dmg": 0.18, "aspd": 0.15, "crit": 0.08}, "refine": {"dmg": 0.05}, "effects": {"double": 0.1}, 
		"desc": "Legendaria: solo va en la mano izquierda, y allí cuenta entera. Tus ataques básicos a veces golpean otra vez."}, 

	"katar": {"name": "Katar", "slot": "weapon", "class": "thief", "job": ["assassin", "assassin_cross"], 
		"weapon_type": "katar", "rank": 1, "icon": "katar", 
		"mods": {"dmg": 0.12, "crit": 0.06}, "refine": {"dmg": 0.05}}, 
	"jur": {"name": "Jur", "slot": "weapon", "class": "thief", "job": ["assassin", "assassin_cross"], 
		"weapon_type": "katar", "rank": 2, "icon": "jur", 
		"mods": {"dmg": 0.16, "aspd": 0.06, "crit": 0.06}, "refine": {"dmg": 0.05}}, 
	"jamadhar": {"name": "Jamadhar", "slot": "weapon", "class": "thief", "job": ["assassin", "assassin_cross"], 
		"weapon_type": "katar", "rank": 3, "icon": "jamadhar", 
		"mods": {"dmg": 0.22, "crit": 0.1, "basic_dmg": 0.06}, "refine": {"dmg": 0.05}}, 

	"club": {"name": "Club", "slot": "weapon", "class": "acolyte", "rank": 1, "icon": "club", 
		"mods": {"dmg": 0.08}, "refine": {"dmg": 0.05}}, 
	"mace": {"name": "Mace", "slot": "weapon", "class": "acolyte", "rank": 1, "icon": "mace", 
		"mods": {"dmg": 0.1}, "refine": {"dmg": 0.05}}, 
	"morning_star": {"name": "Morning Star", "slot": "weapon", "class": "acolyte", "rank": 2, "icon": "morning_star", 
		"mods": {"dmg": 0.12, "crit": 0.05}, "refine": {"dmg": 0.05}}, 
	"chain": {"name": "Chain", "slot": "weapon", "class": "acolyte", "rank": 2, "icon": "chain", 
		"mods": {"skill_dmg": 0.1, "aspd": 0.06}, "refine": {"dmg": 0.05}}, 
	"stunner": {"name": "Stunner", "slot": "weapon", "class": "acolyte", "rank": 3, "icon": "stunner", 
		"mods": {"dmg": 0.14}, "refine": {"dmg": 0.05}, "effects": {"stun_hit": 0.08}, 
		"proc": {"skill": "holy_light", "chance": 0.1}, 
		"desc": "8% de aturdir con el ataque básico. 10% con el ataque básico: lanza Holy Light ×Lv."}, 
	"mjolnir": {"element": "wind", "name": "Mjolnir", "slot": "weapon", "class": "acolyte", "legendary": true, "icon": "mjolnir", 
		"mods": {"dmg": 0.25, "aspd": 0.15}, "refine": {"dmg": 0.05}, 
		"proc": {"skill": "thunder_storm", "chance": 0.08, "level": 3}, 
		"effects": {"stun_hit": 0.06}, 
		"desc": "Legendaria: martillo de Viento de Thor. Tus ataques básicos aturden y a veces invocan Thunder Storm."}, 

	"six_shooter": {"name": "Six Shooter", "slot": "weapon", "class": "gunslinger", "rank": 1, "icon": "six_shooter", 
		"mods": {"dmg": 0.08}, "refine": {"dmg": 0.05}}, 
	"rifle": {"name": "Rifle", "slot": "weapon", "class": "gunslinger", "rank": 2, "icon": "rifle", 
		"mods": {"dmg": 0.12, "basic_dmg": 0.06}, "refine": {"dmg": 0.05}}, 
	"single_shotgun": {"name": "Shotgun", "slot": "weapon", "class": "gunslinger", "rank": 2, "icon": "single_shotgun", 
		"mods": {"dmg": 0.12, "area": 0.08}, "refine": {"dmg": 0.05}}, 
	"lever_action_rifle": {"name": "Lever Action Rifle", "slot": "weapon", "class": "gunslinger", "rank": 3, "icon": "lever_action_rifle", 
		"mods": {"basic_dmg": 0.18, "aspd": 0.08}, "refine": {"dmg": 0.05}, 
		"proc": {"skill": "tracking", "chance": 0.08}, 
		"desc": "8% con el ataque básico: lanza Tracking ×Lv."}, 
	"avenger_gatling": {"name": "Avenger Gatling Gun", "slot": "weapon", "class": "gunslinger", "legendary": true, "icon": "avenger_gatling", 
		"mods": {"dmg": 0.2, "aspd": 0.2}, "refine": {"dmg": 0.05}, "effects": {"splash": 1.2}, 
		"desc": "Legendaria: ametralladora; cada bala de tu ataque básico estalla en área."}, 
	"destroyer": {"name": "Destroyer", "slot": "weapon", "class": "gunslinger", "legendary": true, "icon": "destroyer", "lg_skill": "desperado", 
		"mods": {"skill_dmg": 0.25, "haste": 0.1}, "refine": {"dmg": 0.05}, "effects": {"lg_grenades": 1.0}, 
		"desc": "Legendaria: lanzagranadas. Desperado lanza 3 granadas a los monstruos de alrededor, que estallan medio segundo después en área (120% de su daño, fuego). Recargas más rápido."}, 

	"axe": {"name": "Axe", "slot": "weapon", "class": "merchant", "rank": 1, "icon": "axe", 
		"mods": {"dmg": 0.08}, "refine": {"dmg": 0.05}}, 
	"battle_axe": {"name": "Battle Axe", "slot": "weapon", "class": "merchant", "rank": 2, "icon": "battle_axe", 
		"mods": {"dmg": 0.12, "crit": 0.05}, "refine": {"dmg": 0.05}}, 
	"hammer": {"name": "Hammer", "slot": "weapon", "class": "merchant", "rank": 2, "icon": "hammer", 
		"mods": {"dmg": 0.12}, "refine": {"dmg": 0.05}, "effects": {"stun_hit": 0.05}, 
		"desc": "5% de aturdir con el ataque básico."}, 
	"buster": {"name": "Buster", "slot": "weapon", "class": "merchant", "rank": 2, "icon": "buster", 
		"mods": {"dmg": 0.14, "basic_dmg": 0.06, "aspd": -0.04}, "refine": {"dmg": 0.05}}, 
	"great_axe": {"name": "Great Axe", "slot": "weapon", "class": "merchant", "rank": 3, "icon": "great_axe", 
		"mods": {"dmg": 0.16, "basic_dmg": 0.08}, "refine": {"dmg": 0.05}, "effects": {"stun_hit": 0.06}, 
		"proc": {"skill": "cart_revolution", "chance": 0.08}, 
		"desc": "6% de aturdir con el ataque básico. 8% con el ataque básico: lanza Cart Revolution ×Lv."}, 
	"tomahawk": {"element": "wind", "name": "Tomahawk", "slot": "weapon", "class": "merchant", "rank": 3, "icon": "tomahawk", 
		"mods": {"dmg": 0.14, "aspd": 0.06}, "refine": {"dmg": 0.05}, 
		"proc": {"skill": "mammonite", "chance": 0.08}, 
		"desc": "Arma de Viento. 8% con el ataque básico: lanza Mammonite ×Lv."}, 
	"bloody_axe": {"name": "Bloody Axe", "slot": "weapon", "class": "merchant", "legendary": true, "icon": "bloody_axe", 
		"mods": {"dmg": 0.3, "move": 0.12}, "refine": {"dmg": 0.05}, "effects": {"splash": 1.6, "kill_heal": 0.002}, 
		"desc": "Legendaria: el hacha sedienta de sangre. Corres más, cada golpe básico salpica en área y cada muerte te cura."}, 

	"huuma_bird_wing": {"name": "Huuma Bird Wing", "slot": "weapon", "class": "ninja", "rank": 1, "icon": "huuma_bird_wing", 
		"mods": {"dmg": 0.08}, "refine": {"dmg": 0.05}}, 
	"huuma_calm_mind": {"name": "Huuma Calm Mind", "slot": "weapon", "class": "ninja", "rank": 2, "icon": "huuma_calm_mind", 
		"mods": {"dmg": 0.12, "haste": 0.06}, "refine": {"dmg": 0.05}}, 

	"kagekiri": {"name": "Kagekiri", "slot": "weapon", "class": "ninja", "rank": 2, "icon": "kagekiri", "weapon_type": "dagger", 
		"mods": {"dmg": 0.1, "crit": 0.06}, "refine": {"dmg": 0.05}}, 
	"kamaitachi": {"element": "wind", "name": "Kamaitachi", "slot": "weapon", "class": "ninja", "rank": 3, "icon": "kamaitachi", 
		"weapon_type": "dagger", "mods": {"dmg": 0.13, "aspd": 0.08}, "refine": {"dmg": 0.05}, 
		"proc": {"skill": "lightning_crash", "chance": 0.06}, 
		"desc": "Arma de Viento. 6% con el ataque básico: lanza Lightning Crash ×Lv."}, 
	"huuma_thunderstorm": {"element": "wind", "name": "Huuma Thunderstorm", "slot": "weapon", "class": "ninja", "rank": 2, "icon": "huuma_thunderstorm", 
		"mods": {"dmg": 0.12, "aspd": 0.06}, "refine": {"dmg": 0.05}, "desc": "Arma de Viento."}, 
	"huuma_fluttering_snow": {"element": "water", "name": "Huuma Fluttering Snow", "slot": "weapon", "class": "ninja", "rank": 3, "icon": "huuma_fluttering_snow", 
		"mods": {"dmg": 0.14}, "refine": {"dmg": 0.05}, 
		"proc": {"skill": "freezing_spear", "chance": 0.08}, 
		"desc": "Arma de Agua. 8% con el ataque básico: lanza Freezing Spear ×Lv."}, 
	"huuma_blaze": {"element": "fire", "name": "Huuma Blaze", "slot": "weapon", "class": "ninja", "rank": 3, "icon": "huuma_blaze", 
		"mods": {"dmg": 0.14}, "refine": {"dmg": 0.05}, 
		"proc": {"skill": "flaming_petals", "chance": 0.08}, 
		"desc": "Arma de Fuego. 8% con el ataque básico: lanza Flaming Petals ×Lv."}, 
	"huuma_giant_wheel": {"name": "Huuma Giant Wheel", "slot": "weapon", "class": "ninja", "legendary": true, "icon": "huuma_giant_wheel", 
		"mods": {"dmg": 0.25, "aspd": 0.12}, "refine": {"dmg": 0.05}, "effects": {"mirror_extra": 1.0}, 
		"proc": {"skill": "throw_huuma", "chance": 0.1, "level": 5}, 
		"desc": "Legendaria: el Huuma de rueda gigante. Tus ataques básicos a veces lanzan Throw Huuma Shuriken Nv5 ×Lv y Mirror Image crea una sombra más."}, 



	"mysteltainn": {"name": "Mysteltainn", "slot": "weapon", "class": "swordsman", "legendary": true, "icon": "mysteltainn", 
		"lg_skill": "bash", "mods": {"dmg": 0.22, "aspd": 0.08}, "refine": {"dmg": 0.05}, "effects": {"lg_bash": 1.0}, 
		"desc": "Legendaria: la espada que se alimenta: cada monstruo que Bash mata le suma daño a Bash para el resto de la partida, cada vez algo más despacio: ×2 a los 300, ×4,16 a los 3000."}, 
	"mighty_staff": {"name": "Mighty Staff", "slot": "weapon", "class": "mage", "legendary": true, "icon": "mighty_staff", 
		"lg_skill": "fire_wall", "mods": {"skill_dmg": 0.22}, "refine": {"dmg": 0.05}, "effects": {"lg_firewall": 1.0}, 
		"desc": "Legendaria: Fire Wall te rodea: un anillo de muros de fuego que se mueve contigo, quema a todo lo que lo toca y lo empuja hacia afuera."}, 





	"roguemaster_bow": {"name": "Roguemaster's Bow", "slot": "weapon", "class": "thief", "job": ["rogue", "stalker"], "legendary": true, 
		"icon": "roguemaster_bow", "lg_skill": "double_strafe", "mods": {"dmg": 0.25, "aspd": 0.08, "crit": 0.05}, "refine": {"dmg": 0.05}, 
		"effects": {"lg_strip_arrow": 1.0}, 
		"desc": "Legendaria: las flechas de Double Strafe desarman como Full Strip, también a jefes y MVP; cada monstruo desarmado da una carga de Botín, que no se acaba mientras disparas. Botín: +5 cargas máx. y +30% de daño de Double Strafe por carga."}, 
	"ballista": {"name": "Ballista", "slot": "weapon", "class": "archer", "legendary": true, "icon": "ballista", 
		"lg_skill": "double_strafe", "mods": {"dmg": 0.22, "aspd": 0.06}, "refine": {"dmg": 0.05}, "effects": {"lg_ds": 1.0}, 
		"desc": "Legendaria: las flechas de Double Strafe rebotan 5 veces más y cada rebote pega un 18% más fuerte; contra uno solo (un MVP) rebotan sobre él. Las del Double Strafe de un arma o carta también rebotan, sin crecer."}, 
	"quadrille": {"element": "holy", "name": "Quadrille", "slot": "weapon", "class": "acolyte", "legendary": true, "icon": "quadrille", 
		"lg_skill": "heal", "mods": {"dmg": 0.18, "max_hp_pct": 0.08}, "refine": {"dmg": 0.05}, "effects": {"lg_heal": 1.0}, 
		"desc": "Legendaria: Heal también castiga: una explosión de luz sagrada daña a los monstruos a tu alrededor con el triple de la cantidad de Heal, sin la parte por vida máxima (los no-muertos y demonios, mucho más) y se lanza aunque tengas la vida llena. El Heal que lanzan tus cartas castiga con el triple de su cantidad base."}, 
	"golden_axe": {"name": "Golden Axe", "slot": "weapon", "class": "merchant", "legendary": true, "icon": "golden_axe", 
		"lg_skill": "mammonite", "mods": {"dmg": 0.22, "loot": 0.15}, "refine": {"dmg": 0.05}, "effects": {"lg_mammon": 1.0}, 
		"desc": "Legendaria: Mammonite ya no gasta zeny: crece con el zeny ganado en la partida (+100% cada 4000, hasta x4) y con el que tienes guardado (x1,5 con 100k, x2 con 1M), y cada monstruo que mata suelta monedas."}, 


	"dwarven_hammer": {"name": "Martillo de los Enanos", "slot": "weapon", "class": "merchant", "legendary": true, "icon": "hammer", 
		"lg_skill": "hammer_fall", "job": ["blacksmith", "whitesmith"], "mods": {"dmg": 0.2, "max_hp_pct": 0.06}, "refine": {"dmg": 0.05}, "effects": {"lg_molten": 1.0}, 
		"desc": "Legendaria: cuando tu forja estalla deja metal fundido en el suelo 5 s: los monstruos que lo pisan arden (la quemadura que rueda, más fuerte cuanto más refinada estaba el arma). Hammer Fall lanzado sobre el metal fundido llena el doble de Aguante."}, 
	"ginnungagap": {"name": "Ginnungagap", "slot": "weapon", "class": "thief", "legendary": true, "icon": "ginnungagap", 
		"lg_skill": "back_stab", "job": ["rogue", "stalker"], "mods": {"dmg": 0.2, "crit": 0.1}, "refine": {"dmg": 0.05}, "effects": {"lg_backstab": 1.0}, 
		"desc": "Legendaria: contra uno solo (un MVP), Back Stab lo apuñala más veces: al menos 5 más 1 por cada mejora de Back Stab (12 con Back Stab EX), y cada puñalada repetida hace el 80% del daño en vez del 60%."}, 
	"murasame": {"name": "Murasame", "slot": "weapon", "class": "ninja", "legendary": true, "icon": "murasame", 
		"lg_skill": "mirror_image", "mods": {"dmg": 0.2, "aspd": 0.1}, "refine": {"dmg": 0.05}, "effects": {"lg_mirror": 1.0}, 
		"desc": "Legendaria: tus sombras de Mirror Image lanzan contigo todo lo que arrojas (shuriken, kunai, Huuma) al 60% de su daño."}, 
	"crimson_bolt": {"name": "Crimson Bolt", "slot": "weapon", "class": "gunslinger", "legendary": true, "icon": "crimson_bolt", 
		"lg_skill": "tracking", "mods": {"dmg": 0.22, "crit": 0.06}, "refine": {"dmg": 0.05}, "effects": {"lg_track": 0.35}, 
		"desc": "Legendaria: Tracking marca a su blanco: recibe ×1,35 de todo tu daño durante 8 s y, al morir, la marca salta al monstruo más fuerte cercano."}, 
	"chained_souls": {"name": "Libro de las Almas Encadenadas", "slot": "weapon", "class": "taekwon", "job": ["soul_linker"], "legendary": true, 
		"icon": "sage_book", "lg_skill": "eswoo", "mods": {"skill_dmg": 0.22, "haste": 0.06}, "refine": {"skill_dmg": 0.04}, "effects": {"lg_soul_chain": 0.3}, 
		"desc": "Legendaria: los monstruos atados por Eswoo reciben ×1,3 del daño de tus espíritus. Cuando uno atado muere, su alma salta como un Esma gratis al monstruo más cercano y lo ata: una cadena que limpia la horda. Contra un MVP atado, cada golpe de tus espíritus llena su Aguante."}, 
	"survivors_rod": {"name": "Sky Leap Boots", "slot": "shoes", "class": "taekwon", "legendary": true, "icon": "survivors_rod", 
		"lg_skill": "flying_kick", "mods": {"dmg": 0.2, "move": 0.08}, "refine": {"dmg": 0.05}, "effects": {"lg_fkick": 1.0}, 
		"desc": "Legendaria: Flying Side Kick rebota de monstruo en monstruo 3 veces más al aterrizar, cada patada más fuerte."}, 



	"exquisite_foxtail": {"name": "Exquisite Yellow Foxtail Model", "slot": "weapon", "class": "doram", "legendary": true, 
		"icon": "exquisite_foxtail", "lg_skill": "picky_peck", "mods": {"skill_dmg": 0.2, "aspd": 0.1}, "refine": {"skill_dmg": 0.04}, 
		"effects": {"lg_picky_chain": 1.0}, 
		"desc": "Legendaria: cada Picky que estalla deja salir otro Picky, con el 60% de su daño y su tiempo, que también estalla (hasta dos veces seguidas)."}, 
	"magic_foxtail": {"name": "Magic Yellow Foxtail Staff", "slot": "weapon", "class": "doram", "legendary": true, 
		"icon": "magic_foxtail", "lg_skill": "catnip_meteor", "mods": {"skill_dmg": 0.22, "haste": 0.06}, "refine": {"skill_dmg": 0.04}, 
		"effects": {"lg_spear_meteor": 1.0}, 
		"desc": "Legendaria: cada Silvervine Stem Spear llama un Catnip Meteor donde cae, del mismo elemento que la lanza (si tienes Catnip Meteor; uno por segundo como mucho)."}, 
	"bunny_charm": {"name": "Basic Bunny Charm", "slot": "acc", "class": "doram", "job": ["spirit_handler"], "legendary": true, 
		"icon": "bunny_charm", "lg_skill": "lunatic_carrot_beat", "mods": {"skill_dmg": 0.1, "max_hp_pct": 0.1}, "refine": {"max_hp_pct": 0.01}, 
		"effects": {"lg_carrot_stun": 1.0}, 
		"desc": "Legendaria: Lunatic Carrot Beat aturde el doble de seguido, y cada monstruo que aturde recibe encima otra lluvia de 3 zanahorias."}, 
	"leaf_talisman": {"name": "Basic Leaf Talisman", "slot": "acc", "class": "doram", "legendary": true, 
		"icon": "leaf_talisman", "lg_skill": "catnip_meteor", "mods": {"skill_dmg": 0.1, "area": 0.08}, "refine": {"skill_dmg": 0.02}, 
		"effects": {"lg_catnip_powder": 1.0}, 
		"desc": "Legendaria: cada Catnip Meteor deja una nube de Catnip Powder 3 s: frena a los monstruos dentro y les hace el 10% de su daño cada 0,5 s."}, 

	"golden_mace": {"element": "holy", "name": "Golden Mace", "slot": "weapon", "class": "merchant", "legendary": true, 
		"job": ["alchemist", "creator"], "icon": "golden_mace", 
		"mods": {"dmg": 0.2, "skill_dmg": 0.2, "haste": 0.1}, "refine": {"dmg": 0.05}, 
		"proc": {"skill": "demonstration", "chance": 0.08, "level": 3}, 
		"desc": "Legendaria: maza dorada de Sagrado. Recargas más rápido y tus ataques básicos a veces lanzan Demonstration."}, 


	"paracelsus_mace": {"name": "Paracelsus Mace", "slot": "weapon", "class": "merchant", "legendary": true, 
		"job": ["alchemist", "creator"], "icon": "paracelsus_mace", 
		"mods": {"dmg": 0.15, "max_hp_pct": 0.1}, "refine": {"dmg": 0.05}, 
		"effects": {"homun_power": 0.5, "summon_dmg": 0.3, "plant_chain": 2.0, "summon_leech": 0.002}, 
		"desc": "Legendaria: maza de Paracelso para invocadores. Tus Homúnculos pegan un 50% más y todas tus invocaciones un 30%; cada mordida de las plantas de Bio Cannibalize salta a 2 monstruos más, y cada golpe de una invocación te cura un 0,2% de tu vida máxima."}, 
	"holy_avenger": {"element": "holy", "name": "Holy Avenger", "slot": "weapon", "class": "swordsman", "legendary": true, 
		"job": ["crusader", "paladin"], "icon": "holy_avenger", 
		"mods": {"dmg": 0.25, "max_hp_pct": 0.12, "armor": 2.0}, "refine": {"dmg": 0.05}, "effects": {"vs_undead": 0.2}, 
		"proc": {"skill": "grand_cross", "chance": 0.07, "level": 3}, 
		"desc": "Legendaria: espada sagrada de Sagrado. Hiere más a no-muertos y tus ataques básicos a veces lanzan Grand Cross."}, 
	"encyclopedia": {"name": "Encyclopedia", "slot": "weapon", "class": "mage", "legendary": true, 
		"job": ["sage", "professor"], "icon": "encyclopedia", "lg_skill": "earth_spike", 
		"mods": {"skill_dmg": 0.3, "haste": 0.12, "area": 0.1}, "refine": {"skill_dmg": 0.04}, "effects": {"lg_quake": 1.0}, 
		"desc": "Legendaria: el libro de la tierra de Juno. Earth Spike y Heaven's Drive vuelven a golpear medio segundo después a cada monstruo que alcanzan (60% del daño). Recargas más rápido."}, 


	"bragi_lyre": {"name": "Lira de Bragi", "slot": "weapon", "class": "archer", "legendary": true, 
		"job": ["bard", "clown"], "book": "song", "icon": "bragi_lyre", 
		"mods": {"dmg": 0.2, "aspd": 0.12, "haste": 0.08}, "refine": {"dmg": 0.05}, "effects": {"lg_lyre": 1.0}, 
		"desc": "Legendaria de las canciones: el arpa del dios de la poesía. En cada Bis, las recargas de todas tus habilidades avanzan 1 s y durante ese compás los procs de tu ataque básico (cartas y equipo) saltan el doble de seguido."}, 
	"dancer_whip": {"name": "Látigo de la Bailarina", "slot": "weapon", "class": "archer", "legendary": true, 
		"job": ["bard", "clown"], "book": "dance", "icon": "dancer_whip", 
		"mods": {"dmg": 0.22, "aspd": 0.1, "move": 0.08}, "refine": {"dmg": 0.05}, "effects": {"lg_whip": 1.0}, 
		"desc": "Legendaria de las danzas: cada danza que suena fortalece el Bis (+25%). En el Bis tus golpes sueltan un paso de baile: una onda que empuja y golpea con el daño de ese golpe, más grande cuantas más danzas suenen."}, 
	"electric_guitar": {"element": "wind", "name": "Electric Guitar", "slot": "weapon", "class": "archer", "legendary": true, 
		"job": ["bard", "clown"], "icon": "electric_guitar", 
		"mods": {"dmg": 0.2, "aspd": 0.15, "move": 0.08}, "refine": {"dmg": 0.05}, 
		"proc": {"skill": "thunder_storm", "chance": 0.07, "level": 3}, 
		"desc": "Legendaria: cada acorde trae una tormenta. Tus ataques básicos a veces lanzan Thunder Storm."}, 
	"sucsamad": {"name": "Sucsamad", "slot": "weapon", "class": "thief", "legendary": true, 
		"job": ["rogue", "stalker"], "icon": "sucsamad", "lg_skill": "double_attack", 
		"mods": {"dmg": 0.25, "crit": 0.12, "loot": 0.15}, "refine": {"dmg": 0.05}, "effects": {"double": 0.15, "lg_chain_double": 0.35}, 
		"proc": {"skill": "raid", "chance": 0.06, "level": 3}, 
		"desc": "Legendaria: Double Attack encadena: cada golpe extra tiene un 35% de traer otro más (hasta 9 golpes). A veces lanza Raid. Más zeny."}, 
	"hurricane_fury": {"name": "Hurricane Fury", "slot": "weapon", "class": "acolyte", "legendary": true, 
		"job": ["monk", "champion"], "icon": "hurricane_fury_knuckle", "lg_skill": "asura_strike", 
		"mods": {"dmg": 0.2, "skill_dmg": 0.15}, "refine": {"dmg": 0.05}, "effects": {"lg_asura_echo": 0.5, "lg_asura_haste": 1.0}, 
		"desc": "Legendaria: Asura Strike usa toda tu velocidad de recarga, sin rendimientos decrecientes (hasta 1 s). Y 3 segundos después, un Asura fantasma vuelve a caer en el mismo lugar con la mitad de su daño (uno a la vez)."}, 
	"kaiser_knuckle": {"name": "Kaiser Knuckle", "slot": "weapon", "class": "acolyte", "legendary": true, 
		"job": ["monk", "champion"], "icon": "kaiser_knuckle", 
		"mods": {"dmg": 0.25, "aspd": 0.2}, "refine": {"dmg": 0.05}, "effects": {"splash": 1.4, "lg_kaiser": 1.0}, 
		"proc": {"skill": "investigate", "chance": 0.1, "level": 5}, 
		"desc": "Legendaria: tus ataques básicos golpean en área y a veces lanzan Occult Impaction Nv5 ×Lv (o a tu nivel si lo tienes más alto), que golpea a todos los monstruos de esa área además de los que tiene detrás."}, 
	"berserk_knuckle": {"name": "Berserk Knuckle", "slot": "weapon", "class": "acolyte", "legendary": true, 
		"job": ["monk", "champion"], "icon": "berserk_knuckle", "lg_skill": "triple_attack", 
		"mods": {"dmg": 0.2, "aspd": 0.1}, "refine": {"dmg": 0.05}, "effects": {"lg_berserk": 1.0}, 
		"desc": "Legendaria: furia del combo. Cada golpe del combo del Monk suma un 5% más de daño al combo (hasta ×2); la furia dura 6 s después de cada combo, aunque la cadena se corte. El combo empieza un 50% más seguido y busca su siguiente monstruo un 50% más lejos."}, 

	"cap": {"name": "Cap", "slot": "head", "rank": 1, "icon": "cap", "view": "hat_cap", 
		"mods": {"max_hp_pct": 0.06}, "refine": {"armor": 0.5}}, 
	"ribbon": {"name": "Ribbon", "slot": "head", "rank": 1, "icon": "ribbon", "view": "hat_ribbon", 
		"mods": {"skill_dmg": 0.05, "regen": 0.5}, "refine": {"armor": 0.5}}, 
	"bandana": {"name": "Bandana", "slot": "head", "rank": 1, "icon": "bandana", "view": "hat_bandana", 
		"mods": {"armor": 1.0, "move": 0.03}, "refine": {"armor": 0.5}}, 
	"goggles": {"name": "Goggles", "slot": "head", "rank": 2, "icon": "goggles", "view": "hat_goggles", 
		"mods": {"crit": 0.04, "dodge": 0.02}, "refine": {"armor": 0.5}}, 
	"apple_of_archer": {"name": "Apple of Archer", "slot": "head", "rank": 2, "icon": "apple_of_archer", "view": "hat_apple", 
		"mods": {"aspd": 0.08, "basic_dmg": 0.08}, "refine": {"armor": 0.5}}, 
	"valkyrie_helm": {"name": "Valkyrie Helm", "slot": "head", "legendary": true, "icon": "valkyrie_helm", "view": "hat_valkyrie", 
		"mods": {"max_hp_pct": 0.12, "skill_dmg": 0.12, "armor": 2.0}, "refine": {"armor": 0.5}, "effects": {"valhalla": 25.0}, 
		"desc": "Legendaria: Furia de Valhalla. Cada 25 s entras 5 s en Berserk (+100% de daño, más velocidad de ataque, de recarga y de movimiento). Una Berserk Potion que recojas dura 20 s y suma +50% de daño y +50% de daño crítico."}, 






	"sunglasses": {"name": "Sunglasses", "slot": "mid", "face": true, "icon": "sunglasses", "view": "hat_sunglasses", 
		"mods": {"vs_mvp": 0.08, "crit": 0.02}}, 
	"elven_ears": {"name": "Elven Ears", "slot": "mid", "face": true, "icon": "elven_ears", "view": "hat_elven_ears", 
		"mods": {"dex_pct": 0.05, "int_pct": 0.05}}, 
	"opera_masque": {"name": "Opera Masque", "slot": "mid", "face": true, "icon": "opera_masque", "view": "hat_opera_masque", 
		"mods": {"tower_dmg": 0.01, "dmg": 0.03}}, 
	"eye_patch": {"name": "Eye Patch", "slot": "mid", "face": true, "icon": "eye_patch", "view": "hat_eye_patch", 
		"mods": {"str_pct": 0.06, "crit_dmg": 0.05}}, 
	"angel_wing_ears": {"name": "Angel Wing Ears", "slot": "mid", "face": true, "icon": "angel_wing_ears", "view": "hat_angel_wing_ears", 
		"mods": {"vit_pct": 0.06, "tower_hp": 0.012}}, 
	"monocle": {"name": "Monocle", "slot": "mid", "face": true, "icon": "monocle", "view": "hat_monocle", 
		"mods": {"luk_pct": 0.06, "vs_mvp": 0.05}}, 
	"pipe": {"name": "Pipe", "slot": "low", "face": true, "icon": "pipe", "view": "hat_pipe", 
		"mods": {"all_pct": 0.03}}, 
	"gas_mask": {"name": "Gas Mask", "slot": "low", "face": true, "icon": "gas_mask", "view": "hat_gas_mask", 
		"mods": {"max_hp_pct": 0.05, "tower_hp": 0.012}}, 
	"gum_in_mouth": {"name": "Bubble Gum", "slot": "low", "face": true, "icon": "gum_in_mouth", "view": "hat_gum_in_mouth", 
		"mods": {"agi_pct": 0.06, "move": 0.03}}, 
	"pacifier": {"name": "Pacifier", "slot": "low", "face": true, "icon": "pacifier", "view": "hat_pacifier", 
		"mods": {"vit_pct": 0.05, "regen": 0.5}}, 
	"mustache": {"name": "Bushy Mustache", "slot": "low", "face": true, "icon": "mustache", "view": "hat_mustache", 
		"mods": {"tower_dmg": 0.012, "str_pct": 0.03}}, 
	"fish_in_mouth": {"name": "Fish in Mouth", "slot": "low", "face": true, "icon": "fish_in_mouth", "view": "hat_fish_in_mouth", 
		"mods": {"vs_mvp": 0.08, "agi_pct": 0.04}}, 
	"ifrit_eye": {"name": "Ifrit's Eye", "slot": "mid", "face": true, "legendary": true, "icon": "ifrit_eye", "view": "hat_ifrit_eye", 
		"mods": {"vs_mvp": 0.3, "tower_dmg": 0.02, "str_pct": 0.08}, 
		"desc": "Legendaria de la torre: el fuego de Ifrit contra los MVP, y más daño cuanto más alto llegaste en la torre."}, 
	"gryphon_ears": {"name": "Gryphon Wing Ears", "slot": "mid", "face": true, "legendary": true, "icon": "gryphon_ears", "view": "hat_gryphon_ears", 
		"mods": {"max_hp_pct": 0.15, "armor": 4.0}, "effects": {"lives": 1.0, "hit_shield": 0.03}, 
		"desc": "Legendaria de la torre para tanques: +1 vida extra al empezar la partida (2 en la torre) y cada golpe que recibes te da un escudo del 3% de tu vida máxima (hasta 30%, como mucho cada 0,5 s)."}, 
	"angel_kiss": {"name": "Angel's Kiss", "slot": "low", "face": true, "legendary": true, "icon": "angel_kiss", "view": "hat_angel_kiss", 
		"mods": {"all_pct": 0.06, "max_hp_pct": 0.1}, "effects": {"lives": 1.0}, 
		"desc": "Legendaria de la torre: +1 vida extra al empezar la partida (2 en la torre)."}, 
	"frozen_breath": {"name": "Frozen Breath", "slot": "low", "face": true, "legendary": true, "icon": "frozen_breath", "view": "hat_frozen_breath", 
		"mods": {"tower_hp": 0.03, "tower_dmg": 0.02, "vit_pct": 0.1}, 
		"desc": "Legendaria de la torre: más vida y daño cuanto más alto llegaste en la torre."}, 

	"cotton_shirt": {"name": "Cotton Shirt", "slot": "armor", "rank": 1, "icon": "cotton_shirt", 
		"mods": {"armor": 1.5}, "refine": {"armor": 1.0}}, 
	"adventurers_suit": {"name": "Adventurer's Suit", "slot": "armor", "rank": 1, "icon": "adventurers_suit", 
		"mods": {"armor": 2.0, "max_hp_pct": 0.05}, "refine": {"armor": 1.0}}, 
	"chain_mail": {"name": "Chain Mail", "slot": "armor", "rank": 2, "icon": "chain_mail", 
		"mods": {"armor": 4.0, "move": -0.03}, "refine": {"armor": 1.0}}, 
	"saints_robe": {"name": "Saint's Robe", "slot": "armor", "rank": 2, "icon": "saints_robe", 
		"mods": {"armor": 2.0, "regen": 1.0, "skill_dmg": 0.05}, "refine": {"armor": 1.0}}, 
	"tights": {"name": "Tights", "slot": "armor", "rank": 2, "icon": "tights", 
		"mods": {"armor": 1.0, "aspd": 0.05, "basic_dmg": 0.05}, "refine": {"armor": 1.0}}, 
	"valkyrian_armor": {"name": "Valkyrian Armor", "slot": "armor", "legendary": true, "icon": "valkyrian_armor", 
		"mods": {"armor": 6.0, "max_hp_pct": 0.15, "regen": 1.5}, "refine": {"armor": 1.0}, "effects": {"undead_guard": 0.2, "last_stand": 60.0}, 
		"desc": "Legendaria: Einherjar. Al bajar del 30% de vida (o al morir) te curas un 30% y eres inmortal 3 s; una vez por minuto."}, 

	"guard": {"name": "Guard", "slot": "shield", "rank": 1, "icon": "guard", "view": "guard", 
		"mods": {"armor": 2.0}, "refine": {"armor": 0.6}}, 
	"buckler": {"name": "Buckler", "slot": "shield", "rank": 2, "icon": "buckler", "view": "buckler", 
		"mods": {"armor": 3.0, "dodge": 0.03}, "refine": {"armor": 0.6}}, 
	"shield": {"name": "Shield", "slot": "shield", "rank": 2, "icon": "shield", "view": "shield", 
		"mods": {"armor": 4.0, "max_hp": 25.0}, "refine": {"armor": 0.7}}, 
	"holy_guard": {"name": "Holy Guard", "slot": "shield", "rank": 3, "icon": "holy_guard", "view": "guard", 
		"mods": {"armor": 4.0, "regen": 1.0}, "refine": {"armor": 0.7}, "effects": {"undead_guard": 0.1}, 
		"desc": "Los no-muertos y demonios te hieren menos."}, 
	"mirror_shield": {"name": "Mirror Shield", "slot": "shield", "rank": 3, "icon": "mirror_shield", "view": "mirror", 
		"mods": {"armor": 5.0, "dodge": 0.04, "skill_dmg": 0.05}, "refine": {"armor": 0.8}}, 
	"valkyrja_shield": {"name": "Valkyrja's Shield", "slot": "shield", "legendary": true, "icon": "valkyrja_shield", "view": "mirror", 
		"mods": {"armor": 7.0, "max_hp_pct": 0.1, "dmg": 0.08}, "refine": {"armor": 1.0}, "effects": {"undead_guard": 0.2, "aegis": 8.0}, 
		"desc": "Legendaria: Égida. Cada 8 s anula el siguiente golpe y suelta un estallido sagrado a tu alrededor."}, 



	"royal_guard_shield": {"name": "Royal Guard Shield", "slot": "shield", "class": "swordsman", "legendary": true, "job": ["paladin"], 
		"lg_skill": "shield_chain", "icon": "royal_guard_shield", "view": "guard", 
		"mods": {"armor": 6.0, "max_hp_pct": 0.12, "dmg": 0.1}, "refine": {"armor": 1.0}, "effects": {"lg_chain": 3.0, "lg_cross_mark": 0.5}, 
		"desc": "Legendaria: Shield Chain salta 3 veces más y cada golpe deja una Cruz Sagrada en el monstruo: tu Grand Cross le pega ×1,5 durante 6 s."}, 



	"padded_armor": {"name": "Padded Armor", "slot": "armor", "rank": 1, "icon": "padded_armor", 
		"mods": {"armor": 3.0, "max_hp_pct": 0.04}, "refine": {"armor": 0.8}}, 
	"silk_robe": {"name": "Silk Robe", "slot": "armor", "rank": 2, "icon": "silk_robe", 
		"mods": {"armor": 1.5, "skill_dmg": 0.06, "haste": 0.03}, "refine": {"armor": 0.5}}, 
	"thief_clothes": {"name": "Thief Clothes", "slot": "armor", "rank": 2, "icon": "thief_clothes", 
		"mods": {"armor": 1.5, "dodge": 0.04, "aspd": 0.04}, "refine": {"armor": 0.5}}, 
	"wooden_mail": {"name": "Wooden Mail", "slot": "armor", "rank": 2, "icon": "wooden_mail", 
		"mods": {"armor": 3.0, "regen": 1.0, "max_hp_pct": 0.05}, "refine": {"armor": 0.8}}, 
	"full_plate": {"name": "Full Plate", "slot": "armor", "rank": 3, "icon": "full_plate", 
		"mods": {"armor": 6.0, "max_hp_pct": 0.06, "move": -0.04}, "refine": {"armor": 1.0}}, 
	"glittering_jacket": {"name": "Glittering Jacket", "slot": "armor", "rank": 3, "icon": "glittering_jacket", 
		"mods": {"armor": 1.5, "dodge": 0.05, "crit": 0.04}, "refine": {"armor": 0.5}}, 
	"ragamuffin_manteau": {"name": "Ragamuffin Manteau", "slot": "garment", "rank": 2, "icon": "ragamuffin_manteau", 
		"mods": {"armor": 0.5, "dodge": 0.05}, "refine": {"armor": 0.5}}, 
	"pauldron": {"name": "Pauldron", "slot": "garment", "rank": 2, "icon": "pauldron", 
		"mods": {"armor": 2.0, "basic_dmg": 0.05}, "refine": {"armor": 0.5}}, 
	"ancient_cape": {"name": "Ancient Cape", "slot": "garment", "rank": 3, "icon": "ancient_cape", 
		"mods": {"armor": 1.5, "max_hp_pct": 0.05, "dodge": 0.03}, "refine": {"armor": 0.5}}, 
	"heavenly_maiden_robe": {"name": "Heavenly Maiden Robe", "slot": "garment", "rank": 3, "icon": "heavenly_maiden_robe", 
		"mods": {"skill_dmg": 0.06, "dodge": 0.03}, "refine": {"armor": 0.5}}, 
	"crystal_pumps": {"name": "Crystal Pumps", "slot": "shoes", "rank": 2, "icon": "crystal_pumps", 
		"mods": {"skill_dmg": 0.05, "move": 0.03}, "refine": {"armor": 0.5}}, 
	"high_heels": {"name": "High Heels", "slot": "shoes", "rank": 2, "icon": "high_heels", 
		"mods": {"crit": 0.04, "move": 0.03}, "refine": {"armor": 0.5}}, 
	"greaves": {"name": "Greaves", "slot": "shoes", "rank": 3, "icon": "greaves", 
		"mods": {"armor": 2.0, "max_hp_pct": 0.05, "move": 0.02}, "refine": {"armor": 0.6}}, 
	"safety_ring": {"name": "Safety Ring", "slot": "acc", "rank": 2, "icon": "safety_ring", 
		"mods": {"armor": 2.0, "dodge": 0.03}, "refine": {}}, 
	"belt": {"name": "Belt", "slot": "acc", "rank": 2, "icon": "belt", 
		"mods": {"dmg": 0.04, "max_hp_pct": 0.04}, "refine": {}}, 
	"bow_thimble": {"name": "Bow Thimble", "slot": "acc", "rank": 3, "icon": "bow_thimble", 
		"mods": {"basic_dmg": 0.06, "aspd": 0.04}, "refine": {}}, 
	"staff": {"name": "Staff", "slot": "weapon", "class": "mage", "rank": 2, "icon": "staff", 
		"mods": {"skill_dmg": 0.16, "max_hp_pct": 0.04}, "refine": {"skill_dmg": 0.04}}, 
	"wand_of_occult": {"name": "Wand of Occult", "slot": "weapon", "class": "mage", "rank": 3, "icon": "wand_of_occult", 
		"mods": {"skill_dmg": 0.18, "haste": 0.06}, "refine": {"skill_dmg": 0.04}}, 
	"great_bow": {"name": "Great Bow", "slot": "weapon", "class": "archer", "rank": 2, "icon": "great_bow", 
		"mods": {"dmg": 0.13, "crit": 0.04}, "refine": {"dmg": 0.05}}, 
	"arbalest": {"name": "Arbalest", "slot": "weapon", "class": "archer", "rank": 3, "icon": "arbalest", 
		"mods": {"dmg": 0.16, "basic_dmg": 0.06}, "refine": {"dmg": 0.05}}, 
	"hunter_bow": {"name": "Hunter Bow", "slot": "weapon", "class": "archer", "rank": 3, "icon": "hunter_bow", 
		"mods": {"dmg": 0.14, "aspd": 0.08}, "refine": {"dmg": 0.05}}, 
	"hood": {"name": "Hood", "slot": "garment", "rank": 1, "icon": "hood", 
		"mods": {"armor": 0.5, "dodge": 0.02}, "refine": {"armor": 0.5}}, 
	"muffler": {"name": "Muffler", "slot": "garment", "rank": 1, "icon": "muffler", 
		"mods": {"dodge": 0.03}, "refine": {"armor": 0.5}}, 
	"manteau": {"name": "Manteau", "slot": "garment", "rank": 2, "icon": "manteau", 
		"mods": {"armor": 1.0, "dodge": 0.04}, "refine": {"armor": 0.5}}, 
	"valkyrian_manteau": {"name": "Valkyrian Manteau", "slot": "garment", "legendary": true, "icon": "valkyrian_manteau", 
		"mods": {"dodge": 0.1, "armor": 2.0, "dmg": 0.08}, "refine": {"armor": 0.5}, "effects": {"wind_step": 1.0}, 
		"desc": "Legendaria: Paso del viento. Al esquivar un golpe ganas velocidad 2 s y tus habilidades se recargan 0.4 s antes."}, 

	"sandals": {"name": "Sandals", "slot": "shoes", "rank": 1, "icon": "sandals", 
		"mods": {"move": 0.03}, "refine": {"armor": 0.5}}, 
	"shoes": {"name": "Shoes", "slot": "shoes", "rank": 1, "icon": "shoes", 
		"mods": {"armor": 1.0, "move": 0.02}, "refine": {"armor": 0.5}}, 
	"boots": {"name": "Boots", "slot": "shoes", "rank": 2, "icon": "boots", 
		"mods": {"move": 0.05, "armor": 1.0}, "refine": {"armor": 0.5}}, 
	"sleipnir": {"name": "Sleipnir", "slot": "shoes", "legendary": true, "icon": "sleipnir", 
		"mods": {"move": 0.2, "haste": 0.1, "regen": 2.0, "magnet": 0.5}, "refine": {"armor": 0.5}, "effects": {"odin_wind": 20.0, "gallop": GALLOP_DMG}, 
		"desc": "Legendaria: Viento de Odín y Galope. Cada 20 s toda la EXP, el zeny y los minerales del mapa vienen a ti, y mientras te mueves cada 10% de velocidad de movimiento te da +1% de daño (hasta +40%)."}, 

	"clip": {"name": "Clip", "slot": "acc", "rank": 1, "icon": "clip", "mods": {"haste": 0.05}, "refine": {}}, 
	"rosary": {"name": "Rosary", "slot": "acc", "rank": 1, "icon": "rosary", "mods": {"crit": 0.04}, "refine": {}}, 
	"ring": {"name": "Ring", "slot": "acc", "rank": 2, "icon": "ring", "mods": {"dmg": 0.06}, "refine": {}}, 
	"earring": {"name": "Earring", "slot": "acc", "rank": 2, "icon": "earring", "mods": {"skill_dmg": 0.08}, "refine": {}}, 
	"glove": {"name": "Glove", "slot": "acc", "rank": 2, "icon": "glove", "mods": {"basic_dmg": 0.08, "aspd": 0.03}, "refine": {}}, 
	"brooch": {"name": "Brooch", "slot": "acc", "rank": 2, "icon": "brooch", "mods": {"dodge": 0.04, "move": 0.03}, "refine": {}}, 
	"necklace": {"name": "Necklace", "slot": "acc", "rank": 2, "icon": "necklace", "mods": {"max_hp_pct": 0.08}, "refine": {}}, 

	"embryo": {"name": "Embryo", "slot": "acc", "legendary": true, "icon": "embryo", 
		"mods": {"max_hp_pct": 0.1, "dmg": 0.08, "haste": 0.08}, "refine": {}, "effects": {"homun_extra": 1.0, "homun_power": 0.2}, 
		"desc": "Legendaria: con Call Homunculus, un Homúnculo más te acompaña y todos pegan un 20% más. Un Merchant empieza con un Homúnculo (como Call Homunculus Nv 1), que se va si elige Blacksmith."}, 
	"megingjard": {"name": "Megingjard", "slot": "acc", "legendary": true, "icon": "megingjard", 
		"mods": {"dmg": 0.25, "max_hp_pct": 0.1}, "refine": {}, "effects": {"kill_heal": 0.004, "thor": 1.0}, 
		"desc": "Legendaria: Fuerza de Thor. Cada muerte te cura y da un 1% más de daño durante 6 s (acumula hasta ×1,40)."}, 
	"brisingamen": {"name": "Brisingamen", "slot": "acc", "legendary": true, "icon": "brisingamen", 
		"mods": {"dmg": 0.1, "crit": 0.08, "haste": 0.1}, "refine": {}, "effects": {"freya": 0.12}, 
		"desc": "Legendaria: Bendición de Freya. Cada crítico recarga tus habilidades 0.12 s antes (hasta 4 veces por segundo y el 35% de cada recarga)."}, 


	"ring_flame_lord": {"name": "Ring of Flame Lord", "slot": "acc", "legendary": true, "icon": "ring_flame_lord", 
		"mods": {"proc_dmg": 0.2, "aspd": 0.08, "dmg": 0.08}, "refine": {}, "effects": {"proc_chance": 0.5}, 
		"desc": "Legendaria: tus procs del ataque básico (cartas y equipo) salen un 50% más seguido y pegan un 20% más."}, 
	"ring_resonance": {"name": "Ring of Resonance", "slot": "acc", "legendary": true, "icon": "ring_resonance", 
		"mods": {"max_hp_pct": 0.15, "armor": 3.0, "regen": 2.0}, "refine": {}, "effects": {"hit_proc": 0.5, "hit_heal": 0.03}, 
		"desc": "Legendaria: tus cartas que se lanzan al recibir un golpe salen un 50% más seguido, y cada una te cura un 3% de la vida."}, 
	"lord_kaho_horn": {"name": "Lord Kaho's Horn", "slot": "head", "legendary": true, "icon": "lord_kaho_horn", 
		"mods": {"armor": 4.0, "dmg": 0.1, "max_hp_pct": 0.08}, "refine": {"armor": 0.5}, "effects": {"status_time": 1.0, "status_vuln": 0.3}, 
		"desc": "Legendaria: tus estados (congelado, piedra, aturdido, dormido) duran +100% y los monstruos con un estado reciben un 30% más de daño."}, 
	"diabolus_manteau": {"name": "Diabolus Manteau", "slot": "garment", "legendary": true, "icon": "diabolus_manteau", 
		"mods": {"dodge": 0.08, "armor": 3.0, "dmg": 0.1}, "refine": {"armor": 0.5}, "effects": {"poison_stack": 1.0, "poison_cap": 0.5, "poison_dmg": 0.3}, 
		"desc": "Legendaria: cada dosis de veneno acumula el doble, el veneno llega a un 50% más de cargas y hace un 30% más de daño."}, 
	"diabolus_boots": {"name": "Diabolus Boots", "slot": "shoes", "legendary": true, "icon": "diabolus_boots", 
		"mods": {"move": 0.1, "haste": 0.1, "skill_dmg": 0.08}, "refine": {"armor": 0.5}, "effects": {"chain_cast": 0.2}, 
		"desc": "Legendaria: cada habilidad que lanzas acerca 0.2 s la recarga de todas las demás: cuantas más habilidades, más rápido giran."}, 
	"odin_blessing": {"name": "Odin's Blessing", "slot": "armor", "legendary": true, "icon": "odin_blessing", 
		"mods": {"armor": 6.0, "max_hp_pct": 0.15, "regen": 2.0}, "refine": {"armor": 1.0}, "effects": {"buff_power": 0.5}, 
		"desc": "Legendaria: todos tus buffs son un 50% más fuertes (Blessing, Adrenaline Rush...). En lo que tus buffs dan de daño, solo un cuarto de eso."}, 
	"bradium_shield": {"name": "Bradium Shield", "slot": "shield", "legendary": true, "icon": "bradium_shield", 
		"mods": {"armor": 6.0, "max_hp_pct": 0.1, "skill_dmg": 0.1}, "refine": {"armor": 1.0}, "effects": {"weak_bonus": 0.4}, 
		"desc": "Legendaria: todo tu daño con ventaja de elemento (ataque básico, habilidades y procs) y los combos elementales hacen un 40% más."}, 
	"ifrit_ear": {"name": "Ifrit's Ear", "slot": "head", "legendary": true, "icon": "ifrit_ear", 
		"mods": {"armor": 3.0, "dmg": 0.12, "max_hp_pct": 0.08}, "refine": {"armor": 0.5}, "effects": {"burn_time": 0.5, "burn_blast": 1.0}, 
		"desc": "Legendaria: tus quemaduras duran un 50% más y, cuando el fuego salta de un monstruo muerto, estalla en llamas a su alrededor."}, 
	"vampire_familiar": {"name": "Vampire's Familiar", "slot": "garment", "legendary": true, "icon": "vampire_familiar", 
		"mods": {"dodge": 0.06, "aspd": 0.08, "dmg": 0.1}, "refine": {"armor": 0.5}, "effects": {"bleed_at": 1.0, "bleed_chain": 1.0}, 
		"desc": "Legendaria: el sangrado revienta con 4 cargas en vez de 5 y la salpicadura deja sangrando a los que toca."}, 

	"diabolus_ring": {"name": "Diabolus Ring", "slot": "acc", "legendary": true, "icon": "diabolus_ring", 
		"mods": {"dmg": 0.1, "crit": 0.05, "max_hp_pct": 0.08}, "refine": {}, "effects": {"poison_amp": 1.0}, 
		"desc": "Legendaria: Malicia. Tu veneno corroe el doble: cada carga hace que el monstruo reciba un 2% más de daño de todos (en vez de 1%)."}, 
	"diabolus_robe": {"name": "Diabolus Robe", "slot": "armor", "legendary": true, "icon": "diabolus_robe", 
		"mods": {"armor": 4.0, "skill_dmg": 0.15, "haste": 0.08}, "refine": {"armor": 1.0}, "effects": {"chain_cast": 0.1}, 
		"desc": "Legendaria: cada habilidad que lanzas acerca 0.1 s la recarga de todas las demás."}, 
	"flame_armor": {"name": "Flame Armor", "slot": "armor", "legendary": true, "icon": "flame_armor", 
		"mods": {"armor": 5.0, "max_hp_pct": 0.1, "skill_dmg": 0.1}, "refine": {"armor": 1.0}, "effects": {"burn_power": 1.0}, 
		"desc": "Legendaria: tus quemaduras hacen +100% de daño."}, 
	"vampire_hairband": {"name": "Vampire Hairband", "slot": "head", "legendary": true, "icon": "vampire_hairband", 
		"mods": {"crit": 0.06, "basic_dmg": 0.12, "max_hp_pct": 0.06}, "refine": {"armor": 0.5}, "effects": {"bleed_power": 0.4}, 
		"desc": "Legendaria: cada corte guarda un 40% más de sangre para el reventón."}, 
	"morpheus_ring": {"name": "Morpheus's Ring", "slot": "acc", "legendary": true, "icon": "morpheus_ring", 
		"mods": {"skill_dmg": 0.1, "haste": 0.08, "max_hp_pct": 0.08}, "refine": {}, "effects": {"status_chance": 0.15}, 
		"desc": "Legendaria: tus habilidades con estado (congelar, piedra, aturdir, dormir) tienen un 15% más de probabilidad de causarlo."}, 
	"phoenix_ring": {"name": "Phoenix Ring", "slot": "acc", "legendary": true, "icon": "phoenix_ring", 
		"mods": {"aspd": 0.12, "basic_dmg": 0.1, "proc_dmg": 0.2}, "refine": {}, "effects": {"proc_chance": 0.5}, 
		"desc": "Legendaria: Llama del Fénix. Tus procs del ataque básico (cartas y equipo) salen un 50% más seguido y pegan un 20% más."}, 
	"bloody_knight_shield": {"name": "Bloody Knight Shield", "slot": "shield", "legendary": true, "icon": "bloody_knight_shield", "view": "shield", 
		"mods": {"armor": 7.0, "max_hp_pct": 0.12, "regen": 1.5}, "refine": {"armor": 1.0}, "effects": {"hit_proc": 0.3}, 
		"desc": "Legendaria: tus cartas que se lanzan al recibir un golpe salen un 30% más seguido."}, 
	"odin_mask": {"name": "Odin Mask", "slot": "head", "legendary": true, "icon": "odin_mask", 
		"mods": {"max_hp_pct": 0.1, "haste": 0.08, "regen": 2.0}, "refine": {"armor": 0.5}, "effects": {"heal_power": 0.3, "buff_power": 0.2}, 
		"desc": "Legendaria: tus curaciones curan un 30% más y tus buffs son un 20% más fuertes. En lo que tus buffs dan de daño, solo un cuarto de eso."}, 
	"paracelsus_coat": {"name": "Paracelsus Coat", "slot": "armor", "legendary": true, "icon": "paracelsus_coat", 
		"mods": {"armor": 4.0, "max_hp_pct": 0.12, "skill_dmg": 0.08}, "refine": {"armor": 1.0}, 
		"effects": {"summon_dmg": 0.5, "homun_power": 0.4, "falcon_dmg": 0.4}, 
		"desc": "Legendaria: tus invocaciones y tu halcón pegan más: los animales del Doram un 50%, el halcón un 40%, y los homúnculos y las plantas un 90%."}, 
	"bradium_earring": {"name": "Bradium Earring", "slot": "acc", "legendary": true, "icon": "bradium_earring", 
		"mods": {"skill_dmg": 0.12, "dmg": 0.06, "haste": 0.06}, "refine": {}, "effects": {"weak_bonus": 0.2}, 
		"desc": "Legendaria: todo tu daño con ventaja de elemento (ataque básico, habilidades y procs) hace un 20% más."}, 
	"critical_ring": {"name": "Critical Ring", "slot": "acc", "legendary": true, "icon": "critical_ring", 
		"mods": {"crit": 0.12, "crit_dmg": 0.5, "aspd": 0.08, "dmg": 0.08}, "refine": {}, "effects": {}, 
		"desc": "Legendaria: +12% de crítico y +50% de daño crítico."}, 




	"crescent_scythe": {"name": "Crescent Scythe", "slot": "weapon", "class": "swordsman", "unique": true, "legendary": true, 
		"stage": "prontera", "icon": "crescent_scythe", "mods": {"dmg": 0.35, "crit": 0.05}, "refine": {"dmg": 0.05}, 
		"effects": {"splash": 2.0, "u_scythe": 7.0}, 
		"desc": "Única de Baphomet: tu ataque básico siega en media luna a tu alrededor y cada 7 golpes la guadaña del Señor de los Demonios cae sobre todos los que te rodean y te devuelve vida por cada uno. Cada monstruo segado le da un alma (un jefe, 4): giran a tu alrededor y cada una suma un 4% al daño de la guadaña. Con 20, la siguiente es la Luna Sangrienta: tres tajos cada vez más amplios, cada uno el doble de fuerte ×Lv."}, 
	"golden_bug_shell": {"name": "Golden Thief Bug Shell", "slot": "shield", "unique": true, "legendary": true, 
		"stage": "culvert", "icon": "golden_bug_shell", "view": "mirror", "mods": {"armor": 4.0, "max_hp_pct": 0.08}, "refine": {"armor": 0.5}, 
		"effects": {"u_goldbug": 0.6}, 
		"desc": "Única del Golden Thief Bug: su caparazón dorado detiene el 60% del daño de proyectiles, hechizos y mecánicas, y lo devuelve triplicado al monstruo más cercano, con una onda dorada a tu alrededor."}, 
	"tiger_footskin": {"name": "Tiger Footskin", "slot": "shoes", "unique": true, "legendary": true, 
		"stage": "payon", "icon": "tiger_footskin", "mods": {"move": 0.12, "max_hp_pct": 0.1}, "refine": {"max_hp_pct": 0.01}, 
		"effects": {"u_tiger": 1.0}, 
		"desc": "Única de Eddga: el Endure del tigre. Cada golpe que recibes (como mucho uno cada 0,5 s) suma una Furia, hasta 10: con la furia despierta tienes +35% de velocidad y +35% de velocidad de ataque, y cada Furia te da +5% de daño, un multiplicador aparte de tus otros bonos (×1,50 con 10; no a venenos, quemaduras ni sangrados). Se apaga 6 s después del último golpe. Cada 5 Furias el tigre ruge y golpea a tu alrededor (radio 4,5 m) ×Lv; con las 10, el Endure: recibes un 15% menos de daño."}, 
	"moonlight_dagger": {"name": "Moonlight Dagger", "slot": "weapon", "class": "thief", "unique": true, "legendary": true, 
		"stage": "pay_cave", "icon": "moonlight_dagger", "weapon_type": "dagger", "mods": {"dmg": 0.25, "aspd": 0.15}, 
		"refine": {"dmg": 0.05}, "effects": {"lifesteal": 0.03, "u_moon": 0.35}, 
		"desc": "Única de Moonlight Flower: tus ataques básicos sueltan pétalos de luna que saltan entre 5 monstruos y te curan ×Lv. Sirve en la mano izquierda."}, 
	"orc_hero_helm": {"name": "Orc Hero Helm", "slot": "head", "unique": true, "legendary": true, "view": "hat_orc_hero", 
		"stage": "orc", "icon": "orc_hero_helm", "mods": {"armor": 2.0, "max_hp_pct": 0.08}, "refine": {"armor": 0.3}, 
		"effects": {"u_orc": 0.08}, 
		"desc": "Única del Orc Hero: el héroe pelea mejor rodeado. Un 8% más de daño por cada monstruo a tu alrededor (hasta ×1,80)."}, 
	"orcish_axe": {"name": "Orcish Axe", "slot": "weapon", "class": "merchant", "unique": true, "legendary": true, 
		"stage": "orc_dun", "icon": "orcish_axe", "mods": {"dmg": 0.35, "max_hp_pct": 0.08}, "refine": {"dmg": 0.05}, 
		"effects": {"u_quake": 6.0}, 
		"desc": "Única del Orc Lord: cada 6 golpes básicos el hacha parte el suelo: un Terremoto golpea y aturde a todos a tu alrededor y abre 4 grietas que corren hacia afuera. Cada uno suma furia, y el quinto es el Gran Terremoto: mucho más amplio y fuerte, aturde a todos (a los jefes les llena el Aguante) y abre 8 ríos de lava que queman ×Lv."}, 
	"bone_helm": {"name": "Bone Helm", "slot": "head", "unique": true, "legendary": true, "view": "hat_bone_helm", 
		"stage": "glast", "icon": "bone_helm", "mods": {"armor": 2.0, "dmg": 0.05}, "refine": {"armor": 0.3}, 
		"effects": {"u_bone": 0.25}, 
		"desc": "Única del Dark Lord: 1 de cada 4 monstruos que matas se levanta como esqueleto (hasta 8): te rodean, reciben los golpes por ti y estallan al romperse. Pegan según tu vida máxima y cada golpe te la sube. Ante un jefe se alza un Skeleton General ×Lv."}, 
	"bishop_bible": {"name": "Bible of the Fallen Bishop", "slot": "weapon", "class": "acolyte", "unique": true, "legendary": true, 
		"stage": "nameless", "icon": "bishop_bible", "mods": {"skill_dmg": 0.25}, "refine": {"skill_dmg": 0.04}, 
		"effects": {"u_bishop": 3.0, "heal_power": 0.3}, 
		"desc": "Única del Fallen Bishop: cada curación que te lanzan estalla en luz sagrada, también con la vida llena (Sagrado, como mucho dos veces por segundo): hiere a los monstruos a 5 m con el triple de la curación, más a no-muertos y demonios, y crece con tu daño de habilidades y tu área. No depende de Holy Light. Cada 3,5 s el obispo reza por ti y te cura un 4% de vida."}, 
	"beelzebub_wing": {"name": "Beelzebub's Wing", "slot": "acc", "unique": true, "legendary": true, "view": "hat_beelzebub_wing", 
		"stage": "abbey", "icon": "beelzebub_wing", "mods": {"move": 0.05, "crit": 0.04}, "refine": {"dmg": 0.02}, 
		"effects": {"u_flies": 4.0}, 
		"desc": "Única de Beelzebub: 4 Hunter Fly giran a tu alrededor; cada 0,4 s pican a los monstruos a 6 m (60 ×Lv, +0,1% de vida) y los infestan 6 s. Un infestado que muere estalla en moscas: 600 ×Lv a los 3 más cercanos, que quedan infestados, en cadena por la horda. Cada muerte suma una mosca por 8 s (hasta 12). Crece con FUE, Daño básico y Daño de procs."}, 
	"huuma_kraken": {"name": "Huuma Kraken", "slot": "weapon", "class": "ninja", "unique": true, "legendary": true, 
		"stage": "byalan", "icon": "huuma_kraken", "mods": {"dmg": 0.3, "aspd": 0.12}, "refine": {"dmg": 0.05}, 
		"effects": {"u_kraken": 1.8}, 
		"desc": "Única del Kraken: cada 1,8 s el Kraken lanza su Huuma de agua, que salta entre 8 monstruos y puede congelarlos (combo con Viento)."}, 
	"turtle_shell": {"name": "Turtle General Shell", "slot": "armor", "unique": true, "legendary": true, 
		"stage": "turtle", "icon": "turtle_shell", "mods": {"armor": 6.0, "max_hp_pct": 0.15, "move": -0.05}, "refine": {"armor": 0.5}, 
		"effects": {"u_turtle": 0.25}, "proc_hit": {"skill": "magnum_break", "chance": 0.25, "level": 5}, 
		"desc": "Única del Turtle General: -25% de todo el daño que recibes, y uno de cada 4 golpes que recibes responde con Magnum Break."}, 
	"osiris_ankh": {"name": "Ankh of Osiris", "slot": "acc", "unique": true, "legendary": true, 
		"stage": "pyramid", "icon": "osiris_ankh", "mods": {"max_hp_pct": 0.05, "regen": 1.0}, "refine": {"dmg": 0.02}, 
		"effects": {"u_ankh": 1.0}, 
		"desc": "Única de Osiris: el rey de la Pirámide no deja que mueras. Al caer vuelves a la vida con toda la vida y 5 s de invulnerabilidad, y una ola sagrada arrasa a tu alrededor (radio 9 m); mientras dura, el juicio de Osiris quema a todos a tu alrededor (radio 4 m) cada 0,5 s ×Lv. Se recarga en 150 s (la luz dorada sobre tu cabeza: listo) y se usa antes que las Yggdrasil Leaf."}, 
	"maya_crown": {"name": "Crown of Maya", "slot": "head", "unique": true, "legendary": true, "view": "hat_maya_crown", 
		"stage": "anthell", "icon": "maya_crown", "mods": {"armor": 1.0, "dmg": 0.05}, "refine": {"dmg": 0.02}, 
		"effects": {"u_maya": 8.0}, 
		"desc": "Única de Maya: la reina del hormiguero te cede su guardia. Hormigas soldado (Andre, Piere, Deniro) brotan del suelo golpeando y pelean a tu lado, hasta 8 ×Lv."}, 


	"sword_wings": {"name": "Sword Wings", "slot": "wings", "wings": true, "rank": 99, "icon": "sword_wings", "view": "sword_wings", "bound": true, 
		"mods": {"dmg": 0.3, "max_hp_pct": 0.3, "aspd": 0.2, "haste": 0.2, "move": 0.1, "count": 1.0}, 
		"desc": "Alas forjadas en la cima de la Torre. Quien las lleva pelea con todo: +30% de daño y vida, +20% de velocidad de ataque y recarga, +10% de movimiento y +1 a todo lo que lanzas. Sus huecos solo aceptan cartas de MVP, de cualquier tipo, y las alas brillan con su color."}, 
	"queen_wings": {"name": "Wings of the Queen", "slot": "garment", "unique": true, "legendary": true, "view": "queen_wings", 
		"stage": "mjolnir", "icon": "queen_wings", "mods": {"dodge": 0.05, "move": 0.05}, "refine": {"dodge": 0.005}, 
		"effects": {"u_queen": 1.0}, 
		"desc": "Única de Mistress, Tormenta de la Reina: al moverte las alas juntan carga estática, 1 cada 0,5 s (quieto no se carga), y tus golpes de Viento suman 1 más (como mucho 1 cada 0,5 s). Con 20 cargas se descargan solas en cuanto un monstruo está a 6 m: durante 3 s una tormenta de rayos te sigue y golpea cada 0,25 s a todos los monstruos a 6 m de ti (hasta 40; 12 golpes; más ancha con tu área). Luego la carga vuelve a 0 ×Lv."}, 
	"storm_bow": {"element": "wind", "name": "Owl Baron's Storm Bow", "slot": "weapon", "class": "archer", "unique": true, "legendary": true, 
		"stage": "clock_tower", "icon": "storm_bow", "mods": {"dmg": 0.25, "crit": 0.1}, "refine": {"dmg": 0.05}, 
		"effects": {"u_owl": 1.0}, 
		"desc": "Única del Owl Baron: arco de Viento. Cada crítico de tu ataque básico llama un Jupitel Thunder sobre el monstruo, que salta a 3 monstruos cercanos más (75% del daño); si está solo (un MVP), lo golpea dos veces más."}, 
	"lich_wand": {"name": "Lich's Bone Wand", "slot": "weapon", "class": "mage", "unique": true, "legendary": true, 
		"stage": "niflheim", "icon": "lich_wand", "mods": {"skill_dmg": 0.3, "area": 0.1}, "refine": {"skill_dmg": 0.04}, 
		"effects": {"u_coma": 0.05}, 
		"desc": "Única del Lord of Death: cada golpe de tus habilidades mágicas tiene un 5% de dejar en Coma a un monstruo: ese golpe hace ×8 de daño. Un jefe en Coma recibe el doble de daño de todos durante 4 s (como mucho una vez cada 7 s). El ataque básico y los procs no lo provocan."}, 


	"imperial_guard": {"name": "Imperial Guard", "slot": "shield", "unique": true, "legendary": true, "view": "mirror", 
		"stage": "prontera", "icon": "imperial_guard", "mods": {"armor": 6.0, "max_hp_pct": 0.12}, "refine": {"max_hp_pct": 0.015}, 
		"effects": {"u_bulwark": 1.0, "block": 0.1}, 
		"desc": "Única de Baphomet: +10% de bloqueo. Bloquear, esquivar y recibir golpes carga el Baluarte (6 niveles). R lo descarga: nada te daña un momento y una onda de 7 m (+1 m por nivel) golpea y lanza lejos a los monstruos y llena el Aguante de los jefes. Crece con FUE y vida máxima."}, 
	"juperos_railgun": {"name": "Juperos Railgun", "slot": "weapon", "class": "gunslinger", "unique": true, "legendary": true, 
		"stage": "juperos", "icon": "juperos_railgun", "mods": {"dmg": 0.3, "crit_dmg": 0.4}, "refine": {"dmg": 0.05}, 
		"effects": {"u_overload": 1.0}, 
		"desc": "Única de Vesper: el Cañón Apocalipsis. Todo el daño de tu ataque básico se guarda como energía, y cada ataque carga el cañón: 8 niveles, cada uno pide más ataques que el anterior (la barra bajo tus pies). R lo dispara: un rayo que cruza el mapa entero, más ancho con tu área, y descarga toda la energía en cada monstruo que toca: x1 con el nivel 1, hasta x10 con el 8. La energía no tiene límite."}, 

	"santa_hat": {"name": "Santa's Hat", "slot": "head", "unique": true, "legendary": true, "view": "hat_santa", 
		"stage": "toy_factory", "icon": "santa_hat", "mods": {"max_hp_pct": 0.08, "armor": 1.0}, "refine": {"max_hp_pct": 0.01}, 
		"effects": {"u_gift": 3.0}, 
		"desc": "Única de Stormy Knight: Navidad en Lutie. Cada 3 s y con cada habilidad de Apoyo que lanzas (buff, curación o barrera) repartes 3 regalos: vuelan a los monstruos cercanos y estallan, y cada uno te cura un poco. Crecen con tu efecto de Apoyo (DES) ×Lv."}, 








	"fists": {"name": "Puños", "slot": "weapon", "class": "taekwon", "legendary": true, "fixed": true, "bound": true, "fixed_slots": 2, "icon": "fists", 
		"fists": 0.004, "mods": {"dmg": 0.1}, "refine": {"dmg": 0.05}, "effects": {"kick_cap": 10.0}, 
		"desc": "Sin armas: tus Puños están en tu Almacén Kafra (uno por cuenta) y no se venden, no se cambian ni se rompen. Nakurusa los refina y les da grado y Abstract les pone Cartas Eternas: empiezas cada partida con ellos así. Crecen con tu Base Lv y, si te vuelves Star Gladiator, evolucionan conservando refinamiento, cartas y grado (el Soul Linker los cambia por un libro). Con ellos, Taekwon Mission llega a una racha de 30 en vez de 20."}, 
	"star_fists": {"name": "Puños Estelares", "slot": "weapon", "class": "taekwon", "legendary": true, "fixed": true, "fixed_slots": 2, "icon": "star_fists", 
		"job": ["star_gladiator"], "bound": true, "fists": 0.006, "mods": {"dmg": 0.2}, "refine": {"dmg": 0.06}, "effects": {"kick_cap": 10.0}, 
		"desc": "Tus Puños evolucionados: arden con el poder de las estrellas. Más daño y crecen más rápido con tu Base Lv. Conservan el refinamiento, las cartas y el grado de tus Puños. Con ellos, Taekwon Mission llega a una racha de 30 en vez de 20."}, 


	"book_billows": {"name": "Book of Billows", "slot": "weapon", "class": "taekwon", "job": ["soul_linker"], "rank": 1, "fixed_slots": 1, "icon": "book_billows", 
		"mods": {"skill_dmg": 0.08, "haste": 0.04}, "refine": {"skill_dmg": 0.03}, "effects": {"eswoo_vuln": 0.2}, 
		"desc": "Eswoo marca a los monstruos: mientras están encogidos reciben ×1,2 de daño de todo el grupo."}, 
	"book_gust": {"name": "Book of Gust of Wind", "slot": "weapon", "class": "taekwon", "job": ["soul_linker"], "rank": 2, "fixed_slots": 2, "icon": "book_gust", 
		"mods": {"skill_dmg": 0.12, "aspd": 0.1}, "refine": {"skill_dmg": 0.03}, "effects": {"soul_time": 0.5}, 
		"desc": "Los espíritus de Soul Link lanzan su habilidad un 50% más seguido y su poder dura un 50% más en tus aliados."}, 
	"book_earth": {"name": "Book of Mother Earth", "slot": "weapon", "class": "taekwon", "job": ["soul_linker"], "rank": 2, "fixed_slots": 2, "icon": "book_earth", 
		"mods": {"skill_dmg": 0.1, "max_hp_pct": 0.1}, "refine": {"skill_dmg": 0.03}, "effects": {"kaite_power": 0.6}, 
		"desc": "Kaite absorbe un 60% más de daño."}, 
	"book_sun": {"name": "Book of the Blazing Sun", "slot": "weapon", "class": "taekwon", "job": ["soul_linker"], "rank": 3, "fixed_slots": 3, "icon": "book_sun", 
		"mods": {"skill_dmg": 0.18}, "refine": {"skill_dmg": 0.04}, "effects": {"spirit_seek": 1.0}, 
		"desc": "Estin y Esma buscan solos el elemento que más daña a los monstruos que golpean, sin necesitar Mild Wind."}, 
	"book_dragon": {"name": "Legacy of Dragon", "slot": "weapon", "class": "taekwon", "job": ["soul_linker"], "rank": 3, "fixed_slots": 3, "icon": "book_dragon", 
		"mods": {"skill_dmg": 0.15, "haste": 0.08}, "refine": {"skill_dmg": 0.04}, "effects": {"soul_double": 1.0}, 
		"desc": "Soul Link presta dos espíritus distintos a la vez, también a tus aliados."}, 



	"reaper_ledger": {"name": "Book of the Dead", "slot": "weapon", "class": "taekwon", "job": ["soul_linker", "sage", "professor"], "unique": true, "legendary": true, 
		"stage": "thanatos", "icon": "reaper_ledger", "mods": {"dmg": 0.25, "crit": 0.05}, "refine": {"dmg": 0.05}, 
		"effects": {"u_reaper": 10.0}, 
		"desc": "Única de Thanatos: el registro del dios de la muerte. Cada monstruo que matas te da un alma (hasta 10; cada una un 3% más de daño, hasta ×1,30). Con 10 se desata solo el Juicio de Thanatos sobre todo lo que te rodea ×Lv."}, 


	"star_blessing": {"name": "Star of Blessing", "slot": "acc", "class": "taekwon", "job": ["star_gladiator"], "unique": true, "legendary": true, 
		"stage": "thanatos", "icon": "star_blessing", "mods": {"dmg": 0.15, "aspd": 0.1}, "refine": {"dmg": 0.03}, 
		"effects": {"u_cosmos": 1.0}, 
		"desc": "Única de Thanatos para el Star Gladiator: la Unión del Sol, la Luna y las Estrellas dura el triple, no te cuesta vida y, al terminar, vuelve en la mitad de tiempo."}, 


	"infiltrator": {"name": "Infiltrator", "slot": "weapon", "class": "thief", "job": ["assassin", "assassin_cross"], "unique": true, "legendary": true, 
		"weapon_type": "katar", "stage": "biolab", "icon": "jamadhar", "mods": {"dmg": 0.3, "crit": 0.1}, "refine": {"dmg": 0.05}, 
		"effects": {"u_sonic": 1.0}, 
		"desc": "Única de Eremes Guile: el katar del asesino del laboratorio. Cada Sonic Blow le graba dos tajos a su objetivo (un jefe antes que nadie); con los 8 la marca estalla con todo el veneno que tiene encima, el doble de lo que le quedaba por hacer, y lo contagia a los de alrededor."}, 

	"clone_blade": {"name": "Clone Blade", "slot": "weapon", "class": "super_novice", "also_class": ["swordsman"], "unique": true, "legendary": true, 
		"stage": "biolab", "icon": "clone_blade", "mods": {"dmg": 0.3, "crit": 0.06}, "refine": {"dmg": 0.05}, 
		"effects": {"u_clones": 1.5}, 
		"desc": "Única de Lord Knight Seyren: la hoja de los experimentos de Lighthalzen. Cada 1,5 s un clon del laboratorio lucha por ti y lanza su habilidad dos veces: Bowling Bash, Sonic Blow, Cart Termination, Heal, Sharp Shooting o Storm Gust. Vienen los seis por turno, y cuando llegan todos, el Experimento Final: los seis a la vez a tu alrededor ×Lv."}, 


	"ifrit_mask": {"name": "Ifrit Mask", "slot": "head", "unique": true, "legendary": true, "view": "hat_ifrit_mask", 
		"stage": "thor", "icon": "ifrit_mask", "mods": {"skill_dmg": 0.12, "max_hp_pct": 0.06}, "refine": {"skill_dmg": 0.02}, 
		"effects": {"u_volcano": 12.0}, 
		"desc": "Única de Ifrit: el volcán late con tus hechizos. Cada habilidad que lanzas aviva su Calor (las brasas que giran a tu alrededor); con 12, Ifrit erupciona: una columna de lava arrasa y quema todo a tu alrededor, el suelo sigue ardiendo 8 s y, durante 6 s, tus habilidades se recargan un 50% más rápido. Durante esos 6 s el Calor sube a la mitad de velocidad, y otra erupción suma su lava sin alargarlos ×Lv."}, 

	"glacial_heart": {"name": "Glacial Heart", "slot": "acc", "unique": true, "legendary": true, 
		"stage": "ice_dun", "icon": "glacial_heart", "mods": {"max_hp_pct": 0.06, "armor": 2.0}, "refine": {"max_hp_pct": 0.01}, 
		"effects": {"u_shatter": 1.0}, 
		"desc": "Única de Ktullanux: el hielo eterno. Tus golpes congelan a veces (los de Agua, mucho más a menudo). Golpear a un monstruo congelado lo hace añicos: estalla en esquirlas que hieren y congelan a los de alrededor, y la cadena sigue con cada golpe. Contra un jefe, cada congelación llena su Aguante y su hielo también estalla ×Lv."}, 

	"dark_rune": {"name": "Dark Rune", "slot": "acc", "unique": true, "legendary": true, 
		"stage": "ra_san", "icon": "dark_rune", "mods": {"dmg": 0.08, "dodge": 0.04}, "refine": {"dmg": 0.02}, 
		"effects": {"u_gloom": 1.0}, 
		"desc": "Única de Gloom Under Night: la noche que dormía bajo el templo de Freyja. Cada 15 s cae la noche a tu alrededor durante 6 s y te sigue: los monstruos en la oscuridad pierden tu rastro (van mucho más lentos) y reciben ×1,35 de daño de todo el grupo (los jefes ×1,15). Cada monstruo que derrotas en la oscuridad la alarga medio segundo, hasta 12 s."}, 

	"diabolus_helm": {"name": "Diabolus Helm", "slot": "head", "legendary": true, "icon": "diabolus_helm", 
		"mods": {"armor": 2.0, "dmg": 0.1, "max_hp_pct": 0.08}, "refine": {"armor": 0.5}, "effects": {"poison_dmg": 0.3}, 
		"desc": "Legendaria: tu veneno hace un 30% más de daño."}, 
	"diabolus_armor": {"name": "Diabolus Armor", "slot": "armor", "legendary": true, "icon": "diabolus_armor", 
		"mods": {"armor": 4.0, "max_hp_pct": 0.12, "dmg": 0.05}, "refine": {"armor": 0.5}, "effects": {"poison_cap": 0.5}, 
		"desc": "Legendaria: el veneno llega a un 50% más de cargas."}, 
	"archmage_hat": {"name": "Archmage Hat", "slot": "head", "legendary": true, "icon": "archmage_hat", 
		"mods": {"armor": 1.0, "skill_dmg": 0.12, "max_hp_pct": 0.06}, "refine": {"armor": 0.5}, "effects": {"chain_cast": 0.08}, 
		"desc": "Legendaria: cada habilidad acerca 0.08 s la recarga de las demás."}, 
	"arcane_manteau": {"name": "Arcane Manteau", "slot": "garment", "legendary": true, "icon": "arcane_manteau", 
		"mods": {"armor": 2.0, "haste": 0.1, "dodge": 0.04}, "refine": {"armor": 0.5}, "effects": {}, 
		"desc": "Legendaria: -10% de recarga."}, 
	"surtr_ring": {"name": "Surtr's Ring", "slot": "acc", "legendary": true, "icon": "surtr_ring", 
		"mods": {"dmg": 0.1, "crit": 0.04}, "refine": {}, "effects": {"burn_power": 0.3}, 
		"desc": "Legendaria: tus quemaduras queman un 30% más fuerte."}, 
	"ifrit_manteau": {"name": "Ifrit's Mantle", "slot": "garment", "legendary": true, "icon": "ifrit_manteau", 
		"mods": {"armor": 2.0, "max_hp_pct": 0.1, "dmg": 0.06}, "refine": {"armor": 0.5}, "effects": {"burn_time": 0.3, "burn_heat_start": 10.0}, 
		"desc": "Legendaria: tus quemaduras duran un 30% más y prenden con 10 de Calor."}, 
	"vampire_fang": {"name": "Vampire's Fang", "slot": "acc", "legendary": true, "icon": "vampire_fang", 
		"mods": {"dmg": 0.1, "aspd": 0.06}, "refine": {}, "effects": {"bleed_power": 0.3}, 
		"desc": "Legendaria: cada corte guarda un 30% más de sangre."}, 
	"blood_boots": {"name": "Bloodied Boots", "slot": "shoes", "legendary": true, "icon": "blood_boots", 
		"mods": {"move": 0.1, "dmg": 0.06, "max_hp_pct": 0.06}, "refine": {"armor": 0.5}, "effects": {"bleed_dmg": 0.3}, 
		"desc": "Legendaria: tus reventones de sangrado hacen un 30% más."}, 
	"morpheus_shawl": {"name": "Morpheus's Shawl", "slot": "garment", "legendary": true, "icon": "morpheus_shawl", 
		"mods": {"armor": 2.0, "skill_dmg": 0.08, "max_hp_pct": 0.06}, "refine": {"armor": 0.5}, "effects": {"status_time": 0.3}, 
		"desc": "Legendaria: tus estados duran un 30% más."}, 
	"morpheus_bracelet": {"name": "Morpheus's Bracelet", "slot": "acc", "legendary": true, "icon": "morpheus_bracelet", 
		"mods": {"skill_dmg": 0.1, "haste": 0.06}, "refine": {}, "effects": {"status_vuln": 0.15}, 
		"desc": "Legendaria: los monstruos con un estado reciben un 15% más."}, 
	"flame_lord_crown": {"name": "Crown of the Flame Lord", "slot": "head", "legendary": true, "icon": "flame_lord_crown", 
		"mods": {"armor": 2.0, "aspd": 0.08, "dmg": 0.06}, "refine": {"armor": 0.5}, "effects": {"proc_chance": 0.25}, 
		"desc": "Legendaria: tus procs del ataque básico salen un 25% más seguido."}, 
	"phoenix_mantle": {"name": "Phoenix Mantle", "slot": "garment", "legendary": true, "icon": "phoenix_mantle", 
		"mods": {"armor": 2.0, "max_hp_pct": 0.08, "proc_dmg": 0.25}, "refine": {"armor": 0.5}, "effects": {}, 
		"desc": "Legendaria: todos tus procs pegan un 25% más."}, 
	"bloody_knight_armor": {"name": "Bloody Knight Armor", "slot": "armor", "legendary": true, "icon": "bloody_knight_armor", 
		"mods": {"armor": 5.0, "max_hp_pct": 0.15}, "refine": {"armor": 0.5}, "effects": {"hit_proc": 0.25}, 
		"desc": "Legendaria: tus cartas al recibir un golpe salen un 25% más seguido."}, 
	"resonance_helm": {"name": "Helm of Resonance", "slot": "head", "legendary": true, "icon": "resonance_helm", 
		"mods": {"armor": 3.0, "max_hp_pct": 0.1, "proc_dmg": 0.1}, "refine": {"armor": 0.5}, "effects": {"hit_heal": 0.02}, 
		"desc": "Legendaria: cada carta que salta al recibir un golpe te cura un 2%."}, 
	"odin_mantle": {"name": "Odin's Mantle", "slot": "garment", "legendary": true, "icon": "odin_mantle", 
		"mods": {"armor": 2.0, "max_hp_pct": 0.1, "regen": 1.0}, "refine": {"armor": 0.5}, "effects": {"heal_power": 0.3}, 
		"desc": "Legendaria: tus curaciones curan un 30% más."}, 
	"odin_boots": {"name": "Boots of Odin", "slot": "shoes", "legendary": true, "icon": "odin_boots", 
		"mods": {"move": 0.1, "haste": 0.08}, "refine": {"armor": 0.5}, "effects": {"buff_power": 0.3}, 
		"desc": "Legendaria: tus buffs son un 30% más fuertes. En lo que tus buffs dan de daño, solo un cuarto de eso."}, 
	"paracelsus_hat": {"name": "Paracelsus's Hat", "slot": "head", "legendary": true, "icon": "paracelsus_hat", 
		"mods": {"armor": 2.0, "max_hp_pct": 0.08, "haste": 0.05}, "refine": {"armor": 0.5}, "effects": {"summon_dmg": 0.3, "falcon_dmg": 0.3}, 
		"desc": "Legendaria: tus invocaciones y tu halcón pegan un 30% más."}, 
	"homunculus_charm": {"name": "Homunculus Charm", "slot": "acc", "legendary": true, "icon": "embryo", 
		"mods": {"dmg": 0.08, "max_hp_pct": 0.06}, "refine": {}, "effects": {"homun_power": 0.3}, 
		"desc": "Legendaria: tus Homúnculos pegan un 30% más."}, 
	"bradium_helm": {"name": "Bradium Helm", "slot": "head", "legendary": true, "icon": "bradium_helm", 
		"mods": {"armor": 3.0, "dmg": 0.08, "max_hp_pct": 0.06}, "refine": {"armor": 0.5}, "effects": {"weak_bonus": 0.2}, 
		"desc": "Legendaria: todo tu daño con ventaja de elemento (ataque básico, habilidades y procs) hace un 20% más."}, 
	"bradium_armor": {"name": "Bradium Armor", "slot": "armor", "legendary": true, "icon": "bradium_armor", 
		"mods": {"armor": 5.0, "max_hp_pct": 0.12}, "refine": {"armor": 0.5}, "effects": {"weak_bonus": 0.2}, 
		"desc": "Legendaria: todo tu daño con ventaja de elemento (ataque básico, habilidades y procs) hace un 20% más."}, 
	"freya_crown": {"name": "Crown of Freya", "slot": "head", "legendary": true, "icon": "freya_crown", 
		"mods": {"armor": 2.0, "crit": 0.06, "crit_dmg": 0.2}, "refine": {"armor": 0.5}, "effects": {}, 
		"desc": "Legendaria: +6% de crítico y +20% de daño crítico."}, 
	"freya_cape": {"name": "Freya's Cape", "slot": "garment", "legendary": true, "icon": "freya_cape", 
		"mods": {"armor": 2.0, "crit": 0.04, "max_hp_pct": 0.06}, "refine": {"armor": 0.5}, "effects": {"freya": 0.06}, 
		"desc": "Legendaria: cada crítico recarga tus habilidades 0.06 s antes (hasta 4 veces por segundo y el 35% de cada recarga)."}, 
	"jarngreipr": {"name": "Jarngreipr", "slot": "acc", "legendary": true, "icon": "jarngreipr", 
		"mods": {"dmg": 0.12, "area": 0.08}, "refine": {}, "effects": {}, 
		"desc": "Legendaria: los guantes de Thor: +12% de daño y +8% de área."}, 
	"thor_helm": {"name": "Helm of Thor", "slot": "head", "legendary": true, "icon": "thor_helm", 
		"mods": {"armor": 3.0, "max_hp_pct": 0.1, "dmg": 0.06}, "refine": {"armor": 0.5}, "effects": {"kill_heal": 0.003}, 
		"desc": "Legendaria: cada muerte te cura un poco."}, 

	"executioner_gloves": {"name": "Executioner's Gloves", "slot": "acc", "legendary": true, "icon": "executioner_gloves", 
		"mods": {"dmg": 0.08, "aspd": 0.06}, "refine": {}, "effects": {"stagger_hit": 0.2}, 
		"desc": "Legendaria: cada golpe tuyo a un jefe llena un poco su Aguante."}, 
	"punishment_shoes": {"name": "Shoes of Punishment", "slot": "shoes", "legendary": true, "icon": "punishment_shoes", 
		"mods": {"move": 0.1, "dmg": 0.05}, "refine": {"armor": 0.5}, "effects": {"wing_fill": 0.15}, 
		"desc": "Legendaria: llenas el Aguante de los jefes un 15% más rápido."}, 
	"asprika": {"name": "Asprika", "slot": "garment", "legendary": true, "icon": "asprika", 
		"mods": {"armor": 2.0, "max_hp_pct": 0.1}, "refine": {"armor": 0.5}, "effects": {"wing_broken": 0.15}, 
		"desc": "Legendaria: los jefes aturdidos por el Aguante reciben otro 15% de daño."}, 
	"imperial_ring": {"name": "Imperial Ring", "slot": "acc", "legendary": true, "icon": "imperial_ring", 
		"mods": {"dmg": 0.1}, "refine": {}, "effects": {"wing_stun": 0.5}, 
		"desc": "Legendaria: el aturdimiento del Aguante dura 0,5 s más."}, 
	"einherjar_boots": {"name": "Boots of the Einherjar", "slot": "shoes", "legendary": true, "icon": "einherjar_boots", 
		"mods": {"move": 0.1, "dmg": 0.12, "aspd": 0.06}, "refine": {"armor": 0.5}, "effects": {}, 
		"desc": "Legendaria: +12% de daño y +6% de velocidad de ataque."}, 
	"valkyrie_ring": {"name": "Ring of the Valkyrie", "slot": "acc", "legendary": true, "icon": "valkyrie_ring", 
		"mods": {"dmg": 0.1, "haste": 0.08, "max_hp_pct": 0.06}, "refine": {}, "effects": {}, 
		"desc": "Legendaria: +10% de daño y -8% de recarga."}, 
	"valkyrja_greaves": {"name": "Valkyrja's Greaves", "slot": "shoes", "legendary": true, "icon": "valkyrja_greaves", 
		"mods": {"move": 0.08, "dodge": 0.08, "armor": 2.0}, "refine": {"armor": 0.5}, "effects": {}, 
		"desc": "Legendaria: +8% de evasión."}, 
	"aegis_helm": {"name": "Helm of the Aegis", "slot": "head", "legendary": true, "icon": "aegis_helm", 
		"mods": {"armor": 4.0, "max_hp_pct": 0.1}, "refine": {"armor": 0.5}, "effects": {"block": 0.05}, 
		"desc": "Legendaria: 5% de bloquear cada golpe."}, 


	"aegis_reginleif": {"name": "Aegis of Reginleif", "slot": "garment", "unique": true, "legendary": true, "route": "light", 
		"icon": "aegis_reginleif", "mods": {"max_hp_pct": 0.1, "armor": 2.0}, "refine": {"max_hp_pct": 0.01}, 
		"effects": {"u_aegis": 0.3}, 
		"desc": "Única de la ruta de Valhalla: el escudo de Reginleif, llevado a la espalda (va en la prenda: sirve con armas a dos manos y junto a tu propio escudo). Al recibir un golpe, 30% de bloquearlo y que caiga un círculo de columnas de luz sagrada a tu alrededor ×Lv."}, 
	"corrupt_spear": {"name": "Corrupted Spear Shard", "slot": "acc", "unique": true, "legendary": true, "route": "dark", 
		"icon": "corrupt_spear", "mods": {"dmg": 0.15, "crit": 0.05, "crit_dmg": 0.25}, "refine": {"dmg": 0.02}, 
		"effects": {"u_blood": 1.0}, 
		"desc": "Única de la ruta de Niflheim: un trozo de la lanza de Randgris. Tus críticos (de ataque básico o de habilidad) hacen caer la lanza corrupta sobre el monstruo (un gran golpe de sombra en área) y dejan un charco de sangre que hiere a los que lo pisan y te cura por cada uno ×Lv."}, 




	"soul_sacred_excalibur": {"name": "Alma de Dark Lord (Excalibur)", "slot": "soul", "soul_of": "sacred_excalibur", "unique": true, "legendary": true, "rank": 99, "icon": "soul@sacred_excalibur", "mvp": "dark_lord"}, 
	"soul_crescent_scythe": {"name": "Alma de Baphomet (Crescent Scythe)", "slot": "soul", "soul_of": "crescent_scythe", "unique": true, "legendary": true, "rank": 99, "icon": "soul@crescent_scythe", "mvp": "baphomet"}, 
	"soul_golden_bug_shell": {"name": "Alma de Golden Thief Bug", "slot": "soul", "soul_of": "golden_bug_shell", "unique": true, "legendary": true, "rank": 99, "icon": "soul@golden_bug_shell", "mvp": "golden_bug"}, 
	"soul_tiger_footskin": {"name": "Alma de Eddga", "slot": "soul", "soul_of": "tiger_footskin", "unique": true, "legendary": true, "rank": 99, "icon": "soul@tiger_footskin", "mvp": "eddga"}, 
	"soul_moonlight_dagger": {"name": "Alma de Moonlight Flower", "slot": "soul", "soul_of": "moonlight_dagger", "unique": true, "legendary": true, "rank": 99, "icon": "soul@moonlight_dagger", "mvp": "moonlight"}, 
	"soul_orc_hero_helm": {"name": "Alma de Orc Hero", "slot": "soul", "soul_of": "orc_hero_helm", "unique": true, "legendary": true, "rank": 99, "icon": "soul@orc_hero_helm", "mvp": "ork_hero"}, 
	"soul_orcish_axe": {"name": "Alma de Orc Lord", "slot": "soul", "soul_of": "orcish_axe", "unique": true, "legendary": true, "rank": 99, "icon": "soul@orcish_axe", "mvp": "orc_lord"}, 
	"soul_bone_helm": {"name": "Alma de Dark Lord (Bone Helm)", "slot": "soul", "soul_of": "bone_helm", "unique": true, "legendary": true, "rank": 99, "icon": "soul@bone_helm", "mvp": "dark_lord"}, 
	"soul_bishop_bible": {"name": "Alma de Fallen Bishop", "slot": "soul", "soul_of": "bishop_bible", "unique": true, "legendary": true, "rank": 99, "icon": "soul@bishop_bible", "mvp": "fallen_bishop"}, 
	"soul_beelzebub_wing": {"name": "Alma de Beelzebub", "slot": "soul", "soul_of": "beelzebub_wing", "unique": true, "legendary": true, "rank": 99, "icon": "soul@beelzebub_wing", "mvp": "beelzebub"}, 
	"soul_huuma_kraken": {"name": "Alma de Kraken", "slot": "soul", "soul_of": "huuma_kraken", "unique": true, "legendary": true, "rank": 99, "icon": "soul@huuma_kraken", "mvp": "kraken"}, 
	"soul_turtle_shell": {"name": "Alma de Turtle General", "slot": "soul", "soul_of": "turtle_shell", "unique": true, "legendary": true, "rank": 99, "icon": "soul@turtle_shell", "mvp": "turtle_general"}, 
	"soul_osiris_ankh": {"name": "Alma de Osiris", "slot": "soul", "soul_of": "osiris_ankh", "unique": true, "legendary": true, "rank": 99, "icon": "soul@osiris_ankh", "mvp": "osiris"}, 
	"soul_maya_crown": {"name": "Alma de Maya", "slot": "soul", "soul_of": "maya_crown", "unique": true, "legendary": true, "rank": 99, "icon": "soul@maya_crown", "mvp": "maya"}, 
	"soul_queen_wings": {"name": "Alma de Mistress", "slot": "soul", "soul_of": "queen_wings", "unique": true, "legendary": true, "rank": 99, "icon": "soul@queen_wings", "mvp": "mistress"}, 
	"soul_storm_bow": {"name": "Alma de Owl Baron", "slot": "soul", "soul_of": "storm_bow", "unique": true, "legendary": true, "rank": 99, "icon": "soul@storm_bow", "mvp": "owl_baron"}, 
	"soul_lich_wand": {"name": "Alma de Lord of Death", "slot": "soul", "soul_of": "lich_wand", "unique": true, "legendary": true, "rank": 99, "icon": "soul@lich_wand", "mvp": "lord_of_death"}, 
	"soul_juperos_railgun": {"name": "Alma de Vesper", "slot": "soul", "soul_of": "juperos_railgun", "unique": true, "legendary": true, "rank": 99, "icon": "soul@juperos_railgun", "mvp": "apocalips"}, 
	"soul_imperial_guard": {"name": "Alma de Baphomet (Imperial Guard)", "slot": "soul", "soul_of": "imperial_guard", "unique": true, "legendary": true, "rank": 99, "icon": "soul@imperial_guard", "mvp": "baphomet"}, 
	"soul_santa_hat": {"name": "Alma de Stormy Knight", "slot": "soul", "soul_of": "santa_hat", "unique": true, "legendary": true, "rank": 99, "icon": "soul@santa_hat", "mvp": "knight_of_windstorm"}, 
	"soul_reaper_ledger": {"name": "Alma de Thanatos (Book of the Dead)", "slot": "soul", "soul_of": "reaper_ledger", "unique": true, "legendary": true, "rank": 99, "icon": "soul@reaper_ledger", "mvp": "thanatos"}, 
	"soul_star_blessing": {"name": "Alma de Thanatos (Star of Blessing)", "slot": "soul", "soul_of": "star_blessing", "unique": true, "legendary": true, "rank": 99, "icon": "soul@star_blessing", "mvp": "thanatos"}, 
	"soul_infiltrator": {"name": "Alma de Eremes Guile", "slot": "soul", "soul_of": "infiltrator", "unique": true, "legendary": true, "rank": 99, "icon": "soul@infiltrator", "mvp": "eremes"}, 
	"soul_clone_blade": {"name": "Alma de Lord Knight Seyren", "slot": "soul", "soul_of": "clone_blade", "unique": true, "legendary": true, "rank": 99, "icon": "soul@clone_blade", "mvp": "l_seyren"}, 
	"soul_ifrit_mask": {"name": "Alma de Ifrit", "slot": "soul", "soul_of": "ifrit_mask", "unique": true, "legendary": true, "rank": 99, "icon": "soul@ifrit_mask", "mvp": "ifrit"}, 
	"soul_glacial_heart": {"name": "Alma de Ktullanux", "slot": "soul", "soul_of": "glacial_heart", "unique": true, "legendary": true, "rank": 99, "icon": "soul@glacial_heart", "mvp": "ktullanux"}, 
	"soul_dark_rune": {"name": "Alma de Gloom Under Night", "slot": "soul", "soul_of": "dark_rune", "unique": true, "legendary": true, "rank": 99, "icon": "soul@dark_rune", "mvp": "gloom"}, 
	"soul_aegis_reginleif": {"name": "Alma de Reginleif", "slot": "soul", "soul_of": "aegis_reginleif", "unique": true, "legendary": true, "rank": 99, "icon": "soul@aegis_reginleif", "mvp": "reginleif"}, 
	"soul_corrupt_spear": {"name": "Alma de Randgris", "slot": "soul", "soul_of": "corrupt_spear", "unique": true, "legendary": true, "rank": 99, "icon": "soul@corrupt_spear", "mvp": "randgris_fallen"}, 


	"soul_excalibur": {"name": "Alma de Masamune", "slot": "soul", "soul_of": "excalibur", "legendary": true, "rank": 99, "icon": "soul@excalibur"}, 
	"soul_gungnir": {"name": "Alma de Gungnir", "slot": "soul", "soul_of": "gungnir", "legendary": true, "rank": 99, "icon": "soul@gungnir"}, 
	"soul_rudra_bow": {"name": "Alma de Rudra Bow", "slot": "soul", "soul_of": "rudra_bow", "legendary": true, "rank": 99, "icon": "soul@rudra_bow"}, 
	"soul_falken_blitz": {"name": "Alma de Falken Blitz", "slot": "soul", "soul_of": "falken_blitz", "legendary": true, "rank": 99, "icon": "soul@falken_blitz"}, 
	"soul_grimtooth": {"name": "Alma de Grimtooth", "slot": "soul", "soul_of": "grimtooth", "legendary": true, "rank": 99, "icon": "soul@grimtooth"}, 
	"soul_assassin_dagger": {"name": "Alma de Assassin Dagger", "slot": "soul", "soul_of": "assassin_dagger", "legendary": true, "rank": 99, "icon": "soul@assassin_dagger"}, 
	"soul_mjolnir": {"name": "Alma de Mjolnir", "slot": "soul", "soul_of": "mjolnir", "legendary": true, "rank": 99, "icon": "soul@mjolnir"}, 
	"soul_avenger_gatling": {"name": "Alma de Avenger Gatling Gun", "slot": "soul", "soul_of": "avenger_gatling", "legendary": true, "rank": 99, "icon": "soul@avenger_gatling"}, 
	"soul_destroyer": {"name": "Alma de Destroyer", "slot": "soul", "soul_of": "destroyer", "legendary": true, "rank": 99, "icon": "soul@destroyer"}, 
	"soul_bloody_axe": {"name": "Alma de Bloody Axe", "slot": "soul", "soul_of": "bloody_axe", "legendary": true, "rank": 99, "icon": "soul@bloody_axe"}, 
	"soul_huuma_giant_wheel": {"name": "Alma de Huuma Giant Wheel", "slot": "soul", "soul_of": "huuma_giant_wheel", "legendary": true, "rank": 99, "icon": "soul@huuma_giant_wheel"}, 
	"soul_mysteltainn": {"name": "Alma de Mysteltainn", "slot": "soul", "soul_of": "mysteltainn", "legendary": true, "rank": 99, "icon": "soul@mysteltainn"}, 
	"soul_mighty_staff": {"name": "Alma de Mighty Staff", "slot": "soul", "soul_of": "mighty_staff", "legendary": true, "rank": 99, "icon": "soul@mighty_staff"}, 
	"soul_roguemaster_bow": {"name": "Alma de Roguemaster's Bow", "slot": "soul", "soul_of": "roguemaster_bow", "legendary": true, "rank": 99, "icon": "soul@roguemaster_bow"}, 
	"soul_ballista": {"name": "Alma de Ballista", "slot": "soul", "soul_of": "ballista", "legendary": true, "rank": 99, "icon": "soul@ballista"}, 
	"soul_quadrille": {"name": "Alma de Quadrille", "slot": "soul", "soul_of": "quadrille", "legendary": true, "rank": 99, "icon": "soul@quadrille"}, 
	"soul_golden_axe": {"name": "Alma de Golden Axe", "slot": "soul", "soul_of": "golden_axe", "legendary": true, "rank": 99, "icon": "soul@golden_axe"}, 
	"soul_dwarven_hammer": {"name": "Alma de Martillo de los Enanos", "slot": "soul", "soul_of": "dwarven_hammer", "legendary": true, "rank": 99, "icon": "soul@dwarven_hammer"}, 
	"soul_ginnungagap": {"name": "Alma de Ginnungagap", "slot": "soul", "soul_of": "ginnungagap", "legendary": true, "rank": 99, "icon": "soul@ginnungagap"}, 
	"soul_murasame": {"name": "Alma de Murasame", "slot": "soul", "soul_of": "murasame", "legendary": true, "rank": 99, "icon": "soul@murasame"}, 
	"soul_crimson_bolt": {"name": "Alma de Crimson Bolt", "slot": "soul", "soul_of": "crimson_bolt", "legendary": true, "rank": 99, "icon": "soul@crimson_bolt"}, 
	"soul_chained_souls": {"name": "Alma de Libro de las Almas Encadenadas", "slot": "soul", "soul_of": "chained_souls", "legendary": true, "rank": 99, "icon": "soul@chained_souls"}, 
	"soul_survivors_rod": {"name": "Alma de Sky Leap Boots", "slot": "soul", "soul_of": "survivors_rod", "legendary": true, "rank": 99, "icon": "soul@survivors_rod"}, 
	"soul_golden_mace": {"name": "Alma de Golden Mace", "slot": "soul", "soul_of": "golden_mace", "legendary": true, "rank": 99, "icon": "soul@golden_mace"}, 
	"soul_paracelsus_mace": {"name": "Alma de Paracelsus Mace", "slot": "soul", "soul_of": "paracelsus_mace", "legendary": true, "rank": 99, "icon": "soul@paracelsus_mace"}, 
	"soul_holy_avenger": {"name": "Alma de Holy Avenger", "slot": "soul", "soul_of": "holy_avenger", "legendary": true, "rank": 99, "icon": "soul@holy_avenger"}, 
	"soul_encyclopedia": {"name": "Alma de Encyclopedia", "slot": "soul", "soul_of": "encyclopedia", "legendary": true, "rank": 99, "icon": "soul@encyclopedia"}, 
	"soul_bragi_lyre": {"name": "Alma de Lira de Bragi", "slot": "soul", "soul_of": "bragi_lyre", "legendary": true, "rank": 99, "icon": "soul@bragi_lyre"}, 
	"soul_dancer_whip": {"name": "Alma de Látigo de la Bailarina", "slot": "soul", "soul_of": "dancer_whip", "legendary": true, "rank": 99, "icon": "soul@dancer_whip"}, 
	"soul_electric_guitar": {"name": "Alma de Electric Guitar", "slot": "soul", "soul_of": "electric_guitar", "legendary": true, "rank": 99, "icon": "soul@electric_guitar"}, 
	"soul_sucsamad": {"name": "Alma de Sucsamad", "slot": "soul", "soul_of": "sucsamad", "legendary": true, "rank": 99, "icon": "soul@sucsamad"}, 
	"soul_hurricane_fury": {"name": "Alma de Hurricane Fury", "slot": "soul", "soul_of": "hurricane_fury", "legendary": true, "rank": 99, "icon": "soul@hurricane_fury"}, 
	"soul_kaiser_knuckle": {"name": "Alma de Kaiser Knuckle", "slot": "soul", "soul_of": "kaiser_knuckle", "legendary": true, "rank": 99, "icon": "soul@kaiser_knuckle"}, 
	"soul_berserk_knuckle": {"name": "Alma de Berserk Knuckle", "slot": "soul", "soul_of": "berserk_knuckle", "legendary": true, "rank": 99, "icon": "soul@berserk_knuckle"}, 
	"soul_valkyrie_helm": {"name": "Alma de Valkyrie Helm", "slot": "soul", "soul_of": "valkyrie_helm", "legendary": true, "rank": 99, "icon": "soul@valkyrie_helm"}, 
	"soul_valkyrian_armor": {"name": "Alma de Valkyrian Armor", "slot": "soul", "soul_of": "valkyrian_armor", "legendary": true, "rank": 99, "icon": "soul@valkyrian_armor"}, 
	"soul_valkyrja_shield": {"name": "Alma de Valkyrja's Shield", "slot": "soul", "soul_of": "valkyrja_shield", "legendary": true, "rank": 99, "icon": "soul@valkyrja_shield"}, 
	"soul_royal_guard_shield": {"name": "Alma de Royal Guard Shield", "slot": "soul", "soul_of": "royal_guard_shield", "legendary": true, "rank": 99, "icon": "soul@royal_guard_shield"}, 
	"soul_valkyrian_manteau": {"name": "Alma de Valkyrian Manteau", "slot": "soul", "soul_of": "valkyrian_manteau", "legendary": true, "rank": 99, "icon": "soul@valkyrian_manteau"}, 
	"soul_sleipnir": {"name": "Alma de Sleipnir", "slot": "soul", "soul_of": "sleipnir", "legendary": true, "rank": 99, "icon": "soul@sleipnir"}, 
	"soul_embryo": {"name": "Alma de Embryo", "slot": "soul", "soul_of": "embryo", "legendary": true, "rank": 99, "icon": "soul@embryo"}, 
	"soul_megingjard": {"name": "Alma de Megingjard", "slot": "soul", "soul_of": "megingjard", "legendary": true, "rank": 99, "icon": "soul@megingjard"}, 
	"soul_brisingamen": {"name": "Alma de Brisingamen", "slot": "soul", "soul_of": "brisingamen", "legendary": true, "rank": 99, "icon": "soul@brisingamen"}, 
	"soul_ring_flame_lord": {"name": "Alma de Ring of Flame Lord", "slot": "soul", "soul_of": "ring_flame_lord", "legendary": true, "rank": 99, "icon": "soul@ring_flame_lord"}, 
	"soul_ring_resonance": {"name": "Alma de Ring of Resonance", "slot": "soul", "soul_of": "ring_resonance", "legendary": true, "rank": 99, "icon": "soul@ring_resonance"}, 
	"soul_lord_kaho_horn": {"name": "Alma de Lord Kaho's Horn", "slot": "soul", "soul_of": "lord_kaho_horn", "legendary": true, "rank": 99, "icon": "soul@lord_kaho_horn"}, 
	"soul_diabolus_manteau": {"name": "Alma de Diabolus Manteau", "slot": "soul", "soul_of": "diabolus_manteau", "legendary": true, "rank": 99, "icon": "soul@diabolus_manteau"}, 
	"soul_diabolus_boots": {"name": "Alma de Diabolus Boots", "slot": "soul", "soul_of": "diabolus_boots", "legendary": true, "rank": 99, "icon": "soul@diabolus_boots"}, 
	"soul_odin_blessing": {"name": "Alma de Odin's Blessing", "slot": "soul", "soul_of": "odin_blessing", "legendary": true, "rank": 99, "icon": "soul@odin_blessing"}, 
	"soul_bradium_shield": {"name": "Alma de Bradium Shield", "slot": "soul", "soul_of": "bradium_shield", "legendary": true, "rank": 99, "icon": "soul@bradium_shield"}, 
	"soul_ifrit_ear": {"name": "Alma de Ifrit's Ear", "slot": "soul", "soul_of": "ifrit_ear", "legendary": true, "rank": 99, "icon": "soul@ifrit_ear"}, 
	"soul_vampire_familiar": {"name": "Alma de Vampire's Familiar", "slot": "soul", "soul_of": "vampire_familiar", "legendary": true, "rank": 99, "icon": "soul@vampire_familiar"}, 
	"soul_diabolus_ring": {"name": "Alma de Diabolus Ring", "slot": "soul", "soul_of": "diabolus_ring", "legendary": true, "rank": 99, "icon": "soul@diabolus_ring"}, 
	"soul_diabolus_robe": {"name": "Alma de Diabolus Robe", "slot": "soul", "soul_of": "diabolus_robe", "legendary": true, "rank": 99, "icon": "soul@diabolus_robe"}, 
	"soul_flame_armor": {"name": "Alma de Flame Armor", "slot": "soul", "soul_of": "flame_armor", "legendary": true, "rank": 99, "icon": "soul@flame_armor"}, 
	"soul_vampire_hairband": {"name": "Alma de Vampire Hairband", "slot": "soul", "soul_of": "vampire_hairband", "legendary": true, "rank": 99, "icon": "soul@vampire_hairband"}, 
	"soul_morpheus_ring": {"name": "Alma de Morpheus's Ring", "slot": "soul", "soul_of": "morpheus_ring", "legendary": true, "rank": 99, "icon": "soul@morpheus_ring"}, 
	"soul_phoenix_ring": {"name": "Alma de Phoenix Ring", "slot": "soul", "soul_of": "phoenix_ring", "legendary": true, "rank": 99, "icon": "soul@phoenix_ring"}, 
	"soul_bloody_knight_shield": {"name": "Alma de Bloody Knight Shield", "slot": "soul", "soul_of": "bloody_knight_shield", "legendary": true, "rank": 99, "icon": "soul@bloody_knight_shield"}, 
	"soul_odin_mask": {"name": "Alma de Odin Mask", "slot": "soul", "soul_of": "odin_mask", "legendary": true, "rank": 99, "icon": "soul@odin_mask"}, 
	"soul_paracelsus_coat": {"name": "Alma de Paracelsus Coat", "slot": "soul", "soul_of": "paracelsus_coat", "legendary": true, "rank": 99, "icon": "soul@paracelsus_coat"}, 
	"soul_bradium_earring": {"name": "Alma de Bradium Earring", "slot": "soul", "soul_of": "bradium_earring", "legendary": true, "rank": 99, "icon": "soul@bradium_earring"}, 
	"soul_critical_ring": {"name": "Alma de Critical Ring", "slot": "soul", "soul_of": "critical_ring", "legendary": true, "rank": 99, "icon": "soul@critical_ring"}, 
	"soul_diabolus_helm": {"name": "Alma de Diabolus Helm", "slot": "soul", "soul_of": "diabolus_helm", "legendary": true, "rank": 99, "icon": "soul@diabolus_helm"}, 
	"soul_diabolus_armor": {"name": "Alma de Diabolus Armor", "slot": "soul", "soul_of": "diabolus_armor", "legendary": true, "rank": 99, "icon": "soul@diabolus_armor"}, 
	"soul_archmage_hat": {"name": "Alma de Archmage Hat", "slot": "soul", "soul_of": "archmage_hat", "legendary": true, "rank": 99, "icon": "soul@archmage_hat"}, 
	"soul_arcane_manteau": {"name": "Alma de Arcane Manteau", "slot": "soul", "soul_of": "arcane_manteau", "legendary": true, "rank": 99, "icon": "soul@arcane_manteau"}, 
	"soul_surtr_ring": {"name": "Alma de Surtr's Ring", "slot": "soul", "soul_of": "surtr_ring", "legendary": true, "rank": 99, "icon": "soul@surtr_ring"}, 
	"soul_ifrit_manteau": {"name": "Alma de Ifrit's Mantle", "slot": "soul", "soul_of": "ifrit_manteau", "legendary": true, "rank": 99, "icon": "soul@ifrit_manteau"}, 
	"soul_vampire_fang": {"name": "Alma de Vampire's Fang", "slot": "soul", "soul_of": "vampire_fang", "legendary": true, "rank": 99, "icon": "soul@vampire_fang"}, 
	"soul_blood_boots": {"name": "Alma de Bloodied Boots", "slot": "soul", "soul_of": "blood_boots", "legendary": true, "rank": 99, "icon": "soul@blood_boots"}, 
	"soul_morpheus_shawl": {"name": "Alma de Morpheus's Shawl", "slot": "soul", "soul_of": "morpheus_shawl", "legendary": true, "rank": 99, "icon": "soul@morpheus_shawl"}, 
	"soul_morpheus_bracelet": {"name": "Alma de Morpheus's Bracelet", "slot": "soul", "soul_of": "morpheus_bracelet", "legendary": true, "rank": 99, "icon": "soul@morpheus_bracelet"}, 
	"soul_flame_lord_crown": {"name": "Alma de Crown of the Flame Lord", "slot": "soul", "soul_of": "flame_lord_crown", "legendary": true, "rank": 99, "icon": "soul@flame_lord_crown"}, 
	"soul_phoenix_mantle": {"name": "Alma de Phoenix Mantle", "slot": "soul", "soul_of": "phoenix_mantle", "legendary": true, "rank": 99, "icon": "soul@phoenix_mantle"}, 
	"soul_bloody_knight_armor": {"name": "Alma de Bloody Knight Armor", "slot": "soul", "soul_of": "bloody_knight_armor", "legendary": true, "rank": 99, "icon": "soul@bloody_knight_armor"}, 
	"soul_resonance_helm": {"name": "Alma de Helm of Resonance", "slot": "soul", "soul_of": "resonance_helm", "legendary": true, "rank": 99, "icon": "soul@resonance_helm"}, 
	"soul_odin_mantle": {"name": "Alma de Odin's Mantle", "slot": "soul", "soul_of": "odin_mantle", "legendary": true, "rank": 99, "icon": "soul@odin_mantle"}, 
	"soul_odin_boots": {"name": "Alma de Boots of Odin", "slot": "soul", "soul_of": "odin_boots", "legendary": true, "rank": 99, "icon": "soul@odin_boots"}, 
	"soul_paracelsus_hat": {"name": "Alma de Paracelsus's Hat", "slot": "soul", "soul_of": "paracelsus_hat", "legendary": true, "rank": 99, "icon": "soul@paracelsus_hat"}, 
	"soul_homunculus_charm": {"name": "Alma de Homunculus Charm", "slot": "soul", "soul_of": "homunculus_charm", "legendary": true, "rank": 99, "icon": "soul@homunculus_charm"}, 
	"soul_bradium_helm": {"name": "Alma de Bradium Helm", "slot": "soul", "soul_of": "bradium_helm", "legendary": true, "rank": 99, "icon": "soul@bradium_helm"}, 
	"soul_bradium_armor": {"name": "Alma de Bradium Armor", "slot": "soul", "soul_of": "bradium_armor", "legendary": true, "rank": 99, "icon": "soul@bradium_armor"}, 
	"soul_freya_crown": {"name": "Alma de Crown of Freya", "slot": "soul", "soul_of": "freya_crown", "legendary": true, "rank": 99, "icon": "soul@freya_crown"}, 
	"soul_freya_cape": {"name": "Alma de Freya's Cape", "slot": "soul", "soul_of": "freya_cape", "legendary": true, "rank": 99, "icon": "soul@freya_cape"}, 
	"soul_jarngreipr": {"name": "Alma de Jarngreipr", "slot": "soul", "soul_of": "jarngreipr", "legendary": true, "rank": 99, "icon": "soul@jarngreipr"}, 
	"soul_thor_helm": {"name": "Alma de Helm of Thor", "slot": "soul", "soul_of": "thor_helm", "legendary": true, "rank": 99, "icon": "soul@thor_helm"}, 
	"soul_executioner_gloves": {"name": "Alma de Executioner's Gloves", "slot": "soul", "soul_of": "executioner_gloves", "legendary": true, "rank": 99, "icon": "soul@executioner_gloves"}, 
	"soul_punishment_shoes": {"name": "Alma de Shoes of Punishment", "slot": "soul", "soul_of": "punishment_shoes", "legendary": true, "rank": 99, "icon": "soul@punishment_shoes"}, 
	"soul_asprika": {"name": "Alma de Asprika", "slot": "soul", "soul_of": "asprika", "legendary": true, "rank": 99, "icon": "soul@asprika"}, 
	"soul_imperial_ring": {"name": "Alma de Imperial Ring", "slot": "soul", "soul_of": "imperial_ring", "legendary": true, "rank": 99, "icon": "soul@imperial_ring"}, 
	"soul_einherjar_boots": {"name": "Alma de Boots of the Einherjar", "slot": "soul", "soul_of": "einherjar_boots", "legendary": true, "rank": 99, "icon": "soul@einherjar_boots"}, 
	"soul_valkyrie_ring": {"name": "Alma de Ring of the Valkyrie", "slot": "soul", "soul_of": "valkyrie_ring", "legendary": true, "rank": 99, "icon": "soul@valkyrie_ring"}, 
	"soul_valkyrja_greaves": {"name": "Alma de Valkyrja's Greaves", "slot": "soul", "soul_of": "valkyrja_greaves", "legendary": true, "rank": 99, "icon": "soul@valkyrja_greaves"}, 
	"soul_aegis_helm": {"name": "Alma de Helm of the Aegis", "slot": "soul", "soul_of": "aegis_helm", "legendary": true, "rank": 99, "icon": "soul@aegis_helm"}, 
}


const LEGENDARY_COLOR: = Color(0.85, 0.42, 0.05)
const WINGS_COLOR: = Color(0.62, 0.3, 0.95)

const TOWER_WINGS: = "sword_wings"







const HEL_WINGS_ITEM: = "hel_requiem"







const ENDOW_PRICE: = 1000000
const ENDOW_MATCH: = 0.25
const ENDOW_ELEMENTS: = ["fire", "water", "wind", "earth", "poison", "holy", "shadow", "ghost"]
const HEL_WINGS_NAME: = "Wings of Hel"
const HEL_WINGS_MULT: = 1.5
const HEL_WINGS_KEEP: = ["count"]
const HEL_WINGS_COLOR: = Color(1.0, 0.78, 0.32)




const WING_REFINE_MAX: = 10
const WING_LEVELS: = [
	"Tus atributos rinden completos hasta 12", 
	"Aturdimiento del Aguante +1 s", 
	"Cartas de MVP de las alas +15%", 
	"Tus atributos rinden completos hasta 14", 
	"+1 hueco de MVP y creces +50% con Ymir", 
	"Quebrar el Aguante recarga tus habilidades 30%", 
	"Llenas el Aguante un 25% más rápido", 
	"Cartas de MVP de las alas +30%", 
	"Jefe aturdido: recibe +20% de tu daño", 
	"Tus atributos rinden completos hasta 19", 
]



static func wing_fx(r: int) -> Dictionary:
	var fx: = {}
	var cap: = (2 if r >= 1 else 0) + (2 if r >= 4 else 0) + (5 if r >= 10 else 0)
	if cap > 0:
		fx["wing_stat_cap"] = float(cap)
	if r >= 2:
		fx["wing_stun"] = 1.0
	if r >= 3:
		fx["wing_card"] = 0.3 if r >= 8 else 0.15
	if r >= 5:
		fx["wing_ymir"] = 0.5
	if r >= 6:
		fx["wing_break_cd"] = 0.3
	if r >= 7:
		fx["wing_fill"] = 0.25
	if r >= 9:
		fx["wing_broken"] = 0.2
	return fx



static func bound_item(id: String) -> bool:
	return bool(ITEMS.get(id, {}).get("bound", false))





const UNIQUE_COLOR: = Color(0.2, 0.85, 0.95)

const SOUL_COLOR: = Color(0.95, 0.45, 0.85)




const SOUL_POT_REFUND: = [0, 1, 10, 35]




const LEGEND_SOUL_PRICE: = 10
const UNIQUE_MVP_CHANCE: = 0.017
const UNIQUE_BOSS_CHANCE: = 0.0012



const KARMA_UNIQUE_CHANCE: = 0.017
const UNIQUE_HELL_MULT: = 2.0




const UNIQUE_OWNED_MULT: = 0.2
const UNIQUE_COST_MULT: = 2.0
const UNIQUE_SELL: = 2000



const U_COSMOS_DURATION: = 3.0
const U_COSMOS_COOLDOWN: = 0.5

const UNIQUE_TAGS: = {"lg_dance_step": "dancer_whip", "u_scythe": "crescent_scythe", "u_goldbug": "golden_bug_shell", "u_moon": "moonlight_dagger", 
	"u_quake": "orcish_axe", "u_bone": "bone_helm", "u_bishop": "bishop_bible", "u_flies": "beelzebub_wing", 
	"u_kraken": "huuma_kraken", "u_ankh": "osiris_ankh", "u_maya": "maya_crown", "u_queen": "queen_wings", 
	"u_owl": "storm_bow", "u_rail": "juperos_railgun", "u_overload": "juperos_railgun", "u_excalibur": "sacred_excalibur", "lg_masamune": "excalibur", "u_sonic": "infiltrator", "u_gift": "santa_hat", "u_reaper": "reaper_ledger", 
	"u_clones": "clone_blade", "u_tiger": "tiger_footskin", "u_aegis": "aegis_reginleif", "u_blood": "corrupt_spear", 
	"u_coma": "lich_wand", "u_volcano": "ifrit_mask", "u_shatter": "glacial_heart", "u_bulwark": "imperial_guard"}

const U_SCYTHE_DMG: = 7.0
const U_SCYTHE_HEAL: = 0.01
const U_SCYTHE_RADIUS: = 4.5





const U_SCYTHE_SOULS: = 20
const U_SCYTHE_BOSS_SOULS: = 4
const U_SCYTHE_SOUL_DMG: = 0.04
const U_SCYTHE_MOON_K: = 2.0
const U_SCYTHE_MOON_GAP: = 0.22
const U_QUAKE_DMG: = 3.5


const U_QUAKE_FX_GAP: = 0.9
const U_QUAKE_COLOR: = Color(1.0, 0.55, 0.22)
const U_QUAKE_LAVA_COLOR: = Color(1.0, 0.4, 0.08)
const U_QUAKE_RADIUS: = 5.0
const U_QUAKE_STUN: = 0.5






const U_QUAKE_FISSURES: = 4
const U_QUAKE_FISSURE_LEN: = 7.0
const U_QUAKE_FISSURE_W: = 1.3
const U_QUAKE_FISSURE_DMG: = 2.5
const U_QUAKE_RAGE: = 5
const U_QUAKE_GREAT_R: = 1.8
const U_QUAKE_GREAT_K: = 4.0
const U_QUAKE_GREAT_STUN: = 1.5
const U_QUAKE_GREAT_FISSURES: = 8
const U_QUAKE_LAVA_BURN: = 3.0
const U_MOON_DMG: = 6.0
const U_ORC_MAX: = 0.8
const U_ORC_RADIUS: = 4.5
const U_BONE_MAX: = 8




















const U_BONE_TIME: = 40.0


const U_BONE_DMG: = 7.2
const U_BONE_GUARD: = 0.25
const U_BONE_GUARD_RANGE: = 6.0
const U_BONE_BLAST: = 4.0
const U_BONE_BLAST_RADIUS: = 3.0
const U_BONE_HP_DMG: = 0.5
const U_BONE_HP_K: = 0.15
const U_BONE_HP_N: = 50.0
const U_BONE_GENERAL_EVERY: = 8.0
const U_BONE_GENERAL_TIME: = 16.0
const U_BONE_GENERAL_RANGE: = 16.0
const U_BONE_GENERAL_DMG: = 4.0
const U_BONE_GENERAL_GUARD: = 1.0


const U_BISHOP_CD: = 0.5
const U_BISHOP_RADIUS: = 5.0
const U_BISHOP_PRAYER: = 3.5

const U_BISHOP_MIN: = 6.0
const U_BISHOP_PRAYER_HEAL: = 0.04

const U_BISHOP_HEAL_CAP: = 0.2
const U_GOLDBUG_REFLECT: = 3.0


const U_GOLDBUG_WAVE: = 12.0
const U_GOLDBUG_RADIUS: = 4.0
const U_GOLDBUG_CD: = 1.0
const U_FLY_RADIUS: = 1.8
const U_FLY_DMG: = 4.5

const U_FLY_REACH: = 6.0
const U_FLY_EVERY: = 0.4
const U_FLY_HEAL: = 0.1










const U_FLY_MAX: = 12
const U_FLY_BROOD_TIME: = 8.0
const U_PLAGUE_TIME: = 6.0
const U_PLAGUE_REACH: = 5.0
const U_PLAGUE_JUMPS: = 3
const U_PLAGUE_DMG: = 30.0
const U_PLAGUE_PER_SEC: = 10.0
const U_PLAGUE_PER_FRAME: = 3
const U_PLAGUE_QUEUE: = 20
const U_PLAGUE_DEPTH: = 12
const U_PLAGUE_MARKS: = 40
const U_PLAGUE_COLOR: = Color(0.5, 0.68, 0.12)
const U_MAYA_EVERY: = 2.5

const U_MAYA_BURST: = 18.0
const U_MAYA_BURST_RADIUS: = 2.5
const U_MAYA_TIME: = 18.0
const U_MAYA_DMG: = 9.0










const U_QUEEN_CHARGE: = 20
const U_QUEEN_STEP: = 0.5
const U_QUEEN_WIND_GAP: = 0.5
const U_QUEEN_STORM: = 3.0
const U_QUEEN_TICK: = 0.25
const U_QUEEN_RADIUS: = 6.0
const U_QUEEN_DMG: = 10.0
const U_QUEEN_HITS: = 40
const U_QUEEN_COLOR: = Color(0.55, 0.85, 1.0)
const U_QUEEN_FULL_COLOR: = Color(1.0, 0.95, 0.6)
const U_OWL_CD: = 0.2



const U_OWL_HELD: = 0.1
const U_OWL_HELD_MAX: = 20



const U_OWL_CHAIN: = 3
const U_OWL_CHAIN_RANGE: = 5.0
const U_OWL_CHAIN_DMG: = 0.75
const U_OWL_LONE: = 2
const U_RAIL_LENGTH: = 14.0
const U_RAIL_WIDTH: = 0.9
const U_RAIL_CD: = 0.12
const U_RAIL_SPARKS: = 5
const U_RAIL_SOUND_CD: = 0.5






const U_OV_STAGES: = 8
const U_OV_STAGE_SWINGS: = [10.0, 15.0, 20.0, 25.0, 30.0, 40.0, 50.0, 60.0]
const U_OV_SWING_GAP: = 0.12


const U_OV_GAUGE_H: = 13.0
const U_OV_MULT: = [0.0, 1.0, 1.5, 2.0, 3.0, 4.0, 5.5, 7.5, 10.0]
const U_OV_RANGE: = 18.0

const U_OV_LENGTH: = 22.0
const U_OV_LENGTH_MAX: = 500.0

const U_OV_WIDTH: = 2.0

const U_OV_BURSTS: = 16
const U_OV_WINDUP: = 0.35

const U_OV_MUZZLE_UP: = 0.45
const U_OV_MUZZLE_AHEAD: = 0.55
const U_OV_BLUE: = Color(0.35, 0.75, 1.0)
const U_OV_GOLD: = Color(1.0, 0.82, 0.35)








const U_EX_MULT: = [0.0, 1.0, 1.5, 2.0, 3.0, 4.0, 5.5, 7.5, 10.0]














const U_EX_BURN: = 0.12





const MASA_IAI: = 2.5
const MASA_IAI_CD: = 0.3
const MASA_IAI_RADIUS: = 3.2
const MASA_CALM: = 0.25
const MASA_CALM_STACKS: = 4
const U_EX_WINDUP: = 0.7
const U_EX_SPEED: = 70.0
const U_EX_TRAVEL_MAX: = 0.9
const U_EX_HALF: = 1.1
const U_EX_FLARE: = 0.07
const U_EX_HALF_MAX: = 6.0
const U_EX_AIM_RANGE: = 30.0
const U_EX_AIM_DIRS: = 32
const U_EX_SEGMENT: = 3.5
const U_EX_GOLD: = Color(1.0, 0.84, 0.38)










const U_BW_STAGES: = 6
const U_BW_STAGE_STEPS: = [5, 6, 7, 8, 9, 10]
const U_BW_WEIGHT: = {"guard": 3.0, "lucky": 3.0, "evade": 3.0, "aegis": 4.0, "absorb": 2.0, "miss": 2.0, "hit": 1.0}
const U_BW_GAP: = 0.15


const U_BW_IDLE: = 2.0
const U_BW_MULT: = [0.0, 30.0, 55.0, 85.0, 120.0, 165.0, 220.0]
const U_BW_RADIUS: = 6.0
const U_BW_RADIUS_STAGE: = 1.0
const U_BW_CORE: = 3.0
const U_BW_CORE_MULT: = 1.5
const U_BW_WINDUP: = 0.38


const U_BW_WAVE_TIME: = 0.32
const U_BW_BANDS: = 5
const U_BW_STAGGER: = 6.0

const U_BW_BLUE: = Color(0.32, 0.55, 1.0)
const U_BW_GOLD: = Color(1.0, 0.8, 0.32)
const U_BW_PALE: = Color(0.82, 0.9, 1.0)


const U_BW_WAVE_A: = Color(0.86, 0.92, 1.0)
const U_BW_WAVE_B: = Color(0.62, 0.72, 0.9)
const U_BW_FLASH: = Color(0.95, 0.97, 1.0)
const U_EX_PALE: = Color(1.0, 0.96, 0.8)





const U_EX_STAGE_CASTS: = [4.0, 5.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0]

const U_EX_SWORDS: = 24
const U_EX_CAST_GAP: = 0.25
const U_EX_PEAK_WINDOW: = 0.3







const U_TIGER_CD: = 0.5
const U_TIGER_FURY_MAX: = 10
const U_TIGER_FURY_TIME: = 6.0
const U_TIGER_FURY_DMG: = 0.05
const U_TIGER_ROAR_EVERY: = 5
const U_TIGER_ENDURE: = 0.15

const U_TIGER_ROAR: = 15.0
const U_TIGER_ROAR_RADIUS: = 4.5
const U_TIGER_COLOR: = Color(1.0, 0.6, 0.15)





const U_ANKH_RADIUS: = 9.0
const U_ANKH_DMG: = 25.0
const U_ANKH_INVULN: = 5.0
const U_ANKH_RECHARGE: = 150.0
const U_ANKH_AURA_RADIUS: = 4.0
const U_ANKH_AURA_DMG: = 8.0
const U_ANKH_AURA_EVERY: = 0.5
const U_ANKH_COLOR: = Color(1.0, 0.88, 0.45)




const U_COMA_BOSS_MULT: = 2.0





const U_COMA_HIT_MULT: = 8.0



const BOLTS_MAX: = 20
const U_COMA_BOSS_TIME: = 4.0
const U_COMA_BOSS_CD: = 3.0


const U_GIFT_CD: = 0.8
const U_GIFT_DMG: = 25.0

const U_GIFT_EVERY: = 3.0
const U_GIFT_RADIUS: = 2.2
const U_GIFT_HEAL: = 0.01

const U_SOUL_DMG: = 0.03
const U_REAPER_DMG: = 22.0
const U_REAPER_CD: = 3.0
const U_REAPER_RADIUS: = 5.5

const U_CLONE_SKILLS: = ["bowling_bash", "sonic_blow", "cart_termination", "heal", "sharp_shooting", "storm_gust"]

const U_CLONE_DMG: = 1.5

const U_CLONE_AGAIN: = 0.35

const U_CLONE_COLORS: = {"bowling_bash": Color(0.95, 0.45, 0.35), "sonic_blow": Color(0.65, 0.4, 0.95), 
	"cart_termination": Color(0.95, 0.75, 0.3), "heal": Color(0.55, 0.95, 0.6), "sharp_shooting": Color(0.45, 0.8, 1.0), 
	"storm_gust": Color(0.6, 0.85, 1.0)}




const U_AEGIS_DMG: = 20.0
const U_AEGIS_RADIUS: = 4.5
const U_AEGIS_CD: = 1.0
const U_BLOOD_DMG: = 4.0
const U_BLOOD_RADIUS: = 2.4
const U_BLOOD_TICKS: = 6
const U_BLOOD_HEAL: = 0.005

const U_BLOOD_HEAL_MAX: = 0.03
const U_BLOOD_CD: = 1.0

const U_SPEAR_DMG: = 16.0
const U_SPEAR_RADIUS: = 2.6





const U_VOLCANO_GAP: = 0.3
const U_VOLCANO_DMG: = 30.0
const U_VOLCANO_RADIUS: = 6.0
const U_VOLCANO_BURN: = 4.0



const U_VOLCANO_TICKS: = 16
const U_VOLCANO_LAVA: = 4.0
const U_VOLCANO_LAVA_DMG: = 3.0
const U_VOLCANO_FURY_TIME: = 6.0
const U_VOLCANO_HASTE: = 0.5

const U_VOLCANO_FURY_HEAT: = 2.0




const U_SHATTER_WATER: = 0.2
const U_SHATTER_FREEZE: = 0.06
const U_SHATTER_GAP: = 0.08
const U_SHATTER_FREEZE_TIME: = 2.0
const U_SHATTER_DMG: = 7.0
const U_SHATTER_RADIUS: = 2.6
const U_SHATTER_CHAIN: = 0.45
const U_SHATTER_BOSS_CD: = 2.0



const U_GLOOM_FIRST: = 4.0
const U_GLOOM_EVERY: = 15.0
const U_GLOOM_TIME: = 6.0
const U_GLOOM_MAX: = 12.0
const U_GLOOM_RADIUS: = 6.0
const U_GLOOM_KILL: = 0.5
const U_GLOOM_FRAIL: = 0.35
const U_GLOOM_BOSS: = 0.15
const U_CLONE_NAMES: = {"bowling_bash": "Seyren", "sonic_blow": "Eremes", "cart_termination": "Howard", "heal": "Margaretha", 
	"sharp_shooting": "Cecil", "storm_gust": "Kathryne"}




const LEGENDARY_CHANCE: = 0.0075

const ELITE_LEGENDARY_CHANCE: = 0.0008


const SKILL_BURST_RADIUS: = 1.6
const SKILL_BURST_DMG: = 0.6




const DESTROYER_GRENADES: = 3
const DESTROYER_FUSE: = 0.5
const DESTROYER_GRENADE_RADIUS: = 2.2
const DESTROYER_GRENADE_DMG: = 1.2


const ENCYCLO_ECHO: = 0.6
const ENCYCLO_ECHO_DELAY: = 0.5



const GRYPHON_GUARD_CD: = 0.5
const GRYPHON_GUARD_MAX: = 0.3

const LEGENDARY_WEAPON_SHARE: = 0.3






const LG_BACKSTAB_HITS: = 5

const LG_BACKSTAB_EVOLVED: = 12


const BS_LUK_K: = 100.0
const BS_LUK_FADE: = 0.75


const LG_BACKSTAB_REPEAT: = 0.8


const BS_REPEAT: = 0.6

const BACKSTAB_X_GROWTH_CAP: = 7

const BS_EXTRA_STABS: = 4





const LG_BASH_AT: = 300.0
const LG_BASH_POW: = 0.5


func lg_bash_bonus(kills: int) -> float:
	return pow(maxf(0.0, float(kills)) / LG_BASH_AT, LG_BASH_POW)
const LG_RING_SEGMENTS: = 6
const LG_RING_RADIUS: = 3.2
const LG_RING_TIME: = 1.0
const LG_RING_DMG: = 1.5
const LG_DS_BOUNCES: = 5
const LG_DS_GROW: = 1.18


const LG_RUDRA_WAVES: = 3
const LG_RUDRA_WAVE: = 0.4
const LG_RUDRA_HEAL: = 0.006
const LG_RUDRA_MAX: = 6


const LG_FALKEN_ANGLE: = 0.35
const LG_FALKEN_SIDE: = 0.6
const LG_HEAL_DMG: = 3.0
const LG_HEAL_RADIUS: = 4.5
const LG_MAMMON_ZENY: = 4
const LG_MIRROR_DMG: = 0.6
const LG_TRACK_TIME: = 8.0
const LG_TRACK_JUMP: = 9.0
const LG_FKICK_BOUNCES: = 3
const LG_FKICK_GROW: = 1.25





const LG_FURY_STEP: = 0.05
const LG_FURY_MAX: = 20
const LG_FURY_WINDOW: = 6.0
const LG_FURY_START: = 1.5
const LG_FURY_REACH: = 1.5

const LG_FURY_TAGS: = ["triple_attack", "chain_combo", "combo_finish", "chain_crush", "chain_crush_x"]
const LEGENDARY_MIN_TIME: = 200.0

const RANK_STEP: = 180.0







const SETS: = {


	"diabolus_venom": {"name": "Diabolus: Veneno", "build": "Veneno", "items": ["diabolus_manteau", "diabolus_ring"], 











		"mods": {"dmg": 0.1}, "effects": {"poison_growth": 0.01, "poison_dmg": 0.4, "poison_jumps": 2.0}, 
		"desc": "Tu veneno pega un 40% más, crece x1.076 por carga (en vez de x1.066) y, al morir un monstruo envenenado, pasa a los 2 más cercanos con la mitad de sus cargas; +10% de daño", 
		"more": ["diabolus_helm", "diabolus_armor"], "full_mods": {"dmg": 0.15}, "full_effects": {"poison_growth": 0.02, "poison_stack": 1.0, "poison_dmg": 0.6, "poison_jumps": 2.0}, 
		"full_desc": "Tu veneno pega otro 60% más, crece x1.096 por carga, cada dosis suma una carga más y pasa a 2 monstruos más; +15% de daño"}, 
	"diabolus_arcane": {"name": "Diabolus: Arcano", "build": "Rotación de habilidades", "items": ["diabolus_boots", "diabolus_robe"], 
		"mods": {"haste": 0.1, "skill_dmg": 0.15}, "effects": {"chain_cast": 0.1}, 
		"desc": "Cada habilidad acerca 0.1 s más la recarga de las demás, -10% recarga y +15% daño de habilidades", 
		"more": ["archmage_hat", "arcane_manteau"], "full_mods": {"haste": 0.1, "skill_dmg": 0.25}, "full_effects": {"chain_cast": 0.2}, 
		"full_desc": "Cada habilidad acerca otros 0.2 s la recarga de las demás, -10% recarga y +25% daño de habilidades"}, 
	"ifrit_flames": {"name": "Llamas de Ifrit", "build": "Quemadura", "items": ["ifrit_ear", "flame_armor"], 
		"mods": {"dmg": 0.1}, "effects": {"burn_jumps": 2.0}, 
		"desc": "El fuego salta a 2 monstruos más al morir el que arde y +10% de daño", 
		"more": ["surtr_ring", "ifrit_manteau"], "full_mods": {"dmg": 0.15}, "full_effects": {"burn_power": 0.6, "burn_jumps": 2.0}, 
		"full_desc": "Tus quemaduras queman un 60% más, el fuego salta a 2 monstruos más y +15% de daño"}, 
	"vampire_blood": {"name": "Sangre Vampírica", "build": "Sangrado", "items": ["vampire_familiar", "vampire_hairband"], 
		"mods": {"aspd": 0.1}, "effects": {"bleed_heal": 0.015}, 
		"desc": "Cada reventón de sangrado te cura un 1.5% de la vida y +10% de velocidad de ataque", 
		"more": ["vampire_fang", "blood_boots"], "full_mods": {"aspd": 0.15}, "full_effects": {"bleed_at": 1.0, "bleed_chain": 1.0}, 
		"full_desc": "El sangrado revienta con una carga menos, el reventón deja sangrando a los que salpica y +15% de velocidad de ataque"}, 
	"morpheus_dream": {"name": "Sueño de Morfeo", "build": "Estados", "items": ["lord_kaho_horn", "morpheus_ring"], 
		"mods": {"skill_dmg": 0.1}, "effects": {"status_time": 0.5, "status_vuln": 0.2}, 
		"desc": "Tus estados duran un 50% más, los monstruos con un estado reciben otro +20% y +10% daño de habilidades", 
		"more": ["morpheus_shawl", "morpheus_bracelet"], "full_mods": {"skill_dmg": 0.15}, "full_effects": {"status_time": 0.5, "status_vuln": 0.3}, 
		"full_desc": "Tus estados duran otro 50%, los monstruos con un estado reciben otro +30% y +15% daño de habilidades"}, 






	"flame_rings": {"name": "Anillos de Llama", "build": "Procs al atacar", "items": ["ring_flame_lord", "phoenix_ring"], 
		"mods": {"aspd": 0.15}, "effects": {"proc_chance": 0.5, "proc_power": 0.4}, 
		"desc": "Tus procs del ataque básico salen un 50% más seguido, todos tus procs pegan x1.4 (multiplicador aparte) y +15% de velocidad de ataque", 
		"more": ["flame_lord_crown", "phoenix_mantle"], "full_mods": {"aspd": 0.15}, "full_effects": {"proc_chance": 0.5, "proc_power": 0.4}, 
		"full_desc": "Tus procs del ataque básico salen otro 50% más seguido, el multiplicador de tus procs sube a x1.8 y +15% de velocidad de ataque"}, 
	"bloody_oath": {"name": "Juramento Sangriento", "build": "Procs al recibir golpes", "items": ["ring_resonance", "bloody_knight_shield"], 
		"mods": {"max_hp_pct": 0.15, "proc_dmg": 0.2}, "effects": {"hit_proc": 0.3, "hit_heal": 0.02}, 
		"desc": "Tus cartas al recibir un golpe salen un 30% más seguido y pegan un 20% más, cada una te cura otro 2% y +15% de vida máxima", 
		"more": ["bloody_knight_armor", "resonance_helm"], "full_mods": {"max_hp_pct": 0.2, "proc_dmg": 0.3}, "full_effects": {"hit_proc": 0.5, "hit_heal": 0.03}, 
		"full_desc": "Tus cartas al recibir un golpe salen otro 50% más seguido y pegan otro 30% más, cada una te cura otro 3% y +20% de vida máxima"}, 
	"odin_grace": {"name": "Gracia de Odín", "build": "Soporte", "items": ["odin_blessing", "odin_mask"], 
		"mods": {"haste": 0.1}, "effects": {"buff_power": 0.5, "heal_power": 0.3}, 
		"desc": "Tus buffs son otro 50% más fuertes, tus curaciones curan otro 30% y -10% recarga. En lo que tus buffs dan de daño, solo un cuarto de eso", 
		"more": ["odin_mantle", "odin_boots"], "full_mods": {"haste": 0.1}, "full_effects": {"buff_power": 0.5, "heal_power": 0.5}, 
		"full_desc": "Tus buffs son otro 50% más fuertes, tus curaciones curan otro 50% y -10% recarga. En lo que tus buffs dan de daño, solo un cuarto de eso"}, 
	"paracelsus_lab": {"name": "Laboratorio de Paracelso", "build": "Invocaciones", "items": ["embryo", "paracelsus_coat"], 
		"mods": {"max_hp_pct": 0.1}, "effects": {"summon_dmg": 0.5, "homun_power": 0.5, "falcon_dmg": 0.5, "summon_count": 1.0}, 
		"desc": "Una invocación más por habilidad; tus invocaciones y tu halcón pegan otro 50% (homúnculos y plantas, otro 100%) y +10% de vida máxima", 
		"more": ["paracelsus_hat", "homunculus_charm"], "full_mods": {"max_hp_pct": 0.1}, "full_effects": {"summon_count": 1.0, "summon_dmg": 0.75, "homun_power": 0.75, "falcon_dmg": 0.75}, 
		"full_desc": "Otra invocación más por habilidad; tus invocaciones y tu halcón pegan otro 75% (homúnculos y plantas, otro 150%) y +10% de vida máxima"}, 
	"bradium_set": {"name": "Bradium", "build": "Elementos", "items": ["bradium_shield", "bradium_earring"], 
		"mods": {"dmg": 0.1}, "effects": {"weak_bonus": 0.3}, 
		"desc": "Todo tu daño con ventaja de elemento hace otro 30% más y +10% de daño", 
		"more": ["bradium_helm", "bradium_armor"], "full_mods": {"dmg": 0.15}, "full_effects": {"weak_bonus": 0.5}, 
		"full_desc": "Tus golpes eficaces por elemento hacen otro 50% más y +15% de daño"}, 
	"freya_tears": {"name": "Lágrimas de Freya", "build": "Crítico", "items": ["brisingamen", "critical_ring"], 
		"mods": {"crit_dmg": 0.4}, "effects": {"freya": 0.08}, 
		"desc": "Cada crítico recarga tus habilidades otros 0.08 s antes (hasta 4 veces por segundo y el 35% de cada recarga) y +40% de daño crítico", 
		"more": ["freya_crown", "freya_cape"], "full_mods": {"crit": 0.1, "crit_dmg": 0.6}, "full_effects": {"freya": 0.1}, 
		"full_desc": "Cada crítico recarga tus habilidades otros 0.1 s antes (hasta 4 veces por segundo y el 35% de cada recarga), +10% de crítico y +60% de daño crítico"}, 
	"gods_set": {"name": "Tesoros de los Dioses", "build": "Horda", "items": ["megingjard", "sleipnir"], 
		"mods": {"dmg": 0.15, "max_hp_pct": 0.15}, "effects": {"kill_heal": 0.004}, 
		"desc": "Cada muerte te cura otro poco, +15% de daño y +15% de vida máxima", 
		"more": ["jarngreipr", "thor_helm"], "full_mods": {"dmg": 0.2, "area": 0.2}, "full_effects": {"kill_heal": 0.006, "magnet_area": MAGNET_AREA}, 
		"full_desc": "Cada muerte te cura otro poco más, +20% de daño, +20% de área y otro +10% de área por cada +100% de radio de recogida"}, 





	"thor_wrath": {"name": "Ira de Thor", "build": "Aguante", "items": ["executioner_gloves", "punishment_shoes"], 
		"mods": {"dmg": 0.1}, "effects": {"stagger_hit": 0.4, "wing_fill": 0.1, "thor_bolt": 10.0, "stagger_elites": 1.0}, 
		"desc": "Tus golpes llenan el Aguante de los jefes y de las élites (desde cualquier Peligro), lo llenas un 10% más rápido y cada vez que lo rompes cae un rayo con 10 s de tu daño por segundo contra ese jefe, que salta a los 8 monstruos más cercanos (6 m) con la mitad; +10% de daño", 
		"more": ["asprika", "imperial_ring"], "full_mods": {"dmg": 0.15}, "full_effects": {"stagger_hit": 0.4, "wing_fill": 0.25, "thor_bolt": 6.0, "wing_stun": 0.5}, 
		"full_desc": "Tus golpes llenan otro poco el Aguante, lo llenas otro 25% más rápido, el rayo pega 6 s más, el aturdimiento dura 0,5 s más y +15% de daño"}, 
	"valkyrie_set": {"name": "Valquiria", "build": "Berserk", "items": ["valkyrie_helm", "valkyrian_armor"], 
		"mods": {"dmg": 0.3, "max_hp_pct": 0.2, "haste": 0.12}, "effects": {}, 
		"desc": "+30% de daño, +20% de vida máxima y -12% recarga", 
		"more": ["einherjar_boots", "valkyrie_ring"], "full_mods": {"dmg": 0.4, "aspd": 0.2, "haste": 0.1}, "full_effects": {}, 
		"full_desc": "+40% de daño, +20% de velocidad de ataque y -10% recarga"}, 
	"aegis_set": {"name": "Égida de las Valquirias", "build": "Evasión y bloqueo", "items": ["valkyrja_shield", "valkyrian_manteau"], 
		"mods": {"dodge": 0.1, "armor": 5.0, "dmg": 0.2}, "effects": {}, 
		"desc": "+10% de evasión, +5 de defensa y +20% de daño", 
		"more": ["valkyrja_greaves", "aegis_helm"], "full_mods": {"dodge": 0.1, "armor": 5.0, "dmg": 0.25}, "full_effects": {"block": 0.1}, 
		"full_desc": "+10% de bloqueo, +10% de evasión, +5 de defensa y +25% de daño"}, 
	"archer_set": {"name": "Set del Arquero", "items": ["apple_of_archer", "tights"], 
		"mods": {"aspd": 0.08, "basic_dmg": 0.1}, "desc": "+8% ASPD, +10% daño de ataques básicos"}, 
	"mage_set": {"name": "Set del Mago", "items": ["ribbon", "saints_robe", "earring"], 
		"mods": {"skill_dmg": 0.12, "haste": 0.06}, "desc": "+12% daño de habilidades, -6% recarga"}, 
	"knight_set": {"name": "Set del Caballero", "items": ["bandana", "chain_mail", "ring"], 
		"mods": {"armor": 3.0, "dmg": 0.08}, "desc": "+3 defensa, +8% daño"}, 
	"adventurer_set": {"name": "Set del Aventurero", "items": ["adventurers_suit", "sandals", "hood"], 
		"mods": {"move": 0.08, "xp": 0.1}, "desc": "+8% velocidad, +10% EXP"}, 
	"gunslinger_set": {"name": "Set del Pistolero", "items": ["goggles", "manteau", "glove"], 
		"mods": {"aspd": 0.06, "crit": 0.06}, "desc": "+6% ASPD, +6% crítico"}, 
	"thief_set": {"name": "Set del Ladrón", "items": ["bandana", "muffler", "glove"], 
		"mods": {"dodge": 0.05, "crit": 0.06}, "desc": "+5% evasión, +6% crítico"}, 
	"acolyte_set": {"name": "Set del Acólito", "items": ["cap", "saints_robe", "rosary"], 
		"mods": {"regen": 1.5, "skill_dmg": 0.08}, "desc": "+1.5 vida/s, +8% daño de habilidades"}, 
	"poring_combo": {"name": "Combo Poring", "cards": ["poring_card", "poporing_card"], 
		"mods": {"regen": 1.5, "crit": 0.03}, "desc": "+1.5 vida/s, +3% crítico"}, 
	"forest_combo": {"name": "Combo del Bosque", "cards": ["willow_card", "smokie_card"], 
		"mods": {"haste": 0.06, "dodge": 0.04}, "desc": "-6% recarga, +4% evasión"}, 
	"wolf_combo": {"name": "Combo de la Manada", "cards": ["wolf_card", "lunatic_card"], 
		"mods": {"crit": 0.06, "move": 0.05}, "desc": "+6% crítico, +5% velocidad"}, 
}









const STAGE_SETS: = {
	"prontera": ["aegis_set"], 
	"culvert": ["diabolus_venom"], 
	"payon": ["odin_grace"], 
	"pay_cave": ["vampire_blood"], 
	"byalan": ["paracelsus_lab"], 
	"turtle": ["diabolus_arcane", "thor_wrath"], 
	"pyramid": ["flame_rings"], 
	"anthell": ["gods_set"], 
	"orc": ["valkyrie_set"], 
	"orc_dun": ["ifrit_flames", "bloody_oath"], 
	"mjolnir": ["thor_wrath", "bradium_set"], 
	"clock_tower": ["freya_tears", "morpheus_dream"], 
	"glast": ["bloody_oath"], 
	"niflheim": ["diabolus_arcane"], 
	"nameless": ["vampire_blood", "flame_rings"], 
	"abbey": ["diabolus_venom", "aegis_set"], 
	"juperos": ["bradium_set"], 
	"toy_factory": ["morpheus_dream"], 
	"thanatos": ["valkyrie_set"], 
	"biolab": ["paracelsus_lab"], 
	"ice_dun": ["odin_grace"], 
	"ra_san": ["freya_tears"], 
	"thor": ["gods_set", "ifrit_flames"], 
}



const ITEM_TIERS: = [
	{"mult": 1.0, "color": Color(0.1, 0.1, 0.12)}, 
	{"mult": 1.3, "color": Color(0.12, 0.5, 0.18)}, 
	{"mult": 1.6, "color": Color(0.15, 0.3, 0.8)}, 
	{"mult": 2.0, "color": Color(0.55, 0.2, 0.7)}, 
]


const SLOT_WEIGHTS: = [54.0, 27.0, 13.0, 6.0]








const PURPLE_TRAITS: = {
	"vampiric": {"name": "Vampírica", "text": "Cada monstruo que matas te cura el %s de la vida", "fx": {"kill_heal": [0.001, 0.002, 0.003]}}, 
	"echo": {"name": "Eco", "text": "+%s de doble lanzamiento", "fx": {"double_cast": [0.02, 0.04, 0.06]}}, 
	"ember": {"name": "Ardiente", "text": "Tus habilidades pueden quemar (%s) y la quemadura pega +%s", "fx": {"skill_burn": [0.03, 0.05, 0.08], "burn_power": [0.04, 0.07, 0.1]}}, 
	"serrated": {"name": "Dentada", "text": "Tus golpes pueden hacer sangrar (%s) y el sangrado pega +%s", "fx": {"bleed_hit": [0.02, 0.04, 0.06], "bleed_power": [0.04, 0.07, 0.1]}}, 
	"venom": {"name": "Venenosa", "text": "+%s carga de veneno por dosis y el veneno pega +%s", "low": "El veneno pega +%s", 
		"fx": {"poison_stack": [0.0, 0.0, 1.0], "poison_dmg": [0.04, 0.07, 0.1]}, "whole": ["poison_stack"]}, 
	"hunter": {"name": "Cazadora", "text": "+%s de daño a jefes y MVP", "fx": {"vs_boss": [0.04, 0.07, 0.1]}}, 
	"breaker": {"name": "Quebrantadora", "text": "Llenas el Aguante de los jefes un %s más rápido", "fx": {"wing_fill": [0.05, 0.08, 0.12]}}, 
	"lingering": {"name": "Persistente", "text": "Tus estados duran un %s más", "fx": {"status_time": [0.06, 0.1, 0.15]}}, 
	"resonant": {"name": "Vibrante", "text": "Tus procs salen un %s más seguido", "fx": {"proc_chance": [0.05, 0.08, 0.12]}}, 
	"lucky": {"name": "Afortunada", "text": "+%s de probabilidad de drop", "fx": {"drop_find": [0.02, 0.03, 0.05]}}, 
	"blessed": {"name": "Bendita", "text": "+%s de curación", "fx": {"heal_power": [0.06, 0.1, 0.15]}}, 
	"shattering": {"name": "Demoledora", "text": "+%s de daño a un jefe aturdido por el Aguante", "fx": {"wing_broken": [0.03, 0.05, 0.08]}}, 
}






const TRAIT_ROLL_COST: = [0, 20000, 60000, 350000]
const TRAIT_ROLL_LATE: = [0, 40000, 120000, 600000]
const TRAIT_ROLL_CHEAP: = 5




func trait_fx(id: String, tier: int) -> Dictionary:
	var out: = {}
	var d: Dictionary = PURPLE_TRAITS.get(id, {})
	for f in d.get("fx", {}):
		var v: = float(d.fx[f][clampi(tier, 1, 3) - 1])
		if v > 0.0:
			out[f] = v
	return out



func trait_text(id: String, tier: int) -> String:
	var d: Dictionary = PURPLE_TRAITS.get(id, {})
	if d.is_empty():
		return ""
	var t: = clampi(tier, 1, 3)
	var fx: = trait_fx(id, t)
	var vals: = []
	for f in fx:
		vals.append(str(roundi(float(fx[f]))) if f in d.get("whole", []) else pct_text(float(fx[f])))
	return TranslationServer.translate(str(d.low) if t < 3 and d.has("low") else str(d.text)) % vals




func pct_text(v: float) -> String:
	var p: = v * 100.0
	var lang: = TranslationServer.get_locale().substr(0, 2)
	var s: = str(roundi(p)) if absf(p - roundf(p)) < 0.001 else String.num(p, 1)
	if lang in ["es", "pt", "ru", "de", "fr"]:
		s = s.replace(".", ",")
	return s + (" %" if lang in ["de", "fr"] else "%")





const REFINE_RATES: = {
	"w1": [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.6, 0.4, 0.19], 
	"w2": [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.6, 0.4, 0.2, 0.19], 
	"w3": [1.0, 1.0, 1.0, 1.0, 1.0, 0.6, 0.5, 0.2, 0.2, 0.19], 
	"w4": [1.0, 1.0, 1.0, 1.0, 0.6, 0.4, 0.4, 0.2, 0.2, 0.09], 
	"armor": [1.0, 1.0, 1.0, 1.0, 0.6, 0.4, 0.4, 0.2, 0.2, 0.09], 
}
const MAX_REFINE: = 10




const REFINE_STAT_STEP: = 0.15


const REFINE_SLOW_GROWTH: = {"crit_dmg": 1.0 / 3.0}
const REFINE_SAFE: = {"weapon": 7, "armor": 4}
const REFINE_OVER_DMG: = 0.05

const ORES: = {
	"oridecon": {"name": "Oridecon", "for": "weapon", "color": Color(0.75, 0.55, 0.9)}, 
	"elunium": {"name": "Elunium", "for": "armor", "color": Color(0.6, 0.8, 1.0)}, 
}
const ORE_DROP_CHANCE: = 0.002

const ITEM_SELL_BASE: = 20
const ITEM_SELL_PER_SLOT: = 30

const ITEM_SELL_LEGENDARY: = 600





const HARD: = {"hp": 1.2, "dmg": 1.5, "speed": 1.12, "rate": 1.3, "elite_extra": 1, 
	"raid_every": 0.8, "raid_hp": 1.15, "loot": 1.5, "small_chest": 1.5}




const SPHERE_HITS: = 14.0
const SPHERE_GAIN_CD: = 0.35
const SPHERE_ASPD: = 0.02
const ASURA_BASE: = 0.25
const ASURA_PER_SPHERE: = 0.15





const ASURA_X_HP_K: = 0.013
const ASURA_X_HP_POW: = 0.68


const ASURA_ECHO_DELAY: = 3.0




const ASURA_LG_MIN_CD: = 1.0


const MAMMONITE_BROKE: = 0.85





const BOWL_CHAIN_SHARE: = 0.4
const BOWL_CHAIN_LEN: = 3.0
const BOWL_CHAIN_SOURCES: = 12
const BOWL_CHAIN_MAX: = 30
const BOWL_CLUMP_GAP: = 0.5


const CART_ZENY_STEP: = 4000.0
const CART_ZENY_MAX: = 2.0

const GOLDEN_AXE_RUN_MAX: = 3.0



const MERCHANT_BANK_FROM: = 10000.0
const MERCHANT_BANK_DMG: = 0.12
const MERCHANT_BANK_MAX: = 0.4


const BANK_POWER: = 0.5
const BANK_POWER_MAX: = 2.0




const ACHIEVEMENT_CATS: = {"battle": "Combate", "adventure": "Aventura", "growth": "Progreso", 
	"collection": "Colección", "economy": "Zeny y forja", "social": "En grupo (extra: no cuentan para el total)"}
const ACHIEVEMENTS: = {
	"kills_100": {"cat": "battle", "icon": "icon_battle", "name": "Primeros pasos", "desc": "Derrota 100 monstruos.", "stat": "kills", "goal": 100, "coins": 1}, 
	"kills_1k": {"cat": "battle", "icon": "icon_battle", "name": "Cazador", "desc": "Derrota 1.000 monstruos.", "stat": "kills", "goal": 1000, "coins": 2}, 
	"kills_10k": {"cat": "battle", "icon": "icon_battle", "name": "Exterminador", "desc": "Derrota 10.000 monstruos.", "stat": "kills", "goal": 10000, "coins": 3}, 
	"kills_50k": {"cat": "battle", "icon": "icon_battle", "name": "Leyenda de Rune-Midgard", "desc": "Derrota 50.000 monstruos.", "stat": "kills", "goal": 50000, "coins": 5}, 
	"boss_10": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Cazajefes", "desc": "Derrota 10 jefes.", "stat": "boss_kills", "goal": 10, "coins": 2}, 
	"boss_100": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Azote de los jefes", "desc": "Derrota 100 jefes.", "stat": "boss_kills", "goal": 100, "coins": 3}, 
	"mvp_1": {"cat": "battle", "icon": "icon_goal_achieve", "name": "¡MVP!", "desc": "Derrota a tu primer MVP.", "stat": "mvp_kills", "goal": 1, "coins": 1}, 
	"mvp_10": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Cazador de MVP", "desc": "Derrota 10 MVP.", "stat": "mvp_kills", "goal": 10, "coins": 2}, 
	"mvp_50": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Matadioses", "desc": "Derrota 50 MVP.", "stat": "mvp_kills", "goal": 50, "coins": 5}, 
	"hit_10k": {"cat": "battle", "icon": "icon_battle", "name": "Golpe devastador", "desc": "Haz un golpe de 10.000 de daño.", "stat": "best_hit", "goal": 10000, "coins": 2}, 
	"hit_100k": {"cat": "battle", "icon": "icon_battle", "name": "Golpe del fin del mundo", "desc": "Haz un golpe de 100.000 de daño.", "stat": "best_hit", "goal": 100000, "coins": 4}, 
	"dps_1k": {"cat": "battle", "icon": "icon_battle", "name": "Tormenta de acero", "desc": "Termina una partida con 1.000 de daño por segundo.", "stat": "best_dps", "goal": 1000, "coins": 2}, 
	"dps_10k": {"cat": "battle", "icon": "icon_battle", "name": "Cataclismo", "desc": "Termina una partida con 10.000 de daño por segundo.", "stat": "best_dps", "goal": 10000, "coins": 4}, 
	"stages_2": {"cat": "adventure", "icon": "icon_see", "name": "Viajero", "desc": "Vence al MVP de 2 mapas distintos.", "stat": "stages", "goal": 2, "coins": 1}, 
	"altar_1": {"cat": "adventure", "icon": "icon_goal_achieve", "name": "Ofrenda", "desc": "Acepta el trato de un Altar de los Dioses.", "stat": "altars", "goal": 1, "coins": 1}, 
	"altar_50": {"cat": "adventure", "icon": "icon_goal_achieve", "name": "Elegido de los dioses", "desc": "Acepta 50 tratos de los Altares de los Dioses.", "stat": "altars", "goal": 50, "coins": 3}, 
	"altar_run_5": {"cat": "battle", "icon": "icon_battle", "name": "Tentando a los dioses", "desc": "Acepta 5 altares en una misma partida.", "stat": "altars_run", "goal": 5, "coins": 3}, 
	"explore_all": {"cat": "adventure", "icon": "icon_see", "name": "Cartógrafo", "desc": "Entra en todos los mapas del mundo.", "stat": "entered", "goal": "all", "coins": 3}, 
	"regions_all": {"cat": "adventure", "icon": "icon_see", "name": "Viajero de Midgard", "desc": "Vence a un MVP en cada región.", "stat": "regions", "goal": "all", "coins": 4}, 
	"danger_5": {"cat": "adventure", "icon": "icon_goal_achieve", "name": "Valiente", "desc": "Desbloquea el peligro 5.", "stat": "max_danger", "goal": 5, "coins": 2}, 
	"danger_10": {"cat": "adventure", "icon": "icon_goal_achieve", "name": "Temerario", "desc": "Desbloquea el peligro 10.", "stat": "max_danger", "goal": 10, "coins": 3}, 
	"danger_15": {"cat": "adventure", "icon": "icon_goal_achieve", "name": "Leyenda viviente", "desc": "Desbloquea el peligro 15.", "stat": "max_danger", "goal": 15, "coins": 5}, 
	"hell_5": {"cat": "adventure", "icon": "icon_goal_achieve", "name": "Señor del Infierno", "desc": "Desbloquea el Infierno 5.", "stat": "max_danger", "goal": 20, "coins": 8}, 
	"hell_7": {"cat": "adventure", "icon": "icon_goal_achieve", "name": "Noche sin fin", "desc": "Desbloquea el Infierno 7.", "stat": "max_danger", "goal": 22, "coins": 10}, 
	"hell_10": {"cat": "adventure", "icon": "icon_goal_achieve", "name": "Ragnarök", "desc": "Desbloquea el Infierno 10.", "stat": "max_danger", "goal": 25, "coins": 15}, 
	"hell_15": {"cat": "adventure", "icon": "icon_goal_achieve", "name": "Fimbulvetr", "desc": "Desbloquea el Infierno 15, el máximo.", "stat": "max_danger", "goal": 30, "coins": 20}, 
	"hell_mvp_1": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Bautismo de fuego", "desc": "Vence a un MVP en Infierno.", "stat": "hell_mvp", "goal": 1, "coins": 3}, 
	"hell_mvp_5": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Domador del Infierno", "desc": "Vence a un MVP en Infierno 5.", "stat": "hell_mvp", "goal": 5, "coins": 6}, 
	"hell_mvp_8": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Contra la marea", "desc": "Vence a un MVP en Infierno 8.", "stat": "hell_mvp", "goal": 8, "coins": 10}, 
	"heralds_10": {"cat": "battle", "icon": "icon_battle", "name": "Apagafuegos", "desc": "Derrota 10 Heraldos de Surtr.", "stat": "heralds", "goal": 10, "coins": 4}, 
	"hell_mvp_10": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Crepúsculo de los dioses", "desc": "Vence a un MVP en Infierno 10.", "stat": "hell_mvp", "goal": 10, "coins": 20}, 
	"hell_mvp_15": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Más allá del Ragnarök", "desc": "Vence a un MVP en Infierno 15.", "stat": "hell_mvp", "goal": 15, "coins": 30}, 
	"risen_500": {"cat": "battle", "icon": "icon_battle", "name": "Sin descanso", "desc": "Derrota 500 espectros alzados por el Ragnarök.", "stat": "risen_kills", "goal": 500, "coins": 5}, 
	"stages_all": {"cat": "adventure", "icon": "icon_see", "name": "Conquistador", "desc": "Vence al MVP de todos los mapas.", "stat": "stages", "goal": "all", "coins": 5}, 
	"hard_1": {"cat": "adventure", "icon": "icon_see", "name": "Sin miedo", "desc": "Vence a un MVP en peligro 8 o más.", "stat": "hard_stages", "goal": 1, "coins": 2}, 
	"hard_all": {"cat": "adventure", "icon": "icon_see", "name": "Pesadilla", "desc": "Vence a todos los MVP en peligro 8 o más.", "stat": "hard_stages", "goal": "all", "coins": 5}, 
	"quest_1": {"cat": "adventure", "icon": "icon_adventure", "name": "Buen samaritano", "desc": "Completa una quest.", "stat": "quests", "goal": 1, "coins": 1}, 
	"quest_4": {"cat": "adventure", "icon": "icon_adventure", "name": "Mano amiga", "desc": "Completa 4 quests.", "stat": "quests", "goal": 4, "coins": 2}, 
	"quest_all": {"cat": "adventure", "icon": "icon_adventure", "name": "Héroe de Midgard", "desc": "Completa todas las quests.", "stat": "quests", "goal": "all", "coins": 5}, 
	"endless_5": {"cat": "adventure", "icon": "icon_adventure", "name": "Sin fin", "desc": "Llega a 5 minutos de reloj en una partida infinita.", "stat": "endless_best", "goal": 300, "coins": 2}, 
	"endless_15": {"cat": "adventure", "icon": "icon_adventure", "name": "Incansable", "desc": "Llega a 15 minutos de reloj en una partida infinita.", "stat": "endless_best", "goal": 900, "coins": 3}, 
	"endless_30": {"cat": "adventure", "icon": "icon_adventure", "name": "Eterno", "desc": "Llega a 30 minutos de reloj en una partida infinita.", "stat": "endless_best", "goal": 1800, "coins": 5}, 
	"runs_10": {"cat": "adventure", "icon": "icon_adventure", "name": "Aventurero", "desc": "Juega 10 partidas.", "stat": "runs", "goal": 10, "coins": 1}, 
	"runs_100": {"cat": "adventure", "icon": "icon_adventure", "name": "Veterano de mil batallas", "desc": "Juega 100 partidas.", "stat": "runs", "goal": 100, "coins": 3}, 
	"play_10h": {"cat": "adventure", "icon": "icon_adventure", "name": "Toda una vida", "desc": "Juega 10 horas en total.", "stat": "play_time", "goal": 36000, "coins": 4}, 
	"lvl_30": {"cat": "growth", "icon": "icon_goal_level", "name": "En forma", "desc": "Llega al nivel 30 en una partida.", "stat": "run_level", "goal": 30, "coins": 1}, 
	"lvl_60": {"cat": "growth", "icon": "icon_goal_level", "name": "Imparable", "desc": "Llega al nivel 60 en una partida.", "stat": "run_level", "goal": 60, "coins": 3}, 
	"job_1": {"cat": "growth", "icon": "icon_job_change", "name": "Segunda clase", "desc": "Haz tu primer cambio de clase en una partida.", "stat": "jobs", "goal": 1, "coins": 1}, 
	"job_5": {"cat": "growth", "icon": "icon_job_change", "name": "Mil caminos", "desc": "Llega a 5 segundas clases distintas.", "stat": "jobs", "goal": 5, "coins": 3}, 
	"class_10": {"cat": "growth", "icon": "icon_goal_level", "name": "Maestría", "desc": "Llega a nivel de clase 10 con una clase.", "stat": "class_level", "goal": 10, "coins": 2}, 
	"classes_all": {"cat": "growth", "icon": "icon_job_change", "name": "Polifacético", "desc": "Juega con todas las clases.", "stat": "classes", "goal": "all", "coins": 2}, 
	"reborn_1": {"cat": "growth", "icon": "icon_job_change", "name": "Renacido", "desc": "Renace con una clase en Valhalla.", "stat": "reborn", "goal": 1, "coins": 3}, 
	"reborn_all": {"cat": "growth", "icon": "icon_job_change", "name": "Ejército de Valhalla", "desc": "Renace con todas las clases.", "stat": "reborn", "goal": "all", "coins": 5}, 
	"stat_50": {"cat": "growth", "icon": "icon_goal_status", "name": "Fuerza bruta", "desc": "Sube un atributo a 50 en una partida.", "stat": "best_stat", "goal": 50, "coins": 2}, 
	"stat_150": {"cat": "growth", "icon": "icon_goal_status", "name": "Semidiós", "desc": "Sube un atributo a 150 en una partida.", "stat": "best_stat", "goal": 150, "coins": 4}, 
	"evo_1": {"cat": "growth", "icon": "icon_inchant_success", "name": "Evolución", "desc": "Evoluciona una habilidad.", "stat": "evos", "goal": 1, "coins": 1}, 
	"evo_10": {"cat": "growth", "icon": "icon_inchant_success", "name": "Maestro de las artes", "desc": "Evoluciona 10 habilidades distintas.", "stat": "evos", "goal": 10, "coins": 3}, 
	"cards_10": {"cat": "collection", "icon": "icon_get_item", "name": "Coleccionista", "desc": "Reúne 10 cartas en el álbum.", "stat": "cards", "goal": 10, "coins": 1}, 
	"cards_50": {"cat": "collection", "icon": "icon_get_item", "name": "Gran coleccionista", "desc": "Reúne 50 cartas en el álbum.", "stat": "cards", "goal": 50, "coins": 3}, 
	"cards_all": {"cat": "collection", "icon": "icon_get_item", "name": "Álbum completo", "desc": "Reúne todas las cartas.", "stat": "cards", "goal": "all", "coins": 5}, 
	"legend_1": {"cat": "collection", "icon": "icon_get_item", "name": "¡Legendario!", "desc": "Consigue un objeto legendario.", "stat": "legendaries", "goal": 1, "coins": 2}, 
	"legend_25": {"cat": "collection", "icon": "icon_get_item", "name": "Tesoro de los dioses", "desc": "Consigue 10 objetos legendarios.", "stat": "legendaries", "goal": 10, "coins": 4}, 
	"pet_1": {"cat": "collection", "icon": "icon_taming", "name": "Amigo fiel", "desc": "Consigue una mascota.", "stat": "pets", "goal": 1, "coins": 1}, 
	"pet_all": {"cat": "collection", "icon": "icon_taming", "name": "Zoológico de Prontera", "desc": "Consigue todas las mascotas (sin contar las de MVP).", "stat": "pets", "goal": "all", "coins": 5}, 
	"pet_mvp_1": {"cat": "collection", "icon": "icon_taming", "name": "Domador de leyendas", "desc": "Doma a un MVP como mascota.", "stat": "mvp_pets", "goal": 1, "coins": 5}, 
	"recipe_1": {"cat": "collection", "icon": "icon_eat", "name": "Buen provecho", "desc": "Aprende una receta de Klaws.", "stat": "recipes", "goal": 1, "coins": 1}, 
	"recipe_all": {"cat": "collection", "icon": "icon_eat", "name": "Gourmet", "desc": "Aprende todas las recetas de Klaws.", "stat": "recipes", "goal": "all", "coins": 3}, 
	"zeny_100k": {"cat": "economy", "icon": "icon_get_zeny", "name": "Ahorrador", "desc": "Gana 100.000 zeny en total.", "stat": "zeny_earned", "goal": 100000, "coins": 2}, 
	"zeny_1m": {"cat": "economy", "icon": "icon_get_zeny", "name": "Millonario", "desc": "Gana 1.000.000 de zeny en total.", "stat": "zeny_earned", "goal": 1000000, "coins": 4}, 
	"spend_50k": {"cat": "economy", "icon": "icon_spend_zeny", "name": "Cliente de la Kafra", "desc": "Gasta 50.000 zeny en Prontera.", "stat": "zeny_spent", "goal": 50000, "coins": 2}, 
	"spend_500k": {"cat": "economy", "icon": "icon_spend_zeny", "name": "Mecenas de Prontera", "desc": "Gasta 500.000 zeny en Prontera.", "stat": "zeny_spent", "goal": 500000, "coins": 4}, 
	"refine_7": {"cat": "economy", "icon": "icon_enchant_success", "name": "Herrero aficionado", "desc": "Refina un objeto a +7 en una partida.", "stat": "best_refine", "goal": 7, "coins": 2}, 
	"refine_10": {"cat": "economy", "icon": "icon_enchant_success", "name": "Maestro refinador", "desc": "Refina un objeto a +10 en una partida.", "stat": "best_refine", "goal": 10, "coins": 4}, 
	"forge_7": {"cat": "economy", "icon": "icon_enchant_success", "name": "Obra maestra", "desc": "Refina un objeto del almacén a +7 con Nakurusa.", "stat": "storage_refine", "goal": 7, "coins": 3}, 
	"broken": {"cat": "economy", "icon": "icon_enchant_fail", "name": "Lágrimas de herrero", "desc": "Rompe un objeto al refinarlo.", "stat": "broken", "goal": 1, "coins": 1}, 



	"tower_25": {"cat": "adventure", "icon": "icon_goal_achieve", "name": "Escalador", "desc": "Supera el piso 25 de la Endless Tower.", "stat": "tower_top", "goal": 25, "coins": 2}, 
	"tower_50": {"cat": "adventure", "icon": "icon_goal_achieve", "name": "Mitad del cielo", "desc": "Supera el piso 50 de la Endless Tower.", "stat": "tower_top", "goal": 50, "coins": 3}, 
	"tower_ach_100": {"cat": "adventure", "icon": "icon_goal_achieve", "name": "Sobre las nubes", "desc": "Supera el piso 100 de la Endless Tower.", "stat": "tower_top", "goal": 100, "coins": 5}, 
	"hel_10": {"cat": "adventure", "icon": "icon_adventure", "name": "Puertas de Niflheim", "desc": "Llega al piso 10 de la Torre de Hel.", "stat": "hel_top", "goal": 10, "coins": 3}, 
	"hel_50": {"cat": "adventure", "icon": "icon_adventure", "name": "Corazón de Niflheim", "desc": "Llega al piso 50 de la Torre de Hel.", "stat": "hel_top", "goal": 50, "coins": 5}, 
	"oath_5": {"cat": "battle", "icon": "icon_battle", "name": "Palabra dada", "desc": "Vence a un MVP con Juramento 5 o más.", "stat": "oath_top", "goal": 5, "coins": 2}, 
	"oath_15": {"cat": "battle", "icon": "icon_battle", "name": "Juramento de sangre", "desc": "Vence a un MVP con Juramento 15 o más.", "stat": "oath_top", "goal": 15, "coins": 4}, 
	"pot_1": {"cat": "growth", "icon": "icon_inchant_success", "name": "Polvo de estrellas", "desc": "Tira el Potencial estelar de una pieza con Altair.", "stat": "pot_rolls", "goal": 1, "coins": 1}, 
	"pot_legend": {"cat": "growth", "icon": "icon_inchant_success", "name": "Estrella legendaria", "desc": "Consigue una línea Legendaria de Potencial estelar.", "stat": "pot_legend", "goal": 1, "coins": 3}, 
	"pot_perfect": {"cat": "growth", "icon": "icon_inchant_success", "name": "Constelación perfecta", "desc": "Consigue una línea Legendaria perfecta de Potencial estelar.", "stat": "pot_perfect", "goal": 1, "coins": 4}, 
	"wings_5": {"cat": "growth", "icon": "icon_enchant_success", "name": "Plumas de Valkyria", "desc": "Refina unas Sword Wings a +5 con plumas.", "stat": "wings_top", "goal": 5, "coins": 2}, 
	"wings_10": {"cat": "growth", "icon": "icon_enchant_success", "name": "Alas de Asgard", "desc": "Refina unas Sword Wings a +10 con plumas.", "stat": "wings_top", "goal": 10, "coins": 5}, 
	"gacha_10": {"cat": "collection", "icon": "icon_get_item", "name": "Probando suerte", "desc": "Gira 10 veces la Máquina Gacha.", "stat": "gacha_spins", "goal": 10, "coins": 1}, 
	"gacha_50": {"cat": "collection", "icon": "icon_get_item", "name": "Coleccionista de cápsulas", "desc": "Gira 50 veces la Máquina Gacha.", "stat": "gacha_spins", "goal": 50, "coins": 3}, 
	"gacha_legend": {"cat": "collection", "icon": "icon_get_item", "name": "¡Legendario!", "desc": "Consigue un cosmético Legendario.", "stat": "cos_legendary", "goal": 1, "coins": 2}, 
	"gacha_unique": {"cat": "collection", "icon": "icon_get_item", "name": "Traje de gala", "desc": "Consigue un traje Único de cuerpo completo.", "stat": "cos_unique", "goal": 1, "coins": 3}, 
	"stagger_50": {"cat": "battle", "icon": "icon_battle", "name": "Rompeguardias", "desc": "Rompe el Aguante de los jefes 50 veces.", "stat": "stagger_breaks", "goal": 50, "coins": 2}, 
	"stagger_500": {"cat": "battle", "icon": "icon_battle", "name": "Martillo de los dioses", "desc": "Rompe el Aguante de los jefes 500 veces.", "stat": "stagger_breaks", "goal": 500, "coins": 4}, 
	"morroc_1": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Contra el Rey Demonio", "desc": "Derrota a Satan Morroc.", "stat": "satan_morroc", "goal": 1, "coins": 3}, 
	"finale_1": {"cat": "battle", "icon": "icon_goal_achieve", "name": "El fin de Infinito", "desc": "Vence el final de Infinito.", "stat": "morroc_finale", "goal": 1, "coins": 4}, 


	"coop_10": {"cat": "social", "extra": true, "icon": "icon_party", "name": "En buena compañía", "desc": "Termina 10 partidas en grupo.", "stat": "coop_runs", "goal": 10, "coins": 2}, 
	"coop_50": {"cat": "social", "extra": true, "icon": "icon_party", "name": "Hermandad", "desc": "Termina 50 partidas en grupo.", "stat": "coop_runs", "goal": 50, "coins": 3}, 
	"friends_5": {"cat": "social", "extra": true, "icon": "icon_add_friend", "name": "Círculo de amigos", "desc": "Ten 5 amigos.", "stat": "friends", "goal": 5, "coins": 2}, 
	"plag_10": {"cat": "growth", "icon": "icon_job_change", "name": "Copión", "desc": "Copia 10 habilidades distintas con Plagiarism.", "stat": "plagiarized", "goal": 10, "coins": 3}, 
	"ktullanux_1": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Deshielo", "desc": "Vence a Ktullanux en la Ice Cave.", "stat": "stage:ice_dun", "goal": 1, "coins": 3}, 
	"gloom_1": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Amanecer en el santuario", "desc": "Vence a Gloom Under Night en Rachel Sanctuary.", "stat": "stage:ra_san", "goal": 1, "coins": 3}, 
	"ifrit_1": {"cat": "battle", "icon": "icon_goal_achieve", "name": "Apagafuegos", "desc": "Vence a Ifrit en Thor Volcano.", "stat": "stage:thor", "goal": 1, "coins": 3}, 
}









const CHAMP_DESC: = "El #1 de su oficio la semana pasada subiendo en solitario la Endless Tower o la Torre de Hel. Se renueva cada lunes; varios títulos de campeón no suman su efecto."
const TITLES: = {
	"golden_poring": {"name": "Golden Poring", "tier": "especial", "check": "special", "mob": "gold_poring", "icon_scale": 1.2, 
		"color": Color(1.0, 0.8, 0.22), "desc": "Apoyó el desarrollo de Midgard Survivors con una donación. ¡Gracias!"}, 
	"angeling": {"name": "Angeling", "tier": "especial", "check": "special", "mob": "angeling", "icon_scale": 0.85, 
		"color": Color(1.0, 0.72, 0.9), "desc": "Miembro de Ko-fi: apoya el desarrollo de Midgard Survivors cada mes. ¡Gracias!"}, 
	"naght_bane": {"name": "Azote de Naght Sieger", "tier": "especial", "check": "special", "mob": "naght_sieger", 
		"color": Color(1.0, 0.38, 0.32), "desc": "Ganó el desafío del piso 100 de la Endless Tower en solitario."}, 












	"wb_week": {"name": "Campeón del Jefe del Mundo", "tier": "especial", "check": "special", "mob": "baphomet", 
		"temp": true, "effects": {"drop_find": 0.1}, 
		"color": Color(1.0, 0.5, 0.3), "desc": "Top 3 del Jefe del Mundo la semana pasada. Se renueva cada lunes."}, 
	"hel_week": {"name": "Campeón semanal de Hel", "tier": "especial", "check": "special", "mob": "randgris_fallen", "hel": true, 
		"temp": true, "effects": {"drop_find": 0.05}, 
		"color": Color(0.85, 0.35, 1.0), "desc": "Top 3 de la Torre de Hel (en solitario) la semana pasada. Se renueva cada lunes."}, 







	"champ_knight": {"name": "Campeón de Knight", "tier": "especial", "check": "special", "job_icon": 7, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(0.95, 0.42, 0.36), "desc": CHAMP_DESC}, 
	"champ_crusader": {"name": "Campeón de Crusader", "tier": "especial", "check": "special", "job_icon": 14, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(1.0, 0.6, 0.45), "desc": CHAMP_DESC}, 
	"champ_wizard": {"name": "Campeón de Wizard", "tier": "especial", "check": "special", "job_icon": 9, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(0.58, 0.52, 1.0), "desc": CHAMP_DESC}, 
	"champ_sage": {"name": "Campeón de Sage", "tier": "especial", "check": "special", "job_icon": 16, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(0.5, 0.65, 1.0), "desc": CHAMP_DESC}, 
	"champ_hunter": {"name": "Campeón de Hunter", "tier": "especial", "check": "special", "job_icon": 11, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(0.45, 0.85, 0.42), "desc": CHAMP_DESC}, 
	"champ_bard": {"name": "Campeón de Bard", "tier": "especial", "check": "special", "job_icon": 19, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(0.55, 0.9, 0.65), "desc": CHAMP_DESC}, 
	"champ_rebellion": {"name": "Campeón de Rebellion", "tier": "especial", "check": "special", "job_icon": 4215, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(0.9, 0.72, 0.48), "desc": CHAMP_DESC}, 
	"champ_kagerou": {"name": "Campeón de Kagerou", "tier": "especial", "check": "special", "job_icon": 4211, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(0.66, 0.52, 0.92), "desc": CHAMP_DESC}, 
	"champ_star_gladiator": {"name": "Campeón de Star Gladiator", "tier": "especial", "check": "special", "job_icon": 4047, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(1.0, 0.62, 0.38), "desc": CHAMP_DESC}, 
	"champ_soul_linker": {"name": "Campeón de Soul Linker", "tier": "especial", "check": "special", "job_icon": 4049, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(1.0, 0.75, 0.5), "desc": CHAMP_DESC}, 
	"champ_spirit_handler": {"name": "Campeón de Spirit Handler", "tier": "especial", "check": "special", "job_icon": 4218, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(0.95, 0.82, 0.5), "desc": CHAMP_DESC}, 
	"champ_assassin": {"name": "Campeón de Assassin", "tier": "especial", "check": "special", "job_icon": 12, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(0.75, 0.55, 0.95), "desc": CHAMP_DESC}, 
	"champ_rogue": {"name": "Campeón de Rogue", "tier": "especial", "check": "special", "job_icon": 17, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(0.62, 0.6, 0.9), "desc": CHAMP_DESC}, 
	"champ_priest": {"name": "Campeón de Priest", "tier": "especial", "check": "special", "job_icon": 8, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(1.0, 0.88, 0.5), "desc": CHAMP_DESC}, 
	"champ_monk": {"name": "Campeón de Monk", "tier": "especial", "check": "special", "job_icon": 15, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(1.0, 0.75, 0.4), "desc": CHAMP_DESC}, 
	"champ_blacksmith": {"name": "Campeón de Blacksmith", "tier": "especial", "check": "special", "job_icon": 10, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(0.92, 0.66, 0.36), "desc": CHAMP_DESC}, 
	"champ_alchemist": {"name": "Campeón de Alchemist", "tier": "especial", "check": "special", "job_icon": 18, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(0.7, 0.85, 0.45), "desc": CHAMP_DESC}, 
	"champ_super_novice": {"name": "Campeón de Super Novice", "tier": "especial", "check": "special", "job_icon": 23, "group": "champ", 
		"temp": true, "effects": {"drop_find": 0.05}, "color": Color(1.0, 0.8, 0.4), "desc": CHAMP_DESC}, 
	"hel_bane": {"name": "Azote de Hel", "tier": "especial", "check": "special", "mob": "naght_sieger", "hel": true, 
		"color": Color(0.95, 0.12, 0.18), "desc": "El primero en vencer al jefe del piso 100 de la Torre de Hel."}, 
	"cm": {"name": "Community Manager", "tier": "especial", "check": "special", "mob": "mystcase", 
		"color": Color(0.68, 0.45, 1.0), "desc": "Community Manager de Midgard Survivors: cuida el Discord y a sus jugadores."}, 
	"dev": {"name": "Creador de Midgard", "tier": "especial", "check": "special", "mob": "item_emperium", "rainbow": true, 
		"color": Color(1.0, 0.55, 0.95), "desc": "Creó Midgard Survivors."}, 
	"tower_150": {"name": "Rompecielos", "tier": "leyenda", "check": "tower", "goal": 150, 
		"color": Color(0.72, 0.6, 1.0), "desc": "Supera el piso 150 de la Endless Tower."}, 
	"hell_five": {"name": "Ragnarök Encarnado", "tier": "leyenda", "check": "hell_classes", "goal": 5, 
		"color": Color(1.0, 0.45, 0.2), "desc": "Vence a un MVP en Infierno 10, en solitario, con 5 clases distintas."}, 
	"hell_maps": {"name": "Terror de los Dioses", "tier": "leyenda", "check": "hell_maps", "goal": 10, 
		"color": Color(1.0, 0.62, 0.25), "desc": "Vence en Infierno 10, en solitario, a los MVP de 10 mapas distintos."}, 
	"rebirth_bane": {"name": "Freno del Renacimiento", "tier": "leyenda", "check": "", 
		"color": Color(0.72, 0.45, 1.0), "desc": "Vence en solitario a Morroc, el final de Infinito, en Infierno 10."}, 
	"untouchable": {"name": "Intocable", "tier": "leyenda", "check": "", 
		"color": Color(0.55, 0.95, 1.0), "desc": "Vence a un MVP en Infierno 10, en solitario, recibiendo en total menos daño que tu vida máxima."}, 
	"oath_max": {"name": "Elegido de Odín", "tier": "leyenda", "check": "", 
		"color": Color(1.0, 0.3, 0.28), "desc": "Vence a un MVP en solitario con todos los Juramentos en su rango más alto."}, 
	"oath_20": {"name": "Einherjar", "tier": "leyenda", "check": "oath", "goal": 20, 
		"color": Color(1.0, 0.42, 0.36), "desc": "Vence a un MVP en solitario con Juramento 20 o más."}, 
	"doomed": {"name": "Sentenciado", "tier": "leyenda", "check": "", 
		"color": Color(0.9, 0.25, 0.3), "desc": "Supera el piso 100 de la Endless Tower subiendo desde el piso 1 con la Sentencia de muerte y el Orgullo de los MVP activos."}, 
	"hel_tower": {"name": "Señor de Niflheim", "tier": "leyenda", "check": "hel", "goal": 100, "mob": "naght_sieger", 
		"color": Color(0.6, 0.45, 1.0), "desc": "Llega al piso 100 de la Torre de Hel."}, 
	"tower_100": {"name": "Cumbre de la Torre", "tier": "gloria", "check": "tower", "goal": 100, 
		"color": Color(0.7, 0.72, 1.0), "desc": "Supera el piso 100 de la Endless Tower."}, 
	"hell_trio": {"name": "Señor del Ragnarök", "tier": "gloria", "check": "hell_classes", "goal": 3, 
		"color": Color(1.0, 0.55, 0.4), "desc": "Vence a un MVP en Infierno 10, en solitario, con 3 clases distintas."}, 
	"lightning": {"name": "Relámpago", "tier": "gloria", "check": "", 
		"color": Color(1.0, 0.95, 0.45), "desc": "Vence al MVP de un mapa en Infierno 10, en solitario, en menos de 9 minutos."}, 
	"bare": {"name": "Sin Kafra", "tier": "gloria", "check": "", 
		"color": Color(0.75, 0.95, 0.6), "desc": "Vence a un MVP en Infierno 8 o más, en solitario, sin equipo inicial y sin caer ni una vez."}, 
	"hell_15": {"name": "Más allá del Ragnarök", "tier": "leyenda", "check": "", 
		"color": Color(0.85, 0.35, 1.0), "desc": "Vence a un MVP en Infierno 15, en solitario."}, 
	"oath_10": {"name": "Juramentado", "tier": "gloria", "check": "oath", "goal": 10, 
		"color": Color(0.95, 0.55, 0.5), "desc": "Vence a un MVP en solitario con Juramento 10 o más."}, 
	"emperium": {"name": "Rompe-Emperium", "tier": "gloria", "check": "", 
		"color": Color(0.6, 0.85, 1.0), "desc": "Rompe 70 Emperiums en una sola partida del Emperium Festival, en solitario."}, 


	"doomed_hel": {"name": "Condenado de Hel", "tier": "leyenda", "check": "", "mob": "naght_sieger", 
		"color": Color(0.75, 0.12, 0.3), "desc": "Llega al piso 100 de la Torre de Hel subiendo desde el piso 1 con la Sentencia de muerte y el Orgullo de los MVP activos."}, 

	"thor_hammer": {"name": "Martillo de Thor", "tier": "gloria", "check": "", "hidden": true, 
		"color": Color(0.6, 0.8, 1.0), "desc": "Rompe el Aguante de un MVP 8 veces en una sola pelea, en solitario."}, 
	"close_call": {"name": "Por un pelo", "tier": "gloria", "check": "", "hidden": true, 
		"color": Color(1.0, 0.5, 0.45), "desc": "Vence a un MVP en solitario con menos del 1% de tu vida."}, 
	"treasure_hunter": {"name": "Cazatesoros", "tier": "gloria", "check": "stat", "stat": "gold_poring", "goal": 25, "hidden": true, "mob": "gold_poring", 
		"color": Color(1.0, 0.82, 0.3), "desc": "Atrapa 25 veces al Poring Dorado con tesoro."}, 
	"bare_hands": {"name": "Puños limpios", "tier": "gloria", "check": "", "hidden": true, 
		"color": Color(0.85, 0.75, 0.6), "desc": "Vence a un MVP en solitario sin arma equipada."}, 
	"phoenix": {"name": "Fénix", "tier": "gloria", "check": "", "hidden": true, 
		"color": Color(1.0, 0.6, 0.25), "desc": "Gana una partida en solitario tras caer y revivir 3 veces."}, 
	"collector": {"name": "Coleccionista", "tier": "gloria", "check": "cosmetics", "hidden": true, 
		"color": Color(0.9, 0.7, 1.0), "desc": "Consigue todos los cosméticos de la Máquina Gacha de una misma rareza."}, 
}



const TITLE_HELL: = 10

const TITLE_HELL_TOP: = 15
const TITLE_FAST: = 540.0
const TITLE_BARE_HELL: = 8
const TITLE_EMPERIUMS: = 70


const TITLE_BREAKS: = 8
const TITLE_CLOSE_HP: = 0.01
const TITLE_PHOENIX_FALLS: = 3







const TOWN_BABY: = {"chance": 0.08, "gap": 10, "time": 45.0, "close": 1.6, "speed": 5.0, "scale": 0.72, "body": "super_novice", "every": [2.0, 3.5]}
const CROWD_LINES: = {
	"baby": ["zenyyyssss pls", "me das zeny?", "dame zeny", "oe dame zeny"], 
	"shouter": [
		"busco pt para Glast Heim, faltan 2, pm", "lf party Payon Cave, soy %s", "alguien pt? %s busca grupo", 
		"necesito priest para pt de Orc Dungeon!!", "bless agi plz", "alguien que me dé agi? :D", 
		"priest, dopa x favor ;_;", "kyrie plz antes del MVP", "me regalan zeny? soy nuevo", 
		"alguien 1k para potas?", "donen para mi carta ;_;", "x1 en el coliseo?", "quien quiere duelo? manco el que no venga", 
		"busco gente para Endless Tower", "alguien hace Orc Memory? pm", "instancia de Sealed Shrine, faltan 3", 
		"VENDO Elunium barato!! @ norte de la fuente", "S> Poring Card / B> Oridecon", "compro Old Blue Box, pm", 
		"B> Yggdrasil Berry 3k c/u", "guild activa busca gente, WoE todos los domingos", "alguien sabe cuándo sale el MVP?", 
	], 
	"idler": ["lag?", "jajaja", "brb", "afk un rato", "gg", "^^", "hola :D", "alguien vio a Baphomet?", "qué buena build tienes", "xD"], 
	"walker": ["permiso~", "voy a farmear un rato", "alguien para Pyramid?", "lol", "ya vuelvo"], 
	"leaver": ["me voy a lvlear, bye!", "nos vemos", "a por el MVP!!", "warp a Payon"], 
	"arrival": ["hola Prontera!", "volví :D", "uff, casi muero", "alguien vende potas?"], 
}
const CROWD_SHOPS: = ["Elus y Oris baratos", "Cartas raras ★", "Potas y alas", "Todo a 1z!! (mentira)", "Equipo +7 :D", 
	"Gemas azules", "Yggs 3k", "Flechas de fuego", "Compro cartas", "Ofertas de la fuente", "Sombreros únicos"]
const CROWD_ROOMS: = ["PT GH lvl 60+", "Buffs gratis :)", "Busco guild activa", "WoE guild recluta", "Pt Orc Dungeon", "Chat de amigos uwu", 
	"Pt Payon Cave", "Byalan lvl 50+", "Pyramid, falta tank", "Clock Tower 70+", "Juperos pt", "Caza MVP Baphomet", 
	"MVP Osiris, faltan 2", "Lf healer!!", "Lf tank para Niflheim", "Ant Hell farm", "Abbey, solo pros", "Novatos bienvenidos", 
	"Pt Turtle Island", "Mjolnir pt exp"]
const CROWD_NAMES_A: = ["Dark", "Shadow", "Lady", "Kiri", "Sakura", "Neko", "Pr0", "Lord", "Holy", "Mini", "Sweet", 
	"Killer", "Angel", "Ice", "Fire", "Luna", "Zero", "Kawaii", "Super", "Mr", "Sir", "Black"]
const CROWD_NAMES_B: = ["Knight", "Sin", "Priest", "Wiz", "Hunter", "Blade", "Poring", "Rose", "Star", "Dragon", "Soul", 
	"Fox", "Wolf", "Moon", "Storm", "Smith", "Bard", "Monk", "Rogue", "Sage", "Chan", "Kun"]




const TOWN_NPCS: = [
	{"id": "kafra", "sprite": "npc_kafra", "name": "Empleada Kafra", "title": "Mejoras y almacén", "cell": Vector2i(151, 191), "dir": 0, 
		"color": Color(0.55, 0.75, 1.0), 
		"lines": ["¡Mejoras permanentes para todos tus aventureros!", "Más daño, más vida, más botín... ¡pasa por aquí!"]}, 
	{"id": "sage", "sprite": "npc_sage", "name": "Chingue", "title": "Sabio de Juno", "cell": Vector2i(161, 191), "dir": 0, 
		"color": Color(0.7, 0.55, 1.0), 
		"lines": ["¿Quieres elegir mejor al subir de nivel?", "Rerolls, destierros y más opciones: la sabiduría de Juno."]}, 
	{"id": "pacts", "sprite": "npc_weapon_master", "name": "Gray", "title": "Maestro de armas", "cell": Vector2i(148, 176), "dir": 0, 
		"color": Color(1.0, 0.55, 0.4), 
		"lines": ["¿Peleas cuerpo a cuerpo? Te enseño un pacto.", "Cambia ranuras de habilidad por fuerza pura."]}, 
	{"id": "chef", "sprite": "npc_chef", "name": "Klaws", "title": "Chef", "cell": Vector2i(163, 176), "dir": 0, 
		"color": Color(1.0, 0.8, 0.45), 
		"lines": ["¡La buena comida hace grandes aventureros!", "Elige un plato y te lo preparo para la aventura."]}, 
	{"id": "refiner", "sprite": "npc_refiner", "name": "Nakurusa", "title": "Refinador", "cell": Vector2i(144, 190), "dir": 0, "face_center": true, 
		"color": Color(0.85, 0.6, 0.35), 
		"lines": ["Tráeme tu equipo del almacén y lo dejo como nuevo... o lo rompo.", "Oridecon para armas, Elunium para armaduras."]}, 
	{"id": "rebirth", "sprite": "npc_valkyrie", "name": "Valkyrie", "title": "Renacimiento", "cell": Vector2i(156, 193), "dir": 0, 
		"color": Color(1.0, 0.85, 0.45), 
		"lines": ["Reúne los fragmentos de Ymir y renace en Valhalla.", "Los guerreros dignos renacen más fuertes."]}, 


	{"id": "party", "sprite": "npc_party", "name": "Lydia", "title": "Grupos (cooperativo)", "cell": Vector2i(139, 172), "dir": 6, 
		"color": Color(0.55, 0.9, 1.0), 
		"lines": ["¿A la aventura con amigos? ¡Arma tu grupo aquí!", "Crea una sala y pasa el código, o únete a la de un amigo."]}, 
	{"id": "teleport", "sprite": "npc_teleporter", "name": "nearQ", "title": "Teletransportador", "cell": Vector2i(171, 179), "dir": 0, "face_center": true, 
		"color": Color(0.75, 0.6, 1.0), "event": true, 
		"lines": ["El espacio se pliega para quien sabe mirar...", "¿Conoces de verdad el filo de tu poder?"]}, 


	{"id": "gacha", "sprite": "npc_gacha_machine", "name": "Máquina Gacha", "title": "Cosméticos", "cell": Vector2i(141, 181), "dir": 0, 
		"color": Color(1.0, 0.55, 0.75), 
		"lines": ["¡Gira la máquina y llévate un cosmético!", "Sombreros, alas, mochilas... ¿Te tocará uno legendario?"]}, 




	{"id": "star_smith", "sprite": "npc_star_smith", "through": true, 
		"name": "Altair", "title": "Emperador Estelar", "cell": Vector2i(137, 187), "dir": 0, "face_center": true, 
		"color": Color(1.0, 0.85, 0.45), 
		"lines": ["Star Crumbs: tres líneas nuevas para tu equipo.", "¿Brillará en dorado esta vez?"]}, 
	{"id": "socket", "sprite": "npc_socket", "name": "Abstract", "title": "Engarzador", "cell": Vector2i(168, 190), "dir": 0, "face_center": true, 
		"color": Color(0.7, 0.85, 0.6), 
		"lines": ["Un hueco más para tus cartas... si tienes el material.", "Hasta las legendarias tienen sitio para una carta."]}, 
]














const ALTAR_EVERY: = [60.0, 90.0]
const ALTAR_MAX: = 5
const ALTAR_DIST: = [25.0, 30.0]
const ALTAR_LIFE: = 120.0
const ALTAR_CHANNEL: = 2.0
const ALTAR_RADIUS: = 1.8
const EMPERIUM_GUARDS: = 5



const ALTAR_MVP_HP_MAX: = 1.0
const ALTARS: = {
	"odin": {"name": "Altar de Odin", "god": "Odin", "color": Color(0.8, 0.86, 1.0), "model": "altar_odin", "icon": "sleipnir", 
		"height": 3.6, "bad": "Más monstruos feroces", "good": "Tus procs y autocast salen un 30% más seguido", 
		"mods": {"elite": 1.0, "proc_chance": 0.3, "hit_proc": 0.3}}, 
	"freyja": {"name": "Altar de Freyja", "god": "Freyja", "color": Color(1.0, 0.82, 0.4), "model": "altar_freyja", "icon": "brisingamen", 
		"height": 4.0, "bad": "Monstruos +20% de daño", "good": "+8% de crítico y +15% de daño crítico", 
		"mods": {"enemy_dmg": 0.2, "crit": 0.08, "crit_dmg": 0.15}}, 
	"thor": {"name": "Altar de Thor", "god": "Thor", "color": Color(0.45, 0.72, 1.0), "model": "altar_thor", "icon": "mjolnir", 
		"height": 4.2, "bad": "+40% de monstruos", "good": "+20% de daño de habilidades y +30% de zeny", 
		"mods": {"spawn": 0.4, "skill_dmg": 0.2, "loot": 0.3}}, 
	"loki": {"name": "Altar de Loki", "god": "Loki", "color": Color(0.5, 0.95, 0.4), "model": "altar_loki", "icon": "bloody_branch", 
		"height": 3.4, "bad": "Monstruos +25% de velocidad", "good": "+30% de probabilidad de carta y +0,5% de legendarias en los cofres", 
		"mods": {"enemy_speed": 0.25, "card": 0.3, "legend": 0.005}}, 
	"niflheim": {"name": "Altar de Niflheim", "god": "Niflheim", "color": Color(0.7, 0.45, 1.0), "model": "altar_niflheim", "icon": "dead_branch", 
		"height": 3.0, "bad": "Monstruos +25% de vida", "good": "+35% de EXP, +10% de daño de habilidades y +20% de daño de invocaciones", 


		"mods": {"enemy_hp": 0.25, "xp": 0.35, "skill_dmg": 0.1, "summon_dmg": 0.2}}, 
	"valkyrie": {"name": "Altar de la Valkyrie", "god": "Valkyrie", "color": Color(1.0, 0.62, 0.78), "model": "altar_valkyrie", "icon": "valkyrie_helm", 
		"height": 3.8, "bad": "El MVP llega 60 s antes y con +25% de vida (los altares, hasta +100%)", "good": "+20% de daño y +10% de vida máxima", 
		"mods": {"mvp_early": 60.0, "mvp_hp": 0.25, "dmg": 0.2, "max_hp_pct": 0.1}}, 
	"emperium": {"name": "Emperium", "god": "El Emperium", "color": Color(1.0, 0.86, 0.3), "model": "altar_emperium", "icon": "gem_emperium", 
		"height": 2.6, "bad": "Aparece su guardia de élites", "good": "Véncela: Treasure Box del MVP y +1 nivel", 
		"mods": {"guardians": 1}}, 
	"yggdrasil": {"name": "Brote de Yggdrasil", "god": "Yggdrasil", "color": Color(0.5, 1.0, 0.62), "model": "altar_yggdrasil", "icon": "yggdrasil_leaf", 
		"height": 3.0, "w": 0.3, "bad": "", "good": "+1 vida extra y +2 de vida por segundo", 
		"mods": {"lives": 1, "regen": 2.0}}, 




	"baldur": {"name": "Altar de Baldur", "god": "Baldur", "color": Color(1.0, 0.93, 0.6), "model": "altar_valkyrie", "icon": "blessing", 
		"height": 3.8, "karma": 1, "calm": true, "bad": "Solo si no te golpean mientras rezas", 
		"good": "+10% vida máxima, +5% daño y vida al máximo  ·  hacia Valhalla", 
		"mods": {"max_hp_pct": 0.1, "dmg": 0.05, "heal": 1}}, 
	"hel": {"name": "Altar de Hel", "god": "Hel", "color": Color(0.85, 0.12, 0.2), "model": "altar_niflheim", "icon": "dead_branch", 
		"height": 3.2, "karma": -1, "bad": "−15% de vida máxima", "good": "+10% de daño (multiplica)  ·  hacia Niflheim", 
		"mods": {"max_hp_pct": -0.15, "dmg": 0.1}}, 



	"hypnotist": {"name": "El Hipnotista", "god": "El Hipnotista", "color": Color(0.74, 0.46, 1.0), "npc": "npc_hypnotist", 
		"height": 3.4, "w": 0.0, "bad": "Olvida y destierra una habilidad que tienes", "good": "Sus niveles pasan a otra habilidad, nueva o que ya tengas", 
		"mods": {}}, 
}



# [MOD] Altar spawn weights, read at the roll site in core/altars.gd spawn() (the only place the
# pool is picked; force-spawns from karma/net/debug bypass it). Shipped defaults are w=1.0 for every
# rollable altar except yggdrasil (w=0.3) - 7.3 total, so each of the seven was 13.7% and yggdrasil
# 4.1%. Rollable pool is the 8 ids WITHOUT "npc"/"karma": baldur/hel (karma) and hypnotist (npc) are
# not here. New odds: odin/thor/loki/emperium 6.0 = 20.4% each (measured 200 k rolls of the real loop,
# work/logs/altar_odds/: 20.47 / 20.34 / 20.41 / 20.39), yggdrasil 3.0 = 10.2% (kept at half the
# others - it is the only rollable altar with an empty "bad", so the dev's own w=0.3 is a scarcity signal,
# x10 here is already generous), freyja/niflheim/valkyrie 0.8 = 2.7% each. Total weight 29.4; the reward
# pool (the five altars whose "good" is a real reward) is 91.9% of spawns - stock 58.9%, or 45.2% if you
# count Emperium as a debuff altar, which is what v11 did and v15 undoes.
# EMPERIUM moved 0.8 -> 6.0 in v15 - it was mis-grouped with the "bad four" in v11. Its "bad" is a fight
# (EMPERIUM_GUARDS = 5 elites from the stage/tower tier pool, altars.gd:761-788) and its "good" is the best
# payout in the table: a 3-roll bonus-2 MVP Treasure Box (altars.gd:796 -> main.gd:13598) plus +1 level per
# hero (altars.gd:799-803). That box goes through roll_item()'s normal pool, so it is one of the two altars
# that can mint Sword Wings (SWORD_WINGS_FARM_GUIDE.md §11). The genuinely bad three are the ones whose
# "bad" side scales with the monster curve and pays nothing: enemy_dmg +20%, enemy_hp +25%, MVP +25% HP early.
const MOD_ALTAR_W: = {"odin": 6.0, "thor": 6.0, "loki": 6.0, "yggdrasil": 3.0, "freyja": 0.8, "niflheim": 0.8, "valkyrie": 0.8, "emperium": 6.0}
# [MOD] Baldur vs Hel are a separate spawn (karma.gd, every KARMA_ALTAR_EVERY from KARMA_ALTAR_FROM):
# shipped 50/50 pick_random(). 0.75 = three Baldur (heal, +10% HP, +5% dmg, Valhalla route) per Hel
# (-15% max HP, Niflheim route).
const MOD_KARMA_BALDUR: = 0.75
const HYPNO_AT: = [150.0, 330.0, 510.0]
const HYPNO_ENDLESS_EVERY: = 180.0
const HYPNO_LIFE: = 120.0
const HYPNO_WINDOW: = 60.0


const HYPNO_KEEP: = ["call_homunculus", "call_homunculus_x"]






const FUSE_COST: = {"normal": 5, "boss": 10, "mvp": 20}

const DAILY_FIRST_BONUS: = 0.5
const ETERNAL_UNSOCKET_ZENY: = {"normal": 500, "boss": 1500, "mvp": 4000}
const ETERNAL_COLOR: = Color(1.0, 0.78, 0.3)
const SOCKET_MAX_EXTRA: = 1
const SOCKET_MAX_LEGENDARY: = 2
const SOCKET_COST: = [2000, 3000, 4500, 6000]
const SOCKET_COST_LEGENDARY: = [8000, 16000]


const SOCKET_CHANCE: = [0.6, 0.45, 0.3]
const SOCKET_CHANCE_LEGENDARY: = [0.2, 0.12]












const QUEST_AT: = 60.0
const QUEST_SPAWN_DIST: = [11.0, 16.0]




const QUEST_TALK_RANGE: = 2.6
const QUEST_COLOR: = Color(1.0, 0.82, 0.3)
const QUESTS: = {
	"prontera": {"spot": Vector2i(243, 190), "name": "El carro del Chef", "type": "defend", 
		"npc": "npc_chef", "npc_name": "Klaws", "npc_title": "Chef", "prop": "quest_cart", 
		"call": "¡Socorro! ¡Mi arroz!", 
		"talk": ["¡Aventurero, ayúdame! Llevo arroz a mi cocina de Prontera...", "...¡y los Poring quieren comérselo todo! Protege mi carro un minuto."], 
		"objective": "Protege el carro del Chef", 
		"duration": 60.0, "hits": 40, "mobs": ["poring", "poporing", "lunatic"], "every": 3.0, "batch": 2, 
		"thanks": "¡Mi arroz está a salvo! Ven a verme a Prontera: te cocinaré algo especial.", 
		"fail": "Mi arroz... ¡se lo han comido todo!", 
		"reward": {"unlock": "chef", "recipe": "rice_cake"}, 
		"hard": {"hits": 0.7, "duration": 1.25, "batch": 1.5}}, 


	"orc_dun": {"spot": Vector2i(46, 105), "name": "El herrero perdido", "type": "escort", 
		"npc": "npc_socket", "npc_name": "Abstract", "npc_title": "Engarzador", 
		"call": "¡Eh, tú! ¡Sácame de aquí!", 
		"talk": ["Bajé a buscar mineral para mis engarces y los orcos me rodearon...", "Llévame hasta la salida y te enseñaré a abrir huecos para cartas en tu equipo."], 
		"objective": "Lleva a Abstract a la salida", 
		"distance": [26.0, 34.0], "speed": 4.6, "hits": 25, "mobs": ["orc_zombie", "zenorc", "orc_skeleton"], "every": 3.5, "batch": 2, 
		"thanks": "¡Libre al fin! Búscame en Prontera: abriré huecos para cartas en tu equipo permanente.", 
		"fail": "Ugh... los orcos me atraparon otra vez...", 
		"reward": {"unlock": "socket"}, 
		"hard": {"hits": 0.7, "batch": 1.5}}, 


	"payon": {"spot": Vector2i(243, 210), "name": "El refinador enjaulado", "type": "hunt", "cage": true, 
		"npc": "npc_refiner", "npc_name": "Nakurusa", "npc_title": "Refinador", 
		"call": "¡Sácame de esta jaula!", 
		"talk": ["Un lobo vagabundo me encerró en esta jaula y se llevó la llave...", "Derrótalo y te lo pagaré: refinaré tu equipo en mi forja de Prontera."], 
		"objective": "Derrota al Lobo carcelero", 
		"guardian": "vagabond_wolf", "guardian_name": "Lobo carcelero", 
		"duration": 100.0, "mobs": ["wolf", "smokie"], "every": 4.0, "batch": 2, 
		"thanks": "¡Libre! Búscame en Prontera, junto a mi forja.", 
		"fail": "El lobo huyó con la llave...", 
		"reward": {"unlock": "refiner"}, 
		"hard": {"duration": 0.85, "batch": 1.5, "guardian_hp": 1.5}}, 


	"pay_cave": {"spot": Vector2i(134, 163), "name": "La hermana perdida", "type": "escort", 
		"npc": "npc_sister", "npc_name": "Hermana Clara", "npc_title": "Acólita", 
		"npc_look": {"body": "acolyte", "look": {"gender": "f", "hair": 17, "hair_color": 7, "cloth": 0}}, 
		"call": "¡Que alguien me guíe a la luz!", 
		"talk": ["Vine a rezar por las almas de la cueva y me perdí entre los muertos...", "Llévame a la salida y te daré la receta favorita de mi abadía. Y quizá un amigo."], 
		"objective": "Lleva a la hermana Clara a la salida", 
		"distance": [24.0, 32.0], "speed": 4.4, "hits": 25, "mobs": ["zombie", "skeleton", "munak"], "every": 3.5, "batch": 2, 
		"thanks": "¡Bendito seas! Este Bongun te seguirá desde ahora.", 
		"fail": "La oscuridad... me alcanzó...", 
		"reward": {"recipe": "steamed_tongue", "pet": "bon_gun"}, 
		"hard": {"hits": 0.7, "batch": 1.5}}, 



	"orc": {"spot": Vector2i(190, 157), "name": "El ladrón prisionero", "type": "ritual", 
		"npc": "npc_thief", "npc_name": "Rumin", "npc_title": "Ladrón", 
		"call": "¡Psst! ¡Aquí, aventurero!", 
		"talk": ["Los orcos me ataron con un hechizo de tres sellos...", "Rompe los sellos: quédate en cada círculo hasta que se apague. Te enseñaré un plato de ladrones."], 
		"objective": "Rompe los sellos de los orcos", 
		"circles": 3, "hold": 5.0, "seal_color": Color(1.0, 0.35, 0.3), 
		"duration": 110.0, "mobs": ["orc_baby", "ork_warrior", "orc_lady"], "every": 3.5, "batch": 2, 
		"thanks": "¡Libre! Toma, la receta de las patas de saltamontes. Crujientes.", 
		"fail": "Los sellos se cerraron otra vez...", 
		"reward": {"recipe": "fried_grasshopper"}, 
		"hard": {"duration": 0.85, "batch": 1.5, "hold": 1.3}}, 
	"glast": {"spot": Vector2i(154, 211), "name": "Los braseros de Glast Heim", "type": "ritual", "braziers": true, 
		"npc": "npc_priest", "npc_name": "Padre Bernard", "npc_title": "Sacerdote", 
		"call": "¡Ayúdame a encender la luz!", 
		"talk": ["Los muertos de Glast Heim temen al fuego sagrado...", "Enciende los cuatro braseros: quédate junto a cada uno hasta que prenda."], 
		"objective": "Enciende los braseros sagrados", 
		"circles": 4, "hold": 4.0, "seal_color": Color(1.0, 0.75, 0.3), 
		"duration": 120.0, "mobs": ["whisper", "ghoul", "skeleton"], "every": 3.5, "batch": 2, 
		"thanks": "La luz ha vuelto. Este guiso te dará fuerzas, y este Ghostring te cuidará.", 
		"fail": "Los braseros se apagaron...", 
		"reward": {"recipe": "immortal_stew", "card": "ghostring_card"}, 
		"hard": {"duration": 0.85, "batch": 1.5, "hold": 1.3}}, 
	"nameless": {"spot": Vector2i(216, 185), "name": "El faro de Nameless", "type": "defend", 
		"npc": "npc_sailor", "npc_name": "Marlo", "npc_title": "Farero", "prop": "ritual_bonfire", 
		"call": "¡El fuego del faro se apaga!", 
		"talk": ["Si el fuego del faro se apaga, ningún barco volverá a encontrar la isla...", "Defiéndelo de los muertos un poco más de un minuto."], 
		"objective": "Protege el fuego del faro", 
		"duration": 75.0, "hits": 45, "mobs": ["flame_skull", "hell_poodle", "ragged_zombie"], "every": 3.0, "batch": 2, 
		"thanks": "¡El faro sigue encendido! Toma, un plato de la isla y una carta que encontré en la playa.", 
		"fail": "El faro... se apagó...", 
		"reward": {"recipe": "nine_tail_dish", "card": "angeling_card"}, 
		"hard": {"hits": 0.7, "duration": 1.25, "batch": 1.5}}, 
	"abbey": {"spot": Vector2i(142, 111), "name": "El exorcismo de la abadía", "type": "ritual", 
		"npc": "npc_monk", "npc_name": "Hermano Gregor", "npc_title": "Monje", 
		"call": "¡La abadía está maldita!", 
		"talk": ["Tres sellos encierran algo terrible bajo la abadía...", "Purifícalos y acaba con lo que salga. Mi sopa de la suerte será tuya."], 
		"objective": "Purifica los sellos de la abadía", 
		"circles": 3, "hold": 5.0, "seal_color": Color(0.7, 0.5, 1.0), 
		"boss": "dullahan", "boss_name": "Dullahan maldito", 
		"duration": 150.0, "mobs": ["disguise", "gibbet", "hunter_fly"], "every": 3.5, "batch": 2, 
		"thanks": "La abadía es libre. La sopa es tuya... y este pequeño Baphomet también, por lo visto.", 
		"fail": "La maldición sigue aquí...", 
		"reward": {"recipe": "lucky_soup", "pet": "baphomet_jr"}, 
		"hard": {"duration": 0.85, "batch": 1.5, "hold": 1.3, "guardian_hp": 1.5}}, 

	"culvert": {"name": "La carreta de las cloacas", "type": "defend", 
		"npc": "quest_npc", "npc_name": "Tilda", "npc_title": "Comerciante", "prop": "quest_cart", 
		"npc_look": {"body": "merchant", "look": {"gender": "f", "hair": 6, "hair_color": 3, "cloth": 0}}, 
		"call": "¡Los bichos me roban la mercancía!", 
		"talk": ["Bajé con mi carreta a vender en las cloacas... ¡y los insectos la rodearon!", "Defiéndela un minuto y te quedas con mi Tarou. Sabe buscar cosas."], 
		"objective": "Protege la carreta de Tilda", 
		"duration": 60.0, "hits": 40, "mobs": ["thief_bug", "tarou", "cramp"], "every": 3.0, "batch": 2, 
		"thanks": "¡Mi mercancía está a salvo! Toma, este Tarou te seguirá a todas partes.", 
		"fail": "Se lo llevaron todo...", 
		"reward": {"pet": "tarou", "card": "thief_bug_card"}, 
		"hard": {"hits": 0.7, "duration": 1.25, "batch": 1.5}}, 
	"byalan": {"name": "El altar de Mastela", "type": "defend", 
		"npc": "quest_npc", "npc_name": "Sor Ondina", "npc_title": "Sacerdotisa", "prop": "ritual_bonfire", 
		"npc_look": {"body": "priest", "look": {"gender": "f", "hair": 9, "hair_color": 5, "cloth": 0}}, 
		"call": "¡El altar de la isla está en peligro!", 
		"talk": ["En este altar maceramos la fruta Mastela para el vino de la isla...", "Las criaturas del mar quieren apagarlo. Protégelo y la receta es tuya."], 
		"objective": "Protege el altar de Mastela", 
		"duration": 70.0, "hits": 45, "mobs": ["kukre", "vadon", "marina", "hydra"], "every": 3.0, "batch": 2, 
		"thanks": "El altar sigue en pie. Llévale esta receta a tu cocinero de Prontera.", 
		"fail": "El altar... se apagó...", 
		"reward": {"recipe": "mastela_wine"}, 
		"hard": {"hits": 0.7, "duration": 1.25, "batch": 1.5}}, 
	"turtle": {"name": "El rehén de las tortugas", "type": "hunt", "cage": true, 
		"npc": "quest_npc", "npc_name": "Sir Aldo", "npc_title": "Caballero", 
		"npc_look": {"body": "knight", "look": {"gender": "m", "hair": 4, "hair_color": 1, "cloth": 0}}, 
		"call": "¡Aventurero, sácame de aquí!", 
		"talk": ["Las tortugas guerreras me encerraron: su carcelero guarda la llave.", "Derrótalo y este Permeter que me seguía será tuyo."], 
		"objective": "Derrota a la Tortuga carcelera", 
		"guardian": "solider", "guardian_name": "Tortuga carcelera", 
		"duration": 100.0, "mobs": ["permeter", "freezer", "heater"], "every": 4.0, "batch": 2, 
		"thanks": "¡Libre! Gracias, aventurero. Cuida bien de este Permeter.", 
		"fail": "La tortuga huyó con la llave...", 
		"reward": {"pet": "permeter", "card": "solider_card"}, 
		"hard": {"duration": 0.85, "batch": 1.5, "guardian_hp": 1.5}}, 
	"pyramid": {"name": "El cocinero del desierto", "type": "hunt", "cage": true, 
		"npc": "quest_npc", "npc_name": "Hassan", "npc_title": "Cocinero nómada", 
		"npc_look": {"body": "thief", "look": {"gender": "m", "hair": 8, "hair_color": 2, "cloth": 0}}, 
		"call": "¡Las momias me han encerrado!", 
		"talk": ["Bajé a la pirámide a cazar escorpiones para mi guiso... y un Minorous me encerró.", "Derrótalo y te doy mi receta más picante."], 
		"objective": "Derrota al Minorous carcelero", 
		"guardian": "minorous", "guardian_name": "Minorous carcelero", 
		"duration": 100.0, "mobs": ["mummy", "isis", "matyr"], "every": 4.0, "batch": 2, 
		"thanks": "¡Libre! Escorpiones al vapor: que tus venenos piquen el doble.", 
		"fail": "El Minorous se escapó...", 
		"reward": {"recipe": "desert_scorpions"}, 
		"hard": {"duration": 0.85, "batch": 1.5, "guardian_hp": 1.5}}, 
	"anthell": {"name": "La apicultora perdida", "type": "escort", 
		"npc": "quest_npc", "npc_name": "Melisa", "npc_title": "Apicultora", 
		"npc_look": {"body": "hunter", "look": {"gender": "f", "hair": 3, "hair_color": 4, "cloth": 0}}, 
		"call": "¡Me he perdido entre las hormigas!", 
		"talk": ["Seguí a una abeja reina hasta este hormiguero y ya no sé salir...", "Llévame a la salida y te enseño mis pasteles de miel. A tus bichos les encantan."], 
		"objective": "Lleva a Melisa a la salida", 
		"distance": [24.0, 32.0], "speed": 4.6, "hits": 25, "mobs": ["andre", "piere", "deniro", "vitata"], "every": 3.5, "batch": 2, 
		"thanks": "¡Aire libre! Toma la receta de mis pasteles de miel.", 
		"fail": "Las hormigas... me rodearon...", 
		"reward": {"recipe": "honey_pastry"}, 
		"hard": {"hits": 0.7, "batch": 1.5}}, 
	"mjolnir": {"name": "El minero de Mjolnir", "type": "escort", 
		"npc": "quest_npc", "npc_name": "Brokk", "npc_title": "Minero", 
		"npc_look": {"body": "blacksmith", "look": {"gender": "m", "hair": 10, "hair_color": 6, "cloth": 0}}, 
		"call": "¡Eh, échame una mano!", 
		"talk": ["La mina se vino abajo y las avispas no me dejan salir...", "Llévame afuera y te enseño las brochetas de los mineros: con una nunca tienes bastante."], 
		"objective": "Lleva a Brokk fuera de la mina", 
		"distance": [26.0, 34.0], "speed": 4.4, "hits": 25, "mobs": ["hornet", "steel_chocho", "skel_worker", "iron_fist"], "every": 3.5, "batch": 2, 
		"thanks": "¡Fuera de la mina! Las Twin Spice Skewers son tuyas: todo te saldrá dos veces.", 
		"fail": "La mina... me tragó otra vez...", 
		"reward": {"recipe": "twin_skewer"}, 
		"hard": {"hits": 0.7, "batch": 1.5}}, 
	"clock_tower": {"name": "Las agujas del reloj", "type": "ritual", "braziers": true, 
		"npc": "quest_npc", "npc_name": "Otto", "npc_title": "Relojero", 
		"npc_look": {"body": "sage", "look": {"gender": "m", "hair": 12, "hair_color": 0, "cloth": 0}}, 
		"call": "¡El reloj se ha vuelto loco!", 
		"talk": ["Los engranajes de la torre se han desbocado y el tiempo se desordena...", "Ajusta las cuatro agujas: quédate junto a cada una hasta que encaje."], 
		"objective": "Ajusta las agujas del reloj", 
		"circles": 4, "hold": 4.0, "seal_color": Color(1.0, 0.85, 0.4), 
		"duration": 120.0, "mobs": ["punk", "alarm", "clock", "rideword"], "every": 3.5, "batch": 2, 
		"thanks": "¡En hora otra vez! Este Alarm no se separa de mí... mejor llévatelo tú.", 
		"fail": "Las agujas se soltaron...", 
		"reward": {"pet": "alarm", "card": "clock_card"}, 
		"hard": {"duration": 0.85, "batch": 1.5, "hold": 1.3}}, 
	"niflheim": {"name": "El manantial de Hwergelmir", "type": "ritual", 
		"npc": "quest_npc", "npc_name": "Sigrun", "npc_title": "Hechicera", 
		"npc_look": {"body": "wizard", "look": {"gender": "f", "hair": 14, "hair_color": 7, "cloth": 0}}, 
		"call": "¡El manantial se corrompe!", 
		"talk": ["Del manantial de Hwergelmir sale el tónico que afila la mente de los magos...", "Los muertos lo están corrompiendo. Purifica sus tres sellos y la receta será tuya."], 
		"objective": "Purifica los sellos del manantial", 
		"circles": 3, "hold": 5.0, "seal_color": Color(0.5, 0.75, 1.0), 
		"duration": 115.0, "mobs": ["quve", "hylozoist", "gibbet", "loli_ruri"], "every": 3.5, "batch": 2, 
		"thanks": "El manantial vuelve a ser puro. Bebe del tónico y tu magia no tendrá freno.", 
		"fail": "El manantial... se ha perdido...", 
		"reward": {"recipe": "hwergelmir_tonic"}, 
		"hard": {"duration": 0.85, "batch": 1.5, "hold": 1.3}}, 
	"juperos": {"name": "El explorador de Juperos", "type": "escort", 
		"npc": "quest_npc", "npc_name": "Rex", "npc_title": "Explorador", 
		"npc_look": {"body": "gunslinger", "look": {"gender": "m", "hair": 5, "hair_color": 2, "cloth": 0}}, 
		"call": "¡Las máquinas me persiguen!", 
		"talk": ["Vine a estudiar las ruinas de Juperos y despertaron las máquinas...", "Llévame a la salida. Un Dimik de estos me ha tomado cariño: puede ser tuyo."], 
		"objective": "Lleva a Rex a la salida", 
		"distance": [26.0, 34.0], "speed": 4.6, "hits": 25, "mobs": ["venatu", "venatu_1", "dimik", "dimik_1"], "every": 3.5, "batch": 2, 
		"thanks": "¡Lo logramos! Toma, este Dimik ya te sigue a ti.", 
		"fail": "Las máquinas... me alcanzaron...", 
		"reward": {"pet": "dimik", "card": "venatu_card"}, 
		"hard": {"hits": 0.7, "batch": 1.5}}, 
	"toy_factory": {"name": "El horno de Lutie", "type": "defend", 
		"npc": "quest_npc", "npc_name": "Nana", "npc_title": "Pastelera", "prop": "ritual_bonfire", 
		"npc_look": {"body": "alchemist", "look": {"gender": "f", "hair": 2, "hair_color": 4, "cloth": 0}}, 
		"call": "¡Mis tortitas se queman!", 
		"talk": ["Este horno hace las tortitas más ricas de Lutie... ¡y los juguetes quieren apagarlo!", "Protégelo un poco más de un minuto y te enseño la receta."], 
		"objective": "Protege el horno de Nana", 
		"duration": 70.0, "hits": 45, "mobs": ["cookie", "cookie_xmas", "cruiser", "mystcase"], "every": 3.0, "batch": 2, 
		"thanks": "¡Tortitas a salvo! Te regalo la receta: ligeras como tus flechas.", 
		"fail": "Mi horno... se ha apagado...", 
		"reward": {"recipe": "lutie_pancake"}, 
		"hard": {"hits": 0.7, "duration": 1.25, "batch": 1.5}}, 
	"thanatos": {"name": "Los sellos de Thanatos", "type": "ritual", 
		"npc": "quest_npc", "npc_name": "Hermano Elías", "npc_title": "Monje", 
		"npc_look": {"body": "monk", "look": {"gender": "m", "hair": 7, "hair_color": 0, "cloth": 0}}, 
		"call": "¡Los recuerdos de la torre despiertan!", 
		"talk": ["Los recuerdos de los caídos en esta torre se han vuelto contra los vivos...", "Sella los cuatro círculos y los dejaremos descansar. Uno de ellos te seguirá en paz."], 
		"objective": "Sella los recuerdos de Thanatos", 
		"circles": 4, "hold": 4.5, "seal_color": Color(0.75, 0.55, 1.0), 
		"duration": 125.0, "mobs": ["solace", "observation", "retribution", "shelter"], "every": 3.5, "batch": 2, 
		"thanks": "Descansan por fin. Este pequeño Observation ha decidido seguirte.", 
		"fail": "Los recuerdos... siguen despiertos...", 
		"reward": {"pet": "observation", "card": "retribution_card"}, 
		"hard": {"duration": 0.85, "batch": 1.5, "hold": 1.3}}, 
	"biolab": {"name": "El científico encerrado", "type": "hunt", "cage": true, 
		"npc": "quest_npc", "npc_name": "Dr. Wolfgang", "npc_title": "Científico", 
		"npc_look": {"body": "alchemist", "look": {"gender": "m", "hair": 11, "hair_color": 6, "cloth": 0}}, 
		"call": "¡Sus experimentos me encerraron!", 
		"talk": ["Mis propios experimentos se rebelaron y me encerraron aquí...", "Derrota a Laurell, el que tiene la llave. Este Kavac era mi ayudante: ahora será tuyo."], 
		"objective": "Derrota a Laurell carcelero", 
		"guardian": "rawrel", "guardian_name": "Laurell carcelero", 
		"duration": 100.0, "mobs": ["ygnizem", "whikebain", "kavac"], "every": 4.0, "batch": 2, 
		"thanks": "¡Libre! Cuida de Kavac: es más listo de lo que parece.", 
		"fail": "Laurell escapó con la llave...", 
		"reward": {"pet": "kavac", "card": "rawrel_card"}, 
		"hard": {"duration": 0.85, "batch": 1.5, "guardian_hp": 1.5}}, 
	"ice_dun": {"name": "La exploradora congelada", "type": "escort", 
		"npc": "quest_npc", "npc_name": "Freya", "npc_title": "Exploradora", 
		"npc_look": {"body": "hunter", "look": {"gender": "f", "hair": 13, "hair_color": 8, "cloth": 0}}, 
		"call": "¡No siento los pies... ayúdame!", 
		"talk": ["Vine a buscar el té de los Siroma y la cueva se cerró de hielo a mi espalda...", "Llévame a la salida antes de que me congele. Te enseñaré a preparar ese té."], 
		"objective": "Lleva a Freya fuera de la cueva", 
		"distance": [24.0, 32.0], "speed": 4.4, "hits": 25, "mobs": ["siroma", "snowier", "gazeti"], "every": 3.5, "batch": 2, 
		"thanks": "¡Calor al fin! El Siroma Iced Tea es tuyo: lo que congeles, quedará congelado.", 
		"fail": "El frío... me alcanzó...", 
		"reward": {"recipe": "siroma_tea"}, 
		"hard": {"hits": 0.7, "batch": 1.5}}, 


	"ra_san": {"name": "Los sellos estelares", "type": "ritual", 
		"npc": "npc_star_smith", "npc_name": "Altair", "npc_title": "Emperador Estelar", 
		"call": "¡Los sellos de las estrellas se rompen!", 
		"talk": ["Bajo este templo duerme Gloom Under Night, sellado con la luz de las estrellas que caen sobre Rachel...", 
			"Los demonios rompen los sellos. Renueva los cuatro: quédate en cada círculo hasta que brille.", 
			"Si aguantan, te enseñaré a despertar el poder dormido de tu equipo con Star Crumbs."], 
		"objective": "Renueva los sellos estelares", 
		"circles": 4, "hold": 4.5, "seal_color": Color(1.0, 0.9, 0.5), 
		"boss": "gremlin", "boss_name": "Gremlin rompesellos", 
		"duration": 140.0, "mobs": ["agav", "echio", "hodremlin"], "every": 3.5, "batch": 2, 
		"thanks": "Las estrellas aguantarán. Búscame en Prontera: con Star Crumbs despertaré tres líneas en tu equipo.", 
		"fail": "Los sellos... se rompieron...", 
		"reward": {"unlock": "star_smith"}, 
		"hard": {"duration": 0.85, "batch": 1.5, "hold": 1.3, "guardian_hp": 1.5}}, 
	"thor": {"name": "La herrera de Veins", "type": "hunt", "cage": true, 
		"npc": "quest_npc", "npc_name": "Brunhild", "npc_title": "Herrera", 
		"npc_look": {"body": "blacksmith", "look": {"gender": "f", "hair": 5, "hair_color": 1, "cloth": 0}}, 
		"call": "¡Quema! ¡Sácame de aquí!", 
		"talk": ["Subí al volcán a templar mi martillo en la lava y una Kasa me encerró...", "Derrótala y te llevas al Magmaring que me hacía compañía. Y una carta, por las molestias."], 
		"objective": "Derrota a la Kasa carcelera", 
		"guardian": "kasa", "guardian_name": "Kasa carcelera", 
		"duration": 100.0, "mobs": ["magmaring", "imp", "blazer"], "every": 4.0, "batch": 2, 
		"thanks": "¡Libre! Cuida de este Magmaring: calienta más de lo que parece.", 
		"fail": "La Kasa huyó con la llave...", 
		"reward": {"pet": "magmaring", "card": "explosion_card"}, 
		"hard": {"duration": 0.85, "batch": 1.5, "guardian_hp": 1.5}}, 
}


const QUEST_NPC_UNLOCK: = {"chef": "prontera", "socket": "orc_dun", "refiner": "payon", "star_smith": "ra_san"}

const QUEST_SEAL_DIST: = [6.0, 10.0]
const QUEST_SEAL_RADIUS: = 1.8















const CHEF_MAX_LEVEL: = 3

const RECIPE_RENAMED: = {"bomber_steak": "twin_skewer"}

const CHEF_LEVEL_COST: = {2: 1000000, 3: 3000000}
const RECIPES: = {
	"rice_cake": {"name": "Rice Cake", "icon": "dish_rice_cake", "quest": "prontera", 
		"desc": "Al subir de nivel o al aguantar un golpe mortal: una explosión de arroz empuja a los monstruos, los deja pegados 2 s y te cura un 15%.", 
		"heal": 0.15, "radius": 7.5, "push": 16.0, "glue": 2.0, "mods": {}}, 
	"steamed_tongue": {"name": "Steamed Tongue", "icon": "dish_steamed_tongue", "quest": "pay_cave", 
		"desc": "Mientras sigas atacando, cada ataque básico pega un 3% más que el anterior (hasta ×1,75). La racha se pierde tras 3 s sin atacar. +10% de daño básico.", 
		"step": 0.03, "cap": 0.75, "window": 3.0, "mods": {"basic_dmg": 0.1}}, 
	"fried_grasshopper": {"name": "Fried Grasshopper Legs", "icon": "dish_fried_grasshopper", "quest": "orc", 
		"desc": "Al esquivar o bloquear un golpe contraatacas al instante con un 150% de tu ataque básico. +8% de esquiva y +6% de velocidad de ataque.", 
		"counter": 1.5, "mods": {"dodge": 0.08, "aspd": 0.06}}, 

	"immortal_stew": {"name": "Immortal Stew", "icon": "dish_immortal_stew", "quest": "glast", 
		"desc": "Cada monstruo que derrotas te da +1 de vida máxima durante la partida (desde los 2000, +2 cada 5). En grupo, tus muertes hacen crecer la vida de todo el grupo.", 

		"per_kill": 1.0, "full_kills": 2000, "slow_every": 2.5}, 
	"nine_tail_dish": {"name": "Nine Tail Dish", "icon": "dish_nine_tail", "quest": "nameless", 
		"desc": "Cada 2 s un fuego de zorro golpea a los 3 monstruos más cercanos con el 150% de tu ataque básico (fuego). Devuelves el 30% del daño que recibes a los monstruos cercanos. +5% de bloqueo (con escudo) y +3 de defensa.", 
		"reflect": 0.3, "radius": 3.5, "mods": {"armor": 3.0}, "effects": {"block": 0.05}, 



		"fox_every": 2.0, "fox_count": 3, "fox_range": 7.0, "fox_mult": 1.5}, 
	"lucky_soup": {"name": "Lucky Soup", "icon": "dish_lucky_soup", "quest": "abbey", 
		"desc": "Tus críticos tienen un 3% de soltar un cofre pequeño (como mucho uno cada 30 s) y los cofres un 25% de traer un objeto más. +4% de crítico y +15% de daño crítico.", 
		"crit_chest": 0.03, "crit_chest_cd": 30.0, "extra_roll": 0.25, "mods": {"crit": 0.04, "crit_dmg": 0.15}}, 
	"twin_skewer": {"name": "Twin Spice Skewers", "icon": "dish_twin_skewer", "quest": "mjolnir", 
		"desc": "+10% de Doble lanzamiento: tus habilidades de ataque pueden lanzarse dos veces (no suma daño).", 
		"effects": {"double_cast": 0.1}}, 
	"hwergelmir_tonic": {"name": "Hwergelmir's Tonic", "icon": "dish_hwergelmir_tonic", "quest": "niflheim", 
		"desc": "Tus habilidades hacen +8% de daño, se recargan un 6% más rápido y abarcan un 6% más.", 
		"mods": {"skill_dmg": 0.08, "haste": 0.06, "area": 0.06}}, 
	"desert_scorpions": {"name": "Steamed Desert Scorpions", "icon": "dish_desert_scorpions", "quest": "pyramid", 
		"desc": "Veneno, sangrado y quemadura hacen +50% de daño, y tus estados alterados duran un 30% más.", 
		"effects": {"poison_dmg": 0.5, "bleed_dmg": 0.5, "burn_power": 0.5, "status_time": 0.3}}, 
	"honey_pastry": {"name": "Honey Pastry", "icon": "dish_honey_pastry", "quest": "anthell", 
		"desc": "Tus invocaciones, homúnculos y halcón hacen un 50% más de daño.", 
		"effects": {"summon_dmg": 0.5, "homun_power": 0.5, "falcon_dmg": 0.5}}, 
	"mastela_wine": {"name": "Mastela Fruit Wine", "icon": "dish_mastela_wine", "quest": "byalan", 
		"desc": "Tus curaciones curan un 40% más y tus bendiciones y canciones son un 25% más fuertes. +2 de regeneración.", 
		"effects": {"heal_power": 0.4, "buff_power": 0.25}, "mods": {"regen": 2.0}}, 
	"lutie_pancake": {"name": "Lutie Lady's Pancake", "icon": "dish_lutie_pancake", "quest": "toy_factory", 
		"desc": "+12% de daño básico, +10% de velocidad de ataque, +5% de velocidad de movimiento y proyectiles un 20% más rápidos.", 
		"mods": {"basic_dmg": 0.12, "aspd": 0.1, "move": 0.05, "proj_speed": 0.2}}, 


	"siroma_tea": {"name": "Siroma Iced Tea", "icon": "dish_siroma_tea", "quest": "ice_dun", 
		"desc": "Tus estados duran un 25% más y llenan un 50% más rápido el Aguante de los jefes y MVP. +6% de velocidad de movimiento.", 
		"effects": {"status_time": 0.25, "wing_fill": 0.5}, "mods": {"move": 0.06}}, 
}



func job_paths(class_id: String) -> Array:
	var d: Dictionary = CLASSES[class_id]
	var out: = []
	if d.has("job2"):
		out.append(d.job2)
	if d.has("job2_alt"):
		out.append(d.job2_alt)
	return out






func job_looks(class_id: String) -> Array:
	var d: Dictionary = CLASSES[class_id]
	var first: = {"name": str(d.name), "body": str(d.body), "weapon": str(d.get("weapon", "")), 
		"weapon_fx": str(d.get("weapon_fx", "")), "attack": d.get("attack", 5)}
	var out: = [first]
	for path in job_paths(class_id):
		var prev: = first
		for job in [path, path.get("trans", {})]:
			if (job as Dictionary).is_empty():
				continue
			var e: = {"job": job, "body": str(job.get("body", prev.body)), "weapon": str(job.get("weapon", prev.weapon)), 
				"weapon_fx": str(job.get("weapon_fx", prev.weapon_fx)), "attack": job.get("attack", prev.attack)}
			out.append(e)
			prev = e

	for lk in d.get("looks", []):
		out.append({"job": lk, "body": str(lk.body), "weapon": str(lk.weapon), "weapon_fx": str(lk.weapon_fx), "attack": lk.get("attack", first.attack)})
	return out





func shown_job(class_id: String, look: Dictionary) -> Dictionary:
	var all: = job_looks(class_id)
	var want: = str(look.get("show", ""))

	if want.begins_with("outfit_") and COSMETICS.has(want):
		return outfit_look(want, all[0])
	if want != "":
		for e in all:
			if str(e.get("job", {}).get("id", "")) == want:
				return e
	return all[0]






const OUTFIT_NO_SIT: = ["outfit_oktoberfest"]



static func outfit_sits(view: String) -> bool:
	return not OUTFIT_NO_SIT.has(view.trim_suffix("_f"))



func outfit_look(id: String, first: Dictionary) -> Dictionary:
	var d: Dictionary = COSMETICS[id]
	return {"job": {"id": id, "name": str(d.name)}, "body": str(d.view), "weapon": "", "weapon_fx": "", "attack": first.get("attack", 5)}



func outfit_looks(class_id: String) -> Array:
	var first: Dictionary = job_looks(class_id)[0]
	var out: = []
	for id in COSMETICS:
		if str(COSMETICS[id].slot) == "body" and Save.has_cosmetic(str(id)):
			out.append(outfit_look(str(id), first))
	return out



func job_title(job: Dictionary, female: bool) -> String:
	return str(job.get("name_f", job.name)) if female else str(job.name)












const PICK_X2_FROM: = 99
const PICK_X3_FROM: = 200
const CHOICE_RARITY: = [
	{"name": "Común", "color": Color(0.62, 0.65, 0.72), "steps": 1, "w": 70.0}, 
	{"name": "Rara", "color": Color(0.3, 0.55, 1.0), "steps": 2, "w": 22.0}, 
	{"name": "Épica", "color": Color(0.7, 0.35, 0.95), "steps": 3, "w": 7.0}, 
	{"name": "Legendaria", "color": Color(1.0, 0.68, 0.15), "steps": 3, "w": 1.0, "all_stats": 1}, 
]
const CHOICE_LUK_SHIFT: = 1.2



const TOWN_WALK_SPEED: = 4.8


const LEVEL_UP_PUSH_RADIUS: = 4.0
const LEVEL_UP_PUSH: = 12.0




const XP_GEMS: = [
	[0, "gem_blue", 1.15], 
	[8, "gem_yellow", 1.3], 
	[30, "gem_red", 1.45], 
	[80, "gem_emperium", 1.6], 
]


const GEM_BOUNCE_TIER: = 2



const GEM_DING_DB: = -13.0
const GEM_DING_GAP: = 0.075
const GEM_DING_NOTES: = [0, 2, 4, 7, 9, 12]
const GEM_DING_RESET: = 0.6




const PICKUP_CAP: = {"xp": 200, "loot": 80, "potion": 12}
const PICKUP_MERGE_EVERY: = 0.5
const PICKUP_MERGE_CELL: = 2.5





const CHEST_DIAMOND: = "chest_diamond"
const CHEST_SPRITES: = ["chest_small", "chest", "chest_gold", "chest_golden_poring", "chest_golden_poring"]
const CHEST_COLORS: = [Color(0.85, 0.6, 0.4), Color(1.0, 0.82, 0.45), Color(1.0, 0.78, 0.2), Color(1.0, 0.8, 0.2), Color(1.0, 0.85, 0.15)]


const SMALL_CHEST_CHANCE: = 0.0015
const SMALL_CHEST_ZENY: = 25



const ENDLESS_FEROZ_EVERY: = [12.0, 18.0]
const ENDLESS_FEROZ_MAX: = 6
const FEROCIOUS: = {"from": 60.0, "every": [45.0, 60.0], "every_hard": [30.0, 40.0], "max": 2, "max_hard": 3, 
	"hp": 4.0, "dmg": 1.4, "speed": 1.15, "xp": 5, "chest": 0.12, "card": 0.00475, "zeny": 3.0, 
	"scale": 1.3, "knock": 0.5}







const SPECIAL_SPEED_MAX: = 6.5
const SPECIAL_KINDS: = {
	"feroz": {"label": "%s Feroz", "w": 3.0, "hp": 4.0, "dmg": 1.4, "speed": 1.15, "scale": 1.3, 
		"tint": Color(1.0, 0.6, 0.55), "glow": Color(1.0, 0.2, 0.12, 0.6), "text": Color(1.0, 0.4, 0.35)}, 
	"veloz": {"label": "%s Veloz", "w": 2.0, "hp": 1.6, "dmg": 0.7, "speed": 1.8, "scale": 1.1, 
		"tint": Color(0.6, 0.92, 1.0), "glow": Color(0.3, 0.85, 1.0, 0.55), "text": Color(0.45, 0.9, 1.0)}, 
	"maldito": {"label": "%s Maldito", "w": 2.0, "hp": 2.5, "dmg": 1.1, "speed": 1.1, "scale": 1.2, "hex": true, 
		"tint": Color(0.75, 0.55, 1.0), "glow": Color(0.6, 0.2, 0.9, 0.6), "text": Color(0.8, 0.55, 1.0)}, 
	"gigante": {"label": "%s Gigante", "w": 1.0, "hp": 9.0, "dmg": 1.8, "speed": 0.75, "scale": 1.9, "no_knock": true, 
		"tint": Color(1.0, 0.85, 0.5), "glow": Color(1.0, 0.75, 0.2, 0.55), "text": Color(1.0, 0.82, 0.35)}, 


	"corrupto": {"label": "%s Corrupto", "w": 0.0, "hp": 7.0, "dmg": 1.6, "speed": 1.1, "scale": 1.6, "no_knock": true, 
		"tint": Color(0.78, 0.42, 0.45), "glow": Color(0.55, 0.0, 0.05, 0.75), "text": Color(1.0, 0.28, 0.25)}, 

	"guardia": {"label": "%s Guardián", "w": 0.0, "hp": 6.0, "dmg": 1.5, "speed": 1.0, "scale": 2.0, "no_knock": true, 
		"tint": Color(1.0, 0.88, 0.45), "glow": Color(1.0, 0.8, 0.15, 0.7), "text": Color(1.0, 0.86, 0.3)}, 
}







const KARMA_MAX: = 100
const KARMA_CHEST: = 20
const KARMA_ALTAR: = 15


const KARMA_DEMON_FROM: = 120.0
const KARMA_DEMON_EVERY: = [110.0, 160.0]
const KARMA_DEMONS: = ["baphomet_jr", "dark_priest", "marionette", "whisper"]



const CORRUPT_CHEST_HP: = 0.25






const HEL_MARK_DMG: = 1.08
const HEL_MARK_FOE_DMG: = 1.06
const FEATHER_HP: = 1.06
const FEATHER_REGEN: = 0.002
const FEATHER_FOE_HP: = 1.06
const CORRUPT_CHEST_ROLLS: = 4
const CORRUPT_CHEST_BONUS: = 2
const CORRUPT_COLOR: = Color(0.85, 0.12, 0.18)
const PURE_COLOR: = Color(1.0, 0.93, 0.62)


const KARMA_ALTAR_FROM: = 90.0
const KARMA_ALTAR_EVERY: = [150.0, 210.0]
const KARMA_CALM: = 4.0


const KARMA_LOOK_FROM: = 25
const KARMA_RICH: = 50
const KARMA_ELITE_MULT: = 1.5
const KARMA_BOX_MULT: = 1.5





const KARMA_ROUTES: = {
	"light": {"mvp": "reginleif", "name": "Ruta de Valhalla", "portal": "Portal: Valhalla", "color": Color(1.0, 0.92, 0.6), 
		"unique": "aegis_reginleif", "boon": "valhalla", 
		"foe_hp": 1.35, "foe_dmg": 1.1, "foe_speed": 1.0, "foe_steady": true, 
		"foes": "Bendición de Asgard: los enemigos tienen +35% de vida y +10% de daño, y no retroceden"}, 
	"dark": {"mvp": "randgris_fallen", "name": "Ruta de Niflheim", "portal": "Portal: Niflheim", "color": Color(0.85, 0.12, 0.2), 
		"unique": "corrupt_spear", "boon": "hel_pact", 
		"foe_hp": 1.15, "foe_dmg": 1.35, "foe_speed": 1.15, "foe_burst": 0.06, 
		"foes": "Corrupción de Hel: los enemigos tienen +15% de vida, +35% de daño y +15% de velocidad, y estallan al morir (6% de tu vida)"}, 
}
const KARMA_BURST_RADIUS: = 2.0
const KARMA_BURST_DELAY: = 0.6




const VALHALLA_REVIVES: = 1




const VALHALLA_REGEN: = 0.02
const VALHALLA_XP: = 0.15
const VALHALLA_HP: = 0.2
const VALHALLA_DMG: = 0.2
const HEL_PACT_DMG: = 0.5
const HEL_PACT_TAKEN: = 0.2
const HEL_PACT_KILL_HEAL: = 0.02



const HEXES: = {
	"hex_slow": {"name": "Lentitud", "duration": 4.0, "mods": {"move": -0.4}}, 
	"hex_weak": {"name": "Debilidad", "duration": 5.0, "mods": {"dmg": -0.3}}, 
	"hex_dull": {"name": "Torpeza", "duration": 5.0, "mods": {"haste": -0.35, "aspd": -0.3}}, 

	"oath_silence": {"name": "Lex Divina", "duration": 2.0, "mods": {}, "oath": true, 
		"desc": "Silenciado: no lanzas habilidades y sus recargas esperan. Tu ataque básico sigue."}, 
	"oath_curse": {"name": "Maldición", "duration": 15.0, "mods": {}, "oath": true, 
		"desc": "Tu vida máxima baja con cada golpe. Se va tras 15 s sin recibir golpes o al vencer a un jefe."}, 
}














const ANTONIO: = {"from": 60.0, "check": 40.0, "chance": 0.3, "tank": 6.0, "min_hp": 300.0, "rolls": 1, 
	"color": Color(0.95, 0.3, 0.3)}
const RUNNER: = {"mob": "gold_poring", "from": 70.0, "check": 30.0, "chance": 0.06, "scale": 2.1, "life": 40.0, "tank": 13.0, 
	"min_hp": 400.0, "drop_share": 0.06, "zeny": 90, "catch_zeny": 2000, "catch_coins": 14, "box": 0.18, "speed": 0.78, "color": Color(1.0, 0.82, 0.25)}





const GOLD_PORING_ORES: = 3
const GOLD_PORING_CRUMB: = 0.05
const GOLD_PORING_COIN: = 0.05
const DROP_SOUNDS: = ["drop_blue", "drop_green", "drop_blue", "drop_purple"]
const DROP_SOUND_LEGENDARY: = "drop_yellow"



















const MORROC_LEVELS: = 5












const MORROC_FINALE: = {"mob": "morroc_kid", "adult": "morroc_adult", "at": 2400.0, "warn_at": [300.0, 60.0], 
	"teasers": ["Algo se agita bajo Midgard: el final de Infinito llegará en 5 minutos", 
		"Una risa infantil resuena a lo lejos: el final llega en 1 minuto"], 




	"retry": 3.0, "force_after": 20.0, "omen": 24.0, "radius": 27.0, "min_radius": 15.0, "search": 20.0, "impact": 4.0, "impact_pct": 0.3, 
	"tank": 160.0, "min_hp": 40000.0, "ymir_at": 45.0, "phases": [1.0, 0.7, 0.4], "enrage": 1.35, "grow_time": 2.4, 
	"color": Color(0.62, 0.3, 1.0), "zeny": 8000, "coins": 30, "chest": 8, "poring_coins": 5, 
	"cosmetic": "morroc_minions", "title": "rebirth_bane", "title_hell": 10, 
	"incarnations": {"hp": 0.04, "time": 18.0, "heal": 0.06, "crash_pct": 0.22, "crash_extra": 0.08, 
		"crash_size": 4.5, "stagger": 6.5, "vuln": 0.5, "rain_every": 2.4, "rain_size": 2.6, "rain_dmg": 0.8}, 
	"abilities": [
		{"id": "skulls", "name": "Lluvia de Calaveras", "mech": "volley", "phases": [0, 1, 2], "first": 3.0, "every": 9.0, 
			"cast": 0.9, "count": 7, "size": 2.4, "dmg": 1.0, "fall": 1.4, "gap": 0.14, "spread": 5.0}, 
		{"id": "orbit", "name": "Danza de Calaveras", "mech": "orbit", "phases": [0, 2], "first": 7.0, "every": 19.0, 
			"time": 8.0, "count": 4, "near": 2.2, "far": 7.0, "breath": 4.0, "spin": 1.5, "hit": 1.1, "dmg": 1.0, "warm": 1.0, 
			"alert": "Danza de Calaveras: giran a su alrededor, ¡que no te toquen!"}, 
		{"id": "rifts", "name": "Grietas del Abismo", "mech": "spokes", "phases": [0, 1, 2], "first": 12.0, "every": 15.0, 
			"cast": 1.5, "count": 5, "width": 2.2, "wave": 0.9, "dmg": 1.3, 
			"alert": "Grietas del Abismo: ponte entre las grietas, dos oleadas"}, 
		{"id": "judgement", "name": "Juicio Infernal", "alt": "Abrazo del Abismo", "mech": "judgement", 
			"phases": [0, 1, 2], "first": 17.0, "every": 18.0, "cast": 2.6, "out": 8.0, "safe": 3.2, "pct": 0.3, "lethal": true, 
			"pull": 0.45, "alert": "Juicio Infernal: ¡te arrastra! Corre lejos de Morroc", 
			"alt_alert": "Abrazo del Abismo: ¡pégate a Morroc!"}, 
		{"id": "claws", "name": "Garras del Renacido", "mech": "cone", "phases": [2], "first": 3.5, "every": 6.5, 
			"cast": 0.9, "radius": 8.5, "angle": 2.0, "dmg": 1.3, "fx": "hell_in"}, 
		{"id": "seal", "name": "Sello de la Desesperación", "mech": "seal", "phases": [2], "first": 8.0, "every": 15.0, 
			"time": 5.0, "size": 3.2, "dmg": 1.4, "pool": 16.0, "pool_pct": 0.045, "pools": 3, 
			"alert": "Sello de la Desesperación: llévalo al borde, deja ahí su sangre"}, 
		{"id": "dive", "name": "Embestida del Renacido", "mech": "dive", "phases": [2], "first": 11.0, "every": 16.0, 
			"cast": 0.9, "count": 3, "width": 2.8, "dmg": 1.3, 
			"alert": "Embestida del Renacido: tres embestidas, ¡esquiva hacia un lado!"}, 
	], 
	"warn": "Una risa infantil resuena en Midgard...: el final de Infinito ha llegado", 
	"warn2": "El cielo se tiñe de violeta: Morroc caerá en el círculo", 
	"caption": "Morroc caerá aquí", 
	"count_text": "Morroc desciende en  %d", 
	"talk_name": "Morroc", 
	"talk": ["¿Todavía sigues en pie? Llevas tanto tiempo aquí que ya me aburrí de mirarte.", 
		"Mis calaveras cuentan a los que has derribado... demasiados.", 
		"¿Creías que esto no tenía final? Yo soy el final.", 
		"Ven, juguemos un rato... antes de que despierte del todo."], 
	"intro": "¡Juguemos! Tus últimos minutos serán los más divertidos.", 
	"sub": "El final de Infinito: ¡vence y la partida termina en victoria!", 
	"phase_shouts": ["", "¡Mis sombras! ¡Venid a mí!", "¡Basta de juegos! ¡Contemplad mi verdadera forma!"], 
	"grow": "Morroc despierta: ¡su verdadera forma!", 
	"reborn": "Por fin... ¡este cuerpo vuelve a ser mío!", 
	"death": "Este cuerpo... aún no estaba listo... Nos volveremos a ver...", 
	"win": "Morroc ha caído: has llegado al final de Infinito", 









	"again": {"hp": 1.5, "dmg": 1.2, "omen": 8.0, "ores": 5, "coin": 0.05, 
		"warn": "Morroc %s se levanta de nuevo: ¡más fuerte que antes!", 
		"intro": "¿Otra vez tú? Esta vez no voy a jugar.", 
		"sub": "Vence y elige si sigues: cada Morroc vencido cuenta en los récords", 
		"win": "%s ha caído"}, 
}


const SPLASH_FX_GAP: = 0.18

const HEAL_NUMBER_GAP: = 0.6


const HURT_NUMBER_GAP: = 0.4
const BARRIER_NUMBER_GAP: = 1.0

const SHARP_LENGTH_MAX: = 30.0


const SHARP_TRAP_MULT: = 2.0

const FALCON_ASSAULT_BOSS: = 1.5
const PROC_GAP_MS: = 100





const PROC_HELD_POW: = 0.75




const PROC_GROUND_GAP_MS: = 600
const NUMBER_HERO_GAP: = 3.6


const NUMBER_HERO_SIDE: = 3.0
const NUMBER_HERO_ABOVE: = 3.5

const NUMBER_HERO_LIFT: = 1.2



const HEAL_HP_PCT: = 0.001
const HEAL_ZONE_PCT: = 0.0012


const DEATH_CAUSES: = ["Golpe cuerpo a cuerpo", "Disparo", "Fire Bolt", "Tormenta", "Lluvia infernal", "Venganza de los caídos", 
	"Heraldos de Surtr", "Meteoros errantes", "Estallido corrupto", "Golpe aplastante", "Embestida", "Maldición", "Explosión"]

const DOOM_CAUSE: = "Sentencia de muerte"


const MORROC_HP_EASE: = 0.2

const MELEE_BOSS_REACH: = 0.6
const MORROC: = {"mob": "satan_morroc", "min_danger": 5, "from": 300.0, "window": 60.0, "chance": 0.35, "mvp_gap": 100.0, "retry": 5.0, 
	"endless_every": 150.0, "endless_chance": 0.3, "endless_gap": 300.0, 
	"omen": 20.0, "radius": 15.0, "min_radius": 10.0, "search": 8.0, "impact": 4.0, "impact_pct": 0.3, 
	"tank": 65.0, "min_hp": 12000.0, "ymir_at": 20.0, "phases": [1.0, 0.65, 0.3], "enrage": 1.25, 
	"color": Color(0.9, 0.18, 0.15), "zeny": 2600, "coins": 16, "chest": 5, "gems": 14, 
	"incarnations": {"hp": 0.045, "time": 18.0, "heal": 0.06, "crash_pct": 0.22, "crash_extra": 0.08, 
		"crash_size": 4.5, "stagger": 6.5, "vuln": 0.5, "rain_every": 2.6, "rain_size": 2.6, "rain_dmg": 0.8}, 
	"abilities": [
		{"id": "scythe", "name": "Guadaña Infernal", "mech": "cone", "phases": [0, 1, 2], "first": 4.0, "every": 7.0, 
			"cast": 1.1, "radius": 7.5, "angle": 2.4, "dmg": 1.2, "fx": "hell_in"}, 
		{"id": "rifts", "name": "Grietas del Abismo", "mech": "spokes", "phases": [0, 1, 2], "first": 9.0, "every": 14.0, 
			"cast": 1.5, "count": 6, "width": 2.2, "wave": 0.9, "dmg": 1.3, 
			"alert": "Grietas del Abismo: ponte entre las grietas, dos oleadas"}, 
		{"id": "judgement", "name": "Juicio Infernal", "alt": "Abrazo del Abismo", "mech": "judgement", 
			"phases": [0, 1, 2], "first": 15.0, "every": 17.0, "cast": 2.6, "out": 8.0, "safe": 3.2, "pct": 0.3, "lethal": true, 
			"pull": 0.45, "alert": "Juicio Infernal: ¡te arrastra! Corre lejos de Satan Morroc", 
			"alt_alert": "Abrazo del Abismo: ¡pégate a Satan Morroc!"}, 
		{"id": "seal", "name": "Sello de la Desesperación", "mech": "seal", "phases": [1, 2], "first": 6.0, "every": 15.0, 
			"time": 5.0, "size": 3.2, "dmg": 1.4, "pool": 16.0, "pool_pct": 0.045, "pools": 3, 
			"alert": "Sello de la Desesperación: llévalo al borde, deja ahí su sangre"}, 
		{"id": "dive", "name": "Alas del Apocalipsis", "mech": "dive", "phases": [2], "first": 4.0, "every": 16.0, 
			"cast": 1.0, "count": 3, "width": 2.8, "dmg": 1.3, 
			"alert": "Alas del Apocalipsis: tres embestidas, ¡esquiva hacia un lado!"}, 
	], 
	"intro": "Mortales... Midgard arderá en el Ragnarok.", 
	"phase_shouts": ["", "¡Encarnaciones, venid a mí!", "¡Contemplad el fin de Midgard!"], 
	"death": "Esto... no ha terminado... volveré...", 
}


const CHEST_ROLLS: = {"elite": 1, "boss": 3, "golden_poring": 5}

const CHEST_MIN_SLOTS: = 3


const BASE_CARD_SLOTS: = 1



const CARD_DROP_CHANCE: = 0.00038
const BOSS_CARD_CHANCE: = 0.1425



const BOSS_CARD_PITY: = 5




const MVP_SUMMON_CARD_PITY: = 25



const MVP_FIGHT_CARD_CHANCE: = 0.3
const MVP_CARD_CHANCE: = 0.285

# [MOD] MOD_MVP_CARD_MULT: multiplier on the drop chance of MVP cards ONLY. The gate at every roll site
# is GameData.is_mvp_card(card) - the card id, not the monster kind - so mob/elite/boss/raid-fight cards
# keep their shipped odds (CARD_DROP_CHANCE, ELITE_CARD_CHANCE, BOSS_CARD_CHANCE, MVP_FIGHT_CARD_CHANCE
# are untouched). Sites: World._kill (boss MVP, plus every MVP card that survives the hell pool swap)
# and world.hell_late.shadow_down (hell shadow MVPs). 2.4 => 0.285 * 2.4 = 0.684 per MVP kill.
const MOD_MVP_CARD_MULT: = 2.4

# [MOD] MOD_MORROC_SPAWN: multiplier on the two Satan Morroc spawn rolls only. MorrocEvent.plan()
# (one roll per normal run, MORROC.chance 0.35 -> 0.70) and MorrocEvent._schedule() (the endless
# re-roll every MORROC.endless_every, 0.3 -> 0.6, still spaced by endless_gap 300s). Nothing else
# on the path is touched: the danger >= MORROC.min_danger gate, the 300-360s window, the hard
# deadline at stage-MVP minus (mvp_gap + omen), the 5s retry, the open-arena search and the
# one-per-normal-run limit all stay as shipped, so 2.0 raises the per-run rate to ~70% x P(arena).
# Values >= 2.86 make the roll itself always pass; only then does the arena search / deadline
# become the whole remaining risk on tight dungeon maps.
const MOD_MORROC_SPAWN: = 2.0

const CARD_LUK_BONUS: = 0.02

const ELITE_CARD_CHANCE: = 0.076
const POTION_DROP_CHANCE: = 0.006



const POTION_HEAL: = 0.25
const POTION_SPRITES: = ["item_potion", "item_potion_orange", "item_potion_yellow", "item_potion_white"]
const POTION_HOME_AT: = 6








const POWER_DROPS: = {
	"bubble_gum": {"name": "Bubble Gum", "effect": "magnet", "duration": 30.0, "chance": 0.0006, "color": Color(1.0, 0.55, 0.8), 
		"mods": {"loot": 1.0, "card": 1.0}, 
		"desc": "30 s de doble zeny y doble probabilidad de cartas; todo lo que hay en el suelo viene hacia ti, también cartas, objetos y cofres, y mientras dura los atraes desde mucho más lejos."}, 
	"siegfried_token": {"name": "Token of Siegfried", "effect": "immortal", "duration": 2.5, "chance": 0.00035, 
		"color": Color(1.0, 0.85, 0.35), "desc": "Inmortal durante 2,5 segundos."}, 
	"berserk_potion": {"name": "Berserk Potion", "effect": "berserk", "duration": 12.0, "chance": 0.00035, 
		"mods": {"dmg": 1.0, "aspd": 0.5, "haste": 0.6, "move": 0.45}, "color": Color(1.0, 0.3, 0.25), 
		"desc": "Máquina de matar 12 s: +100% de daño, más velocidad de ataque, de recarga y de movimiento."}, 
	"frozen_rose": {"name": "Frozen Rose", "effect": "freeze", "duration": 6.0, "radius": 22.0, "chance": 0.00035, 
		"color": Color(0.55, 0.85, 1.0), "desc": "Congela a todos los monstruos cercanos durante 6 segundos."}, 
}

const SKILL_POWERS: = {

	"tower_wind": {"name": "Viento de la torre", "mods": {"move": 0.6}, "color": Color(0.85, 0.7, 1.0), 
		"desc": "Corres mucho más rápido hasta el portal al piso siguiente."}, 

	"mild_wind": {"name": "Mild Wind", "color": Color(0.7, 1.0, 0.85), "desc": "Patadas del elemento elegido."}, 
	"union": {"name": "Union of the Sun, Moon and Stars", "mods": {"aspd": 0.35, "dmg": 0.3, "crit": 0.15, "move": 0.15}, 
		"color": Color(1.0, 0.85, 0.4), "desc": "Fundido con el sol, la luna y las estrellas."}, 
	"warmth": {"name": "Warmth", "color": Color(1.0, 0.6, 0.3), "desc": "Aura de calor."}, 
	"warmth_sun": {"name": "Warmth of the Sun", "color": Color(1.0, 0.55, 0.25), "desc": "Aura de calor."}, 
	"warmth_stars": {"name": "Warmth of the Stars", "color": Color(1.0, 0.95, 0.6), "desc": "Las estrellas caen sobre los monstruos que te rodean."}, 
	"spirit_knight": {"name": "Espíritu del Caballero", "mods": {"dmg": 0.2, "max_hp_pct": 0.1}, "color": Color(0.85, 0.75, 1.0)}, 
	"spirit_wizard": {"name": "Espíritu del Mago", "mods": {"skill_dmg": 0.3}, "color": Color(0.85, 0.75, 1.0)}, 
	"spirit_priest": {"name": "Espíritu del Sacerdote", "mods": {"regen": 4.0, "armor": 2.0}, "color": Color(0.85, 0.75, 1.0)}, 
	"spirit_hunter": {"name": "Espíritu del Cazador", "mods": {"aspd": 0.25, "proj_speed": 0.3}, "color": Color(0.85, 0.75, 1.0)}, 
	"spirit_assassin": {"name": "Espíritu del Asesino", "mods": {"crit": 0.2, "dodge": 0.08}, "color": Color(0.85, 0.75, 1.0)}, 
	"spirit_monk": {"name": "Espíritu del Monje", "mods": {"aspd": 0.2, "dmg": 0.12}, "color": Color(0.85, 0.75, 1.0)}, 
	"spirit_crusader": {"name": "Espíritu del Cruzado", "mods": {"armor": 4.0, "max_hp_pct": 0.15}, "color": Color(0.85, 0.75, 1.0)}, 
	"spirit_sage": {"name": "Espíritu del Sabio", "mods": {"haste": 0.25, "area": 0.15}, "color": Color(0.85, 0.75, 1.0)}, 
	"spirit_rogue": {"name": "Espíritu del Pícaro", "mods": {"loot": 0.3, "move": 0.12}, "color": Color(0.85, 0.75, 1.0)}, 
	"spirit_blacksmith": {"name": "Espíritu del Herrero", "mods": {"aspd": 0.2, "crit_dmg": 0.3}, "color": Color(0.85, 0.75, 1.0)}, 
	"spirit_alchemist": {"name": "Espíritu del Alquimista", "mods": {"regen": 3.0, "skill_dmg": 0.15}, "color": Color(0.85, 0.75, 1.0)}, 
	"spirit_bard": {"name": "Espíritu del Artista", "mods": {"move": 0.2, "haste": 0.15}, "color": Color(0.85, 0.75, 1.0)}, 
	"spirit_star": {"name": "Espíritu del Star Gladiator", "mods": {"dmg": 0.15, "crit": 0.12, "aspd": 0.1}, "color": Color(0.85, 0.75, 1.0)}, 
	"heat_barrel": {"name": "Heat Barrel", "color": Color(1.0, 0.45, 0.2), "desc": "Cañón al rojo vivo."}, 


	"over_thrust_x": {"name": "Maximum Power-Thrust", "color": Color(1.0, 0.45, 0.2), 
		"desc": "La forja vaciada de golpe: multiplica todo tu daño y el arma se rompe la mitad."}, 
	"temper_fire": {"name": "Arma templada: Fuego", "color": Color(1.0, 0.5, 0.25), 
		"desc": "Tus golpes neutrales (ataque básico y habilidades) son de Fuego."}, 
	"temper_water": {"name": "Arma templada: Agua", "color": Color(0.5, 0.75, 1.0), 
		"desc": "Tus golpes neutrales (ataque básico y habilidades) son de Agua."}, 
	"temper_wind": {"name": "Arma templada: Viento", "color": Color(0.7, 0.95, 0.45), 
		"desc": "Tus golpes neutrales (ataque básico y habilidades) son de Viento."}, 
	"temper_earth": {"name": "Arma templada: Tierra", "color": Color(0.85, 0.65, 0.4), 
		"desc": "Tus golpes neutrales (ataque básico y habilidades) son de Tierra."}, 
}

const LEGEND_POWERS: = {
	"steel_body": {"name": "Steel Body", "mods": {"move": -0.25}, "color": Color(0.7, 0.78, 0.9)}, 
	"critical_explosion": {"name": "Critical Explosion", "mods": {}, "color": Color(1.0, 0.85, 0.35)}, 
	"martyr": {"name": "Martyr's Reckoning", "mods": {}, "color": Color(1.0, 0.7, 0.5)}, 
	"gospel": {"name": "Gospel", "mods": {}, "color": Color(1.0, 0.92, 0.6)}, 
	"provoke": {"name": "Provoke", "mods": {"armor": 4.0}, "color": Color(1.0, 0.45, 0.3)}, 
	"provoke_x": {"name": "Provoke EX", "mods": {"armor": 10.0}, "color": Color(1.0, 0.45, 0.3)}, 
	"gospel_might": {"name": "Gospel: fuerza", "mods": {"dmg": 0.25}, "color": Color(1.0, 0.6, 0.4)}, 
	"gospel_guard": {"name": "Gospel: defensa", "mods": {"armor": 6.0}, "color": Color(0.7, 0.85, 1.0)}, 
	"gospel_haste": {"name": "Gospel: prisa", "mods": {"aspd": 0.25, "move": 0.1}, "color": Color(0.7, 1.0, 0.7)}, 
	"tiger_rush": {"name": "Furia del tigre", "mods": {"move": 0.35, "aspd": 0.35}, "color": Color(1.0, 0.7, 0.25)}, 
	"wind_step": {"name": "Paso del viento", "mods": {"move": 0.35}, "color": Color(0.6, 0.95, 0.8)}, 

	"sleipnir_gallop": {"name": "Galope de Sleipnir", "mods": {"move": 0.8, "magnet": 1.5}, "color": Color(0.75, 0.9, 1.0)}, 


	"kafra_emperium": {"name": "Bendición del Emperium", "mods": {}, "color": Color(1.0, 0.82, 0.35), 
		"desc": "Regalo de la Kafra ambulante: todo tu daño se multiplica mientras dura."}, 
	"kafra_star": {"name": "Poder del Nivel 99", "mods": {"move": 0.6}, "color": Color(1.0, 0.9, 0.5), 
		"desc": "¡Derrota a tus enemigos con solo tocarlos con el poder del nivel 99! Además, ¡eres intocable y más rápido!"}, 

	"valhalla_rage": {"name": "Ira de Valhalla", "mods": {"dmg": 0.5, "crit_dmg": 0.5}, "color": Color(1.0, 0.35, 0.3)}, 
}


const VALHALLA_TIME: = 5.0
const VALHALLA_POTION_TIME: = 20.0


const COOP_REVIVE_RANGE: = 1.6
const COOP_REVIVE_TIME: = 3.0
const COOP_REVIVE_HP: = 0.3
const COOP_REVIVE_INVULN: = 2.0




const COOP_HP: = {"crowd": 0.3, "tough": 0.6, "mvp": 1.1}
const COOP_SPAWN: = 0.6








const MAX_ENEMIES_COOP: = 150


static func coop_hp(n: int, kind: String) -> float:
	return 1.0 + float(COOP_HP[kind]) * maxi(0, n - 1)


static func coop_spawn(n: int) -> float:
	return 1.0 + COOP_SPAWN * maxi(0, n - 1)









const COOP_XP_CUT: = 0.0
const COOP_XP_MULT: = 1.0
static func coop_xp(n: int) -> float:
	return (1.0 - COOP_XP_CUT * maxi(0, n - 1)) / coop_spawn(n) * (COOP_XP_MULT if n > 1 else 1.0)



const HEAT_DELAY: = 0.35
const HEAT_RAMP: = 2.5
const HEAT_COOL: = 0.8
const HEAT_STILL_MAX: = 2.0






const GUN_MARK_SKILLS: = ["tracking", "desperado", "spread_attack", "fire_rain", "banishing_buster", "hammer_of_god"]
const CRIMSON_TIME: = 6.0
const CRIMSON_MAX: = 30

const CRIMSON_ALPHA: = 0.6
const CRIMSON_SIZE: = 0.75
const CRIMSON_SIZE_BOSS: = 1.1



const CRIMSON_BOSS_STACKS: = 5
const DRAGON_TAIL_BOSS_MULT: = 2.0
const DRAGON_TAIL_MULT: = 0.4
const DRAGON_TAIL_RADIUS: = 2.2
const DRAGON_TAIL_GAP: = 0.6
const DRAGON_TAIL_FX: = 8
const DRAGON_TAIL_COLOR: = Color(1.0, 0.4, 0.25)







const CRIT_PHYS_COLOR: = Color(0.95, 0.35, 0.28)
const CRIT_MAGIC_COLOR: = Color(0.42, 0.68, 1.0)


const METEOR_WINDUP: = 0.18
const U_SB_CUTS: = 8
const U_SB_PER_CAST: = 2
const U_SB_MARK_TIME: = 6.0
const U_SB_BURST: = 2.0
const U_SB_TICKS_MAX: = 60.0
const U_SB_SPREAD: = 0.4
const U_SB_RADIUS: = 3.5
const U_SB_DMG: = 15.0
const U_SB_HITSTOP: = 0.06
const U_SB_LIT: = Color(0.55, 1.0, 0.4)
const U_SB_DARK: = Color(0.32, 0.18, 0.45)


const U_OV_HITSTOP: = 0.05

const U_OV_NUMBERS: = 2
const U_OV_HITSTOP_STAGE: = 0.012
const LAST_STAND_HP: = 0.3
const LAST_STAND_TIME: = 3.0
const AEGIS_DMG: = 3.0
const AEGIS_RADIUS: = 3.5
const THOR_STACK: = 0.01
const THOR_MAX: = 40







const GALLOP_DMG: = 0.1
const GALLOP_MAX: = 0.4
const GALLOP_GRACE: = 1.0




const MAGNET_AREA: = 0.1





















const KAFRA_WALK: = {"every": 240.0, "every_lv3": 180.0, "every_lv5": 150.0, "life": 40.0, "dist": [18.0, 26.0], "reach": 2.4, 
	"options": 3, "pool": ["mvp_half", "valk_half", "ymir", "sweep", "golden", "star"], 
	"emp_mult": 1.5, "emp_time": 60.0, "mvp_hp": 0.5, "ymir": 20.0, "star_time": 30.0, "star_hit": 8.0, "star_gap": 0.3, 
	"star_over": 0.3, "star_bgm": "prt_are01", 
	"strong": {"emp_time": 90.0, "mvp_hp": 0.4, "ymir": 30.0, "star_time": 40.0}, 
	"color": Color(0.55, 0.75, 1.0)}


const KAFRA_WALK_OPTS: = {
	"emperium": {"name": "Bendición del Emperium", "icon": "gem_emperium", "color": Color(0.95, 0.68, 0.15), "desc": "x%s de daño durante %d s."}, 
	"mvp_half": {"name": "Golpe al MVP", "icon": "skill:lex_aeterna", "color": Color(0.85, 0.25, 0.25), "desc": "El próximo MVP aparece con el %d%% de su vida."}, 
	"valk_half": {"name": "Golpe a la Valkyria", "icon": "valkyrie_helm", "color": Color(0.9, 0.45, 0.65), "desc": "La próxima Valkyria aparece con el %d%% de su vida."}, 
	"ymir": {"name": "Corazón de Ymir", "icon": "ymir_fragment", "color": Color(0.6, 0.3, 0.95), "desc": "En la próxima pelea de MVP empiezas con el Corazón de Ymir en x%d, solo para ti."}, 
	"sweep": {"name": "Limpieza Kafra", "icon": "skill:magnus_exorcismus", "color": Color(0.3, 0.6, 0.95), "desc": "Una onda de luz derrota a todos los monstruos comunes del mapa (con su EXP)."}, 
	"golden": {"name": "Poring Dorado", "icon": "gold_coin", "color": Color(0.85, 0.6, 0.1), "desc": "Aparece un Poring Dorado con tesoro: ¡atrápalo antes de que escape!"}, 
	"star": {"name": "Poder del Nivel 99", "icon": "skill:assumptio", "color": Color(0.2, 0.55, 0.95), "desc": "¡Derrota a tus enemigos con solo tocarlos con el poder del nivel 99! Además, ¡eres intocable! (%d s)"}, 
}
const THOR_TIME: = 6.0
const WIND_STEP_CD: = 0.4
const FREYA_EVERY: = 0.25





func card_tier(card: String) -> String:
	for m in MONSTERS:
		var d: Dictionary = MONSTERS[m]
		if str(d.get("card", "")) == card:
			if d.get("mvp", false):
				return "mvp"
			return "boss" if d.has("boss") or d.get("elite", false) else "normal"
	return "mvp"


func fuse_cost(card: String) -> int:
	return int(FUSE_COST[card_tier(card)])


func power_def(id: String) -> Dictionary:
	if HEXES.has(id):
		return HEXES[id]
	if PET_POWERS.has(id):
		return PET_POWERS[id]
	if SKILL_POWERS.has(id):
		return SKILL_POWERS[id]
	return POWER_DROPS[id] if POWER_DROPS.has(id) else LEGEND_POWERS[id]



const POWER_ELITE_CHANCE: = 0.15



const PROP_COUNT: = 8
const PROP_MIN_DIST: = 12.0
const PROP_MAX_DIST: = 30.0
const PROP_DESPAWN_DIST: = 60.0
const PROP_RESPAWN: = 5.0
const PROP_STEEL_CHANCE: = 0.2
const PROPS: = {
	"woodbox": {"zeny": [8, 25], "potion": 0.3, "power": 0.05, "branch": 0.03}, 
	"steelbox": {"zeny": [40, 90], "potion": 0.5, "power": 0.18, "branch": 0.06}, 
}


const MAX_GROUND_CHESTS: = 12



const CHEST_PULL: = 3.0




const PET_FETCH_DIST: = 20.0
const PET_FETCH_SPEED: = 40.0

const PET_FETCH_MAX: = 10.0






static func adaptive_gfx_default() -> bool:
	return OS.has_feature("web") and MouseWalk.touch()
const ITEM_PULL: = 3.0


const ITEM_PULL_SHARE: = 0.5
const CHEST_REACH: = 1.1

const INVENTORY_MAX: = 48

const TRAINING_BAG_SPARE: = 16
const MAX_CHEST_ROLLS: = 5



const SPAWNS: = [
	{"mob": "poring", "from": 0.0, "to": 9999.0, "every": 0.9, "batch": 1}, 
	{"mob": "lunatic", "from": 30.0, "to": 9999.0, "every": 2.0, "batch": 1}, 
	{"mob": "fabre", "from": 75.0, "to": 9999.0, "every": 2.4, "batch": 2}, 
	{"mob": "willow", "from": 150.0, "to": 9999.0, "every": 4.0, "batch": 1}, 
]

const EVENTS: = [
	{"at": 75.0, "type": "ring", "mob": "poring", "count": 24}, 
	{"at": 135.0, "type": "ring", "mob": "fabre", "count": 30}, 
	{"at": 100.0, "type": "elite", "mob": "mastering"}, 
	{"at": 190.0, "type": "elite", "mob": "eclipse"}, 
	{"at": 240.0, "type": "boss", "mob": "angeling"}, 
	{"at": 290.0, "type": "elite", "mob": "mastering"}, 
	{"at": 360.0, "type": "elite", "mob": "elder_willow"}, 
	{"at": 430.0, "type": "elite", "mob": "eclipse"}, 
	{"at": 240.0, "type": "ring", "mob": "poring", "count": 30}, 
	{"at": 330.0, "type": "ring", "mob": "willow", "count": 20}, 
	{"at": 400.0, "type": "ring", "mob": "lunatic", "count": 40}, 
	{"at": MVP_TIME, "type": "boss", "mob": "baphomet"}, 
]




const MAX_ENEMIES_DESKTOP: = 120





const CROWD_FUSE_AT: = 0.25








const CROWD_CAP_TOWER: = 120
const CROWD_CAP_TOWER_COOP: = 160
const CROWD_FUSE_MAX: = 30
const CROWD_FUSE: = 4
const CROWD_FUSE_STEP: = 3




const CROWD_FUSE_STEP_COOP: = 6
const CROWD_FUSE_DMG: = 0.3




const CROWD_FUSE_LOOT: = 0.05


const RECYCLE_DIST: = 34.0
const RECYCLE_AFTER: = 6.0

const MAX_ENEMIES_WEB: = 120
var MAX_ENEMIES: int = MAX_ENEMIES_WEB if OS.has_feature("web") else MAX_ENEMIES_DESKTOP


const PAYON_SPAWNS: = [
	{"mob": "spore", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "poporing", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "smokie", "from": 60.0, "to": 9999.0, "every": 2.8, "batch": 2}, 
	{"mob": "wolf", "from": 120.0, "to": 9999.0, "every": 3.8, "batch": 2}, 
	{"mob": "bigfoot", "from": 200.0, "to": 9999.0, "every": 4.5, "batch": 1}, 
]
const PAYON_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "spore", "count": 28}, 
	{"at": 110.0, "type": "elite", "mob": "elder_willow"}, 
	{"at": 170.0, "type": "ring", "mob": "smokie", "count": 30}, 
	{"at": 240.0, "type": "boss", "mob": "vagabond_wolf"}, 
	{"at": 300.0, "type": "elite", "mob": "eclipse"}, 
	{"at": 340.0, "type": "ring", "mob": "wolf", "count": 26}, 
	{"at": 400.0, "type": "elite", "mob": "elder_willow"}, 
	{"at": 450.0, "type": "ring", "mob": "bigfoot", "count": 16}, 
	{"at": 540.0, "type": "boss", "mob": "eddga"}, 
]

const ORC_SPAWNS: = [
	{"mob": "orc_baby", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "ork_warrior", "from": 45.0, "to": 9999.0, "every": 2.2, "batch": 1}, 
	{"mob": "orc_lady", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "orc_archer", "from": 140.0, "to": 9999.0, "every": 4.5, "batch": 1}, 
	{"mob": "orc_zombie", "from": 170.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
]
const ORC_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "orc_baby", "count": 28}, 
	{"at": 120.0, "type": "elite", "mob": "high_orc"}, 
	{"at": 180.0, "type": "ring", "mob": "ork_warrior", "count": 26}, 
	{"at": 250.0, "type": "elite", "mob": "high_orc"}, 
	{"at": 320.0, "type": "elite", "mob": "high_orc"}, 
	{"at": 370.0, "type": "ring", "mob": "orc_lady", "count": 24}, 
	{"at": 430.0, "type": "elite", "mob": "high_orc"}, 
	{"at": 480.0, "type": "ring", "mob": "orc_zombie", "count": 20}, 
	{"at": 570.0, "type": "boss", "mob": "ork_hero"}, 
]

const PAY_CAVE_SPAWNS: = [
	{"mob": "zombie", "from": 0.0, "to": 200.0, "every": 1.0, "batch": 1}, 
	{"mob": "skeleton", "from": 20.0, "to": 260.0, "every": 1.8, "batch": 1}, 
	{"mob": "skel_archer", "from": 60.0, "to": 9999.0, "every": 3.6, "batch": 1}, 
	{"mob": "skel_soldier", "from": 90.0, "to": 9999.0, "every": 2.6, "batch": 1}, 
	{"mob": "munak", "from": 150.0, "to": 9999.0, "every": 2.2, "batch": 2}, 
	{"mob": "bon_gun", "from": 200.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "horong", "from": 260.0, "to": 9999.0, "every": 3.0, "batch": 1}, 
	{"mob": "sohee", "from": 320.0, "to": 9999.0, "every": 3.2, "batch": 2}, 
]
const PAY_CAVE_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "zombie", "count": 28}, 
	{"at": 130.0, "type": "elite", "mob": "nine_tail"}, 
	{"at": 190.0, "type": "ring", "mob": "skel_soldier", "count": 22}, 
	{"at": 250.0, "type": "boss", "mob": "skeleton_general"}, 
	{"at": 320.0, "type": "elite", "mob": "nine_tail"}, 
	{"at": 380.0, "type": "ring", "mob": "munak", "count": 22}, 
	{"at": 440.0, "type": "elite", "mob": "nine_tail"}, 
	{"at": 490.0, "type": "ring", "mob": "sohee", "count": 18}, 
	{"at": 560.0, "type": "boss", "mob": "moonlight"}, 
]
const ORC_DUN_SPAWNS: = [
	{"mob": "drainliar", "from": 0.0, "to": 9999.0, "every": 1.4, "batch": 1}, 
	{"mob": "orc_zombie", "from": 0.0, "to": 9999.0, "every": 1.3, "batch": 1}, 
	{"mob": "zenorc", "from": 40.0, "to": 9999.0, "every": 2.4, "batch": 2}, 
	{"mob": "orc_skeleton", "from": 100.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "orc_archer", "from": 160.0, "to": 9999.0, "every": 3.8, "batch": 1}, 
]
const ORC_DUN_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "orc_zombie", "count": 28}, 
	{"at": 130.0, "type": "elite", "mob": "high_orc"}, 
	{"at": 190.0, "type": "ring", "mob": "zenorc", "count": 24}, 
	{"at": 260.0, "type": "elite", "mob": "high_orc"}, 
	{"at": 330.0, "type": "ring", "mob": "orc_skeleton", "count": 22}, 
	{"at": 400.0, "type": "elite", "mob": "high_orc"}, 
	{"at": 470.0, "type": "ring", "mob": "drainliar", "count": 26}, 
	{"at": 580.0, "type": "boss", "mob": "orc_lord"}, 
]

const GLAST_SPAWNS: = [
	{"mob": "zombie", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "whisper", "from": 30.0, "to": 9999.0, "every": 2.8, "batch": 1}, 
	{"mob": "skeleton", "from": 60.0, "to": 9999.0, "every": 2.4, "batch": 2}, 
	{"mob": "skel_archer", "from": 90.0, "to": 9999.0, "every": 3.4, "batch": 1}, 
	{"mob": "ghoul", "from": 110.0, "to": 9999.0, "every": 3.2, "batch": 2}, 
	{"mob": "wraith", "from": 180.0, "to": 9999.0, "every": 4.0, "batch": 1}, 
	{"mob": "evil_druid", "from": 260.0, "to": 9999.0, "every": 5.0, "batch": 1}, 
]
const GLAST_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "zombie", "count": 30}, 
	{"at": 120.0, "type": "elite", "mob": "raydric"}, 
	{"at": 180.0, "type": "ring", "mob": "whisper", "count": 18}, 
	{"at": 250.0, "type": "boss", "mob": "bloody_knight"}, 
	{"at": 320.0, "type": "elite", "mob": "khalitzburg"}, 
	{"at": 370.0, "type": "ring", "mob": "ghoul", "count": 26}, 
	{"at": 430.0, "type": "elite", "mob": "raydric"}, 
	{"at": 480.0, "type": "ring", "mob": "wraith", "count": 18}, 
	{"at": 540.0, "type": "elite", "mob": "khalitzburg"}, 
	{"at": 600.0, "type": "boss", "mob": "dark_lord"}, 
]

const NAMELESS_SPAWNS: = [
	{"mob": "ragged_zombie", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "hell_poodle", "from": 25.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "zombie_slaughter", "from": 60.0, "to": 9999.0, "every": 2.8, "batch": 1}, 
	{"mob": "flame_skull", "from": 100.0, "to": 9999.0, "every": 3.0, "batch": 2}, 
	{"mob": "banshee", "from": 150.0, "to": 9999.0, "every": 3.4, "batch": 1}, 
]
const NAMELESS_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "ragged_zombie", "count": 30}, 
	{"at": 125.0, "type": "elite", "mob": "necromancer"}, 
	{"at": 185.0, "type": "ring", "mob": "hell_poodle", "count": 24}, 
	{"at": 255.0, "type": "boss", "mob": "banshee_master"}, 
	{"at": 325.0, "type": "elite", "mob": "necromancer"}, 
	{"at": 375.0, "type": "ring", "mob": "flame_skull", "count": 26}, 
	{"at": 440.0, "type": "elite", "mob": "necromancer"}, 
	{"at": 490.0, "type": "ring", "mob": "zombie_slaughter", "count": 20}, 
	{"at": 555.0, "type": "elite", "mob": "necromancer"}, 
	{"at": 620.0, "type": "boss", "mob": "fallen_bishop"}, 
]

const ABBEY_SPAWNS: = [
	{"mob": "disguise", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "rideword", "from": 25.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "gibbet", "from": 60.0, "to": 9999.0, "every": 2.8, "batch": 1}, 
	{"mob": "dark_priest", "from": 110.0, "to": 9999.0, "every": 3.6, "batch": 1}, 
	{"mob": "hunter_fly", "from": 150.0, "to": 9999.0, "every": 2.4, "batch": 2}, 
]
const ABBEY_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "disguise", "count": 30}, 
	{"at": 125.0, "type": "elite", "mob": "bloody_murderer"}, 
	{"at": 185.0, "type": "ring", "mob": "rideword", "count": 26}, 
	{"at": 260.0, "type": "boss", "mob": "dullahan"}, 
	{"at": 325.0, "type": "elite", "mob": "bloody_murderer"}, 
	{"at": 380.0, "type": "ring", "mob": "hunter_fly", "count": 28}, 
	{"at": 445.0, "type": "elite", "mob": "bloody_murderer"}, 
	{"at": 500.0, "type": "ring", "mob": "gibbet", "count": 22}, 
	{"at": 570.0, "type": "elite", "mob": "bloody_murderer"}, 
	{"at": 640.0, "type": "boss", "mob": "beelzebub"}, 
]

const CULVERT_SPAWNS: = [
	{"mob": "thief_bug", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "tarou", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "plankton", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "cramp", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
	{"mob": "thara_frog", "from": 200.0, "to": 9999.0, "every": 4.5, "batch": 1}, 
]
const CULVERT_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "thief_bug", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "toad"}, 
	{"at": 175.0, "type": "ring", "mob": "tarou", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "thief_bug_male"}, 


	{"at": 275.0, "type": "boss", "mob": "thief_bug_egg"}, 
	{"at": 300.0, "type": "elite", "mob": "toad"}, 
	{"at": 345.0, "type": "ring", "mob": "plankton", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "toad"}, 
	{"at": 460.0, "type": "ring", "mob": "thara_frog", "count": 20}, 
	{"at": 520.0, "type": "boss", "mob": "golden_bug"}, 
]

const BYALAN_SPAWNS: = [
	{"mob": "kukre", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "vadon", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "marina", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "hydra", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
	{"mob": "marse", "from": 200.0, "to": 9999.0, "every": 4.5, "batch": 1}, 
]
const BYALAN_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "kukre", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "obeaune"}, 
	{"at": 175.0, "type": "ring", "mob": "vadon", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "strouf"}, 
	{"at": 300.0, "type": "elite", "mob": "obeaune"}, 
	{"at": 345.0, "type": "ring", "mob": "marina", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "obeaune"}, 
	{"at": 460.0, "type": "ring", "mob": "marse", "count": 20}, 
	{"at": 540.0, "type": "boss", "mob": "kraken"}, 
]

const TURTLE_SPAWNS: = [
	{"mob": "solider", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "permeter", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "freezer", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "heater", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
]
const TURTLE_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "solider", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "turtle_knight"}, 
	{"at": 175.0, "type": "ring", "mob": "permeter", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "turtle_champion"}, 
	{"at": 300.0, "type": "elite", "mob": "turtle_knight"}, 
	{"at": 345.0, "type": "ring", "mob": "freezer", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "turtle_knight"}, 
	{"at": 460.0, "type": "ring", "mob": "heater", "count": 20}, 
	{"at": 560.0, "type": "boss", "mob": "turtle_general"}, 
]

const PYRAMID_SPAWNS: = [
	{"mob": "matyr", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "mummy", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "isis", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "ghoul", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
	{"mob": "minorous", "from": 200.0, "to": 9999.0, "every": 4.5, "batch": 1}, 
]
const PYRAMID_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "matyr", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "marduk"}, 
	{"at": 175.0, "type": "ring", "mob": "mummy", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "ancient_mummy"}, 
	{"at": 300.0, "type": "elite", "mob": "marduk"}, 
	{"at": 345.0, "type": "ring", "mob": "isis", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "marduk"}, 
	{"at": 460.0, "type": "ring", "mob": "minorous", "count": 20}, 
	{"at": 560.0, "type": "boss", "mob": "osiris"}, 
]

const ANTHELL_SPAWNS: = [
	{"mob": "andre", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "piere", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "deniro", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "vitata", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
]
const ANTHELL_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "andre", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "argiope"}, 
	{"at": 175.0, "type": "ring", "mob": "piere", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "giant_spider"}, 
	{"at": 300.0, "type": "elite", "mob": "argiope"}, 
	{"at": 345.0, "type": "ring", "mob": "deniro", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "argiope"}, 
	{"at": 460.0, "type": "ring", "mob": "vitata", "count": 20}, 
	{"at": 570.0, "type": "boss", "mob": "maya"}, 
]

const MJOLNIR_SPAWNS: = [
	{"mob": "hornet", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "steel_chocho", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "skel_worker", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "iron_fist", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
	{"mob": "argos", "from": 200.0, "to": 9999.0, "every": 4.5, "batch": 1}, 
]
const MJOLNIR_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "hornet", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "giant_hornet"}, 
	{"at": 175.0, "type": "ring", "mob": "steel_chocho", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "golem"}, 
	{"at": 300.0, "type": "elite", "mob": "giant_hornet"}, 
	{"at": 345.0, "type": "ring", "mob": "skel_worker", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "giant_hornet"}, 
	{"at": 460.0, "type": "ring", "mob": "argos", "count": 20}, 
	{"at": 575.0, "type": "boss", "mob": "mistress"}, 
]

const CLOCK_TOWER_SPAWNS: = [
	{"mob": "punk", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "alarm", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "clock", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "rideword", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
]
const CLOCK_TOWER_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "punk", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "mimic"}, 
	{"at": 175.0, "type": "ring", "mob": "alarm", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "owl_duke"}, 
	{"at": 300.0, "type": "elite", "mob": "mimic"}, 
	{"at": 345.0, "type": "ring", "mob": "clock", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "mimic"}, 
	{"at": 460.0, "type": "ring", "mob": "rideword", "count": 20}, 
	{"at": 590.0, "type": "boss", "mob": "owl_baron"}, 
]

const NIFLHEIM_SPAWNS: = [
	{"mob": "quve", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "hylozoist", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "gibbet", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "loli_ruri", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
]
const NIFLHEIM_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "quve", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "bloody_murderer"}, 
	{"at": 175.0, "type": "ring", "mob": "hylozoist", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "dullahan"}, 
	{"at": 300.0, "type": "elite", "mob": "bloody_murderer"}, 
	{"at": 345.0, "type": "ring", "mob": "gibbet", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "bloody_murderer"}, 
	{"at": 460.0, "type": "ring", "mob": "loli_ruri", "count": 20}, 
	{"at": 620.0, "type": "boss", "mob": "lord_of_death"}, 
]

const JUPEROS_SPAWNS: = [
	{"mob": "venatu", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "venatu_1", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "dimik", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "dimik_1", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
]
const JUPEROS_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "venatu", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "dimik_2"}, 
	{"at": 175.0, "type": "ring", "mob": "venatu_1", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "archdam"}, 
	{"at": 300.0, "type": "elite", "mob": "dimik_2"}, 
	{"at": 345.0, "type": "ring", "mob": "dimik", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "dimik_2"}, 
	{"at": 460.0, "type": "ring", "mob": "dimik_1", "count": 20}, 
	{"at": 630.0, "type": "boss", "mob": "apocalips"}, 
]

const TOY_FACTORY_SPAWNS: = [
	{"mob": "cookie", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "cookie_xmas", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "cruiser", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "mystcase", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
]
const TOY_FACTORY_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "cookie", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "marionette"}, 
	{"at": 175.0, "type": "ring", "mob": "garm_baby", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "garm"}, 
	{"at": 300.0, "type": "elite", "mob": "marionette"}, 
	{"at": 345.0, "type": "ring", "mob": "cookie_xmas", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "marionette"}, 
	{"at": 460.0, "type": "ring", "mob": "mystcase", "count": 20}, 
	{"at": 600.0, "type": "boss", "mob": "knight_of_windstorm"}, 
]

const THANATOS_SPAWNS: = [
	{"mob": "solace", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "observation", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "retribution", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "shelter", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
]
const THANATOS_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "solace", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "zherlthsh"}, 
	{"at": 175.0, "type": "ring", "mob": "retribution", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "tha_odium"}, 
	{"at": 300.0, "type": "elite", "mob": "zherlthsh"}, 
	{"at": 345.0, "type": "ring", "mob": "observation", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "zherlthsh"}, 
	{"at": 460.0, "type": "ring", "mob": "shelter", "count": 20}, 
	{"at": 640.0, "type": "boss", "mob": "thanatos"}, 
]

const BIOLAB_SPAWNS: = [
	{"mob": "ygnizem", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "whikebain", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "kavac", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "rawrel", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
]
const BIOLAB_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "armaia", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "seyren"}, 
	{"at": 175.0, "type": "ring", "mob": "erend", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "harword"}, 
	{"at": 300.0, "type": "elite", "mob": "eremes"}, 
	{"at": 345.0, "type": "ring", "mob": "whikebain", "count": 24}, 
	{"at": 380.0, "type": "elite", "mob": "magaleta"}, 
	{"at": 410.0, "type": "elite", "mob": "shecil"}, 
	{"at": 460.0, "type": "ring", "mob": "kavac", "count": 20}, 
	{"at": 500.0, "type": "elite", "mob": "katrinn"}, 
	{"at": 650.0, "type": "boss", "mob": "l_seyren"}, 
]

const THOR_SPAWNS: = [
	{"mob": "magmaring", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "imp", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "blazer", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "explosion", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
]
const THOR_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "magmaring", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "salamander"}, 
	{"at": 175.0, "type": "ring", "mob": "imp", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "lava_golem"}, 
	{"at": 300.0, "type": "elite", "mob": "kasa"}, 
	{"at": 345.0, "type": "ring", "mob": "blazer", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "salamander"}, 
	{"at": 460.0, "type": "ring", "mob": "magmaring", "count": 20}, 
	{"at": 500.0, "type": "elite", "mob": "kasa"}, 
	{"at": 650.0, "type": "boss", "mob": "ifrit"}, 
]

const RA_SAN_SPAWNS: = [
	{"mob": "agav", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "echio", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "seeker", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "isilla", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
]
const RA_SAN_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "vanberk", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "gremlin"}, 
	{"at": 175.0, "type": "ring", "mob": "hodremlin", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "beholder_master"}, 
	{"at": 300.0, "type": "elite", "mob": "beholder"}, 
	{"at": 345.0, "type": "ring", "mob": "agav", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "gremlin"}, 
	{"at": 460.0, "type": "ring", "mob": "echio", "count": 20}, 
	{"at": 500.0, "type": "elite", "mob": "beholder"}, 
	{"at": 640.0, "type": "boss", "mob": "gloom"}, 
]

const ICE_DUN_SPAWNS: = [
	{"mob": "siroma", "from": 0.0, "to": 9999.0, "every": 1.0, "batch": 1}, 
	{"mob": "snowier", "from": 25.0, "to": 9999.0, "every": 1.8, "batch": 1}, 
	{"mob": "gazeti", "from": 60.0, "to": 9999.0, "every": 2.6, "batch": 2}, 
	{"mob": "iceicle", "from": 120.0, "to": 9999.0, "every": 3.6, "batch": 2}, 
]
const ICE_DUN_EVENTS: = [
	{"at": 70.0, "type": "ring", "mob": "siroma", "count": 28}, 
	{"at": 115.0, "type": "elite", "mob": "ice_titan"}, 
	{"at": 175.0, "type": "ring", "mob": "snowier", "count": 28}, 
	{"at": 240.0, "type": "boss", "mob": "furious_snowier"}, 
	{"at": 300.0, "type": "elite", "mob": "ice_titan"}, 
	{"at": 345.0, "type": "ring", "mob": "gazeti", "count": 24}, 
	{"at": 410.0, "type": "elite", "mob": "ice_titan"}, 
	{"at": 460.0, "type": "ring", "mob": "siroma", "count": 20}, 
	{"at": 630.0, "type": "boss", "mob": "ktullanux"}, 
]







const STAGES: = {
	"prontera": {"region": "prontera", "tier": 1, "bgm": "Streamside", "name": "Prontera Field", "map": "prt_fild08", "mvp_time": MVP_TIME, "unlock": "", 
		"spawns": SPAWNS, "events": EVENTS, "mvp": "baphomet", 
		"desc": "MVP: Baphomet"}, 
	"payon": {"region": "payon", "tier": 2, "bgm": "Nano East", "name": "Payon Forest", "map": "pay_fild07", "mvp_time": 540.0, "unlock": "prontera", 
		"spawns": PAYON_SPAWNS, "events": PAYON_EVENTS, "mvp": "eddga", 
		"desc": "MVP: Eddga"}, 
	"pay_cave": {"region": "payon", "tier": 3, "bgm": "Welcome Mr. Hwang", "name": "Payon Cave", "map": "pay_dun04", "mvp_time": 560.0, "unlock": "payon", 
		"spawns": PAY_CAVE_SPAWNS, "events": PAY_CAVE_EVENTS, "mvp": "moonlight", 
		"desc": "MVP: Moonlight Flower · no-muertos: usa Sagrado y Fuego"}, 
	"orc": {"region": "geffen", "tier": 4, "bgm": "One Fine Day", "name": "Orc Village", "map": "gef_fild14", "mvp_time": 570.0, "unlock": "pay_cave", 
		"spawns": ORC_SPAWNS, "events": ORC_EVENTS, "mvp": "ork_hero", 
		"desc": "MVP: Orc Hero · orcos de Tierra: usa Fuego y Viento"}, 
	"orc_dun": {"region": "geffen", "tier": 5, "bgm": "Help Yourself", "name": "Orc Dungeon", "map": "orcsdun01", "mvp_time": 580.0, "unlock": "orc", 
		"spawns": ORC_DUN_SPAWNS, "events": ORC_DUN_EVENTS, "mvp": "orc_lord", 
		"desc": "MVP: Orc Lord · orcos no-muertos"}, 
	"glast": {"region": "glast", "tier": 6, "bgm": "Curse'n Pain", "name": "Glast Heim", "map": "glast_01", "mvp_time": 600.0, "unlock": "orc_dun", 
		"spawns": GLAST_SPAWNS, "events": GLAST_EVENTS, "mvp": "dark_lord", 
		"desc": "MVP: Dark Lord · no-muertos: usa Sagrado y Fuego"}, 
	"nameless": {"region": "nameless", "tier": 7, "bgm": "Good Night", "name": "Nameless Island", "map": "nameless_n", "mvp_time": 620.0, "unlock": "glast", 
		"spawns": NAMELESS_SPAWNS, "events": NAMELESS_EVENTS, "mvp": "fallen_bishop", 
		"desc": "MVP: Fallen Bishop Hibram · no-muertos y oscuridad: usa Sagrado"}, 
	"abbey": {"region": "nameless", "tier": 8, "bgm": "Monastery In Disguise", "name": "Cursed Abbey", "map": "abbey02", "mvp_time": 640.0, "unlock": "nameless", 
		"spawns": ABBEY_SPAWNS, "events": ABBEY_EVENTS, "mvp": "beelzebub", 
		"desc": "MVP: Beelzebub · demonios y no-muertos: usa Sagrado"}, 
	"culvert": {"region": "prontera", "tier": 1, "bgm": "Under the ground", "name": "Prontera Culvert", "map": "prt_sewb1", "mvp_time": 520.0, 
		"spawns": CULVERT_SPAWNS, "events": CULVERT_EVENTS, "mvp": "golden_bug", 
		"desc": "MVP: Golden Thief Bug · insectos de las alcantarillas: usa Fuego"}, 
	"byalan": {"region": "alberta", "tier": 2, "bgm": "Be Nice 'n Easy", "name": "Byalan Island", "map": "iz_dun01", "mvp_time": 540.0, 
		"spawns": BYALAN_SPAWNS, "events": BYALAN_EVENTS, "mvp": "kraken", 
		"desc": "MVP: Kraken · criaturas marinas de Agua: usa Viento"}, 
	"turtle": {"region": "alberta", "tier": 3, "bgm": "Into the Abyss", "name": "Turtle Island", "map": "tur_dun02", "mvp_time": 560.0, 
		"spawns": TURTLE_SPAWNS, "events": TURTLE_EVENTS, "mvp": "turtle_general", 
		"desc": "MVP: Turtle General · tortugas guerreras de Tierra: usa Fuego"}, 
	"pyramid": {"region": "morroc", "tier": 3, "bgm": "Backattack!!", "name": "Pyramid", "map": "moc_pryd03", "mvp_time": 560.0, 
		"spawns": PYRAMID_SPAWNS, "events": PYRAMID_EVENTS, "mvp": "osiris", 
		"desc": "MVP: Osiris · momias no-muertas: usa Sagrado y Fuego"}, 
	"anthell": {"region": "morroc", "tier": 4, "bgm": "An Ant-lion's Pit", "name": "Ant Hell", "map": "anthell01", "mvp_time": 570.0, 
		"spawns": ANTHELL_SPAWNS, "events": ANTHELL_EVENTS, "mvp": "maya", 
		"desc": "MVP: Maya · hormigas de Tierra: usa Fuego"}, 
	"mjolnir": {"region": "aldebaran", "tier": 4, "bgm": "Dreamer's Dream", "name": "Mjolnir Dead Pit", "map": "mjo_dun01", "mvp_time": 575.0, 
		"spawns": MJOLNIR_SPAWNS, "events": MJOLNIR_EVENTS, "mvp": "mistress", 
		"desc": "MVP: Mistress · mineros y abejas: usa Fuego"}, 
	"clock_tower": {"region": "aldebaran", "tier": 5, "bgm": "Aeon", "name": "Clock Tower", "map": "c_tower1", "mvp_time": 590.0, 
		"spawns": CLOCK_TOWER_SPAWNS, "events": CLOCK_TOWER_EVENTS, "mvp": "owl_baron", 
		"desc": "MVP: Owl Baron · relojes y juguetes encantados"}, 
	"niflheim": {"region": "glast", "tier": 7, "bgm": "Christmas in the 13th Month", "name": "Niflheim", "map": "niflheim", "mvp_time": 620.0, 
		"spawns": NIFLHEIM_SPAWNS, "events": NIFLHEIM_EVENTS, "mvp": "lord_of_death", 
		"desc": "MVP: Lord of the Dead · el reino de los muertos: usa Sagrado"}, 
	"juperos": {"region": "schwarzwald", "tier": 8, "bgm": "We Have Lee But You Don't Have", "name": "Juperos", "map": "jupe_core", "mvp_time": 630.0, 
		"spawns": JUPEROS_SPAWNS, "events": JUPEROS_EVENTS, "mvp": "apocalips", 
		"desc": "MVP: Vesper · máquinas antiguas: usa Viento"}, 
	"toy_factory": {"region": "lutie", "tier": 6, "bgm": "Toy Factory", "name": "Toy Factory", "map": "xmas_dun01", "mvp_time": 600.0, 
		"spawns": TOY_FACTORY_SPAWNS, "events": TOY_FACTORY_EVENTS, "mvp": "knight_of_windstorm", 
		"desc": "MVP: Stormy Knight · juguetes y galletas de Navidad; el caballero de Viento: usa Tierra"}, 
	"thanatos": {"region": "hugel", "tier": 9, "bgm": "Tower of Thanatos", "name": "Thanatos Tower", "map": "tha_t03", "mvp_time": 640.0, 
		"spawns": THANATOS_SPAWNS, "events": THANATOS_EVENTS, "mvp": "thanatos", 
		"desc": "MVP: Memory of Thanatos · almas de la torre, fantasmas: usa Sagrado"}, 
	"biolab": {"region": "schwarzwald", "tier": 10, "bgm": "Bio Laboratory", "name": "Bio Laboratory", "map": "lhz_dun02", "mvp_time": 650.0, 
		"spawns": BIOLAB_SPAWNS, "events": BIOLAB_EVENTS, "mvp": "l_seyren", 
		"desc": "MVP: Lord Knight Seyren · los clones de los héroes: cada uno de un elemento"}, 
	"ice_dun": {"region": "rachel", "tier": 8, "bgm": "Yetit Petit", "name": "Ice Cave", "map": "ice_dun03", "mvp_time": 630.0, 
		"spawns": ICE_DUN_SPAWNS, "events": ICE_DUN_EVENTS, "mvp": "ktullanux", 
		"desc": "MVP: Ktullanux · criaturas de Agua de la cueva helada: usa Viento"}, 
	"ra_san": {"region": "rachel", "tier": 9, "bgm": "Underneath The Temple", "name": "Rachel Sanctuary", "map": "ra_san02", "mvp_time": 640.0, 
		"spawns": RA_SAN_SPAWNS, "events": RA_SAN_EVENTS, "mvp": "gloom", 
		"desc": "MVP: Gloom Under Night · guardianes del templo de Freyja y demonios de la noche"}, 
	"thor": {"region": "veins", "tier": 10, "bgm": "Sleeping Volcano", "name": "Thor Volcano", "map": "thor_v01", "mvp_time": 650.0, 
		"spawns": THOR_SPAWNS, "events": THOR_EVENTS, "mvp": "ifrit", 
		"desc": "MVP: Ifrit · criaturas de Fuego del volcán: usa Agua"}, 
}




const REGIONS: = {
	"prontera": {"min_danger": 1, "side": "right", "name": "Prontera", "pos": Vector2(845, 615), "unlock": "", "stages": ["prontera", "culvert"]}, 
	"payon": {"min_danger": 2, "side": "right", "name": "Payon", "pos": Vector2(1000, 765), "unlock": "prontera", "stages": ["payon", "pay_cave"]}, 
	"alberta": {"min_danger": 3, "side": "up", "name": "Alberta", "pos": Vector2(1090, 935), "unlock": "prontera", "stages": ["byalan", "turtle"]}, 
	"morroc": {"min_danger": 4, "side": "up", "name": "Morroc", "pos": Vector2(626, 864), "unlock": "payon", "stages": ["pyramid", "anthell"]}, 
	"geffen": {"min_danger": 5, "side": "down", "name": "Geffen", "pos": Vector2(600, 550), "unlock": "payon", "stages": ["orc", "orc_dun"]}, 
	"aldebaran": {"min_danger": 6, "side": "up", "name": "Al De Baran", "pos": Vector2(840, 325), "unlock": "geffen", "stages": ["mjolnir", "clock_tower"]}, 
	"glast": {"min_danger": 7, "side": "left", "name": "Glast Heim", "pos": Vector2(430, 495), "unlock": "geffen", "stages": ["glast", "niflheim"]}, 
	"schwarzwald": {"min_danger": 9, "side": "up", "name": "Schwarzwald", "pos": Vector2(575, 265), "unlock": "glast", "stages": ["juperos", "biolab"]}, 
	"lutie": {"min_danger": 10, "side": "left", "name": "Lutie", "pos": Vector2(1040, 180), "unlock": "aldebaran", "stages": ["toy_factory"]}, 
	"hugel": {"min_danger": 11, "side": "down", "name": "Hugel", "pos": Vector2(895, 40), "unlock": "schwarzwald", "stages": ["thanatos"]}, 
	"nameless": {"min_danger": 8, "side": "right", "name": "Nameless Island", "pos": Vector2(128, 728), "unlock": "glast", "stages": ["nameless", "abbey"]}, 
	"rachel": {"min_danger": 12, "side": "up", "name": "Rachel", "pos": Vector2(250, 325), "unlock": "schwarzwald", "stages": ["ice_dun", "ra_san"]}, 
	"veins": {"min_danger": 13, "side": "left", "name": "Veins", "pos": Vector2(185, 550), "unlock": "rachel", "stages": ["thor"]}, 
}





const DANGER_MAX: = 30



const DANGER_HELL10: = 25



const DANGER_RATE_STEP: = 0.15
const DANGER_SPEED_STEP: = 0.06
const DANGER_BOSS_SPEED_STEP: = 0.015


const DANGER_HP_CROWD: = 1.24
const DANGER_DMG_CROWD: = 1.13













const DANGER_STEEP_FROM: = 4
const DANGER_HP_CROWD_LATE: = 1.34
const DANGER_DMG_CROWD_LATE: = 1.17


const DANGER_TOUGH_HP: = 1.1
const DANGER_TOUGH_DMG: = 1.06




const DANGER_HELL_FROM: = 16
const HELL_HP: = 2.0
const HELL_DMG: = 1.5
const HELL_LATE_FROM: = 11



const HELL_HP_LATE: = 2.15
const HELL_HP_TRIM_FROM: = 10
const HELL_HP_TRIM: = 0.9
const HELL_DMG_LATE: = 1.6






const HELL_HP_SQUEEZE: = [1.0, 1.35, 1.35, 1.3, 1.3, 1.25, 1.2, 1.2, 1.1, 1.1, 1.1, 1.1, 1.05, 1.05, 1.05, 1.05]
const HELL_RATE: = 0.15
const HELL_SPEED: = 0.06


const HELL_RAMP: = 300.0


const HELL_FEATURES: = [
	{"name": "Horda de Midgard", "desc": "Monstruos de todos los mapas se suman a la partida."}, 
	{"name": "Sangre maldita", "desc": "Te curas la mitad (pociones, habilidades y regeneración)."}, 
	{"name": "Cacería feroz", "desc": "Los monstruos feroces llegan el doble de seguido."}, 
	{"name": "Venganza de los caídos", "desc": "Algunos monstruos estallan al morir: aléjate del círculo rojo."}, 
	{"name": "Lluvia infernal", "desc": "Cada pocos segundos caen pilares de fuego sobre ti: muévete."}, 
	{"name": "Cerco de almas", "desc": "De vez en cuando un anillo de monstruos aparece a tu alrededor y se cierra sobre ti: ábrete paso."}, 
	{"name": "Heraldos de Surtr", "desc": "Aparecen monstruos gigantes en llamas que queman el suelo a su alrededor. Derrótalos: sueltan un cofre y te curan."}, 
	{"name": "Marea infernal", "desc": "De vez en cuando llegan el triple de monstruos durante unos segundos. Si la aguantas, aparece un cofre."}, 
	{"name": "Meteoros errantes", "desc": "Franjas de meteoros cruzan el mapa por donde estás: sal de la línea roja."}, 
	{"name": "Ragnarök", "desc": "Algunos monstruos caídos se alzan otra vez como espectros más rápidos."}, 
	{"name": "Sombras de los MVP", "desc": "De vez en cuando llega una sombra del MVP del mapa con una de sus mecánicas: apréndela antes de pelear con él."}, 
	{"name": "Élites con Aguante", "desc": "Los élites no se congelan, aturden ni duermen: los estados llenan su barra de Aguante, como a los jefes."}, 
	{"name": "Altares profanados", "desc": "Rezar en un altar despierta a su guardián, que te persigue hasta que lo vences."}, 
	{"name": "La niebla de Niflheim", "desc": "La niebla va y viene. Mientras está, solo la luz de Yggdrasil es segura: se retira cada poco y aparece otra más lejos, marcada en el mapa. Fuera pierdes vida y te curas la mitad."}, 
	{"name": "Marca del Apocalipsis", "desc": "De vez en cuando Morroc te marca: a los 5 segundos estalla donde estés y deja sangre en el suelo durante 30 segundos. Apártate a tiempo y no la pises."}, 
]





const HELL_SHADOW_FIRST: = 60.0
const HELL_SHADOW_EVERY: = 80.0
const HELL_SHADOW_HP: = 0.15
const HELL_SHADOW_CAST_EVERY: = 5.0
const HELL_SHADOW_PCT: = 0.1
const HELL_SHADOW_HEAL: = 0.15


const HELL_SHADOW_CARD: = 0.25







const HELL_SHADOW_TANK: = 20.0
const HELL_PROFANE_TANK: = 4.0
const HELL_SHADOW_MECHS: = ["cone", "rain", "slam", "charge", "spokes"]

const HELL_STAGGER_ELITE: = 0.4










const PUNISH_DMG: = 1.5
const PUNISH_COLOR: = Color(1.0, 0.55, 0.2)
const PUNISH_SKILLS: = {


	"soul_breaker": true, "soul_breaker_x": true, 
	"arclouse_dash": true, "arclouse_dash_x": true, "arrow_shower": true, "arrow_shower_x": true, 
	"arrow_vulcan": true, "arrow_vulcan_x": true, "asura_strike": true, "asura_strike_x": true, 
	"axe_tornado": true, "axe_tornado_x": true, "back_stab": true, "banishing_buster": true, 
	"banishing_buster_x": true, "bowling_bash": true, "bowling_bash_x": true, "cart_cannon": true, 
	"cart_revolution": true, "cart_revolution_x": true, "catnip_meteor": true, 
	"catnip_meteor_x": true, "chain_crush": true, "chain_crush_x": true, "charge_attack": true, 
	"charge_attack_x": true, "counter_kick": true, "demonstration": true, "demonstration_x": true, 
	"desperado": true, "desperado_x": true, "dissonance": true, "dissonance_x": true, 
	"double_strafe": true, "double_strafe_x": true, "earth_spike": true, "earth_spike_x": true, 
	"esma": true, "esma_x": true, "estin": true, "exploding_dragon": true, "exploding_dragon_x": true, 
	"falcon_assault": true, "falcon_assault_x": true, "finger_offensive": true, 
	"finger_offensive_x": true, "fire_bolt": true, "fire_rain": true, "fire_rain_x": true, 
	"flaming_petals": true, "flying_kick": true, "flying_kick_x": true, "grand_cross": true, 
	"grand_cross_x": true, "gravitation_field": true, "gravitation_field_x": true, 
	"heavens_drive": true, "heavens_drive_x": true, "holy_light": true, "holy_light_x": true, 
	"huuma_storm": true, "huuma_storm_x": true, "investigate": true, "investigate_x": true, 
	"killing_strike": true, "killing_strike_x": true, "kunai_explosion": true, 
	"kunai_explosion_x": true, "kunai_splash": true, "kunai_splash_x": true, "leap": true, 
	"lord_of_vermilion": true, "lord_of_vermilion_x": true, "magnus_exorcismus": true, 
	"magnus_exorcismus_x": true, "mammonite": true, "mammonite_x": true, "moonlight_fantasy": true, 
	"moonlight_fantasy_x": true, "musical_strike": true, "musical_strike_x": true, "picky_peck": true, 
	"picky_peck_x": true, "roundhouse_kick": true, "ruwach": true, "ruwach_x": true, 
	"shadow_slash": true, "shadow_slash_x": true, "shield_boomerang": true, 
	"shield_boomerang_x": true, "silvervine_stem_spear": true, "silvervine_stem_spear_x": true, 
	"slug_shot": true, "slug_shot_x": true, "soul_strike": true, "soul_strike_x": true, 
	"spear_boomerang": true, "spear_boomerang_x": true, "spread_attack": true, 
	"spread_attack_x": true, "throw_huuma": true, "throw_huuma_x": true, "throw_kunai": true, 
	"throw_kunai_x": true, "throw_shuriken": true, "throw_shuriken_x": true, "throw_zeny": true, 
	"throw_zeny_x": true, "thunder_storm": true, "thunder_storm_x": true, "tornado_kick": true, 
	"tornado_kick_x": true, "tracking": true, "tracking_x": true, "triple_action": true, 
	"triple_action_x": true, "volcano": true, "volcano_x": true, "warmth_stars": true, 
	"warmth_sun": true, "warmth_sun_x": true
}

const HELL_PROFANE_HP: = 3.0
const HELL_PROFANE_SPEED: = 1.25










const HELL_FOG_RADIUS: = 17.0


const HELL_FOG_FIRST: = 60.0
const HELL_FOG_ON: = 25.0
const HELL_FOG_OFF: = 55.0
const HELL_FOG_STAY: = 9.0
const HELL_FOG_SHRINK: = 8.0
const HELL_FOG_MOVE: = 22.0


const HELL_FOG_PCT: = 0.03
const HELL_FOG_RAMP: = 0.015
const HELL_FOG_MAX: = 0.12
const HELL_FOG_HEAL: = 0.5








const MARK_FIRST: = 30.0

const MARK_EVERY: = 30.0
const MARK_FOLLOW: = 4.0
const MARK_LOCK: = 1.0
const MARK_RADIUS: = 3.2
const MARK_PCT: = 0.3

const MARK_POOL_TIME: = 30.0
const MARK_POOL_MAX: = 12
const MARK_POOL_PCT: = 0.05




const MORROC_GAME_FIRST: = 90.0
const MORROC_GAME_EVERY: = 170.0
const MORROC_GAME_TIME: = 10.0
const MORROC_SEAL_GAME_TIME: = 14.0
const MORROC_SEAL_TIME: = 1.5
const MORROC_HOP_TIME: = 12.0



const MORROC_SEAL_SIZE: = 1.8
const MORROC_HOP_SIZE: = 1.5
const MORROC_DANCE_SIZE: = 3.6
const MORROC_GAME_CLEAR: = 7.0


const MORROC_DANCE_GRACE: = 3.0
const MORROC_GAMES: = ["skulls", "dance", "seals", "hop"]



const MORROC_TOYS: = {
	"abyss_rain": {"name": "Lluvia del abismo", "icon": "meteor_storm", "max": 3, 
		"desc": "Cada pocos segundos caen calaveras sobre los monstruos cercanos (más calaveras cada vez que lo eliges)."}, 
	"rift": {"name": "Grieta al morir", "icon": "exploding_dragon", "max": 3, 
		"desc": "Algunos monstruos que matas abren una grieta que daña a los de alrededor."}, 
	"whim": {"name": "Capricho del niño", "icon": "improve_concentration", "max": 3, "mods": {"haste": 0.06}, 
		"desc": "Tus recargas son un 6% más rápidas."}, 
	"bone_crown": {"name": "Corona de huesos", "icon": "kyrie_eleison", "max": 3, 
		"desc": "Cada pocos segundos un escudo de calaveras del 6% de tu vida máxima."}, 
	"laugh": {"name": "Risa de Morroc", "icon": "loud_exclamation", "max": 3, 
		"desc": "Los monstruos cerca de ti van más lentos."}, 
	"broken_toy": {"name": "Juguete roto", "icon": "bash", "max": 3, 
		"desc": "+3% de daño por cada juguete que tengas."}, 
	"tantrum": {"name": "Berrinche", "icon": "status_combo", "max": 3, "fx": {"wing_fill": 0.25, "wing_broken": 0.1}, 
		"desc": "Llenas el Aguante de los jefes un 25% más rápido y les pegas un 10% más cuando están aturdidos."}, 
	"poison_gift": {"name": "Regalo envenenado", "icon": "venom_dust", "max": 1, 
		"desc": "Cuando muere un monstruo con veneno o sangrado, sus cargas saltan al de al lado."}, 
}
const TOY_RAIN_EVERY: = 4.0
const TOY_RAIN_DMG: = 6.0
const TOY_RIFT_CHANCE: = 0.15
const TOY_RIFT_DMG: = 5.0

const TOY_RIFT_GAP: = 0.12
const TOY_BONES_EVERY: = 8.0
const TOY_BONES_SHIELD: = 0.06
const TOY_LAUGH_RADIUS: = 4.0
const TOY_BROKEN_DMG: = 0.03
const TOY_GIFT_STACKS: = 10


const HELL_RING_EVERY: = 32.0
const HELL_RING_COUNT: = 22
const HELL_RING_RADIUS: = 10.0





const HELL_HERALD_EVERY: = 45.0
const HELL_HERALD_HP: = 4.0
const HELL_HERALD_FIRE: = 3.0
const HELL_HERALD_SIZE: = 2.6
const HELL_HERALD_PCT: = 0.12
const HELL_HERALD_CHEST: = 1
const HELL_HERALD_HEAL: = 0.2


const HELL_TIDE_EVERY: = 55.0
const HELL_TIDE_TIME: = 12.0
const HELL_TIDE_RATE: = 3.0



const HELL_METEOR_EVERY: = 14.0
const HELL_METEOR_LINES: = 3
const HELL_METEOR_WIDTH: = 1.6
const HELL_METEOR_CAST: = 1.5
const HELL_METEOR_PCT: = 0.18



const HELL_RISE_CHANCE: = 0.12
const HELL_RISE_GAP: = 0.15
const HELL_RISE_HP: = 0.6
const HELL_RISE_SPEED: = 1.3



const HELL_REVENGE_CHANCE: = 0.06
const HELL_REVENGE_CAST: = 1.0
const HELL_REVENGE_SIZE: = 1.6
const HELL_REVENGE_PCT: = 0.08
const HELL_REVENGE_GAP: = 0.25

const HELL_HEAL: = 0.5



const HELL_RAIN_EVERY: = 9.0




const STORM_FROM: = 10
const STORM_EVERY: = 12.0
const STORM_BOLTS: = 3
const STORM_GAP: = 0.55
const STORM_CAST: = 0.9
const STORM_SIZE: = 1.5
const STORM_PCT: = 0.08
const HELL_RAIN_COUNT: = 4
const HELL_RAIN_CAST: = 1.3
const HELL_RAIN_SIZE: = 2.0
const HELL_RAIN_PCT: = 0.15


const DANGER_HARD: = 8

const FEATURED_BONUS: = 0.25



const CURSE_XP: = 0.7
const CURSE_ZENY: = 2.0








const OATHS: = [
	{"id": "tough", "name": "Monstruos robustos", "icon": "hp_recovery", "pts": [1, 2, 4], "val": [1.3, 1.6, 2.0], 
		"desc": "Todos los monstruos tienen más vida, también los jefes y los MVP.", 
		"ranks": ["+30% de vida", "+60% de vida", "+100% de vida"]}, 
	{"id": "hunt", "name": "Cacería salvaje", "icon": "provoke", "pts": [1, 2, 3], "val": [1.5, 2.0, 3.0], 
		"desc": "Los monstruos especiales (feroces, veloces, malditos y gigantes) llegan más seguido, y caben más a la vez.", 
		"ranks": ["Un 50% más", "El doble", "El triple"]}, 
	{"id": "kyrie", "name": "Kyrie Eleison", "icon": "kyrie_eleison", "pts": [1, 2, 3], "val": [0.35, 0.65, 1.0], 
		"desc": "Los monstruos llegan con Kyrie Eleison: una barrera del 30% de su vida, y el golpe que la rompe no les hace daño. Los jefes no.", 
		"ranks": ["Uno de cada tres monstruos", "Dos de cada tres monstruos", "Todos los monstruos"]}, 
	{"id": "elite", "name": "Monstruos de élite", "icon": "over_thrust", "pts": [2, 4, 6], "val": [1, 2, 2], 
		"desc": "Los monstruos especiales aprenden habilidades de monstruo: Heal (curan a los de alrededor), Power Up (pegan más fuerte), Teleport (aparecen a tu lado), Summon Slave (llaman esbirros) o Blood Drain (tus golpes recibidos los curan).", 
		"ranks": ["Una habilidad cada uno", "Dos habilidades cada uno", "Dos habilidades y llegan el doble de seguido"]}, 
	{"id": "mvp_fury", "name": "Furia del MVP", "icon": "meteor_assault", "pts": [2, 4], "val": [0.8, 0.65], 
		"desc": "Los MVP, las Valquirias y Satan Morroc descansan menos entre una mecánica y la siguiente (siguen sin lanzar dos a la vez).", 
		"ranks": ["Un 20% menos de espera", "Un 35% menos de espera"]}, 
	{"id": "hellfire", "name": "Infierno ardiente", "icon": "fire_rain", "pts": [1, 2, 3], "val": [0.8, 0.65, 0.5], 
		"desc": "La Lluvia infernal, los Meteoros errantes y el Cerco de almas llegan más seguido.", 
		"ranks": ["Un 25% más seguido", "Un 55% más seguido", "El doble de seguido"]}, 
	{"id": "lex", "name": "Lex Divina", "icon": "lex_aeterna", "pts": [2, 4], "val": [12.0, 7.0], 
		"desc": "Algunos golpes de los monstruos te lanzan Lex Divina: 2 segundos sin lanzar habilidades (tu ataque básico sigue; las recargas esperan).", 
		"ranks": ["Como mucho una vez cada 12 s", "Como mucho una vez cada 7 s"]}, 


	{"id": "curse", "name": "Maldición", "icon": "signum_crucis", "pts": [2, 4], "val": [0.03, 0.04], 
		"desc": "Cada golpe que recibes te maldice: baja tu vida máxima, y con ella lo que escala con tu vida. Se va tras 15 s sin recibir golpes o al vencer a un jefe.", 
		"ranks": ["−3% por golpe, hasta −40%", "−4% por golpe, hasta −60%"]}, 
	{"id": "unlucky", "name": "Sin suerte", "icon": "coin_flip", "pts": [3, 6], "val": [0.5, 0.0], 
		"desc": "Tu esquiva perfecta (Lucky, la de la SUE) baja y también tu Flee: los golpes que esquivabas ahora te dan, también las mecánicas de los MVP.", 
		"ranks": ["La mitad de esquiva perfecta, -25% de Flee", "Sin esquiva perfecta, -50% de Flee"]}, 





	{"id": "wounds", "name": "Heridas abiertas", "icon": "martyrs_reckoning", "pts": [1, 3], "val": [0.8, 0.65], 
		"desc": "Te curas menos (pociones, habilidades y regeneración), encima de Sangre maldita del Infierno.", 
		"ranks": ["−20% de curación", "−35% de curación"]}, 
]


const OATH_CURSE_MAX: = [0.4, 0.6]
const OATH_CURSE_GAP: = 1.0
const OATH_CURSE_HOLD: = 15.0

const OATH_SILENCE: = 2.0
const OATH_SILENCE_CHANCE: = 0.3

const OATH_KYRIE: = 0.3









const OATH_AFFIXES: = {
	"heal": {"name": "Heal", "color": Color(0.55, 1.0, 0.6), "every": 5.0, "heal": 0.12, "reach": 6.0}, 
	"power_up": {"name": "Power Up", "color": Color(1.0, 0.45, 0.35), "dmg": 1.6}, 
	"teleport": {"name": "Teleport", "color": Color(0.7, 0.75, 1.0), "every": 7.0, "far": 7.0, "near": 3.0}, 
	"summon": {"name": "Summon Slave", "color": Color(1.0, 0.8, 0.4), "every": 12.0, "count": 3, "max": 9}, 
	"drain": {"name": "Blood Drain", "color": Color(0.9, 0.3, 0.5), "heal": 0.1, "gap": 3.0}, 
}


const OATH_TITLE_STEPS: = [10, 20]



func oath_def(id: String) -> Dictionary:
	for o in OATHS:
		if str(o.id) == id:
			return o
	return {}



func oath_points(sworn: Dictionary) -> int:
	var n: = 0
	for id in sworn:
		var o: = oath_def(str(id))
		var r: = int(sworn[id])
		if not o.is_empty() and r > 0:
			n += int((o.pts as Array)[mini(r, (o.pts as Array).size()) - 1])
	return n



func oath_max_points() -> int:
	var n: = 0
	for o in OATHS:
		n += int((o.pts as Array).back())
	return n



func oath_value(id: String, r: int, fallback: = 1.0) -> float:
	var o: = oath_def(id)
	if o.is_empty() or r <= 0:
		return fallback
	return float((o.val as Array)[mini(r, (o.val as Array).size()) - 1])





func stage_min_danger(stage_id: String) -> int:
	var r: Dictionary = REGIONS.get(stage_region(stage_id), {})
	return clampi(int(r.get("min_danger", 1)), 1, DANGER_MAX)



const DANGER_FREE_STEPS: = 4






func stage_danger_range(stage_id: String, max_unlocked: int) -> Vector2i:
	var lo: = stage_min_danger(stage_id)
	var free: = mini(maxi(lo, Save.danger_best(stage_id)) + DANGER_FREE_STEPS, DANGER_HELL_FROM - 1)
	return Vector2i(lo, clampi(maxi(free, max_unlocked), lo, DANGER_MAX))



func stage_danger_range_after(stage_id: String, d: int, max_unlocked: int) -> int:
	var lo: = stage_min_danger(stage_id)
	var best: = maxi(maxi(lo, Save.danger_best(stage_id)), d)
	var unlocked: = maxi(max_unlocked, next_danger_unlock(d)) if d >= max_unlocked else max_unlocked
	return clampi(maxi(mini(best + DANGER_FREE_STEPS, DANGER_HELL_FROM - 1), unlocked), lo, DANGER_MAX)




func next_danger_unlock(d: int) -> int:
	var step: = 2 if d + 1 >= DANGER_HELL_FROM else 1
	return mini(DANGER_MAX, d + step)



func hell_level(d: int) -> int:
	return maxi(0, d - DANGER_HELL_FROM + 1)






func poison_corrode(stacks: int, by: Player) -> float:
	return 1.0 + POISON_CORRODE * stacks * (1.0 + (float(by.effects.get("poison_amp", 0.0)) if by != null else 0.0))






const EARLY_DANGER_DMG: = {1: 0.4, 2: 0.3, 3: 0.2}

func early_danger_dmg(d: int) -> float:
	return float(EARLY_DANGER_DMG.get(d, 0.0))



func danger_name(d: int) -> String:
	var h: = hell_level(d)
	return tr("Infierno %d") % h if h > 0 else tr("Peligro %d") % d





func danger_hp(d: int, ramp: = 1.0, crowd: = false, squeeze: = true) -> float:
	var trim: = HELL_HP_TRIM if hell_level(d) >= HELL_HP_TRIM_FROM else 1.0
	return trim * DANGER_TOUGH_HP * (_crowd_curve(DANGER_HP_CROWD, DANGER_HP_CROWD_LATE, d) if crowd else pow(1.2, _base_danger(d) - 1)) * lerpf(1.0, hell_mult(HELL_HP, HELL_HP_LATE, hell_level(d)) * (hell_squeeze(d) if squeeze else 1.0), ramp)



func hell_squeeze(d: int) -> float:
	return float(HELL_HP_SQUEEZE[clampi(hell_level(d), 0, HELL_HP_SQUEEZE.size() - 1)])


func danger_dmg(d: int, ramp: = 1.0, crowd: = false) -> float:
	return DANGER_TOUGH_DMG * (_crowd_curve(DANGER_DMG_CROWD, DANGER_DMG_CROWD_LATE, d) if crowd else pow(1.11, _base_danger(d) - 1)) * lerpf(1.0, hell_mult(HELL_DMG, HELL_DMG_LATE, hell_level(d)), ramp)




func hell_mult(early: float, late: float, h: int) -> float:
	return pow(early, mini(h, HELL_LATE_FROM - 1)) * pow(late, maxi(0, h - HELL_LATE_FROM + 1))




func _crowd_curve(early: float, late: float, d: int) -> float:
	var b: = _base_danger(d)
	if hell_level(d) > 0:
		return pow(early, b - 1)
	return pow(early, mini(b, DANGER_STEEP_FROM) - 1) * pow(late, maxi(0, b - DANGER_STEEP_FROM))




func danger_rate(d: int, ramp: = 1.0) -> float:
	return (1.0 + DANGER_RATE_STEP * (_base_danger(d) - 1)) * (1.0 + HELL_RATE * hell_level(d) * ramp)




func danger_speed(d: int, ramp: = 1.0, crowd: = false) -> float:
	var step: = DANGER_SPEED_STEP if crowd else DANGER_BOSS_SPEED_STEP
	return 1.0 + step * (_base_danger(d) - 1) + HELL_SPEED * hell_level(d) * ramp




func _base_danger(d: int) -> int:
	return mini(d, DANGER_HELL_FROM - 1)






const CROWD_ZENY_FREE: = 20000
const CROWD_ZENY_K: = 73000.0
const CROWD_ZENY_MIN: = 0.45


func crowd_zeny_mult(kills: int) -> float:
	return maxf(CROWD_ZENY_MIN, 1.0 / (1.0 + maxf(0.0, float(kills - CROWD_ZENY_FREE)) / CROWD_ZENY_K))





const MVP_HP_LOW: = 1.5
const MVP_HP_HIGH: = 2.0


func mvp_danger_hp(d: int) -> float:
	if hell_level(d) > 0:
		return 1.0
	return lerpf(MVP_HP_LOW, MVP_HP_HIGH, float(d - 1) / float(DANGER_HELL_FROM - 2))



func hell_ramp(t: float) -> float:
	return clampf(t / HELL_RAMP, 0.0, 1.0)



func danger_xp(d: int) -> float:


	return pow(pow(1.13, d - 1), 0.5)



func danger_reward(d: int) -> float:
	return 1.0 + 0.12 * (d - 1)



func danger_class_xp(d: int) -> float:
	return 1.0 + 0.08 * (d - 1)



func danger_cards(d: int) -> float:
	return 1.0 + 0.01 * (d - 1)



func danger_boxes(d: int) -> float:
	return 1.0 + 0.05 * (d - 1)


func danger_legend(d: int) -> float:
	return 0.0004 * (d - 1) + HELL_LEGEND_EACH * hell_level(d) + HELL_LEGEND_STEP * _late_hell(d)



const HELL_EGG_STEP: = 0.05

const HELL_LEGEND_EACH: = 0.0008


const HELL_PAYS_FROM: = 5
const HELL_LEGEND_STEP: = 0.0008
const HELL_UNIQUE_STEP: = 0.25
func _late_hell(d: int) -> int:
	return maxi(0, hell_level(d) - HELL_PAYS_FROM + 1)



func unique_mult(d: int) -> float:
	return UNIQUE_HELL_MULT + HELL_UNIQUE_STEP * _late_hell(d) if hell_level(d) > 0 else 1.0


var _norm: = {}





func mob_norm(id: String) -> Vector3:
	if _norm.is_empty():
		var avg: = {}
		for sid in STAGES:
			var n: = 0
			var t: = Vector3.ZERO
			for sp in STAGES[sid].spawns:
				var m: Dictionary = MONSTERS.get(sp.mob, {})
				if m.is_empty():
					continue
				t += Vector3(float(m.hp), float(m.damage), float(m.xp))
				n += 1
			avg[sid] = t / maxf(1.0, n)
		var ref: Vector3 = avg["prontera"]
		for sid in STAGES:
			var f: = Vector3(ref.x / maxf(1.0, avg[sid].x), ref.y / maxf(0.1, avg[sid].y), ref.z / maxf(0.1, avg[sid].z))
			var mobs: Array = []
			for sp in STAGES[sid].spawns:
				mobs.append(sp.mob)
			for ev in STAGES[sid].events:
				mobs.append(ev.mob)
			mobs.append(STAGES[sid].mvp)
			for m in mobs:
				if not _norm.has(m):
					_norm[m] = f
	return _norm.get(id, Vector3.ONE)



func stage_region(id: String) -> String:
	return str(STAGES.get(id, {}).get("region", ""))



func featured_stage() -> String:
	var d: = Time.get_date_dict_from_system()
	var ids: Array = STAGES.keys()
	var seed_v: = int(d.year) * 372 + int(d.month) * 31 + int(d.day)
	return str(ids[(seed_v * 7919) % ids.size()])































const ARENA_KEEP_PROPS: = []


const ARENA_FLAT_MARGIN: = 1.0
const ARENA_FLAT_BLEND: = 3.0
const ARENA_CLEAR_MARGIN: = 3.0
const ARENA_CLEAR_FRONT: = 12.0
const RAIDS: = {
	"baphomet": {"arena": "prt_maze03", "flat": 1.6, "title": "Laberinto de Baphomet", "color": Color(0.75, 0.3, 1.0), 
		"radius": 13.0, "hp_mult": 3.5, "pillars": {"sprite": "barricade", "count": 0}, 
		"npc": {"sprite": "npc_priest", "name": "Sacerdotisa"}, 
		"intro": "¡Mortales! Este laberinto será vuestra tumba.", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡Sentid la oscuridad de Niflheim!", "¡NO SERÉ DERROTADO POR UN MORTAL!"], 
		"abilities": [
			{"id": "brandish", "mech": "cone", "name": "Brandish Spear", "every": 8.0, "first": 4.0, 
				"phases": [0, 1, 2], "cast": 1.1, "radius": 6.0, "angle": 1.4, "dmg": 1.7, "fx": "brandish", 
				"alert": "Brandish Spear: ¡sal del frente de Baphomet!"}, 
			{"id": "charge", "mech": "charge", "name": "Embestida", "every": 13.0, "first": 9.0, 
				"phases": [0, 1, 2], "cast": 0.8, "dmg": 1.4, "alert": "¡Embestida! Apártate de la línea"}, 
			{"id": "lov", "mech": "shield", "name": "Lord of Vermilion", "every": 30.0, "first": 16.0, 
				"phases": [0, 1, 2], "cast": 5.0, "pct": 0.85, "fx": "lord", "shield_fx": "kyrie", "lethal": true, 
				"npc_line": "¡Rápido, bajo mi Kyrie Eleison!", 
				"alert": "Lord of Vermilion: ¡entra en el Kyrie de la Sacerdotisa!"}, 
			{"id": "summon", "mech": "summon", "name": "Invocar Baphomet Jr.", "every": 22.0, "first": 11.0, 
				"phases": [0, 1, 2], "mob": "baphomet_jr", "count": 4, "alert": "Llegan los Baphomet Jr."}, 
			{"id": "curse", "mech": "cleanse", "name": "Maldición de Niflheim", "every": 26.0, "first": 6.0, 
				"phases": [1, 2], "pct": 0.025, "zone_fx": "sanctuary", 
				"npc_line": "¡Purifícate en mi Sanctuary!", 
				"alert": "Maldición: busca el Sanctuary para limpiarla"}, 
			{"id": "darkness", "mech": "rain", "name": "Oscuridad", "every": 11.0, "first": 3.0, 
				"phases": [2], "cast": 1.4, "count": 7, "size": 2.6, "dmg": 1.6, "fx": "hell_in", 
				"alert": "Oscuridad: esquiva los círculos"}, 
			{"id": "rifts", "mech": "spokes", "name": "Tajos de Niflheim", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "hell_in", "sound": "earth_quake", "alert": "Tajos de Niflheim: ¡ponte entre las grietas!"}, 
			{"id": "towers", "mech": "towers", "name": "Sellos del laberinto", "every": 30.0, "first": 16.0, 
				"phases": [0, 1, 2], "count": 3, "size": 1.8, "time": 7.0, "pct": 0.3, "fx": "lord", 
				"lethal": true, "alert": "Sellos del laberinto: ¡pisa cada sello antes de que estalle!"}, 



			{"id": "abyss_leap", "mech": "leap", "name": "Caída del Abismo", "every": 26.0, "first": 14.0, "phases": [0, 1, 2], 
				"track": 2.6, "lock": 0.8, "follow": 4.5, "size": 3.4, "dmg": 2.4, "rifts": 6, "width": 1.8, "rift_dmg": 1.4, 
				"wave": 0.9, "fx": "hell_in", "alert": "Caída del Abismo: ¡su sombra te persigue, sal de ella antes de que caiga!"}, 
		]}, 
	"eddga": {"arena": "pay_fild11", "title": "Bosque de Eddga", "color": Color(1.0, 0.55, 0.15), 
		"radius": 13.0, "hp_mult": 5.5, "pillars": {"sprite": "crystal_pillar", "count": 4, "hits": 2}, 
		"npc": {}, 
		"intro": "¡GRRRAAAH! ¡Este bosque es mío!", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡El bosque arderá contigo dentro!", "¡GRAAAAAAH!"], 
		"abilities": [
			{"id": "slam", "mech": "slam", "name": "Hammer Fall", "every": 7.0, "first": 3.0, 
				"phases": [0, 1, 2], "cast": 1.2, "count": 1, "size": 3.4, "dmg": 1.6, "stun": 1.2, 
				"fx": "stun", "alert": "Hammer Fall: ¡fuera del círculo!"}, 
			{"id": "roar", "mech": "los", "name": "Rugido Ígneo", "every": 24.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 3.5, "pct": 0.8, "fx": "firepillar", "lethal": true, 
				"alert": "Rugido Ígneo: ¡escóndete detrás de una roca!"}, 
			{"id": "summon", "mech": "summon", "name": "Llamada de la manada", "every": 20.0, "first": 8.0, 
				"phases": [0, 1, 2], "mob": ["wolf", "bigfoot"], "count": 6, "alert": "La manada de Eddga acude"}, 
			{"id": "charge", "mech": "charge", "name": "Salto del tigre", "every": 12.0, "first": 6.0, 
				"phases": [1, 2], "cast": 0.7, "dmg": 1.5, "alert": "¡Salto del tigre!"}, 
			{"id": "burn", "mech": "platforms", "name": "El bosque arde", "every": 34.0, "first": 5.0, 
				"phases": [1, 2], "cast": 4.0, "duration": 6.0, "pct": 0.1, "count": 3, "fx": "firewall", 
				"lethal": true, "alert": "¡El bosque arde! Sube a las rocas"}, 
			{"id": "rifts", "mech": "spokes", "name": "Zarpazos", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "firehit1", "sound": "fire_pillar", "alert": "Zarpazos: ¡ponte entre las grietas!"}, 
			{"id": "tether", "mech": "tether", "name": "Cadena del tigre", "every": 34.0, "first": 18.0, 
				"phases": [0, 1, 2], "duration": 9.0, "range": 6.0, "pct": 0.04, "alert": "Cadena del tigre: ¡no te alejes del tótem!"}, 
			{"id": "stalk", "mech": "snap", "mode": "stop", "name": "Acecho del tigre", "every": 27.0, "first": 15.0, "phases": [0, 1, 2], 
				"time": 3.0, "pct": 0.3, "fx": "stonecurse", "alone": true}, 
		]}, 
	"moonlight": {"arena": "pay_dun03", "title": "Cueva de Moonlight Flower", "color": Color(1.0, 0.85, 0.45), 
		"radius": 12.0, "hp_mult": 2.5, "pillars": {"sprite": "barricade", "count": 0}, 
		"npc": {}, 
		"intro": "Jijiji... ¿vienes a jugar con la Flor de la Luna?", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡La luna te hechiza!", "¡Ya no es un juego!"], 
		"abilities": [
			{"id": "fire", "mech": "rain", "name": "Fuego de zorro", "every": 8.0, "first": 3.0, 
				"phases": [0, 1, 2], "cast": 1.2, "count": 4, "size": 2.4, "dmg": 1.4, "fx": "firepillar", 
				"alert": "Fuego de zorro: esquiva los círculos"}, 
			{"id": "charm", "mech": "mark", "name": "Encanto Lunar", "every": 28.0, "first": 10.0, 
				"phases": [0, 1, 2], "duration": 11.0, "count": 4, "pct": 0.22, "fx": "moonlight_1", 
				"bubble_fx": "bubble1", "lethal": true, 
				"alert": "Encanto Lunar: ¡revienta todas las burbujas antes de que termine!"}, 
			{"id": "summon", "mech": "summon", "name": "Séquito del zorro", "every": 22.0, "first": 7.0, 
				"phases": [0, 1, 2], "mob": ["horong", "sohee"], "count": 6, "alert": "Llega el séquito"}, 
			{"id": "bell", "mech": "orb", "name": "Campana espiritual", "every": 25.0, "first": 6.0, 
				"phases": [1, 2], "duration": 13.0, "pct": 0.5, "boss_pct": 0.06, "fx": "holyhit", 
				"alert": "Campana espiritual: te persigue, ¡atráela hasta Moonlight Flower sin que te toque!"}, 
			{"id": "eggs", "mech": "eggs", "name": "Huevos de Nine Tail", "every": 30.0, "first": 14.0, 
				"phases": [2], "egg": "peco_egg", "hatch": "nine_tail", "count": 3, "time": 9.0, "hp": 0.012, 
				"alert": "¡Rompe los huevos antes de que eclosionen!"}, 
			{"id": "rifts", "mech": "spokes", "name": "Rayos de luna", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "holyhit", "sound": "angelus", "alert": "Rayos de luna: ¡ponte entre las grietas!"}, 
			{"id": "puddles", "mech": "puddles", "name": "Fuegos fatuos", "every": 24.0, "first": 10.0, 
				"phases": [0, 1, 2], "cast": 1.5, "count": 3, "size": 2.4, "duration": 12.0, "pct": 0.025, 
				"fx": "firewall", "element": "fire", "alert": "Fuegos fatuos: ¡sal del círculo, el fuego se queda!"}, 
		]}, 
	"ork_hero": {"arena": "gef_fild10", "title": "Campamento del Orc Hero", "color": Color(0.5, 0.85, 0.3), 
		"radius": 13.0, "hp_mult": 4.5, "pillars": {"sprite": "barricade", "count": 4, "hits": 3}, 
		"npc": {}, 
		"intro": "¡Humano! ¡El honor orco exige tu cabeza!", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡Arqueros! ¡Disparad!", "¡POR LA HORDA ORCA!"], 
		"abilities": [
			{"id": "cleave", "mech": "cone", "name": "Tajo del Héroe", "every": 7.0, "first": 3.0, 
				"phases": [0, 1, 2], "cast": 1.0, "radius": 5.5, "angle": 1.6, "dmg": 1.7, "fx": "brandish", 
				"alert": "Tajo del Héroe: ¡sal del frente!"}, 
			{"id": "volley", "mech": "los", "name": "Lluvia de flechas orcas", "every": 22.0, "first": 10.0, 
				"phases": [0, 1, 2], "cast": 3.5, "pct": 0.75, "fx": "pierce", "lethal": true, 
				"alert": "Lluvia de flechas: ¡cúbrete tras una barricada!"}, 


			{"id": "ritual", "mech": "eggs", "name": "Ritual de guerra", "every": 34.0, "first": 16.0, 
				"phases": [0, 1, 2], "egg": "orc_shaman", "count": 3, "time": 12.0, "hp": 0.015, 
				"boss_heal": 0.12, "chant": "¡Espíritus de la horda, dadle fuerza!", 
				"alert": "Ritual de guerra: ¡mata a los chamanes antes de que terminen!"}, 
			{"id": "summon", "mech": "summon", "name": "Grito de guerra", "every": 20.0, "first": 7.0, 
				"phases": [1, 2], "mob": ["ork_warrior", "orc_archer"], "count": 6, "alert": "¡Refuerzos orcos!"}, 
			{"id": "charge", "mech": "charge", "name": "Carga orca", "every": 11.0, "first": 5.0, 
				"phases": [2], "cast": 0.7, "dmg": 1.5, "alert": "¡Carga orca!"}, 
			{"id": "rifts", "mech": "spokes", "name": "Hachazos", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "earthhit", "sound": "earth_quake", "alert": "Hachazos: ¡ponte entre las grietas!"}, 
			{"id": "lanes", "mech": "volley", "name": "Andanada orca", "every": 22.0, "first": 13.0, 
				"phases": [0, 1, 2], "cast": 1.6, "wave": 1.2, "width": 3.0, "dmg": 1.5, "fx": "pierce", 
				"sound": "arrow_hit", "alert": "Andanada orca: ¡ponte entre las flechas!"}, 
		]}, 
	"orc_lord": {"arena": "orcsdun02", "title": "Profundidades del Orc Lord", "color": Color(0.9, 0.4, 0.2), 
		"radius": 11.0, "hp_mult": 5.0, "pillars": {"sprite": "rock_pillar", "count": 0}, 
		"npc": {}, 
		"intro": "¡Los muertos de mi clan se alzan por mí!", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡La tierra temblará!", "¡ARDED, GUSANOS!"], 
		"abilities": [
			{"id": "quake", "mech": "slam", "name": "Terremoto", "every": 8.0, "first": 3.0, 
				"phases": [0, 1, 2], "cast": 1.2, "count": 3, "size": 3.0, "dmg": 1.5, "fx": "quagmire", 
				"alert": "Terremoto: ¡fuera de los círculos!"}, 
			{"id": "bombs", "mech": "bombs", "name": "Bomb Porings", "every": 30.0, "first": 10.0, 
				"phases": [0, 1, 2], "mob": "bomb_poring", "count": 3, "time": 10.0, "hp": 0.018, "pct": 0.35, 
				"lethal": true, "alert": "¡Destruye las Bomb Poring antes de que exploten!"}, 
			{"id": "summon", "mech": "summon", "name": "Clan no-muerto", "every": 21.0, "first": 6.0, 
				"phases": [0, 1, 2], "mob": ["orc_zombie", "orc_skeleton"], "count": 6, "alert": "El clan se alza"}, 
			{"id": "lava", "mech": "platforms", "name": "Grieta de magma", "every": 32.0, "first": 6.0, 
				"phases": [1, 2], "cast": 4.0, "duration": 6.0, "pct": 0.1, "count": 3, "fx": "lava_slide", 
				"lethal": true, "alert": "¡El magma sube! Sube a los montículos"}, 
			{"id": "rifts", "mech": "spokes", "name": "Fisuras", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "firepillar", "sound": "fire_pillar", "alert": "Fisuras: ¡ponte entre las grietas!"}, 
			{"id": "wall", "mech": "wall", "name": "Ola de magma", "every": 30.0, "first": 20.0, 
				"phases": [1, 2], "count": 2, "gap": 3.4, "speed": 5.0, "lead": 1.6, "pct": 0.45, 
				"fx": "firepillar", "color": Color(1.0, 0.35, 0.1), "lethal": true, "alert": "¡Ola de magma! Cruza por el hueco"}, 
			{"id": "orders", "mech": "snap", "mode": "any", "name": "Orden del Señor Orco", "every": 27.0, "first": 14.0, "phases": [0, 1, 2], 
				"time": 3.0, "pct": 0.3, "fx": "stonecurse", "alone": true}, 
		]}, 
	"dark_lord": {"arena": "glast_01", "flat": true, "title": "Cementerio de Glast Heim", "color": Color(0.6, 0.2, 0.35), 
		"radius": 13.0, "hp_mult": 4.0, "pillars": {"sprite": "barricade", "count": 0}, 
		"npc": {"sprite": "npc_sister", "name": "Hermana"}, 
		"intro": "Glast Heim es mío... y tu alma también.", 
		"phases": [1.0, 0.65, 0.35], 
		"phase_shouts": ["", "¡Que el invierno eterno te congele!", "¡ARRODÍLLATE ANTE EL SEÑOR OSCURO!"], 
		"abilities": [
			{"id": "meteor", "mech": "shield", "name": "Meteor Storm", "every": 30.0, "first": 15.0, 
				"phases": [0, 1, 2], "cast": 5.0, "pct": 0.85, "fx": "meteor1", "shield_fx": "pneuma1", "lethal": true, 
				"npc_line": "¡Bajo mi Pneuma, rápido!", 
				"alert": "Meteor Storm: ¡entra en el Pneuma de la Hermana!"}, 
			{"id": "tombs", "mech": "eggs", "name": "Tumbas malditas", "every": 28.0, "first": 8.0, 
				"phases": [0, 1, 2], "egg": "mob_tomb", "hatch": "khalitzburg", "count": 3, "time": 10.0, "hp": 0.012, 
				"alert": "¡Destruye las tumbas antes de que se alcen los muertos!"}, 
			{"id": "soul", "mech": "orb", "name": "Alma condenada", "every": 24.0, "first": 5.0, 
				"phases": [0, 1, 2], "duration": 13.0, "pct": 0.5, "boss_pct": 0.05, "fx": "holyhit", 
				"alert": "Alma condenada: te persigue, ¡atráela hasta Dark Lord sin que te toque!"}, 
			{"id": "frost", "mech": "ice", "name": "Invierno eterno", "every": 40.0, "first": 3.0, 
				"phases": [1, 2], "duration": 14.0, "count": 3, "size": 4.5, "fx": "stormgust", 
				"alert": "Invierno eterno: ¡el suelo helado resbala!"}, 
			{"id": "hail", "mech": "rain", "name": "Lluvia de meteoros", "every": 9.0, "first": 4.0, 
				"phases": [1, 2], "cast": 1.4, "count": 5, "size": 2.8, "dmg": 1.6, "fx": "meteor1", 
				"alert": "Meteoros: esquiva los círculos"}, 
			{"id": "curse", "mech": "cleanse", "name": "Maldición", "every": 26.0, "first": 10.0, 
				"phases": [2], "pct": 0.025, "zone_fx": "sanctuary", 
				"npc_line": "¡Ven a mi Sanctuary!", "alert": "Maldición: busca el Sanctuary"}, 
			{"id": "rifts", "mech": "spokes", "name": "Lanzas de hielo", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "stormgust", "sound": "frost_diver", "alert": "Lanzas de hielo: ¡ponte entre las grietas!"}, 
			{"id": "still", "mech": "still", "mode": "still", "name": "No te detengas", "every": 30.0, "first": 14.0, 
				"phases": [0, 1, 2], "duration": 6.0, "pct": 0.06, "fx": "stormgust", "alert": "No te detengas: ¡si te quedas quieto te congelas!"}, 
			{"id": "brand", "mech": "brand", "name": "Marca Maldita", "every": 26.0, "first": 14.0, "phases": [1, 2], 
				"time": 6.0, "size": 3.7, "pct": 0.1, "fx": "hell_in", "tint": Color(0.75, 0.15, 0.35), 
				"alert": "Marca Maldita: lleva el charco lejos y déjalo ordenado en el borde"}, 
			{"id": "twilight", "mech": "polar", "name": "Juicio de la Penumbra", "every": 36.0, "first": 20.0, "phases": [1, 2], 
				"time": 5.5, "flip_time": 7.5, "flip": [], "size": 2.6, "pct": 0.6, "alone": true, "lethal": true}, 
		]}, 
	"fallen_bishop": {"arena": "abbey02", "title": "Abadía Maldita", "color": Color(0.55, 0.25, 0.6), 
		"radius": 12.0, "hp_mult": 4.5, "pillars": {"sprite": "barricade", "count": 0}, 
		"npc": {"sprite": "npc_priest", "name": "Sacerdotisa"}, 
		"intro": "Esta abadía ya no reza a ningún dios... sólo a mí.", 
		"phases": [1.0, 0.65, 0.3], 
		"phase_shouts": ["", "¡Confiesa tus pecados ante la oscuridad!", "¡RÉQUIEM PARA LOS VIVOS!"], 
		"abilities": [
			{"id": "requiem", "mech": "shield", "name": "Réquiem oscuro", "every": 30.0, "first": 14.0, 
				"phases": [0, 1, 2], "cast": 5.0, "pct": 0.85, "fx": "lord", "shield_fx": "kyrie", "lethal": true, 
				"npc_line": "¡Bajo mi Kyrie Eleison, ya!", 
				"alert": "Réquiem oscuro: ¡entra en el Kyrie de la Sacerdotisa!"}, 
			{"id": "cross", "mech": "rain", "name": "Cruz oscura", "every": 9.0, "first": 4.0, 
				"phases": [0, 1, 2], "cast": 1.3, "count": 5, "size": 2.6, "dmg": 1.6, "fx": "holyhit", 
				"alert": "Cruz oscura: sal de los círculos"}, 
			{"id": "graves", "mech": "eggs", "name": "Fosas de la abadía", "every": 28.0, "first": 9.0, 
				"phases": [0, 1, 2], "egg": "mob_tomb", "hatch": "zombie_slaughter", "count": 3, "time": 10.0, "hp": 0.012, 
				"alert": "¡Destruye las tumbas antes de que se alcen los muertos!"}, 
			{"id": "souls", "mech": "orb", "name": "Alma penitente", "every": 25.0, "first": 6.0, 
				"phases": [1, 2], "duration": 13.0, "pct": 0.5, "boss_pct": 0.05, "fx": "holyhit", 
				"alert": "Alma penitente: te persigue, ¡llévala hasta Hibram sin que te toque!"}, 
			{"id": "confession", "mech": "mark", "name": "Confesión", "every": 30.0, "first": 12.0, 
				"phases": [1, 2], "duration": 11.0, "count": 4, "pct": 0.22, "fx": "holyhit", 
				"bubble_fx": "bubble1", "lethal": true, 
				"alert": "Confesión: ¡revienta las burbujas antes de que termine!"}, 
			{"id": "summon", "mech": "summon", "name": "Coro de la abadía", "every": 20.0, "first": 7.0, 
				"phases": [1, 2], "mob": ["ragged_zombie", "banshee"], "count": 6, "alert": "Los fieles caídos se alzan"}, 
			{"id": "curse", "mech": "cleanse", "name": "Excomunión", "every": 26.0, "first": 10.0, 
				"phases": [2], "pct": 0.025, "zone_fx": "sanctuary", 
				"npc_line": "¡Ven a mi Sanctuary!", "alert": "Excomunión: busca el Sanctuary"}, 
			{"id": "rifts", "mech": "spokes", "name": "Cruces caídas", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "holy_cross", "sound": "angelus", "alert": "Cruces caídas: ¡ponte entre las grietas!"}, 
			{"id": "tether", "mech": "tether", "name": "Cadenas de penitencia", "every": 34.0, "first": 18.0, 
				"phases": [0, 1, 2], "duration": 9.0, "range": 6.0, "pct": 0.04, "alert": "Cadenas de penitencia: ¡quédate cerca del altar!"}, 
			{"id": "brand", "mech": "brand", "name": "Estigma Impuro", "every": 26.0, "first": 14.0, "phases": [1, 2], 
				"time": 6.0, "size": 3.7, "pct": 0.1, "fx": "holyhit", "tint": Color(0.55, 0.25, 0.65), 
				"alert": "Estigma Impuro: deja el charco lejos, en el borde"}, 
		]}, 
	"beelzebub": {"arena": "abbey03", "title": "Santuario de Beelzebub", "color": Color(0.55, 0.45, 0.2), 
		"radius": 12.0, "hp_mult": 4.8, "pillars": {"sprite": "rock_pillar", "count": 4, "hits": 2}, 
		"npc": {"sprite": "npc_priest", "name": "Sacerdotisa"}, 
		"intro": "Bzzz... El Señor de las Moscas ha despertado. Tu carne será su festín.", 
		"phases": [1.0, 0.65, 0.3], 
		"phase_shouts": ["", "¡Que el enjambre te devore!", "¡SOY EL SEÑOR DE LAS MOSCAS!"], 
		"abilities": [
			{"id": "swarm", "mech": "summon", "name": "Enjambre", "every": 16.0, "first": 5.0, 
				"phases": [0, 1, 2], "mob": ["hunter_fly", "hunter_fly", "rideword"], "count": 8, "alert": "¡El enjambre de Beelzebub!"}, 
			{"id": "plague", "mech": "los", "name": "Plaga de moscas", "every": 26.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 3.5, "pct": 0.8, "fx": "poisonzone", "lethal": true, 
				"alert": "Plaga de moscas: ¡escóndete detrás de una roca!"}, 
			{"id": "hellfire", "mech": "rain", "name": "Fuego infernal", "every": 9.0, "first": 4.0, 
				"phases": [0, 1, 2], "cast": 1.3, "count": 5, "size": 2.6, "dmg": 1.7, "fx": "firepillar", 
				"alert": "Fuego infernal: sal de los círculos"}, 
			{"id": "devour", "mech": "mark", "name": "Banquete", "every": 30.0, "first": 14.0, 
				"phases": [1, 2], "duration": 11.0, "count": 4, "pct": 0.22, "fx": "poisonzone", 
				"bubble_fx": "bubble1", "lethal": true, 
				"alert": "Banquete: ¡revienta las burbujas antes de que te devore!"}, 
			{"id": "dive", "mech": "charge", "name": "Picada del Señor", "every": 11.0, "first": 6.0, 
				"phases": [1, 2], "cast": 0.7, "dmg": 1.6, "alert": "¡Picada! Apártate de la línea"}, 
			{"id": "rot", "mech": "cleanse", "name": "Podredumbre", "every": 26.0, "first": 10.0, 
				"phases": [2], "pct": 0.025, "zone_fx": "sanctuary", 
				"npc_line": "¡Ven a mi Sanctuary!", "alert": "Podredumbre: busca el Sanctuary"}, 
			{"id": "rifts", "mech": "spokes", "name": "Picaduras", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "poisonzone", "sound": "earth_spike", "alert": "Picaduras: ¡ponte entre las grietas!"}, 
			{"id": "wall", "mech": "wall", "name": "Muro del enjambre", "every": 30.0, "first": 20.0, 
				"phases": [1, 2], "count": 2, "gap": 3.4, "speed": 5.0, "lead": 1.6, "pct": 0.45, 
				"fx": "poisonzone", "color": Color(0.62, 0.22, 0.7), "lethal": true, "alert": "¡Muro del enjambre! Cruza por el hueco"}, 
			{"id": "vortex", "mech": "vortex", "name": "Vórtice del Señor de las Moscas", "every": 24.0, "first": 10.0, "phases": [1, 2], 
				"duration": 5.5, "from": 1.5, "size": 6.5, "pull": 0.5, "pct": 0.06, "fx": "poisonzone", 
				"alert": "Vórtice: ¡te absorbe! Sal antes de que el círculo te alcance"}, 
			{"id": "hell_judge", "mech": "doom", "name": "Juicio del Infierno", "every": 46.0, "first": 24.0, "phases": [1, 2], 
				"charge": 3.0, "time": 4.0, "pct": 0.3, "heal": 0.5, "alone": true, "lethal": true}, 
		]}, 
	"golden_bug": {"arena": "prt_sewb4", "title": "Nido del Golden Thief Bug", "color": Color(1.0, 0.8, 0.3), 
		"radius": 12.0, "hp_mult": 4.2, "pillars": {"sprite": "barricade", "count": 0}, 
		"npc": {}, 
		"intro": "¡Bzzz! ¡Todo el oro de Prontera es mío!", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡Mi caparazón de oro brilla!", "¡BZZZZZT!"], 
		"abilities": [
			{"id": "rain", "mech": "rain", "name": "Lluvia de fuego", "every": 8.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.2, "count": 5, "size": 2.4, "dmg": 1.4, "fx": "firepillar", "alert": "Lluvia de fuego: esquiva los círculos"}, 
			{"id": "charge", "mech": "charge", "name": "Embestida dorada", "every": 12.0, "first": 6.0, "phases": [0, 1, 2], "cast": 0.8, "dmg": 1.5, "alert": "¡Embestida! Apártate de la línea"}, 
			{"id": "summon", "mech": "summon", "name": "Enjambre", "every": 18.0, "first": 9.0, "phases": [0, 1, 2], "mob": ["thief_bug", "cramp"], "count": 8, "alert": "¡Llega el enjambre!"}, 
			{"id": "bombs", "mech": "bombs", "name": "Huevos explosivos", "every": 30.0, "first": 14.0, "phases": [1, 2], "mob": "bomb_poring", "count": 3, "time": 10.0, "hp": 0.018, "pct": 0.3, "lethal": true, "alert": "¡Destruye los huevos antes de que estallen!"}, 
			{"id": "rifts", "mech": "spokes", "name": "Destellos dorados", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "firehit1", "sound": "fire_pillar", "alert": "Destellos dorados: ¡ponte entre las grietas!"}, 
			{"id": "puddles", "mech": "puddles", "name": "Fuego dorado", "every": 24.0, "first": 10.0, 
				"phases": [0, 1, 2], "cast": 1.5, "count": 3, "size": 2.4, "duration": 12.0, "pct": 0.025, 
				"fx": "firewall", "element": "fire", "alert": "Fuego dorado: ¡sal del círculo, el fuego se queda!"}, 
			{"id": "glint", "mech": "snap", "mode": "stop", "name": "Brillo hipnótico", "every": 27.0, "first": 15.0, "phases": [0, 1, 2], 
				"time": 3.0, "pct": 0.3, "fx": "stonecurse", "alone": true}, 
		]}, 
	"kraken": {"arena": "iz_dun01", "flat": true, "title": "Profundidades de Byalan", "color": Color(0.45, 0.6, 1.0), 
		"radius": 12.0, "hp_mult": 4.2, "pillars": {"sprite": "crystal_pillar", "count": 4, "hits": 3}, 
		"npc": {}, 
		"intro": "Las mareas te arrastrarán al fondo...", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡El océano entero me obedece!", "¡AHOGAOS!"], 
		"abilities": [
			{"id": "slam", "mech": "slam", "name": "Tentáculo", "every": 7.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.1, "count": 2, "size": 3.0, "dmg": 1.6, "stun": 1.0, "fx": "stormgust", "alert": "Tentáculos: ¡fuera de los círculos!"}, 
			{"id": "wave", "mech": "los", "name": "Maremoto", "every": 24.0, "first": 12.0, "phases": [0, 1, 2], "cast": 3.5, "pct": 0.8, "fx": "stormgust", "lethal": true, "alert": "Maremoto: ¡escóndete detrás de un cristal!"}, 
			{"id": "summon", "mech": "summon", "name": "Criaturas del fondo", "every": 20.0, "first": 8.0, "phases": [0, 1, 2], "mob": ["marina", "hydra", "marine_sphere"], "count": 7, "alert": "Las criaturas del fondo acuden"}, 
			{"id": "ice", "mech": "ice", "name": "Agua helada", "every": 40.0, "first": 16.0, "phases": [1, 2], "duration": 12.0, "count": 3, "size": 4.5, "fx": "stormgust", "alert": "¡El agua se congela! El suelo resbala"}, 
			{"id": "rifts", "mech": "spokes", "name": "Tentáculos", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "stormgust", "sound": "frost_diver", "alert": "Tentáculos: ¡ponte entre las grietas!"}, 
			{"id": "wall", "mech": "wall", "name": "Maremoto", "every": 30.0, "first": 20.0, 
				"phases": [1, 2], "count": 2, "gap": 3.4, "speed": 5.0, "lead": 1.6, "pct": 0.45, 
				"fx": "stormgust", "color": Color(0.3, 0.6, 1.0), "lethal": true, "alert": "¡Maremoto! Cruza por el hueco de la ola"}, 
			{"id": "vortex", "mech": "vortex", "name": "Remolino de Byalan", "every": 24.0, "first": 8.0, "phases": [1, 2], 
				"duration": 5.5, "from": 1.5, "size": 7.0, "pull": 0.5, "pct": 0.06, "fx": "stormgust", 
				"alert": "Remolino: ¡te arrastra! Corre lejos del Kraken"}, 
			{"id": "abyss_eye", "mech": "snap", "mode": "any", "name": "Ojo del abismo", "every": 27.0, "first": 14.0, "phases": [0, 1, 2], 
				"time": 3.0, "pct": 0.3, "fx": "stonecurse", "alone": true}, 
		]}, 
	"turtle_general": {"arena": "tur_dun02", "flat": true, "title": "Fortaleza de Turtle General", "color": Color(0.55, 0.75, 0.35), 
		"radius": 12.0, "hp_mult": 4.2, "pillars": {"sprite": "rock_pillar", "count": 4, "hits": 3}, 
		"npc": {}, 
		"intro": "¡Ningún humano pisará mi isla!", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡Caparazones, formación!", "¡POR LA ISLA!"], 
		"abilities": [
			{"id": "starfall", "mech": "starfall", "name": "Caparazones de Fuego", "every": 22.0, "first": 14.0, "phases": [0, 1, 2], 
				"count": 6, "step": 0.55, "size": 2.4, "dmg": 1.5, "fx": "meteor1", 
				"alert": "Caparazones de Fuego: ¡no dejes de correr, los caparazones te siguen!"}, 
			{"id": "cleave", "mech": "cone", "name": "Tajo del general", "every": 7.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.0, "radius": 5.5, "angle": 1.5, "dmg": 1.7, "fx": "brandish", "alert": "Tajo del general: ¡sal del frente!"}, 
			{"id": "quake", "mech": "los", "name": "Terremoto", "every": 22.0, "first": 10.0, "phases": [0, 1, 2], "cast": 3.5, "pct": 0.75, "fx": "quagmire", "lethal": true, "alert": "Terremoto: ¡cúbrete tras una roca!"}, 
			{"id": "summon", "mech": "summon", "name": "Guardia tortuga", "every": 19.0, "first": 7.0, "phases": [0, 1, 2], "mob": ["solider", "permeter", "freezer", "heater"], "count": 7, "alert": "¡La guardia tortuga acude!"}, 
			{"id": "charge", "mech": "charge", "name": "Embestida de caparazón", "every": 11.0, "first": 5.0, "phases": [1, 2], "cast": 0.7, "dmg": 1.5, "alert": "¡Embestida!"}, 
			{"id": "rifts", "mech": "spokes", "name": "Grietas de roca", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "quagmire", "sound": "earth_quake", "alert": "Grietas de roca: ¡ponte entre las grietas!"}, 
			{"id": "still", "mech": "still", "mode": "move", "name": "Terremoto: ¡quieto!", "every": 30.0, "first": 14.0, 
				"phases": [0, 1, 2], "duration": 6.0, "pct": 0.06, "fx": "earthhit", "alert": "Terremoto: ¡no te muevas o caerás!"}, 
		]}, 
	"osiris": {"arena": "moc_pryd04", "flat": 1.6, "title": "Cámara de Osiris", "color": Color(0.95, 0.8, 0.4), 
		"radius": 12.0, "hp_mult": 4.2, "pillars": {"sprite": "barricade", "count": 0}, 
		"npc": {"sprite": "npc_priest", "name": "Sacerdotisa"}, 
		"intro": "¿Quién osa perturbar el descanso del faraón?", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡La maldición de la pirámide!", "¡MI REINO ES ETERNO!"], 
		"abilities": [
			{"id": "rain", "mech": "rain", "name": "Arenas malditas", "every": 9.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.3, "count": 6, "size": 2.5, "dmg": 1.5, "fx": "hell_in", "alert": "Arenas malditas: esquiva los círculos"}, 
			{"id": "curse", "mech": "cleanse", "name": "Maldición del faraón", "every": 26.0, "first": 8.0, "phases": [0, 1, 2], "pct": 0.025, "zone_fx": "sanctuary", "alert": "Maldición: busca la zona sagrada para limpiarla"}, 
			{"id": "summon", "mech": "summon", "name": "Despertar de las momias", "every": 20.0, "first": 10.0, "phases": [0, 1, 2], "mob": ["mummy", "isis"], "count": 7, "alert": "Las momias despiertan"}, 
			{"id": "soul", "mech": "orb", "name": "Alma del faraón", "every": 25.0, "first": 14.0, "phases": [1, 2], "duration": 13.0, "pct": 0.5, "boss_pct": 0.05, "fx": "holyhit", "alert": "Alma del faraón: te persigue, ¡llévala hasta Osiris sin que te toque!"}, 
			{"id": "rifts", "mech": "spokes", "name": "Maldición del desierto", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "hell_in", "sound": "earth_spike", "alert": "Maldición del desierto: ¡ponte entre las grietas!"}, 
			{"id": "wall", "mech": "wall", "name": "Tormenta de arena", "every": 30.0, "first": 20.0, 
				"phases": [1, 2], "count": 2, "gap": 3.4, "speed": 5.0, "lead": 1.6, "pct": 0.45, 
				"fx": "quagmire", "color": Color(0.95, 0.8, 0.45), "lethal": true, "alert": "¡Tormenta de arena! Cruza por el hueco"}, 
			{"id": "brand", "mech": "brand", "name": "Maldición del Faraón", "every": 26.0, "first": 14.0, "phases": [1, 2], 
				"time": 6.0, "size": 3.7, "pct": 0.1, "fx": "hell_in", "tint": Color(0.85, 0.65, 0.2), 
				"alert": "Maldición del Faraón: deja las arenas malditas lejos, en el borde"}, 
		]}, 
	"maya": {"arena": "anthell02", "title": "Nido de Maya", "color": Color(0.8, 0.6, 0.35), 
		"radius": 12.0, "hp_mult": 4.2, "pillars": {"sprite": "rock_pillar", "count": 4, "hits": 3}, 
		"npc": {}, 
		"intro": "Mis hijas te devorarán, intruso.", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡La colonia despierta!", "¡POR LA REINA!"], 
		"abilities": [
			{"id": "starfall", "mech": "starfall", "name": "Lluvia del Hormiguero", "every": 22.0, "first": 14.0, "phases": [0, 1, 2], 
				"count": 6, "step": 0.55, "size": 2.4, "dmg": 1.5, "fx": "meteor1", 
				"alert": "Lluvia del Hormiguero: ¡no dejes de correr, la tierra te sigue!"}, 
			{"id": "slam", "mech": "slam", "name": "Golpe de la reina", "every": 7.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.2, "count": 3, "size": 3.0, "dmg": 1.5, "stun": 1.0, "fx": "quagmire", "alert": "Golpe de la reina: ¡fuera de los círculos!"}, 
			{"id": "acid", "mech": "los", "name": "Ácido", "every": 24.0, "first": 12.0, "phases": [0, 1, 2], "cast": 3.5, "pct": 0.8, "fx": "poisonzone", "lethal": true, "alert": "Ácido: ¡escóndete detrás de una roca!"}, 
			{"id": "summon", "mech": "summon", "name": "La colonia", "every": 18.0, "first": 8.0, "phases": [0, 1, 2], "mob": ["andre", "vitata", "piere"], "count": 8, "alert": "¡La colonia acude!"}, 
			{"id": "charge", "mech": "charge", "name": "Embestida", "every": 12.0, "first": 6.0, "phases": [1, 2], "cast": 0.8, "dmg": 1.5, "alert": "¡Embestida! Apártate de la línea"}, 
			{"id": "rifts", "mech": "spokes", "name": "Patas de la reina", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "earthhit", "sound": "earth_quake", "alert": "Patas de la reina: ¡ponte entre las grietas!"}, 
			{"id": "towers", "mech": "towers", "name": "Nidos", "every": 30.0, "first": 16.0, 
				"phases": [0, 1, 2], "count": 3, "size": 1.8, "time": 7.0, "pct": 0.3, "fx": "poisonzone", 
				"lethal": true, "alert": "Nidos: ¡pisa cada nido antes de que eclosione!"}, 
			{"id": "cave_in", "mech": "snap", "mode": "move", "name": "Derrumbe del hormiguero", "every": 27.0, "first": 18.0, "phases": [0, 1, 2], 
				"time": 3.0, "pct": 0.3, "fx": "earthhit", "alone": true}, 
		]}, 
	"mistress": {"arena": "mjo_dun02", "title": "Panal de Mistress", "color": Color(1.0, 0.85, 0.3), 
		"radius": 12.0, "hp_mult": 4.2, "pillars": {"sprite": "barricade", "count": 0}, 
		"npc": {}, 
		"intro": "Zzz... ¡nadie toca mi miel!", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡Mis abejas, al ataque!", "¡ZZZZZZ!"], 
		"abilities": [
			{"id": "starfall", "mech": "starfall", "name": "Enjambre Real", "every": 22.0, "first": 14.0, "phases": [0, 1, 2], 
				"count": 6, "step": 0.55, "size": 2.4, "dmg": 1.5, "fx": "meteor1", 
				"alert": "Enjambre Real: ¡no dejes de correr, el enjambre te sigue!"}, 
			{"id": "rain", "mech": "rain", "name": "Lluvia de aguijones", "every": 8.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.1, "count": 6, "size": 2.3, "dmg": 1.4, "fx": "holyhit", "alert": "Aguijones: esquiva los círculos"}, 
			{"id": "mark", "mech": "mark", "name": "Veneno real", "every": 28.0, "first": 10.0, "phases": [0, 1, 2], "duration": 11.0, "count": 4, "pct": 0.22, "fx": "poisonzone", "bubble_fx": "bubble1", "lethal": true, "alert": "Veneno real: ¡revienta las burbujas antes de que acabe!"}, 
			{"id": "summon", "mech": "summon", "name": "Enjambre", "every": 18.0, "first": 7.0, "phases": [0, 1, 2], "mob": ["hornet", "giant_hornet"], "count": 8, "alert": "¡Llega el enjambre!"}, 
			{"id": "charge", "mech": "charge", "name": "Picado", "every": 11.0, "first": 5.0, "phases": [1, 2], "cast": 0.7, "dmg": 1.5, "alert": "¡Picado!"}, 
			{"id": "rifts", "mech": "spokes", "name": "Relámpagos", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "lightning", "sound": "thunder", "alert": "Relámpagos: ¡ponte entre las grietas!"}, 
			{"id": "volley", "mech": "volley", "name": "Lluvia de aguijones", "every": 22.0, "first": 13.0, 
				"phases": [0, 1, 2], "cast": 1.6, "wave": 1.2, "width": 3.0, "dmg": 1.5, "fx": "pierce", 
				"sound": "arrow_hit", "alert": "Lluvia de aguijones: ¡ponte entre las líneas!"}, 
			{"id": "buzz", "mech": "snap", "mode": "any", "name": "Zumbido de la reina", "every": 27.0, "first": 16.0, "phases": [0, 1, 2], 
				"time": 3.0, "pct": 0.3, "fx": "stonecurse", "alone": true}, 
		]}, 
	"owl_baron": {"arena": "alde_dun02", "title": "Sótano de la Torre del Reloj", "color": Color(0.6, 0.5, 0.9), 
		"radius": 12.0, "hp_mult": 4.2, "pillars": {"sprite": "crystal_pillar", "count": 4, "hits": 3}, 
		"npc": {}, 
		"intro": "El tiempo se detiene... para ti.", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡Tic, tac!", "¡TU HORA HA LLEGADO!"], 
		"abilities": [
			{"id": "rain", "mech": "rain", "name": "Engranajes", "every": 8.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.2, "count": 5, "size": 2.4, "dmg": 1.5, "fx": "stun", "alert": "Engranajes: esquiva los círculos"}, 
			{"id": "bolt", "mech": "los", "name": "Tormenta de rayos", "every": 24.0, "first": 12.0, "phases": [0, 1, 2], "cast": 3.5, "pct": 0.8, "fx": "lord", "lethal": true, "alert": "Tormenta: ¡escóndete detrás de un cristal!"}, 
			{"id": "summon", "mech": "summon", "name": "Juguetes", "every": 19.0, "first": 8.0, "phases": [0, 1, 2], "mob": ["alarm", "punk"], "count": 7, "alert": "Los juguetes cobran vida"}, 
			{"id": "orb", "mech": "orb", "name": "Reloj de arena", "every": 26.0, "first": 15.0, "phases": [1, 2], "duration": 13.0, "pct": 0.5, "boss_pct": 0.05, "fx": "holyhit", "alert": "Reloj de arena: te persigue, ¡llévalo hasta el Owl Baron sin que te toque!"}, 
			{"id": "rifts", "mech": "spokes", "name": "Agujas", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "lightning", "sound": "thunder", "alert": "Agujas: ¡ponte entre las grietas!"}, 
			{"id": "clock", "mech": "clock", "name": "Hora final", "every": 32.0, "first": 15.0, 
				"phases": [0, 1, 2], "step": 0.8, "dmg": 1.6, "fx": "thunderstorm", "lethal": true, "alert": "Hora final: ¡sigue a las agujas del reloj!"}, 
		]}, 
	"lord_of_death": {"arena": "nif_fild01", "title": "Campos de Niflheim", "color": Color(0.55, 0.3, 0.7), 
		"radius": 13.0, "hp_mult": 4.2, "pillars": {"sprite": "barricade", "count": 0}, 
		"npc": {"sprite": "npc_priest", "name": "Sacerdotisa"}, 
		"intro": "Bienvenido a mi reino, mortal. Nunca saldrás.", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡Los muertos te reclaman!", "¡ARRODÍLLATE ANTE LA MUERTE!"], 
		"abilities": [
			{"id": "cone", "mech": "cone", "name": "Guadaña", "every": 7.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.0, "radius": 6.0, "angle": 1.5, "dmg": 1.8, "fx": "brandish", "alert": "Guadaña: ¡sal del frente!"}, 
			{"id": "dark", "mech": "shield", "name": "Oscuridad eterna", "every": 30.0, "first": 16.0, "phases": [0, 1, 2], "cast": 5.0, "pct": 0.85, "fx": "lord", "shield_fx": "kyrie", "lethal": true, "npc_line": "¡Rápido, bajo mi Kyrie Eleison!", "alert": "Oscuridad eterna: ¡entra en el Kyrie!"}, 
			{"id": "summon", "mech": "summon", "name": "Almas en pena", "every": 20.0, "first": 9.0, "phases": [0, 1, 2], "mob": ["quve", "loli_ruri"], "count": 7, "alert": "Las almas en pena acuden"}, 
			{"id": "curse", "mech": "cleanse", "name": "Maldición de Niflheim", "every": 26.0, "first": 6.0, "phases": [1, 2], "pct": 0.025, "zone_fx": "sanctuary", "npc_line": "¡Purifícate en mi Sanctuary!", "alert": "Maldición: busca el Sanctuary"}, 
			{"id": "rifts", "mech": "spokes", "name": "Guadañas", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "hell_in", "sound": "earth_spike", "alert": "Guadañas: ¡ponte entre las grietas!"}, 
			{"id": "sweep", "mech": "sweep", "name": "Guadaña giratoria", "every": 28.0, "first": 18.0, 
				"phases": [1, 2], "cast": 1.8, "turn": 4.7, "time": 5.0, "width": 2.2, "dmg": 1.8, 
				"fx": "hell_in", "alert": "Guadaña giratoria: ¡síguela por detrás, donde ya pasó!"}, 
			{"id": "vortex", "mech": "vortex", "name": "Abrazo de la Muerte", "every": 26.0, "first": 12.0, "phases": [1, 2], 
				"duration": 6.0, "from": 1.5, "size": 7.5, "pull": 0.5, "pct": 0.06, "fx": "hell_in", 
				"alert": "Abrazo de la Muerte: ¡te arrastra hacia él! Corre"}, 
			{"id": "brand", "mech": "brand", "name": "Marca del Segador", "every": 28.0, "first": 18.0, "phases": [2], 
				"time": 6.0, "size": 3.7, "pct": 0.1, "fx": "hell_in", "tint": Color(0.6, 0.3, 0.85), 
				"alert": "Marca del Segador: deja su charco lejos, en el borde"}, 
			{"id": "reaper_guard", "mech": "guard", "name": "Guardia del Segador", "every": 32.0, "first": 20.0, "phases": [0, 1, 2], 
				"duration": 9.0, "arc": 2.6, "turn": 0.9}, 
			{"id": "hell_judge", "mech": "doom", "name": "Juicio del Infierno", "every": 46.0, "first": 28.0, "phases": [1, 2], 
				"charge": 3.0, "time": 4.0, "pct": 0.3, "heal": 0.5, "alone": true, "lethal": true}, 
		]}, 
	"apocalips": {"arena": "jupe_core", "title": "Núcleo de Juperos", "color": Color(0.5, 0.6, 0.75), 
		"radius": 12.0, "hp_mult": 4.2, "pillars": {"sprite": "rock_pillar", "count": 4, "hits": 3}, 
		"npc": {}, 
		"intro": "INTRUSO DETECTADO. ELIMINANDO.", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "MODO DE COMBATE ACTIVADO.", "SOBRECARGA DEL NÚCLEO."], 
		"abilities": [
			{"id": "slam", "mech": "slam", "name": "Puño de acero", "every": 7.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.1, "count": 3, "size": 3.0, "dmg": 1.6, "stun": 1.0, "fx": "quagmire", "alert": "Puño de acero: ¡fuera de los círculos!"}, 
			{"id": "laser", "mech": "los", "name": "Rayo del núcleo", "every": 22.0, "first": 10.0, "phases": [0, 1, 2], "cast": 3.5, "pct": 0.8, "fx": "lord", "lethal": true, "alert": "Rayo del núcleo: ¡cúbrete tras una roca!"}, 
			{"id": "summon", "mech": "summon", "name": "Unidades de defensa", "every": 20.0, "first": 8.0, "phases": [0, 1, 2], "mob": ["venatu_1", "dimik_1"], "count": 7, "alert": "Unidades de defensa activadas"}, 
			{"id": "bombs", "mech": "bombs", "name": "Minas", "every": 30.0, "first": 14.0, "phases": [1, 2], "mob": "bomb_poring", "count": 3, "time": 10.0, "hp": 0.018, "pct": 0.35, "lethal": true, "alert": "¡Destruye las minas antes de que exploten!"}, 
			{"id": "rifts", "mech": "spokes", "name": "Láseres", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "lightning", "sound": "thunder", "alert": "Láseres: ¡ponte entre las grietas!"}, 
			{"id": "sweep", "mech": "sweep", "name": "Rayo del núcleo", "every": 28.0, "first": 18.0, 
				"phases": [1, 2], "cast": 1.8, "turn": 4.7, "time": 5.0, "width": 2.2, "dmg": 1.8, 
				"fx": "lightning", "alert": "Rayo del núcleo: ¡síguelo por detrás, donde ya pasó!"}, 
			{"id": "shutdown", "mech": "runes", "name": "Código de apagado", "every": 48.0, "first": 22.0, "phases": [1, 2], 
				"count": 4, "show": 1.0, "time": 14.0, "pct": 0.5, "stagger": 6.0, "vuln": 0.5, "fx": "lightning", "alone": true, "lethal": true}, 
		]}, 
	"knight_of_windstorm": {"arena": "xmas_dun01", "flat": true, "title": "Fábrica de Juguetes", "color": Color(0.6, 0.85, 1.0), 
		"radius": 12.0, "hp_mult": 4.2, "pillars": {"sprite": "crystal_pillar", "count": 4, "hits": 3}, 
		"npc": {}, 
		"intro": "La tormenta no conoce la Navidad.", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡Que ruja la ventisca!", "¡INVIERNO SIN FIN!"], 
		"abilities": [
			{"id": "lance", "mech": "cone", "name": "Lanza de la tormenta", "every": 7.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.0, "radius": 6.0, "angle": 1.4, "dmg": 1.7, "fx": "stormgust", "alert": "Lanza de la tormenta: ¡sal del frente!"}, 
			{"id": "charge", "mech": "charge", "name": "Carga del viento", "every": 12.0, "first": 6.0, "phases": [0, 1, 2], "cast": 0.8, "dmg": 1.5, "alert": "¡Carga del viento! Apártate de la línea"}, 
			{"id": "gust", "mech": "los", "name": "Storm Gust", "every": 24.0, "first": 12.0, "phases": [0, 1, 2], "cast": 3.5, "pct": 0.8, "fx": "stormgust", "lethal": true, "alert": "Storm Gust: ¡cúbrete tras un cristal!"}, 
			{"id": "summon", "mech": "summon", "name": "Juguetes de guardia", "every": 20.0, "first": 8.0, "phases": [0, 1, 2], "mob": ["garm_baby", "mystcase"], "count": 7, "alert": "¡Los juguetes despiertan!"}, 
			{"id": "rifts", "mech": "spokes", "name": "Ventiscas", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "stormgust", "sound": "frost_diver", "alert": "Ventiscas: ¡ponte entre las grietas!"}, 
			{"id": "frost", "mech": "ice", "name": "Suelo congelado", "every": 36.0, "first": 16.0, 
				"phases": [1, 2], "duration": 14.0, "count": 3, "size": 4.5, "fx": "stormgust", 
				"alert": "Suelo congelado: ¡el hielo resbala!"}, 
			{"id": "wall", "mech": "wall", "name": "Muro de la tormenta", "every": 30.0, "first": 20.0, 
				"phases": [1, 2], "count": 2, "gap": 3.4, "speed": 5.0, "lead": 1.6, "pct": 0.45, 
				"fx": "stormgust", "color": Color(0.55, 0.85, 1.0), "lethal": true, "alert": "¡Muro de la tormenta! Cruza por el hueco"}, 
			{"id": "storm_guard", "mech": "guard", "name": "Guardia de la tormenta", "every": 32.0, "first": 16.0, "phases": [0, 1, 2], 
				"duration": 9.0, "arc": 2.6, "turn": 0.9}, 
		]}, 
	"thanatos": {"arena": "thana_boss", "title": "La cima de Thanatos", "color": Color(0.55, 0.3, 0.75), 
		"radius": 12.0, "hp_mult": 4.4, "pillars": {"sprite": "rock_pillar", "count": 4, "hits": 3}, 
		"npc": {"sprite": "npc_priest", "name": "Sacerdotisa"}, 
		"intro": "Recuerda... lo que es morir.", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "Tu alma ya me pertenece.", "¡TODO ACABA EN MÍ!"], 
		"abilities": [
			{"id": "scythe", "mech": "cone", "name": "Guadaña de la muerte", "every": 7.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.0, "radius": 6.5, "angle": 1.6, "dmg": 1.8, "fx": "hell_in", "alert": "Guadaña de la muerte: ¡sal del frente!"}, 
			{"id": "rain", "mech": "rain", "name": "Almas en pena", "every": 9.0, "first": 4.0, "phases": [0, 1, 2], "cast": 1.2, "count": 5, "size": 2.4, "dmg": 1.5, "fx": "hell_in", "alert": "Almas en pena: esquiva los círculos"}, 
			{"id": "curse", "mech": "cleanse", "name": "Maldición de Thanatos", "every": 26.0, "first": 8.0, 
				"phases": [0, 1, 2], "pct": 0.025, "zone_fx": "sanctuary", 
				"npc_line": "¡Purifícate en mi Sanctuary!", 
				"alert": "Maldición de Thanatos: busca el Sanctuary para limpiarla"}, 
			{"id": "rifts", "mech": "spokes", "name": "Lamentos", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "hell_in", "sound": "earth_spike", "alert": "Lamentos: ¡ponte entre las grietas!"}, 
			{"id": "souls", "mech": "towers", "name": "Sellos del alma", "every": 30.0, "first": 18.0, 
				"phases": [1, 2], "count": 3, "size": 1.8, "time": 7.0, "pct": 0.3, "fx": "lord", 
				"lethal": true, "alert": "Sellos del alma: ¡pisa cada sello antes de que estalle!"}, 
			{"id": "chain", "mech": "tether", "name": "Cadena de almas", "every": 34.0, "first": 22.0, 
				"phases": [1, 2], "duration": 9.0, "range": 6.0, "pct": 0.04, "alert": "Cadena de almas: ¡no te alejes del tótem!"}, 
			{"id": "soul_judge", "mech": "polar", "name": "Juicio de las Almas", "every": 36.0, "first": 15.0, "phases": [0, 1, 2], 
				"time": 5.5, "flip_time": 7.5, "flip": [2], "size": 2.6, "pct": 0.6, "alone": true, "lethal": true}, 
			{"id": "memories", "mech": "runes", "name": "Recuerdos de Thanatos", "every": 48.0, "first": 26.0, "phases": [1, 2], 
				"count": 4, "show": 1.0, "time": 14.0, "pct": 0.5, "stagger": 6.0, "vuln": 0.5, "fx": "hell_in", "alone": true, "lethal": true}, 
		]}, 


	"reginleif": {"arena": "odin_past", "flat": true, "title": "Valhalla de antaño", "color": Color(1.0, 0.9, 0.55), 
		"boss_hp": 1.2, "boss_dmg": 1.15, "aura": {"fx": "holyhit", "every": 1.4, "color": Color(1.0, 0.9, 0.55, 0.7)}, 
		"radius": 15.0, "hp_mult": 5.0, "pillars": {"sprite": "crystal_pillar", "count": 4, "hits": 3}, 
		"npc": {}, 
		"intro": "Has caminado por la luz. Ahora demuestra que la mereces.", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡Einherjar, a mí!", "¡POR ODIN Y POR VALHALLA!"], 
		"abilities": [
			{"id": "spear", "mech": "cone", "name": "Lanza del Juicio", "every": 7.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.0, 
				"radius": 7.0, "angle": 1.3, "dmg": 1.8, "fx": "holyhit", "alert": "Lanza del Juicio: ¡sal del frente de Reginleif!"}, 
			{"id": "spears", "mech": "volley", "name": "Lanzas de Valhalla", "every": 15.0, "first": 6.0, "phases": [0, 1, 2], 
				"cast": 1.4, "wave": 1.0, "width": 2.6, "dmg": 1.5, "fx": "holyhit", "sound": "angelus", 
				"alert": "Lanzas de Valhalla: ¡ponte entre las lanzas!"}, 
			{"id": "pillars", "mech": "rain", "name": "Columnas de luz", "every": 11.0, "first": 9.0, "phases": [1, 2], "cast": 1.2, 
				"count": 6, "size": 2.4, "dmg": 1.5, "fx": "holyhit", "alert": "Columnas de luz: esquiva los círculos"}, 
			{"id": "starfall", "mech": "starfall", "name": "Caída de Valhalla", "every": 22.0, "first": 12.0, "phases": [0, 1, 2], 
				"count": 6, "step": 0.55, "size": 2.4, "dmg": 1.5, "fx": "meteor1", 
				"alert": "Caída de Valhalla: ¡no dejes de correr, los meteoros te siguen!"}, 
			{"id": "judgment", "mech": "los", "name": "Juicio de Valhalla", "every": 30.0, "first": 16.0, "phases": [0, 1, 2], 
				"cast": 3.5, "pct": 0.8, "fx": "magnus", "lethal": true, "alert": "Juicio de Valhalla: ¡escóndete detrás de un cristal!"}, 
			{"id": "aegis", "mech": "break", "name": "Égida de las Valkyrias", "every": 34.0, "first": 22.0, "phases": [1, 2], 
				"time": 12.0, "count": 3, "mob": "raydric", "hp": 0.025, "stagger": 7.0, "vuln": 0.6, "pct": 0.45, 
				"fx": "holyhit", "aura": "kyrie", "lethal": true, 
				"alert": "Égida de las Valkyrias: ¡derriba a los portaestandartes y rompe su escudo!"}, 
			{"id": "einherjar", "mech": "summon", "name": "Einherjar", "every": 22.0, "first": 8.0, "phases": [1, 2], 
				"mob": ["raydric", "bloody_knight"], "count": 5, "alert": "¡Los Einherjar acuden a Reginleif!"}, 
			{"id": "seals", "mech": "towers", "name": "Sellos de Asgard", "every": 30.0, "first": 18.0, 
				"phases": [2], "count": 3, "size": 1.8, "time": 7.0, "pct": 0.3, "fx": "holyhit", 
				"lethal": true, "alert": "Sellos de Asgard: ¡pisa cada sello antes de que estalle!"}, 
			{"id": "charge", "mech": "charge", "name": "Vuelo de la Valkyria", "every": 12.0, "first": 5.0, 
				"phases": [0, 1, 2], "cast": 0.6, "dmg": 1.6, "alert": "¡Vuelo de la Valkyria! Apártate de la línea"}, 
			{"id": "scales", "mech": "polar", "name": "Balanza de Valhalla", "every": 36.0, "first": 26.0, "phases": [1, 2], 
				"time": 5.5, "flip_time": 7.5, "flip": [], "size": 2.6, "pct": 0.6, "alone": true, "lethal": true}, 
		]}, 
	"randgris_fallen": {"arena": "odin_past", "flat": true, "title": "Valhalla en ruinas", "color": Color(0.85, 0.12, 0.2), 
		"boss_hp": 1.2, "boss_dmg": 1.15, "aura": {"fx": "hell_in", "every": 1.2, "color": Color(0.85, 0.12, 0.2, 0.7)}, 
		"radius": 15.0, "hp_mult": 5.0, "pillars": {"sprite": "rock_pillar", "count": 4, "hits": 3}, 
		"npc": {}, 
		"intro": "Tú también elegiste la oscuridad... entonces sangra conmigo.", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡Hel me dio esta lanza!", "¡VALHALLA ME DESTERRÓ Y TÚ CAERÁS CONMIGO!"], 
		"abilities": [
			{"id": "spear", "mech": "cone", "name": "Lanza Corrompida", "every": 6.0, "first": 3.0, "phases": [0, 1, 2], "cast": 0.9, 
				"radius": 6.0, "angle": 2.0, "dmg": 1.9, "fx": "hell_in", "alert": "Lanza Corrompida: ¡sal del frente!"}, 
			{"id": "blood", "mech": "rain", "name": "Lluvia de sangre", "every": 9.0, "first": 5.0, "phases": [0, 1, 2], "cast": 1.2, 
				"count": 6, "size": 2.4, "dmg": 1.5, "fx": "hell_in", "alert": "Lluvia de sangre: esquiva los círculos"}, 
			{"id": "hel_brand", "mech": "brand", "name": "Sangre de Nidhogg", "every": 24.0, "first": 10.0, "phases": [0, 1, 2], 
				"time": 6.0, "size": 3.7, "pct": 0.1, "fx": "hell_in", "tint": Color(0.75, 0.08, 0.15), 
				"alert": "Sangre de Nidhogg: deja el charco lejos, en el borde"}, 
			{"id": "embrace", "mech": "vortex", "name": "Abrazo de Hel", "every": 26.0, "first": 16.0, "phases": [1, 2], 



				"duration": 6.0, "from": 1.5, "size": 7.5, "pull": 0.4, "pct": 0.04, "dmg_from": 0.65, "fx": "hell_in", 
				"alert": "Abrazo de Hel: ¡te arrastra hacia ella! Corre"}, 
			{"id": "mark", "mech": "mark", "name": "Marca de Hel", "every": 30.0, "first": 20.0, "phases": [1, 2], 
				"duration": 11.0, "count": 4, "pct": 0.22, "fx": "hell_in", "bubble_fx": "bubble1", "lethal": true, 
				"alert": "Marca de Hel: ¡revienta todas las burbujas antes de que termine!"}, 
			{"id": "souls", "mech": "break", "name": "Almas encadenadas", "every": 36.0, "first": 26.0, "phases": [1, 2], 
				"time": 11.0, "count": 4, "mob": "whisper", "hp": 0.02, "stagger": 7.0, "vuln": 0.6, "pct": 0.45, 
				"fx": "hell_in", "aura": "devil", "lethal": true, 
				"alert": "Almas encadenadas: ¡libera las almas que la alimentan y cae su coraza!"}, 
			{"id": "fallen", "mech": "summon", "name": "Los caídos", "every": 22.0, "first": 8.0, "phases": [0, 1, 2], 
				"mob": ["dark_priest", "whisper"], "count": 6, "alert": "Los caídos se levantan"}, 
			{"id": "chains", "mech": "tether", "name": "Cadenas de Hel", "every": 34.0, "first": 30.0, 
				"phases": [2], "duration": 9.0, "range": 6.0, "pct": 0.04, "alert": "Cadenas de Hel: ¡no te alejes del tótem!"}, 
			{"id": "hel_scales", "mech": "polar", "name": "Balanza de Hel", "every": 36.0, "first": 24.0, "phases": [1, 2], 
				"time": 5.5, "flip_time": 7.5, "flip": [2], "size": 2.6, "pct": 0.6, "alone": true, "lethal": true}, 
		]}, 
	"l_seyren": {"arena": "lhz_dun02", "title": "Laboratorio de Lighthalzen", "color": Color(1.0, 0.45, 0.3), 
		"radius": 12.0, "hp_mult": 4.4, "pillars": {"sprite": "barricade", "count": 4, "hits": 3}, 
		"npc": {}, 
		"intro": "Otro sujeto de prueba... no durarás.", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡Berserk!", "¡NO SOY UN EXPERIMENTO!"], 
		"abilities": [
			{"id": "bash", "mech": "slam", "name": "Bowling Bash", "every": 7.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.1, "count": 3, "size": 3.0, "dmg": 1.6, "stun": 1.0, "fx": "firepillar", "alert": "Bowling Bash: ¡fuera de los círculos!"}, 
			{"id": "pierce", "mech": "charge", "name": "Spiral Pierce", "every": 11.0, "first": 6.0, "phases": [0, 1, 2], "cast": 0.7, "dmg": 1.6, "alert": "¡Spiral Pierce! Apártate de la línea"}, 
			{"id": "brandish", "mech": "cone", "name": "Brandish Spear", "every": 9.0, "first": 5.0, "phases": [0, 1, 2], "cast": 1.0, "radius": 6.0, "angle": 1.6, "dmg": 1.7, "fx": "brandish", "alert": "Brandish Spear: ¡sal del frente!"}, 
			{"id": "clones", "mech": "summon", "name": "Clones del laboratorio", "every": 20.0, "first": 8.0, "phases": [0, 1, 2], "mob": ["ygnizem", "whikebain", "armaia", "kavac"], "count": 7, "alert": "¡Los clones salen de sus tanques!"}, 
			{"id": "rifts", "mech": "spokes", "name": "Tajos de fuego", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "firehit1", "sound": "fire_pillar", "alert": "Tajos de fuego: ¡ponte entre las grietas!"}, 
			{"id": "lanes", "mech": "volley", "name": "Fuego de los tanques", "every": 22.0, "first": 14.0, 
				"phases": [1, 2], "cast": 1.6, "wave": 1.2, "width": 3.0, "dmg": 1.5, "fx": "firehit1", 
				"sound": "fire_pillar", "alert": "Fuego de los tanques: ¡ponte entre las líneas!"}, 
			{"id": "berserk", "mech": "sweep", "name": "Hoja de Berserk", "every": 28.0, "first": 18.0, 
				"phases": [2], "cast": 1.8, "turn": 4.7, "time": 5.0, "width": 2.2, "dmg": 1.8, 
				"fx": "firepillar", "alert": "Hoja de Berserk: ¡síguela por detrás, donde ya pasó!"}, 
		]}, 
	"ifrit": {"arena": "thor_v01", "flat": true, "title": "Corazón del volcán", "color": Color(1.0, 0.42, 0.12), 
		"radius": 13.0, "hp_mult": 4.4, "pillars": {"sprite": "rock_pillar", "count": 4, "hits": 3}, 
		"npc": {}, 
		"intro": "¿Quién se atreve a despertar al señor del fuego?", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡El volcán despierta!", "¡ARDE CONMIGO, MORTAL!"], 
		"abilities": [
			{"id": "claw", "mech": "cone", "name": "Garra ígnea", "every": 7.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.0, "radius": 6.0, "angle": 1.5, "dmg": 1.8, "fx": "firepillar", "alert": "Garra ígnea: ¡sal del frente de Ifrit!"}, 
			{"id": "charge", "mech": "charge", "name": "Embestida de lava", "every": 12.0, "first": 6.0, "phases": [0, 1, 2], "cast": 0.8, "dmg": 1.5, "alert": "¡Embestida de lava! Apártate de la línea"}, 
			{"id": "eruption", "mech": "rain", "name": "Erupción", "every": 9.0, "first": 4.0, "phases": [0, 1, 2], "cast": 1.2, "count": 5, "size": 2.4, "dmg": 1.5, "fx": "meteor1", "alert": "Erupción: esquiva los círculos"}, 
			{"id": "summon", "mech": "summon", "name": "Hijos del volcán", "every": 20.0, "first": 8.0, "phases": [0, 1, 2], "mob": ["imp", "blazer", "magmaring"], "count": 7, "alert": "¡Los hijos del volcán acuden!"}, 
			{"id": "hellfire", "mech": "los", "name": "Fuego infernal", "every": 24.0, "first": 14.0, "phases": [0, 1, 2], "cast": 3.5, "pct": 0.8, "fx": "firepillar", "lethal": true, "alert": "Fuego infernal: ¡cúbrete tras una roca!"}, 
			{"id": "rifts", "mech": "spokes", "name": "Grietas de magma", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "firehit1", "sound": "fire_pillar", "alert": "Grietas de magma: ¡ponte entre las grietas!"}, 
			{"id": "lava", "mech": "platforms", "name": "La lava sube", "every": 34.0, "first": 6.0, 
				"phases": [1, 2], "cast": 4.0, "duration": 6.0, "pct": 0.1, "count": 3, "fx": "firewall", 
				"lethal": true, "alert": "¡La lava sube! Sube a las rocas"}, 
			{"id": "wall", "mech": "wall", "name": "Ola de fuego", "every": 30.0, "first": 20.0, 
				"phases": [1, 2], "count": 2, "gap": 3.4, "speed": 5.0, "lead": 1.6, "pct": 0.45, 
				"fx": "firepillar", "color": Color(1.0, 0.4, 0.1), "lethal": true, "alert": "¡Ola de fuego! Cruza por el hueco"}, 
			{"id": "brand", "mech": "brand", "name": "Marca de Ifrit", "every": 28.0, "first": 18.0, "phases": [2], 
				"time": 6.0, "size": 3.7, "pct": 0.1, "fx": "firepillar", "tint": Color(1.0, 0.45, 0.1), 
				"alert": "Marca de Ifrit: deja su charco de lava lejos, en el borde"}, 
			{"id": "inferno", "mech": "doom", "name": "Corazón del volcán", "every": 46.0, "first": 26.0, "phases": [1, 2], 
				"charge": 3.0, "time": 4.0, "pct": 0.3, "heal": 0.5, "alone": true, "lethal": true}, 
		]}, 
	"gloom": {"arena": "ra_san05", "title": "El sello de Freyja", "color": Color(0.5, 0.32, 0.8), 
		"radius": 13.0, "hp_mult": 4.4, "pillars": {"sprite": "crystal_pillar", "count": 4, "hits": 3}, 
		"npc": {"sprite": "npc_priest", "name": "Sacerdotisa de Freyja"}, 
		"intro": "Mil años bajo este templo... y el primero en llegar eres tú.", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡La noche cae sobre Rachel!", "¡NINGÚN SELLO ME DETENDRÁ!"], 
		"abilities": [
			{"id": "swipe", "mech": "cone", "name": "Zarpazo de sombra", "every": 7.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.0, "radius": 6.5, "angle": 1.6, "dmg": 1.8, "fx": "hell_in", "alert": "Zarpazo de sombra: ¡sal del frente!"}, 
			{"id": "eyes", "mech": "rain", "name": "Ojos de la noche", "every": 9.0, "first": 4.0, "phases": [0, 1, 2], "cast": 1.2, "count": 5, "size": 2.4, "dmg": 1.5, "fx": "hell_in", "alert": "Ojos de la noche: esquiva los círculos"}, 
			{"id": "night", "mech": "shield", "name": "Noche eterna", "every": 30.0, "first": 16.0, "phases": [0, 1, 2], "cast": 5.0, "pct": 0.85, "fx": "lord", "shield_fx": "kyrie", "lethal": true, 
				"npc_line": "¡Bajo el Kyrie de Freyja, rápido!", "alert": "Noche eterna: ¡entra en el Kyrie de la Sacerdotisa!"}, 
			{"id": "summon", "mech": "summon", "name": "Sombras del santuario", "every": 20.0, "first": 9.0, "phases": [0, 1, 2], "mob": ["hodremlin", "seeker", "gremlin"], "count": 7, "alert": "Las sombras del santuario acuden"}, 
			{"id": "curse", "mech": "cleanse", "name": "Maldición de Gloom", "every": 26.0, "first": 7.0, "phases": [1, 2], "pct": 0.025, "zone_fx": "sanctuary", 
				"npc_line": "¡Purifícate en el Sanctuary de Freyja!", "alert": "Maldición de Gloom: busca el Sanctuary para limpiarla"}, 
			{"id": "rifts", "mech": "spokes", "name": "Rayos de la noche", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "hell_in", "sound": "earth_spike", "alert": "Rayos de la noche: ¡ponte entre las grietas!"}, 
			{"id": "seals", "mech": "towers", "name": "Sellos de Freyja", "every": 30.0, "first": 18.0, 
				"phases": [0, 1, 2], "count": 3, "size": 1.8, "time": 7.0, "pct": 0.3, "fx": "lord", 
				"lethal": true, "alert": "Sellos de Freyja: ¡pisa cada sello antes de que estalle!"}, 
			{"id": "abyss", "mech": "vortex", "name": "Abismo de Gloom", "every": 26.0, "first": 12.0, "phases": [1, 2], 
				"duration": 6.0, "from": 1.5, "size": 7.0, "pull": 0.5, "pct": 0.06, "fx": "hell_in", 
				"alert": "Abismo de Gloom: ¡te arrastra hacia él! Corre"}, 
			{"id": "night_guard", "mech": "guard", "name": "Guardia de la noche", "every": 32.0, "first": 20.0, "phases": [0, 1, 2], 
				"duration": 9.0, "arc": 2.6, "turn": 0.9}, 
			{"id": "eclipse", "mech": "polar", "name": "Eclipse", "every": 36.0, "first": 15.0, "phases": [1, 2], 
				"time": 5.5, "flip_time": 7.5, "flip": [2], "size": 2.6, "pct": 0.6, "alone": true, "lethal": true}, 
		]}, 
	"ktullanux": {"arena": "ice_dun02", "title": "Corazón helado", "color": Color(0.55, 0.85, 1.0), 
		"radius": 12.0, "hp_mult": 4.4, "pillars": {"sprite": "crystal_pillar", "count": 4, "hits": 3}, 
		"npc": {}, 
		"intro": "Grrrooo... el hielo eterno te reclama.", 
		"phases": [1.0, 0.6, 0.3], 
		"phase_shouts": ["", "¡GRRROOOAAAR!", "¡EL HIELO NUNCA SE ROMPE!"], 
		"abilities": [
			{"id": "breath", "mech": "cone", "name": "Aliento helado", "every": 7.0, "first": 3.0, "phases": [0, 1, 2], "cast": 1.0, "radius": 6.0, "angle": 1.5, "dmg": 1.8, "fx": "stormgust", "alert": "Aliento helado: ¡sal del frente de Ktullanux!"}, 
			{"id": "stomp", "mech": "slam", "name": "Pisotón glacial", "every": 9.0, "first": 5.0, "phases": [0, 1, 2], "cast": 1.1, "count": 3, "size": 3.0, "dmg": 1.6, "stun": 1.0, "fx": "icecrash", "alert": "Pisotón glacial: ¡fuera de los círculos!"}, 
			{"id": "blizzard", "mech": "los", "name": "Ventisca", "every": 24.0, "first": 12.0, "phases": [0, 1, 2], "cast": 3.5, "pct": 0.8, "fx": "stormgust", "lethal": true, "alert": "Ventisca: ¡cúbrete tras un cristal!"}, 
			{"id": "summon", "mech": "summon", "name": "Hijos del hielo", "every": 20.0, "first": 8.0, "phases": [0, 1, 2], "mob": ["iceicle", "siroma", "snowier"], "count": 7, "alert": "¡Los hijos del hielo acuden!"}, 
			{"id": "rifts", "mech": "spokes", "name": "Grietas de hielo", "every": 16.0, "first": 12.0, 
				"phases": [0, 1, 2], "cast": 1.4, "count": 4, "count_last": 6, "width": 2.0, "wave": 1.0, "dmg": 1.4, 
				"fx": "icecrash", "sound": "frost_diver", "alert": "Grietas de hielo: ¡ponte entre las grietas!"}, 
			{"id": "icicles", "mech": "starfall", "name": "Lluvia de carámbanos", "every": 22.0, "first": 14.0, "phases": [0, 1, 2], 
				"count": 6, "step": 0.55, "size": 2.4, "dmg": 1.5, "fx": "icecrash", 
				"alert": "Lluvia de carámbanos: ¡no dejes de correr, los carámbanos te siguen!"}, 
			{"id": "frost", "mech": "ice", "name": "Suelo congelado", "every": 36.0, "first": 16.0, 
				"phases": [1, 2], "duration": 14.0, "count": 3, "size": 4.5, "fx": "stormgust", 
				"alert": "Suelo congelado: ¡el hielo resbala!"}, 
			{"id": "still", "mech": "still", "mode": "still", "name": "Frío eterno", "every": 30.0, "first": 20.0, 
				"phases": [1, 2], "duration": 6.0, "pct": 0.06, "fx": "stormgust", "alert": "Frío eterno: ¡si te quedas quieto te congelas!"}, 
			{"id": "glacier", "mech": "break", "name": "Coraza glacial", "every": 40.0, "first": 24.0, "phases": [1, 2], 
				"time": 12.0, "count": 3, "mob": "ice_titan", "hp": 0.025, "stagger": 7.0, "vuln": 0.6, "pct": 0.45, 
				"fx": "icecrash", "aura": "kyrie", "lethal": true, 
				"alert": "Coraza glacial: ¡derriba a los Ice Titan y rompe su escudo!"}, 
		]}, 




	"naght_sieger": {"arena": "6@tower", "title": "La cima de la Endless Tower", "hel_title": "El abismo de la Torre de Hel", "color": Color(1.0, 0.4, 0.3), 
		"radius": 14.0, "epic": true, "pillars": {"sprite": "crystal_pillar", "count": 4, "hits": 2}, 
		"npc": {"sprite": "npc_lucile", "name": "Lucile"}, 
		"intro": "¿Cien pisos para morir aquí? La cima es mía... y la noche también.", 
		"phases": [1.0, 0.75, 0.5, 0.25], 
		"phase_shouts": ["", "¡Despierta, Espada Helada!", "¡Fuego y hielo, a la vez!", "¡SOY LA NOCHE QUE NUNCA TERMINA!"], 
		"abilities": [
			{"id": "starfall", "mech": "starfall", "name": "Caída de la Noche", "every": 22.0, "first": 17.0, "phases": [0, 1, 2, 3], 
				"count": 6, "step": 0.55, "size": 2.4, "dmg": 1.5, "fx": "meteor1", 
				"alert": "Caída de la Noche: ¡no dejes de correr, los meteoros te siguen!"}, 

			{"id": "flame_slash", "mech": "cone", "name": "Tajo de la Espada Ígnea", "every": 7.0, "first": 3.0, 
				"phases": [0, 2, 3], "cast": 1.0, "radius": 7.5, "angle": 2.2, "dmg": 1.9, "fx": "firepillar", 
				"color": Color(1.0, 0.45, 0.15), "alert": "Tajo ígneo: ¡sal del frente de Naght Sieger!"}, 
			{"id": "fire_rifts", "mech": "spokes", "name": "Grietas Ígneas", "every": 15.0, "first": 9.0, 
				"phases": [0, 2, 3], "cast": 1.3, "count": 5, "count_last": 8, "width": 2.0, "wave": 0.9, "dmg": 1.6, 
				"fx": "firehit1", "sound": "fire_pillar", "alert": "Grietas Ígneas: ¡entre las grietas, dos oleadas!"}, 
			{"id": "inferno", "mech": "brand", "name": "Infierno eterno", "every": 24.0, "first": 13.0, 
				"phases": [0, 1, 2, 3], "time": 6.0, "size": 3.2, "pct": 0.1, "fx": "firepillar", "tint": Color(1.0, 0.4, 0.15), 
				"alert": "Infierno eterno: deja el charco lejos, en el borde"}, 

			{"id": "ice_slash", "mech": "cone", "name": "Tajo de la Espada Helada", "every": 7.0, "first": 3.0, 
				"phases": [1, 2, 3], "cast": 1.0, "radius": 7.5, "angle": 2.2, "dmg": 1.9, "fx": "icecrash", 
				"color": Color(0.55, 0.85, 1.0), "alert": "Tajo helado: ¡sal del frente de Naght Sieger!"}, 



			{"id": "lances", "mech": "volley", "name": "Lanzas de escarcha", "every": 18.0, "first": 10.0, 
				"phases": [1, 2, 3], "cast": 1.5, "wave": 1.1, "width": 2.8, "dmg": 1.6, "fx": "icecrash", 
				"sound": "frost_diver", "color": Color(0.55, 0.85, 1.0), "alert": "Lanzas de escarcha: ¡ponte entre las líneas!"}, 
			{"id": "frozen_time", "mech": "still", "mode": "move", "name": "Tiempo congelado", "every": 30.0, "first": 15.0, 
				"phases": [1, 3], "duration": 5.0, "pct": 0.1, "fx": "freezing", 
				"alert": "Tiempo congelado: ¡QUIETO o te rompes!"}, 
			{"id": "night_charge", "mech": "charge", "name": "Embestida nocturna", "every": 12.0, "first": 6.0, 
				"phases": [1, 2, 3], "cast": 0.7, "dmg": 1.7, "alert": "¡Embestida nocturna! Apártate de la línea"}, 

			{"id": "twin_sweep", "mech": "ns_twin_sweep", "name": "Danza de las Espadas Gemelas", "every": 26.0, "first": 8.0, 
				"phases": [2, 3], "cast": 1.8, "turn": 4.2, "time": 5.5, "width": 2.2, "dmg": 1.9, 
				"alert": "Espadas Gemelas: ¡dos haces giran, quédate detrás de uno!"}, 
			{"id": "brand", "mech": "ns_brand", "name": "Marca de la Dualidad", "every": 32.0, "first": 16.0, 
				"phases": [2, 3], "time": 7.0, "size": 3.0, "pct": 0.55, "lethal": true, 
				"alert": "Marca de la Dualidad: ¡ve al círculo del elemento CONTRARIO a tu marca!"}, 
			{"id": "hours", "mech": "clock", "name": "Las horas de la noche", "every": 40.0, "first": 24.0, 
				"phases": [2], "step": 0.55, "dmg": 1.6, "fx": "hell_in", "alert": "Las horas de la noche: ¡sigue al reloj!"}, 
			{"id": "seals", "mech": "towers", "name": "Sellos de la cima", "every": 30.0, "first": 20.0, 
				"phases": [2, 3], "count": 3, "size": 1.8, "time": 7.0, "pct": 0.35, "fx": "lord", 
				"lethal": true, "alert": "Sellos de la cima: ¡pisa cada sello antes de que estalle!"}, 
			{"id": "black_wall", "mech": "wall", "name": "Muro de llamas negras", "every": 34.0, "first": 28.0, 
				"phases": [2, 3], "count": 2, "gap": 3.4, "speed": 5.5, "lead": 1.5, "pct": 0.45, 
				"fx": "firepillar", "color": Color(0.75, 0.25, 0.9), "lethal": true, "alert": "¡Muro de llamas negras! Cruza por el hueco"}, 

			{"id": "eclipse", "mech": "shield", "name": "Eclipse de la Noche Eterna", "every": 36.0, "first": 22.0, 
				"phases": [1, 2, 3], "cast": 5.0, "pct": 0.9, "fx": "lord", "shield_fx": "kyrie", "lethal": true, 
				"npc_line": "¡Aquí, bajo mi escudo! ¡Rápido!", 
				"alert": "Eclipse: ¡ponte bajo el escudo de Lucile!"}, 
			{"id": "no_return", "mech": "doom", "name": "Noche sin retorno", "every": 46.0, "first": 30.0, "phases": [1, 3], 
				"charge": 3.0, "time": 4.0, "pct": 0.3, "heal": 0.5, "alone": true, "lethal": true}, 
			{"id": "summit_runes", "mech": "runes", "name": "Runas de la cima", "every": 48.0, "first": 34.0, "phases": [2, 3], 
				"count": 4, "show": 1.0, "time": 14.0, "pct": 0.5, "stagger": 6.0, "vuln": 0.5, "fx": "firepillar", "alone": true, "lethal": true}, 
		]}, 
}










const NAGHT: = {"hp": 2.6, "dmg": 1.25, "enrage": 480.0, "enrage_dmg": 6.0, 
	"intermission": {"at": 2, "echo_hp": 0.07, "echo_gap": 8.0, "time": 50.0, "heal": 0.12}, 
	"shrink_to": 0.62, "shrink_time": 70.0, 
	"traps": {
		"jets": {"from": 0, "every": [6.5, 5.5, 4.5, 3.2], "lanes": [1, 1, 2, 2], "width": 2.2, "warn": 1.3, "dmg": 1.4}, 
		"orbs": {"from": 1, "count": [0, 2, 2, 3], "speed": 4.2, "size": 1.0, "pct": 0.09}, 
		"runes": {"from": 2, "every": [0.0, 0.0, 3.4, 2.6], "count": 3, "size": 2.2, "warn": 1.5, "dmg": 1.3}, 
	}, 
	"fire": Color(1.0, 0.45, 0.15), "ice": Color(0.55, 0.85, 1.0), "night": Color(0.6, 0.35, 1.0), 
	"victory": "Imposible... la noche... ha terminado...", 


	"talk": [
		["Lucile", "¡Piso 100! ¡Esta es la cima de la torre!", "tnm_lucile02"], 
		["Naght Sieger", "Cien pisos... y todavía respiras. Qué curioso.", "tnm_lucile03"], 
		["Lucile", "¡Esa voz...! ¡Es Naght Sieger, el señor de la torre!", "tnm_lucile03"], 
		["Naght Sieger", "Pequeña guía... ¿cuántos héroes me has traído ya? Ninguno volvió a bajar.", "tnm_lucile03"], 
		["Lucile", "¡Esta vez es distinto! Nadie había llegado tan lejos sin rendirse.", "tnm_lucile01"], 
		["Naght Sieger", "Entonces que suba. Mis dos espadas llevan siglos sin cruzarse con nadie.", "tnm_lucile03"], 
		["Lucile", "Tranquilidad, voy a tu lado. ¡Entra cuando quieras!", "tnm_lucile02"], 
	], 

	"talk_again": [
		["Naght Sieger", "¿Otra vez tú? La noche no olvida... y yo tampoco.", "tnm_lucile03"], 
		["Lucile", "¡Nosotros tampoco! ¡Vamos a ganarle de nuevo!", "tnm_lucile02"], 
	], 

	"talk_hel": [
		["Lucile", "¡Naght Sieger nos espera! Espero que estés listo...", "tnm_lucile02"], 
	], 
	"lucile": ["¡Cuidado con las trampas de la torre!", "¡Lo tienes! ¡No le des respiro!", "¡Sus espadas, rómpelas!", 
		"¡Es ahora o nunca!"], 
}


const RAID_PILLAR_HITS: = 2








const RAID_YMIR_TIME: = 40.0
const RAID_YMIR_ENDLESS_STEP: = 15.0
const RAID_YMIR_MIN: = 40.0
const RAID_YMIR_MVP_DMG: = 0.05
const RAID_YMIR_MVP_CAST: = 0.02


const RAID_YMIR_CAST_MAX: = 1.5




const RAID_YMIR_ACCEL_MAX: = 2.0
const RAID_YMIR_ACCEL_TIME: = 60.0



static func ymir_rate(since: float) -> float:
	return 1.0 + (RAID_YMIR_ACCEL_MAX - 1.0) * clampf(since / RAID_YMIR_ACCEL_TIME, 0.0, 1.0)




const RAID_CAST_GAP: = 0.8



const RAID_ANCHOR_MECHS: = ["towers", "tether", "platforms", "los", "cleanse"]
const RAID_ANCHOR_KINDS: = ["towers", "tether", "hazard", "holy"]


const RAID_YMIR_HERO_DMG: = 0.08
const RAID_YMIR_HERO_CD: = 0.03
const RAID_YMIR_CD_MAX: = 2.0



const RAID_YMIR_TICK_MAX: = 2.0
const RAID_BRAND_GRACE: = 1.0
const RAID_YMIR_WARN: = 40.0



const RAID_HIT_PCT: = 0.1
const RAID_HIT_PCT_DANGER: = 0.03


const RAID_MECH_DMG: = 1.3






const MVP_SCALE: = 1.3
const MVP_RADIUS: = 1.15
const MVP_UNDER_PRIORITY: = 11
const MVP_FX_PRIORITY: = 13
const MVP_PRIORITY: = 15





const HERO_PRIORITY: = 12
const HERO_FX_PRIORITY: = 13
const RAID_SHIELD_RADIUS: = 2.3
const RAID_ZONE_RADIUS: = 2.0
const RAID_ORB_SPEED: = 0.8



const RAID_ORB_WAKE: = 1.5

const RAID_ORB_VULN: = 0.5
const RAID_ORB_VULN_TIME: = 6.0
const RAID_PLATFORM_RADIUS: = 1.8


func _ready() -> void :
	_setup_input()






const UPGRADE_COST_POW: = 1.35




const UPGRADE_COST_MULT: = 1.4
func upgrade_cost(id: String, level: int) -> int:
	return int(round(UPGRADES[id].cost * UPGRADE_COST_MULT * pow(level + 1, UPGRADE_COST_POW) / 10.0) * 10)






var _doom_icon: Texture2D
func doom_icon() -> Texture2D:
	if _doom_icon != null:
		return _doom_icon
	var spr: RoSprite = RoAssets.sprite(["flame_skull"]) if RoAssets.has_sprite("flame_skull") else null
	if spr != null and spr.frame_count(0) > 0:



		var img: = spr.compose_image(0, 0, 0, [], true)
		var used: = img.get_used_rect()
		if used.size.x > 0:

			var side: = mini(used.size.x, roundi(used.size.y * 0.54))
			var cut: = img.get_region(Rect2i(used.position.x, used.end.y - side, side, side))


			var half: = side * 0.5
			for y in side:
				for x in side:
					var c: = cut.get_pixel(x, y)
					if c.a > 0.0:
						var d: = Vector2(x + 0.5 - half, y + 0.5 - half).length() / half
						c.a *= clampf((1.0 - d) / 0.22, 0.0, 1.0)
						cut.set_pixel(x, y, c)
			_doom_icon = ImageTexture.create_from_image(cut)
			return _doom_icon
	var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % str(UPGRADES.doom.icon)
	return load(path) as Texture2D if ResourceLoader.exists(path) else null



func meta_mods() -> Dictionary:
	var out: = {}
	for id in UPGRADES:
		var lv: = Save.upgrade_active(id)
		if lv <= 0:
			continue
		var mods: Dictionary = UPGRADES[id].mods
		for k in mods:
			out[k] = out.get(k, 0.0) + float(mods[k]) * lv
	return out


func card_slots() -> int:
	return BASE_CARD_SLOTS + Save.upgrade_active("card_slot")










const OPENING_TIME: = 180.0
const OPENING_DANGER: = 2
const OPENING_RATE: = 0.7
const OPENING_DMG: = 0.6
const RAID_GENTLE_DMG: = 0.6
const RAID_GENTLE_CAST: = 1.25
const RAID_GENTLE_HP: = 0.8
const RAID_GENTLE_BOSS_DMG: = 0.8



func spawn_rate(t: float) -> float:
	return 1.0 + t / 170.0


func scale_hp(t: float) -> float:
	return 1.0 + t / 150.0




func scale_boss_hp(t: float) -> float:
	return 1.0 + t / 600.0




const XP_CURVE_STEP: = 40.0


const XP_EARLY_BONUS: = 0.0
const XP_EARLY_UNTIL: = 30


const PACE_XP: = {1: 1.0}




const FRENZY_SPEED: = 1.3
const FRENZY_ZENY: = 0.3


const FRENZY_MOB_SPEED: = 0.9



const GAME_FAST_SPEED: = 2.0


const KICK_FURY_MAX: = 20


const KICK_CAP_FISTS: = 10

const HUNT_STEP: = 0.04
const HUNT_MAX: = 20

const SHADOW_STRIKE: = 0.2



const SHADOW_ABSORB_MAX: = 0.25
const SHADOW_ABSORB_CUT: = 0.5

const HUUMA_FALL: = 0.35

const CHARM_TINT: = {"water": Color(0.45, 0.75, 1.0), "wind": Color(0.75, 1.0, 0.6), "earth": Color(0.85, 0.7, 0.45)}
const KICK_FURY_TIME: = 6.0
const KICK_FURY_BOSS: = 2.0




const SHIELD_X: = {
	"endure_x": {"reflect": 1.0, "hit_proc": 1.0, "burst": 2.0, "color": Color(1.0, 0.8, 0.3)}, 
	"energy_coat_x": {"burst": 3.0, "color": Color(0.5, 0.7, 1.0)}, 
	"assumptio_x": {"heal": 0.2, "burst": 1.0, "color": Color(1.0, 0.95, 0.7)}, 
	"kaite_x": {"reflect": 1.5, "color": Color(0.8, 0.85, 1.0)}, 
	"tuna_party_x": {"heal": 0.1, "burst": 1.5, "color": Color(0.6, 0.85, 1.0)}, 
	"reject_sword_x": {"reflect": 1.0, "burst": 1.5, "color": Color(0.85, 0.85, 1.0)}, 
}
const SHIELD_BURST_RADIUS: = 5.0
const MVP_SPEED_MAX: = 0.6



const MVP_CAST_BASE: = 0.05
const MVP_CAST_MAX: = 0.2
const MVP_CAST_ENDLESS: = 0.05
func mvp_cast_mult(d: int, steps: int) -> float:
	var k: = float(d - 1) / float(DANGER_HELL10 - 1) + MVP_CAST_ENDLESS * steps
	return (1.0 - MVP_CAST_BASE) * (1.0 - MVP_CAST_MAX * clampf(k, 0.0, 1.0))


func xp_to_next(level: int) -> int:
	var base: = 4 + (level - 1) * 5 + pow(level - 1, 1.6) * 1.2
	var early: = 1.0 + XP_EARLY_BONUS * maxf(0.0, float(XP_EARLY_UNTIL - level) / (XP_EARLY_UNTIL - 1))
	return int(base * (1.0 + (level - 1) / XP_CURVE_STEP) * early)




func pick_levels(level: int) -> int:
	return 3 if level >= PICK_X3_FROM else (2 if level >= PICK_X2_FROM else 1)





func skill_has_element(id: String) -> bool:
	var s: Dictionary = SKILLS[id]
	return s.has("damage") or s.has("element") or s.get("uses_arrows", false)




var _element_mults: = {}
func element_mult(attack: String, defence: String) -> float:
	var known = _element_mults.get(attack)
	if known == null:
		known = {}
		_element_mults[attack] = known
	var got = known.get(defence)
	if got != null:
		return got
	var row: Array = ELEMENT_TABLE.get(attack, ELEMENT_TABLE.neutral)
	var v: = maxf(MIN_ELEMENT_MULT, float(row[maxi(0, ELEMENT_ORDER.find(defence))]))
	known[defence] = v
	return v


func monster_element(id: String) -> String:
	return MONSTER_ELEMENTS.get(id, "neutral")





func set_part(sid: String) -> Dictionary:
	if not sid.ends_with("@4"):
		return SETS[sid]
	var st: Dictionary = SETS[sid.trim_suffix("@4")]
	return {"name": st.name, "mods": st.get("full_mods", {}), "effects": st.get("full_effects", {}), "desc": st.get("full_desc", "")}



func set_pieces(sid: String) -> Array:
	return (SETS[sid].get("items", []) as Array) + (SETS[sid].get("more", []) as Array)



func stage_sets(sid: String) -> Array:
	return STAGE_SETS.get(sid, [])



func set_stages(set_id: String) -> Array:
	var out: = []
	for sid in STAGES:
		if (STAGE_SETS.get(sid, []) as Array).has(set_id):
			out.append(sid)
	return out



var _legend_set_of: = {}
func legend_set_of(item_id: String) -> String:
	if _legend_set_of.is_empty():
		for sid in SETS:
			if SETS[sid].has("more"):
				for pid in set_pieces(sid):
					_legend_set_of[pid] = sid
	return str(_legend_set_of.get(item_id, ""))




func loadout_legend_max(class_id: String) -> int:
	var top: = Save.is_reborn(class_id) or bool(CLASSES[class_id].get("no_rebirth", false))
	return LOADOUT_MAX_LEGENDARY + (REBIRTH_LEGEND_SLOTS if top else 0) + Save.tower_legend_slots()




func soul_slot_open(class_id: String) -> bool:
	return Save.is_reborn(class_id) or bool(CLASSES.get(class_id, {}).get("no_rebirth", false))



func wings_slot_open() -> bool:
	return Save.storage().any( func(s): return bool(ITEMS.get(str(s.get("id", "")), {}).get("wings", false)))





func skill_stats(id: String) -> Dictionary:
	var own: = id.trim_suffix("_x")
	if SKILL_SCALE.has(own):
		return SKILL_SCALE[own]
	return _SCALE_MAGIC if SKILLS.has(id) and SKILLS[id].get("magic", false) else _SCALE_PHYS



func skill_phys_share(id: String) -> float:
	return 1.0 - float(skill_stats(id).get("int", 0.0))




func skill_of_tag(tag: String) -> String:
	if SKILLS.has(tag):
		return tag
	if tag.begins_with("homun_"):
		return "call_homunculus"
	var t: = tag.get_slice("@", 0)
	if t.contains(":"):
		t = t.get_slice(":", t.get_slice_count(":") - 1)
	return t if SKILLS.has(t) else ""





func skill_scaling(id: String) -> String:
	var s: Dictionary = SKILLS[id]
	if HIGHER_STAT_SKILLS.has(id.trim_suffix("_x")):
		return tr("La más alta de FUE e INT")
	var parts: = []
	for k in skill_stats(id):
		parts.append(SCALE_NAMES[k])
	if (s.has("tank_hp") or s.has("hp_power")) and not parts.has("Vida"):
		parts.append("Vida")
	if s.has("tank_def"):
		parts.append("Def")
	if s.has("zeny_cost"):
		parts.append("Zeny")
	return _scaling_text(parts)



func support_scaling(id: String) -> String:
	return _scaling_text(["DES", "Vida"] if SKILLS[id].has("amount_hp") else ["DES"])





func gear_scaling(d: Dictionary) -> String:
	if d.has("fists"):
		return _scaling_text(["Nivel base"])


	if d.has("proc"):
		return _scaling_text([_proc_stat(str(d.proc.skill)), "Daño básico", "Daño de procs", "Nivel base"])
	if d.has("proc_hit"):
		return _scaling_text([_proc_stat(str(d.proc_hit.skill)), "Vida", "Daño de procs", "Nivel base"])
	var fx: Dictionary = d.get("effects", {})

	if fx.has("u_owl"):
		return _scaling_text([_proc_stat("jupitel_thunder"), "Daño básico", "Daño de procs", "Nivel base"])

	if fx.has("u_flies"):
		return _scaling_text(["FUE", "Daño básico", "Daño de procs", "Nivel base"])



	if fx.has("u_excalibur"):
		return _scaling_text(["Daño de habilidades"])
	if fx.has("u_overload"):
		return _scaling_text(["Daño básico"])





	if fx.has("lg_heal"):
		return _scaling_text(["INT", "Daño de habilidades", "Curación", "DES"])
	if fx.has("u_bishop"):
		return _scaling_text([TranslationServer.translate("FUE") + "/" + TranslationServer.translate("INT"), "Daño de habilidades", "Curación"])


	if not str(d.get("desc", "")).contains("×Lv") and not AUTOCAST_TAGS.any( func(t): return fx.has(t)):
		return ""
	if fx.has("u_gift"):
		return _scaling_text(["DES", "Nivel base"])
	for tag in AUTOCAST_INT_TAGS + MAGIC_TAGS:
		if fx.has(tag):
			return _scaling_text(["INT", "Nivel base"])
	for tag in AUTOCAST_MAGIC_TAGS + HYBRID_TAGS:
		if fx.has(tag):
			return _scaling_text([TranslationServer.translate("FUE") + "/" + TranslationServer.translate("INT"), "Nivel base"])
	return _scaling_text(["FUE", "Nivel base"])




func gear_cast_skill(d: Dictionary) -> String:
	if d.has("proc"):
		return str(d.proc.skill)
	if d.has("proc_hit"):
		return str(d.proc_hit.skill)
	if (d.get("effects", {}) as Dictionary).has("u_owl"):
		return "jupitel_thunder"
	return ""






func gear_nature(d: Dictionary) -> String:
	var cast: = gear_cast_skill(d)
	if cast != "":
		return skill_nature(cast)
	if gear_scaling(d) == "":
		return ""
	var fx: Dictionary = d.get("effects", {})
	for tag in AUTOCAST_INT_TAGS + MAGIC_TAGS + AUTOCAST_MAGIC_TAGS + ["lg_heal"]:
		if fx.has(tag):
			return TranslationServer.translate("Mágica")
	for tag in HYBRID_TAGS:
		if fx.has(tag):
			return TranslationServer.translate("Física y mágica")
	return ""





func proc_by_int(skill: String) -> bool:
	return skill_stats(skill).has("int")





func proc_note(d: Dictionary) -> String:
	if d.has("proc"):
		return TranslationServer.translate("Se lanza sola: sube con tu daño básico y «Daño de procs», no con daño de habilidades.")
	if d.has("proc_hit"):
		return TranslationServer.translate("Se lanza sola al recibir golpes: sube con tu vida y «Daño de procs», no con daño de habilidades.")
	if (d.get("effects", {}) as Dictionary).has("u_owl"):
		return TranslationServer.translate("Se lanza sola: sube con tu daño básico y «Daño de procs», no con daño de habilidades.")
	return ""




func skill_nature(id: String) -> String:
	if not SKILLS.has(id) or not SKILLS[id].has("damage"):
		return ""
	var st: = skill_stats(id)
	var phys: = float(st.get("str", 0.0)) > 0.0 or not st.has("int")
	var mag: = float(st.get("int", 0.0)) > 0.0
	if phys and mag:
		return TranslationServer.translate("Física y mágica")
	return TranslationServer.translate("Mágica") if mag else TranslationServer.translate("Física")



func _proc_stat(skill: String) -> String:
	if proc_by_int(skill):
		return TranslationServer.translate("FUE") + "/" + TranslationServer.translate("INT")
	return "FUE"


func _scaling_text(parts: Array) -> String:
	return " + ".join(parts.map( func(p): return TranslationServer.translate(str(p))))






func unique_of_stage(stage_id: String, job: = "") -> String:
	var shared: = ""
	var any: = ""
	for id in ITEMS:
		if ITEMS[id].get("unique", false) and str(ITEMS[id].get("stage", "")) == stage_id:
			var jobs: Array = ITEMS[id].get("job", [])
			if job != "" and jobs.has(job):
				return id
			if jobs.is_empty() and shared == "":
				shared = id
			if any == "":
				any = id
	return shared if shared != "" else any






func stage_shared_uniques(stage_id: String) -> Array:
	var out: = []
	for id in ITEMS:
		if ITEMS[id].get("unique", false) and str(ITEMS[id].get("stage", "")) == stage_id and (ITEMS[id].get("job", []) as Array).is_empty():
			out.append(id)
	return out








func stage_roll_pool(stage_id: String) -> Array:
	var out: = []
	for id in ITEMS:
		if ITEMS[id].get("unique", false) and str(ITEMS[id].get("stage", "")) == stage_id:
			out.append(id)
	return out



static var _mvp_cards: = {}


static func is_mvp_card(id: String) -> bool:
	if _mvp_cards.is_empty():
		for m in MONSTERS:
			if MONSTERS[m].get("mvp", false) and MONSTERS[m].has("card"):
				_mvp_cards[str(MONSTERS[m].card)] = str(m)
	return _mvp_cards.has(id)




static func mvp_card_color(id: String) -> Color:
	if not is_mvp_card(id):
		return Color(0, 0, 0, 0)
	var c: Color = MONSTERS[_mvp_cards[id]].get("color", Color.WHITE)
	return Color.from_hsv(c.h, clampf(c.s * 1.4 + 0.25, 0.0, 0.9), maxf(0.85, c.v), 1.0)



static func bank_tens(bank: float) -> float:
	return maxf(0.0, log(maxf(1.0, bank) / MERCHANT_BANK_FROM) / log(10.0))



static func bank_mult(bank: float) -> float:
	return 1.0 + minf(BANK_POWER_MAX, BANK_POWER * bank_tens(bank))



static func merchant_bank_dmg(bank: float) -> float:
	return minf(MERCHANT_BANK_MAX, MERCHANT_BANK_DMG * bank_tens(bank))


func skill_value(id: String, field: String, level: int) -> float:
	var s: Dictionary = SKILLS[id]
	var base: float = float(s.get(field, 0.0))
	var per: Dictionary = s.get("per_level", {})
	var top: = skill_cap(id)
	var value: = base + float(per.get(field, 0.0)) * (mini(level, top) - 1)


	if level > top and (s.get("over_add", {}) as Dictionary).has(field):
		return value + float(s.over_add[field]) * (level - top)
	if level > top and field in s.get("over_never", []):
		return value



	if level > top and (field in OVERLEVEL_FIELDS or field in s.get("bonus", [])) and not field in OVERLEVEL_NEVER:



		var step: = float(s.get("over_dmg_step", s.get("over_step", OVERLEVEL_STEP))) if field == "damage" else float(s.get("over_step", OVERLEVEL_STEP))
		value *= 1.0 + step * overlevel_steps(level - top)
	elif level > top and field in OVERLEVEL_SHRINK:
		value /= 1.0 + OVERLEVEL_STEP * overlevel_steps(level - top)
	return value





static func overlevel_steps(over: int) -> float:
	if over <= OVERLEVEL_FULL:
		return float(over)
	if over <= OVERLEVEL_HALF:
		return OVERLEVEL_FULL + (over - OVERLEVEL_FULL) * 0.5
	return OVERLEVEL_FULL + (OVERLEVEL_HALF - OVERLEVEL_FULL) * 0.5 + (over - OVERLEVEL_HALF) * 0.25




func grows_past_cap(id: String) -> bool:
	if id == "call_homunculus" or id == "call_homunculus_x":
		return true
	var s: Dictionary = SKILLS[id]
	var top: = skill_cap(id)
	var fields: Array = s.keys() + (s.get("per_level", {}) as Dictionary).keys()
	for f in fields:
		if s.get(f) is float or (s.get("per_level", {}) as Dictionary).has(f):
			if not is_equal_approx(skill_value(id, f, top), skill_value(id, f, top + 1)):
				return true
	return false



func skill_cap(id: String) -> int:
	return 1 if SKILLS[id].get("evolved", false) else MAX_SKILL_LEVEL


func _setup_input() -> void :
	var binds: = {
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN], 
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], 
		"pause": [KEY_ESCAPE, KEY_P], 
		"pick_1": [KEY_1], "pick_2": [KEY_2], "pick_3": [KEY_3], 
		"equip_window": [KEY_Q], "status_window": [KEY_C], "inventory_window": [KEY_I], 


		"arrow_next": [KEY_V], "arrow_prev": [KEY_C], "pet_fetch": [KEY_G], 
	}
	for action in binds:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action, 0.2)
		for key in binds[action]:
			var ev: = InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
	var axes: = {"move_left": [JOY_AXIS_LEFT_X, -1.0], "move_right": [JOY_AXIS_LEFT_X, 1.0], 
		"move_up": [JOY_AXIS_LEFT_Y, -1.0], "move_down": [JOY_AXIS_LEFT_Y, 1.0]}
	for action in axes:
		var jm: = InputEventJoypadMotion.new()
		jm.axis = axes[action][0]
		jm.axis_value = axes[action][1]
		InputMap.action_add_event(action, jm)
	var start: = InputEventJoypadButton.new()
	start.button_index = JOY_BUTTON_START
	InputMap.action_add_event("pause", start)

	var dpad: = {"move_left": JOY_BUTTON_DPAD_LEFT, "move_right": JOY_BUTTON_DPAD_RIGHT, 
		"move_up": JOY_BUTTON_DPAD_UP, "move_down": JOY_BUTTON_DPAD_DOWN}
	for action in dpad:
		var jb: = InputEventJoypadButton.new()
		jb.button_index = dpad[action]
		InputMap.action_add_event(action, jb)




	for action in ["ui_left", "ui_right", "ui_up", "ui_down"]:
		if not InputMap.has_action(action):
			continue
		for ev in InputMap.action_get_events(action):
			if ev is InputEventJoypadMotion:
				InputMap.action_erase_event(action, ev)
