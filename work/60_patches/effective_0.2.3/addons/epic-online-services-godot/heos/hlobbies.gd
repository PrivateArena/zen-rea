extends Node






var max_search_results = 25


var presence_enabled = true








var local_rtc_options = {
	flags = EOS.RTC.JoinRoomFlags.EnableDataChannel
}






var _log = HLog.logger("HLobbies")







func create_lobby_async(opts: EOS.Lobby.CreateLobbyOptions) -> HLobby:
	_log.debug("Creating lobby...")
	EOS.Lobby.LobbyInterface.create_lobby(opts)

	var ret = await IEOS.lobby_interface_create_lobby_callback
	if not EOS.is_success(ret):
		_log.error("Failed to create lobby: %s" % EOS.result_str(ret))
		return null

	_log.debug("Lobby created: lobby_id=%s" % ret.lobby_id)

	var lobby = HLobby.new()
	lobby.init_from_id(ret.lobby_id)
	return lobby





func join_by_id_async(lobby_id: String) -> HLobby:
	_log.debug("Joining lobby by id: lobby_id=%s" % lobby_id)

	var opts = EOS.Lobby.JoinLobbyByIdOptions.new()
	opts.lobby_id = lobby_id
	opts.presence_enabled = presence_enabled
	opts.local_rtc_options = local_rtc_options
	EOS.Lobby.LobbyInterface.join_lobby_by_id(opts)

	var ret = await IEOS.lobby_interface_join_lobby_by_id_callback
	if not EOS.is_success(ret):
		_log.error("Failed to join lobby: result_code=%s" % EOS.result_str(ret))
		return null

	_log.debug("Lobby joined: lobby_id=%s" % lobby_id)

	var lobby = HLobby.new()
	lobby.init_from_id(lobby_id)
	return lobby




func join_async(lobby: HLobby):
	if not lobby:
		return null
	_log.debug("Joining lobby...")

	var opts = EOS.Lobby.JoinLobbyOptions.new()
	opts.lobby_details = lobby._lobby_details
	opts.presence_enabled = presence_enabled
	opts.local_rtc_options = local_rtc_options
	EOS.Lobby.LobbyInterface.join_lobby(opts)

	var ret = await IEOS.lobby_interface_join_lobby_callback
	if not EOS.is_success(ret):
		_log.error("Failed to join lobby: result_code=%s" % EOS.result_str(ret))
		return null

	_log.debug("Lobby joined: lobby_id=%s" % ret.lobby_id)

	var new_lobby = HLobby.new()
	new_lobby.init_from_id(ret.lobby_id)
	return new_lobby




func search_by_product_user_id_async(product_user_id: String):
	_log.debug("Searching for lobbies by product user id: product_user_id=%s" % product_user_id)
	var opts = EOS.Lobby.CreateLobbySearchOptions.new()
	opts.max_results = max_search_results

	var search: EOSGLobbySearch = create_search(opts)
	if not search:
		return null

	search.set_target_user_id(product_user_id)

	return await search_async(search)











func search_by_attribute_async(attributes):
	if typeof(attributes) == TYPE_DICTIONARY:
		attributes = [attributes]
	_log.debug("Searching for lobbies by attributes: attributes=%s" % str(attributes))
	var opts = EOS.Lobby.CreateLobbySearchOptions.new()
	opts.max_results = max_search_results

	var search: EOSGLobbySearch = create_search(opts)
	if not search:
		return null

	for attr in attributes:
		if attr.has("comparison"):
			search.set_parameter(attr.key, attr.value, attr.comparison)
		else:
			search.set_parameter(attr.key, attr.value, EOS.ComparisonOp.Equal)

	return await search_async(search)




func search_by_lobby_id_async(lobby_id: String):
	_log.debug("Searching for lobbies by lobby id: lobby_id=%s" % lobby_id)
	var opts = EOS.Lobby.CreateLobbySearchOptions.new()
	opts.max_results = max_search_results

	var search: EOSGLobbySearch = create_search(opts)
	if not search:
		return null

	search.set_lobby_id(lobby_id)

	return await search_async(search)




func search_by_bucket_id_async(bucket_id: String):
	_log.debug("Searching for lobbies by bucket id: bucket_id=%s" % bucket_id)
	return await HLobbies.search_by_attribute_async({
		key = EOS.Lobby.SEARCH_BUCKET_ID, 
		value = bucket_id, 
		comparison = EOS.ComparisonOp.Equal
	})



func create_search(opts: EOS.Lobby.CreateLobbySearchOptions):
	_log.debug("Creating lobby search...")

	var create_ret = EOS.Lobby.LobbyInterface.create_lobby_search(opts)
	if not EOS.is_success(create_ret):
		_log.error("Failed to create lobby search: result_code=%s" % EOS.result_str(create_ret))
		return null

	return create_ret.lobby_search



func search_async(lobby_search: EOSGLobbySearch):
	_log.debug("Searching for lobbies...")

	lobby_search.find(HAuth.product_user_id)

	var search_ret = await IEOS.lobby_search_find_callback
	if not EOS.is_success(search_ret):
		_log.error("Failed to search for lobbies: result_code=%s" % EOS.result_str(search_ret))
		return null

	var count = lobby_search.get_search_result_count()
	_log.debug("Found lobbies: count=%s" % count)

	var lobbies: Array[HLobby] = []
	for search_idx in count:
		var copy_ret = lobby_search.copy_search_result_by_index(search_idx)
		if not EOS.is_success(copy_ret):
			_log.error("Failed to copy lobby search result by index: result_code=%s" % EOS.result_str(copy_ret))
			continue

		var lobby = HLobby.new()
		var details = copy_ret.lobby_details
		lobby._init_from_details(details)
		lobbies.append(lobby)

	return lobbies
