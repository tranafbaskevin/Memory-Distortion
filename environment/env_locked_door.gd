## EnvLockedDoor — Cửa khoá CÓ Ý NGHĨA
## Khác với LockedDoor (cần chìa khoá), cái này khoá theo progression
## Nhưng luôn có foreshadow: âm thanh/ánh sáng gợi ý có gì đó phía sau
## Giải quyết Testarossa: "không bao giờ chỉ là barrier kỹ thuật trần trụi"
extends Area2D

## ID phòng (phải khớp với RoomGateManager.room_states)
@export var room_id: String = ""
## Scene đích khi đã unlock
@export_file("*.tscn") var target_scene: String = ""
@export var target_spawn_name: String = "SpawnPoint"
## Lời hint khi cửa còn khoá (gợi ý có gì đó phía sau, không giải thích rõ)
@export var locked_hint: String = ""
## Kiểu foreshadow (ảnh hưởng âm thanh phía sau cửa)
@export_enum("silence", "whisper", "dripping", "breathing", "music_box") var foreshadow_type: String = "silence"

var _player_nearby: bool = false
var _show_prompt: bool = false
var _foreshadow_timer: float = 0.0
const FORESHADOW_INTERVAL: float = 8.0  # Phát âm thanh foreshadow mỗi 8 giây

@onready var prompt_label: Label = get_node_or_null("PromptLabel")
@onready var light_hint: PointLight2D = get_node_or_null("LightHint")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Ánh sáng hé qua khe cửa — luôn hiển thị ở foreshadow mode
	if light_hint and RoomGateManager.is_foreshadow(room_id):
		light_hint.show()
		light_hint.energy = 0.3
	elif light_hint:
		light_hint.hide()
	
	# Kết nối signal khi phòng được unlock
	RoomGateManager.room_state_changed.connect(_on_room_state_changed)
	
	if prompt_label:
		prompt_label.hide()

func _process(delta: float) -> void:
	if not _player_nearby:
		return
	
	# Foreshadow audio lặp đi lặp lại khi player đứng gần
	_foreshadow_timer += delta
	if _foreshadow_timer >= FORESHADOW_INTERVAL:
		_foreshadow_timer = 0.0
		if not RoomGateManager.is_unlocked(room_id):
			_play_foreshadow_audio()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	_player_nearby = true
	_foreshadow_timer = FORESHADOW_INTERVAL * 0.6  # Phát sớm hơn lần đầu
	
	if prompt_label:
		if RoomGateManager.is_unlocked(room_id):
			prompt_label.text = "Nhấn E để mở cửa"
		else:
			prompt_label.text = "..."
		prompt_label.show()

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	_player_nearby = false
	_foreshadow_timer = 0.0
	if prompt_label:
		prompt_label.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not _player_nearby:
		return
	if not (event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")):
		return
	
	if RoomGateManager.is_unlocked(room_id):
		_enter_room()
	else:
		_try_locked()

func _enter_room() -> void:
	if target_scene == "":
		return
	Global.player_spawn_name = target_spawn_name
	SaveSystem.save_game()
	AudioManager.play_door_open()
	get_tree().change_scene_to_file(target_scene)

func _try_locked() -> void:
	# Phát foreshadow ngay và lời thoại gợi ý
	_play_foreshadow_audio()
	var hint = locked_hint if locked_hint != "" else "Cửa không mở ra. Có âm thanh kỳ lạ từ phía bên trong."
	Narrative.show_message(hint, 3.5)
	
	# Camera rung rất nhẹ — player cảm giác "đẩy" cửa
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var camera = player.find_child("Camera2D", true, false)
		if camera:
			camera.shake(1.5, 0.15, 20.0)
	
	# Light hint pulse — ánh sáng sau cửa sáng lên chút rồi tắt
	if light_hint:
		var tween = create_tween()
		tween.tween_property(light_hint, "energy", 0.8, 0.1)
		tween.tween_property(light_hint, "energy", 0.3, 0.5)

func _play_foreshadow_audio() -> void:
	match foreshadow_type:
		"whisper":    AudioManager.play_sfx_placeholder("whisper_behind_door")
		"dripping":   AudioManager.play_sfx_placeholder("water_drip")
		"breathing":  AudioManager.play_sfx_placeholder("quiet_breathing")
		"music_box":  AudioManager.play_sfx_placeholder("music_box_faint")
		"silence":    pass  # Silence IS the foreshadow — nothing = wrong

func _on_room_state_changed(changed_room_id: String, new_state: RoomGateManager.RoomState) -> void:
	if changed_room_id != room_id:
		return
	if new_state == RoomGateManager.RoomState.UNLOCKED:
		# Khi phòng được unlock, đèn sáng lên hơn
		if light_hint:
			var tween = create_tween()
			tween.tween_property(light_hint, "energy", 1.2, 0.8)
		if prompt_label and _player_nearby:
			prompt_label.text = "Nhấn E để mở cửa"
		print("[EnvLockedDoor] Room '", room_id, "' unlocked — door now accessible.")
