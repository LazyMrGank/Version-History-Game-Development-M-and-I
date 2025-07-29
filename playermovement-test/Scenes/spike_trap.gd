extends Node2D

@export var fall_speed: float = 300.0
@export var spike_move_distance: float = 50.0
@export var spike_move_speed: float = 200.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var retract_timer = $RetractTimer
@onready var spike_timer = $SpikeTimer
@onready var trigger_area = $TriggerArea
@onready var killzone = $Killzone
@onready var kill_collision = $Killzone

var is_triggered: bool = false
var is_moving_up: bool = false
var original_position: Vector2
var target_position: Vector2

func _ready():
	print("Racism")

	original_position = animated_sprite_2d.position
	target_position = original_position - Vector2(0, spike_move_distance)

	animated_sprite_2d.position = original_position
	killzone.monitoring = false
	spike_timer.one_shot = true
	retract_timer.one_shot = true

func _process(delta: float):
	if is_moving_up and animated_sprite_2d.position != target_position:
		animated_sprite_2d.position = animated_sprite_2d.position.move_towards(target_position, spike_move_speed * delta)
		kill_collision.position = animated_sprite_2d.position
		if animated_sprite_2d.position == target_position:
			is_moving_up = false
			print("SPIKE HAS ERECTED")
			
	elif not is_moving_up and animated_sprite_2d.position != original_position and not is_triggered:
		animated_sprite_2d.position = animated_sprite_2d.position.move_towards(original_position, spike_move_speed * delta)
		kill_collision.position = animated_sprite_2d.position
		if animated_sprite_2d.position == original_position:
			print("Spike is flacid")

func _on_trigger_area_body_entered(body: Node2D) -> void:
	if is_triggered:
		return
	if body.is_in_group("Player"):
		print("player is getting touched")
		is_triggered = true
		trigger_area.monitoring = false
		spike_timer.start()
		
func _on_spike_timer_timeout() -> void:
	print("spike is extending")
	is_moving_up = true
	killzone.monitoring = true
	retract_timer.start()
