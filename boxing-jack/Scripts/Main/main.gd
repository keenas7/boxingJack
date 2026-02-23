extends Node
var player
var enemy
var retryButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = preload("res://Scenes/player_phys_2.tscn").instantiate()
	player.position = $PlayerSpawn.position
	add_child(player)
	
	enemy = preload("res://Scenes/enemy.tscn").instantiate()
	enemy.position = $EnemySpawn.position
	add_child(enemy)
	
	retryButton = $ButtonLayer/Retry
	retryButton.hide()
	retryButton.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	enemy.playerPos = player.position
	if (player.health <= 0 || enemy.health <= 0):
		retryButton.show()
		retryButton.disabled = false
		
		#Send player and enemy into the void, where they can't be heard
		# (That's pretty dark)
		player.position = Vector2(-2100,2100)
		enemy.position = Vector2(2100,-2100)

func _on_retry_pressed() -> void:
	#Code taken from here: https://forum.godotengine.org/t/reloading-a-scene/11896/3 
	get_tree().reload_current_scene()
