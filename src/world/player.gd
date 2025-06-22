extends CharacterBody3D

const SPEED: float         = 5.0
const JUMP_VELOCITY: float = 4.5
@onready var camera_3d: Camera3D = $"../Camera3D"


func _physics_process(delta: float) -> void:
    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta

    # Handle jump.
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var direction := (camera_3d.transform.basis*Vector3(input_dir.x, 0, input_dir.y)).normalized()
    rotate_player(input_dir)
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()


func rotate_player(output):
    var direction := (camera_3d.global_transform.basis * transform.basis * Vector3(output.x, 0, -output.y)).normalized()
    var angle     := Vector2(direction.x, direction.z).angle()
    rotate_y(lerp_angle(0, angle, 0.5))
