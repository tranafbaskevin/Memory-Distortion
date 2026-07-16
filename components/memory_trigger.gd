class_name MemoryTrigger
extends BaseTrigger

# Định nghĩa 2 loại trigger theo yêu cầu thiết kế
@export_enum("type_a_story", "type_b_ambient") var trigger_type: String = "type_a_story"
@export var trigger_id: String = "" # ID duy nhất dùng để lưu trạng thái Type A

# Tham số immersion loop
@export var trigger_chance: float = 1.0     # Tỷ lệ kích hoạt (đặc biệt cho Type B)
@export var random_delay_min: float = 0.0
@export var random_delay_max: float = 0.5
@export var trigger_cooldown: float = 15.0  # Cooldown giữa các lần kích hoạt cho Type B

# Tương tác feedback
@export var narrative_text: String = ""
@export_enum("whisper", "echo", "creak", "none") var feedback_sound: String = "whisper"

# Các mức độ tác động lên chỉ số
@export var fear_increase: int = 1
@export var truth_increase: int = 0         # Type A có thể làm tăng mức độ chấp nhận sự thật

# Mức độ làm chậm người chơi (30% làm chậm = 0.7 speed_multiplier)
@export var player_slow_factor: float = 0.7
@export var slow_duration: float = 1.5

# Hiệu ứng vignette
@export var vignette_intensity: float = 0.65
@export var vignette_duration: float = 1.5

func _custom_ready() -> void:
	add_to_group("MemoryTrigger")
	# Mặc định MemoryTrigger yêu cầu nhấn E
	require_interaction = true
	
	# Nếu là Type A và đã được kích hoạt từ trước (khôi phục từ save)
	if trigger_type == "type_a_story" and trigger_id != "":
		if Global.unlocked_rooms.get("trigger_" + trigger_id, false):
			has_triggered = true
			# Vô hiệu hoá va chạm
			set_deferred("monitoring", false)

func _on_trigger_fired(player: Node2D) -> void:
	if not is_instance_valid(player):
		return
		
	_run_immersion_loop(player)

func _run_immersion_loop(player: Node2D) -> void:
	_on_cooldown = true
	if trigger_type == "type_a_story":
		has_triggered = true
		if trigger_id != "":
			Global.unlocked_rooms["trigger_" + trigger_id] = true
			SaveSystem.save_game()
	
	# 1. Random delay trước khi xảy ra
	var delay = randf_range(random_delay_min, random_delay_max)
	if delay > 0:
		await get_tree().create_timer(delay).timeout
		
	if not is_instance_valid(player):
		_on_cooldown = false
		return
		
	print("[MemoryTrigger] Fired: ", trigger_id if trigger_id != "" else name, " (Type: ", trigger_type, ")")
	
	# 2. Làm chậm người chơi 30% (multiplier = 0.7)
	if "speed_multiplier" in player:
		player.speed_multiplier = player_slow_factor
		
	# 3. Hiệu ứng visual distortion (Vignette tăng cường độ dựa vào Fear Level hiện tại)
	var scaled_vignette = clampf(vignette_intensity + (Global.fear_level * 0.05), 0.3, 0.95)
	Vignette.show_vignette(scaled_vignette, 0.3)
	
	# 4. Hiệu ứng camera shake nhẹ tạo cảm giác chóng mặt
	var camera = player.find_child("Camera2D", true, false)
	if camera and camera.has_method("shake"):
		camera.shake(1.5 + Global.fear_level * 0.5, slow_duration, 15.0)
		
	# 5. Play audio feedback
	_play_feedback_sound()
	
	# 6. Hiển thị narrative text
	if narrative_text != "":
		Narrative.show_message(narrative_text, slow_duration + 1.0)
		
	# 7. Tăng Fear Level & Truth Acceptance Level (nếu có)
	if trigger_type == "type_a_story" and has_triggered:
		if fear_increase > 0:
			Global.fear_level = clampi(Global.fear_level + fear_increase, 0, 5)
			print("[MemoryTrigger] Fear Level increased to: ", Global.fear_level)
		if truth_increase > 0:
			Global.truth_acceptance_level = clampi(Global.truth_acceptance_level + truth_increase, 0, 5)
			print("[MemoryTrigger] Truth Acceptance Level increased to: ", Global.truth_acceptance_level)
			
	# Chờ hết thời gian làm chậm để hồi phục tốc độ
	await get_tree().create_timer(slow_duration).timeout
	
	if is_instance_valid(player) and "speed_multiplier" in player:
		player.speed_multiplier = 1.0
		
	# Khôi phục Vignette
	Vignette.hide_vignette(vignette_duration)
	
	# Chờ cooldown cho lần trigger tiếp theo (Type B)
	if repeatable or trigger_type == "type_b_ambient":
		await get_tree().create_timer(trigger_cooldown).timeout
	_on_cooldown = false

func _play_feedback_sound() -> void:
	match feedback_sound:
		"whisper":
			AudioManager.play_sfx_placeholder("memory_whisper")
		"echo":
			AudioManager.play_sfx_placeholder("memory_echo")
		"creak":
			AudioManager.play_sfx_placeholder("wood_creak_eerie")
