## MicroCueTrigger — Sự kiện micro-unease ở phút 1:30
## Giải quyết Testarossa Drop #1:
## Khoảng trống sau unease cue không được "nguội" — cần texture âm thanh liên tục
## Cue này: đèn toilet nhấp nháy 1 lần khi player đi ngang → không có giải thích
## Đủ để gây "có gì đó lạ" mà không dạy player "distortion tồn tại"
extends Area2D

var _has_triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	if _has_triggered:
		return
	
	# Chỉ kích hoạt nếu đã qua 60 giây (player có thời gian học không gian)
	# Và Controller đang ở Tier 0→1 (chưa có distortion chính thức)
	if DistortionController.get_elapsed_minutes() < 1.0:
		return
	
	_has_triggered = true
	_trigger_micro_cue()

func _trigger_micro_cue() -> void:
	# Tìm đèn toilet gần nhất
	var toilet_light = get_node_or_null("../ToiletDoorLight")
	
	# Nhấp nháy 1 lần duy nhất — không lặp lại
	if toilet_light:
		toilet_light.energy = 0.0
		await get_tree().create_timer(0.08).timeout
		toilet_light.energy = 1.0
		await get_tree().create_timer(0.06).timeout
		toilet_light.energy = 0.2
		await get_tree().create_timer(0.12).timeout
		toilet_light.energy = 1.0
	
	# Âm thanh mờ — rất nhẹ, không rõ nguồn gốc
	AudioManager.play_sfx_placeholder("light_buzz_brief")
	
	# KHÔNG có lời thoại. Không có giải thích.
	# Sự im lặng sau đó là phần quan trọng nhất.
	print("[MicroCueTrigger] Micro-cue fired at ", "%.1f" % DistortionController.get_elapsed_minutes(), " min")
