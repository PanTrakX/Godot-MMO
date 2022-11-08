class_name PlayerCharacter
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree() -> void:
	set_multiplayer_authority(str(self.name).to_int())
	$MultiplayerSynchronizer.set_multiplayer_authority(1)
	return


func _ready() -> void:
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		%Camera.current = true
	return


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventMouseMotion:
			rpc_id(1, "server_rotate", event.relative)
	return


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		
		rpc_id(1, "server_move", input_dir)
		
	if multiplayer.is_server():
		move_and_slide()


@rpc
func server_move(input_dir) -> void:
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	return

@rpc
func server_rotate(mouse_motion: Vector2) -> void:
	rotate_y(-mouse_motion.x * 0.01)
	$Head.rotate_x(-mouse_motion.y * 0.01)
	return
