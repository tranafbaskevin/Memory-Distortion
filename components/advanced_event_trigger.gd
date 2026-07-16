class_name AdvancedEventTrigger
extends BaseTrigger

signal triggered(player: Node2D)

## Xác suất kích hoạt (0.0 → 1.0)
@export_range(0.0, 1.0) var trigger_chance: float = 1.0
## Thời gian chờ trước khi hiệu ứng xảy ra (giây)
@export var delay: float = 0.0
## Lời thoại hiển thị SAU delay
@export var dialogue_text: String = ""

func _custom_ready() -> void:
	# Mặc định kích hoạt tự động khi giẫm vào
	require_interaction = false

func _on_trigger_fired(player: Node2D) -> void:
	if randf() > trigger_chance:
		print("[AdvancedEventTrigger] Skipped by random chance (", event_id, ")")
		has_triggered = false # Cho phép thử lại
		return
		
	_on_cooldown = true
	
	if delay > 0:
		await get_tree().create_timer(delay).timeout
		
	if not is_instance_valid(player):
		_on_cooldown = false
		return
		
	print("[AdvancedEventTrigger] Triggered: ", event_id if event_id != "" else name)
	triggered.emit(player)
	_on_trigger(player)
	
	if dialogue_text != "":
		Narrative.show_message(dialogue_text)
		
	# Cooldown ngắn
	await get_tree().create_timer(2.0).timeout
	_on_cooldown = false

## Override hàm này để tùy biến sự kiện
func _on_trigger(_player: Node2D) -> void:
	pass
