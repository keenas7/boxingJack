extends CharacterBody2D

const MAX_SPEED = 250

var sourceName = "Enemy"
@export var health = 3
@export var speed = 0
@export var accel = 400
@export var jumpVel = -250
@export var gravityMul = 0.5
@export var dodgeForceX = -250
@export var dodgeForceY = -50
var tempTimer = 3

@export var stamina = 4
@export var regenRate = 1

#atkVal and defVal are used for comparing the high/low blocks/punches between the players
# 0 - means nothing
# 1 - means low block/attack
# 2 - means high block/attack
var atkVal = 0
var defVal = 0

#moveCooldown is used to determine how long a move should stay active once performed
# This is to make it so that blocking doesn't have to be frame perfect, but instead, the player has some "leeway"
# However, when the moveCooldown timer is >0, the player is not able to perform anymore moves
var moveCooldown = 0

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
	#move(delta)
	#jump()
	affectedByGravity(delta)
	#punch()
	defend(delta)
	#dodge()
	regenStamina(delta)
	reduceCooldown(delta)
	healthLabel.text = str(health, ", ", stamina)
	move_and_slide()
	
############MOVEMENT FUNCTIONS#################
func move(delta: float) -> void:
	var moveDir = Input.get_axis("MoveLeft","MoveRight")
	
	#More complex movement
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
			velocity.x -= accel * moveDir * delta
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
	

func jump():
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

###############ATTACK/DEFENSE FUNCTIONS##############
func punch():
	#This is to check if a move has been performed, that way the function doesn't end up eating the
	# player's stamina
	var hasMoveBeenPressed = Input.is_action_just_pressed("LowPunch") || Input.is_action_just_pressed("HighPunch")
	if (hasMoveBeenPressed && stamina >= 2 && moveCooldown <= 0):
		if (Input.is_action_just_pressed("LowPunch")):
			print("LowPunch")
			atkVal = 1
		elif (Input.is_action_just_pressed("HighPunch")):
			print("HighPunch")
			atkVal = 2
		stamina -= 2
		moveCooldown = 0.5

func defend(delta):
	if (tempTimer <= 0):
		defVal = 2
		moveCooldown = anim.get_playing_speed()
		stamina -= 2
		tempTimer = 3
	else:
		tempTimer -= delta

#The dodge function has a problem where dodging while moving left is weaker than dodging
# when moving right
func dodge():
	if (Input.is_action_just_pressed("Dodge") && stamina >= 4 && moveCooldown <= 0):
		print("Dodge")
		stamina -= 4
		defVal = 3
		moveCooldown = 0.5

#Function to reduce the value on the moveCooldown, works like a timer
func reduceCooldown(delta:float):
	if (moveCooldown > 0):
		moveCooldown -= delta
	else:
		moveCooldown = 0
		atkVal = 0
		defVal = 0
		

#Function for regerating stamina
func regenStamina(delta:float):
	if (stamina < 4):
		stamina += regenRate * delta
	else:
		stamina = 4
		
func hit(incomingAtkVal:int):
	if (incomingAtkVal != atkVal && incomingAtkVal != defVal):
		health -= 1
		
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
