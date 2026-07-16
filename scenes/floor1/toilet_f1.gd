extends Node2D

func _ready() -> void:
	# Đăng ký phát nhạc nền cho toilet
	AudioManager.play_ambient_for_scene(scene_file_path)
	
	# SYSTEM 3: Memory Bleed (Ký ức phòng ngủ F2 rò rỉ âm thanh xuống Toilet F1)
	if Global.fear_level >= 3:
		await get_tree().create_timer(1.8).timeout
		if is_inside_tree():
			print("[MemoryBleed] Play bedroom echo whisper in toilet due to high fear level")
			# Phát tiếng thì thầm phòng ngủ lạc lõng trong phòng toilet F1
			AudioManager.play_sfx_placeholder("memory_bleed_bedroom_whisper")
