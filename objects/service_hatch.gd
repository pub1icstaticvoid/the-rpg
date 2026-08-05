extends Area2D
class_name ServiceHatch

# Format per ticket: { "table": table_ref, "orders": Array[Dictionary] }
var active_tickets: Array[Dictionary] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_hatch_ui()

func on_interact() -> void:
	var table_to_submit: Table = _get_pending_table()
	
	if table_to_submit == null or table_to_submit.table_orders.is_empty():
		print("service hatch: no valid order to submit")
		return
	
	submit_ticket(table_to_submit)

func submit_ticket(table_with_order: Table) -> void:
	var existing_index = -1
	for i in range(active_tickets.size()):
		if active_tickets[i]["table"] == table_with_order:
			existing_index = i
			break
	
	if existing_index != -1:
		active_tickets[existing_index]["orders"] = table_with_order.table_orders.duplicate(true)
		print("service hatch: updated ticket for table ", table_with_order.table_id)
	else:
		active_tickets.append({
			"table": table_with_order,
			"orders": table_with_order.table_orders.duplicate(true)
		})
		print("service hatch: ticket placed for table ", table_with_order.table_id)
	
	_update_hatch_ui()

func _get_pending_table() -> Table:
	var cafe_node = owner if owner != null else get_parent()
	
	for child in cafe_node.get_children():
		if child is Table and child.current_state == Table.TableState.WAITING_FOR_FOOD:
				return child
	return

func _update_hatch_ui() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
