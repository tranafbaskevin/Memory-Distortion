extends Area2D

# Đường dẫn đến scene hành lang của tầng khác
@export_file("*.tscn") var target_scene: String
# Tên Marker2D ở hành lang tầng tiếp theo để spawn Player
@export var target_spawn_name: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if target_scene != "":
			# Thiết lập điểm spawn tiếp theo trong Global autoload
			Global.player_spawn_name = target_spawn_name
			print("Stair Transition Triggered! Moving to: ", target_scene, " (Spawn: ", target_spawn_name, ")")
			
			# GHI CHÚ: Nơi này có thể phát nhạc leo thang hoặc chạy hiệu ứng Fade-out màn hình ở Phase sau
			
			# Tiến hành chuyển Scene
			get_tree().change_scene_to_file(target_scene)
		else:
			print("Warning: target_scene is empty on stairs: ", name)
