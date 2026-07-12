extends Interactable

# Xuất ra đường dẫn file của Scene muốn chuyển tới
@export_file("*.tscn") var target_scene: String
# Tên của Node Marker2D tại Scene tiếp theo nơi Player sẽ xuất hiện
@export var target_spawn_name: String = ""

func _ready() -> void:
	# Gọi hàm ready của lớp cha (Interactable) để đăng ký nhóm tương tác
	super._ready()
	# Nếu dùng prompt mặc định thì đổi thành mở cửa
	if prompt_message == "Nhấn E để tương tác":
		prompt_message = "Nhấn E để mở cửa"

# Ghi đè hàm ảo _interact của Interactable
func _interact(_player: Node2D) -> void:
	if target_scene != "":
		# Thiết lập điểm spawn tiếp theo trong Global autoload
		Global.player_spawn_name = target_spawn_name
		print("Door opened! Transitioning to: ", target_scene, " (Spawn Marker: ", target_spawn_name, ")")
		
		# Chuyển Scene
		get_tree().change_scene_to_file(target_scene)
	else:
		print("Warning: target_scene is empty on door: ", name)
