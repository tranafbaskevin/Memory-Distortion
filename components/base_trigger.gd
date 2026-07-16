class_name BaseTrigger
extends Area2D

@export var repeatable: bool = false
@export var require_interaction: bool = true # Bắt buộc nhấn E khi đứng trong vùng trigger
@export var event_id: String = ""

var can_interact: bool = false
var _player: Node2D = null
var has_triggered: bool = false
var _on_cooldown: bool = false

func _ready() -> void:
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_custom_ready()

func _custom_ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	if not repeatable and has_triggered:
		return
	if _on_cooldown:
		return
		
	can_interact = true
	_player = body
	print("[BaseTrigger] Player entered trigger: ", name)
	
	# Hiển thị gợi ý phím E nếu cần tương tác
	if require_interaction:
		var prompt = body.find_child("PromptLabel", true, false)
		if prompt:
			prompt.text = "Nhấn E để nhớ lại..."
			prompt.show()
	else:
		# Kích hoạt tự động
		print("[BaseTrigger] Trigger fired automatically: ", name)
		_fire_trigger()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		can_interact = false
		_player = null
		print("[BaseTrigger] Player exited trigger: ", name)
		
		var prompt = body.find_child("PromptLabel", true, false)
		if prompt:
			prompt.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not can_interact or not require_interaction or _on_cooldown:
		return
	if not repeatable and has_triggered:
		return
		
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_E or event.keycode == KEY_ENTER:
			print("[BaseTrigger] Interact pressed on: ", name)
			_fire_trigger()

func _fire_trigger() -> void:
	has_triggered = true
	print("[BaseTrigger] Trigger fired: ", name)
	
	if is_instance_valid(_player):
		var prompt = _player.find_child("PromptLabel", true, false)
		if prompt:
			prompt.hide()
			
	_on_trigger_fired(_player)

func _on_trigger_fired(_player_node: Node2D) -> void:
	pass
