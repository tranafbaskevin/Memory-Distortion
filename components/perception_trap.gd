class_name PerceptionTrap
extends Node2D

@export_enum("vanish_on_look", "peripheral_only") var trap_mode: String = "vanish_on_look"
@export var min_fear_level: int = 2
@export var detection_angle: float = 0.65
@export var max_distance: float = 600.0
@export var fade_speed: float = 5.0 # Tốc độ ẩn hiện bằng lerp

var _player: Node2D = null
var _sprite: Sprite2D = null
var _target_alpha: float = 0.0

func _ready() -> void:
	add_to_group("PerceptionTrap")
	_sprite = get_node_or_null("Sprite2D")
	if _sprite:
		_sprite.modulate.a = 0.0 # Bắt đầu ẩn hoàn toàn
		# Thiết lập màu bóng mờ tối
		_sprite.modulate.r = 0.05
		_sprite.modulate.g = 0.05
		_sprite.modulate.b = 0.08
		
	_player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	if not is_instance_valid(_player) or not _sprite:
		return
		
	# Chỉ hoạt động khi Fear Level đạt ngưỡng
	if Global.fear_level < min_fear_level:
		_target_alpha = 0.0
		_sprite.modulate.a = move_toward(_sprite.modulate.a, _target_alpha, delta * fade_speed)
		return
		
	var dist = global_position.distance_to(_player.global_position)
	if dist > max_distance:
		_target_alpha = 0.0
		_sprite.modulate.a = move_toward(_sprite.modulate.a, _target_alpha, delta * fade_speed)
		return
		
	# Hướng từ player đến bẫy nhận thức
	var dir_to_trap = (global_position - _player.global_position).normalized()
	var player_facing = _player.get("facing_direction")
	
	if player_facing is Vector2:
		var dot = player_facing.dot(dir_to_trap)
		
		match trap_mode:
			"vanish_on_look":
				# Ẩn đi khi player nhìn trực diện (dot > threshold) hoặc lại quá gần (< 130px)
				if dot > detection_angle or dist < 130.0:
					_target_alpha = 0.0
				else:
					# Hiện ra mờ mờ ở khoảng cách xa khi không bị nhìn trực diện
					_target_alpha = 0.55
					
			"peripheral_only":
				# Chỉ hiện ra khi nằm trong tầm nhìn ngoại vi (nhìn xéo xéo, dot từ 0.1 đến 0.55)
				# Ẩn đi lập tức nếu nhìn thẳng vào (dot > 0.6) hoặc quay mặt hẳn đi (dot <= 0.0) hoặc lại quá gần
				if dot >= 0.1 and dot <= 0.55 and dist > 130.0:
					_target_alpha = 0.5
				else:
					_target_alpha = 0.0
					
	# Áp dụng hiệu ứng fade lerp mượt mà
	_sprite.modulate.a = move_toward(_sprite.modulate.a, _target_alpha, delta * fade_speed)
