extends Node

enum States {idle, new, old}

var state = States.idle

func change_State(newState):
	state = newState

func _process(_delta: float) -> void:
	match state:
		States.idle:
			Idle()
		States.new:
			New()
		States.old:
			Old()

func Idle():
	$"..".play("default")
	if Input.is_action_just_pressed("new"):
		change_State(States.new)
	elif Input.is_action_just_pressed("old"):
		change_State(States.old)
		
func New():
	$"..".play("new")
	await $"..".animation_finished
	change_State(States.idle)

func Old():
	$"..".play("old")
	await $"..".animation_finished
	change_State(States.idle)
