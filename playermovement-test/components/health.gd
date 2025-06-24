class_name Health
extends Node


signal max_health_changed(diff: int)
signal health_changed(diff: int)
signal health_depleted


@export var max_health: int = 3
@export var immortality: bool = false

var immortality_time: Timer = null

@onready var health: int = max_health
