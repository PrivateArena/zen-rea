extends Node













var _log = HLog.logger("HFriends")






func _ready() -> void :
	pass








func get_friends_async() -> Array:
	_log.debug("Getting friends...")

	var query_opts = EOS.Friends.QueryFriendsOptions.new()
	EOS.Friends.FriendsInterface.query_friends(query_opts)

	var ret = await IEOS.friends_interface_query_friends_callback

	if not EOS.is_success(ret):
		_log.error("Failed to query friends: result_code=%s" % EOS.result_str(ret))
		return []

	var get_count_opts = EOS.Friends.GetFriendsCountOptions.new()
	var friends_count: int = EOS.Friends.FriendsInterface.get_friends_count(get_count_opts)

	var user_infos = []
	for i: int in friends_count:
		var opts = EOS.Friends.GetFriendAtIndexOptions.new()
		opts.index = i

		var friend_epic_account_id = EOS.Friends.FriendsInterface.get_friend_at_index(opts)
		var user_info = await HAuth.get_user_info_async(friend_epic_account_id)
		if user_info:
			user_infos.append(user_info)
	return user_infos
