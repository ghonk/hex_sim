"""
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
                                                                                   
88                                                  88                      
88                                                  ""                      
88                                                                                 
88,dPPYba,    ,adPPYba,  8b,     ,d8     ,adPPYba,  88  88,dPYba,,adPYba,   
88P'    "8a  a8P_____88   `Y8, ,8P'      I8[    ""  88  88P'   "88"    "8a  
88       88  8PP```````     )888(         `"Y8ba,   88  88      88      88  
88       88  "8b,   ,aa   ,d8" "8b,      aa    ]8I  88  88      88      88  
88       88   `"Ybbd8"'  8P'     `Y8     `"YbbdP"'  88  88      88      88  
                                                                                                                      
This experiment presents participants with trials consisting of 
six words: a base word, a thematic associate, a taxonomic 
co-category member, and 3 unrelated words. Participants' goal is
to use the mouse to select the two words that are most similar. 
Word Choice (Accuracy) and Reaction Time are collected as DVs  

NOTES - added 'goes with' on 3.3.16, at 30 per cell 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
"""
__author__  = "g_honk"
__credits__ = "n_conaway"
__status__  = "real_deal"
__license__ = "GPL"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
from psychopy import visual, event, core
from socket   import gethostname
from time     import strftime
from os       import getcwd, listdir, path, system
import numpy  as np	 
import random as rnd
from misc     import *
import sys
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Experiment Settings
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

experiment_name = "hex_sim"
conditions   = [1,2,3,4,5]
cond_labels  = ['sextet_rand', 'sextet_base', 
                'triad_rand', 'triad_base',
                'triad_goes']
window_color = [.46, .74, .96]
font_color   = [-1,-1,-1]
init_button_color = [.5, .5, .5]
text_font    = "Consolas"
text_size    = 20

# Set up interface
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Get subject information and materials
if sys.platform=='darwin':
    checkdirectory(getcwd() + '/subjects/')

    # Get subject information
    [subject_number, condition, subject_file] = getsubjectinfo(
        experiment_name, conditions, getcwd() + '/subjects/')
    
    # Get materials list
    trial_materials = np.genfromtxt(
    	getcwd() + "\\materials\\stimuli.csv", delimiter = ",", 
        dtype = "str").astype(str)

else:
    checkdirectory(getcwd() + '\\subjects\\')

    # Get subject information
    [subject_number,condition,subject_file] = getsubjectinfo(
        experiment_name,conditions,getcwd() + '\\subjects\\')

    # Get materials list
    trial_materials = np.genfromtxt(
        getcwd() + "\\materials\\stimuli.csv", delimiter = ",", 
        dtype = "str").astype(str)

# # prep trial list
if condition > 2:
	np.array(trial_materials)[:,0:3]
trial_materials = trial_materials.tolist()
item_key = ['BASE','TAXONOMIC','THEMATIC','UNRELATED','UNRELATED','UNRELATED']

# Create window and set logging option
if gethostname() not in ['klab1','klab2','klab3']:
    win=visual.Window([1440,900],units='pix',color = window_color, fullscr=True, screen = 0)

else:
    win=visual.Window([1440,900],units='pix', color = window_color, fullscr = True)
    checkdirectory(getcwd() + '\\logfiles\\')
    log_file=getcwd()+ '\\logfiles\\' + str(subject_number)+ '-logfile.txt'
    while path.exists(log_file):
       log_file=log_file+'_dupe.txt'
    log_file=open(log_file,'w')
    sys.stdout=log_file
    sys.stderr=log_file

# Define the mouse and timer
cursor = event.Mouse(visible = True, newPos = None, win = win)
timer = core.Clock()

# Get current date and time
current_time = strftime("%a, %d %b %Y %X")

# Get instructions
from instructs import *
instructions = visual.TextStim(win, text = '', wrapWidth = 900,
	color = font_color, font = text_font, height = text_size)
fix_cross = visual.TextStim(win, text = '+', color = font_color, 
	font = text_font, height = text_size, pos = [0,0])


# Start logging info
print '\n SUBJECT INFORMATION:'
print ['ID: ', subject_number]
print ['condition: ', condition]
print ['Data file: ', subject_file]
print ['Run Time: ', current_time]
print '\n'
print ['----- Materials ------']
rnd.shuffle(trial_materials)
for i in trial_materials:
	print i

subject_data = [[current_time], [subject_number]]

# Start the experiment, display instructions
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
if condition == 1:
	execfile('sextet_rand.py')
elif condition == 2:
    execfile('sextet_base.py')
elif condition == 3:
    execfile('triad_rand.py')
elif condition == 4:
    execfile('triad_base.py')
else:
    execfile('triad_base_goes.py')
# Wrap it up
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

instructions.setText(end_instructs)
instructions.draw()
win.flip()
event.waitKeys()

print '\nExperiment completed'
if gethostname() in ['klab1','klab2','klab3']:
    copy2db(subject_file,experiment_name)
    log_file.close()
    os.system("TASKKILL /F /IM pythonw.exe")











