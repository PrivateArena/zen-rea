extends SceneTree

# [PROBE] Emperium trial cadence. Replays tower_run.gd _start_floor()'s event gate (:545 top floor, :571 the
# event elif) and tower_events.gd's kind roll (_event_w/_event_pick/pick/emp_due/pick_for, :72-135) outside the
# game, over the real consts cut verbatim out of the live layer by mk_probe.py. Nothing else about a floor
# matters for the cadence: every floor is cleared in turn, so floor++ == one floor climbed.
#
# Runs the same gate three ways: stock (no MOD_EVENT_W, no cadence), mod v14 (weights only, cadence off) and
# mod v15 (weights + MOD_EMP_EVERY guarantee).
#
#   python3 mk_probe.py && godot --headless --path . -s res://sim.gd

const C = preload("res://consts.gd")


class Events:
	# verbatim structure of core/tower_events.gd
	var kind: = ""
	var w: = {}
	var every: = 0
	var emp_floor: = -1

	func _event_w(k: String) -> float:
		return float(w.get(k, 1.0))

	func _event_pick(pool: Array) -> String:
		var total: = 0.0
		for k in pool:
			total += _event_w(str(k))
		var r: = randf() * total
		for k in pool:
			r -= _event_w(str(k))
			if r <= 0.0:
				return _note(str(k))
		return _note(str(pool[0]))

	func pick() -> String:
		var pool: Array = C.TOWER_EVENT_KEYS.filter( func(k): return k != kind)
		return _note(_event_pick(pool))

	func emp_due(f: int) -> bool:
		if every <= 0:
			return false
		if emp_floor < 0:
			emp_floor = C.TOWER_EVENT_AT - every
		var d: = f - emp_floor
		if d >= every:
			return true
		if d == every - 1:
			return (f + 1) % C.TOWER_TIER_FLOORS == 0
		return false

	func pick_for(f: int) -> String:
		var k: = ""
		if emp_due(f):
			k = _note("emperium")
		else:
			k = pick()
		if k == "emperium":
			emp_floor = f
		return k

	func _note(k: String) -> String:
		kind = k
		return k


func run(label: String, w: Dictionary, every: int, floors: int) -> void :
	var e := Events.new()
	e.w = w
	e.every = every
	var hits := {}
	var gaps: Array = []
	var last := 0
	var events := 0
	for f in range(1, floors + 1):
		var top: = f % C.TOWER_TIER_FLOORS == 0
		if top:
			continue                                   # MVP / tier-top floor, checked first (:545)
		var is_event: = e.emp_due(f) or (f >= C.TOWER_EVENT_FROM and f % C.TOWER_TIER_FLOORS == C.TOWER_EVENT_AT)
		if not is_event:
			continue
		events += 1
		var k: = e.pick_for(f)
		hits[k] = int(hits.get(k, 0)) + 1
		if k == "emperium":
			if last > 0:
				gaps.append(f - last)
			last = f
	gaps.sort()
	var n: = gaps.size()
	var mean: = float(floors) / maxf(1.0, float(hits.get("emperium", 0)))
	var p50: int = int(gaps[int(n * 0.5)]) if n > 0 else 0
	var p90: int = int(gaps[int(n * 0.9)]) if n > 0 else 0
	var worst: int = int(gaps[n - 1]) if n > 0 else 0
	print("")
	print("== %s   (%d floors, %d event floors = %.2f per floor-block of 10)" % [label, floors, events, 10.0 * events / floors])
	print("   emperium: %d trials  ->  1 every %.2f floors (median gap %d, p90 %d, min %d, worst %d)" % [int(hits.get("emperium", 0)), mean, p50, p90, gaps[0] if n > 0 else 0, worst])
	print("   emperium share of event floors: %.2f %%" % (100.0 * int(hits.get("emperium", 0)) / maxf(1.0, float(events))))
	for k in C.TOWER_EVENT_KEYS:
		print("   %-10s %7d   %6.2f per 100 floors" % [str(k), int(hits.get(k, 0)), 100.0 * int(hits.get(k, 0)) / floors])


func _init():
	randomize()
	var N := 2000000
	print("gate consts (verbatim): EVENT_AT=%d EVENT_FROM=%d TIER_FLOORS=%d  MOD_EVENT_W=%s  MOD_EMP_EVERY=%d" % [C.TOWER_EVENT_AT, C.TOWER_EVENT_FROM, C.TOWER_TIER_FLOORS, C.MOD_EVENT_W, C.MOD_EMP_EVERY])
	run("shipped 0.2.7 (uniform weights, no cadence)", {}, 0, N)
	run("mod v14 (MOD_EVENT_W emperium 9, cadence off)", C.MOD_EVENT_W, 0, N)
	run("mod v15 (MOD_EVENT_W emperium 9 + cadence %d)" % C.MOD_EMP_EVERY, C.MOD_EVENT_W, C.MOD_EMP_EVERY, N)
	run("control: cadence %d only, shipped weights" % C.MOD_EMP_EVERY, {}, C.MOD_EMP_EVERY, N)
	quit()
