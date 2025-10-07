extends CharacterBody2D

@export var patrol_speed: float = 60.0
@export var chase_speed: float = 75.0
@export var back_off_speed: float = 70.0
@export var back_off_duration: float = 1.0
@export var post_back_off_duration: float = 1.0
@export var idle_time_min: float = 1.0
@export var idle_time_max: float = 3.0
@export var close_distance: float = 40.0
@export var health: int = 10
@export var projectile_spawn_offsets: Array[Vector2] = [
	Vector2(-50, -50), # Top-left
	Vector2(50, -50),  # Top-right
	Vector2(-50, 0),   # Left
	Vector2(50, 0)     # Right
]
@export var summon_spawn_offset: Vector2 = Vector2(0, -50)
@export var spell_spawn_offset: float = 50.0
@export var spell2_spawn_offsets: Array[Vector2] = [
	Vector2(50, 20),   # Right, slightly below
	Vector2(70, 30),   # Right, farther and lower
	Vector2(-50, 20),  # Left, slightly below
	Vector2(-70, 30)   # Left, farther and lower
]
@export var attack_area_base_offset: Vector2 = Vector2(20, 0) # Default right-facing offset
@export var floor_check_offset: Vector2 = Vector2(20, 10) # Offset for floor detection
@export var floor_check_target: Vector2 = Vector2(10, 20) # Default right-facing raycast target

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D
@onready var attack_area: Area2D = $AttackArea
@onready var floor_check: RayCast2D = $FloorCheck
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var projectile_scene: PackedScene = preload("res://enemy_projectile.tscn")
@onready var summon_scene: PackedScene = preload("res://Scenes/summon.tscn")
@onready var spell_scene: PackedScene = preload("res://boss_spell1.tscn")
@onready var spell2_scene: PackedScene = preload("res://boss_spell_2.tscn")

enum State { PATROL, IDLE, CHASE, BACK_OFF, POST_BACK_OFF, SECOND_ATTACK, ATTACK3, HIT, TURN_PAUSE }
var current_state: State = State.PATROL
var direction: float = 1.0
var player: Node = null
var idle_timer: float = 0.0
var back_off_timer: float = 0.0
var post_back_off_timer: float = 0.0
var chase_attack_timer: float = 0.0
var turn_pause_timer: float = 0.0
var is_attacking: bool = false
var is_hit: bool = false
var locked_facing_direction: bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	animation_player.animation_finished.connect(_on_animation_finished)
	animated_sprite.flip_h = false
	animation_player.play("walk")
	chase_attack_timer = randf_range(7.0, 8.0)

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	floor_check.position = floor_check_offset if not animated_sprite.flip_h else Vector2(-floor_check_offset.x, floor_check_offset.y)
	floor_check.target_position = floor_check_target if not animated_sprite.flip_h else Vector2(-floor_check_target.x, floor_check_target.y)
	
	if attack_area.get_child_count() > 0:
		var collision_shape = attack_area.get_child(0)
		if collision_shape is CollisionShape2D:
			collision_shape.position = attack_area_base_offset if not animated_sprite.flip_h else Vector2(-attack_area_base_offset.x, attack_area_base_offset.y)
	
	if current_state == State.CHASE and not is_attacking and not is_hit:
		chase_attack_timer -= delta
	
	match current_state:
		State.PATROL:
			_patrol_state(delta)
		State.IDLE:
			_idle_state(delta)
		State.CHASE:
			_chase_state(delta)
		State.BACK_OFF:
			_back_off_state(delta)
		State.POST_BACK_OFF:
			_post_back_off_state(delta)
		State.SECOND_ATTACK:
			_second_attack_state(delta)
		State.ATTACK3:
			_attack3_state(delta)
		State.HIT:
			_hit_state(delta)
		State.TURN_PAUSE:
			_turn_pause_state(delta)
	
	move_and_slide()

func _patrol_state(delta: float) -> void:
	if is_hit:
		return
	velocity.x = direction * patrol_speed
	animation_player.play("walk")
	animated_sprite.flip_h = direction < 0
	
	idle_timer -= delta
	if idle_timer <= 0:
		current_state = State.IDLE
		velocity.x = 0
		animation_player.play("idle")
		idle_timer = randf_range(idle_time_min, idle_time_max)

func _idle_state(delta: float) -> void:
	if is_hit:
		return
	velocity.x = 0
	idle_timer -= delta
	if idle_timer <= 0:
		current_state = State.PATROL
		direction *= -1
		animation_player.play("walk")
		idle_timer = randf_range(idle_time_min, idle_time_max)

func _chase_state(delta: float) -> void:
	if is_hit:
		return
	if player:
		var distance_to_player = player.global_position.x - global_position.x
		if not is_attacking:
			if abs(distance_to_player) <= close_distance:
				velocity.x = 0
				animation_player.play("attack")
				is_attacking = true
				locked_facing_direction = distance_to_player < 0
			elif chase_attack_timer <= 0:
				current_state = State.ATTACK3
				velocity.x = 0
				animation_player.play("attack3")
				locked_facing_direction = distance_to_player < 0
				chase_attack_timer = randf_range(7.0, 8.0)
			else:
				velocity.x = sign(distance_to_player) * chase_speed
				animation_player.play("walk")
				var collision = get_last_slide_collision()
				var is_wall_hit = collision and abs(collision.get_normal().x) > 0.8 
				var is_ledge = is_on_floor() and not floor_check.is_colliding()
				if is_wall_hit or is_ledge:
					animated_sprite.flip_h = not animated_sprite.flip_h
					velocity.x = 0
					current_state = State.TURN_PAUSE
					turn_pause_timer = 1.0
					animation_player.play("idle")
					return
		animated_sprite.flip_h = locked_facing_direction if is_attacking else distance_to_player < 0

func _back_off_state(delta: float) -> void:
	if is_hit:
		return
	if player:
		var distance_to_player = player.global_position.x - global_position.x
		velocity.x = -sign(distance_to_player) * back_off_speed
		animation_player.play("walk")
		animated_sprite.flip_h = velocity.x < 0
	
	back_off_timer -= delta
	if back_off_timer <= 0:
		current_state = State.POST_BACK_OFF
		post_back_off_timer = post_back_off_duration

func _post_back_off_state(delta: float) -> void:
	if is_hit:
		return
	if player:
		var distance_to_player = player.global_position.x - global_position.x
		velocity.x = 0
		animation_player.play("idle")
		animated_sprite.flip_h = distance_to_player < 0
	
	post_back_off_timer -= delta
	if post_back_off_timer <= 0:
		if randf() < 0.5:
			current_state = State.SECOND_ATTACK
			animation_player.play("attack2")
		else:
			current_state = State.CHASE

func _second_attack_state(delta: float) -> void:
	if is_hit:
		return
	if player:
		var distance_to_player = player.global_position.x - global_position.x
		velocity.x = 0
		animated_sprite.flip_h = distance_to_player < 0
	
	if animation_player.current_animation == "attack2" and animation_player.current_animation_position == 0:
		for offset in projectile_spawn_offsets:
			var projectile = projectile_scene.instantiate()
			projectile.global_position = global_position + offset
			get_tree().current_scene.add_child(projectile)

func _attack3_state(delta: float) -> void:
	if is_hit:
		return
	if player:
		# Stay still
		velocity.x = 0
		# Maintain locked facing direction
		animated_sprite.flip_h = locked_facing_direction

func _hit_state(delta: float) -> void:
	# Stay still during hit
	velocity.x = 0
	# Maintain locked facing direction from when hit was triggered
	animated_sprite.flip_h = locked_facing_direction

func _turn_pause_state(delta: float) -> void:
	if is_hit:
		return
	# Stay still and play idle
	velocity.x = 0
	animation_player.play("idle")
	# Count down pause timer
	turn_pause_timer -= delta
	if turn_pause_timer <= 0:
		# Resume chase
		current_state = State.CHASE

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		current_state = State.CHASE
		idle_timer = 0

func _on_attack_area_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.play_hit_animation2()

func play_hit_animation() -> void:
	if animation_player.has_animation("hit") and not is_hit and health > 0:
		is_hit = true
		is_attacking = false
		current_state = State.HIT
		health -= 1
		velocity.x = 0
		if health <= 0:
			animation_player.play("death")
		else:
			animation_player.play("hit")
		print("Boss hit, health reduced to: ", health)
	else:
		print("Error: 'hit' animation not found or already playing or boss is dead")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack" and current_state == State.CHASE:
		# Start back-off
		is_attacking = false
		current_state = State.BACK_OFF
		back_off_timer = back_off_duration
	elif anim_name == "attack2" and current_state == State.SECOND_ATTACK:
		# Return to chase after attack2
		current_state = State.CHASE
	elif anim_name == "attack3" and current_state == State.ATTACK3:
		# Randomly spawn summon, spell1, or spell2 (33% chance each)
		var rand = randf()
		if rand < 0.333:
			# Spawn summon above
			var summon = summon_scene.instantiate()
			summon.global_position = global_position + summon_spawn_offset
			get_tree().current_scene.add_child(summon)
		elif rand < 0.667:
			# Spawn spell1 to the side facing the player
			var spell_offset = Vector2(spell_spawn_offset if not locked_facing_direction else -spell_spawn_offset, 0)
			var spell = spell_scene.instantiate()
			spell.global_position = global_position + spell_offset
			get_tree().current_scene.add_child(spell)
		else:
			# Spawn four spell2 instances (two right, two left, slightly below)
			for offset in spell2_spawn_offsets:
				var spell2 = spell2_scene.instantiate()
				spell2.global_position = global_position + offset
				get_tree().current_scene.add_child(spell2)
		# Return to chase
		current_state = State.CHASE
	elif anim_name == "hit" and current_state == State.HIT:
		# Return to appropriate state after hit
		is_hit = false
		if player:
			current_state = State.CHASE
		else:
			current_state = State.PATROL
			direction = -1 if locked_facing_direction else 1
			animation_player.play("walk")
	elif anim_name == "death" and current_state == State.HIT:
		# Handle death (e.g., remove boss)
		queue_free()
