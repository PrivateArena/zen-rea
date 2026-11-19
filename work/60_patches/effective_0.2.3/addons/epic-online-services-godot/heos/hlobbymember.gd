
class_name HLobbyMember
extends BaseClass





signal rtc_state_updated






var product_user_id: String
var epic_account_id: String
var display_name: String


var attributes = []

var rtc_state = {
	is_in_rtc_room = false, 
	is_talking = false, 
	is_locally_muted = false, 
	is_hard_muted = false, 
	is_audio_output_disabled = false, 
}






var _attributes_to_add = []

var _lobby: HLobby

var _log = HLog.logger("HLobbyMember")






func _init(p_lobby: HLobby) -> void :
	super._init("HLobbyMember")

	_lobby = p_lobby







func get_attribute(key: String):
	for attr in attributes:
		if attr.key == key:
			return attr
	return {}



func is_muted() -> bool:
	if HAuth.product_user_id == product_user_id:
		return rtc_state.is_audio_output_disabled
	else:
		return rtc_state.is_locally_muted



func is_hard_muted() -> bool:
	return rtc_state.is_hard_muted



func is_owner() -> bool:
	return _lobby.owner_product_user_id == product_user_id





func toggle_mute_member_async() -> bool:
	var _is_muted = is_muted()
	var action = "Unmuting" if _is_muted else "Muting"

	if not _lobby or not _lobby.rtc_room_name:
		return false

	if HAuth.product_user_id == product_user_id:

		_log.debug("%s ourself" % action)

		var opts: EOS.RTCAudio.UpdateSendingOptions = EOS.RTCAudio.UpdateSendingOptions.new()
		opts.room_name = _lobby.rtc_room_name
		opts.audio_status = EOS.RTCAudio.AudioStatus.Enabled if _is_muted else EOS.RTCAudio.AudioStatus.Disabled

		EOS.RTCAudio.RTCAudioInterface.update_sending(opts)
		var ret = await IEOS.rtc_audio_interface_update_sending_callback
		if not EOS.is_success(ret):
			_log.error("Failed to update audio sending: result_code=%s" % EOS.result_str(ret))
			return false

		var did_update = HLog._check_diff_and_set_dict(rtc_state, "is_audio_output_disabled", ret.audio_status == EOS.RTCAudio.AudioStatus.Disabled, "member:" + product_user_id)
		if did_update:
			rtc_state_updated.emit()
			_lobby.lobby_updated.emit()

		return true
	else:
		_log.debug("%s member: product_user_id=%s" % [action, product_user_id])

		var opts: EOS.RTCAudio.UpdateReceivingOptions = EOS.RTCAudio.UpdateReceivingOptions.new()
		opts.room_name = _lobby.rtc_room_name
		opts.participant_id = product_user_id
		opts.audio_enabled = _is_muted

		EOS.RTCAudio.RTCAudioInterface.update_receiving(opts)
		var ret = await IEOS.rtc_audio_interface_update_receiving_callback
		if not EOS.is_success(ret):
			_log.error("Failed to update audio receiving: result_code=%s" % EOS.result_str(ret))
			return false

		var did_update = HLog._check_diff_and_set_dict(rtc_state, "is_locally_muted", ret.audio_enabled == false, "member:" + product_user_id)
		if did_update:
			rtc_state_updated.emit()
			_lobby.lobby_updated.emit()

	return true



func toggle_hard_mute_member_async() -> bool:
	if not _lobby.is_owner():
		return false
	var _is_hard_muted = is_hard_muted()
	var action = "Un hard-muting" if _is_hard_muted else "Hard-muting"
	_log.debug("%s member: product_user_id=%s" % [action, product_user_id])

	var opts: EOS.Lobby.HardMuteMemberOptions = EOS.Lobby.HardMuteMemberOptions.new()
	opts.lobby_id = _lobby.lobby_id
	opts.target_user_id = product_user_id
	opts.hard_mute = not _is_hard_muted
	EOS.Lobby.LobbyInterface.hard_mute_member(opts)

	var ret = await IEOS.lobby_interface_hard_mute_member_callback
	if not EOS.is_success(ret):
		_log.error("Failed to %s member: result_code=%s" % [action, EOS.result_str(ret)])
		return false

	rtc_state.is_hard_muted = not _is_hard_muted
	rtc_state_updated.emit()
	_lobby.lobby_updated.emit()

	return true



func kick_member_async() -> bool:
	if not _lobby.is_owner():
		return false

	_log.debug("Kicking member: product_user_id=%s" % product_user_id)

	var opts = EOS.Lobby.KickMemberOptions.new()
	opts.lobby_id = _lobby.lobby_id
	opts.target_user_id = product_user_id

	EOS.Lobby.LobbyInterface.kick_member(opts)
	var ret = await IEOS.lobby_interface_kick_member_callback
	if not EOS.is_success(ret):
		_log.error("Failed to kick member: result_code=%s" % EOS.result_str(ret))
		return false

	_log.debug("Kick member was successful: product_user_id=%s" % product_user_id)

	return true



func promote_member_async() -> bool:
	if not _lobby.is_owner():
		return false

	_log.debug("Promoting member: product_user_id=%s" % product_user_id)

	var opts = EOS.Lobby.PromoteMemberOptions.new()
	opts.lobby_id = _lobby.lobby_id
	opts.target_user_id = product_user_id
	EOS.Lobby.LobbyInterface.promote_member(opts)

	var ret = await IEOS.lobby_interface_promote_member_callback
	if not EOS.is_success(ret):
		_log.error("Failed to promote member: result_code=%s" % EOS.result_str(ret))
		return false

	_log.debug("Promote member was successful: product_user_id=%s" % product_user_id)

	return true



func is_self() -> bool:
	return product_user_id == HAuth.product_user_id
