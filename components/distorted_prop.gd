extends Sprite2D

@export var prop_id: String = ""

var _base_scale: Vector2 = Vector2(1.0, 1.0)
var _base_rotation: float = 0.0

func _ready() -> void:
	_base_scale = scale
	_base_rotation = rotation
	add_to_group("DistortedProp")
	_apply_distortion()
	
	# Lắng nghe sự thay đổi của tier / fear_level
	if DistortionController.has_signal("tier_changed"):
		DistortionController.tier_changed.connect(_on_tier_changed)

func _process(_delta: float) -> void:
	# Nếu Fear Level >= 2, prop co giãn nhẹ nhàng một cách kỳ lạ (như đang thở)
	# Điều này tạo ra sự khó chịu thị giác khi người chơi quan sát kỹ
	var fear = Global.fear_level
	if fear >= 2:
		var time = Time.get_ticks_msec() / 1000.0
		var wobble = sin(time * 1.5) * (float(fear) * 0.012)
		scale.x = _base_scale.x * (1.0 - fear * 0.03 + wobble)
		scale.y = _base_scale.y * (1.0 + fear * 0.02 - wobble * 0.5)

func _on_tier_changed(_new_tier: int) -> void:
	_apply_distortion()

func _apply_distortion() -> void:
	var fear = Global.fear_level
	
	# Góc xoay bị lệch nhẹ theo nỗi sợ (khiến đồ vật trông như bị đặt xéo)
	rotation = _base_rotation + (fear * 0.025)
	
	# Hao mòn màu sắc (hao mòn ký ức): Đồ vật xỉn màu, chuyển sang ám tối/bẩn
	var color_darkness = clampf(1.0 - fear * 0.12, 0.45, 1.0)
	modulate = Color(color_darkness, color_darkness * 0.92, color_darkness * 0.88, 1.0)
	
	print("[DistortedProp] Prop: ", name, " | Fear: ", fear, " | Rot: ", rotation, " | Color darkness: ", color_darkness)
