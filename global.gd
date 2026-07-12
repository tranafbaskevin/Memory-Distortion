extends Node

# Biến toàn cục lưu tên vị trí Marker2D mà Player cần dịch chuyển tới sau khi chuyển scene
var player_spawn_name: String = ""
var bedroom_distorted: bool = false
var room_visits: Dictionary = {}

# ─── GAMEPLAY STATE ───────────────────────────────────────────────────────────
## Người chơi đang giữ chìa khoá không?
var player_has_key: bool = false
## Đếm tổng sự kiện distortion đã xảy ra
var distortion_events_count: int = 0
