extends Node2D

@export var customer_scene: PackedScene = preload("res://entities/customers/customer.tscn")
@export var tables: Array[Table] = []

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_T:
			spawn_party(randi_range(1, 4))

func spawn_party(party_size: int) -> void:
	var target_table: Table = null
	for table in tables:
		if table.can_fit_party(party_size):
			target_table = table
			break

	if target_table == null:
		print("no open tables for party of ", party_size)
		return
	
	print("spawning party of ", party_size, " heading to table ", target_table.table_id)
	
	var party: Array[Customer] = []
	for i in range(party_size):
		var customer = customer_scene.instantiate() as Customer
		customer.global_position = global_position + Vector2(i * 12 - (party_size * 6), 0)
		get_parent().add_child(customer)
		party.append(customer)
	
	target_table.assign_party(party)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if tables.is_empty():
		var found_tables = get_parent().find_children("*", "Table", true, false)
		for node in found_tables:
			if node is Table:
				tables.append(node)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
