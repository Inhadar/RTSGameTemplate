extends Node

# Load GUI and preloaded scenes for missiles, enemies, and players
@onready var GUI = $"GUİ"
@onready var missile_scene = preload("res://Objects/missile.tscn")
### For Debugging ###
@onready var enemy_scene = preload("res://Objects/Enemy.tscn")
@onready var player_scene = preload("res://Objects/Player.tscn")


func _ready() -> void:
	# Clear previous player data
	Globals.current_players.clear()
	count_players()
	count_enemies()
	set_enemy_connects()
	set_player_connects()


func _input(event: InputEvent) -> void:
	# Handle player input for selecting an enemy
	if event.is_action_pressed("move"):
		for i in $Enemies.get_children():
			# If mouse click is close enough to an enemy
			if i.global_position.distance_to(event.global_position) < 20:
				for j in $Players.get_children():
					# If any player is within a 200 unit range of the clicked enemy
					if j.global_position.distance_to(i.global_position) < 200:
						GUI.enemy_progress(i)
						Globals.chosen_enemy = i.name
						break


func set_player_connects():
	# Connect each player's damage signal to the damage handler
	for i in $Players.get_children():
		i.connect("player_take_damage", Callable(self, "player_damage").bind(i))


func player_damage(player):
	# Reduce player health and update the GUI status
	player.health -= 10
	GUI.update_player_status(player)


func set_enemy_connects():
	# Connect each enemy's signals to their respective handlers
	for i in $Enemies.get_children():
		i.connect("mouse_entered", Callable(self, "focus_enemy").bind(i))
		i.connect("mouse_exited", Callable(self, "unfocus_enemy").bind(i))
		i.connect("enemy_take_damage", Callable(self, "enemy_damage").bind(i))
		i.connect("fire_to_player", Callable(self, "attack_to_player").bind(i))


func focus_enemy(_enemy):
	# Set focus state when mouse is over an enemy
	Globals.move_touch_perm = false
	Globals.focus_on_enemy = true


func unfocus_enemy(_enemy):
	# Reset focus state when mouse leaves the enemy
	Globals.move_touch_perm = true
	Globals.focus_on_enemy = false


func enemy_damage(enemy):
	# Reduce enemy health and update the GUI status
	enemy.health -= 10
	GUI.update_enemy_status(enemy)


func attack_to_player(enemy):
	# Trigger enemy to spawn a missile targeting the player
	spawn_enemy_missiles(1, enemy)


func count_players():
	# Initialize the player dictionary in Globals
	for i in $Players.get_children():
		Globals.current_players[i.name] = []
	GUI.check_players()


func count_enemies():
	# Initialize the enemy dictionary in Globals
	for i in $Enemies.get_children():
		Globals.current_enemies[i.name] = []


func write_objects_count():
	# Update the global count of active players and enemies
	Globals.enemy_count = $Enemies.get_child_count()
	Globals.player_count = $Players.get_child_count()


func _process(_delta: float) -> void:
	# Update game statistics every frame
	write_objects_count()
	write_players_data()


func write_players_data():
	# Update each player's velocity in the global tracking array
	for i in Globals.current_players.keys():
		if $Players.has_node(NodePath(i)):
			var cpv = $Players.get_node(NodePath(i))
			Globals.current_players[i].clear()
			Globals.current_players[i].append(cpv.velocity)
			Globals.current_players[i].append(cpv.health)
			
				

func spawn_player_missiles(count):
	if $Enemies.has_node(NodePath(Globals.chosen_enemy)):
		var target = $Enemies.get_node(NodePath(Globals.chosen_enemy))
		if $Players.has_node(NodePath(Globals.chosen_player)):
			var missile_source = $Players.get_node(NodePath(Globals.chosen_player))
			for i in range(count):
				var missile = missile_scene.instantiate()
				var fire_poses = missile_source.get_node(NodePath("FirePoses"))
				var a = i  % fire_poses.get_child_count()
				missile.global_position = fire_poses.get_node(str(a)).global_position
				missile.target = target
				if $Enemies.has_node(NodePath(Globals.chosen_enemy)):
					$Missiles.add_child(missile)
					await get_tree().create_timer(0.2).timeout 
				else:
					break


func spawn_enemy_missiles(count, enemy):
	# Spawn missiles from an enemy toward the selected player
	if $Players.has_node(NodePath(Globals.chosen_player)):
		var target = $Players.get_node(NodePath(Globals.chosen_player))
		var missile_source = enemy
		for i in range(count):
			var missile = missile_scene.instantiate()
			missile.target_is_enemy = false
			var fire_poses = missile_source.get_node(NodePath("FirePoses"))
			var a = i % fire_poses.get_child_count()
			missile.global_position = fire_poses.get_node(str(a)).global_position
			missile.target = target

			if $Players.has_node(NodePath(Globals.chosen_player)):
				$Missiles.add_child(missile)
				await get_tree().create_timer(0.2).timeout
			else:
				break
	else:
		# Stop the attack timer if no player target exists
		enemy.get_node(NodePath("AttackTimer")).stop()


# GUI button callbacks for spawning missiles
func _on_gui_attack_1() -> void:
	spawn_player_missiles(1)


func _on_gui_attack_2() -> void:
	spawn_player_missiles(2)


func _on_gui_attack_3() -> void:
	spawn_player_missiles(3)


func _on_gui_remove_old_missilles() -> void:
	# Clear all active missiles
	for i in $Missiles.get_children():
		i.queue_free()


### DEBUG FUNCTIONS ###

func _on_gui_restart() -> void:
	# Reload the current scene for testing and debugging
	var _restart_scene = get_tree().reload_current_scene()
