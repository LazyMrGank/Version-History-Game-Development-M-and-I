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
