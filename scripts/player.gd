extends CharacterBody2D


@export var SPEED = 300.0
@export var MAX_FALL_SPEED= 1000

@export var JUMP_HEIGHT      = 100
@export var JUMP_TIME_PEAK   = 0.3
@export var JUMP_TIME_DECENT = 0.26
@export var VARIABLE_JUMP_HEIGHT = 220

@onready var JUMP_VELOCITY = ((2.0 * JUMP_HEIGHT) / JUMP_TIME_PEAK) * -1.0
@onready var JUMP_GRAVITY  = ((-2.0 * JUMP_HEIGHT) / (JUMP_TIME_PEAK * JUMP_TIME_PEAK)) * -1.0
@onready var VARIABLE_JUMP_GRAVITY  = ((JUMP_VELOCITY * JUMP_VELOCITY) / (2.0 * VARIABLE_JUMP_HEIGHT))
@onready var FALL_GRAVITY  = ((-2.0 * JUMP_HEIGHT) / (JUMP_TIME_DECENT * JUMP_TIME_DECENT)) * -1.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dashing = false
var dashing_time = 1
var dashing_time_tracker = 0
var dashing_speed = 1200
var dashing_friction = 1200 ** (3)
var dashing_direction = Vector2(0,0)

var is_wall_jumping = false
var wall_jump_time = 0.6
var wall_jump_time_tracker = 0

var has_double_jump = true
var is_jumping = false

var arbitrary_tracker = 0

func _physics_process(delta):
	#print("Dashing: "+str(dashing)+"  dashing_time_tracker: " + str(dashing_time_tracker))
	if Input.is_action_just_pressed("dash") and ! dashing:
		dashing = true
		dashing_direction = Vector2(Input.get_axis("move_left", "move_right"),Input.get_axis("move_up", "move_down")).normalized()
		dashing_direction.y *= 1.0
		velocity = dashing_direction * dashing_speed
		move_and_slide()
		return
	if dashing:
		dashing_time_tracker += delta
		if dashing_time_tracker > dashing_time or velocity.length() < SPEED:
			dashing = false
			dashing_time_tracker = 0
		elif velocity.y > MAX_FALL_SPEED:
			print("ok")
			dashing = false
			dashing_time_tracker = 0
		else:
			velocity = dashing_direction * (dashing_speed - ((dashing_time_tracker)*dashing_friction ) ** (1.0/3) )
			move_and_slide()
			return
	if is_wall_jumping:
		print(str(wall_jump_time_tracker))
		wall_jump_time_tracker += delta
		if wall_jump_time_tracker > wall_jump_time:
			is_wall_jumping = false
			wall_jump_time_tracker = 0
		else: 
			velocity.y += get_gravity() * delta
			move_and_slide()
			return
	# Add the gravity.
	if not is_on_floor() and not (is_on_wall() and Vector2(Input.get_axis("move_left", "move_right"),0).normalized() + get_wall_normal() == Vector2(0,0)) :
		velocity.y += get_gravity() * delta
		if velocity.y > MAX_FALL_SPEED:
			velocity.y=MAX_FALL_SPEED
	elif not is_on_floor() and is_on_wall():
		arbitrary_tracker += delta
		velocity.y += get_gravity() * delta * 0.5
		if velocity.y > MAX_FALL_SPEED/5.0:
			velocity.y=MAX_FALL_SPEED/5.0
	elif is_on_floor():
		has_double_jump = true
		is_jumping = false
	# Handle jump.
	if Input.is_action_just_pressed("jump") and ( is_on_floor() or has_double_jump) and not is_on_wall():
		if ! is_on_floor():
			has_double_jump = false
		jump()
	if Input.is_action_just_pressed("jump") and is_on_wall():
		wall_jump()
		move_and_slide()
		return

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func get_gravity() -> float:
	if velocity.y < 0.0 and Input.is_action_pressed("jump"):
		return VARIABLE_JUMP_GRAVITY
	elif velocity.y < 0.0:
		return JUMP_GRAVITY
	else:
		return FALL_GRAVITY
	
func jump():
	velocity.y = JUMP_VELOCITY
	is_jumping = true
	
func wall_jump():
	velocity.y = JUMP_VELOCITY
	velocity.x = -get_wall_normal().x*JUMP_VELOCITY / 3.0
	is_jumping = true
	is_wall_jumping = true
