## LightFlicker — Đèn nhấp nháy ngẫu nhiên, tạo cảm giác không ổn định
## Gắn script này vào bất kỳ PointLight2D nào để kích hoạt hiệu ứng
extends PointLight2D

@export var base_energy: float = 1.0
@export var flicker_intensity: float = 0.3 # Biên độ dao động năng lượng
@export var flicker_speed: float = 0.08    # Thời gian giữa mỗi lần thay đổi (giây)
@export var is_enabled: bool = true        # Bật/tắt flicker từ bên ngoài

var _timer: float = 0.0

func _ready() -> void:
	energy = base_energy

func _process(delta: float) -> void:
	if not is_enabled:
		energy = base_energy
		return
	
	_timer += delta
	if _timer >= flicker_speed:
		_timer = 0.0
		# Năng lượng dao động ngẫu nhiên quanh base_energy
		energy = base_energy + randf_range(-flicker_intensity, flicker_intensity)

## Bật flicker đột ngột mạnh hơn (dùng cho sự kiện kinh dị)
func flicker_burst(duration: float = 1.0, burst_intensity: float = 0.6) -> void:
	var original_intensity = flicker_intensity
	flicker_intensity = burst_intensity
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
