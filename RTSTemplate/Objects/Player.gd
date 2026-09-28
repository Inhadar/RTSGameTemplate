extends CharacterBody2D

# Player's health value
var health = 100

# Signals for damage events
signal player_take_damage

# Player's movement speed
var speed = 10000
# Allows or blocks player movement
var move_perm = true
# Stores the position where the player last clicked to move
var click_pos = Vector2.ZERO

# Dictionary for movement direction names and their corresponding Vector2 values
var direction = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"upright": Vector2(1, -1),
	"upleft": Vector2(-1, -1),
	"downright": Vector2(1, 1),
	"downleft": Vector2(-1, 1),
}


func _ready() -> void:
	# Set the initial click position to the player's current global position
	click_pos = global_position
	# Display the player name on the UI element
	$Name.text = name


var touch_perm = true

func _physics_process(delta: float) -> void:
	# Prevent the player from moving below a specific Y-axis threshold (for example, staying above the UI bar)
	if get_global_mouse_position().y < get_viewport_rect().size.y / 1.5:
		if Globals.focus_on_enemy == false:
			Globals.move_touch_perm = true
	else:
		Globals.move_touch_perm = false

	# Allow movement input only if this is the chosen player and movement is permitted
	if (name == Globals.chosen_player) and Globals.move_touch_perm:
		if Input.is_action_just_pressed("move"):
			# Update the destination to the mouse's current global position
			click_pos = get_global_mouse_position()

	# Calculate the distance to the target position
	var distance = global_position.distance_to(click_pos)

	# Move toward the target position if the distance is significant
	if distance > 3:
		var target_pos = (click_pos - global_position).normalized()
		check_current_direction(round(target_pos))
		velocity = target_pos * speed * delta
	else:
		velocity = Vector2.ZERO

	# Handle animations based on velocity
	state_machine(velocity)
	# Move the player according to calculated velocity
	move_and_slide()


func state_machine(vel):
	# Simple state machine to update idle animation when not moving
	if vel == Vector2.ZERO:
		# Player is idle
		$Label.text = "IDLE"
		$Visuals/AnimationPlayer.seek(0.15, true)
		# You could stop the animation here instead of seek
		#$Visuals/AnimationPlayer.stop()


func check_current_direction(value):
	# Matches the current normalized direction with a name and plays corresponding animation
	for i in direction.keys():
		if direction[i] == value:
			$Label.text = i
			$Visuals/AnimationPlayer.play(i)


func _on_hit_box_area_entered(area: Area2D) -> void:
	# Detects collision with a missile
	if area.is_in_group("Missile"):
		# Check if the missile is meant to damage the player (target_is_enemy == false)
		if area.target_is_enemy == false:
			# Emit signal to notify the game logic that the player has taken damage
			emit_signal("player_take_damage")
		# TODO: Implement bullet type check, apply damage, and update player status here
		pass
