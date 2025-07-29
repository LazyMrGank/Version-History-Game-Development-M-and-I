extends CharacterBody2D
var is_moving_left = true
var gravity = 10
var speed = 32

func _ready():
	$AnimationPlayer.play("Walk")
	
func _physics_process(_delta):
	move_character()
	detect_turn_around()
	hit()
	end_of_hit()
	start_walk()
func move_character():
	velocity.x = -speed if is_moving_left else speed
	velocity.y += gravity
	move_and_slide()
	
func detect_turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		is_moving_left = !is_moving_left
		scale.x = -scale.x
		
func hit():
	$AttackDetector.monitoring = true
	
func end_of_hit():
	$AttackDetector.monitoring = false
	
func start_walk():
	$AnimationPlayer.play("Walk")
	
