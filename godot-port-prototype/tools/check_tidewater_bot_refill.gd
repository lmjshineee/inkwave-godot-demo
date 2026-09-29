extends SceneTree


func _initialize() -> void:
	call_deferred("_check")


func _check() -> void:
	var scene := (load("res://tidewater_play.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	await physics_frame
	scene.set_physics_process(false)
	scene.call("_start_round")
	var bot: Node3D = scene.get_node("Bot")
	var walker: CharacterBody3D = scene.get_node("World/Walker")
	walker.set_physics_process(false)
	var combat: Node3D = scene.get_node("Combat")
	var player_config: Dictionary = combat.get("weapon_data")["player"]
	bot.global_position = Vector3(8.0, 0.05, 8.0)
	walker.global_position = Vector3(8.0, 0.05, 4.0)
	bot.set("ink_amount", float(player_config["inkMax"]) * 0.10)
	bot.set("last_fire_time", 0.0)
	var start := bot.global_position
	var blue_before := float(scene.get("ink").call("coverage", 1))
	bot.call("tick", 0.1)
	if not bool(bot.get("refilling")) or bot.global_position != start \
			or not (combat.get("projectiles") as Array).is_empty() \
			or float(scene.get("ink").call("coverage", 1)) != blue_before:
		_fail("low-ink bot moved, fired or painted instead of refilling")
		return
	# Crossing the lower threshold must not cancel refill; the source waits for 85%.
	for step in range(30):
		bot.call("tick", 0.25)
	if float(bot.get("ink_amount")) <= float(player_config["inkMax"]) * 0.12 \
			or not bool(bot.get("refilling")) or bot.global_position != start:
		_fail("bot did not remain in refill mode above the 12% entry threshold")
		return
	for step in range(20):
		bot.call("tick", 0.25)
		if not bool(bot.get("refilling")):
			break
	if bool(bot.get("refilling")) or float(bot.get("ink_amount")) < float(player_config["inkMax"]) * 0.85:
		_fail("bot did not leave refill mode at 85% ink")
		return
	if (combat.get("projectiles") as Array).is_empty():
		_fail("refilled bot did not resume its selected shooter attack")
		return
	bot.call("reset")
	if bool(bot.get("refilling")) or float(bot.get("ink_amount")) != float(player_config["inkMax"]):
		_fail("respawn did not reset the bot's refill state")
		return
	bot.call("select_weapon", "roller")
	bot.global_position = start
	bot.set("ink_amount", 5.0)
	bot.set("last_fire_time", 0.0)
	blue_before = float(scene.get("ink").call("coverage", 1))
	bot.call("tick", 0.1)
	if not bool(bot.get("refilling")) or bot.global_position != start \
			or float(scene.get("ink").call("coverage", 1)) != blue_before:
		_fail("empty roller kept moving or painting during refill")
		return
	print("PASS: bot waits below 12% ink, resumes above 85%, resets, and pauses roller paint")
	quit()


func _fail(message: String) -> void:
	printerr("FAIL: ", message)
	quit(1)
