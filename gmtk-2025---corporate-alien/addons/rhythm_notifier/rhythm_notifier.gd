@tool
@icon("icon.svg")
class_name RhythmNotifier
extends Node

signal beatFour(current_beat:int)
signal beatOne(current_beat:int)
signal beatTwo(current_beat:int)
signal beatThree(current_beat:int)
signal fourAnd(current_beat:int)

class _Rhythm:

	signal interval_changed(current_interval: int)

	var repeating: bool
	var beat_count: float
	var start_beat: float
	var last_frame_interval
	

	func _init(_repeating, _beat_count, _start_beat):
		repeating = _repeating
		beat_count = _beat_count
		start_beat = _start_beat
		

	const TOO_LATE = .1 # This long after interval starts, we are too late to emit
	# We pass secs_per_beat so user can change bpm any time
	func emit_if_needed(position: float, secs_per_beat: float) -> void:
		var interval_secs = beat_count * secs_per_beat
		var current_interval = int(floor((position - start_beat) / interval_secs))
		var secs_past_interval = fmod(position - start_beat, interval_secs)
		var valid_interval = current_interval > 0 and (repeating or current_interval == 1)
		var too_late = secs_past_interval >= TOO_LATE
		if not valid_interval or too_late:
			last_frame_interval = null
		elif last_frame_interval != current_interval:
			interval_changed.emit(current_interval)
			last_frame_interval = current_interval


## Emitted once per beat, excluding beat 0.  The [param current_beat] parameter
## is the value of [member RhythmNotifier.current_beat].
## [br][br][color=yellow]Note:[/color] This once-per-beat signal is a convenience to 
## allow connecting in the inspector, and is equivalent to [code]beats(1.0)[/code]. For
## other signal frequencies, use [method beats].
signal beat(current_beat: int)

## Beats per minute.  Changing this value changes [member beat_length].
## [br][br]This value can be changed while [member running] is true.
@export var bpm: float = 60.0:
	set(val):
		if val == 0: return
		bpm = val
		notify_property_list_changed()

## Length of one beat in seconds.  Changing this value changes [member bpm].  It is usually more 
## precise to specify [member bpm] and let [member beat_length] be calculated automatically,
## because song tempos are often an integer bpm.
@export var beat_length: float = 1.0:
	get:
		return 60.0 / bpm
	set(val):
		if val == 0: return
		bpm = 60.0 / val

## Optional [AudioStreamPlayer] to synchronize signals with.  While [member audio_stream_player] is
## playing, [signal beat] and [method beats] signals will be emitted based on playback position.
## [br][br]See [member running] for emitting signals without an [AudioStreamPlayer].
@export var audio_stream_player: AudioStreamPlayer

## If [code]true[/code], [signal beat] and [method beats] signals are being emitted.  Can be set to
## [code]true[/code] to emit signals without playing a stream.  [member running] is always
## [code]true[/code] while [member audio_stream_player] is playing.
@export var running: bool:
	get: return _silent_running or _stream_is_playing()
	set(val):
		if val == running:
			return  # No change
		if _stream_is_playing():
			return  # Can't override
		_silent_running = val
		_position = 0.0

## The current beat, indexed from [code]0[/code].
var current_beat: int:
	get: return int(floor(_position / beat_length))
	
## The current position in seconds.  If [member audio_stream_player] is playing, this is the
## accurate number of seconds into the stream, and setting the value will seek to
## that position.  If the audio stream is not playing, this is the number of seconds
## that [member running] has been set to true, if any, and setting overrides the value.
var current_position: float:
	get: return _position
	set(val):
		if _stream_is_playing():
			audio_stream_player.seek(val)
		elif _silent_running:
			_position = val
var _position: float = 0.0
	
var _cached_output_latency: float:
	get:
		if Time.get_ticks_msec() >= _invalidate_cached_output_latency_by:
			# Cached because method is expensive per its docs
			_cached_output_latency = AudioServer.get_output_latency()
			_invalidate_cached_output_latency_by = Time.get_ticks_msec() + 1000
		return _cached_output_latency
var _invalidate_cached_output_latency_by := 0
var _silent_running: bool
var _rhythms: Array[_Rhythm] = []

func _ready():
	beats(4, true, -3.5).connect(beatOne.emit)
	beats(4, true, -2.65).connect(beatTwo.emit)
	beats(4, true, -1.75).connect(beatThree.emit)
	beats(3).connect(beatFour.emit)
	beats(3.5, true, 0).connect(fourAnd.emit)


# If not stopped, recalculate track position and emit any appropriate signals.
func _physics_process(delta):
	if _silent_running and _stream_is_playing():
		_silent_running = false
	if not running:
		return
	if _silent_running:
		_position += delta
	else:
		_position = audio_stream_player.get_playback_position()
		_position += AudioServer.get_time_since_last_mix() - _cached_output_latency
	if Engine.is_editor_hint():
		return
	for rhythm in _rhythms:
		rhythm.emit_if_needed(_position, beat_length)

func beats(beat_count: float, repeating := true, start_beat := 0.0) -> Signal:
	for rhythm in _rhythms:
		if (rhythm.beat_count == beat_count 
			and rhythm.repeating == repeating
			and rhythm.start_beat == start_beat):
			return rhythm.interval_changed
	var new_rhythm = _Rhythm.new(repeating, beat_count, start_beat)
	_rhythms.append(new_rhythm)
	return new_rhythm.interval_changed
	

func _stream_is_playing():
	return audio_stream_player != null and audio_stream_player.playing
