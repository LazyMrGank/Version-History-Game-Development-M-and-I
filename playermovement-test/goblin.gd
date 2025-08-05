extends CharacterBody2D

@onready var animation_player = $Visuals/AnimationPlayer
var is_moving_left: bool = true
var gravity: float = 10.0
var speed: float = 32.0
var is_attacking: bool = false
var is_hit: bool = false
var health: int = 3  # New health variable

func _ready() -> void:
	$Visuals/AnimationPlayer.play("Walk")
	$Visuals/PlayerDetector.body_entered.connect(_on_player_detector_body_entered)
	$Visuals/PlayerDetector.body_exited.connect(_on_player_detector_body_exited)
	$Visuals/AttackDetector.body_entered.connect(_on_attack_detector_body_entered)
	$Visuals/AnimationPlayer.animation_finished.connect(_on_animation_finished)
	add_to_group("enemies")  # Ensure enemy is in "enemies" group for player detection

func _physics_process(_delta: float) -> void:
	if is_hit or is_attacking or health <= 0:  # Stop movement if hit, attacking, or dead
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
	if body.is_in_group("Player") and not is_attacking and not is_hit and health > 0:
		is_attacking = true
		$Visuals/AnimationPlayer.play("Attack")
		$Visuals/AttackDetector.monitoring = true

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and is_attacking and not is_hit and health > 0:
		is_attacking = false
		$Visuals/AnimationPlayer.play("Walk")
		$Visuals/AttackDetector.monitoring = false

func _on_attack_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and is_attacking:
		print("Hit player during attack!")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Attack" and not is_hit and health > 0:
		is_attacking = false
		$Visuals/AnimationPlayer.play("Walk")
		$Visuals/AttackDetector.monitoring = false
	elif anim_name == "hit" and health > 0:  # Resume walking if still alive
		is_hit = false
		is_attacking = false
		$Visuals/AnimationPlayer.play("Walk")
		$Visuals/AttackDetector.monitoring = false
	elif anim_name == "Death":  # Remove enemy after death animation
		queue_free()

func play_hit_animation():
	if animation_player.has_animation("hit") and not is_hit and health > 0:
		is_hit = true
		is_attacking = false
		$Visuals/AttackDetector.monitoring = false
		health -= 1  # Reduce health by 1
		velocity.x = 0
		if health <= 0:
			animation_player.play("Death")
		else:
			animation_player.play("hit")
	else:
		print("Error: 'hit' animation not found or already playing or enemy is dead")
