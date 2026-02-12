extends Area2D

const MAX_SPEED = 250

@export var health = 3
@export var speed = 0
@export var accel = 400
var healthLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthLabel = $Health
	healthLabel.text = str(health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	move(delta)
	
	
func move(delta: float) -> void:
	var moveDir = Input.get_axis("MoveLeft","MoveRight")
	'''
	#More complex movement, commented out for now
	if (moveDir != 0):
		
		#If the player chooses a direction that is opposite to their current speed
		# then the player will "slide stop" and start moving in the opposite direction
		# with their initial speed being a quarter of what it currently was
		if ((moveDir < 0 && speed > 0)||(moveDir > 0 && speed < 0)):
			speed = (speed/4)*-1
		
		#Check to see if the player has exceeded their max speed
		if (abs(speed) < MAX_SPEED):
			speed += accel * moveDir * delta
		else:
			speed = MAX_SPEED * moveDir
	else:
		#This makes the player slow down, and prevents them from "jittering"
		# when their speed reaches 0, as the constant addition and
		# subtraction of the speed will cause it to go above and below 0
		# but never rarely reach it
		#The formula stops the player once their speed is below 10%
		# of their acceleration, in order to account for higher acceleration
		if (speed > accel*0.1):
			speed -= accel*2 * delta
		elif (speed < accel*-0.1):
			speed += accel*2 * delta
		else:
			speed = 0
	position.x += speed * delta
	'''
	position.x += MAX_SPEED * delta
