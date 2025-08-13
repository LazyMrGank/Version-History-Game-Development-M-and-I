extends CharacterBody2D

@export var speed: float = 50.0  # Movement speed
@export var gravity: float = 980.0  # Gravity for platformer
@export var monster_scene: PackedScene  # Assign in inspector: res://path/to/monster.tscn

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var detection_area: Area2D = $Area2D
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var direction_timer: Timer = $DirectionTimer

var direction: int = 1  # 1 for right, -1 for left
var player_in_area: bool = false
var is_attacking: bool = false
var can_attack: bool = true

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	# Connect signals
	detection_area.body_entered.connect(_on_area_2d_body_entered)
	detection_area.body_exited.connect(_on_area_2d_body_exited)
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	direction_timer.timeout.connect(_on_direction_timeout)
	# Start initial direction timer with random time
	direction_timer.wait_time = rng.randf_range(1.0, 5.0)
	direction_timer.start()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_attacking:
		velocity.x = 0
	else:
		if player_in_area and can_attack:
			_attack()
		else:
			_move()

	move_and_slide()

func _move() -> void:
	velocity.x = direction * speed
	if velocity.x != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.stop()

func _attack() -> void:
	is_attacking = true
	can_attack = false
	velocity.x = 0
	animation_player.play("attack")

func _spawn_monster() -> void:
	if monster_scene:
		var monster = monster_scene.instantiate()
		get_parent().add_child(monster)
		monster.position = position  # Spawn at summoner's position; adjust if needed

func _on_cooldown_timeout() -> void:
	can_attack = true
	is_attacking = false  # Reset attacking state after cooldown

func _on_direction_timeout() -> void:
	direction = 1 if rng.randf() > 0.5 else -1
	direction_timer.wait_time = rng.randf_range(1.0, 5.0)
	direction_timer.start()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
