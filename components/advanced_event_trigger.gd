class_name AdvancedEventTrigger
extends Area2D

signal triggered(player: Node2D)

## Sự kiện có thể kích hoạt nhiều lần không?
@export var repeatable: bool = false
## Xác suất kích hoạt (0.0 → 1.0). Ví dụ 0.7 = 70% cơ hội xảy ra
@export_range(0.0, 1.0) var trigger_chance: float = 1.0
## Thời gian chờ trước khi hiệu ứng xảy ra (giây)
@export var delay: float = 0.0
## Lời thoại hiển thị SAU delay
@export var dialogue_text: String = ""
## Nhãn định danh để Global theo dõi trạng thái
@export var event_id: String = ""

var _has_triggered: bool = false
var _is_cooling_down: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	if not repeatable and _has_triggered:
		return
	if _is_cooling_down:
		return
	
	# Kiểm tra xác suất ngẫu nhiên
	if randf() > trigger_chance:
		print("[AdvancedEventTrigger] Skipped by random chance (", event_id, ")")
		return
	
	_has_triggered = true
	_is_cooling_down = true
	
	# Delay trước khi thực thi
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	# Kiểm tra player còn valid sau delay
	if not is_instance_valid(body):
		return
	
	print("[AdvancedEventTrigger] Triggered: ", event_id if event_id != "" else name)
	triggered.emit(body)
	_on_trigger(body)
	
	if dialogue_text != "":
		Narrative.show_message(dialogue_text)
	
	# Cooldown ngắn để không kích hoạt lại ngay lập tức nếu repeatable = true
	await get_tree().create_timer(2.0).timeout
	_is_cooling_down = false

## Override hàm này để tùy biến sự kiện
func _on_trigger(_player: Node2D) -> void:
	pass

## Đặt lại trạng thái sự kiện từ bên ngoài
func reset() -> void:
	_has_triggered = false
	_is_cooling_down = false
