extends SceneTree


func _initialize() -> void:
	call_deferred("_check")


func _check() -> void:
	# Disable the project's fixed 1280x720 content scale to exercise layout at
	# actual logical viewport sizes without launching a graphical window.
	root.content_scale_size = Vector2i.ZERO
	var scene := (load("res://tidewater_play.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	var settings: RefCounted = scene.get("settings")
	settings.set("ui_scale", 1.1)
	var hud_root: Control = scene.get("hud_root")
	var menu: Panel = scene.get("menu_panel")
	var panel: Panel = scene.get("settings_panel")
	for window_size in [Vector2i(640, 480), Vector2i(480, 320)]:
		root.size = window_size
		await process_frame
		scene.call("_layout_hud")
		var viewport_rect := scene.get_viewport().get_visible_rect()
		if viewport_rect.size != Vector2(window_size):
			_fail("headless resize did not produce the requested canvas: %s" % viewport_rect.size)
			return
		var expected_scale := minf(1.1, minf(viewport_rect.size.x / 520.0, viewport_rect.size.y / 500.0))
		if absf(hud_root.scale.x - expected_scale) > 0.0001 or absf(hud_root.scale.y - expected_scale) > 0.0001:
			_fail("UI scale did not fit the narrow viewport")
			return
		if not _inside_viewport(menu, viewport_rect) or menu.get_global_rect().get_center().distance_to(viewport_rect.size * 0.5) > 2.0:
			_fail("loadout menu does not fit or center in the narrow viewport")
			return
		for card in (scene.get("weapon_cards") as Dictionary).values():
			if not _inside_viewport(card as Control, viewport_rect):
				_fail("weapon card escapes the narrow viewport")
				return
	var cards: Dictionary = scene.get("weapon_cards")
	_click(cards["blaster"] as Control)
	await process_frame
	if scene.get("selected_weapon") != "blaster":
		_fail("scaled weapon card did not receive a viewport click")
		return
	_click(scene.get("setup_settings_button") as Control)
	await process_frame
	if not panel.visible or not _inside_viewport(panel, scene.get_viewport().get_visible_rect()):
		_fail("settings panel does not fit the narrow viewport")
		return
	var save_button: Button = panel.get("save_button")
	if not panel.get_global_rect().encloses(save_button.get_global_rect()):
		_fail("settings actions escape the settings panel")
		return
	print("PASS: 640x480 and 480x320 logical layouts fit; scaled weapon/settings clicks work")
	quit()


func _inside_viewport(control: Control, viewport_rect: Rect2) -> bool:
	return viewport_rect.encloses(control.get_global_rect())


func _click(control: Control) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = control.get_global_rect().get_center()
	event.global_position = event.position
	event.pressed = true
	root.push_input(event, true)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event, true)


func _fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)
