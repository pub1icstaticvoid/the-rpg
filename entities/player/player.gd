extends CharacterBody2D

@export var move_speed: float = 120.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_detector: Area2D = $InteractionDetector

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * move_speed
		
		interaction_detector.rotation = input_vector.angle()
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()

func interact() -> void:
	var overlapping_areas = interaction_detector.get_overlapping_areas()
	
	if overlapping_areas.size > 0:
		var target = overlapping_areas[0]
		
		if target.has_method("on_interact"):
			target.on_interact()
		elif target.get_parent().has_method("on_interact"):
			target.get_parent().on_interact()
		else:
			print("interacted with: ", target.name)
	else:
		print("nothing nearby to interact with")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
