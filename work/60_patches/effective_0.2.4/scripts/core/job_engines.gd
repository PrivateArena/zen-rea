extends RefCounted















const SL_POWER: = 2.4
const SL_RES_STEP: = 0.2
const SL_RES_MAX: = 20
const SL_RES_GAP: = 0.1
const SL_RES_LOSE: = 2.0
const SMITH_POWER: = 2.0
const SMITH_BROKEN: = 5.0
const SMITH_HEAT: = 0.3
const SMITH_CART: = ["cart_termination", "cart_cannon", "cart_revolution", "mammonite"]
const BARD_POWER: = 1.6
const BARD_BIS: = 2.5
const BARD_VULCAN: = 0.25
const LORD_KNIGHT: = preload("res://scripts/core/lord_knight.gd")
const PALADIN: = preload("res://scripts/core/paladin.gd")


static func mult(world: World, p: Player, e: Enemy, tag: String, source: String) -> float:
	if p == null or source == "poison":
		return 1.0
	var m: = 1.0
	var job: = str(p.job2.get("id", ""))
	if job == "soul_linker" and World.SoulLinker.is_spirit(tag):
		m *= SL_POWER * (1.0 + SL_RES_STEP * resonance(world, p, true))
	elif p.forge_on():
		var base: = Player.base_skill(tag)
		if base in SMITH_CART:
			m *= 1.0 + SMITH_HEAT * p.forge_temp_levels()
		if e.is_boss and e.status == "stun":
			m *= SMITH_BROKEN
		if source == "skill" or source == "basic":
			m *= SMITH_POWER
	elif job == "paladin":

		m *= PALADIN.mult(world, p, e, tag)
	elif job == "lord_knight":

		if source == "skill" and Player.base_skill(tag) == "spiral_pierce":
			LORD_KNIGHT.pierce_hit(world, p)
		m *= LORD_KNIGHT.mult(p, tag)
	elif p.performer() != "":
		if p.bis_t > 0.0:
			m *= BARD_BIS
		if Player.base_skill(tag) == "arrow_vulcan":
			m *= 1.0 + BARD_VULCAN * p.songs.size()
		if source == "skill" or source == "basic":
			m *= BARD_POWER
	return m



static func resonance(world: World, p: Player, hit: = false) -> int:
	var n: = int(p.get_meta("sl_res", 0))
	var last: = float(p.get_meta("sl_res_at", -99.0))
	if world.clock - last > SL_RES_LOSE:
		n = 0
	if hit and world.clock - last >= SL_RES_GAP:
		n = mini(SL_RES_MAX, n + 1)
		p.set_meta("sl_res_at", world.clock)
	p.set_meta("sl_res", n)
	return n
