extends Node2D

@export var rotation_speed = 1.0  # Speed in radians/sec (positive = clockwise, negative = counterclockwise)
@export var is_rotating = true    # Toggle rotation on/off in the editor
@export var radius = 100.0        # Distance from pivot to platform (for setup)

func _ready():
	# Position the platform at the specified radius along the x-axis
	var platform = get_node("Platform")
	platform.position = Vector2(radius, 0)

func _process(delta):
	# Rotate the platform if enabled
	if is_rotating:
		rotation += rotation_speed * delta
		$Platform.rotation -= rotation_speed * delta
		$AudioStreamPlayer2D.play()
