class_name ShadowEntity
extends Node2D

@export var guaranteed_spawn: bool = false
@export var min_fear_level: int = 1         # Chỉ spawn nếu Fear Level >= giá trị này
@export var fade_duration: float = 0.3      # Tốc độ biến mất khi bị nhìn trực diện
@export var detection_angle: float = 0.7    # Dot product threshold (0.7 ~ 90 độ Field of View)
@export var max_view_distance: float = 650.0 # Khoảng cách tối đa mà thực thể tồn tại

var _player: Node2D = null
var _is_fading: bool = false

func _ready() -> void:
	# Tính tỷ lệ spawn dựa trên Fear Level
	var fear = Global.fear_level
	if fear < min_fear_level and not guaranteed_spawn:
		queue_free()
		return
		
	# Spawn chance = fear_level / 5.0 (ví dụ Fear Level 1 = 20%, Level 5 = 100%)
	var spawn_chance = float(fear) / 5.0
	if randf() > spawn_chance and not guaranteed_spawn:
		queue_free()
		return
		
	print("[ShadowEntity] Shadow spawned at: ", global_position, " (Fear Level: ", fear, ")")
	
	# Đăng ký vào nhóm thực thể tâm lý
	add_to_group("PsychologicalEntity")
	
	# Tìm player
	_player = get_tree().get_first_node_in_group("Player")
	
	# Modulate bóng mờ đỏ/đen ảo ảnh
	modulate = Color(0.1, 0.1, 0.1, 0.75) # Shadowy dark look

func _process(delta: float) -> void:
	if _is_fading or not is_instance_valid(_player):
		return
		
	var dist = global_position.distance_to(_player.global_position)
	if dist > max_view_distance:
		return
		
	# Hướng từ player đến thực thể
	var dir_to_entity = (global_position - _player.global_position).normalized()
	
	# Kiểm tra xem player có đang nhìn về phía thực thể không
	var player_facing = _player.get("facing_direction")
	if player_facing is Vector2:
		var dot = player_facing.dot(dir_to_entity)
		
		# Nếu player nhìn trực diện (dot > 0.7) hoặc đến quá gần (< 100px)
		if dot > detection_angle or dist < 120.0:
			_vanish_shadow()

func _vanish_shadow() -> void:
	_is_fading = true
	print("[ShadowEntity] Player looked directly or got too close. Fading out.")
	
	# Hiệu ứng fade out bằng Tween
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	# Tiếng thì thầm rất khẽ khi tan rã
	AudioManager.play_sfx_placeholder("shadow_dissolve")
	
	# Sau khi fade xong thì xoá thực thể
	await tween.finished
	queue_free()
