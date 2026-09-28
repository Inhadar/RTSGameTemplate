extends CharacterBody2D

# Signal to notify that this enemy took damage
signal enemy_take_damage
# Signal to notify this enemy is firing at the player
signal fire_to_player

# Enemy health
var health = 100

# Movement speed and control flags
var speed = 10000
var move_perm = true
var click_pos = Vector2.ZERO

# Dictionary to map directions for animations
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
	# Initialize click position at spawn point
	click_pos = global_position
	# Display the enemy's name on the UI label
	$Name.text = self.name


func _physics_process(delta: float) -> void:
	# Calculate distance from current position to the clicked position
	var distance = global_position.distance_to(click_pos)
	
	# If the enemy is too far from the target, move toward it
	if distance > 250:
		var target_pos = (click_pos - global_position).normalized()
		# Update the direction label and play matching animation
		check_current_direction(round(target_pos))
		# Move towards the target
		velocity = target_pos * speed * delta
	else:
		# Stop moving if the target is close enough
		velocity = Vector2.ZERO

	# Update animations based on movement state
	state_machine(velocity)
	# Apply movement
	move_and_slide()


func state_machine(vel):
	# Simple state machine for idle and movement animations
	if vel == Vector2.ZERO:
		# If not moving, set state to IDLE
		$Label.text = "IDLE"
		# Slightly rewind the animation to prevent freeze glitch
		$Visuals/AnimationPlayer.seek(0.15, true)
		# You can optionally stop the animation:
		# $Visuals/AnimationPlayer.stop()
	#else:
		# You can enable this block if you want to debug movement states
		# $Label.text = "WALKING"


func check_current_direction(value):
	# Check which direction the enemy is moving and play corresponding animation
	for i in direction.keys():
		if direction[i] == value:
			$Label.text = i
			$Visuals/AnimationPlayer.play(i)


func _on_player_trigger_area_body_entered(body: Node2D) -> void:
	# When a player enters the enemy's trigger area
	if body.is_in_group("Player"):
		# Set the player's position as the new movement target
		click_pos = body.global_position
		# Start the attack timer to attack at intervals
		$AttackTimer.start()


func _on_hit_box_area_entered(area: Area2D) -> void:
	# When a missile hits this enemy's hitbox
	if area.is_in_group("Missile"):
		# Check if the missile was intended for an enemy
		if area.target_is_enemy:
			emit_signal("enemy_take_damage")  # Notify damage
		# Here you can apply damage or additional effects
		pass


func _on_attack_timer_timeout() -> void:
	# Called when the attack timer reaches zero
	emit_signal("fire_to_player")  # Notify that the enemy is firing at the player
