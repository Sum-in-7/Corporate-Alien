extends AnimatedSprite2D


func _on_rhythm_notifier_beat_one(_current_beat: int) -> void:
	$".".play("default")
func _on_rhythm_notifier_beat_two(_current_beat: int) -> void:
	$".".play("default")
func _on_rhythm_notifier_beat_three(_current_beat: int) -> void:
	$".".play("default")
