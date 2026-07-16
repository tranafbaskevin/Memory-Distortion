extends Node

# ─── NAVIGATION ───────────────────────────────────────────────────────────────
var player_spawn_name: String = ""
var DEBUG_MODE: bool = true


# ─── GAMEPLAY STATE ───────────────────────────────────────────────────────────
var bedroom_distorted: bool = false
var player_has_key: bool = false
var distortion_events_count: int = 0
var fear_level: int = 0             # Cấp độ sợ hãi (0-5)
var truth_acceptance_level: int = 0 # Mức độ chấp nhận sự thật (0-5)
var denial_level: int = 0           # Cấp độ phủ nhận (0-5)
var loop_depth: int = 0             # Độ sâu vòng lặp phủ nhận (0+)

var acceptance_level: int:
	get:
		return truth_acceptance_level
	set(value):
		truth_acceptance_level = value



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
var last_trigger_time: float = -999.0

