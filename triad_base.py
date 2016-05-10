# # # base triad condition

instructions.setText(instructs)

instructions.draw()
win.flip()
core.wait(2)
event.waitKeys()

instructions.setText(init2_instructs)
instructions.draw()
win.flip()
event.waitKeys()

# Set up display
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
buttons     = []
button_text = []
button_pos  = [[0, 125], [-90, -125], [90, -125]]
fill_colors = [[1, 1, 1], init_button_color, init_button_color]
line_colors = [[-1, -1, -1], [1, 1, 1], [1, 1, 1]]

# Make buttons
for idx in range(0,3):
	# Buttons
	buttons.append(visual.Circle(win, radius = 75, fillColor = fill_colors[idx],
		lineColor = line_colors[idx], lineWidth = 3.0))
	buttons[idx].setPos(button_pos[idx])
	# Text labels
	button_text.append(visual.TextStim(win, text = '', height = text_size,
		font = text_font, color = font_color, pos = button_pos[idx]))

# Make other interface content
# adjust fix cross loc
fix_cross.setPos(button_pos[0])

# Conf button
conf_button = visual.Rect(win, width = 150, height = 75, fillColor = init_button_color,
		lineColor = [1, 1, 1], lineWidth = 2.0, pos = [0,-280])
conf_cover = visual.Rect(win, width = 153, height = 78, fillColor = window_color,
		lineColor = window_color, pos = [0,-280])
conf_text = visual.TextStim(win, text = 'CONFIRM', height = text_size + 4,
		font = text_font, color = font_color, pos = [0,-280])

# Trial instructs
trial_ins = [visual.TextStim(win, text = '', height = text_size + 4,
				wrapWidth = 900, font = text_font, color = font_color),
			visual.TextStim(win, text = '', height = text_size + 4,
				wrapWidth = 900, font = text_font, color = font_color)]

trial_ins[0].setText(trial_instructs_base1)
trial_ins[0].setPos([0, 250])

trial_ins[1].setPos([0,-245])
trial_ins[1].setText(trial_instructs_base2)

# Run Trials
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

for trial in trial_materials:
	idx_list = range(1,3)
	rnd.shuffle(idx_list)
	idx_list.insert(0, 0)

	trial_list = [trial[i] for i in idx_list]

	button_text[0].setText(trial[0])

	for idx in idx_list:
		button_text[idx_list.index(idx)].setText(trial[idx])

	[key_responses, all_responses, rts] = trial_mgr_base(win, cursor, timer, 
		buttons, button_text, trial_list, fix_cross, conf_button, conf_text, 
		conf_cover, trial_ins, init_button_color)	

	current_trial = [subject_number, cond_labels[condition - 1], 
		(trial_materials.index(trial) + 1), trial, trial[0], key_responses, ['BASE'],
		item_key[trial.index(key_responses[0])], sum(rts), all_responses, rts,
		idx_list]

	subject_data.append(current_trial)
	writefile(subject_file, subject_data, ',')


	print ''
	print [' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ']
	print ['   Trial Number: ', trial_materials.index(trial) + 1]
	print [' Trial Concepts: ', trial]
	print ['     All Clicks: ', all_responses]
	print ['        All RTs: ', rts]
	print [' Final Response: ', key_responses[0]]
	print ['Response 1 Type: ', 'BASE'] 
	print ['Response 2 Type: ', item_key[trial.index(key_responses[0])]]
	print [' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ']
	print ''

	for idx in range(1,3):
		buttons[idx].setFillColor(init_button_color)
		buttons[idx].setLineColor([1, 1, 1])