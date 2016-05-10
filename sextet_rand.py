# # # random sextet condition

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
button_pos  = [[-210,0],[-90,125],[90,125],[210,0],[90,-125],[-90,-125]]

# Make buttons
for idx in range(0,6):
	# Buttons
	buttons.append(visual.Circle(win, radius = 75, fillColor = init_button_color,
		lineColor = [1, 1, 1], lineWidth = 3.0))
	buttons[idx].setPos(button_pos[idx])
	# Text labels
	button_text.append(visual.TextStim(win, text = '', height = text_size,
		font = text_font, color = font_color, pos = button_pos[idx]))

# Make other interface content
# Conf button
conf_button = visual.Rect(win, width = 150, height = 75, fillColor = init_button_color,
		lineColor = [1, 1, 1], lineWidth = 2.0, pos = [0,-275])
conf_cover = visual.Rect(win, width = 153, height = 78, fillColor = window_color,
		lineColor = window_color, pos = [0,-275])
conf_text = visual.TextStim(win, text = 'CONFIRM', height = text_size + 4,
		font = text_font, color = font_color, pos = [0,-275])

# Trial instructs
trial_ins = visual.TextStim(win, text = '', height = text_size + 4,
		wrapWidth = 900, font = text_font, color = font_color, pos = [0,-245])
trial_ins.setText(trial_instructs_rand)


# Run Trials
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

for trial in trial_materials:
	idx_list = range(0,6)
	rnd.shuffle(idx_list)
	trial_list = [trial[i] for i in idx_list]

	for idx in idx_list:
		button_text[idx_list.index(idx)].setText(trial[idx])
	
	[key_responses, all_responses, rts] = trial_mgr_rand(win, cursor, timer, 
		buttons, button_text, trial_list, fix_cross, conf_button, conf_text, 
		conf_cover, trial_ins, init_button_color)

	current_trial = [subject_number, cond_labels[condition - 1], 
		(trial_materials.index(trial) + 1), trial, key_responses, 
		item_key[trial.index(key_responses[0])], item_key[trial.index(key_responses[1])],
		sum(rts), all_responses, rts, idx_list]

	subject_data.append(current_trial)
	writefile(subject_file, subject_data, ',')


	print ''
	print [' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ']
	print ['   Trial Number: ', trial_materials.index(trial) + 1]
	print [' Trial Concepts: ', trial]
	print ['     All Clicks: ', all_responses]
	print ['        All RTs: ', rts]
	print [' Final Response: ', key_responses]
	print ['Response 1 Type: ', item_key[trial.index(key_responses[0])]]
	print ['Response 2 Type: ', item_key[trial.index(key_responses[1])]]
	print [' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ']
	print ''

	for idx in range(0,6):
		buttons[idx].setFillColor(init_button_color)
		buttons[idx].setLineColor([1, 1, 1])


