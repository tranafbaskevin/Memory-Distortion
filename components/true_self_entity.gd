class_name TrueSelfEntity
extends Area2D

var _player_in_range: bool = false
var _solved: bool = false

func _ready() -> void:
	add_to_group("TrueSelfEntity")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	_solved = Global.unlocked_rooms.get("true_self_integrated", false)
	_update_presence()
	
	# Đồng bộ hiển thị dựa vào Acceptance level
	if DistortionController.has_signal("tier_changed"):
		DistortionController.tier_changed.connect(func(_tier): _update_presence())

func _update_presence() -> void:
	# Chỉ xuất hiện khi Acceptance Level >= 2 và chưa được tích hợp
	var should_be_visible = Global.acceptance_level >= 2 and not _solved
	visible = should_be_visible
	monitoring = should_be_visible
	monitorable = should_be_visible

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not _player_in_range or _solved:
		return
		
	if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_E):
		_integrate_true_self()

func _integrate_true_self() -> void:
	_solved = true
	Global.unlocked_rooms["true_self_integrated"] = true
	Global.truth_acceptance_level = clampi(Global.truth_acceptance_level + 1, 0, 5)
	SaveSystem.save_game()
	
	# Âm thanh chimes giải thoát linh thiêng
	AudioManager.play_sfx_placeholder("true_self_integration_chime")
	
	Narrative.show_message("Tớ đối diện với bản ngã thật sự của mình. Nó mỉm cười nhẹ nhõm: 'Hãy dừng việc chạy trốn lại. Mày là tao, và tao chính là kẻ đã khóa cánh cửa đó để trốn tránh thực tại'.", 6.5)
	
	# Hiệu ứng tan biến bằng một nguồn sáng trắng lóe lên rồi tắt dần
	var light = get_node_or_null("PointLight2D")
	var sprite = get_node_or_null("Sprite2D")
	
	if light and sprite:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(light, "energy", 3.0, 0.4)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
		
		var seq = create_tween()
		seq.tween_interval(0.4)
		seq.tween_property(light, "energy", 0.0, 0.3)
		seq.tween_callback(queue_free)
	else:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_in_range = true
		# Hiển thị prompt gợi ý tương tác
		var prompt = body.find_child("PromptLabel", true, false)
		if prompt:
			prompt.text = "Nhấn E để chạm vào bản ngã"
			prompt.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_in_range = false
		var prompt = body.find_child("PromptLabel", true, false)
		if prompt:
			prompt.hide()
