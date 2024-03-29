## TODO: Braking, max speed in reverse, freeze body after full stop, drift wheel marks

extends VehicleBody3D

## Wheel nodes
@onready var _WHEELS: Array[VehicleWheel3D] = [$BackL, $BackR, $FrontL, $FrontL]

## Camera mouse sensitivity 
const _MOUSE_SENSITIVITY := 0.0025

## Max velocity the vehicle body can reach
const _MAX_VELOCITY := 25
## Engine force applied when accelerating
const _ACCELERATION := 4000
## Variable used to control current max velocity
var _velocity_limit := _MAX_VELOCITY
## Map of _MAX_VELOCITY reached when moving
var _velocity_percent: float = 0

## Steering in radians when moving at _MAX_VELOCITY
const _MIN_STEER := 0.12
## Steering in radians when not moving
const _MAX_STEER := 0.75
## Variable used to control steering
var _steer := _MAX_STEER

## Wheel friction slip
const _MAX_FRICTION = 3.5
## Wheel roughness recover after loosing grip
const _FRICTION_RECOVER_FACTOR = 0.03
## Ammount of rolling in the steering axis when handbrake drifting
const _DRIFT_PIVOTING = 0.9

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	#print(center_of_mass.y)
	#if rotation.z > 0.6 or rotation.z < -0.6: center_of_mass.y = 0.35
	#else : center_of_mass.y = 0.2
	_velocity_percent = linear_velocity.length() / _MAX_VELOCITY
	direction_control(delta)
	manage_wheels()

func _input(event):
	camera_control(event)
	
func camera_control(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		$CameraPivotY.rotate_y(-event.relative.x * _MOUSE_SENSITIVITY)
		$CameraPivotY/CameraPivotX.rotate_x(event.relative.y * _MOUSE_SENSITIVITY)

func direction_control(delta):
	if linear_velocity.length() < _velocity_limit:
		engine_force = Input.get_axis("ui_down","ui_up") * _ACCELERATION
	else: engine_force = 0
	var steer_diff = _MAX_STEER - _MIN_STEER
	_steer = _MAX_STEER - steer_diff * _velocity_percent
	var to = Input.get_axis("ui_right","ui_left") * _steer
	steering = move_toward(steering, to, delta * 2.5)

func manage_wheels():
	for wheel in _WHEELS:
		wheel.wheel_roll_influence = clamp(_velocity_percent, 0, 1)
		wheel.wheel_friction_slip = move_toward(
			wheel.wheel_friction_slip, 
			_MAX_FRICTION, 
			_FRICTION_RECOVER_FACTOR
		)
		handbrake(wheel)

func handbrake(wheel: VehicleWheel3D):
	if Input.is_action_pressed("handbrake"):
		var friction_slip = 0
		wheel.brake = 20
		var slip_ammount = _MAX_FRICTION * _velocity_percent
		if !wheel.use_as_steering:
			slip_ammount = slip_ammount * _DRIFT_PIVOTING
		friction_slip = _MAX_FRICTION - slip_ammount
		wheel.wheel_friction_slip = friction_slip
		_velocity_limit = 1
	else:
		wheel.brake = 0
		_velocity_limit = _MAX_VELOCITY
