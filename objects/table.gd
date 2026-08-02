extends StaticBody2D
class_name Table

@export var table_id: int = 1
@export var seats: Array[Marker2D] = []

var current_party: Array[Customer] = []
var table_order: Dictionary = {}

var is_occupied: bool = false
var food_delivered: bool = false

func can_fit_party(party_size: int) -> bool:
	return not is_occupied and party_size <= seats.size()

func get_seat_position(seat_index: int) -> Vector2:
	if seat_index >= 0 and seat_index < seats.size():
		var seat_marker = seats[seat_index]
		if is_instance_valid(seat_marker):
			return seat_marker.global_position
	return global_position

func assign_party(party_nodes: Array[Customer]) -> void:
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
	if seats.is_empty() and has_node("Seats"):
		for child in $Seats.get_children():
			if child is Marker2D:
				seats.append(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
