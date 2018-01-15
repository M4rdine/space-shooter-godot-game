extends CanvasLayer


signal restart_requested
signal quit_requested

@onready var panel: PanelContainer = $Panel
@onready var vbox: VBoxContainer = $Panel/VBoxContainer
@onready var game_over_label: Label = $Panel/VBoxContainer/GameOverLabel
@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var wave_label: Label = $Panel/VBoxContainer/WaveLabel
@onready var separator: HSeparator = $Panel/VBoxContainer/HSeparator
@onready var restart_btn: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_btn: Button = $Panel/VBoxContainer/QuitButton

var _stats_container: VBoxContainer = null

# Grade label (inserted between title and score)
var _grade_label: Label = null
# Contextual message label
var _message_label: Label = null
# Weapon build container
var _weapon_build_container: VBoxContainer = null

# Score counting animation
var animating_score: bool = false
var display_score: float = 0.0
var target_score: int = 0
var anim_delay: float = 0.0
var _score_value_label: Label = null  # reference to the score number label for animation
var _is_victory: bool = false


func _ready():
	hide()
	_style_panel()
	_style_game_over_label()
	_style_score_label()
	_style_wave_label()
	_style_separator()
	_style_restart_button()
	_style_quit_button()

	if restart_btn:
		restart_btn.pressed.connect(_on_restart)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)


func _process(delta: float):
	if not animating_score:
		return

	if anim_delay > 0.0:
		anim_delay -= delta
		return

	# Count up score
	var increment: float = target_score / 60.0
	if increment < 1.0:
		increment = 1.0
	display_score += increment
	if display_score >= target_score:
		display_score = target_score
		animating_score = false

	if _score_value_label and is_instance_valid(_score_value_label):
		_score_value_label.text = str(int(display_score))


func show_game_over(score: int, wave: int, extra: Dictionary = {}):
	_is_victory = false
	# Clean up previously created dynamic groups
	_cleanup_dynamic_groups()

	# -- Grade --
	var grade = _calculate_grade(score, wave)
	_show_grade(grade)

	# -- Contextual message --
	var msg = _get_contextual_message(wave, score)
	_show_contextual_message(msg)

	# -- Score section with animation --
	if score_label:
		score_label.text = ""
		_replace_with_stat_pair(score_label, "SCORE", "0", 8, 14,
			Color(0.6, 0.6, 0.6), Color(1.0, 1.0, 1.0))
	_start_score_animation(score)

	# -- Wave section --
	if wave_label:
		wave_label.text = ""
		_replace_with_stat_pair(wave_label, "WAVE REACHED", str(wave), 8, 12,
			Color(0.6, 0.6, 0.6), Color(1.0, 0.85, 0.3))

	# -- Extra stats --
	_clear_stats_container()
	if extra.size() > 0:
		_build_stats_grid(extra)

	show()


# ---------------------------------------------------------------------------
# Score Grade System
# ---------------------------------------------------------------------------

func _calculate_grade(score: int, wave: int) -> String:
	if score >= 80000 or wave >= 15:
		return "S"
	elif score >= 50000 or wave >= 12:
		return "A"
	elif score >= 30000 or wave >= 9:
		return "B"
	elif score >= 15000 or wave >= 6:
		return "C"
	else:
		return "D"


func _get_grade_color(grade: String) -> Color:
	match grade:
		"S": return Color(1.0, 0.85, 0.2)
		"A": return Color(0.3, 1.0, 0.3)
		"B": return Color(0.3, 0.8, 1.0)
		"C": return Color(0.7, 0.7, 0.7)
		"D": return Color(0.4, 0.4, 0.4)
		_: return Color(0.4, 0.4, 0.4)


func _get_grade_size(grade: String) -> int:
	match grade:
		"S": return 24
		"A": return 22
		"B": return 20
		"C": return 18
		"D": return 18
		_: return 18


func _show_grade(grade: String):
	# Remove old grade label if any
	if _grade_label and is_instance_valid(_grade_label):
		_grade_label.queue_free()
		_grade_label = null

	if not vbox or not game_over_label:
		return

	_grade_label = Label.new()
	_grade_label.name = "GradeLabelGroup"
	_grade_label.text = grade
	_grade_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_grade_label.add_theme_font_size_override("font_size", _get_grade_size(grade))
	_grade_label.add_theme_color_override("font_color", _get_grade_color(grade))
	_grade_label.add_theme_constant_override("outline_size", 3)
	_grade_label.add_theme_color_override("font_outline_color", Color(_get_grade_color(grade).r * 0.3, _get_grade_color(grade).g * 0.3, _get_grade_color(grade).b * 0.3))
	_grade_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Insert right after the game over label
	var title_idx = game_over_label.get_index()
	vbox.add_child(_grade_label)
	vbox.move_child(_grade_label, title_idx + 1)


# ---------------------------------------------------------------------------
# Contextual Messages
# ---------------------------------------------------------------------------

func _get_contextual_message(wave: int, _score: int) -> String:
	if _is_victory:
		return "The galaxy is safe... for now."
	if wave <= 2:
		return "The void is unforgiving..."
	elif wave <= 5:
		return "A promising start. Keep fighting!"
	elif wave <= 8:
		return "You're getting stronger, pilot."
	elif wave <= 11:
		return "So close! The final boss awaits..."
	else:
		return "An impressive run, Commander!"


func _show_contextual_message(msg: String):
	# Remove old message label if any
	if _message_label and is_instance_valid(_message_label):
		_message_label.queue_free()
		_message_label = null

	if not vbox:
		return

	_message_label = Label.new()
	_message_label.name = "MessageLabelGroup"
	_message_label.text = msg
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_font_size_override("font_size", 8)
	_message_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 0.8))
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Insert after grade label (which is after game_over_label)
	var insert_idx = game_over_label.get_index() + 1
	if _grade_label and is_instance_valid(_grade_label):
		insert_idx = _grade_label.get_index() + 1
	vbox.add_child(_message_label)
	vbox.move_child(_message_label, insert_idx)


# ---------------------------------------------------------------------------
# Score Counting Animation
# ---------------------------------------------------------------------------

func _start_score_animation(score: int):
	target_score = score
	display_score = 0.0
	anim_delay = 0.3
	animating_score = true

	# Find the score value label we just created (second child in the ScoreLabelGroup)
	_score_value_label = null
	if vbox:
		for child in vbox.get_children():
			if child.name == "ScoreLabelGroup" and child is VBoxContainer:
				if child.get_child_count() >= 2:
					_score_value_label = child.get_child(1)
				break


# ---------------------------------------------------------------------------
# Weapon Build Showcase
# ---------------------------------------------------------------------------

func show_weapon_build(weapon_manager: Node):
	# Remove old weapon build container
	if _weapon_build_container and is_instance_valid(_weapon_build_container):
		_weapon_build_container.queue_free()
		_weapon_build_container = null

	if not weapon_manager or not vbox:
		return

	var ids = weapon_manager.get_active_weapon_ids()
	if ids.size() == 0:
		return

	_weapon_build_container = VBoxContainer.new()
	_weapon_build_container.name = "WeaponBuildGroup"
	_weapon_build_container.add_theme_constant_override("separation", 4)
	_weapon_build_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# "YOUR BUILD" header
	var build_header = Label.new()
	build_header.text = "YOUR BUILD"
	build_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	build_header.add_theme_font_size_override("font_size", 7)
	build_header.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
	_weapon_build_container.add_child(build_header)

	# Horizontal row of weapon icons
	var icon_row = HBoxContainer.new()
	icon_row.add_theme_constant_override("separation", 3)
	icon_row.alignment = BoxContainer.ALIGNMENT_CENTER
	icon_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_weapon_build_container.add_child(icon_row)

	for id in ids:
		var level = weapon_manager.get_weapon_level(id)
		var evolved = weapon_manager.is_weapon_evolved(id)
		var data = WeaponRegistry.get_weapon(id)
		var icon = _create_weapon_icon(data, level, evolved)
		icon_row.add_child(icon)

	# Insert before buttons (above restart button)
	var restart_idx = restart_btn.get_index() if restart_btn else vbox.get_child_count()
	vbox.add_child(_weapon_build_container)
	vbox.move_child(_weapon_build_container, restart_idx)


func _create_weapon_icon(data: Dictionary, level: int, evolved: bool) -> Control:
	var container = PanelContainer.new()
	container.custom_minimum_size = Vector2(40, 30)

	var glow: Color = data.get("glow_color", Color.WHITE)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(glow.r * 0.2, glow.g * 0.2, glow.b * 0.2, 0.9)
	if evolved:
		style.border_color = Color(1.0, 0.85, 0.2)
		style.set_border_width_all(2)
	else:
		style.border_color = glow
		style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 2
	style.content_margin_right = 2
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	container.add_theme_stylebox_override("panel", style)

	var icon_vbox = VBoxContainer.new()
	icon_vbox.add_theme_constant_override("separation", 0)
	icon_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_child(icon_vbox)

	# Procedural weapon icon via _draw()
	var icon_draw = Control.new()
	icon_draw.set_script(preload("res://scripts/ui/weapon_icon_draw.gd"))
	icon_draw.setup(data.get("id", ""), glow, evolved)
	icon_vbox.add_child(icon_draw)

	# Level indicator as dots
	var lv_label = Label.new()
	if evolved:
		lv_label.text = "\u2605MAX"
		lv_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	else:
		var max_level: int = data.get("max_level", 5)
		var dots: String = ""
		for i in range(max_level):
			dots += "\u25cf" if i < level else "\u25cb"
		lv_label.text = dots
		lv_label.add_theme_color_override("font_color", glow)
	lv_label.add_theme_font_size_override("font_size", 5)
	lv_label.add_theme_constant_override("outline_size", 1)
	lv_label.add_theme_color_override("font_outline_color", Color.BLACK)
	lv_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_vbox.add_child(lv_label)

	return container


# ---------------------------------------------------------------------------
# Styling helpers
# ---------------------------------------------------------------------------

func _style_panel():
	if not panel:
		return
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.02, 0.02, 0.06, 0.94)
	sb.border_color = Color(0.15, 0.4, 0.7, 0.5)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", sb)


func _style_game_over_label():
	if not game_over_label:
		return
	game_over_label.add_theme_font_size_override("font_size", 18)
	game_over_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	game_over_label.add_theme_color_override("font_outline_color", Color(0.3, 0.0, 0.0))
	game_over_label.add_theme_constant_override("outline_size", 3)
	game_over_label.text = "GAME OVER"


func _style_score_label():
	if not score_label:
		return
	# Defaults cleared; real content set in show_game_over
	score_label.add_theme_font_size_override("font_size", 14)
	score_label.add_theme_color_override("font_color", Color(1, 1, 1))


func _style_wave_label():
	if not wave_label:
		return
	wave_label.add_theme_font_size_override("font_size", 12)
	wave_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))


func _style_separator():
	if not separator:
		return
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.15)
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	sb.content_margin_left = 40
	sb.content_margin_right = 40
	separator.add_theme_stylebox_override("separator", sb)


func _style_restart_button():
	if not restart_btn:
		return
	restart_btn.add_theme_font_size_override("font_size", 10)
	restart_btn.add_theme_color_override("font_color", Color(1, 1, 1))
	restart_btn.custom_minimum_size.x = 200
	restart_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	# Normal state
	var sb_normal := StyleBoxFlat.new()
	sb_normal.bg_color = Color(0.05, 0.15, 0.25, 0.9)
	sb_normal.border_color = Color(0.3, 0.7, 1.0, 0.6)
	sb_normal.set_border_width_all(1)
	sb_normal.set_corner_radius_all(3)
	sb_normal.set_content_margin_all(6)
	restart_btn.add_theme_stylebox_override("normal", sb_normal)

	# Hover
	var sb_hover := sb_normal.duplicate()
	sb_hover.bg_color = Color(0.08, 0.2, 0.35, 0.95)
	sb_hover.border_color = Color(0.4, 0.8, 1.0, 0.9)
	restart_btn.add_theme_stylebox_override("hover", sb_hover)

	# Pressed
	var sb_pressed := sb_normal.duplicate()
	sb_pressed.bg_color = Color(0.03, 0.1, 0.2, 1.0)
	restart_btn.add_theme_stylebox_override("pressed", sb_pressed)

	# Focus
	var sb_focus := sb_normal.duplicate()
	sb_focus.border_color = Color(0.3, 0.7, 1.0, 0.7)
	restart_btn.add_theme_stylebox_override("focus", sb_focus)


func _style_quit_button():
	if not quit_btn:
		return
	quit_btn.add_theme_font_size_override("font_size", 9)
	quit_btn.add_theme_color_override("font_color", Color(1, 1, 1))
	quit_btn.custom_minimum_size.x = 160
	quit_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	# Normal state
	var sb_normal := StyleBoxFlat.new()
	sb_normal.bg_color = Color(0.18, 0.06, 0.08, 0.9)
	sb_normal.border_color = Color(0.7, 0.3, 0.35, 0.5)
	sb_normal.set_border_width_all(1)
	sb_normal.set_corner_radius_all(3)
	sb_normal.set_content_margin_all(5)
	quit_btn.add_theme_stylebox_override("normal", sb_normal)

	# Hover
	var sb_hover := sb_normal.duplicate()
	sb_hover.bg_color = Color(0.25, 0.08, 0.1, 0.95)
	sb_hover.border_color = Color(0.85, 0.4, 0.45, 0.8)
	quit_btn.add_theme_stylebox_override("hover", sb_hover)

	# Pressed
	var sb_pressed := sb_normal.duplicate()
	sb_pressed.bg_color = Color(0.12, 0.04, 0.05, 1.0)
	quit_btn.add_theme_stylebox_override("pressed", sb_pressed)

	# Focus
	var sb_focus := sb_normal.duplicate()
	sb_focus.border_color = Color(0.7, 0.3, 0.35, 0.7)
	quit_btn.add_theme_stylebox_override("focus", sb_focus)


# ---------------------------------------------------------------------------
# Dynamic content builders
# ---------------------------------------------------------------------------

func _cleanup_dynamic_groups():
	# Stop any running score animation
	animating_score = false
	_score_value_label = null

	# Remove any previously created "Group" VBoxContainers / Labels
	# Use free() instead of queue_free() so nodes are removed immediately
	# and don't interfere with newly created nodes of the same name.
	if vbox:
		var to_remove: Array = []
		for child in vbox.get_children():
			if child.name.ends_with("Group"):
				to_remove.append(child)
		for child in to_remove:
			child.get_parent().remove_child(child)
			child.queue_free()

	# Clean up grade label
	if _grade_label and is_instance_valid(_grade_label):
		_grade_label.queue_free()
		_grade_label = null

	# Clean up message label
	if _message_label and is_instance_valid(_message_label):
		_message_label.queue_free()
		_message_label = null

	# Clean up weapon build
	if _weapon_build_container and is_instance_valid(_weapon_build_container):
		_weapon_build_container.queue_free()
		_weapon_build_container = null

	# Re-show the original labels
	if score_label:
		score_label.visible = true
	if wave_label:
		wave_label.visible = true


func _replace_with_stat_pair(
	placeholder: Label,
	header_text: String,
	value_text: String,
	header_size: int,
	value_size: int,
	header_color: Color,
	value_color: Color
):
	# Hide the original label and insert a small VBox right after it
	var parent := placeholder.get_parent()
	var idx := placeholder.get_index()
	placeholder.visible = false

	var container := VBoxContainer.new()
	container.name = placeholder.name + "Group"
	container.add_theme_constant_override("separation", 1)
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var lbl_header := Label.new()
	lbl_header.text = header_text
	lbl_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_header.add_theme_font_size_override("font_size", header_size)
	lbl_header.add_theme_color_override("font_color", header_color)
	container.add_child(lbl_header)

	var lbl_value := Label.new()
	lbl_value.text = value_text
	lbl_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_value.add_theme_font_size_override("font_size", value_size)
	lbl_value.add_theme_color_override("font_color", value_color)
	container.add_child(lbl_value)

	parent.add_child(container)
	parent.move_child(container, idx + 1)


func _clear_stats_container():
	if _stats_container and is_instance_valid(_stats_container):
		_stats_container.queue_free()
		_stats_container = null


func _build_stats_grid(extra: Dictionary):
	var parent := separator.get_parent()
	var sep_idx := separator.get_index()

	_stats_container = VBoxContainer.new()
	_stats_container.name = "StatsContainer"
	_stats_container.add_theme_constant_override("separation", 4)
	_stats_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Map of recognized stat keys to display names
	var stat_labels := {
		"enemies_killed": "ENEMIES KILLED",
		"graze_count": "GRAZES",
		"accuracy": "ACCURACY",
		"time_survived": "TIME SURVIVED",
		"powerups_collected": "POWER-UPS",
		"max_combo": "MAX COMBO",
		"bosses_defeated": "BOSSES DEFEATED",
		"damage_dealt": "DAMAGE DEALT",
		"shots_fired": "SHOTS FIRED",
	}

	for key in extra:
		var display_name: String = stat_labels.get(key, key.to_upper().replace("_", " "))
		var value = extra[key]
		var value_str: String

		if value is float:
			if key == "accuracy":
				value_str = "%.1f%%" % (value * 100.0) if value <= 1.0 else "%.1f%%" % value
			elif key == "time_survived":
				var mins := int(value) / 60
				var secs := int(value) % 60
				value_str = "%d:%02d" % [mins, secs]
			else:
				value_str = "%.1f" % value
		else:
			value_str = str(value)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.alignment = BoxContainer.ALIGNMENT_CENTER

		var lbl_name := Label.new()
		lbl_name.text = display_name
		lbl_name.add_theme_font_size_override("font_size", 7)
		lbl_name.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
		lbl_name.custom_minimum_size.x = 100
		lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(lbl_name)

		var lbl_val := Label.new()
		lbl_val.text = value_str
		lbl_val.add_theme_font_size_override("font_size", 8)
		lbl_val.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		lbl_val.custom_minimum_size.x = 60
		lbl_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.add_child(lbl_val)

		_stats_container.add_child(row)

	# Insert after the separator
	parent.add_child(_stats_container)
	parent.move_child(_stats_container, sep_idx + 1)


func show_victory(score: int, wave: int, extra: Dictionary = {}):
	_is_victory = true
	_cleanup_dynamic_groups()

	# Change title to VICTORY
	if game_over_label:
		game_over_label.text = "VICTORY!"
		game_over_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		game_over_label.add_theme_color_override("font_outline_color", Color(0.4, 0.3, 0.0))

	# -- Grade --
	var grade = _calculate_grade(score, wave)
	_show_grade(grade)

	# -- Contextual message --
	var msg = _get_contextual_message(wave, score)
	_show_contextual_message(msg)

	# -- Score with animation --
	if score_label:
		score_label.text = ""
		_replace_with_stat_pair(score_label, "FINAL SCORE", "0", 8, 14,
			Color(0.6, 0.6, 0.6), Color(1.0, 1.0, 1.0))
	_start_score_animation(score)

	if wave_label:
		wave_label.text = ""
		_replace_with_stat_pair(wave_label, "WAVES SURVIVED", str(wave), 8, 12,
			Color(0.6, 0.6, 0.6), Color(1.0, 0.85, 0.3))

	_clear_stats_container()
	if extra.size() > 0:
		_build_stats_grid(extra)

	# Style panel with gold tint for victory
	if panel:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.04, 0.04, 0.02, 0.94)
		sb.border_color = Color(0.7, 0.6, 0.2, 0.6)
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(4)
		panel.add_theme_stylebox_override("panel", sb)

	show()


# ---------------------------------------------------------------------------
# Button callbacks
# ---------------------------------------------------------------------------

func _on_restart():
	hide()
	animating_score = false
	# Reset title style for next game
	if game_over_label:
		game_over_label.text = "GAME OVER"
		game_over_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		game_over_label.add_theme_color_override("font_outline_color", Color(0.3, 0.0, 0.0))
	_style_panel()
	restart_requested.emit()


func _on_quit():
	hide()
	animating_score = false
	quit_requested.emit()
