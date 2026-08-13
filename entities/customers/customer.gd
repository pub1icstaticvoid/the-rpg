extends CharacterBody2D
class_name Customer

@export var move_speed: float = 60.0

var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var is_seated: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _physics_process(_delta: float) -> void:
	if not is_moving:
		return
	
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		global_position = target_position
		is_moving = false
		is_seated = true
		on_seated()
		return
	
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = global_position.direction_to(next_path_position)
	
	velocity = direction * move_speed
	move_and_slide()

func walk_to_seat(seat_pos: Vector2) -> void:
	target_position = seat_pos
	is_moving = true
	is_seated = false
	
	if not is_inside_tree():
		await ready
	await get_tree().physics_frame
	
	nav_agent.target_position = seat_pos
	
	if nav_agent.is_target_reachable() == false:
		print("target unreachable. directing routing to ", seat_pos)

func on_seated() -> void:
	print(name, " has sat down at their table seat")

func _ready() -> void:
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
