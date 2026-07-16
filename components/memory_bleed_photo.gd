extends Interactable

@onready var sprite = get_node_or_null("Sprite2D")

func _ready() -> void:
	super._ready()
	add_to_group("MemoryBleed")
	prompt_message = "Nhấn E để xem ảnh gia đình..."
	_check_visibility()
	
	# Đồng bộ visibility khi fear level thay đổi
	if DistortionController.has_signal("tier_changed"):
		DistortionController.tier_changed.connect(_on_tier_changed)

func _on_tier_changed(_tier: int) -> void:
	_check_visibility()

func _check_visibility() -> void:
	var active = Global.fear_level >= 3
	visible = active
	is_active = active
	
	if active and sprite:
		# Bức ảnh bị nhuốm màu đỏ máu kỳ quái khi xuất hiện sai bối cảnh
		sprite.modulate = Color(0.7, 0.2, 0.2, 1.0)
		
		# Nháy nhẹ đèn phòng vệ sinh khi ký ức bắt đầu rò rỉ sang
		var light = get_node_or_null("../ToiletLight")
		if light and light.has_method("flicker_burst"):
			light.flicker_burst(0.8, 0.45)

func _interact(player: Node2D) -> void:
	# Lời thoại kỳ dị phản ánh sự mất ổn định của trí nhớ
	Narrative.show_message("Bức ảnh gia đình năm tớ 10 tuổi... Tại sao nó lại nằm ở đây? Khuôn mặt của bố mẹ đã bị cào rách, trống rỗng...", 5.0)
	AudioManager.play_sfx_placeholder("memory_bleed_whisper")
	
	# Rung nhẹ camera
	var camera = player.find_child("Camera2D", true, false)
	if camera and camera.has_method("shake"):
		camera.shake(1.5, 0.4, 20.0)
