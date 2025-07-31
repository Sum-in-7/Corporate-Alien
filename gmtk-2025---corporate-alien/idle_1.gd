extends Sprite2D

var screen_size # Size of the game window.

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("remember") or Input.is_action_just_pressed("new"):
		$".".visible = false
		$Hit1.visible = true
	
