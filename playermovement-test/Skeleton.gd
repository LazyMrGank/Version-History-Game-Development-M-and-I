extends CharacterBody2D

class_name SkeletonEnemy

const speed = 10
var is_chase: bool = true

var gravity = 900
var health = 80
var health_max = 80
var health_min = 0

var dead:bool = false
var taking_damage: bool = false
var damage_to_deal = 20
var is_dealing_damage : bool = false

var dir: Vector2
var knockback_force = -200
var is_roaming: bool = true

var player: CharacterBody2D
var player_in_area = false
var attack_cooldown: float = 1.0  # Time between attacks in seconds
var attack_timer: float = 0.0


func _ready():
	# Connect Area2D signals
	$AttackArea.body_entered.connect(_on_attack_area_body_entered)
	$AttackArea.body_exited.connect(_on_attack_area_body_exited)

func _process(delta):
	if attack_timer > 0:
		attack_timer -= delta
	if player_in_area and !dead and !taking_damage and attack_timer <= 0:
		attack_player()
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	player = Global.playerBody
	move(delta)
	handle_animation()
	move_and_slide()

func handle_animation():
	var anim_sprite = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		anim_sprite.play("Walk")
		if dir.x == -1:
			anim_sprite.flip_h = true
		elif dir.x == 1:
			anim_sprite.flip_h = false
	elif !dead and taking_damage and !is_dealing_damage:
		anim_sprite.play("Hit")
		await get_tree().create_timer(0.8).timeout
		taking_damage = false
	elif !dead and taking_damage and !is_dealing_damage:
		anim_sprite.play("Hit")
		await get_tree().create_timer(0.8).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		anim_sprite.play("Death")
		await get_tree().create_timer(1.0).timeout
		handle_death()

func attack_player():
	if player and !is_dealing_damage:
		is_dealing_damage = true
		attack_timer = attack_cooldown
		# Call the player's health reduction function
		if Global.playerHealth:
			Global.playerHealth.change_health(-damage_to_deal)

func handle_death():
	self.queue_free()

func move(delta):
	if !dead:
		if !is_chase:
			velocity += dir * speed * delta
		elif is_chase and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback_force
			velocity.x = knockback_dir.x
		is_roaming = true
	elif dead:
		velocity.x = 0
	
	
func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5, 2.0, 2.5])
	if !is_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()
	
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body == player:
		player_in_area = true


func _on_Attack_Area_exited(body: Node2D) -> void:
	if body == player:
		player_in_area = false


func _on_attack_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
