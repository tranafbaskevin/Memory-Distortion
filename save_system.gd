## SaveSystem — Lưu và tải trạng thái game bằng ConfigFile
## Auto-save mỗi khi scene thay đổi
## Load tự động khi khởi động
extends Node

const SAVE_PATH = "user://savegame.cfg"

func _ready() -> void:
	# Tải save khi khởi động
	load_game()
	print("[SaveSystem] Ready. Save path: ", SAVE_PATH)

# ─── SAVE ──────────────────────────────────────────────────────────────────────
func save_game() -> void:
	var config = ConfigFile.new()
	
	# Gameplay state
	config.set_value("state", "bedroom_distorted", Global.bedroom_distorted)
	config.set_value("state", "player_has_key", Global.player_has_key)
	config.set_value("state", "distortion_events_count", Global.distortion_events_count)
	config.set_value("state", "player_spawn_name", Global.player_spawn_name)
	config.set_value("state", "global_distortion_level", Global.global_distortion_level)
	config.set_value("state", "elapsed_seconds", Global.elapsed_seconds)
	config.set_value("state", "fear_level", Global.fear_level)
	config.set_value("state", "truth_acceptance_level", Global.truth_acceptance_level)
	
	# Room visits
	for room_id in Global.room_visits:
		config.set_value("room_visits", room_id, Global.room_visits[room_id])
		
	# Unlocked rooms
	for room_id in Global.unlocked_rooms:
		config.set_value("unlocked_rooms", room_id, Global.unlocked_rooms[room_id])
		
	# Anchor observations
	for anchor_id in Global.anchor_observations:
		config.set_value("anchor_observations", anchor_id, Global.anchor_observations[anchor_id])
	
	# Ghi file
	var err = config.save(SAVE_PATH)
	if err == OK:
		print("[SaveSystem] Game saved.")
	else:
		push_warning("[SaveSystem] Failed to save: ", err)

# ─── LOAD ──────────────────────────────────────────────────────────────────────
func load_game() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err != OK:
		print("[SaveSystem] No save found. Starting fresh.")
		return
	
	# Khôi phục gameplay state
	Global.bedroom_distorted = config.get_value("state", "bedroom_distorted", false)
	Global.player_has_key = config.get_value("state", "player_has_key", false)
	Global.distortion_events_count = config.get_value("state", "distortion_events_count", 0)
	Global.player_spawn_name = config.get_value("state", "player_spawn_name", "")
	Global.global_distortion_level = config.get_value("state", "global_distortion_level", 0)
	Global.elapsed_seconds = config.get_value("state", "elapsed_seconds", 0.0)
	Global.fear_level = config.get_value("state", "fear_level", 0)
	Global.truth_acceptance_level = config.get_value("state", "truth_acceptance_level", 0)
	
	# Khôi phục room visits
	if config.has_section("room_visits"):
		for room_id in config.get_section_keys("room_visits"):
			Global.room_visits[room_id] = config.get_value("room_visits", room_id, 0)
			
	# Khôi phục unlocked rooms
	if config.has_section("unlocked_rooms"):
		for room_id in config.get_section_keys("unlocked_rooms"):
			Global.unlocked_rooms[room_id] = config.get_value("unlocked_rooms", room_id, false)
			
	# Khôi phục anchor observations
	if config.has_section("anchor_observations"):
		for anchor_id in config.get_section_keys("anchor_observations"):
			Global.anchor_observations[anchor_id] = config.get_value("anchor_observations", anchor_id, 0)
	
	print("[SaveSystem] Game loaded. Key: ", Global.player_has_key, " | Distorted: ", Global.bedroom_distorted, " | Tier: ", Global.global_distortion_level)

# ─── RESET ─────────────────────────────────────────────────────────────────────
func reset_game() -> void:
	Global.bedroom_distorted = false
	Global.player_has_key = false
	Global.distortion_events_count = 0
	Global.player_spawn_name = ""
	Global.room_visits = {}
	Global.unlocked_rooms = {}
	Global.global_distortion_level = 0
	Global.elapsed_seconds = 0.0
	Global.anchor_observations = {}
	Global.fear_level = 0
	Global.truth_acceptance_level = 0
	
	# Xoá file save
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	
	print("[SaveSystem] Game reset.")

