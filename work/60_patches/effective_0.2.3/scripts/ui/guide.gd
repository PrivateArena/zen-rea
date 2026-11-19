extends RefCounted






static func tabs() -> Array:
	return [
		["basics", TranslationServer.translate("Lo básico"), "bash"], 
		["run", TranslationServer.translate("La partida"), "magnum_break"], 
		["damage", TranslationServer.translate("Daño"), "hammer_fall"], 
		["elements", TranslationServer.translate("Elementos"), "aspersio"], 
		["stats", TranslationServer.translate("Atributos"), "blessing"], 
		["speed", TranslationServer.translate("Crítico y ritmo"), "sonic_blow"], 
		["defense", TranslationServer.translate("Defensa"), "auto_guard"], 
		["status", TranslationServer.translate("Estados"), "envenom"], 
		["monsters", TranslationServer.translate("Monstruos"), "provoke"], 
		["summons", TranslationServer.translate("Invocaciones"), "call_homunculus"], 
		["gear", TranslationServer.translate("Equipo y cartas"), "weapon_perfection"], 
		["eternal", TranslationServer.translate("Cartas Eternas"), "lex_aeterna"], 
		["words", TranslationServer.translate("Palabras de los textos"), "first_aid"], 
		["options", TranslationServer.translate("Opciones útiles"), "improve_concentration"], 
	]




static func split() -> bool:
	return _has("SKILL_SCALE")


static func _has(name: String) -> bool:
	return GameData.get_script().get_script_constant_map().has(name)


static func _num(name: String) -> float:
	return float(GameData.get_script().get_script_constant_map().get(name, 0.0))


static func _pct(v: float) -> String:
	return "%d%%" % roundi(v * 100.0)



static func _mult(v: float) -> String:
	var t: = String.num(v, 2)
	return t.replace(".", ",") if TranslationServer.get_locale().substr(0, 2) in ["es", "pt", "ru", "de", "fr"] else t




static func entries(tab: String) -> Array:
	return _entries(tab).filter( func(e): return str(e[0]) != "")


static func _entries(tab: String) -> Array:
	match tab:
		"basics":
			return [
				[TranslationServer.translate("Ataque básico"), 
					TranslationServer.translate("El golpe de tu arma, solo y sin parar, al ritmo de tu ASPD. Cuando un texto dice «ataque básico» o «básico», habla solo de él: no de las habilidades.")], 
				[TranslationServer.translate("Habilidades"), 
					TranslationServer.translate("Lo que eliges al subir de nivel: Bash, Magnum Break, Magnus Exorcismus, Storm Gust... Se lanzan solas cada vez que terminan de recargarse. Bash es una habilidad, no un ataque básico.")], 
				[TranslationServer.translate("Pasivas"), 
					TranslationServer.translate("Habilidades que no se lanzan: mejoran algo siempre (Sword Mastery, Increase SP Recovery...). Una habilidad a Nv 5 con su pasiva aprendida evoluciona a su versión EX.")], 
				[TranslationServer.translate("Procs"), 
					TranslationServer.translate("Lo que cartas y equipo lanzan por su cuenta: «al atacar» sale de tu ataque básico; «al recibir un golpe», de los golpes que te dan. No ocupan ranuras de habilidad.")], 
				[TranslationServer.translate("Invocaciones"), 
					TranslationServer.translate("Lo que pelea a tu lado: Homúnculos, plantas, Pickies, Tarous, sombras... Mira su pestaña.")], 
				[TranslationServer.translate("Estados"), 
					TranslationServer.translate("Veneno, quemadura, sangrado, congelación, piedra, sueño, aturdimiento... Mira su pestaña.")], 
				[TranslationServer.translate("Jefes, élites y MVP"), 
					TranslationServer.translate("Los élites son monstruos más fuertes y brillantes; los jefes, los grandes del mapa; los MVP, el jefe final de cada mapa. Los estados de control (congelación, aturdimiento...) duran la mitad en los élites, y los jefes y MVP no los sufren.")], 
			]
		"run":
			var rare: Array = GameData.CHOICE_RARITY
			return [
				[TranslationServer.translate("El MVP"), 
					TranslationServer.translate("A los %d minutos aparece el MVP del mapa: vencerlo es la victoria. Mientras, sobrevive a la horda, sube de nivel y busca equipo.") % roundi(GameData.MVP_TIME / 60.0)], 
				[TranslationServer.translate("Subir de nivel"), 
					TranslationServer.translate("Eliges una mejora: una habilidad nueva, un nivel más de una que tienes o un atributo. Su rareza dice cuántos niveles da: común %d, rara %d, épica %d, y legendaria %d más +%d a todos los atributos. La SUE hace salir más raras.") % [
						int(rare[0].steps), int(rare[1].steps), int(rare[2].steps), int(rare[3].steps), int(rare[3].get("all_stats", 1))]], 
				[TranslationServer.translate("Reroll y destierro"), 
					TranslationServer.translate("Con las mejoras del Sabio en Prontera: R vuelve a tirar las opciones y B destierra una (no vuelve en esa partida). En la pausa, «Acumular mejoras» guarda las subidas para elegirlas cuando quieras.")], 
				[TranslationServer.translate("Ranuras"), 
					TranslationServer.translate("Llevas hasta %d habilidades y %d pasivas (+%d con el segundo oficio).") % [GameData.MAX_SKILLS, GameData.MAX_PASSIVES, GameData.JOB_EXTRA_PASSIVES]], 
				[TranslationServer.translate("Munición"), 
					(TranslationServer.translate("Los arqueros y pistoleros cambian el tipo de munición tocando el Carcaj.") if MouseWalk.touch()
						else TranslationServer.translate("Los arqueros y pistoleros cambian el tipo de munición con C / V (o haciendo clic en el Carcaj)."))
						+ " " + TranslationServer.translate("Empiezan con la munición normal; las de elemento salen de los cofres (cada uno puede traer una que te falte).")], 
				[TranslationServer.translate("Segundo oficio"), 
					TranslationServer.translate("A nivel %d eliges el segundo oficio de tu clase: cambia tu aspecto, abre sus habilidades y empiezas con una de ellas.") % GameData.JOB_CHANGE_LEVEL], 
				[TranslationServer.translate("Pactos de Gray"), 
					TranslationServer.translate("En Prontera: hasta %d pactos que cambian tu build (ataque básico, procs, invocaciones, estados, una sola habilidad...). El precio es lo que dejas fuera. Valen en todas las partidas de esa clase.") % GameData.MAX_PACTS], 
				[TranslationServer.translate("Peligro"), 
					TranslationServer.translate("Lo eliges antes de cada partida: más peligro, más monstruos, más fuertes y mejores recompensas. Vencer al MVP en tu peligro más alto abre el siguiente. Pasado el %d vienen los niveles de Infierno.") % (GameData.DANGER_HELL_FROM - 1)], 
				[TranslationServer.translate("Endless Tower"), 
					TranslationServer.translate("Se abre al vencer a un MVP en %s. Entras con una de tus builds guardadas (la gasta) y subes piso a piso; tu récord da premios cada 10 pisos y más legendarios para tu Equipo inicial (pestaña Equipo y cartas).") % GameData.danger_name(GameData.TOWER_UNLOCK_DANGER - 1)], 
				[TranslationServer.translate("Al terminar"), 
					TranslationServer.translate("Con victoria te llevas %d objetos al Almacén Kafra gratis; si caes, uno pagando parte de tu zeny. Lo demás se vende solo. Los únicos y lo de la Endless Tower ya están en tu Almacén.") % GameData.KEEP_WIN
						+ " " + TranslationServer.translate("Tu build se guarda sola al terminar cada partida (las %d últimas); entrar a la Endless Tower con una la gasta.") % Save.TOWER_BUILDS_MAX], 
			]
		"damage":
			return [
				[TranslationServer.translate("Cómo se calcula un golpe"), 
					TranslationServer.translate("Daño de la habilidad o del arma × tu «Daño» × el multiplicador de su tipo (básico, habilidad, proc) × el elemento × el crítico si lo es.")], 
				[TranslationServer.translate("Daño (+X% daño)"), 
					TranslationServer.translate("Multiplica TODO tu daño: ataque básico, habilidades, procs, invocaciones y estados.")], 
				[TranslationServer.translate("Daño básico"), 
					(TranslationServer.translate("Solo el ataque básico (y el veneno, la quemadura o el sangrado que aplica). Sube también con FUE: +%s por punto (con INT en las clases mágicas que pegan con ella).") if split()
						else TranslationServer.translate("Solo el ataque básico (y el veneno, la quemadura o el sangrado que aplica). Sube también con FUE: +%s por punto.")) % _pct(GameData.STR_DMG)], 
				[TranslationServer.translate("Daño de habilidades"), 
					TranslationServer.translate("Solo las habilidades. Las físicas suben +%s por punto de FUE y las mágicas +%s por punto de INT; algunas mezclan vida, Def, AGI o SUE. Su tarjeta lo dice en «Sube con».") % [_pct(GameData.INT_SKILL_DMG), _pct(GameData.INT_SKILL_DMG)] if split()
						else TranslationServer.translate("Solo las habilidades, todas: +%s por punto de INT.") % _pct(GameData.INT_SKILL_DMG)], 
				[TranslationServer.translate("+X% daño de habilidades"), 
					TranslationServer.translate("El del equipo, las cartas y las habilidades multiplica el daño de tus habilidades, encima de FUE e INT: +100%% = x%s, +200%% = x%s.") % [_mult(1.0 + GameData.SKILL_DMG_MULT), _mult(1.0 + 2.0 * GameData.SKILL_DMG_MULT)]], 
				[TranslationServer.translate("Daño de procs"), 
					TranslationServer.translate("Los procs «al atacar» crecen como tu ataque básico; los de «al recibir un golpe», con tu FUE y tu vida máxima. Todos crecen además con tu Base Lv: sus textos lo marcan con «×Lv».")], 
				[TranslationServer.translate("Procs al recibir un golpe"), 
					TranslationServer.translate("Cada golpe que te llega tira su probabilidad, también si lo bloqueas (Guard) o se lo come un escudo (Kyrie, Endure...); los que esquivas (Miss, Lucky) no. Cada proc descansa %s s tras salir. Los hacen salir más Faith, el Gospel, Steel Body, el Pacto de Represalia y el equipo Bloody Knight.") % str(Player.PROC_HIT_CD)], 
				[TranslationServer.translate("Daño a MVP"), 
					TranslationServer.translate("Solo contra los MVP (y el Emperium del festival).")], 
				[TranslationServer.translate("Atq"), 
					TranslationServer.translate("En la ventana de estado: el daño de tu ataque básico. No cambia el de tus habilidades.")], 
				[TranslationServer.translate("Elementos"), 
					TranslationServer.translate("El elemento de tu golpe contra el del monstruo multiplica el daño: mira la pestaña Elementos.")], 
			]
		"elements":
			return [
				[TranslationServer.translate("Tabla de elementos"), 
					TranslationServer.translate("Fila: el elemento de tu ataque. Columna: el del monstruo. Verde, hace más daño; rojo, menos. Nunca baja del %s: siempre pega algo.") % _pct(GameData.MIN_ELEMENT_MULT), 
					"element_table"], 
				[TranslationServer.translate("Tu elemento"), 
					TranslationServer.translate("El de cada habilidad sale en su tarjeta. El del ataque básico lo da el arma (las flechas y balas en los arcos y armas de fuego), y Aspersio lo vuelve Sagrado.")], 
				[TranslationServer.translate("El del monstruo"), 
					TranslationServer.translate("El del jefe o MVP sale bajo su barra de vida, con lo que más le duele. Sobre cualquier monstruo sale «¡Eficaz!» si le haces más daño o «Resiste» si le haces menos.")], 
				[TranslationServer.translate("Combos de elementos"), 
					TranslationServer.translate("Un monstruo congelado se vuelve agua y el viento le hace ×1.75; uno de piedra se vuelve tierra y el fuego le hace ×1.5. Sale «¡Combo!».")], 
			]
		"stats":
			var out: = []
			for k in GameData.STATS:
				var s: Dictionary = GameData.STATS[k]
				out.append(["%s  ·  %s" % [TranslationServer.translate(str(s.name)), TranslationServer.translate(str(s.full))], TranslationServer.translate(str(s.desc))])
			if split():
				out.append([TranslationServer.translate("Sube con"), 
					TranslationServer.translate("Cada habilidad dice en su tarjeta con qué atributo crece. Las físicas con FUE, las mágicas con INT; las mixtas, con la mitad de cada uno.")])
			out.append([TranslationServer.translate("Área"), 
				(TranslationServer.translate("FUE e INT (la mayor de las dos) dan +%s de área por punto, hasta +%s. Lo que pasa del tope no se pierde: la mitad se vuelve daño de habilidades.") if split()
					else TranslationServer.translate("INT da +%s de área por punto, hasta +%s. Lo que pasa del tope no se pierde: la mitad se vuelve daño de habilidades.")) % [_pct(GameData.INT_AREA), _pct(GameData.AREA_MAX)]])
			return out
		"speed":
			return [
				[TranslationServer.translate("Crítico"), 
					TranslationServer.translate("Probabilidad de golpe crítico, hasta el 100%. Pueden ser críticos el ataque básico, las habilidades y los procs; el veneno nunca. Lo que pasa del 100% se vuelve daño crítico, punto por punto.")], 
				[TranslationServer.translate("Daño crítico"), 
					TranslationServer.translate("Cuánto pega un crítico (×1.5 al empezar). Desde ×%s todos tus críticos son ultra (×%s más); desde ×%s, uno de cada 4 es letal (×%s más y explota alrededor).") % [
						str(GameData.ULTRA_CRIT_AT), str(GameData.ULTRA_CRIT_BONUS), str(GameData.LETHAL_CRIT_AT), str(GameData.LETHAL_CRIT_BONUS)]], 
				[TranslationServer.translate("ASPD"), 
					TranslationServer.translate("La velocidad del ataque básico: cuanto más cerca de 200, más rápido. El tope es %d (un ataque cada %s s); lo que pasa del tope son golpes extra en cada ataque (el ×N junto al ASPD). AGI y «vel. de ataque» la suben.") % [roundi(200.0 - GameData.MIN_ATTACK_DELAY / 0.02), str(GameData.MIN_ATTACK_DELAY)]], 
				[TranslationServer.translate("Recarga"), 
					TranslationServer.translate("El tiempo entre dos lanzamientos de una habilidad. DES la baja en todas (%s por punto), AGI solo en las físicas (%s por punto), y el equipo con «-X%% recarga». Cada punto rinde algo menos que el anterior: nunca llega a cero.") % [_pct(GameData.DEX_HASTE), _pct(_num("AGI_SKILL_HASTE"))] if _has("AGI_SKILL_HASTE")
						else TranslationServer.translate("El tiempo entre dos lanzamientos de una habilidad. DES la baja en todas (%s por punto), y el equipo con «-X%% recarga». Cada punto rinde algo menos que el anterior: nunca llega a cero.") % _pct(GameData.DEX_HASTE)], 
				[TranslationServer.translate("Doble lanzamiento"), 
					(TranslationServer.translate("Cada punto de FUE (físicas) o INT (mágicas) da +%s de que una habilidad de ataque salga dos veces, hasta el %s.") if split()
						else TranslationServer.translate("Cada punto de INT da +%s de que una habilidad de ataque salga dos veces, hasta el %s.")) % ["%.1f%%" % (GameData.INT_DOUBLE * 100.0), _pct(GameData.INT_DOUBLE_MAX)]], 
				[TranslationServer.translate("Duración"), 
					TranslationServer.translate("DES alarga lo que dura cada habilidad (+%s por punto) y mejora el efecto de las de apoyo: buffs, curaciones y barreras (+%s por punto).") % [_pct(GameData.DEX_DURATION), _pct(GameData.DEX_SUPPORT)]], 
				[TranslationServer.translate("DES en tus buffs de daño"), 
					TranslationServer.translate("Lo que tus propios buffs dan de daño (EDP, Meltdown, velocidad de ataque, crítico...) toma solo +%s por punto de DES. Las curaciones, las barreras y los buffs al grupo, el efecto entero.") % GameData.pct_text(GameData.DEX_SUPPORT * GameData.BUFF_DEX_DMG_SHARE)], 
			]
		"defense":
			return [
				[TranslationServer.translate("Def"), 
					TranslationServer.translate("Reduce todo el daño que recibes, también el mágico: Def ÷ (Def + %d). Cada punto rinde algo menos que el anterior.") % roundi(GameData.DEF_K)], 
				[TranslationServer.translate("VIT"), 
					TranslationServer.translate("Más vida, más regeneración y %s menos de daño recibido por punto (hasta %s).") % ["%.1f%%" % (GameData.VIT_DMG_CUT * 100.0), _pct(GameData.VIT_DMG_CUT_MAX)]], 
				[TranslationServer.translate("Flee (esquiva)"), 
					TranslationServer.translate("Probabilidad de que un golpe falle, hasta el %s. Los jefes ignoran la mitad y los MVP el %s.") % [_pct(GameData.FLEE_CAP), _pct(GameData.MVP_FLEE_IGNORE)]], 
				[TranslationServer.translate("Lucky"), 
					TranslationServer.translate("Esquiva perfecta (SUE), hasta el %s: esquiva cualquier cosa, también golpes de MVP y mecánicas.") % _pct(GameData.PERFECT_DODGE_CAP)], 
				[TranslationServer.translate("Bloqueo (Guard)"), 
					TranslationServer.translate("Con escudo y una habilidad que bloquea (Auto Guard, Shield Mastery...). Un golpe bloqueado no te hace nada de daño (no es una reducción). Cada refinado del escudo suma +%s de probabilidad, hasta el %s. Contra los golpes de un MVP bloquea la mitad de veces.") % ["%s%%" % str(snappedf(GameData.BLOCK_PER_REFINE * 100.0, 0.1)), _pct(GameData.BLOCK_MAX)]], 
				[TranslationServer.translate("Escudos de vida"), 
					TranslationServer.translate("Barreras como Kyrie Eleison o Assumptio: se comen el daño antes que tu vida. Contra un MVP solo absorben el %s de cada golpe.") % _pct(1.0 - GameData.MVP_SHIELD_PIERCE)], 
				[TranslationServer.translate("Mecánicas"), 
					TranslationServer.translate("Los ataques especiales de MVP y eventos: rayos, zonas marcadas en el suelo, los peligros del Infierno. No se esquivan con Flee y el bloqueo los para menos: sal de la zona marcada. El Lucky sí las esquiva.")], 
				[TranslationServer.translate("Infierno"), 
					TranslationServer.translate("Sus peligros atraviesan el %s de los escudos y el Guard casi no los para. Quedarse quieto los empeora (+%s por golpe seguido en el mismo sitio): ¡muévete!") % [_pct(GameData.HELL_SHIELD_PIERCE), _pct(GameData.HELL_STILL_STEP)]], 
			]
		"status":
			return [
				[TranslationServer.translate("Veneno"), 
					TranslationServer.translate("Se acumula: cada dosis suma una carga (hasta %d) y cada carga lo hace más fuerte, hasta ×%s. Además corroe: cada carga hace que el monstruo reciba un %s más de daño de todos. Con las cargas al tope, las dosis de más saltan al monstruo de al lado. Nunca es crítico.") % [GameData.POISON_MAX_STACKS, str(snappedf(GameData.POISON_GROW_MAX, 1)), _pct(GameData.POISON_CORRODE)]], 
				[TranslationServer.translate("Quemadura"), 
					TranslationServer.translate("Rueda: cada llama suma el %s de su golpe al fuego del monstruo (las habilidades mágicas, un %s más) y lo que no ardió se suma a la nueva, sin límite; se apaga %s s después de la última. Cada llama nueva sobre uno que ya arde suma un Calor: +%s por Calor, sin tope, mientras no se apague. Si muere ardiendo, el fuego salta a los de al lado con la mitad de lo que llevaba, y arde más cuantos más monstruos hay ardiendo.") % [_pct(GameData.BURN_IGNITE), _pct(GameData.BURN_MAGIC), str(GameData.BURN_TIME), _pct(GameData.BURN_HEAT)]], 
				[TranslationServer.translate("Sangrado"), 
					TranslationServer.translate("Al principio no hace nada: cada corte guarda el %s de su golpe. Al %dº corte (o a los %s s del último) estalla todo junto ×%s y salpica a los de alrededor.") % [_pct(GameData.BLEED_STORE), GameData.BLEED_BURST_AT, str(GameData.BLEED_TIME), str(GameData.BLEED_BURST_MULT)]], 
				[TranslationServer.translate("De qué crecen"), 
					TranslationServer.translate("Veneno, quemadura y sangrado crecen con el golpe que los aplica: el del ataque básico, con lo que sube el básico; el de una habilidad, con lo que sube esa habilidad. Más «Daño» los sube a todos.")], 
				[TranslationServer.translate("Congelación y piedra"), 
					TranslationServer.translate("El monstruo no se mueve y cambia de elemento: congelado es agua (el viento le hace ×1.75), de piedra es tierra (el fuego le hace ×1.5).")], 
				[TranslationServer.translate("Sueño"), 
					TranslationServer.translate("Un monstruo dormido recibe críticos más fuertes en los %d golpes que tarda en despertar.") % GameData.SLEEP_HITS], 
				[TranslationServer.translate("Aturdimiento y otros"), 
					TranslationServer.translate("Aturdido, ciego o ralentizado: el monstruo deja de pegar o pega peor un rato. Duran como mucho %s s; los élites los sufren la mitad, los jefes y MVP nada (el veneno, la quemadura y el sangrado sí les afectan).") % str(GameData.STATUS_MAX_TIME)], 
			]
		"monsters":


			var rows: = [[TranslationServer.translate("Familias"), 
				TranslationServer.translate("Muchos monstruos comunes hacen algo más que caminar hacia ti. Cada familia tiene su manera, una señal para verla venir y una respuesta. Los jefes, los élites y los MVP no son de ninguna.")]]
			for f in load("res://scripts/core/mob_traits.gd").guide():
				rows.append([str(f[0]), "%s\n%s" % [str(f[1]), str(f[2])]])
			return rows
		"summons":
			return [
				[TranslationServer.translate("De qué crecen"), 
					TranslationServer.translate("Pickies, Tarous, plantas, sombras y demás crecen con el nivel de su habilidad, con lo que sube esa habilidad (como cualquier otra) y con el «Daño de invocaciones». Tu «Daño» también los sube.")], 
				[TranslationServer.translate("Homúnculos"), 
					TranslationServer.translate("Crecen con tu ATK, FUE e INT y con el «Daño de invocaciones».")], 
				[TranslationServer.translate("Daño de invocaciones"), 
					TranslationServer.translate("Solo el de lo que invocas: no cambia tu ataque básico ni tus habilidades.")], 
			]
		"gear":
			var tiers: Array = GameData.ITEM_TIERS
			return [
				[TranslationServer.translate("Rareza"), 
					TranslationServer.translate("El color del nombre: gris, verde, azul y morado tienen de 0 a 3 ranuras para cartas, y los bonus de verde, azul y morado son los del gris por %s, %s y %s. Después vienen los legendarios, los únicos y las alas.") % [
						str(tiers[1].mult), str(tiers[2].mult), str(tiers[3].mult)]], 
				[TranslationServer.translate("Cartas"), 
					TranslationServer.translate("Las sueltan los monstruos (más los élites, jefes y MVP). En la partida se meten solas en una ranura libre del equipo de su tipo; si no hay, esperan en la bolsa de cartas (Q). Las del Álbum se equipan fuera de la partida, en sus huecos, y valen en todas.")], 
				[TranslationServer.translate("Sets"), 
					TranslationServer.translate("Algunas piezas y cartas dan un bonus extra si las llevas juntas. Los sets legendarios tienen 4 piezas: 2 cualesquiera dan su bonus y las 4, uno mayor.")], 
				[TranslationServer.translate("Refinado"), 
					TranslationServer.translate("Hasta +%d con Oridecon (armas) y Elunium (lo demás). Cada nivel sube un %s los bonus del objeto. Las armas de nivel 1 son seguras hasta +%d (las de más nivel, algo menos) y el resto hasta +%d; más arriba puede fallar y bajar un nivel.") % [
						GameData.MAX_REFINE, _pct(GameData.REFINE_STAT_STEP), int(GameData.REFINE_SAFE.weapon), int(GameData.REFINE_SAFE.armor)]], 
				[TranslationServer.translate("Grado del arma"), 
					TranslationServer.translate("En Nakurusa, las armas del Almacén desde +%d suben de grado (D, C, B, A, S) con Oridecon y zeny: cada grado da más daño de todo (hasta %s en S). Puede fallar, pero solo pierdes lo pagado. El recuadro del arma brilla con el color de su grado.") % [
						GameData.GRADE_MIN_REFINE, _pct(float(GameData.WEAPON_GRADES[GameData.WEAPON_GRADES.size() - 1].dmg))]], 
				[TranslationServer.translate("Engarzador y Refinador"), 
					TranslationServer.translate("Ponen cartas en las ranuras y refinan tu equipo en Prontera. ¿No están? Lee los carteles de SE BUSCA de la ciudad: dicen dónde rescatarlos.")], 
				[TranslationServer.translate("Inventario"), 
					TranslationServer.translate("«Equipar lo mejor al recogerlo» se pone solo lo que mejora lo tuyo. Auto-vender vende al recogerlas las rarezas marcadas. «Bloquear» protege un objeto de los filtros.")], 
				[TranslationServer.translate("Equipo inicial y Almacén Kafra"), 
					TranslationServer.translate("Lo que guardas en el Almacén Kafra se pone en el Equipo inicial de cada clase: empiezas cada partida con ello y nunca se pierde. Los únicos y lo que encuentras en la Endless Tower van directo al Almacén.")], 
				[TranslationServer.translate("Límite de legendarios"), 
					TranslationServer.translate("El Equipo inicial lleva %d legendario y %d único. Renacer la clase da +%d legendario, y la Endless Tower +1 en cada uno de los pisos %s. Las clases que no renacen tienen el de renacer desde el principio.") % [
						GameData.LOADOUT_MAX_LEGENDARY, GameData.LOADOUT_MAX_UNIQUE, GameData.REBIRTH_LEGEND_SLOTS, 
						", ".join(GameData.TOWER_REWARDS.keys().filter( func(fl): return str(GameData.TOWER_REWARDS[fl]) == "legend").map( func(fl): return str(fl)))]], 
			]
		"eternal":
			var fuse: Dictionary = GameData.FUSE_COST
			var unsock: Dictionary = GameData.ETERNAL_UNSOCKET_ZENY
			var cost: Array = GameData.SOCKET_COST
			var luck: Array = GameData.SOCKET_CHANCE
			var lcost: Array = GameData.SOCKET_COST_LEGENDARY
			var lluck: Array = GameData.SOCKET_CHANCE_LEGENDARY
			return [
				[TranslationServer.translate("Carta Eterna"), 
					TranslationServer.translate("Una copia de una carta que es tuya para siempre: va engarzada en una pieza de tu Almacén Kafra y te acompaña en cada partida que empieces con esa pieza. No ocupa los huecos de cartas del Álbum.")], 
				[TranslationServer.translate("Cómo se hace"), 
					TranslationServer.translate("En el Álbum, funde copias de una misma carta: %d de una carta normal, %d de la de un jefe o %d de la de un MVP dan 1 Carta Eterna.") % [
						int(fuse.normal), int(fuse.boss), int(fuse.mvp)]], 
				[TranslationServer.translate("Abstract, el Engarzador"), 
					TranslationServer.translate("Es quien abre huecos y engarza las cartas. Se le rescata en la quest «%s» de %s: llévalo hasta la salida (también en modo difícil). Después te espera en Prontera.") % [
						TranslationServer.translate(str(GameData.QUESTS.orc_dun.name)), TranslationServer.translate(str(GameData.STAGES.orc_dun.name))]], 
				[TranslationServer.translate("Abrir un hueco"), 
					TranslationServer.translate("En el equipo normal, %d hueco más como mucho: de %s a %s zeny según su rareza y un %s, %s o %s de éxito. En los legendarios, hasta %d: %s y %s zeny más minerales enriquecidos de jefes y MVP, con un %s y un %s de éxito. Si falla, pagas, pero la pieza no se pierde.") % [
						GameData.SOCKET_MAX_EXTRA, str(int(cost.min())), str(int(cost.max())), _pct(luck[0]), _pct(luck[1]), _pct(luck[2]), 
						GameData.SOCKET_MAX_LEGENDARY, str(int(lcost[0])), str(int(lcost[1])), _pct(lluck[0]), _pct(lluck[1])]], 
				[TranslationServer.translate("Engarzar y quitar"), 
					TranslationServer.translate("En Abstract, haz clic en el hueco «+» de la pieza y elige una Carta Eterna libre: cada copia va en una sola pieza. Quitarla cuesta %d zeny (normal), %d (jefe) o %d (MVP), y la carta vuelve a tu colección.") % [
						int(unsock.normal), int(unsock.boss), int(unsock.mvp)]], 
				[TranslationServer.translate("En la partida"), 
					TranslationServer.translate("Las Cartas Eternas van primero y no se pueden quitar ni cambiar; las cartas que encuentres solo entran en los huecos que queden libres. Los huecos de las alas solo aceptan cartas de MVP.")], 
			]
		"words":
			return [
				[TranslationServer.translate("«Ataques» y «golpes»"), 
					TranslationServer.translate("«Ataque básico» es solo el de tu arma. «Habilidades» son las que eliges al subir. «Todos tus golpes» o «todo tu daño» incluye las dos cosas.")], 
				[TranslationServer.translate("Al atacar / al recibir un golpe"), 
					TranslationServer.translate("Cuándo salta un proc: con tu ataque básico, o cuando un monstruo te pega.")], 
				[TranslationServer.translate("×Lv"), 
					TranslationServer.translate("Ese daño crece con tu Base Lv.")], 
				[TranslationServer.translate("EX"), 
					TranslationServer.translate("La versión evolucionada de una habilidad: llévala a Nv 5 y aprende su pasiva.")], 
				[TranslationServer.translate("Sube con") if split() else "", 
					TranslationServer.translate("El atributo que hace crecer esa habilidad.")], 
				[TranslationServer.translate("Legendario y único"), 
					TranslationServer.translate("Equipo con un efecto que cambia cómo juegas. Los únicos son aún más raros y van directos a tu Almacén Kafra.")], 
				[TranslationServer.translate("Equipo inicial"), 
					TranslationServer.translate("Lo que pones desde el Almacén Kafra: empiezas cada partida con ello y nunca se pierde.")], 
				[TranslationServer.translate("Vida máx. y vida"), 
					TranslationServer.translate("«+X% vida máx.» sube tu vida en un porcentaje; «+X vida», en una cantidad fija. «vida/s» es lo que te curas solo cada segundo.")], 
				[TranslationServer.translate("EXP, zeny e imán"), 
					TranslationServer.translate("Más experiencia y más zeny de los monstruos; el imán es el radio desde el que recoges lo que hay en el suelo.")], 
				[TranslationServer.translate("Proyectiles"), 
					TranslationServer.translate("«+1 a todo lo que lanzas»: una flecha, bala, rayo o golpe más en las habilidades que lanzan varios.")], 
				[TranslationServer.translate("Porcentaje de atributos"), 
					TranslationServer.translate("«+X% STR» (o AGI, VIT...) sube ese atributo en un porcentaje de lo que tienes; «+X% a todos los atributos», a los seis.")], 
				[TranslationServer.translate("Por cada 10 pisos"), 
					TranslationServer.translate("«Por cada 10 pisos de tu récord en la torre»: crece con el piso más alto que alcanzaste en la Endless Tower.")], 
				[TranslationServer.translate("«+X%» y «×N»"), 
					TranslationServer.translate("«+X%» se suma con los demás bonos del mismo tipo; «×N» multiplica todo tu daño.")], 
				[TranslationServer.translate("Bonus que se suman"), 
					TranslationServer.translate("Varios «+X% daño» se suman entre sí; lo que se multiplica son los tipos distintos: daño × daño de habilidades (o básico) × elemento × crítico. Cada golpe varía además un ±10% al azar.")], 
			]
		"options":
			return [
				[TranslationServer.translate("¿Pocos FPS?"), 
					TranslationServer.translate("En Opciones > Gráficos baja la «Cantidad de efectos» o la opacidad de tus efectos (también desde la pausa), o activa el «Modo rendimiento». Si sigue lento, se traba o se congela, prueba otro «Renderizador»: recomendamos Vulkan u OpenGL (se aplica al reiniciar el juego).")], 
			]
	return []
