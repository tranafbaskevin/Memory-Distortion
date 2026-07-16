extends Node2D

@onready var player = get_node("Player")

func _ready() -> void:
	AudioManager.play_ambient_for_scene("res://scenes/floor1/hallway_f1.tscn")
	
	# Determine player spawn point
	var spawn_name = Global.player_spawn_name
	if spawn_name == "":
		spawn_name = "SpawnStart"
		
	var spawn_node = find_child(spawn_name, true, false)
	if spawn_node and spawn_node is Marker2D:
		player.global_position = spawn_node.global_position
		print("[House] Player spawned at: ", spawn_name, " position: ", spawn_node.global_position)
	else:
		var default_spawn = find_child("SpawnStart", true, false)
		if default_spawn:
			player.global_position = default_spawn.global_position
			print("[House] Spawn point '", spawn_name, "' not found. Used default SpawnStart.")
			
	Global.player_spawn_name = ""
	
	# Connect stair triggers in house scene
	var stair_to_f2 = find_child("StairToFloor2", true, false)
	if stair_to_f2:
		stair_to_f2.body_entered.connect(_on_stair_to_f2_entered)
		
	var stair_to_f1 = find_child("StairToFloor1", true, false)
	if stair_to_f1:
		stair_to_f1.body_entered.connect(_on_stair_to_f1_entered)

func _on_stair_to_f2_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var spawn_f2 = find_child("SpawnFromStairsF1", true, false)
		if spawn_f2:
			Transition.fade_to_black(0.25)
			await get_tree().create_timer(0.3).timeout
			if is_instance_valid(body):
				body.global_position = spawn_f2.global_position
				Transition.fade_from_black(0.25)
				print("[House] Teleported Player to Floor 2")

func _on_stair_to_f1_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var spawn_f1 = find_child("SpawnFromStairsF2", true, false)
		if spawn_f1:
			Transition.fade_to_black(0.25)
			await get_tree().create_timer(0.3).timeout
			if is_instance_valid(body):
				body.global_position = spawn_f1.global_position
				Transition.fade_from_black(0.25)
				print("[House] Teleported Player to Floor 1")
