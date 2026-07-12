extends Camera2D

@export var default_zoom: Vector2 = Vector2(1.0, 1.0)
@export var zoom_speed: float = 0.5

func _ready() -> void:
	zoom = default_zoom
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0

## Zoom mượt mà đến giá trị mục tiêu (dùng cho rooms, distortion, v.v.)
func smooth_zoom(target_zoom: Vector2, duration: float = zoom_speed) -> void:
	var tween = create_tween()
	tween.tween_property(self, "zoom", target_zoom, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

## Camera rung nhẹ — tạo cảm giác bất an tâm lý, KHÔNG phải jumpscare
## strength: cường độ rung (pixel). duration: thời gian rung (giây). frequency: tần suất rung / giây
func shake(strength: float = 4.0, duration: float = 0.5, frequency: float = 20.0) -> void:
	var original_offset = offset
	var elapsed := 0.0
	var interval := 1.0 / frequency
	
	while elapsed < duration:
		# Dịch chuyển offset ngẫu nhiên theo hình tròn nhỏ
		var angle = randf() * TAU
		var dist = randf_range(strength * 0.5, strength)
		offset = original_offset + Vector2(cos(angle), sin(angle)) * dist
		
		await get_tree().create_timer(interval).timeout
		elapsed += interval
	
	# Trả offset về vị trí gốc khi xong
	offset = original_offset

## Camera drift từ từ sang một hướng rồi tự trở về — tạo cảm giác không gian "lệch"
## Dùng cho hiệu ứng "hành lang dài hơn tớ nhớ" 
func drift(direction: Vector2 = Vector2(20, 0), duration: float = 4.0) -> void:
	var tween = create_tween()
	tween.set_loops(0)
	tween.tween_property(self, "offset", direction, duration / 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "offset", Vector2.ZERO, duration / 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
