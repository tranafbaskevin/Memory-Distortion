# Audio Assets — Memory Distortion
# Thư mục này chứa tất cả file âm thanh của game.
# Khi có file thật (.ogg), đặt vào đây và cập nhật AudioManager.

# ─── AMBIENT TRACKS ───────────────────────────────────────────────
# ambient_house.ogg      → Âm nền căn nhà yên tĩnh (loop nhẹ, 30-60s)
# ambient_distorted.ogg  → Âm nền khi đã distorted (tone lạ, reverb nặng)
# ambient_bedroom.ogg    → Tiếng im lặng bất thường trong phòng ngủ

# ─── SFX TRACKS ───────────────────────────────────────────────────
# door_open.ogg          → Tiếng cửa mở (dùng khi chuyển scene)
# door_locked.ogg        → Tiếng cửa kẹt / bị khoá
# footstep_wood.ogg      → Tiếng bước chân trên sàn gỗ
# hallway_creak.ogg      → Tiếng kẽo kẹt hành lang
# whisper_01.ogg         → Tiếng thì thầm (giọng nhẹ, khó nghe rõ)
# page_turn_eerie.ogg    → Tiếng lật trang nhật ký
# key_pickup.ogg         → Tiếng nhặt chìa khoá
# tv_static.ogg          → Tiếng nhiễu tivi
# flicker_sound.ogg      → Tiếng đèn nhấp nháy
# distortion_sting.ogg   → Âm thanh ngắn khi distortion xảy ra

# ─── HOW TO INJECT ────────────────────────────────────────────────
# Thay thế placeholder bằng:
#   AudioManager.play_sfx(preload("res://audio/whisper_01.ogg"))
#   AudioManager.play_ambient(preload("res://audio/ambient_house.ogg"))
