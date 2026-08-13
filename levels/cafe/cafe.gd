extends Node2D

var player_scene: PackedScene = preload("res://entities/player/player.tscn")

func spawn_player() -> void:
	var player_instance = player_scene.instantiate()
	player_instance.position = Vector2(200, 150)
	add_child(player_instance)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_player()
