extends Area2D

var source
var atkVal
var lifeTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	lifeTimer -= delta
	if (lifeTimer <= 0):
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if (body.has_method("hit") && body.sourceName != source):
		body.hit(atkVal)
		
		#Despawn the punch projectile once it hits the player
		# so it won't be able to hit them again
		queue_free()
