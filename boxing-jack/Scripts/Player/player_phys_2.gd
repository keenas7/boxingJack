extends CharacterBody2D

const MAX_SPEED = 250

@export var health = 3
@export var speed = 0
@export var accel = 400
@export var jumpVel = -250
@export var gravityMul = 0.5
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
	affectedByGravity(delta)
	move_and_slide()
	
############MOVEMENT FUNCTIONS#################
func move(delta: float) -> void:
	var moveDir = Input.get_axis("MoveLeft","MoveRight")
	
	#More complex movement, commented out for now
	if (moveDir != 0):
		
		#If the player chooses a direction that is opposite to their current speed
		# then the player will "slide stop" and start moving in the opposite direction
		# with their initial speed being a quarter of what it currently was
		if ((moveDir < 0 && velocity.x > 0)||(moveDir > 0 && velocity.x < 0)):
			velocity.x = (velocity.x/4)*-1
		
		#Check to see if the player has exceeded their max speed
		if (abs(velocity.x) < MAX_SPEED):
			velocity.x += accel * moveDir * delta
		else:
			velocity.x = MAX_SPEED * moveDir
	else:
		#This makes the player slow down, and prevents them from "jittering"
		# when their speed reaches 0, as the constant addition and
		# subtraction of the speed will cause it to go above and below 0
		# but never rarely reach it
		#The formula stops the player once their speed is below 10%
		# of their acceleration, in order to account for higher acceleration
		if (velocity.x > accel*0.1):
			velocity.x -= accel*2 * delta
		elif (velocity.x < accel*-0.1):
			velocity.x += accel*2 * delta
		else:
			velocity.x = 0
	
	
	moveAnimate(delta,moveDir)
	#velocity.x = MAX_SPEED * moveDir

func jump(delta):
	#Part of the code is taken from the base code for the "CharacterBody2D"
	# script template
	if (Input.is_action_just_pressed("Jump") && is_on_floor()):
		velocity.y = jumpVel
		
#This function is needed to control the gravity since there does not seem
# to be a way to control it by default from the inspector
func affectedByGravity(delta:float):
	#Part of the jump code is taken from the base code for the "CharacterBody2D"
	# script template
	if (not is_on_floor()):
		velocity.y += get_gravity().y * gravityMul * delta
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
