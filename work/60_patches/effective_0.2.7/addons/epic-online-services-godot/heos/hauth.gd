
extends Node




signal logged_in


signal logged_out


signal login_error(result_code: EOS.Result)


signal logged_in_auth


signal logged_out_auth


signal login_auth_error(result_code: EOS.Result)


signal logged_in_connect


signal logged_out_connect


signal login_connect_error(result_code: EOS.Result)




signal display_name_changed




signal external_account_info_changed







var epic_account_id: String = ""


var product_user_id: String = ""


var display_name: String



var auto_fetch_external_account: bool = true



var external_account_info: Dictionary = {}



var auto_link_account: bool = true


var auto_connect_account: bool = true



var auth_login_scope_flags: int = EOS.Auth.ScopeFlags.BasicProfile | EOS.Auth.ScopeFlags.Presence | EOS.Auth.ScopeFlags.FriendsList



var auth_login_flags: int = EOS.Auth.LoginFlags.None






var _log = HLog.logger("HAuth")
var _last_connect_login_opts: EOS.Connect.LoginOptions





func _ready() -> void :
	IEOS.connect_interface_auth_expiration.connect(_on_connect_interface_auth_expiration)








func login_devtool_async(server_url: String, credential_name: String) -> bool:
	_log.debug("Logging in using Epic Dev Auth tool...")
	var opts = EOS.Auth.LoginOptions.new()
	opts.credentials = EOS.Auth.Credentials.new()
	opts.credentials.type = EOS.Auth.LoginCredentialType.Developer
	opts.credentials.id = server_url
	opts.credentials.token = credential_name
	opts.scope_flags = auth_login_scope_flags
	opts.login_flags = auth_login_flags

	return await login_async(opts)



func login_account_portal_async() -> bool:
	_log.debug("Logging in using Epic Account Portal...")
	var opts = EOS.Auth.LoginOptions.new()
	opts.credentials = EOS.Auth.Credentials.new()
	opts.credentials.type = EOS.Auth.LoginCredentialType.AccountPortal
	opts.scope_flags = auth_login_scope_flags
	opts.login_flags = auth_login_flags

	return await login_async(opts)





func login_launcher_async() -> bool:
	_log.debug("Logging in using Epic Games Launcher...")
	var cli_opts = _get_command_line_options()
	var auth_password = cli_opts.get("AUTH_PASSWORD", "")

	if "" == auth_password:
		_log.error("Missing -AUTH_PASSWORD=<exchange_code> cli argument. Please see usage docs.")
		return false

	var opts = EOS.Auth.LoginOptions.new()
	opts.credentials = EOS.Auth.Credentials.new()
	opts.credentials.type = EOS.Auth.LoginCredentialType.ExchangeCode
	opts.credentials.token = auth_password
	opts.scope_flags = auth_login_scope_flags
	opts.login_flags = auth_login_flags

	return await login_async(opts)





func login_async(opts: EOS.Auth.LoginOptions) -> bool:
	_log.debug("Logging into Epic Account Services (AuthInterface)...")
	EOS.Auth.AuthInterface.login(opts)

	var auth_login_ret: Dictionary = await IEOS.auth_interface_login_callback
	var auth_res: EOS.Result = auth_login_ret.result_code

	if auth_res == EOS.Result.AuthMFARequired:
		_log.error("Auth requires MFA - This is not supported by the EOS SDK. Please use an account without MFA or use an alternative login method")
		_emit_login_auth_error(auth_res)
		return false

	if auth_res == EOS.Result.InvalidUser:
		if not auth_login_ret.continuance_token:
			_log.error("Auth login failed - Continuance token is invalid")
			_emit_login_auth_error(EOS.Result.InvalidState)
			return false

		if not auto_link_account:
			_log.error("Auth login failed - External account not connected")
			_emit_login_auth_error(EOS.Result.InvalidUser)
			return false

		_log.debug("External account not found. Proceeding to connect account...")
		var continue_success = await _continue_login_async(auth_login_ret.continuance_token)
		if not continue_success:
			return false

	elif not EOS.is_success(auth_res):
		_log.error("Failed to login with EOS Auth: result_code=%s" % EOS.result_str(auth_res))
		_emit_login_auth_error(auth_res)
		return false

	if auth_login_ret.selected_account_id:
		epic_account_id = auth_login_ret.selected_account_id

	if epic_account_id:
		_log.info("Logged into Epic Account Services with Epic Account ID: %s" % epic_account_id)

	if not auto_connect_account:
		logged_in_auth.emit()
		logged_in.emit()
		return true

	return await _connect_account_async()



func logout_async() -> EOS.Result:
	_log.verbose("Logging out from EOS...")
	var ret: EOS.Result = EOS.Result.InvalidAuth
	var _logged_out = false

	if product_user_id:
		_log.debug("Logging out from EOS Connect")
		var logout_connect_opts = EOS.Connect.LogoutOptions.new()
		EOS.Connect.ConnectInterface.logout(logout_connect_opts)
		var logout_connect_ret = await IEOS.connect_interface_logout_callback
		ret = logout_connect_ret.result_code

		if not EOS.is_success(ret):
			_log.error("Failed to logout of EOS Connect. result_code=%s" % EOS.result_str(ret))
			return ret
		else:
			_log.debug("Logged out from EOS connect: product_user_id=%s" % product_user_id)
			product_user_id = ""
			_logged_out = true
			logged_out_connect.emit()


	if epic_account_id:
		_log.debug("Logging out from EOS Auth")
		var logout_auth_opts = EOS.Auth.LogoutOptions.new()
		EOS.Auth.AuthInterface.logout(logout_auth_opts)
		var logout_auth_ret = await IEOS.auth_interface_logout_callback
		ret = logout_auth_ret.result_code

		if not EOS.is_success(ret):
			_log.error("Failed to logout of EOS Auth. result_code=%s" % EOS.result_str(ret))
		else:
			_log.debug("Logged out from EOS Auth: epic_account_id=%s" % epic_account_id)
			epic_account_id = ""
			_logged_out = true
			logged_out_auth.emit()


	if _logged_out:
		display_name = ""
		external_account_info = {}
		display_name_changed.emit()
		external_account_info_changed.emit()
		logged_out.emit()

	return ret



func login_game_services_async(opts: EOS.Connect.LoginOptions) -> bool:
	_log.debug("Logging into Epic Game Services (ConnectInterface)...")
	_last_connect_login_opts = opts
	EOS.Connect.ConnectInterface.login(opts)

	var login_ret: Dictionary = await IEOS.connect_interface_login_callback
	var login_res: EOS.Result = login_ret.result_code

	if login_res == EOS.Result.InvalidUser:
		_log.debug("Epic Game Services user not found. Proceeding to create user...")
		var create_success: bool = await _create_user_async(login_ret.continuance_token)
		if not create_success:
			return false

	elif not EOS.is_success(login_ret):
		_log.error("Failed to login to Epic Game Services: result_code=%s" % EOS.result_str(login_res))
		_emit_login_connect_error(login_res)
		return false

	if login_ret.local_user_id:
		product_user_id = login_ret.local_user_id

	if product_user_id:
		_log.info("Logged into Epic Games Services with Product User ID: %s" % product_user_id)
		if auto_fetch_external_account and EOS.ExternalCredentialType.DeviceidAccessToken != opts.credentials.type:
			get_product_user_info_async()

	logged_in_connect.emit()
	logged_in.emit()
	return true



func login_persistent_auth_async() -> bool:
	_log.debug("Logging in with persistent auth...")
	var opts = EOS.Auth.LoginOptions.new()
	opts.credentials = EOS.Auth.Credentials.new()
	opts.credentials.type = EOS.Auth.LoginCredentialType.PersistentAuth
	opts.scope_flags = auth_login_scope_flags
	opts.login_flags = auth_login_flags

	return await login_async(opts)



func delete_persistent_auth_async(refresh_token: String = "") -> bool:
	_log.debug("Deleting persistent auth...")
	var opts = EOS.Auth.DeletePersistentAuthOptions.new()
	opts.refresh_token = refresh_token
	EOS.Auth.AuthInterface.delete_persistent_auth(opts)

	var ret = await IEOS.auth_interface_delete_persistent_auth_callback
	if not EOS.is_success(ret):
		_log.error("Failed to delete persistent auth: result_code=%s" % EOS.result_str(ret))
		return false

	return true




func login_anonymous_async(p_user_display_name: String) -> bool:
	var user_display_name: String = p_user_display_name.strip_edges()
	if not p_user_display_name:
		_log.error("User display name is empty")
		return false
	_log.debug("Logging in anonymously...")

	EOS.Connect.ConnectInterface.delete_device_id(EOS.Connect.DeleteDeviceIdOptions.new())
	var delete_ret = await IEOS.connect_interface_delete_device_id_callback
	if not EOS.is_success(delete_ret):
		_log.debug("Failed to delete device id: result_code=%s" % EOS.result_str(delete_ret))

	var opts = EOS.Connect.CreateDeviceIdOptions.new()
	opts.device_model = " ".join(PackedStringArray([OS.get_name(), OS.get_model_name()]))
	EOS.Connect.ConnectInterface.create_device_id(opts)

	var create_ret = await IEOS.connect_interface_create_device_id_callback
	if not EOS.is_success(create_ret):
		_log.error("Failed to create device id: result_code=%s" % EOS.result_str(create_ret))
		return false

	var login_opts = EOS.Connect.LoginOptions.new()
	login_opts.credentials = EOS.Connect.Credentials.new()
	login_opts.credentials.type = EOS.ExternalCredentialType.DeviceidAccessToken
	login_opts.credentials.token = null
	login_opts.user_login_info = EOS.Connect.UserLoginInfo.new()
	login_opts.user_login_info.display_name = user_display_name
	display_name = user_display_name
	display_name_changed.emit()

	return await login_game_services_async(login_opts)











func get_user_info_async(p_epic_account_id: String = epic_account_id) -> Dictionary:
	_log.verbose("Querying user info: epic_account_id=%s" % p_epic_account_id)
	var query_opts = EOS.UserInfo.QueryUserInfoOptions.new()
	query_opts.local_user_id = epic_account_id
	query_opts.target_user_id = p_epic_account_id
	EOS.UserInfo.UserInfoInterface.query_user_info(query_opts)

	var ret: Dictionary = await IEOS.user_info_interface_query_user_info_callback
	if not EOS.is_success(ret):
		_log.error("Failed to query user info: result_code=%s" % EOS.result_str(ret))
		return {}

	var copy_opts = EOS.UserInfo.CopyUserInfoOptions.new()
	copy_opts.local_user_id = epic_account_id
	copy_opts.target_user_id = p_epic_account_id
	var copy_ret = EOS.UserInfo.UserInfoInterface.copy_user_info(copy_opts)
	if not EOS.is_success(copy_ret):
		_log.error("Failed to copy user info: result_code=%s" % EOS.result_str(copy_ret))
		return {}

	return copy_ret.user_info











func get_external_account_by_type_async(p_external_account_type: EOS.ExternalAccountType, p_product_user_id: String = product_user_id) -> Dictionary:
	_log.debug("Getting external account by type: external_account_type=%s product_user_id=%s" % [p_external_account_type, p_product_user_id])

	var opts = EOS.Connect.QueryProductUserIdMappingsOptions.new()
	opts.product_user_ids = [p_product_user_id]
	EOS.Connect.ConnectInterface.query_product_user_id_mappings(opts)
	var ret = await IEOS.connect_interface_query_product_user_id_mappings_callback
	if not EOS.is_success(ret):
		_log.error("Failed to query product user id mappings: result_code=%s" % EOS.result_str(ret))
		return {}

	var copy_opts = EOS.Connect.CopyProductUserExternalAccountByAccountTypeOptions.new()
	copy_opts.account_id_type = p_external_account_type
	copy_opts.target_user_id = p_product_user_id
	var copy_ret = EOS.Connect.ConnectInterface.copy_product_user_external_account_by_account_type(copy_opts)
	if not EOS.is_success(copy_ret):
		_log.error("Failed to copy external account: result_code=%s" % EOS.result_str(copy_ret))
		return {}

	_log.debug("Got external account info: product_user_id=%s" % p_product_user_id)

	var acc_info = copy_ret.external_account_info
	if not acc_info:
		acc_info = {}
		_log.error("Failed to get external account info")

	return acc_info




func get_external_accounts_async(p_product_user_id: String = product_user_id) -> Array:
	_log.debug("Getting all external accounts: product_user_id=%s" % p_product_user_id)

	var opts = EOS.Connect.QueryProductUserIdMappingsOptions.new()
	opts.product_user_ids = [p_product_user_id]
	EOS.Connect.ConnectInterface.query_product_user_id_mappings(opts)
	var ret = await IEOS.connect_interface_query_product_user_id_mappings_callback
	if not EOS.is_success(ret):
		_log.error("Failed to query product user id mappings: result_code=%s" % EOS.result_str(ret))
		return []


	var count_opts = EOS.Connect.GetProductUserExternalAccountCountOptions.new()
	count_opts.target_user_id = p_product_user_id
	var count = EOS.Connect.ConnectInterface.get_product_user_external_account_count(count_opts)

	var ext_accs = []
	for i: int in range(count):
		var copy_opts = EOS.Connect.CopyProductUserExternalAccountByIndexOptions.new()
		copy_opts.target_user_id = p_product_user_id
		copy_opts.external_account_info_index = i

		var copy_ret = EOS.Connect.ConnectInterface.copy_product_user_external_account_by_index(copy_opts)
		if not EOS.is_success(copy_ret):
			_log.error("Failed to copy external account: result_code=%s, index=%s" % [EOS.result_str(copy_ret), i])
			continue
		if copy_ret.external_account_info:
			ext_accs.append(copy_ret.external_account_info)

	return ext_accs




func get_product_user_info_async(p_product_user_id: String = product_user_id):
	_log.debug("Getting product user info: product_user_id=%s" % p_product_user_id)

	var opts = EOS.Connect.QueryProductUserIdMappingsOptions.new()
	opts.product_user_ids = [p_product_user_id]
	EOS.Connect.ConnectInterface.query_product_user_id_mappings(opts)
	var ret = await IEOS.connect_interface_query_product_user_id_mappings_callback
	if not EOS.is_success(ret):
		_log.error("Failed to query product user id mappings: result_code=%s" % EOS.result_str(ret))
		return {}

	var copy_opts = EOS.Connect.CopyProductUserInfoOptions.new()
	copy_opts.target_user_id = p_product_user_id
	var copy_ret = EOS.Connect.ConnectInterface.copy_product_user_info(copy_opts)
	if not EOS.is_success(copy_ret):
		_log.error("Failed to copy product user info: result_code=%s" % EOS.result_str(copy_ret))
		return {}

	_log.debug("Got product user info: product_user_id=%s" % p_product_user_id)

	var ext_acc = copy_ret.external_account_info
	if not ext_acc:
		_log.error("Failed to get external account info")
	if ext_acc and ext_acc.product_user_id == product_user_id:
		external_account_info = ext_acc
		external_account_info_changed.emit()

		if ext_acc.display_name:
			display_name = ext_acc.display_name
			display_name_changed.emit()

	return ext_acc






func _on_connect_interface_auth_expiration(data: Dictionary):
	_log.debug("Connect Auth Expiring...")
	_connect_account_async()


func _connect_account_async() -> bool:
	_log.debug("Connecting account to Epic Game Services...")

	if _last_connect_login_opts:
		var opts = _last_connect_login_opts
		if opts and opts.credentials and EOS.ExternalCredentialType.DeviceidAccessToken == opts.credentials.type:
			return await login_game_services_async(opts)


	var auth_token_ret = EOS.Auth.AuthInterface.copy_user_auth_token(EOS.Auth.CopyUserAuthTokenOptions.new(), epic_account_id)
	if not EOS.is_success(auth_token_ret):
		_log.error("Failed to get user auth token: result_code=%s" % EOS.result_str(auth_token_ret))
		_emit_login_auth_error(auth_token_ret.result_code)
		return false

	var token = auth_token_ret.token

	var login_options = EOS.Connect.LoginOptions.new()
	login_options.credentials = EOS.Connect.Credentials.new()
	login_options.credentials.type = EOS.ExternalCredentialType.Epic
	login_options.credentials.token = token.access_token


	if not epic_account_id:
		logged_in_auth.emit()

	return await login_game_services_async(login_options)


func _continue_login_async(continuance_token: EOSGContinuanceToken) -> bool:
	_log.debug("Continuing login...")
	var link_opts = EOS.Auth.LinkAccountOptions.new()
	link_opts.continuance_token = continuance_token
	EOS.Auth.AuthInterface.link_account(link_opts)

	var link_ret: Dictionary = await IEOS.auth_interface_link_account_callback
	if not EOS.is_success(link_ret):
		_log.error("Failed to link account: result_code=%s" % EOS.result_str(link_ret))
		_emit_login_auth_error(link_ret.result_code)
		return false

	if link_ret.selected_account_id:
		epic_account_id = link_ret.selected_account_id

	return true


func _create_user_async(continuance_token: EOSGContinuanceToken) -> bool:
	_log.debug("Creating user...")
	var create_opts = EOS.Connect.CreateUserOptions.new()
	create_opts.continuance_token = continuance_token
	EOS.Connect.ConnectInterface.create_user(create_opts)

	var create_ret: Dictionary = await IEOS.connect_interface_create_user_callback

	if not EOS.is_success(create_ret):
		_log.error("Failed to create user: result_code=%s" % EOS.result_str(create_ret))
		_emit_login_connect_error(create_ret.result_code)
		return false

	if create_ret.local_user_id:
		product_user_id = create_ret.local_user_id

	return true


func _emit_login_auth_error(result_code: EOS.Result):
	login_auth_error.emit(result_code)
	login_error.emit(result_code)


func _emit_login_connect_error(result_code: EOS.Result):
	login_connect_error.emit(result_code)
	login_error.emit(result_code)


func _get_command_line_options():
	var options = {}
	var args = OS.get_cmdline_args()
	for arg in args:
		arg = arg.trim_prefix("--").trim_prefix("-")
		var kvp = arg.split("=")
		if len(kvp) > 1:
			options[kvp[0]] = kvp[1]
	return options
