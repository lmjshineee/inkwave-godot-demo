extends SceneTree


func _initialize() -> void:
	call_deferred("_check")


func _check() -> void:
	var scene := (load("res://tidewater_play.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	var menu: Panel = scene.get("menu_panel")
	var cards: Dictionary = scene.get("weapon_cards")
	var size := scene.get_viewport().get_visible_rect().size
	if not menu.visible or cards.size() != 4 or menu.get_global_rect().get_center().distance_to(size * 0.5) > 2.0:
		_fail("setup loadout panel is absent or not centered")
		return
	for card in cards.values():
		var icon := card.get_child(0) as TextureRect
		if card.mouse_filter != Control.MOUSE_FILTER_STOP:
			_fail("loadout card does not receive mouse input")
			return
		if icon.texture == null:
			_fail("loadout card lacks its source weapon icon")
			return
		if icon.size.x > 70.0 or icon.size.y > 70.0 or icon.position.y + icon.size.y > card.size.y - 25.0:
			_fail("loadout icon overflows its card: %s at %s" % [icon.size, icon.position])
			return
	_click(cards["blaster"] as Panel)
	await process_frame
	if scene.get("selected_weapon") != "blaster" or scene.get_node("Combat").get("selected_id") != "blaster":
		_fail("clicking a setup card did not equip the blaster")
		return
	var select := InputEventKey.new()
	select.keycode = KEY_3
	select.pressed = true
	scene.call("_input", select)
	if scene.get("selected_weapon") != "charger" or scene.get_node("Combat").get("selected_id") != "charger":
		_fail("menu keyboard selection did not update the equipped weapon")
		return
	var selected_style := (cards["charger"] as Panel).get_theme_stylebox("panel") as StyleBoxFlat
	if selected_style.border_color != Color("ff8a14"):
		_fail("selected weapon card lacks the orange highlight")
		return
	scene.call("_begin_intro")
	if menu.visible:
		_fail("loadout panel remained over the intro")
		return
	scene.call("_start_round")
	scene.call("damage_player", 100.0)
	scene.call("_update_hud")
	if not menu.visible or not String(scene.get("menu_hint").text).contains("重生") \
			or bool(scene.get("pointer_locked")) or bool(scene.get("paused")):
		_fail("loadout panel did not return during respawn")
		return
	_click(cards["roller"] as Panel)
	await process_frame
	if scene.get("selected_weapon") != "roller" or scene.get_node("Combat").get("selected_id") != "roller":
		_fail("clicking a respawn card did not equip the roller")
		return
	if bool(scene.get("pointer_locked")) or bool(scene.get("paused")):
		_fail("respawn card click unexpectedly captured or paused the cursor")
		return
	scene.call("_notification", Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	if not bool(scene.get("paused")):
		_fail("focus loss did not pause the respawn wait")
		return
	_click(cards["shooter"] as Panel)
	await process_frame
	if scene.get("selected_weapon") != "shooter" or not bool(scene.get("paused")):
		_fail("paused respawn card click did not select while keeping the pause")
		return
	_click_at(Vector2(5.0, 5.0))
	await process_frame
	if bool(scene.get("paused")) or bool(scene.get("pointer_locked")):
		_fail("clicking outside the respawn panel did not resume with a visible cursor")
		return
	_click(cards["roller"] as Panel)
	await process_frame
	scene.call("_update_player_respawn", 10.0)
	if not bool(scene.get("pointer_locked")) or scene.get_node("Combat").get("selected_id") != "roller":
		_fail("respawn did not restore mouse look and keep the selected weapon")
		return
	print("PASS: centered setup menu, source icons, keyboard/click selection and respawn mouse flow")
	quit()


func _click(card: Panel) -> void:
	_click_at(card.get_global_rect().get_center())


func _click_at(position: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.global_position = event.position
	event.pressed = true
	root.push_input(event, true)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event, true)


func _fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)
