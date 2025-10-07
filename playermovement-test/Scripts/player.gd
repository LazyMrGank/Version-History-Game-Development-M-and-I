extends CharacterBody2D


@onready var speed = 2.0
@onready var jump_velocity = -400.0
@onready var acceleration : float = 15.0
@export var jumps = 2

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = (direction * speed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
