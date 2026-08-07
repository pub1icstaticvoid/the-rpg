extends Area2D
class_name ServiceHatch

# Format per ticket: { "table": table_ref, "orders": Array[Dictionary] }
var active_tickets: Array[Dictionary] = []

# Format per plate: { "table": table_ref, "item_name": String }
var ready_dishes: Array[Dictionary] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func on_interact() -> void:
	print("service hatch: opening hatch UI...")
	
	# Try finding by name across the tree
	var hatch_ui = get_tree().root.find_child("HatchUI", true, false)
	
	# Fallback: check CanvasLayer directly if find_child missed it
	if hatch_ui == null:
		var canvas_layer = owner.get_node_or_null("UI")
		if canvas_layer:
			hatch_ui = canvas_layer.get_node_or_null("HatchUI")
	
	if hatch_ui:
		hatch_ui.open_for_hatch(self)
	else:
		print("service hatch error: Could not find HatchUI node! Check node name in CanvasLayer.")

func pin_ticket_to_rail(ticket_data: Dictionary) -> void:
	for i in range(active_tickets.size()):
		if active_tickets[i]["table"] == ticket_data["table"]:
			active_tickets[i]["orders"] = ticket_data["orders"].duplicate(true)
			print("service hatch: updated ticket on rail for table ", ticket_data["table"].table_id)
			return
	active_tickets.append(ticket_data)
	print("service hatch: pinned new ticket to rail for table ", ticket_data["table"].table_id)

func remove_ticket_from_rail(table_ref: Table) -> void:
	for i in range(active_tickets.size() - 1, -1, -1):
		if active_tickets[i]["table"] == table_ref:
			active_tickets.remove_at(i)
			print("service hatch: removed ticket to rail for table ", table_ref.table_id)
			break

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
