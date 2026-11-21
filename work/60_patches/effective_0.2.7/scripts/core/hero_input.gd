class_name HeroInput
extends RefCounted





func move_vector(_hero: Player, _world: World) -> Vector2:
	return Vector2.ZERO



static func typing(n: Node) -> bool:
	var f: = n.get_viewport().gui_get_focus_owner()
	return f is LineEdit or f is TextEdit




class Local extends HeroInput:
	func move_vector(hero: Player, world: World) -> Vector2:

		var v: = Vector2.ZERO if HeroInput.typing(world) else\
		MouseWalk.screen_to_world(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
		if v != Vector2.ZERO:
			world.mouse_walk.cancel()
		else:
			v = world.mouse_walk.input_vector(hero.position)
		if world.autopilot:
			v = world.autopilot_input()
		return v





class Remote extends HeroInput:
	var pos: = Vector3.INF
	var stick: = Vector2.ZERO
	var fresh: = false


	var placed: = Vector3.INF


	var deaf_until: = 0
	var next_place: = 0

	func move_vector(_hero: Player, _world: World) -> Vector2:
		return stick




class BotHero extends HeroInput:
	func move_vector(hero: Player, world: World) -> Vector2:
		var goal: = Vector3.INF
		var lead: = world.player
		var fallen: = world.fallen_ally(hero)
		var raid_goal: Vector3 = world.raid.autopilot_goal(hero) if world.raid.state == "fight" else Vector3.INF
		if fallen != null:
			goal = fallen.position
		elif raid_goal != Vector3.INF:
			goal = raid_goal
		elif lead != null and lead != hero and not lead.downed and lead.position.distance_to(hero.position) > 12.0:
			goal = lead.position
		return Bot.steer(world, goal, hero)
