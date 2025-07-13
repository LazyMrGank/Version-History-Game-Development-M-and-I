extends Control

@onready var health = $"../Health"
@onready var health_bar = $TextureProgressBar


func _on_health_depleted():
	health_bar.value = 0
	
func _on_health_health_changed(diff: int) -> void:
	health_bar.value = health.get_health()
	pass # Replace with function body.


func _on_health_max_health_changed(diff: int) -> void:
	health_bar.max_value = health.get_max_health()
	pass # Replace with function body.
	
func _ready():
	# Connect signals
	health.health_changed.connect(_on_health_health_changed)
	health.max_health_changed.connect(_on_health_max_health_changed)
	health.health_depleted.connect(_on_health_depleted)
	
	# Initialize health bar
	health_bar.max_value = health.get_max_health()
	health_bar.value = health.get_health()
