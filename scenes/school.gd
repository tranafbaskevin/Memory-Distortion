extends Node2D

@onready var door = get_node("DoorToHallway")
@onready var player = get_node("Player")
@onready var desk = get_node_or_null("Desk")
@onready var desk2 = get_node_or_null("Desk2")

var _is_showing_choices: bool = false
var _puzzle_solved: bool = false

func _ready() -> void:
	var title_label = get_node_or_null("RoomTitleOverlay/TitleLabel")
	if title_label:
		title_label.text = "TRƯỜNG HỌC KÝ ỨC"

	AudioManager.play_ambient_for_scene(scene_file_path)
	
	var board = get_node_or_null("DrawingBoard")
	if board:
		board.interacted.connect(_on_board_interacted)
		
	# Nếu bị loop (distortion_events_count > 0), xáo trộn và biến đổi các cái bàn (Object changes on loop)
	var loops = Global.distortion_events_count
	if loops > 0:
		print("[School] Applying loop object drift for loop depth: ", loops)
		if desk:
			# Co giãn méo mó bàn học
			desk.scale = Vector2(1.8, 0.4)
			desk.position += Vector2(randf_range(-40, 40), randf_range(-40, 40))
		if desk2:
			desk2.rotation = 0.5 * loops
			desk2.position += Vector2(randf_range(-50, 50), randf_range(-50, 50))
			
	_puzzle_solved = Global.unlocked_rooms.get("school_puzzle_solved", false)
	if _puzzle_solved:
		if door:
			door.door_state = "unlocked"
			door.locked_hint = ""

func _on_board_interacted(_player: Node2D) -> void:
	if _puzzle_solved:
		Narrative.show_message("Bức tranh học sinh vẽ cảnh một đứa trẻ trốn khóc trong tủ quần áo khi bố mẹ đập phá đồ đạc ngoài nhà... Trí nhớ của tớ đã khớp đúng.", 4.5)
		return
		
	_is_showing_choices = true
	if player and "speed_multiplier" in player:
		player.speed_multiplier = 0.0
		
	AudioManager.play_sfx_placeholder("drawing_puzzle_active")
	Narrative.show_message("Sắp xếp 3 bức tranh của Kevin thời thơ ấu:\n[1] Bố mẹ cười -> Đi công viên -> Điểm 10 (Hạnh phúc)\n[2] Điểm 10 -> Bố mẹ cãi vã -> Trốn trong góc (Khó chịu)", 8.0)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_showing_choices:
		return
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			_resolve_puzzle(false)
		elif event.keycode == KEY_2:
			_resolve_puzzle(true)

func _resolve_puzzle(accept_truth: bool) -> void:
	_is_showing_choices = false
	_puzzle_solved = true
	
	if player and "speed_multiplier" in player:
		player.speed_multiplier = 1.0
		
	if accept_truth:
		# Sắp xếp đúng sự thật -> disturbing -> acceptance + 1
		Global.truth_acceptance_level = clampi(Global.truth_acceptance_level + 1, 0, 5)
		Global.unlocked_rooms["school_puzzle_solved"] = true
		SaveSystem.save_game()
		
		# Đổi màu tranh vẽ thành màu đỏ sẫm báo hiệu sự thật trần trụi
		var board_sprite = get_node_or_null("DrawingBoard/Sprite2D")
		if board_sprite:
			board_sprite.modulate = Color(0.65, 0.1, 0.1, 1.0)
			
		AudioManager.play_sfx_placeholder("drawing_puzzle_solve")
		
		# Nháy đèn đỏ nhẹ trong lớp học
		var light = get_node_or_null("SchoolLight")
		if light:
			light.color = Color(1.0, 0.2, 0.2)
			if light.has_method("flicker_burst"):
				light.flicker_burst(1.0, 0.5)
				
		Narrative.show_message("Tớ xếp lại tranh. Bức vẽ cuối là cảnh đứa trẻ co rúm trốn khóc trong tủ quần áo khi bố mẹ bạo lực ngoài nhà... Tranh vẽ rợn người nhưng đúng thật. Cửa mở.", 5.5)
		
		if door:
			door.door_state = "unlocked"
			door.locked_hint = ""
	else:
		# Sắp xếp sai (chọn ảo tưởng hạnh phúc) -> denial_level +1, tạo loop làm thay đổi layout bàn học
		Global.denial_level = clampi(Global.denial_level + 1, 0, 5)
		Global.loop_depth += 1
		SaveSystem.save_game()
		
		AudioManager.play_sfx_placeholder("loop_reset_scary")
		Narrative.show_message("Không! Tuổi thơ của tớ rất hạnh phúc! Bức vẽ gia đình đang cười... tớ không muốn nhớ cảnh bạo lực kia! Lớp học rung chuyển...", 4.5)
		
		await get_tree().create_timer(3.5).timeout
		# Loop reset đưa player về đầu lớp học
		Transition.change_scene("res://scenes/school.tscn", "SpawnPoint")
