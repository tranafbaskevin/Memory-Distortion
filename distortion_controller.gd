extends Node

# ─── THỜI GIAN ────────────────────────────────────────────────────────────────
var _elapsed_seconds: float = 0.0
var _tracking: bool = true

# ─── TIER SYSTEM ──────────────────────────────────────────────────────────────
var current_tier: int = 0

# Ngưỡng thời gian (giây) để leo tier
const TIER_THRESHOLDS: Dictionary = {
	1: 90.0,    # 1:30 — bắt đầu có dấu hiệu
	2: 240.0,   # 4:00 — vật thể không ổn định
	3: 360.0,   # 6:00 — không gian bóp méo
	4: 600.0,   # 10:00 — áp lực tâm lý tối đa
}

# ─── EVENT POOL ───────────────────────────────────────────────────────────────
# Mỗi Tier có pool event. Scene gọi request_event() → Controller chọn event phù hợp.
# Trọng số càng cao → xuất hiện thường hơn trong tier đó
const EVENT_POOL: Dictionary = {
	1: [
		{"id": "light_flicker",    "weight": 3},
		{"id": "ambient_shift",    "weight": 2},
		{"id": "door_creak_hint",  "weight": 2},
		{"id": "clock_off",        "weight": 1},  # Đồng hồ chạy sai giờ
	],
	2: [
		{"id": "object_shift",     "weight": 3},
		{"id": "tv_static",        "weight": 2},
		{"id": "light_dim",        "weight": 2},
		{"id": "chair_moved",      "weight": 1},
	],
	3: [
		{"id": "hallway_loop",     "weight": 3},
		{"id": "fake_door",        "weight": 2},
		{"id": "room_mismatch",    "weight": 2},
		{"id": "camera_drift",     "weight": 1},
	],
	4: [
		{"id": "whisper",          "weight": 3},
		{"id": "presence_shadow",  "weight": 2},
		{"id": "vignette_max",     "weight": 2},
		{"id": "narrative_spiral", "weight": 1},
	],
}

# ─── COOLDOWN ─────────────────────────────────────────────────────────────────
const COOLDOWN_PER_EVENT: float = 45.0    # Cùng event không lặp trong 45 giây
const COOLDOWN_ANY_EVENT: float = 12.0    # Tối thiểu 12 giây giữa bất kỳ event nào
var _event_cooldowns: Dictionary = {}     # event_id → last_trigger_time
var _last_any_event: float = -999.0

# ─── SIGNALS ──────────────────────────────────────────────────────────────────
signal tier_changed(new_tier: int)
signal event_triggered(event_id: String, tier: int)
signal room_should_unlock(room_id: String)

func _ready() -> void:
	# Khôi phục từ save nếu có
	_elapsed_seconds = Global.elapsed_seconds
	current_tier = Global.global_distortion_level
	print("[DistortionController] Initialized. Current time: ", "%.1f" % _elapsed_seconds, "s | Tier: ", current_tier)


func _process(delta: float) -> void:
	if not _tracking:
		return
	
	_elapsed_seconds += delta
	Global.elapsed_seconds = _elapsed_seconds
	
	# Kiểm tra leo tier
	for tier in [4, 3, 2, 1]:
		if _elapsed_seconds >= TIER_THRESHOLDS[tier] and current_tier < tier:
			_set_tier(tier)
			break

func _set_tier(new_tier: int) -> void:
	if new_tier == current_tier:
		return
	current_tier = new_tier
	Global.global_distortion_level = new_tier
	print("[DistortionController] Tier → ", new_tier, " at ", "%.1f" % _elapsed_seconds, "s")
	tier_changed.emit(new_tier)
	
	# Cập nhật ambient texture khi đổi tier
	AudioManager.set_ambient_tier(new_tier)
	
	# Mở phòng theo tier
	RoomGateManager.check_tier_unlocks(new_tier)

# ─── REQUEST EVENT ─────────────────────────────────────────────────────────────
## Scene/trigger gọi hàm này để "đề xuất" một sự kiện.
## Controller quyết định có chấp nhận không (dựa vào tier, cooldown).
## Trả về event_id đã chọn, hoặc "" nếu từ chối.
func request_event(min_tier: int = -1, max_tier: int = -1) -> String:
	# Nếu không chỉ định tier, dùng tier hiện tại
	if min_tier < 0:
		min_tier = current_tier
	if max_tier < 0:
		max_tier = current_tier
	
	# Kiểm tra cooldown toàn cục
	if _elapsed_seconds - _last_any_event < COOLDOWN_ANY_EVENT:
		return ""
	
	# Chọn tier phù hợp (không vượt quá tier hiện tại)
	var effective_tier = clampi(current_tier, min_tier, max_tier)
	if effective_tier == 0:
		return ""  # Tier 0 = không có event
	
	var event_id = _select_event(effective_tier)
	if event_id == "":
		return ""
	
	# Ghi nhận và phát signal
	_event_cooldowns[event_id] = _elapsed_seconds
	_last_any_event = _elapsed_seconds
	Global.distortion_events_count += 1
	
	print("[DistortionController] Event: '", event_id, "' (Tier ", effective_tier, ") at ", "%.1f" % _elapsed_seconds, "s")
	event_triggered.emit(event_id, effective_tier)
	return event_id

## Chọn event ngẫu nhiên có trọng số từ pool của tier, tôn trọng cooldown riêng
func _select_event(tier: int) -> String:
	if not EVENT_POOL.has(tier):
		return ""
	
	var pool: Array = EVENT_POOL[tier]
	var available: Array = []
	var total_weight: int = 0
	
	for entry in pool:
		var last = _event_cooldowns.get(entry["id"], -999.0)
		if _elapsed_seconds - last >= COOLDOWN_PER_EVENT:
			available.append(entry)
			total_weight += entry["weight"]
	
	if available.is_empty():
		return ""
	
	# Weighted random
	var roll = randi_range(0, total_weight - 1)
	var cumulative = 0
	for entry in available:
		cumulative += entry["weight"]
		if roll < cumulative:
			return entry["id"]
	
	return available[-1]["id"]

# ─── ANCHOR FEEDBACK ──────────────────────────────────────────────────────────
## Gọi khi player chủ động quan sát anchor object — fix Testarossa Drop #2
func notify_anchor_observed(anchor_id: String, observed_count: int) -> void:
	print("[DistortionController] Anchor '", anchor_id, "' observed x", observed_count)
	if observed_count >= 2:
		# Phản hồi nhỏ để xác nhận "hệ thống ghi nhận hành vi của bạn"
		AudioManager.play_sfx_placeholder("anchor_feedback_ping")
		if observed_count == 2:
			# Lần 2 quan sát: gợi ý nhẹ rằng có gì đó đã thay đổi
			await get_tree().create_timer(0.3).timeout
			Narrative.show_message("Có gì đó... không như tớ nhớ.", 2.5)

## Gọi khi player tương tác với vật quan trọng (diary, note, v.v.)
func notify_major_interaction(interaction_id: String) -> void:
	print("[DistortionController] Major interaction: ", interaction_id)
	# Tương tác lớn tăng tốc leo tier
	match interaction_id:
		"diary_read":
			# Đọc nhật ký → jump lên tier 2 ngay nếu chưa tới
			if current_tier < 2:
				_elapsed_seconds = max(_elapsed_seconds, TIER_THRESHOLDS[2])
		"study_notes_read":
			# Đọc ghi chú phòng làm việc → mở thêm phòng
			RoomGateManager.unlock_room("bedroom_main")

# ─── PAUSE / RESUME ───────────────────────────────────────────────────────────
func pause_tracking() -> void:
	_tracking = false

func resume_tracking() -> void:
	_tracking = true

func get_elapsed_minutes() -> float:
	return _elapsed_seconds / 60.0
