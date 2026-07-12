## FakeDoorTransition — Cửa giả, dẫn player quay lại cùng phòng hiện tại
## Tạo ảo giác vòng lặp: mở cửa → tưởng đi nơi khác → nhưng lại ở đây
## Chỉ kích hoạt khi bedroom_distorted = true
extends "res://environment/door.gd"

## Nếu false, cửa hoạt động bình thường. Nếu true, cửa quay vòng.
@export var loop_when_distorted: bool = true

func _ready() -> void:
	super._ready()

func _interact(player: Node2D) -> void:
	if loop_when_distorted and Global.bedroom_distorted:
		# Chuyển về CÙNG scene hiện tại — vòng lặp
		var current_scene_path = get_tree().current_scene.scene_file_path
		Global.player_spawn_name = "SpawnPoint"
		Global.distortion_events_count += 1
		
		# Lời thoại tuỳ theo số lần bị vòng lặp
		var loop_messages = [
			"Ủa... tớ vừa ra khỏi phòng rồi mà sao lại ở đây?",
			"Lại rồi... cái phòng này... tại sao tớ không thoát được?",
			"Có chuyện gì đó không ổn với ngôi nhà này."
		]
		var idx = mini(Global.distortion_events_count - 1, loop_messages.size() - 1)
		Narrative.show_message(loop_messages[idx], 4.0)
		
		AudioManager.play_sfx_placeholder("distortion_sting")
		Vignette.show_vignette(0.5, 0.5)
		
		await get_tree().create_timer(0.4).timeout
		get_tree().change_scene_to_file(current_scene_path)
	else:
		# Hoạt động bình thường
		AudioManager.play_door_open()
		super._interact(player)
