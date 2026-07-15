extends Node

# ─── Ambient Bus ───────────────────────────────────────────────────────────────
var _ambient_player: AudioStreamPlayer
# ─── SFX Bus ───────────────────────────────────────────────────────────────────
var _sfx_player: AudioStreamPlayer
# ─── Tween hiện tại đang fade ──────────────────────────────────────────────────
var _fade_tween: Tween = null

# Map scene path → ambient label (dùng khi chưa có file thật)
const SCENE_AMBIENT_MAP: Dictionary = {
	"res://scenes/floor1/hallway_f1.tscn":  "ambient_house",
	"res://scenes/floor1/kitchen.tscn":     "ambient_house",
	"res://scenes/floor1/living_room.tscn": "ambient_house",
	"res://scenes/floor1/toilet_f1.tscn":   "ambient_house",
	"res://scenes/floor2/hallway_f2.tscn":  "ambient_house",
	"res://scenes/floor2/bedroom_main.tscn":"ambient_bedroom",
	"res://scenes/floor2/bedroom_parents.tscn": "ambient_house",
	"res://scenes/floor2/bedroom_sibling.tscn": "ambient_house",
	"res://scenes/floor2/study_room.tscn":  "ambient_house",
	"res://scenes/floor2/toilet_f2.tscn":   "ambient_house",
}

# ─── ducking & random ambient variables ───────────────────────────────────────
var _is_ducked: bool = false
var _original_ambient_volume: float = -15.0
var _ambient_timer: Timer = null

func _ready() -> void:
	# Tạo AudioStreamPlayer cho ambient (âm nhạc nền, loop)
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Ambient"
	_ambient_player.volume_db = _original_ambient_volume
	add_child(_ambient_player)
	
	# Tạo AudioStreamPlayer riêng cho SFX (không bị ảnh hưởng bởi fade ambient)
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "SFX"
	_sfx_player.volume_db = 0.0
	add_child(_sfx_player)
	
	# Kết nối tín hiệu ducking từ Narrative
	if Narrative.has_signal("message_shown"):
		Narrative.message_shown.connect(_on_message_shown)
	if Narrative.has_signal("message_hidden"):
		Narrative.message_hidden.connect(_on_message_hidden)
		
	# Khởi động timer phát âm thanh ngẫu nhiên
	_setup_random_ambient_timer()
	
	print("[AudioManager] Ready. Ducking & Ambient Audio System V2 initialized.")


# ─── AMBIENT ──────────────────────────────────────────────────────────────────
# Phát âm nền. stream = AudioStream resource (null = dừng ambient hiện tại)
func play_ambient(stream: AudioStream, volume_db: float = -10.0) -> void:
	if stream == null:
		stop_ambient()
		return
	_ambient_player.stream = stream
	_ambient_player.volume_db = volume_db
	_ambient_player.play()
	print("[AudioManager] Ambient playing: ", stream.resource_path)

# Dừng ambient ngay lập tức
func stop_ambient() -> void:
	_ambient_player.stop()
	print("[AudioManager] Ambient stopped")

# Fade volume ambient từ hiện tại sang target_db trong duration giây
func fade_ambient(target_db: float, duration: float = 1.5) -> void:
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_ambient_player, "volume_db", target_db, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	print("[AudioManager] Fading ambient to ", target_db, "db over ", duration, "s")

# ─── SFX ──────────────────────────────────────────────────────────────────────
# Phát một âm thanh sự kiện một lần
func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		push_warning("[AudioManager] play_sfx() called with null stream. Skipping.")
		return
	_sfx_player.stream = stream
	_sfx_player.volume_db = volume_db
	_sfx_player.play()
	print("[AudioManager] SFX playing: ", stream.resource_path)

# ─── PLACEHOLDER HELPERS ──────────────────────────────────────────────────────
# Khi chưa có asset, gọi hàm này để test flow mà không bị crash
func play_ambient_placeholder(label: String = "ambient") -> void:
	print("[AudioManager] [PLACEHOLDER] Ambient would play: ", label)

func play_sfx_placeholder(label: String = "sfx") -> void:
	print("[AudioManager] [PLACEHOLDER] SFX would play: ", label)

# ─── SCENE-AWARE HELPER ───────────────────────────────────────────────────────
# Tự động phát ambient phù hợp dựa theo scene path hiện tại
# Gọi ở đầu _ready() của mỗi scene thay vì hardcode label
func play_ambient_for_scene(scene_path: String, distorted: bool = false) -> void:
	if distorted:
		play_ambient_placeholder("ambient_distorted")
		return
	if SCENE_AMBIENT_MAP.has(scene_path):
		play_ambient_placeholder(SCENE_AMBIENT_MAP[scene_path])
	else:
		play_ambient_placeholder("ambient_house")

# ─── DOOR / TRANSITION SFX ────────────────────────────────────────────────────
func play_door_open() -> void:
	play_sfx_placeholder("door_open")

func play_door_locked() -> void:
	play_sfx_placeholder("door_locked")

func play_key_pickup() -> void:
	play_sfx_placeholder("key_pickup")

# ─── PROGRESSION-BASED AMBIENT TEXTURE ────────────────────────────────────────
func set_ambient_tier(tier: int) -> void:
	match tier:
		0, 1:
			_original_ambient_volume = -18.0
			play_ambient_placeholder("ambient_house")
		2:
			_original_ambient_volume = -14.0
			play_ambient_placeholder("ambient_tension_rising")
		3:
			_original_ambient_volume = -11.0
			play_ambient_placeholder("ambient_distorted_spatial")
		4:
			_original_ambient_volume = -8.0
			play_ambient_placeholder("ambient_psychological_dread")
			
	# Áp dụng mức âm lượng mới (nếu đang không bị vịn lời thoại làm nhỏ âm lượng)
	if not _is_ducked:
		fade_ambient(_original_ambient_volume, 1.5)

# ─── DUCKING LOGIC ────────────────────────────────────────────────────────────
func _on_message_shown(_text: String, _duration: float) -> void:
	_is_ducked = true
	# Giảm âm lượng nền đi 12dB để nhường chỗ cho text/suy nghĩ
	fade_ambient(_original_ambient_volume - 12.0, 0.4)

func _on_message_hidden() -> void:
	_is_ducked = false
	# Khôi phục từ từ lại mức volume gốc
	fade_ambient(_original_ambient_volume, 0.8)

# ─── RANDOM SPATIAL AMBIENT SOUNDS ────────────────────────────────────────────
func _setup_random_ambient_timer() -> void:
	_ambient_timer = Timer.new()
	_ambient_timer.one_shot = true
	_ambient_timer.timeout.connect(_on_ambient_timer_timeout)
	add_child(_ambient_timer)
	_reset_ambient_timer()

func _reset_ambient_timer() -> void:
	# Càng ở Fear Level cao, tiếng động ngẫu nhiên xuất hiện càng thường xuyên!
	var fear = Global.fear_level
	var min_time = clampf(20.0 - fear * 3.0, 5.0, 20.0)
	var max_time = clampf(30.0 - fear * 4.0, 10.0, 30.0)
	_ambient_timer.start(randf_range(min_time, max_time))

func _on_ambient_timer_timeout() -> void:
	# Chỉ phát tiếng động ngẫu nhiên nếu không có hội thoại đang diễn ra và đã vượt qua Level 0
	if not _is_ducked and Global.global_distortion_level >= 1:
		_play_random_ambient_sound()
	_reset_ambient_timer()

func _play_random_ambient_sound() -> void:
	var sounds = ["distant_footsteps", "wood_creak", "low_breathing", "environmental_hum"]
	var selected = sounds[randi() % sounds.size()]
	
	# Âm lượng scaling dựa theo Fear Level hiện tại
	var volume_offset = -18.0 + (Global.fear_level * 2.0)
	
	print("[AudioManager] [SPATIAL_AMBIENT] Play: ", selected, " | Vol: ", volume_offset, "dB (Fear: ", Global.fear_level, ")")
	
	# Play SFX với âm lượng điều chỉnh (ở đây in ra log và play placeholder)
	play_sfx_placeholder(selected + "_vol_" + str(volume_offset))



