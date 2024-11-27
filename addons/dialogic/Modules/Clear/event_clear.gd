@tool
class_name DialogicClearEvent
extends DialogicEvent

## Event that clears audio & visuals (not variables).
## Useful to make sure the scene is clear for a completely new thing.

var time := 1.0
var step_by_step := true

var clear_textbox := true
var clear_portraits := true
var clear_style := true
var clear_music := true
var clear_portrait_positions := true
var clear_background := true
var clear_foreground := true
var clear_tint := true
var clear_weather := true
var clear_video := true

################################################################################
## 						EXECUTE
################################################################################

func _execute() -> void:
	var final_time := time

	if dialogic.Inputs.auto_skip.enabled:
		var time_per_event: float = dialogic.Inputs.auto_skip.time_per_event
		final_time = min(time, time_per_event)

	if clear_textbox and dialogic.has_subsystem("Text"):
		dialogic.Text.update_dialog_text('')
		dialogic.Text.hide_textbox()
		dialogic.current_state = dialogic.States.IDLE
		if step_by_step: await dialogic.get_tree().create_timer(final_time).timeout

	if clear_portraits and dialogic.has_subsystem('Portraits') and len(dialogic.Portraits.get_joined_characters()) != 0:
		if final_time == 0:
			dialogic.Portraits.leave_all_characters("Instant", final_time, step_by_step)
		else:
			dialogic.Portraits.leave_all_characters("", final_time, step_by_step)
		if step_by_step: await dialogic.get_tree().create_timer(final_time).timeout

	if clear_background and dialogic.has_subsystem('Backgrounds') and dialogic.Backgrounds.has_background():
		dialogic.Backgrounds.update_background('', '', final_time)
		if step_by_step: await dialogic.get_tree().create_timer(final_time).timeout

	if clear_foreground and dialogic.has_subsystem('Foregrounds') and dialogic.Foregrounds.has_foreground():
		dialogic.Foregrounds.update_foreground('', '', final_time)
		if step_by_step: await dialogic.get_tree().create_timer(final_time).timeout

	if clear_tint and dialogic.has_subsystem('Tint'):
		dialogic.Tint.update_tint({"red":0, "green":0, "blue":0, "grayscale":0}, final_time)
		dialogic.Tint.update_portrait_tint({"red":0, "green":0, "blue":0, "grayscale":0}, final_time)
		if step_by_step: await dialogic.get_tree().create_timer(final_time).timeout

	if clear_weather:
		var dict := {
			"command": "weather",
			"state": DialogicWeatherEvent.WeatherType.SUNNY,
			}
		dict.make_read_only()
		dialogic.emit_signal('signal_event', dict)
		if step_by_step: await dialogic.get_tree().create_timer(final_time).timeout

	if clear_music and dialogic.has_subsystem('Audio'):
		for channel_id in dialogic.Audio.max_channels:
			if dialogic.Audio.has_music(channel_id):
				dialogic.Audio.update_music('', 0.0, "", final_time, channel_id)
		if step_by_step: await dialogic.get_tree().create_timer(final_time).timeout

	if clear_video and dialogic.has_subsystem('Video'):
		## TODO - Add fade if/when fade is added to Video Subsystem
		dialogic.Video.update_video()
		if step_by_step: await dialogic.get_tree().create_timer(final_time).timeout

	if clear_style and dialogic.has_subsystem('Styles'):
		dialogic.Styles.change_style()

	if clear_portrait_positions and dialogic.has_subsystem('Portraits'):
		dialogic.PortraitContainers.reset_all_containers()

	if not step_by_step:
		await dialogic.get_tree().create_timer(final_time).timeout

	finish()


################################################################################
## 						INITIALIZE
################################################################################

func _init() -> void:
	event_name = "Clear"
	set_default_color('Color9')
	event_category = "Other"
	event_sorting_index = 2


################################################################################
## 						SAVING/LOADING
################################################################################

func get_shortcode() -> String:
	return "clear"


func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name : property_info
		"time"		: {"property": "time",	 			"default": ""},
		"step"		: {"property": "step_by_step", 		"default": true},
		"text"		: {"property": "clear_textbox",		"default": true},
		"portraits"	: {"property": "clear_portraits", 	"default": true},
		"music"		: {"property": "clear_music", 		"default": true},
		"background": {"property": "clear_background", 	"default": true},
		"foreground": {"property": "clear_foreground", 	"default": true},
		"tint"		: {"property": "clear_tint", 		"default": true},
		"weather"	: {"property": "clear_weather",		"default": true},
		"video"		: {"property": "clear_video",		"default": true},
		"positions"	: {"property": "clear_portrait_positions", 	"default": true},
		"style"		: {"property": "clear_style", 		"default": true},
	}


################################################################################
## 						EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Clear')

	add_body_edit('time', ValueType.NUMBER, {'left_text':'Time:'})

	add_body_edit('step_by_step', ValueType.BOOL, {'left_text':'Step by Step:'}, 'time > 0')
	add_body_line_break()

	add_body_edit('clear_textbox', ValueType.BOOL_BUTTON, {'left_text':'Clear:', 'icon':load("res://addons/dialogic/Modules/Clear/clear_textbox.svg"), 'tooltip':'Clear Textbox'})
	add_body_edit('clear_portraits', ValueType.BOOL_BUTTON, {'icon':load("res://addons/dialogic/Modules/Clear/clear_characters.svg"), 'tooltip':'Clear Portraits'})
	add_body_edit('clear_background', ValueType.BOOL_BUTTON, {'icon':load("res://addons/dialogic/Modules/Clear/clear_background.svg"), 'tooltip':'Clear Background'})
	add_body_edit('clear_foreground', ValueType.BOOL_BUTTON, {'icon':load("res://addons/dialogic/Modules/Clear/clear_background.svg"), 'tooltip':'Clear Foreground'})
	add_body_edit('clear_tint', ValueType.BOOL_BUTTON, {'icon':load("res://addons/dialogic/Modules/Clear/clear_background.svg"), 'tooltip':'Clear Tint'})
	add_body_edit('clear_weather', ValueType.BOOL_BUTTON, {'icon':load("res://addons/dialogic/Modules/Clear/clear_background.svg"), 'tooltip':'Clear Weather'})
	add_body_edit('clear_music', ValueType.BOOL_BUTTON, {'icon':load("res://addons/dialogic/Modules/Clear/clear_music.svg"), 'tooltip':'Clear Music'})
	add_body_edit('clear_video', ValueType.BOOL_BUTTON, {'icon':load("res://addons/dialogic/Modules/Clear/clear_music.svg"), 'tooltip':'Clear Video'})
	add_body_edit('clear_style', ValueType.BOOL_BUTTON, {'icon':load("res://addons/dialogic/Modules/Clear/clear_style.svg"), 'tooltip':'Clear Style'})
	add_body_edit('clear_portrait_positions', ValueType.BOOL_BUTTON, {'icon':load("res://addons/dialogic/Modules/Clear/clear_positions.svg"), 'tooltip':'Clear Portrait Positions'})
