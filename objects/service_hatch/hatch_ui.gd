extends Control
class_name HatchUI

@export var ticket_paper_texture: Texture2D
@export var default_dish_texture: Texture2D

# Using safe node getters instead of strict @onready paths to prevent hidden crashes
@onready var rail_drop_area: TextureRect = $HatchFrame/LayoutMargin/MainVbox/RailSection/RailBackground
@onready var rail_tickets_container: HBoxContainer = $HatchFrame/LayoutMargin/MainVbox/RailSection/RailBackground/RailTicketContainer
@onready var prepared_food_container: HBoxContainer = $HatchFrame/LayoutMargin/MainVbox/ShelfContainer/ShelfBackground/PreparedFoodContainer
@onready var close_button: Button = $HatchFrame/LayoutMargin/MainVbox/CloseButton

var current_hatch: ServiceHatch = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	
	if close_button:
		close_button.pressed.connect(close_hatch_ui)
	
	var ticket_tray = get_tree().root.find_child("TicketTray", true, false)
	if ticket_tray:
		ticket_tray.hide()

func open_for_hatch(hatch_ref: ServiceHatch) -> void:
	current_hatch = hatch_ref
	_refresh_rail_display()
	_refresh_shelf_display()
	
	show()
	_set_player_movement(false)
	
	var ticket_tray = get_tree().root.find_child("TicketTray", true, false)
	if ticket_tray:
		ticket_tray.show()

func close_hatch_ui() -> void:
	_set_player_movement(true)
	hide()
	current_hatch = null
	
	var ticket_tray = get_tree().root.find_child("TicketTray", true, false)
	if ticket_tray:
		ticket_tray.hide()
	
	var tray_container = get_tree().root.find_child("TrayContainer", true, false)
	var ui_root = get_tree().root.find_child("UI", true, false)
	if ui_root and tray_container:
		for child in ui_root.get_children():
			if child is TicketItem:
				child.is_dragging = false
				child.reparent(tray_container)

func on_ticket_dropped(ticket_item: TicketItem) -> void:
	if current_hatch == null:
		return
	
	current_hatch.pin_ticket_to_rail(ticket_item.ticket_data)
	ticket_item.queue_free()
	_refresh_rail_display()

func _set_player_movement(enabled: bool) -> void:
	var player = get_tree().root.find_child("Player", true, false)
	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(enabled)

func _refresh_rail_display() -> void:
	for child in rail_tickets_container.get_children():
		child.queue_free()
	
	if current_hatch == null:
		return
	
	for ticket in current_hatch.active_tickets:
		var ticket_rect = TextureRect.new()
		if ticket_paper_texture:
			ticket_rect.texture = ticket_paper_texture
		
		ticket_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ticket_rect.custom_minimum_size = Vector2(64, 80)
		
		var table_id = ticket["table"].table_id if ticket["table"] else "?"
		var label = Label.new()
		label.text = "T-%s" % str(table_id)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(PRESET_FULL_RECT)
		
		ticket_rect.add_child(label)
		rail_tickets_container.add_child(ticket_rect)

func _refresh_shelf_display() -> void:
	for child in prepared_food_container.get_children():
		child.queue_free()
	
	if current_hatch == null:
		return
		
	for dish in current_hatch.ready_dishes:
		var dish_rect = TextureRect.new()
		if default_dish_texture:
			dish_rect.texture = default_dish_texture
		
		dish_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		dish_rect.custom_minimum_size = Vector2(48, 48)
		
		prepared_food_container.add_child(dish_rect)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("ui_cancel"):
		close_hatch_ui()
		get_viewport().set_input_as_handled()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
