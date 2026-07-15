extends Node

# ─── NAVIGATION ───────────────────────────────────────────────────────────────
# Biến toàn cục lưu tên vị trí Marker2D mà Player cần dịch chuyển tới sau khi chuyển scene
var player_spawn_name: String = ""

# ─── GAMEPLAY STATE ───────────────────────────────────────────────────────────
var bedroom_distorted: bool = false
var player_has_key: bool = false
var distortion_events_count: int = 0
var fear_level: int = 0             # Cấp độ sợ hãi (0-5)
var truth_acceptance_level: int = 0 # Mức độ chấp nhận sự thật (0-5)


# ─── ROOM TRACKING ────────────────────────────────────────────────────────────
var room_visits: Dictionary = {}
var unlocked_rooms: Dictionary = {}

# ─── DISTORTION SYSTEM ────────────────────────────────────────────────────────
## Tier hiện tại (mirror từ DistortionController, lưu để save/load)
var global_distortion_level: int = 0
## Thời gian chơi tính bằng giây (mirror từ DistortionController)
var elapsed_seconds: float = 0.0

# ─── ANCHOR OBSERVATION ───────────────────────────────────────────────────────
## Lưu số lần player đã quan sát từng anchor object
## anchor_id → observed_count
var anchor_observations: Dictionary = {}
