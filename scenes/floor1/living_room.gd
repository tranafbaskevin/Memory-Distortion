## Living Room — TV static khi revisit, environmental storytelling
extends Node2D

@onready var tv = $TV
@onready var player = $Player

func _ready() -> void:
	var title_label = get_node_or_null("RoomTitleOverlay/TitleLabel")
	if title_label:
		title_label.text = "PHÒNG KHÁCH"

	AudioManager.play_ambient_for_scene(scene_file_path, Global.bedroom_distorted)
	
	if not Global.room_visits.has("living_room"):
		Global.room_visits["living_room"] = 0
	Global.room_visits["living_room"] += 1
	
	var visit = Global.room_visits["living_room"]
	
	if visit == 1:
		Narrative.show_message("Phòng khách. Tivi tắt. Ghế sofa trông như chưa ai ngồi cả năm nay.", 4.0)
	elif visit >= 2:
		# TV bật lên với màn hình nhiễu
		if tv:
			tv.modulate = Color(1, 0.3, 0.3, 1) # Tivi phát ánh đỏ
		Narrative.show_message("Tivi... tự bật lên? Tiếng nhiễu trắng trải dài trong tai.", 4.5)
		AudioManager.play_sfx_placeholder("tv_static")
		
		if visit >= 3:
			await get_tree().create_timer(2.0).timeout
			# Vignette nhẹ + shift camera
			Vignette.show_vignette(0.2, 2.0)
			var camera = player.find_child("Camera2D", true, false)
			if camera:
				camera.shake(2.0, 0.3, 18.0)
			Narrative.show_message("Trên màn hình... hình như có ai đó đang nhìn lại tớ.", 5.0)
			await get_tree().create_timer(6.0).timeout
			Vignette.hide_vignette(3.0)
