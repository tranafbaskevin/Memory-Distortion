extends Interactable

# Xuất ra đường dẫn file của Scene muốn chuyển tới
@export_file("*.tscn") var target_scene: String
@export var target_spawn_name: String = ""

# Door V2 States
@export_enum("unlocked", "locked", "story_locked") var door_state: String = "unlocked"
@export var room_id: String = "" # Đối với story_locked, khớp với RoomGateManager
@export var locked_hint: String = "Cửa bị khoá. Tớ cần tìm thứ gì đó để mở nó."
@export var story_locked_hint: String = "Cửa không mở ra. Có tiếng động kỳ lạ từ bên trong."
@export_enum("silence", "whisper", "dripping", "breathing", "music_box") var foreshadow_type: String = "silence"

var _player_nearby: bool = false
var _foreshadow_timer: float = 0.0
const FORESHADOW_INTERVAL: float = 8.0

@onready var light_hint: PointLight2D = get_node_or_null("LightHint")
@onready var prompt_label: Label = get_node_or_null("PromptLabel")

func _ready() -> void:
	# Gọi ready của lớp cha (Interactable)
	super._ready()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if RoomGateManager.has_signal("room_state_changed"):
		RoomGateManager.room_state_changed.connect(_on_room_state_changed)
	
	_update_door_state()

func _update_door_state() -> void:
	# Nếu là story_locked, kiểm tra RoomGateManager để đồng bộ trạng thái thực tế
	if door_state == "story_locked" and room_id != "":
		var state = RoomGateManager.get_room_state(room_id)
		if state == RoomGateManager.RoomState.UNLOCKED:
			door_state = "unlocked"
		elif state == RoomGateManager.RoomState.FORESHADOW:
			if light_hint:
				light_hint.show()
				light_hint.energy = 0.3
				light_hint.color = Color(1.0, 0.95, 0.8, 1.0) # Ánh sáng vàng ấm
		else:
			if light_hint:
				light_hint.show()
				light_hint.energy = 0.08
				light_hint.color = Color(0.2, 0.2, 0.3, 1.0) # Ánh sáng xanh xám cực yếu
	
	# Đối với cửa unlocked hoặc locked thông thường, cung cấp ánh sáng định vị cực kỳ yếu
	if door_state != "story_locked":
		if light_hint:
			light_hint.show()
			if door_state == "locked":
				light_hint.energy = 0.12
				light_hint.color = Color(0.85, 0.2, 0.2, 1.0) # Ánh sáng đỏ báo khoá
			else:
				light_hint.energy = 0.15
				light_hint.color = Color(0.75, 0.75, 0.8, 1.0) # Ánh sáng trắng xám mờ báo mở
				
	_update_prompt_message()


func _update_prompt_message() -> void:
	if door_state == "unlocked":
		prompt_message = "Nhấn E để mở cửa"
	elif door_state == "locked":
		if Global.player_has_key:
			prompt_message = "Nhấn E để mở cửa"
		else:
			prompt_message = "Cửa bị khoá..."
	elif door_state == "story_locked":
		prompt_message = "Cửa không mở..."

func _process(delta: float) -> void:
	if not _player_nearby:
		return
	
	# Cập nhật prompt liên tục
	_update_prompt_message()
	
	# Foreshadow audio định kỳ nếu đang ở trạng thái story_locked & foreshadow
	if door_state == "story_locked" and room_id != "":
		if RoomGateManager.is_foreshadow(room_id):
			_foreshadow_timer += delta
			if _foreshadow_timer >= FORESHADOW_INTERVAL:
				_foreshadow_timer = 0.0
				_play_foreshadow_audio()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_nearby = true
		_foreshadow_timer = FORESHADOW_INTERVAL * 0.6
		_update_door_state()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_nearby = false
		_foreshadow_timer = 0.0

func _interact(player: Node2D) -> void:
	_update_door_state()
	
	if door_state == "unlocked":
		_open_door()
	elif door_state == "locked":
		if Global.player_has_key:
			_open_door()
		else:
			_handle_locked(player, locked_hint)
	elif door_state == "story_locked":
		if room_id != "" and RoomGateManager.is_unlocked(room_id):
			_open_door()
		else:
			_handle_locked(player, story_locked_hint, true)

func _open_door() -> void:
	if target_scene != "":
		Transition.change_scene(target_scene, target_spawn_name)
	else:
		print("Warning: target_scene is empty on door: ", name)

func _handle_locked(player: Node2D, message: String, is_story: bool = false) -> void:
	AudioManager.play_door_locked()
	Narrative.show_message(message, 3.0)
	
	# Rung camera nhẹ (giật tay nắm)
	var camera = player.find_child("Camera2D", true, false)
	if camera:
		camera.shake(2.0, 0.15, 22.0)
	
	# Hiệu ứng light hint pulse nếu có đèn
	if light_hint:
		var tween = create_tween()
		tween.tween_property(light_hint, "energy", 0.8, 0.1)
		tween.tween_property(light_hint, "energy", 0.3, 0.5)
		
	if is_story:
		_play_foreshadow_audio()

func _play_foreshadow_audio() -> void:
	match foreshadow_type:
		"whisper":    AudioManager.play_sfx_placeholder("whisper_behind_door")
		"dripping":   AudioManager.play_sfx_placeholder("water_drip")
		"breathing":  AudioManager.play_sfx_placeholder("quiet_breathing")
		"music_box":  AudioManager.play_sfx_placeholder("music_box_faint")

func _on_room_state_changed(changed_room_id: String, _new_state) -> void:
	if changed_room_id == room_id:
		_update_door_state()
