extends Sprite2D

@export var prop_id: String = ""
@export var can_vanish: bool = true # Cho phép ẩn đi ngẫu nhiên dựa trên fear level (các prop trang trí)

var _base_scale: Vector2 = Vector2(1.0, 1.0)
var _base_rotation: float = 0.0

func _ready() -> void:
	_base_scale = scale
	_base_rotation = rotation
	add_to_group("DistortedProp")
	
	# SYSTEM 1: Room State Drift (lệch nhẹ vị trí và góc xoay ban đầu khi load scene)
	var fear = Global.fear_level + Global.loop_depth
	if fear > 0:
		# Độ lệch vị trí tối đa 18px tương ứng với fear level 5
		var drift_x = randf_range(-18.0, 18.0) * (float(fear) / 5.0)
		var drift_y = randf_range(-18.0, 18.0) * (float(fear) / 5.0)
		position += Vector2(drift_x, drift_y)
		
		# Lệch nhẹ góc xoay ngẫu nhiên
		_base_rotation += randf_range(-0.06, 0.06) * (float(fear) / 5.0)
		
		# Tỷ lệ biến mất ngẫu nhiên của các prop trang trí (tối đa 30% ở Fear Level 5)
		if can_vanish and randf() < 0.06 * fear:
			hide()
			print("[RoomStateDrift] Prop vanished: ", name)
			
	# SYSTEM 4: Micro Distortion Loop (dịch chuyển cửa nhẹ khi người chơi bị loop)
	var loops = Global.distortion_events_count
	if loops > 0:
		var parent = get_parent()
		# Nếu là cửa, dịch chuyển ngang nhẹ (35px mỗi vòng lặp) tạo cảm giác sai vị trí
		if parent and (parent.name.contains("Door") or parent.name.contains("Exit")):
			parent.position.x += 35.0 * clampf(float(loops), 0.0, 3.0)
			print("[MicroLoop] Shifted door: ", parent.name, " to X: ", parent.position.x)
	
	_apply_distortion()
	
	# Lắng nghe sự thay đổi của tier / fear_level
	if DistortionController.has_signal("tier_changed"):
		DistortionController.tier_changed.connect(_on_tier_changed)

func _process(_delta: float) -> void:
	# Nếu Fear + Loop >= 2, prop co giãn nhẹ nhàng một cách kỳ lạ (như đang thở)
	var fear = Global.fear_level + Global.loop_depth
	if fear >= 2 and visible:
		var time = Time.get_ticks_msec() / 1000.0
		var wobble = sin(time * 1.5) * (float(fear) * 0.012)
		scale.x = _base_scale.x * (1.0 - fear * 0.03 + wobble)
		scale.y = _base_scale.y * (1.0 + fear * 0.02 - wobble * 0.5)

func _on_tier_changed(_new_tier: int) -> void:
	_apply_distortion()

func _apply_distortion() -> void:
	var fear = Global.fear_level + Global.loop_depth
	
	# Góc xoay bị lệch nhẹ theo nỗi sợ và số lần loop
	rotation = _base_rotation + (fear * 0.025)
	
	# Hao mòn màu sắc (đen tối dần)
	var color_darkness = clampf(1.0 - fear * 0.12, 0.4, 1.0)
	modulate = Color(color_darkness, color_darkness * 0.92, color_darkness * 0.88, 1.0)
	
	print("[DistortedProp] Prop: ", name, " | Scaled Fear: ", fear, " | Rot: ", rotation, " | Color: ", color_darkness)


