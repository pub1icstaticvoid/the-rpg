extends Control
class_name OrderPad

signal order_submitted(submitted_data: Array[Dictionary])
signal order_cancelled

@onready var header_label: Label = $PaperPad/MarginContainer/VBoxContainer/HeaderLabel
@onready var menu_list: VBoxContainer = $PaperPad/MarginContainer/VBoxContainer/MenuList

var target_table: Table = null
var player_selections: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	_setup_menu_rows()

func _setup_menu_rows() -> void:
	var rows: Array[Node] = []
	
	for child in menu_list.get_children():
		if child.name.begins_with("ItemRow_"):
			rows.append(child)
	
	var submit_button = $PaperPad/MarginContainer/VBoxContainer/SubmitButton
	if submit_button:
		submit_button.focus_mode = Control.FOCUS_ALL
	
	for i in range(rows.size()):
		var row = rows[i]
		var item_name = row.name.replace("ItemRow_", "").replace("_", " ")
		player_selections[item_name] = {"checked": false, "qty": 0}
		
		var checkbox: CheckBox = row.get_node("CheckBox")
		var minus_btn: Button = row.get_node("QtyMinus")
		var plus_btn: Button = row.get_node("QtyPlus")
		
		checkbox.focus_mode = Control.FOCUS_ALL
		minus_btn.focus_mode = Control.FOCUS_ALL
		plus_btn.focus_mode = Control.FOCUS_ALL
		
		checkbox.focus_neighbor_right = minus_btn.get_path()
		minus_btn.focus_neighbor_left = checkbox.get_path()
		minus_btn.focus_neighbor_right = plus_btn.get_path()
		plus_btn.focus_neighbor_left = minus_btn.get_path()
		
		if i > 0:
			var prev_row = rows[i - 1]
			checkbox.focus_neighbor_top = prev_row.get_node("CheckBox").get_path()
			minus_btn.focus_neighbor_top = prev_row.get_node("QtyMinus").get_path()
			plus_btn.focus_neighbor_top = prev_row.get_node("QtyPlus").get_path()
		if i < rows.size() - 1:
			var next_row = rows[i + 1]
			checkbox.focus_neighbor_bottom = next_row.get_node("CheckBox").get_path()
			minus_btn.focus_neighbor_bottom = next_row.get_node("QtyMinus").get_path()
			plus_btn.focus_neighbor_bottom = next_row.get_node("QtyPlus").get_path()
		else:
			if submit_button:
				checkbox.focus_neighbor_bottom = submit_button.get_path()
				minus_btn.focus_neighbor_bottom = submit_button.get_path()
				plus_btn.focus_neighbor_bottom = submit_button.get_path()
				submit_button.focus_neighbor_top = checkbox.get_path()
		
		checkbox.toggled.connect(func(is_pressed): _on_checkbox_toggled(item_name, is_pressed))
		minus_btn.pressed.connect(func(): _adjust_quantity(item_name, -1))
		plus_btn.pressed.connect(func(): _adjust_quantity(item_name, 1))

func open_for_table(table: Table) -> void:
	target_table = table
	header_label.text = "TABLE %d" % table.table_id
	
	for item in player_selections:
		player_selections[item]["checked"] = false
		player_selections[item]["qty"] = 0
	
	_update_ui_display()
	show()
	
	_set_player_movement(false)
	
	_focus_first_element()

func _set_player_movement(enabled: bool) -> void:
	var player = get_tree().root.find_child("Player", true, false)
	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(enabled)

func _focus_first_element() -> void:
	for row in menu_list.get_children():
		if row.name.begins_with("ItemRow_") and row.has_node("CheckBox"):
			row.get_node("CheckBox").grab_focus()
			break

func _close_pad() -> void:
	_set_player_movement(true)
	hide()

func _update_ui_display() -> void:
	for row in menu_list.get_children():
		var item_name = row.name.replace("ItemRow_", "").replace("_", " ")
		if player_selections.has(item_name):
			var data = player_selections[item_name]
			row.get_node("CheckBox").set_pressed_no_signal(data["checked"])
			row.get_node("QtyLabel").text = str(data["qty"])

func _on_checkbox_toggled(item_name: String, is_pressed: bool):
	player_selections[item_name]["checked"] = is_pressed
	if is_pressed and player_selections[item_name]["qty"] == 0:
		player_selections[item_name]["qty"] = 1
	elif not is_pressed:
		player_selections[item_name]["qty"] = 0
	_update_ui_display()

func _adjust_quantity(item_name: String, amount: int) -> void:
	var current_qty = player_selections[item_name]["qty"]
	var new_qty = max(0, current_qty + amount)
	
	player_selections[item_name]["qty"] = new_qty
	player_selections[item_name]["checked"] = new_qty > 0
	_update_ui_display()

func _on_submit_button_pressed() -> void:
	if not target_table:
		return
	
	var submitted_order: Array[Dictionary] = []
	
	for item_name in player_selections:
		if player_selections[item_name]["checked"] and player_selections[item_name]["qty"] > 0:
			submitted_order.append({
				"item_name": item_name,
				"quantity": player_selections[item_name]["qty"]
			})
	
	if submitted_order.is_empty():
		print("order pad submitted with 0 items, cancelling order")
		_cancel_order()
	else:
		order_submitted.emit(submitted_order)
		_close_pad()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_cancel_order()

func _cancel_order() -> void:
	print("order pad closed without submitting")
	order_submitted.emit([])
	order_cancelled.emit()
	_close_pad()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
