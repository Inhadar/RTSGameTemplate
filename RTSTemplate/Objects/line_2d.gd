class_name Trail
extends Line2D

# Stores the trail positions
var queue: Array
# Maximum number of points allowed in the trail
const MAX_POINTS: int = 200

# Curve2D instance (currently unused, but can be useful for smooth trails or interpolation later)
@onready var curve := Curve2D.new()


func _process(_delta: float) -> void:
	# Get the current position to add to the trail
	var pos = _get_point_position()
	
	# Add the new position to the front of the queue
	queue.push_front(pos)
	
	# If the queue exceeds the maximum length, remove the oldest point
	if queue.size() > MAX_POINTS:
		queue.pop_back()
	
	# Clear all previously drawn points in Line2D
	clear_points()
	
	# Re-add all points from the queue to Line2D for drawing
	for point in queue:
		add_point(point)


func _get_point_position():
	# This function should return the position you want the trail to follow.
	# For example, you could return the global mouse position like this:
	# return get_global_mouse_position()
	
	pass  # Placeholder for position logic
