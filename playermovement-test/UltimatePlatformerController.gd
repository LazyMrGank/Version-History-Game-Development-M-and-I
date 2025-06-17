extends CharacterBody2D
# Movement parameters
@export var move_speed: float = 200.0
@export var acceleration: float = 1500.0
@export var deceleration: float = 1000.0
@export var jump_velocity: float = 300.0
@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.2
@export var attack_duration: float = 0.5
@onready var coyote_timer = $CoyoteTime
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var jump_height_timer = $JumpHeightTimer
const jump_power = -300.0
const wall_jump_pushback = 100
const wall_slide_gravity = 100
var is_wall_sliding = false
var can_coyote_jump = false
var jump_buffered = false
const jump_height: float = -180
const max_speed: float = 60
const friction: float = 10
# Get the gravity from the project settings
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float = 0.0
var last_direction: float = 1.0  # Default facing right
var is_dashing: bool = false
var dash_timer: float = 0.0
var is_attacking: bool = false
var attack_timer: float = 0.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D  # Adjust to your node name

func _physics_process(delta: float) -> void:

	
	var was_on_floor = is_on_floor()
	# Handle timers
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
	
	# Handle input and movement
	if not is_dashing:  # Normal movement (not dashing)
		# Apply gravity if not on floor or dashing
		if not is_on_floor() && (can_coyote_jump == false):
			velocity.y += gravity * delta
			if velocity.y > 500:
				velocity.y = 500
		# Handle jump
		
		if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
			velocity.y = -jump_velocity
			jump_height_timer.start()
			jump()
		
		# Handle dash (only in air, not during attack)
		if Input.is_action_just_pressed("dash") and not is_on_floor() and not is_dashing and not is_attacking:
			is_dashing = true
			dash_timer = dash_duration
			velocity.y = 0  # Dash is unaffected by gravity
			velocity.x = last_direction * dash_speed
		
		# Handle attack (only on ground)
		if Input.is_action_just_pressed("attack") and is_on_floor() and not is_dashing:
			is_attacking = true
			attack_timer = attack_duration
			if abs(velocity.x) < 10:  # If nearly stopped, stop immediately
				velocity.x = 0
			# Else, let deceleration handle slowdown during attack
		
		# Handle horizontal movement (not during dash or attack)
		if not is_attacking and not is_dashing:
			direction = Input.get_axis("move_left", "move_right")
		if not is_dashing:
			if direction != 0 and not is_attacking:
				last_direction = direction  # Update facing direction
				velocity.x = move_toward(velocity.x, direction * move_speed, acceleration * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		
	# Update sprite facing
	sprite.scale.x = last_direction
	
	# Update animations
	update_animations()
	
	# Move the character
	jump()
	move_and_slide()
	if was_on_floor && !is_on_floor() && velocity.y >= 0:
		can_coyote_jump = true
		coyote_timer.start()
	
	if !was_on_floor && is_on_floor():
		if jump_buffered:
			jump_buffered = false
			print("buffered jump")
			jump()
	attack()
	wall_slide(delta)

func _on_coyote_time_timeout() -> void:
	can_coyote_jump = false

func _input(event):
	if event.is_action_released("jump"):
		if velocity.y < 0.0:
			velocity.y *= 0.5
					
func _on_jump_buffer_timer_timeout() -> void:
	jump_buffered = false
	print("Jump buffered false")

func _on_jump_height_timer_timeout() -> void:
	if !Input.is_action_pressed("jump"):
		if velocity.y < -100:
			velocity.y = 0
			print("Cow")
	else:
		print("high jump")

func update_animations() -> void:
	if is_attacking and is_on_floor():
		animation_player.play("attack")
	elif is_dashing:
		animation_player.play("dash")
	elif not is_on_floor():
		if velocity.y < 0:
			animation_player.play("jump")
		else:
			animation_player.play("falling")
	elif abs(velocity.x) > 10:  # Threshold to prevent jittery transitions
		animation_player.play("run")
	else:
		animation_player.play("idle")
		
	
func attack():
	var overlapping_objects = $HitDetector.get_overlapping_areas()
	
	for area in overlapping_objects:
		var parent = area.get_parent()
		print(parent.name)
		
func jump():
	if Input.is_action_just_pressed("jump"):
		if is_on_wall() and Input.is_action_pressed("move_right"):
				velocity.y = jump_power
				velocity.x = -wall_jump_pushback
		if is_on_wall() and Input.is_action_pressed("move_left"):
				velocity.y = jump_power
		if is_on_floor() || can_coyote_jump:
			if can_coyote_jump:
				velocity.y = jump_velocity
				can_coyote_jump = false
				print("coyote")
		else:
			if !jump_buffered:
				jump_buffered = true
				jump_buffer_timer.start()
				print("Jump buffered true")
			
func wall_slide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			is_wall_sliding = true
		else: 
			is_wall_sliding = false
	else:
		is_wall_sliding = false
		
	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)
		
