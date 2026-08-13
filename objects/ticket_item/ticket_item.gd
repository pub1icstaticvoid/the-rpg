extends TextureRect
class_name TicketItem

# format: { "table": Table, "orders": Array[Dictionary] }
var ticket_data: Dictionary = {}

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_parent: Node = null

var target_table_id: int = -1

@onready var header_label: Label = $MarginContainer/VBoxContainer/HeaderLabel
@onready var orders_label: Label = $MarginContainer/VBoxContainer/OrdersLabel

func setup(data: Dictionary) -> void:
	ticket_data = data
	var table_obj = data.get("table", null)
	var table_id = table_obj.table_id if table_obj else "?"
	
	target_table_id = table_id
	
	if header_label:
		header_label.text = "TABLE %s" % str(table_id)
	
	if orders_label:
		var order_text = ""
		for item in data.get("orders", []):
			order_text += "%dx %s\n" % [item["quantity"], item["item_name"]]
			orders_label.text = order_text
	
	_apply_font_scaling()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			grab_focus()
			_start_drag()
		elif not event.pressed and is_dragging:
			_stop_drag()

func _input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouseMotion:
		global_position = get_global_mouse_position() - drag_offset
	
	if is_dragging and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_stop_drag()

func _start_drag() -> void:
	is_dragging = true
	drag_offset = get_global_mouse_position() - global_position
	original_parent = get_parent()
	z_index = 100
	
	var ui_root = get_tree().root.find_child("UI", true, false)
	if ui_root and original_parent != ui_root:
		reparent(ui_root)

func _stop_drag() -> void:
	if not is_dragging:
		return
	is_dragging = false
	z_index = 0
	
	var hatch_ui = get_tree().root.find_child("HatchUI", true, false) as HatchUI
	if hatch_ui and hatch_ui.visible and _is_hovering_rail(hatch_ui):
		hatch_ui.on_ticket_dropped(self)
	else:
		var tray_container = get_tree().root.find_child("TrayContainer", true, false)
		if tray_container:
			reparent(tray_container)
		elif original_parent and is_instance_valid(original_parent):
			reparent(original_parent)
	
	call_deferred("grab_focus")

func _is_hovering_rail(hatch_ui: HatchUI) -> bool:
	var drop_area = hatch_ui.find_child("RailBackground", true, false) as TextureRect
	if drop_area == null:
		drop_area = hatch_ui.find_child("RailTicketContainer", true, false) as HBoxContainer
	
	if drop_area:
		var ticket_rect: Rect2 = get_global_rect()
		var rail_rect: Rect2 = drop_area.get_global_rect()
		return ticket_rect.intersects(rail_rect)
	return false

func _apply_font_scaling() -> void:
	var base_width: float = 140.0
	var current_width: float = custom_minimum_size.x if custom_minimum_size.x > 0 else size.x
	var scale_ratio: float = current_width / base_width
	
	var font_size = int(8 * scale_ratio)
	
	if header_label:
		header_label.add_theme_font_size_override("font_size", clamp(font_size, 8, 24))
	if orders_label:
		orders_label.add_theme_font_size_override("font_size", clamp(font_size, 8, 24))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(_on_mouse_entered)

func _on_mouse_entered() -> void:
	grab_focus()

func _on_focus_entered() -> void:
	if $FocusBorder:
		$FocusBorder.show()

func _on_focus_exited() -> void:
	if $FocusBorder:
		$FocusBorder.hide()
