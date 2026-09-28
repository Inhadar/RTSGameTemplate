extends Area2D

# Defines whether the missile is targeting an enemy or a player
@export var target_is_enemy = true

# Movement speed of the missile
var speed = 300
# Rotation speed if you want the missile to smoothly turn toward the target
var rotate_speed = 5.0 

# List of missile types (for future use or logic branching)
var type = [
	"normal",
	"explosive",  # Fixed spelling: 'exsplosive' -> 'explosive'
	"flammable",
]

# Current missile type (defaults to "normal")
var current_type = type[0]

# The target this missile is following
var target = null


func go_to_enemy(delta):
	# If a target exists, move towards it
	if target != null:
		var dir = (target.global_position - global_position).normalized()
		
		# If you want the missile to rotate smoothly toward the target:
		# var angle_diff = dir.angle() - rotation
		# rotation += clamp(angle_diff, -rotate_speed * delta, rotate_speed * delta)
		
		# Move the missile toward the target
		position += dir * speed * delta
		

func _physics_process(delta: float) -> void:
	# Called every physics frame, handles missile movement
	go_to_enemy(delta)


func _on_wait_time_timeout() -> void:
	# This function can be used to trigger self-destruction
	# or other timed behaviors when a Timer runs out.
	pass


func _on_body_entered(body: Node2D) -> void:
	# Collision logic based on missile target type
	if target_is_enemy:
		# If the missile is meant to hit enemies
		if body.is_in_group("Enemy"):
			queue_free()  # Destroy the missile
			# TODO: Play destroy animation here
			pass
	else:
		# If the missile is meant to hit players
		if body.is_in_group("Player"):
			queue_free()  # Destroy the missile
			# TODO: Play destroy animation here
			pass
