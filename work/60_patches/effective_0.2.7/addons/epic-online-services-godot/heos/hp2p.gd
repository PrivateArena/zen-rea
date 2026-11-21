extends Node










var _log = HLog.logger("HP2P")








func get_nat_type_async() -> EOS.P2P.NATType:
	_log.debug("Getting nat type...")
	EOS.P2P.P2PInterface.query_nat_type()

	var ret = await IEOS.p2p_interface_query_nat_type_callback
	if not EOS.is_success(ret):
		_log.error("Failed to get nat type: %s" % EOS.result_str(ret))
	else:
		_log.debug("Got nat type: %s" % ret.nat_type)

	return ret.nat_type



func get_relay_control() -> EOS.P2P.RelayControl:
	var ret = EOS.P2P.P2PInterface.get_relay_control()
	if not EOS.is_success(ret):
		_log.error("Failed to get relay control: %s" % EOS.result_str(ret))

	return ret.relay_control



func set_relay_control(relay_control: EOS.P2P.RelayControl) -> EOS.Result:
	return EOS.P2P.P2PInterface.set_relay_control(relay_control)







func get_port_range() -> Dictionary:
	return EOS.P2P.P2PInterface.get_port_range()



func set_port_range(port: int, max_additional_ports_to_try: int) -> EOS.Result:
	var opts = EOS.P2P.SetPortRangeOptions.new()
	opts.port = port
	opts.max_additional_ports_to_try = max_additional_ports_to_try
	return EOS.P2P.P2PInterface.set_port_range(opts)











func get_packet_queue_info():
	return EOS.P2P.P2PInterface.get_packet_queue_info()



func set_packet_queue_size(incoming_packet_queue_max_size_bytes: int, outgoing_packet_queue_max_size_bytes: int) -> EOS.Result:
	var opts = EOS.P2P.SetPacketQueueSizeOptions.new()
	opts.incoming_packet_queue_max_size_bytes = incoming_packet_queue_max_size_bytes
	opts.outgoing_packet_queue_max_size_bytes = outgoing_packet_queue_max_size_bytes
	return EOS.P2P.P2PInterface.set_packet_queue_size(opts)
