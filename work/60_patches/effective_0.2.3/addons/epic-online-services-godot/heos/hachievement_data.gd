
class_name HAchievementData
extends BaseClass


func _init() -> void :
	super._init("HAchievementData")


var achievement_id: String


var unlocked_display_name: String


var unlocked_description: String


var unlocked_icon_url: String


var locked_display_name: String


var locked_description: String


var locked_icon_url: String


var flavor_text: String


var is_hidden: bool


var progress: float = 0.0


var unlock_time: int = EOS.Achievement.UNLOCK_TIME_UNDEFINED


var stats = []



func is_unlocked() -> bool:
	return unlock_time != EOS.Achievement.UNLOCK_TIME_UNDEFINED



func get_display_name() -> String:
	if is_unlocked():
		return unlocked_display_name
	return locked_display_name



func get_description() -> String:
	if is_unlocked():
		return unlocked_description
	return locked_description



func get_icon_url() -> String:
	if is_unlocked():
		return unlocked_icon_url
	return locked_icon_url


func update_stat(p_stat: Dictionary) -> void :
	var found = false
	for i: int in stats.size():
		var stat = stats[i]
		if stat.name == p_stat.name:
			stats[i] = p_stat
			found = true
			break

	if not found:
		stats.append(p_stat)
