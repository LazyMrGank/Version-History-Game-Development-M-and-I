extends CollisionShape2D

var checkpoint_manager
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	checkpoint_manager = $"../../../CheckPointManager"
	player = $"../../../Player"

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


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):#HOLY CRAP PLAYER GOT TOUCHED FOR REALIES OMG")
		print("no it was I")
		killPlayer()


func _on_area_2d_3_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):#HOLY CRAP PLAYER GOT TOUCHED FOR REALIES OMG")
		print("it was I")
		killPlayer()




func _on_area_2d_4_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):#HOLY CRAP PLAYER GOT TOUCHED FOR REALIES OMG")
		print("god it was I")
		killPlayer()


func _on_area_2d_5_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):#HOLY CRAP PLAYER GOT TOUCHED FOR REALIES OMG")
		print("god it was I")
		killPlayer()


func _on_area_2d_6_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):#HOLY CRAP PLAYER GOT TOUCHED FOR REALIES OMG")
		print("god it was I")
		killPlayer()


func _on_area_2d_7_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):#HOLY CRAP PLAYER GOT TOUCHED FOR REALIES OMG")
		print("god it was I")
		killPlayer()


func _on_area_2d_9_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):#HOLY CRAP PLAYER GOT TOUCHED FOR REALIES OMG")
		print("god it was I")
		killPlayer()


func _on_area_2d_15_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):#HOLY CRAP PLAYER GOT TOUCHED FOR REALIES OMG")
		print("god it was I")
		killPlayer()
