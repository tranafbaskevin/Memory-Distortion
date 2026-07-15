## LightFlicker — Đèn nhấp nháy ngẫu nhiên, tạo cảm giác không ổn định
## Gắn script này vào bất kỳ PointLight2D nào để kích hoạt hiệu ứng
extends PointLight2D

@export var base_energy: float = 1.0
@export var flicker_intensity: float = 0.3 # Biên độ dao động năng lượng
@export var flicker_speed: float = 0.08    # Thời gian giữa mỗi lần thay đổi (giây)
@export var is_enabled: bool = true        # Bật/tắt flicker từ bên ngoài

@export var occasional_flicker: bool = true   # Nếu true, không nháy liên tục mà nháy theo đợt để tránh nhàm chán
@export var min_flicker_cooldown: float = 15.0
@export var max_flicker_cooldown: float = 35.0

var _timer: float = 0.0
var _is_flickering: bool = false
var _flicker_duration_left: float = 0.0
var _cooldown_timer: float = 5.0 # Cooldown ngắn lúc bắt đầu
var _entity_flicker_timer: float = 0.0 # Timer kiểm soát đợt nháy khi có entity

func _ready() -> void:
	energy = base_energy
	# Thiết lập thời gian chờ ngẫu nhiên ban đầu
	_cooldown_timer = randf_range(5.0, 15.0)

func _process(delta: float) -> void:
	if not is_enabled:
		energy = base_energy
		return
	
	# Kiểm tra xem có ShadowEntity nào đang xuất hiện trong phòng không
	var entities_present = get_tree().get_nodes_in_group("PsychologicalEntity").size() > 0
	
	# Xử lý đếm ngược thời gian tắt nhấp nháy cho cả 2 chế độ
	if _is_flickering:
		_flicker_duration_left -= delta
		if _flicker_duration_left <= 0:
			_is_flickering = false
			energy = base_energy
			# Thiết lập cooldown mới cho nháy thông thường
			if not entities_present:
				var fear_offset_min = Global.fear_level * 2.0
				var fear_offset_max = Global.fear_level * 3.0
				_cooldown_timer = randf_range(
					maxf(min_flicker_cooldown - fear_offset_min, 4.0),
					maxf(max_flicker_cooldown - fear_offset_max, 8.0)
				)
	
	if entities_present:
		# Nếu có thực thể xuất hiện: nháy 1 đợt ngắn (0.5s - 1.2s) rồi im lặng ngột ngạt (8s - 14s)
		_entity_flicker_timer -= delta
		if _entity_flicker_timer <= 0.0:
			_is_flickering = true
			_flicker_duration_left = randf_range(0.5, 1.2)
			_entity_flicker_timer = randf_range(8.0, 14.0)
			AudioManager.play_sfx_placeholder("flicker_sound_subtle")
			
		# Khi không trong đợt burst nhấp nháy, đèn mờ hẳn đi 40% (dread tĩnh lặng)
		if not _is_flickering:
			energy = lerpf(energy, base_energy * 0.6, 0.08)
			return
	else:
		# Khi không có thực thể, nháy ngẫu nhiên thưa thớt thông thường
		if occasional_flicker:
			if not _is_flickering:
				_cooldown_timer -= delta
				if _cooldown_timer <= 0:
					_is_flickering = true
					_flicker_duration_left = randf_range(1.0, 3.0) # Nháy trong 1-3 giây
					
				# Giữ ánh sáng ổn định
				if not _is_flickering:
					energy = lerpf(energy, base_energy, 0.1)
					return
			
	# Thực hiện nhấp nháy đèn thực tế (trong đợt burst)
	_timer += delta
	if _timer >= flicker_speed:
		_timer = 0.0
		var current_intensity = flicker_intensity + (Global.fear_level * 0.04)
		if entities_present:
			current_intensity = flicker_intensity * 1.5
			
		energy = base_energy + randf_range(-current_intensity, current_intensity)
		energy = maxf(energy, 0.0) # Không để năng lượng bị âm


## Bật flicker đột ngột mạnh hơn (dùng cho sự kiện kinh dị)
func flicker_burst(duration: float = 1.0, burst_intensity: float = 0.6) -> void:
	var original_intensity = flicker_intensity
	flicker_intensity = burst_intensity
	_is_flickering = true
	_flicker_duration_left = duration
	AudioManager.play_sfx_placeholder("flicker_sound")
	await get_tree().create_timer(duration).timeout
	flicker_intensity = original_intensity

## Tắt đèn từ từ (fade out)
func fade_out(duration: float = 2.0) -> void:
	var tween = create_tween()
	tween.tween_property(self, "energy", 0.0, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	is_enabled = false
	await tween.finished

## Bật đèn từ từ (fade in)  
func fade_in(target_energy: float = -1.0, duration: float = 1.5) -> void:
	if target_energy < 0:
		target_energy = base_energy
	is_enabled = true
	var tween = create_tween()
	tween.tween_property(self, "energy", target_energy, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

