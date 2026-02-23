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
var playerPos: Vector2

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

var LowPunch
var HighPunch
var Block
var BlockPunch
var GetHit
var Dodge

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthLabel = $Health
	healthLabel.text = str(health)
	anim = $AnimatedSprite2D
	anim.animation = "Idle"
	anim.play()
	LowPunch = $LowPunch
	HighPunch = $HighPunch
	Block = $Block
	BlockPunch = $BlockPunch
	GetHit = $GetHit
	Dodge = $Dodge


func _physics_process(delta: float) -> void:
	var playerDistance = position.x - playerPos.x
	move(delta, playerDistance)
	#jump()
	affectedByGravity(delta)
	#print(playerDistance)
	if (playerDistance > -110 && playerDistance < 110 && stamina >= 4):
		var ranMove = randi_range(0,2)
		if (false):
			punch()
		elif(false):
			defend()
		else:
			dodge()
			
	regenStamina(delta)
	reduceCooldown(delta)
	healthLabel.text = str(health, ", ", stamina)
	move_and_slide()
	
############MOVEMENT FUNCTIONS#################
func move(delta: float, playerDistance) -> void:
	var moveDir = 0
	if (playerDistance > 5):
		moveDir = -1
	elif (playerDistance < -5):
		moveDir = 1
	
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
	moveAnimate(moveDir)
	

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
	var ranPunch = randi_range(0,1)
	if (stamina >= 2 && moveCooldown <= 0):
		if (ranPunch == 0):
			anim.animation = "LowPunch"
			LowPunch.play()
			atkVal = 1
		else:
			anim.animation = "HighPunch"
			HighPunch.play()
			atkVal = 2
		spawnPunch(atkVal, anim.get_playing_speed())
		stamina -= 2
		moveCooldown = anim.get_playing_speed()
		
func spawnPunch(_atkVal, _lifeSpan):
	var createPunch = preload("res://Scenes/punch_projectile.tscn").instantiate()
	
	if (anim.flip_h):
		createPunch.position.x -= $CollisionShape2D.shape.get_rect().size.x/2
	else:
		createPunch.position.x += $CollisionShape2D.shape.get_rect().size.x/2
	createPunch.position.y += 25
	createPunch.atkVal = atkVal
	createPunch.lifeTimer = _lifeSpan
	createPunch.source = sourceName
	add_child(createPunch)

func defend():
	var ranDefend = randi_range(0,1)
	if (stamina >= 3 && moveCooldown <= 0):
		if (ranDefend == 0):
			anim.animation = "LowBlock"
			defVal = 1
		else:
			anim.animation = "HighBlock"
			defVal = 2
		Block.play()
		stamina -= 3
		moveCooldown = anim.get_playing_speed()

#The dodge function has a problem where dodging while moving left is weaker than dodging
# when moving right
func dodge():
	anim.animation = "Dodge"
	Dodge.play()
	stamina -= 4
	defVal = 3
	moveCooldown = anim.get_playing_speed()

func hit(incomingAtkVal:int):
	if (incomingAtkVal != atkVal && incomingAtkVal != defVal && defVal != 3):
		GetHit.play()
		health -= 1
	elif(incomingAtkVal == defVal):
		BlockPunch.play()

#Function to reduce the value on the moveCooldown, works like a timer
func reduceCooldown(delta:float):
	if (moveCooldown >= 0):
		moveCooldown -= delta
	else:
		moveCooldown = 0
		atkVal = 0
		defVal = 0
		anim.animation = "Idle"

#Function for regerating stamina
func regenStamina(delta:float):
	if (stamina < 4):
		stamina += regenRate * delta
	else:
		stamina = 4
####################################################

###########ANIMATION FUNCTIONS######################
func moveAnimate(moveDir):
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
##################################################
