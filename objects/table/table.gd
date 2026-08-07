extends StaticBody2D
class_name Table

enum TableState {
	EMPTY,
	WAITING_TO_ORDER,
	WAITING_FOR_FOOD,
	EATING,
	WAITING_FOR_CLEANUP
}

const MENU_ITEMS: Array[String] = [
	"Omurice", 
	"Curry Rice", 
	"Hamburg Steak", 
	"Coffee", 
	"Parfait", 
	"Tea"
]

@export var table_id: int = 1
@export var seats: Array[Marker2D] = []

var current_state: TableState = TableState.EMPTY
var current_party: Array[Customer] = []

# table_orders and customer_desired_orders format:
# {
#	"item_name": String,
#	"quantity": int
# }

var table_orders: Array[Dictionary] = []
var customer_desired_orders: Array[Dictionary] = []

func can_fit_party(party_size: int) -> bool:
	return current_state == TableState.EMPTY and party_size <= seats.size()

func get_seat_position(seat_index: int) -> Vector2:
	if seat_index >= 0 and seat_index < seats.size():
		var seat_marker = seats[seat_index]
		if is_instance_valid(seat_marker):
			return seat_marker.global_position
	return global_position

func assign_party(party_nodes: Array[Customer]) -> void:
	current_party = party_nodes
	current_state = TableState.WAITING_TO_ORDER
	table_orders.clear()
	customer_desired_orders.clear()
	
	var num_unique_items: int = randi_range(1, MENU_ITEMS.size())
	var available_menu = MENU_ITEMS.duplicate()
	available_menu.shuffle()
		
	for i in range(num_unique_items):
		var item_name: String = available_menu.pop_back()
		var item_qty: int = randi_range(1, party_nodes.size())
		
		customer_desired_orders.append({
			"item_name": item_name,
			"quantity": item_qty
		})
	
	print("table ", table_id, " seated party of ", party_nodes.size(), ". generated order: ", customer_desired_orders)
	
	for i in range(party_nodes.size()):
		var customer = party_nodes[i]
		if is_instance_valid(customer):
			var seat_pos: Vector2 = get_seat_position(i)
			customer.walk_to_seat(seat_pos)

func on_interact() -> void:
	match current_state:
		TableState.EMPTY:
			print("table ", table_id, " is empty")
		TableState.WAITING_TO_ORDER, TableState.WAITING_FOR_FOOD:
			print("taking order for party of ", current_party.size(), " at table ", table_id)
			var order_pad = get_tree().root.find_child("OrderPad", true, false)
			
			if order_pad:
				order_pad.open_for_table(self)
				
				var submitted_data = await order_pad.order_submitted
				
				if not submitted_data.is_empty():
					table_orders = submitted_data
					current_state = TableState.WAITING_FOR_FOOD
					print("order confirmed for table %d: " % table_id, table_orders)
					
					var ticket_payload = {
						"table": self,
						"orders": table_orders
					}
					
					_spawn_written_ticket(ticket_payload)
				else: 
					print("order cancelled for table %d. remaining in WAITING_TO_ORDER" % table_id)
		TableState.EATING:
			print("table ", table_id, " is currently eating")
		TableState.WAITING_FOR_CLEANUP:
			print("collecting payment and clearing table ", table_id)
			clear_table()

func _spawn_written_ticket(ticket_payload: Dictionary) -> void:
	var tray_container = get_tree().root.find_child("TrayContainer", true, false)
	if tray_container == null:
		print("table error: could not find tray container")
		return
	
	var existing_ticket: TicketItem = null
	
	for child in tray_container.get_children():
		if child is TicketItem and child.target_table_id == table_id:
			existing_ticket = child
			break
	
	if existing_ticket:
		print("table %d: ticket already in tray. updating data." % table_id)
		existing_ticket.setup(ticket_payload)
	else:
		print("table %d: spawning new ticket in tray." % table_id)
		var ticket_scene = preload("res://objects/ticket_item/ticket_item.tscn")
		var ticket_instance = ticket_scene.instantiate() as TicketItem
		
		tray_container.add_child(ticket_instance)
		ticket_instance.setup(ticket_payload)

func clear_table() -> void:
	for customer in current_party:
		customer.leave_cafe()
	current_party.clear()
	table_orders.clear()
	current_state = TableState.EMPTY

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if seats.is_empty() and has_node("Seats"):
		for child in $Seats.get_children():
			if child is Marker2D:
				seats.append(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
