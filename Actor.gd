extends KinematicBody2D

# used in gravitational calculations
const GRAVITY = 20
const MAX_FALLING_SPEED = GRAVITY * 24

# used in jumping-related calculations
const JUMP_FORCE = GRAVITY * 12

# used in acceleration-based running-speed calculations
const MAX_RUNNING_SPEED = 180
const ACCELEARATION = MAX_RUNNING_SPEED / 8
const DECELERATION = MAX_RUNNING_SPEED / 4

# remember input
var up
var down
var left
var right

var startjump
var jumping

# used to determine whether the actor is accelerating or decelerating
#  depending on which direction they are heading and moving towards
#
# additionally: instead of using the direct input, 'dir_heading_to' is used
#  to determine which direction the player want to move as the variable only
#  remembers which input (left or right) was pressed last (if the player presses
#  both left and right because panic button smashing we choose the later) --> mercy
var dir_heading_to 
var dir_moving_to

# the final movement_velocity of the actor
var velocity = Vector2(0, 0)


# main loop
func _physics_process(_delta):
	
	control()
	gravity()
	movement()
	print(velocity == Vector2.ZERO)
	animate()


# controls the creature (for now: player/actor code, does a bunch of different
#  input related 
func control():
	
	# ugly input update code
	# TODO: (maybe?) clean up by reading input mappings as array, create
	#  dictonary
	left = Input.is_action_pressed("move_left")
	right = Input.is_action_pressed("move_right")
	up = Input.is_action_pressed("move_up")
	down = Input.is_action_pressed("move_down")
	
	# TODO: (1) change 'is_action_pressed()' to 'is_action_just_pressed()'
	#       (2) when in air and trying to jump, "remember" that for a few
	#            frames and try to jump when hitting the floor
	 
	jumping = Input.is_action_pressed("move_jump")
	startjump = Input.is_action_just_pressed("move_jump")
	
	# remember last input (why? read comment of 'dir_heading_to'), 'elif'
	#  because we prefer the right-direction in case both buttons are pressed
	#  at the very same frame, level goal will be on the right side? (intuitive)
	if Input.is_action_just_pressed("move_right"):
		dir_heading_to = 1
	elif Input.is_action_just_pressed("move_left"):
		dir_heading_to = -1
	
	# reset the 'remembered button' because we released both input buttons
	if (not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left")):
		dir_heading_to = 0


func movement():
	
	# determine the direction we are currently moving to
	dir_moving_to = sign(velocity.x)
	
	# if (we are trying to head towards the direction we are already moving towards or not moving (at all) yet: 
	if dir_heading_to == dir_moving_to or dir_moving_to == 0:
		
		# we use absolute values when calculating so we dont have to create conditional code 
		#  for moving left and right
		velocity.x = min(abs(velocity.x) + ACCELEARATION, MAX_RUNNING_SPEED) * dir_heading_to
	
	# else we want to decelerate (probably, let's hope no issue later on)
	else:
		
		# same as if-case
		velocity.x = max(abs(velocity.x) - DECELERATION, 0) * dir_moving_to
	
	if startjump:
		jump()
	
	# apply the final movement vector, move the character and calculate the
	#  remaining movement vector
	velocity = move_and_slide(velocity, Vector2.UP)


func gravity():
	
	var gravity = GRAVITY
	
	if velocity.y < 0 and jumping:
		gravity *= 0.5
	
	if velocity.y >= 0 and not is_on_floor():
		gravity *= 2.4
	
	velocity.y = min(velocity.y + gravity, MAX_FALLING_SPEED)


func jump():
	
	if is_on_floor():
		velocity.y -= (JUMP_FORCE + GRAVITY)


func animate():
	
	if velocity == Vector2.ZERO:
		
		get_node("Sprite").play("Idle")
		
	else:
		
		get_node("Sprite").play("Default")
