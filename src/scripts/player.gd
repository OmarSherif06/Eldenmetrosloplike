extends CharacterBody3D

@export var walk_speed: float = 3.5;
@export var sprint_speed: float = 5;
@export var jump_vel: float = 10;
@export var mouse_sens: float = 0.01;
@export var gravity: float = 9.8;
@onready var camera: Camera3D = $Camera3D;

# Bob variables
const BOB_FREQ = 2.0;
const BOB_AMP = 0.08;
var t_bob = 0.0;

# Fov variables
const BASE_FOV: float = 75.0;
const FOV_CHANGE: float = 1.5;

var speed: float;

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED; 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE; 
	
	# Recapture mouse
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Camera
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(- event.relative.x * mouse_sens)
		camera.rotate_x(- event.relative.y * mouse_sens)
		camera.rotation.x = clamp(camera.rotation.x,-1.5,1.5)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta;
	
	# Jumping
	if is_on_floor() and Input.is_action_pressed("Jump"):
		velocity.y = jump_vel;
	
	# Sprinting
	if Input.is_action_pressed("Sprint"):
		speed = sprint_speed;
	else:
		speed = walk_speed;
	
	# Movement
	var input_dir = Input.get_vector("Left","Right","Forward","Back");
	var direction = (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized();
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed;
			velocity.z = direction.z * speed;
		else:
			# Slow down gradually
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 9.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 9.0)
	else:
		# Slow down gradually
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# Fov
	var velocity_clamp = clamp(velocity.length(), 0.5, sprint_speed * 2);
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamp;
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0);
	
	move_and_slide();

func _headbob(time: float) -> Vector3:
	var pos = Vector3.ZERO
	
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
