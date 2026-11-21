extends RefCounted









const SKINS: = {
	"astral": {"name": "Astral Archmage", "color": Color(0.55, 0.45, 1.0), "accent": Color(1.0, 0.85, 0.4), 
		"bodies": {
			"mage": {"pal": "c8f8d3ffffff000000f285593b120f6e4634d6b8c7bd9fb0fff4bcae8be4986dd68558c57144b46035a1532c8f46237effdec4fabbabf49892e97e7acb6266b246518c353e6e252dfff0e5eccac6d8a6a2fff1a8f8d973ebbb41ce9222a66a154b5fbf3547a72d3a92252d7c1e236718195112123e0d0c2dededffcecce0afa7c1958ba77a6f8c645e7747435929273bf7f0e5ffe1cfffc6b2f6ae9fdc9084bd736b9e5652823f3bfff3eb4a2da439218c2d196f221253a98f8b997b7b89676b5267c84255b53243a22a368b2228741d21631616490f0f345637b64d30a943289b39208a2f1a7224135a1e104b160c375838b84b2ea63f2596331d7d2815621e104b140b33673429ff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ff", 
				"cloth": [[72, 86], [57, 60], [9, 15]], "gold": [[27, 31]], "cape": [[64, 71], [32, 39]]}, 
			"mage_f": {"pal": "c8f8d3ffffff000000f285593b120f6e4634d6b8c7bd9fb0576ccd4c60c03547a72b378d2228741a1d591414430f0e32ffdec4fabbabfeeda0d89f2c6b390bb246518c353e6e252d576ccd4053b32f3e992832862128731b1e5d1515460f0e32deb3a2b4a2f39177e36d4ec84e31ab39218b2916661b0f44ededffcecce0afa7c1958ba77a6f8c645e7747435929273bf7f0e5ffe1cfffc6b2f6ae9fdc9084bd736b9e5652823f3bfeeda0e7b53cae70166b390bb8a39ba98f8b997b7b89676bc9b0f4b190e6996ed78053c1673aaa59309744227a33195ffdeb9af8d872f2c64adfa933c5871ba26614884f0f6b390bfeeda0ffdeacffc08ceba171cf855cb269478d4e39673429ff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ffff00ff", 
				"cloth": [[33, 39], [64, 71]], "gold": [[18, 20], [56, 59], [72, 80]], "cape": [[8, 15], [24, 31]]}, 
		}}, 
}



static func palette_id(skin: String, body_key: String) -> String:
	if SKINS.has(skin) and (SKINS[skin].bodies as Dictionary).has(body_key):
		return "skin_%s_%s" % [skin, body_key]
	return ""




static func palette(id: String) -> String:
	var mask: = id.begins_with("skinmask_")
	var rest: = id.trim_prefix("skinmask_" if mask else "skin_")
	for skin in SKINS:
		if not rest.begins_with(str(skin) + "_"):
			continue
		var body: = rest.trim_prefix(str(skin) + "_")
		var b: Dictionary = (SKINS[skin].bodies as Dictionary).get(body, {})
		if b.is_empty():
			return ""
		if not mask:
			return str(b.pal)
		var out: = PackedByteArray()
		out.resize(768)
		for zone in [["cloth", 0], ["gold", 1], ["cape", 2]]:
			for r in b[zone[0]]:
				for i in range(int(r[0]), int(r[1]) + 1):
					out[i * 3 + int(zone[1])] = 255
		return out.hex_encode()
	return ""


static func info(skin: String) -> Dictionary:
	return SKINS.get(skin, {})
