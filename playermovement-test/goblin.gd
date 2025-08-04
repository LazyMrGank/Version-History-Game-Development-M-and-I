extends CharacterBody2D
var is_moving_left = true
var gravity = 10
var speed = 32

func _ready():
	$Visuals/AnimationPlayer.play("Walk")
	
func _physics_process(_delta):
	if $Visuals/AnimationPlayer.current_animation == "Attack":
		return
	move_character()
	detect_turn_around()
	
func move_character():
	velocity.x = speed if is_moving_left else -speed
	velocity.y += gravity
	move_and_slide()

	
func detect_turn_around():
	if not $Visuals/RayCast2D.is_colliding() and is_on_floor():
		is_moving_left = !is_moving_left
		scale.x = -scale.x
		
		
func hit():
	$Visuals/AttackDetector.monitoring = true
	
func end_of_hit():
	$Visuals/PlayerDetector.monitoring = false
	
func start_walk():
	$Visuals/AnimationPlayer.play("Walk")
	
func _on_player_detector_body_entered(body: Node2D) -> void:
	$Visuals/AnimationPlayer.play("Attack")
	print("Did it")
"""
func _on_attack_detector_body_entered(body: Node2D) -> void:
	get_tree().reload_current_scene()
"""
