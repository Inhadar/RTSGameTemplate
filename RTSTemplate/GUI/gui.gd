extends CanvasLayer
# Holds the index of selected buttons
var choosen_button = []

# Attack signals
signal attack1
signal attack2
signal attack3

# Signal to remove old missiles from the scene
signal remove_old_missilles

# Debug signal for restarting
signal restart


func _ready() -> void:
	# Connects each player button to the select_player function
	for i in $Bar/Players/Players.get_children():
		i.connect("pressed", Callable(self, "select_player").bind(i.name))
		i.pivot_offset = Vector2(32, 32)  # Sets the pivot point for rotation/scaling
		$Bar/Players/Players.get_node(NodePath(i.name)).custom_minimum_size = Vector2(64, 64)  # Sets minimum button size
		

func select_player(button_index):
	# Sets the selected player from the global players list
	var current_player = Globals.current_players.keys()[int(button_index)]
	Globals.chosen_player = current_player
	
	# Previously intended to track button selection, now disabled
	# if !button_index in choosen_button:
	#	choosen_button.clear()
	#	choosen_button.append(button_index)

	reset_buttons()  # Reset all buttons appearance
	$Bar/Player/ProgressBar.show()  # Show the player health bar
	$Bar/Player/ProgressBar.value =Globals.current_players[current_player][1]
	$Bar/Player.texture = load("res://Assets/playericon.png")  # Load player icon texture


func enemy_progress(enemy):
	# Updates the enemy UI panel with the given enemy's status
	var enemy_texture = $Bar/Enemy 
	var health_bar = $Bar/Enemy/ProgressBar
	var attack_button = $Bar/Enemy/AttackB

	# Set current enemy health
	health_bar.value = enemy.health

	# Assign enemy icon (this should change based on enemy type later)
	var enemy_icon = load("res://Assets/enemyicon.png")
	enemy_texture.texture = enemy_icon

	# Show attack button and hide health bar until combat starts
	health_bar.hide()
	attack_button.show()
	attack_button.disabled = false
	
	pass


func update_enemy_status(enemy):
	# Updates enemy health and handles its destruction
	var health_bar = $Bar/Enemy/ProgressBar
	var enemy_texture = $Bar/Enemy 

	health_bar.value = enemy.health

	if health_bar.value <= 0:
		# If enemy is dead, change appearance and clean up
		enemy_texture.modulate = Color.DIM_GRAY
		await get_tree().create_timer(0.5).timeout

		if is_instance_valid(enemy):
			enemy_texture.texture = load("res://Assets/emptyicon.png")
			health_bar.hide()
			enemy_texture.modulate = Color.WHITE
			$AnimationPlayer.play("hide")
			enemy.queue_free()  # Remove enemy from the scene
			remove_old_missilles.emit()  # Clean up projectiles


func update_player_status(player):
	# Updates player health and handles death logic
	var health_bar = $Bar/Player/ProgressBar
	var player_texture = $Bar/Player

	health_bar.value = player.health

	if health_bar.value <= 0:
		# If player is dead, gray out texture and remove
		player_texture.modulate = Color.DIM_GRAY
		await get_tree().create_timer(0.5).timeout

		if is_instance_valid(player):
			player_texture.texture = load("res://Assets/emptyicon.png")
			health_bar.hide()
			player_texture.modulate = Color.WHITE
			player.queue_free()  # Remove player from scene
			Globals.current_players.erase(player.name)  # Delete from player list
			check_players()  # Refresh UI
			remove_old_missilles.emit()  # Clean up projectiles


func _on_attack_b_pressed() -> void:
	# Handles attack button press (shows enemy health and hides attack button)
	$AnimationPlayer.play("show")
	$Bar/Enemy/ProgressBar.show()
	$Bar/Enemy/AttackB.hide()
	pass


func reset_buttons():
	# Reset all player button scales, highlight the selected player
	for i in $Bar/Players/Players.get_children():
		if i.name == Globals.chosen_player:
			$Bar/Players/Players.get_node(NodePath(i.name)).scale = Vector2(1.1, 1.1)  # Highlight selected
			# Optional: enlarge the button
			# $Bar/Players/Players.get_node(NodePath(i.name)).custom_minimum_size = Vector2(300, 300)
		else:
			$Bar/Players/Players.get_node(NodePath(i.name)).scale = Vector2(1, 1)  # Reset scale
			# $Bar/Players/Players.get_node(NodePath(i.name)).custom_minimum_size = Vector2(250, 250)


func check_players():
	# Updates the UI buttons and data labels based on the current player list
	for i in $Bar/Players/Players.get_children():
		if int(i.name) > Globals.current_players.keys().size() - 1:
			i.disabled = true  # Disable and hide buttons for non-existent players
			i.hide()
		elif int(i.name) < Globals.current_players.keys().size():
			i.get_node(NodePath("Label")).text = Globals.current_players.keys()[int(i.name)]  # Update label

	# Create velocity data labels for each player if missing
	for j in Globals.current_players.keys():
		if !$DataPanel.has_node(j + "_VData"):
			var new_label = Label.new()
			new_label.name = j + "_VData"
			$DataPanel.add_child(new_label)
			new_label.text = j + "_Velocity: "

			# Apply custom font and background style
			var font = load("res://fonts/NEXT ART_Bold.otf")
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.0, 0.0, 0.0, 0.6)

			new_label.add_theme_font_override("font", font)
			new_label.add_theme_font_size_override("font_size", 32)
			new_label.set("theme_override_colors/font_color", Color.GREEN)
			new_label.add_theme_stylebox_override("normal", style)


func label_updater():
	# Updates FPS, enemy count, player count and player velocity data
	$DataPanel/Fps.text = "FPS: " + str(Engine.get_frames_per_second())
	$DataPanel/Enemy_count.text = "Enemy_Count: " + str(Globals.enemy_count)
	$DataPanel/Player_count.text = "Players_Count: " + str(Globals.player_count)

	write_player_data()  # Update player velocities


func write_player_data():
	# Writes velocity data for each player into its respective label
	for j in Globals.current_players.keys():
		if $DataPanel.has_node(j + "_VData"):
			$DataPanel.get_node(NodePath(j + "_VData")).text = j + "_Velocity: " + str(Globals.current_players[j][0])

	# Alternative version: write all data into one label (commented out)
	"""
	var a = []
	for j in Globals.current_players.keys():
		a.append(j + "_Velocity: " + str(Globals.current_players[j][0]) + "\n")
	$DataPanel.get_node(NodePath("Players_data")).text = "\n".join(a)
	"""


func _process(_delta: float) -> void:
	# Called every frame to update on-screen labels
	label_updater()


func _on_attack_1_pressed() -> void:
	# Emit attack1 signal
	attack1.emit()


func _on_attack_2_pressed() -> void:
	# Emit attack2 signal
	attack2.emit()


func _on_attack_3_pressed() -> void:
	# Emit attack3 signal
	attack3.emit()


## DEBUG BUTTONS ##
func _on_restart_pressed() -> void:
	# Emit restart signal for debugging purposes
	restart.emit()
