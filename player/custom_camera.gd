extends Camera2D

@export var default_zoom: Vector2 = Vector2(1.0, 1.0)
@export var zoom_speed: float = 0.5 # Thời gian di chuyển zoom (giây)

func _ready() -> void:
	zoom = default_zoom
	# Bật các tính năng follow mượt mặc định của Camera2D trong Godot 4
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0

# Hàm hỗ trợ zoom mượt mà, sẵn sàng tích hợp cho các room-based zoom sau này
func smooth_zoom(target_zoom: Vector2, duration: float = zoom_speed) -> void:
	var tween = create_tween()
	# Dùng tween để nội suy giá trị zoom qua hàm Trans/Ease thích hợp cho RPG
	tween.tween_property(self, "zoom", target_zoom, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	print("Camera zooming to: ", target_zoom)
