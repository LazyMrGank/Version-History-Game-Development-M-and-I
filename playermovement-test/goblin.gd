extends CharacterBody2D

var is_moving_left: bool = true
var gravity: float = 10.0
var speed: float = 32.0
var is_attacking: bool = false

func _ready() -> void:
	$Visuals/AnimationPlayer.play("Walk")
	$Visuals/PlayerDetector.body_entered.connect(_on_player_detector_body_entered)
	$Visuals/PlayerDetector.body_exited.connect(_on_player_detector_body_exited)
	$Visuals/AttackDetector.body_entered.connect(_on_attack_detector_body_entered)
	$Visuals/AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta: float) -> void:
	if is_attacking:
		velocity.x = 0
	else:
		move_character()
		detect_turn_around()
	velocity.y += gravity
	move_and_slide()

func move_character() -> void:
	velocity.x = speed if is_moving_left else -speed

func detect_turn_around() -> void:
	if not $Visuals/RayCast2D.is_colliding() and is_on_floor():
		is_moving_left = !is_moving_left
		scale.x = -scale.x

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_attacking:
		is_attacking = true
		$Visuals/AnimationPlayer.play("Attack")
		$Visuals/AttackDetector.monitoring = true

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and is_attacking:
		is_attacking = false
		$Visuals/AnimationPlayer.play("Walk")
		$Visuals/AttackDetector.monitoring = false

func _on_attack_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and is_attacking:
		print("Hit player during attack!")
		
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Attack":
		is_attacking = false
		$Visuals/AnimationPlayer.play("Walk")
		$Visuals/AttackDetector.monitoring = false
