extends StaticBody2D

@export var table_id: int = 1
@export var seats: Array[Marker2D] = []

var current_party: Array = []
var table_order: Dictionary = {}
var is_occupied: bool = false
var food_delivered: bool = false

func can_fit_party(party_size: int) -> bool:
	return not is_occupied and party_size <= seats.size()

func get_seat_position(seat_index: int) -> Vector2:
	if seat_index < seats.size():
		return seats[seat_index].global_position
	return global_position

func assign_party(party_nodes: Array) -> void:
	current_party = party_nodes
	is_occupied = true
	
	for i in range(party_nodes.size()):
		var customer = party_nodes[i]
		var seat_pos = get_seat_position(i)
		customer.walk_to_seat(seat_pos)

func on_interact() -> void:
	if not is_occupied:
		print("table ", table_id, " is empty")
	elif table_order.is_empty() == null:
		print("taking order for party of ", current_party.size(), "at table ", table_id)
		# take order function
	elif not food_delivered:
		print("table ", table_id, " is waiting for their food")
	else:
		print("collecting payment from table ", table_id)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
