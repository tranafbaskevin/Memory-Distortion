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

var _base_position: Vector2
var _debug_print_timer: float = 0.0

@onready var light_hint: PointLight2D = get_node_or_null("LightHint")
@onready var prompt_label: Label = get_node_or_null("PromptLabel")

func _ready() -> void:
	# Gọi ready của lớp cha (Interactable)
	super._ready()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Lưu vị trí ban đầu làm Failsafe anchor
	_base_position = position
	z_index = 5 # Đảm bảo Door luôn render phía trước Player
	
	# Door Debug Rect (Đỏ = cửa)
	var rect = ColorRect.new()
	rect.color = Color(1.0, 0.0, 0.0, 0.6)
	rect.size = Vector2(32, 48)
	rect.position = -rect.size / 2
	rect.set_script(load("res://components/debug_rect.gd"))
	add_child(rect)
	
	if RoomGateManager.has_signal("room_state_changed"):
		RoomGateManager.room_state_changed.connect(_on_room_state_changed)
	
	_update_door_state()

func _update_door_state() -> void:
	if door_state == "story_locked" and room_id != "":
		var state = RoomGateManager.get_room_state(room_id)
		if state == RoomGateManager.RoomState.UNLOCKED:
			door_state = "unlocked"
		elif state == RoomGateManager.RoomState.FORESHADOW:
			if light_hint:
				light_hint.show()
				light_hint.energy = 0.3
				light_hint.color = Color(1.0, 0.95, 0.8, 1.0)
		else:
			if light_hint:
				light_hint.show()
				light_hint.energy = 0.08
				light_hint.color = Color(0.2, 0.2, 0.3, 1.0)
	
	if door_state != "story_locked":
		if light_hint:
			light_hint.show()
			if door_state == "locked":
				light_hint.energy = 0.12
				light_hint.color = Color(0.85, 0.2, 0.2, 1.0)
			else:
				light_hint.energy = 0.15
				light_hint.color = Color(0.75, 0.75, 0.8, 1.0)
				
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
	# ─── MANDATORY INTEGRITY CHECKS ───
	# 1. Đảm bảo Door luôn visible & collision active
	if not visible:
		visible = true
	if modulate.a < 1.0:
		modulate.a = 1.0
	if not monitoring:
		monitoring = true
	if not monitorable:
		monitorable = true
		
	# 2. Failsafe position: kiểm tra nếu cửa bị văng ra khỏi biên giới căn phòng
	var current_scene_name = get_tree().current_scene.name
	if current_scene_name != "House" and current_scene_name != "TrueEnding" and current_scene_name != "InfiniteLoopEnding" and current_scene_name != "BrokenEnding":
		# Nếu là phòng phụ (độ rộng chuẩn 1152x648)
		if position.x < 10.0 or position.x > 1142.0 or position.y < 10.0 or position.y > 638.0:
			print("[DEBUG] Door fail! Door position out of bounds: ", position, ". Respawning at base position: ", _base_position)
			position = _base_position
			
	# 3. Định kỳ in debug log trạng thái (không spam mỗi frame, 5s một lần)
	_debug_print_timer += delta
	if _debug_print_timer >= 5.0:
		_debug_print_timer = 0.0
		print("[DEBUG] Door Name: ", name, " | Pos: ", position, " | Visible: ", visible, " | Monitoring: ", monitoring)

	# ─── NARRATIVE / FORESHADOW LOGIC ───
	if not _player_nearby:
		return
	
	_update_prompt_message()
	
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
	
	var camera = player.find_child("Camera2D", true, false)
	if camera:
		camera.shake(2.0, 0.15, 22.0)
	
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
