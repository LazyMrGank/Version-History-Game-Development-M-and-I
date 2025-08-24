extends Area2D

var checkpoint_manager
var last_location

func _ready() -> void:
	checkpoint_manager = get_parent().get_node("CheckPointManager")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		checkpoint_manager.last_location = $Respawnpoint.global_position
