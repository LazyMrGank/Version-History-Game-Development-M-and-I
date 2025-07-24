extends RigidBody2D

@export var recenter_strength = 100.0  # Strength of the recentering force
@export var damping = 10.0  # Damping to prevent oscillation
var bodies_on_seesaw = 0  # Track how many bodies are on the seesaw
@export var player_mass = 50
func _ready():
	print('ready');
	
	# Connect the body_entered and body_exited signals for collision detection


func _physics_process(delta):
	# Only recenter if no bodies are on the seesaw
	if bodies_on_seesaw == 0:
		var current_rotation = rotation  # Current rotation in radians
		# Apply torque to rotate back to 0 (horizontal)
		var torque = -current_rotation * recenter_strength - angular_velocity * damping
		apply_torque_impulse(torque * delta)
	var collisions = get_colliding_bodies()
#func _on_body_entered(body):
	#print("Boddy");
	#
	## Increment counter when a body (e.g., player) enters
	#if body.is_in_group("Player"):  # Adjust group based on your player setup
		#print("Player hit");
		#
		#bodies_on_seesaw += 1

#func _on_body_exited(body):
	#print("BYE")
	## Decrement counter when a body exits
	#if body.is_in_group("Player"):
		#print("Player left");
		#
		#bodies_on_seesaw = max(0, bodies_on_seesaw - 1)


func _on_area_2d_body_entered(body: Node2D) -> void:
	
	add_constant_force(Vector2.UP * player_mass, body.global_position)





func _on_area_2d_2_body_entered(body: Node2D) -> void:
	
	add_constant_force(Vector2.DOWN * player_mass, body.global_position)
