extends Node
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = preload("res://Scenes/player_phys_2.tscn").instantiate()
	player.position = $PlayerSpawn.position
	add_child(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
