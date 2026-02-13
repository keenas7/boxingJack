extends RigidBody2D

const MAX_SPEED = 250

@export var health = 3
@export var speed = 0
@export var accel = 400
@export var jumpVel = -250
var healthLabel
var anim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthLabel = $Health
	healthLabel.text = str(health)
	anim = $AnimatedSprite2D
	anim.animation = "Idle"
	anim.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	move(delta)
	jump(delta)
	
############MOVEMENT FUNCTIONS#################
func move(delta: float) -> void:
	var moveDir = Input.get_axis("MoveLeft","MoveRight")
	
	#More complex movement, commented out for now
	if (moveDir != 0):
		
		#If the player chooses a direction that is opposite to their current speed
		# then the player will "slide stop" and start moving in the opposite direction
		# with their initial speed being a quarter of what it currently was
		if ((moveDir < 0 && linear_velocity.x > 0)||(moveDir > 0 && linear_velocity.x < 0)):
			linear_velocity.x = (linear_velocity.x/4)*-1
		
		#Check to see if the player has exceeded their max speed
		if (abs(linear_velocity.x) < MAX_SPEED):
			linear_velocity.x += accel * moveDir * delta
		else:
			linear_velocity.x = MAX_SPEED * moveDir
	else:
		#This makes the player slow down, and prevents them from "jittering"
		# when their speed reaches 0, as the constant addition and
		# subtraction of the speed will cause it to go above and below 0
		# but never rarely reach it
		#The formula stops the player once their speed is below 10%
		# of their acceleration, in order to account for higher acceleration
		if (linear_velocity.x > accel*0.1):
			linear_velocity.x -= accel*2 * delta
		elif (linear_velocity.x < accel*-0.1):
			linear_velocity.x += accel*2 * delta
		else:
			linear_velocity.x = 0
	
	
	moveAnimate(delta,moveDir)
	#linear_velocity.x = MAX_SPEED * moveDir

func jump(delta):
	#Add a "is_grounded" check
	if (Input.is_action_pressed("Jump")):
		linear_velocity.y = jumpVel
####################################################

###########ANIMATION FUNCTIONS######################
func moveAnimate(delta, moveDir):
	#This will be how we control the different animations for movement
	if (moveDir != 0):
		#Here as a placeholder
		#anim.animation = "Walk"
		
		#This is to ensure that the player will be facing the direction they were going
		# when they stop walking
		if (moveDir < 0):
			anim.flip_h = true
		elif (moveDir > 0):
			anim.flip_h = false
	else:
		anim.animation = "Idle"
##################################################
