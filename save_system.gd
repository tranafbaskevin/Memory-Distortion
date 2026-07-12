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
	
	# Room visits (lưu từng key trong dictionary)
	for room_id in Global.room_visits:
		config.set_value("room_visits", room_id, Global.room_visits[room_id])
	
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
	
	# Khôi phục room visits
	if config.has_section("room_visits"):
		for room_id in config.get_section_keys("room_visits"):
			Global.room_visits[room_id] = config.get_value("room_visits", room_id, 0)
	
	print("[SaveSystem] Game loaded. Key: ", Global.player_has_key, " | Distorted: ", Global.bedroom_distorted)

# ─── RESET ─────────────────────────────────────────────────────────────────────
func reset_game() -> void:
	Global.bedroom_distorted = false
	Global.player_has_key = false
	Global.distortion_events_count = 0
	Global.player_spawn_name = ""
	Global.room_visits = {}
	
	# Xoá file save
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	
	print("[SaveSystem] Game reset.")
