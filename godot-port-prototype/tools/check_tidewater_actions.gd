extends SceneTree


func _initialize() -> void:
	call_deferred("_check")


func _check() -> void:
	for action in [
		"iw_move_left", "iw_move_right", "iw_move_forward", "iw_move_back",
		"iw_jump", "iw_squid", "iw_fire", "iw_bomb", "iw_special",
		"iw_weapon_1", "iw_weapon_2", "iw_weapon_3", "iw_weapon_4",
		"iw_bot_cycle", "iw_confirm", "iw_restart", "iw_pause",
	]:
		if not InputMap.has_action(action) or InputMap.action_get_events(action).is_empty():
			_fail("missing default InputMap binding: " + action)
			return
	var scene := (load("res://tidewater_play.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	var old_events := InputMap.action_get_events("iw_weapon_3").duplicate()
	InputMap.action_erase_events("iw_weapon_3")
	var replacement := InputEventKey.new()
	replacement.keycode = KEY_5
	InputMap.action_add_event("iw_weapon_3", replacement)
	var original_key := InputEventKey.new()
	original_key.keycode = KEY_3
	original_key.pressed = true
	scene.call("_input", original_key)
	if scene.get("selected_weapon") != "shooter":
		_restore(old_events)
		_fail("old weapon key still selected after rebinding")
		return
	var new_key := InputEventKey.new()
	new_key.keycode = KEY_5
	new_key.pressed = true
	scene.call("_input", new_key)
	var selected: String = scene.get("selected_weapon")
	var equipped: String = scene.get_node("Combat").get("selected_id")
	_restore(old_events)
	if selected != "charger" or equipped != "charger":
		_fail("rebound weapon action did not select the charger")
		return
	var old_fire := InputMap.action_get_events("iw_fire").duplicate()
	InputMap.action_erase_events("iw_fire")
	var fire_key := InputEventKey.new()
	fire_key.keycode = KEY_6
	InputMap.action_add_event("iw_fire", fire_key)
	scene.call("_start_round")
	scene.call("damage_player", 100.0)
	scene.call("_set_pointer_lock", false)
	fire_key.pressed = true
	scene.call("_input", fire_key)
	var still_paused: bool = scene.get("paused")
	InputMap.action_erase_events("iw_fire")
	for event in old_fire:
		InputMap.action_add_event("iw_fire", event)
	if not still_paused:
		_fail("rebound fire key incorrectly resumed the paused respawn screen")
		return
	print("PASS: all default InputMap actions exist and loadout actions can be rebound")
	quit()


func _restore(events: Array[InputEvent]) -> void:
	InputMap.action_erase_events("iw_weapon_3")
	for event in events:
		InputMap.action_add_event("iw_weapon_3", event)


func _fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)
