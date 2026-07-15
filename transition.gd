extends Node

var canvas_layer: CanvasLayer
var color_rect: ColorRect
var _tween: Tween = null

signal fade_out_completed
signal fade_in_completed

func _ready() -> void:
	# CanvasLayer đè lên trên tất cả mọi thứ khác (Vignette layer 10, Narrative layer 1)
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 20
	add_child(canvas_layer)
	
	# ColorRect màu đen phủ toàn màn hình
	color_rect = ColorRect.new()
	canvas_layer.add_child(color_rect)
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.hide()
	print("[Transition] System V2 initialized.")

## Fade màn hình sang đen mượt mà
func fade_to_black(duration: float = 0.5) -> void:
	color_rect.show()
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP # Ngăn chặn input trong lúc fade
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(color_rect, "color", Color(0, 0, 0, 1), duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await _tween.finished
	fade_out_completed.emit()

## Fade từ đen trở lại bình thường
func fade_from_black(duration: float = 0.5) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(color_rect, "color", Color(0, 0, 0, 0), duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await _tween.finished
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.hide()
	fade_in_completed.emit()

## Hàm chuyển scene mượt mà bọc sẵn việc lưu trạng thái
func change_scene(target_scene: String, target_spawn_name: String = "") -> void:
	print("[Transition] Initiating transition to: ", target_scene)
	# Tạm dừng di chuyển của người chơi bằng cách tìm người chơi và vô hiệu hóa vận tốc nếu cần
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("set_physics_process"):
		player.set_physics_process(false)
		
	await fade_to_black(0.6)
	
	# Đặt điểm spawn tiếp theo trong Global
	Global.player_spawn_name = target_spawn_name
	
	# Lưu trạng thái trước khi chuyển cảnh
	SaveSystem.save_game()
	
	# Thay đổi scene
	var err = get_tree().change_scene_to_file(target_scene)
	if err != OK:
		push_error("[Transition] Failed to change scene to: " + target_scene)
	
	# Chờ 1 frame cho scene mới khởi tạo
	await get_tree().process_frame
	
	# Cho phép di chuyển trở lại ở scene mới (nếu có player mới được tạo)
	var new_player = get_tree().get_first_node_in_group("Player")
	if new_player and new_player.has_method("set_physics_process"):
		new_player.set_physics_process(true)
		
	await fade_from_black(0.6)
