## RoomGateManager — Quản lý hệ thống mở phòng semi-open
## Mỗi phòng có trạng thái: locked / foreshadow / unlocked
## "foreshadow" = cửa vẫn khoá nhưng có âm thanh / ánh sáng gợi ý
## "unlocked" = player có thể vào bình thường
extends Node

enum RoomState { LOCKED, FORESHADOW, UNLOCKED }

# Trạng thái ban đầu của từng phòng
# Chú ý: "foreshadow" là trạng thái quan trọng — phòng chưa mở nhưng "có ý nghĩa"
var room_states: Dictionary = {
	# Tầng 1 — mở từ đầu
	"kitchen":         RoomState.UNLOCKED,
	"living_room":     RoomState.UNLOCKED,
	"toilet_f1":       RoomState.UNLOCKED,

	# Tầng 2 — chỉ phòng làm việc mở (gating theo Testarossa)
	"study_room":      RoomState.UNLOCKED,
	"bedroom_main":    RoomState.FORESHADOW,   # Tiếng động sau cửa, mở sau khi đọc study notes
	"bedroom_sibling": RoomState.FORESHADOW,   # Mờ ánh sáng dưới cửa, mở ở Tier 2
	"bedroom_parents": RoomState.LOCKED,       # Hoàn toàn im lặng, mở ở Tier 3
	"toilet_f2":       RoomState.FORESHADOW,   # Tiếng nước nhỏ giọt, mở ở Tier 2
}

# Điều kiện mở theo Tier
const TIER_UNLOCKS: Dictionary = {
	2: ["bedroom_sibling", "toilet_f2"],
	3: ["bedroom_parents"],
}

signal room_state_changed(room_id: String, new_state: RoomState)

func _ready() -> void:
	# Kết nối với DistortionController
	DistortionController.tier_changed.connect(_on_tier_changed)
	restore_from_save()
	print("[RoomGateManager] Initialized. F2 gating active.")


func _on_tier_changed(new_tier: int) -> void:
	check_tier_unlocks(new_tier)

func check_tier_unlocks(tier: int) -> void:
	if TIER_UNLOCKS.has(tier):
		for room_id in TIER_UNLOCKS[tier]:
			if get_room_state(room_id) != RoomState.UNLOCKED:
				unlock_room(room_id)

# ─── API ────────────────────────────────────────────────────────────────────
func get_room_state(room_id: String) -> RoomState:
	if room_states.has(room_id):
		return room_states[room_id]
	return RoomState.UNLOCKED  # Không biết → coi là mở

func unlock_room(room_id: String) -> void:
	if not room_states.has(room_id):
		return
	if room_states[room_id] == RoomState.UNLOCKED:
		return
	room_states[room_id] = RoomState.UNLOCKED
	print("[RoomGateManager] Room unlocked: ", room_id)
	room_state_changed.emit(room_id, RoomState.UNLOCKED)
	
	# Lưu vào Global để SaveSystem nhớ
	if not Global.unlocked_rooms.has(room_id):
		Global.unlocked_rooms[room_id] = true

func is_unlocked(room_id: String) -> bool:
	return get_room_state(room_id) == RoomState.UNLOCKED

func is_foreshadow(room_id: String) -> bool:
	return get_room_state(room_id) == RoomState.FORESHADOW

## Khi load save, khôi phục trạng thái đã lưu
func restore_from_save() -> void:
	for room_id in Global.unlocked_rooms:
		if Global.unlocked_rooms[room_id]:
			room_states[room_id] = RoomState.UNLOCKED
	print("[RoomGateManager] Restored from save.")
