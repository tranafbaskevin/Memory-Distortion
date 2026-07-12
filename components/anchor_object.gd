## AnchorObject — Vật thể có thể quan sát nhiều lần
## Theo dõi số lần player chú ý tới nó.
## Lần quan sát thứ 2+: phát tín hiệu nhỏ xác nhận "hệ thống ghi nhận"
## Fix Testarossa Drop #2: player chủ động quay lại → được thưởng
class_name AnchorObject
extends Interactable

@export var anchor_id: String = ""     # ID duy nhất, dùng để track trong Global
@export var base_description: String = ""   # Lời thoại lần đầu nhìn
@export var changed_description: String = "" # Lời thoại khi quay lại và có gì khác

var _observed_count: int = 0

func _ready() -> void:
	super._ready()
	prompt_message = "Nhấn E để quan sát"
	dialogue_text = base_description if base_description != "" else dialogue_text
	
	# Khôi phục số lần đã quan sát từ save
	if Global.anchor_observations.has(anchor_id):
		_observed_count = Global.anchor_observations[anchor_id]

func _interact(_player: Node2D) -> void:
	_observed_count += 1
	
	# Lưu vào Global
	if anchor_id != "":
		Global.anchor_observations[anchor_id] = _observed_count
	
	# Thông báo cho DistortionController
	DistortionController.notify_anchor_observed(anchor_id, _observed_count)
	
	# Chọn lời thoại phù hợp
	if _observed_count == 1:
		if base_description != "":
			Narrative.show_message(base_description, 3.5)
	elif _observed_count == 2 and changed_description != "":
		Narrative.show_message(changed_description, 4.0)
		# Ánh sáng pulse nhẹ — "pulse" xác nhận có gì đó thay đổi ở đây
		_pulse_feedback()
	else:
		# Lần 3+: im lặng là đáng sợ nhất
		Narrative.show_message("...", 1.5)
	
	print("[AnchorObject] '", anchor_id, "' observed x", _observed_count)

## Hiệu ứng pulse nhỏ — không muốn quá rõ ràng, chỉ đủ để xác nhận
func _pulse_feedback() -> void:
	AudioManager.play_sfx_placeholder("anchor_feedback_ping")
	# Modulate bản thân (nếu có Sprite) sáng lên rồi tắt
	if has_node("Sprite2D"):
		var sprite = get_node("Sprite2D")
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(1.5, 1.5, 1.5, 1), 0.15)
		tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.4)
