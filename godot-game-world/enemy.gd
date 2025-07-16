extends CharacterBody2D

class_name FrogEnemy

const speed = 10
var is_frog_chase: bool

var gravity = 900
var health = 80
var health_max = 80
var health_min = 0

var dead:bool = false
var taking_damage: bool = false
var damage_to_deal = 20
var is_dealing_damage : bool = false

var dir: Vector2
var knockback_force = 200
var is_roaming: bool = true

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	move(delta)
	move_and_slide()
	
func move(delta):
	if !dead:
		if !is_frog_chase:
			velocity += dir * speed * delta
		is_roaming = true
	elif dead:
		velocity.x = 0
	
	
func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5, 2.0, 2.5])
	if !is_frog_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()
	
	
	
