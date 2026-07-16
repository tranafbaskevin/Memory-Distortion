extends Interactable

var _player_in_range: bool = false
var _player: Node2D = null
var _blind_spot_timer: float = 0.0
var _solved: bool = false

const REQUIRED_TIME: float = 2.5

func _ready() -> void:
	super._ready()
	add_to_group("BlindSpotPuzzle")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	_solved = Global.unlocked_rooms.get("blind_spot_solved", false)
	if _solved:
		dialogue_text = "Hộc tủ tự mở hé ra khi tớ quay lưng đi. Bên trong có mẩu giấy ghi: 'Sự thật không nằm ở nơi mày nhìn chằm chằm. Bố không khóa cửa... chính mày đã tự giam cầm bản thân'."
		prompt_message = "Nhấn E để đọc mảnh giấy trong tủ"
	else:
		dialogue_text = "Chiếc tủ gỗ này bị khóa cứng. Tớ cảm thấy có bóng người đứng ngay sau lưng tớ khi đứng ở đây... Tớ không dám quay đầu lại nhìn."
		prompt_message = "Nhấn E để kiểm tra tủ gỗ"

func _process(delta: float) -> void:
	if _solved or not _player_in_range or not is_instance_valid(_player):
		return
		
	# Hướng từ player đến tủ gỗ
	var dir_to_cabinet = (global_position - _player.global_position).normalized()
	var player_facing = _player.get("facing_direction")
	
	if player_facing is Vector2:
		var dot = player_facing.dot(dir_to_cabinet)
		
		# Player đang quay lưng lại với tủ (dot < -0.3)
		if dot < -0.3:
			_blind_spot_timer += delta
			if _blind_spot_timer >= REQUIRED_TIME:
				_solve_puzzle()
		else:
			# Player quay đầu nhìn thẳng vào tủ -> reset đếm ngược
			_blind_spot_timer = 0.0

func _solve_puzzle() -> void:
	_solved = true
	Global.unlocked_rooms["blind_spot_solved"] = true
	Global.truth_acceptance_level = clampi(Global.truth_acceptance_level + 1, 0, 5)
	SaveSystem.save_game()
	
	# Thay đổi lời nhắc và nội dung hội thoại
	dialogue_text = "Hộc tủ tự mở hé ra khi tớ quay lưng đi. Bên trong có mẩu giấy ghi: 'Sự thật không nằm ở nơi mày nhìn chằm chằm. Bố không khóa cửa... chính mày đã tự giam cầm bản thân'."
	prompt_message = "Nhấn E để đọc mảnh giấy trong tủ"
	
	# Âm thanh mở hộc tủ và nháy đèn pin chập chờn báo hiệu
	AudioManager.play_sfx_placeholder("cabinet_unlock_click")
	
	# Nháy nhẹ đèn pin của player để khẳng định hành vi đúng
	var flashlight = _player.find_child("Flashlight", true, false)
	if flashlight:
		var tween = create_tween()
		tween.tween_property(flashlight, "energy", 0.0, 0.08)
		tween.tween_property(flashlight, "energy", 1.5, 0.05)
		tween.tween_property(flashlight, "energy", 1.2, 0.1)
		
	Narrative.show_message("Một tiếng 'click' khe khẽ vang lên sau lưng. Hộc tủ gỗ tự động trượt ra...", 4.5)
	print("[BlindSpotCabinet] Puzzle solved! Truth Acceptance Level increased.")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_in_range = true
		_player = body
		_blind_spot_timer = 0.0

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_in_range = false
		_player = null
		_blind_spot_timer = 0.0
