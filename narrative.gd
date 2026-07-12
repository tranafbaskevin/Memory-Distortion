extends Node

var canvas_layer: CanvasLayer
var panel: PanelContainer
var label: Label
var hide_timer: Timer

func _ready() -> void:
	# Tạo CanvasLayer để vẽ UI đè lên màn hình game
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	
	# Tạo PanelContainer làm nền tối mờ
	panel = PanelContainer.new()
	canvas_layer.add_child(panel)
	
	# Cấu hình Panel nằm ở cạnh dưới, căn giữa màn hình
	panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	# Tạo style nền mờ nhẹ tối giản hợp vibe kinh dị
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7) # Nền tối mờ 70%
	style.set_content_margin_all(12)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	panel.add_theme_stylebox_override("panel", style)
	
	# Tạo Label hiển thị văn bản
	label = Label.new()
	panel.add_child(label)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Thêm viền chữ (outline) màu đen để dễ đọc
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	
	# Ẩn mặc định lúc ban đầu
	panel.hide()
	
	# Khởi tạo Timer tự động ẩn
	hide_timer = Timer.new()
	hide_timer.one_shot = true
	hide_timer.timeout.connect(_on_timeout)
	add_child(hide_timer)

# Hàm toàn cục để hiển thị lời thoại / suy nghĩ của nhân vật
func show_message(text: String, duration: float = 3.0) -> void:
	label.text = text
	panel.show()
	
	# Cập nhật lại vị trí căn giữa x sau khi size panel thay đổi theo độ dài chữ
	await get_tree().process_frame # Chờ 1 frame để Godot tính toán size thực tế của panel
	var viewport_w = get_viewport().get_visible_rect().size.x
	panel.position.x = (viewport_w - panel.size.x) / 2
	panel.position.y = get_viewport().get_visible_rect().size.y - panel.size.y - 40 # Cách mép dưới 40px
	
	hide_timer.start(duration)
	print("[NARRATIVE] ", text)

func show_text(text: String, duration: float = 3.0) -> void:
	show_message(text, duration)

func _on_timeout() -> void:
	panel.hide()
