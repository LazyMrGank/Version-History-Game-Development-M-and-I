extends RigidBody2D

@export var recenter_strength = 100.0  # Strength of the recentering force
@export var damping = 10.0  # Damping to prevent oscillation
var bodies_on_seesaw = 0  # Track how many bodies are on the seesaw

func _ready():
	# Connect the body_entered and body_exited signals for collision detection
	$CollisionShape2D.connect("body_entered", _on_body_entered)
	$CollisionShape2D.connect("body_exited", _on_body_exited)

func _physics_process(delta):
	# Only recenter if no bodies are on the seesaw
	if bodies_on_seesaw == 0:
		var current_rotation = rotation  # Current rotation in radians
		# Apply torque to rotate back to 0 (horizontal)
		var torque = -current_rotation * recenter_strength - angular_velocity * damping
		apply_torque_impulse(torque * delta)

func _on_body_entered(body):
	# Increment counter when a body (e.g., player) enters
	if body.is_in_group("Player"):  # Adjust group based on your player setup
		bodies_on_seesaw += 1

func _on_body_exited(body):
	# Decrement counter when a body exits
	if body.is_in_group("Player"):
		bodies_on_seesaw = max(0, bodies_on_seesaw - 1)
