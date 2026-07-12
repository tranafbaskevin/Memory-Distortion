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


func _ready() -> void:
	# Tạo AudioStreamPlayer cho ambient (âm nhạc nền, loop)
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Ambient"
	_ambient_player.volume_db = -10.0
	add_child(_ambient_player)
	
	# Tạo AudioStreamPlayer riêng cho SFX (không bị ảnh hưởng bởi fade ambient)
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "SFX"
	_sfx_player.volume_db = 0.0
	add_child(_sfx_player)
	
	print("[AudioManager] Ready. Buses: Ambient + SFX")

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

