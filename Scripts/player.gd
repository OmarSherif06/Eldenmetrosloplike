extends CharacterBody3D

@export var speed = 5;
@export var jump_vel = 10;
@export var mouse_sens = 0.01;
@export var gravity = 9.8;
@onready var camera_3d: Camera3D = $Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED; 
	print("hello world");


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta;
	
	if is_on_floor() and Input.is_action_just_pressed("Jump"):
		velocity.y = jump_vel;
	
	var input_dir = Input.get_vector("Left","Right","Forward","Back");
	var direction = (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized();
	print(direction)
	velocity.x = direction.x * speed;
	
	velocity.z = direction.z * speed;
	
	move_and_slide();


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE; 
	
	if event is InputEventMouseMotion:
		rotate_y(- event.relative.x * mouse_sens)
		camera_3d.rotate_x(- event.relative.y * mouse_sens)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x,-1.5,1.5)
	
