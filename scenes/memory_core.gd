extends Node2D

@onready var player = get_node("Player")

func _ready() -> void:
	AudioManager.play_ambient_for_scene(scene_file_path)
	
	var core_node = get_node_or_null("CoreInteractable")
	if core_node:
		core_node.interacted.connect(_on_core_interacted)

func _on_core_interacted(_player: Node2D) -> void:
	if player and "speed_multiplier" in player:
		player.speed_multiplier = 0.0
		
	AudioManager.play_sfx_placeholder("core_activated")
	Narrative.show_message("Tớ chạm tay vào Cốt Lõi Ký Ức. Thời gian dường như ngừng trôi. Các mảnh vỡ thực tại đang được lắp ráp lại...", 4.5)
	
	await get_tree().create_timer(4.5).timeout
	
	var acceptance = Global.truth_acceptance_level
	var denial = Global.denial_level
	var loops = Global.loop_depth
	
	print("[MemoryCore] Evaluation state: Acceptance: ", acceptance, " | Denial: ", denial, " | Loops: ", loops)
	
	if acceptance >= 4:
		# Kết thúc Chấp nhận (True Ending)
		Transition.change_scene("res://scenes/true_ending.tscn")
	elif denial >= 3 or loops >= 3:
		# Kết thúc Phủ nhận (Infinite Loop Ending)
		Transition.change_scene("res://scenes/infinite_loop_ending.tscn")
	else:
		# Kết thúc Vụn vỡ (Broken Ending - Q2)
		Transition.change_scene("res://scenes/broken_ending.tscn")
