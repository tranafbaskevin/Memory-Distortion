extends Interactable

@export var puzzle_id: String = "mirror_puzzle"

func _ready() -> void:
	super._ready()
	prompt_message = "Nhấn E để nhìn vào gương"

func _interact(player: Node2D) -> void:
	# Kiểm tra xem người chơi có đang đối diện với gương không (gương nằm ở tường trên, nên player phải nhìn LÊN)
	# Hướng Vector2.UP tương ứng với y = -1
	var facing = player.get("facing_direction")
	var is_facing_mirror = false
	if facing is Vector2:
		# Gương ở trên tường, do đó người chơi phải nhìn lên phía trên (y âm)
		is_facing_mirror = facing.y < -0.5
		
	if is_facing_mirror:
		# Giải được puzzle
		AudioManager.play_sfx_placeholder("mirror_reveal")
		
		var already_solved = Global.unlocked_rooms.get("mirror_puzzle_solved", false)
		if not already_solved:
			Global.unlocked_rooms["mirror_puzzle_solved"] = true
			Global.truth_acceptance_level = clampi(Global.truth_acceptance_level + 1, 0, 5)
			SaveSystem.save_game()
			
		Narrative.show_message("Ánh đèn pin phản chiếu qua lớp kính mờ, làm lộ ra một dòng chữ viết ngược cào lên tường gỗ đối diện: 'BỐ KHÔNG KHÓA CỬA... LÀ CHÍNH MÀY'.", 5.0)
		
		# Nháy nhẹ đèn pin của player để tạo hiệu ứng chập chờn
		var flashlight = player.find_child("Flashlight", true, false)
		if flashlight:
			var tween = create_tween()
			tween.tween_property(flashlight, "energy", 0.0, 0.08)
			tween.tween_property(flashlight, "energy", 1.5, 0.05)
			tween.tween_property(flashlight, "energy", 0.2, 0.1)
			tween.tween_property(flashlight, "energy", 1.2, 0.15)
	else:
		# Chưa chiếu đúng hướng
		Narrative.show_message("Tấm gương bị mờ bởi bụi bẩn và hơi ẩm lạnh lẽo. Tớ cần chiếu đèn pin thẳng vào gương mới thấy được...", 4.0)
