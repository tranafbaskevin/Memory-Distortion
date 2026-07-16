extends Node2D

@onready var door = get_node("DoorToHallway")
@onready var player = get_node("Player")
@onready var photo = get_node("FamilyPhotoInteractable")
@onready var left_wall = get_node_or_null("LeftWall")
@onready var right_wall = get_node_or_null("RightWall")

# Vị trí đứng chính xác: Vector2(550, 320)
const TARGET_SPOT: Vector2 = Vector2(550.0, 320.0)
const POSITION_TOLERANCE: float = 50.0 # Bán kính sai số cho phép

var _puzzle_solved: bool = false
var _layout_shrunk_count: int = 0

func _ready() -> void:
	AudioManager.play_ambient_for_scene(scene_file_path)
	
	if photo:
		photo.interacted.connect(_on_photo_interacted)
		
	# Nếu giải xong từ trước (trong dữ liệu load game)
	_puzzle_solved = Global.unlocked_rooms.get("crime_scene_solved", false)
	if _puzzle_solved:
		if door:
			door.door_state = "unlocked"
			door.locked_hint = ""
			
	# Gợi ý vị trí đứng bằng một quầng sáng đỏ/xanh mờ ảo dưới sàn (Q1)
	var floor_glow = get_node_or_null("FloorGlow")
	if floor_glow:
		floor_glow.modulate = Color(0.8, 0.2, 0.2, 0.15) # Ánh sáng đỏ rất yếu gợi ý

func _on_photo_interacted(player_node: Node2D) -> void:
	if _puzzle_solved:
		Narrative.show_message("Bức ảnh gia đình hoen ố máu... Nơi mọi ký ức sụp đổ và mở ra sự chấp nhận.", 4.0)
		return
		
	# Kiểm tra tọa độ của player
	var player_pos = player_node.global_position
	var distance = player_pos.distance_to(TARGET_SPOT)
	
	# Kiểm tra hướng nhìn của player (facing_direction.y < -0.7 tức là đang nhìn lên phía trên)
	var player_facing = player_node.get("facing_direction")
	var correct_facing = false
	if player_facing is Vector2:
		if player_facing.y < -0.7:
			correct_facing = true
			
	if distance <= POSITION_TOLERANCE and correct_facing:
		# Tái hiện hành vi Kevin thành công!
		_solve_puzzle()
	else:
		# Sai vị trí hoặc sai hướng -> Co hẹp bức tường, phá hủy layout (Dread & Layout collapse)
		_trigger_layout_collapse()

func _solve_puzzle() -> void:
	_puzzle_solved = true
	Global.unlocked_rooms["crime_scene_solved"] = true
	Global.truth_acceptance_level = clampi(Global.truth_acceptance_level + 2, 0, 5) # acceptance_level +2
	SaveSystem.save_game()
	
	AudioManager.play_sfx_placeholder("crime_scene_solve_shatter")
	
	# Lóe sáng trắng và mở cửa
	var light = get_node_or_null("CrimeLight")
	if light:
		light.color = Color(1.0, 1.0, 1.0)
		light.energy = 2.5
		var tween = create_tween()
		tween.tween_property(light, "energy", 0.8, 1.0)
		
	Narrative.show_message("Tớ đứng đúng chỗ này... Nhìn thẳng lên bức ảnh gia đình... Tớ đã giằng co với bố để bảo vệ mẹ và chính mình. Tớ chấp nhận tội lỗi đau đớn này. Cổng Memory Core mở ra.", 6.5)
	
	if door:
		door.door_state = "unlocked"
		door.locked_hint = ""

func _trigger_layout_collapse() -> void:
	_layout_shrunk_count += 1
	Global.loop_depth += 1
	SaveSystem.save_game()
	
	AudioManager.play_sfx_placeholder("layout_shrink_heavy")
	Narrative.show_message("Sai rồi... Không phải hướng này... Tớ cảm giác những bức tường đang tịnh tiến bóp nghẹt tớ!", 4.0)
	
	# Rung lắc camera cực mạnh
	if player and player.has_method("shake_camera"):
		player.shake_camera(2.0, 0.5, 30.0)
	elif player:
		var cam = player.find_child("Camera2D", true, false)
		if cam and cam.has_method("shake"):
			cam.shake(2.0, 0.5, 30.0)
			
	# Co hẹp hai bức tường hai bên (phá hủy layout phòng)
	if left_wall and right_wall:
		var shift_amount = 60.0
		var tween = create_tween().set_parallel(true)
		tween.tween_property(left_wall, "position:x", left_wall.position.x + shift_amount, 0.8)
		tween.tween_property(right_wall, "position:x", right_wall.position.x - shift_amount, 0.8)
		
	# Nếu lặp lại sai 3 lần, reset toàn bộ phòng để tránh người chơi bị kẹt chết trong tường
	if _layout_shrunk_count >= 3:
		await get_tree().create_timer(2.0).timeout
		Transition.change_scene("res://scenes/crime_scene.tscn", "SpawnPoint")
