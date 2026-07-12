extends Interactable

# Xuất ra đường dẫn file của Scene muốn chuyển tới
@export_file("*.tscn") var target_scene: String
# Tên Marker2D ở hành lang tầng tiếp theo để spawn Player
@export var target_spawn_name: String = ""

func _ready() -> void:
	super._ready()
	if prompt_message == "Nhấn E để tương tác":
		prompt_message = "Nhấn E để leo cầu thang"

# Ghi đè hàm ảo _interact của Interactable
func _interact(_player: Node2D) -> void:
	if target_scene != "":
		Global.player_spawn_name = target_spawn_name
		print("Stair Transition! Moving to: ", target_scene, " (Spawn: ", target_spawn_name, ")")
		
		# GHI CHÚ: Nơi đây có thể chèn hiệu ứng âm thanh leo cầu thang / fade-out ở Phase sau

		get_tree().change_scene_to_file(target_scene)
	else:
		print("Warning: target_scene is empty on stairs: ", name)
