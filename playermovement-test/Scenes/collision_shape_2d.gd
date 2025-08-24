extends CollisionShape2D

var last_location
var checkpoint_manager
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	checkpoint_manager = get_parent().get_node("CheckPointManager")
	player = get_parent().get_node("Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):#HOLY CRAP PLAYER GOT TOUCHED FOR REALIES OMG")
		killPlayer()


func _on_another_death_barrier_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):#HOLY CRAP PLAYER GOT TOUCHED FOR REALIES OMG")
		killPlayer()


func _on_another_another_death_barrier_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):#HOLY CRAP PLAYER GOT TOUCHED FOR REALIES OMG")
		killPlayer()


func _on_another_another_another_death_barrier_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):#HOLY CRAP PLAYER GOT TOUCHED FOR REALIES OMG")
		killPlayer()


func killPlayer():
	player.position = checkpoint_manager.last_location
