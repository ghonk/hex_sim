from psychopy import visual, event, core, gui
import os, random, socket, numpy, shutil
from instructs import *

# creates folder if it doesnt exist
#------------------------------------------------------------------------------
def checkdirectory(dir): 
    if not os.path.exists(dir):
        os.makedirs(dir)


# writes list to file
#------------------------------------------------------------------------------
def writefile(filename,data,delim):
    datafile=open(filename,'w')
    for line in data: #iterate over litems in data list
        currentline='\n' #start each line with a newline
        for j in line: #add each item onto the current line

            if isinstance(j, (list, tuple)): #check if item is a list
                for k in j:
                    currentline=currentline+str(k)+delim
            else:
                currentline=currentline+str(j)+delim
                
##        write current line
        datafile.write(currentline)
    datafile.close()  


# do a dialouge and return subject info 
#------------------------------------------------------------------------------
def getsubjectinfo(experimentname,conditions,datalocation):
    ss_info=[]
    pc=socket.gethostname()
    myDlg = gui.Dlg(title=experimentname)
    myDlg.addText('Subject Info')
    myDlg.addField('ID:', tip='or subject code')
    myDlg.addField('Condition:', random.choice(conditions),choices=conditions)
    myDlg.show()
    if not myDlg.OK:
        core.quit()
        
    subjectinfo = [str(i) for i in myDlg.data]
    
    if subjectinfo[0]=='':
        core.quit()
    else: 
        id=subjectinfo[0]
        condition=subjectinfo[1]
        subjectfile=datalocation+pc+'-'+experimentname+'-'+condition+'-'+id+'.csv'
        while os.path.exists(subjectfile) == True:
            subject_file=datalocation+pc+'-'+experimentname+'-'+condition+'-'+id+'.csv' + '_dupe'
        return [int(id),int(condition),subjectfile]


# copies the data file to a series of dropbox folders
#------------------------------------------------------------------------------  
def copy2db(file_name,experiment_name):
    copyfolders=[ #add your own!
        'C:\\Users\\klab\\Dropbox\\PSYCHOPY DATA\\'+experiment_name+'\\',
        'C:\\Users\\klab\\Dropbox\\garrett\\PSYCHOPY DATA\\'+experiment_name+'\\']

    for i in copyfolders:
        checkdirectory(i)
        shutil.copy(file_name,i)


# takes in 1 or 2-d lists of objects and draws them in the window
#------------------------------------------------------------------------------
def draw_all(win,objects):
    for i in objects:
        if isinstance(i, (list, tuple)):
            for j in i:
                j.draw()
        else:
            i.draw()
    win.flip()


# grab button presses
#------------------------------------------------------------------------------
def buttongui(cursor,timer,buttons,labels):
    #clear events
    timer.reset()
    cursor.clickReset()
    event.clearEvents() 
    
    #iterate until response
    while True:
        
        #quit if desired
        if 'q' in event.getKeys():
            print 'User Terminated'
            core.quit()
            
        #check to see if any stimulus has been clicked inside of
        for i in buttons:
            if cursor.isPressedIn(i):
                return [labels[buttons.index(i)],timer.getTime()]


# run rand trial
#------------------------------------------------------------------------------   
def trial_mgr_rand(win, cursor, timer, buttons, button_text, trial_list, fix_cross,
              conf_button, conf_text, conf_cover, trial_ins, init_button_color):
    
    #set trial vars
    trial_end    = False
    current_sel  = []
    rts          = []
    responses    = ['start']
    buttons.append(conf_button)
    button_text.append(conf_text)   
    trial_list.append('CONFIRM')

    fix_cross.draw()
    win.flip()
    core.wait(.5)

    draw_all(win, [buttons, button_text, conf_cover, trial_ins])
    
    while not trial_end:
        [response, rt] = buttongui(cursor, timer, buttons, trial_list)
        responses.append(response)
        rts.append(rt)

        if len(current_sel) <= 1:
            if response in current_sel:
                current_sel.remove(response)
                buttons[trial_list.index(response)].setFillColor(init_button_color)
                buttons[trial_list.index(response)].setLineColor([1, 1, 1]) 
            else:
                if 'CONFIRM' not in response: 
                    current_sel.append(response) 
                    buttons[trial_list.index(response)].setFillColor([1, 1, 1])
                    buttons[trial_list.index(response)].setLineColor([-1, -1, -1]) 
        else:
            if responses[-1] == 'CONFIRM':
                buttons[trial_list.index(response)].setLineColor([-1, -1, -1])
                buttons[trial_list.index(response)].setFillColor([1, 1, 1])
                trial_end = True
            else:
                if response in current_sel:
                    current_sel.remove(response)
                    buttons[trial_list.index(response)].setFillColor(init_button_color)
                    buttons[trial_list.index(response)].setLineColor([1, 1, 1])     
        
        if len(current_sel) >= 2:
            draw_all(win, [buttons, button_text])
        else:
            draw_all(win, [buttons, button_text, conf_cover, trial_ins])        
        
        core.wait(.2)

    buttons[-1].setLineColor([1, 1, 1])
    buttons[-1].setFillColor(init_button_color)   
    return [current_sel, responses[1:-1], rts]        
    

# run base trial
#------------------------------------------------------------------------------   
def trial_mgr_base(win, cursor, timer, buttons, button_text, trial_list, fix_cross,
              conf_button, conf_text, conf_cover, trial_ins, init_button_color):
    
    #set trial vars
    trial_end    = False
    current_sel  = []
    rts          = []
    responses    = ['start']
    buttons.append(conf_button)
    button_text.append(conf_text)   
    trial_list.append('CONFIRM')

    fix_cross.draw()
    win.flip()
    core.wait(.5)

    draw_all(win, [buttons[0], button_text[0], conf_cover, trial_ins[0]])
    core.wait(1.25)

    draw_all(win, [buttons, button_text, conf_cover, trial_ins])
    
    while not trial_end:
        [response, rt] = buttongui(cursor, timer, buttons[1:], trial_list[1:])   
        responses.append(response)
        rts.append(rt)

        if len(current_sel) < 1:
            if response in current_sel:
                current_sel.remove(response)
                buttons[trial_list.index(response)].setFillColor(init_button_color)
                buttons[trial_list.index(response)].setLineColor([1, 1, 1]) 
            else:
                if 'CONFIRM' not in response: 
                    current_sel.append(response) 
                    buttons[trial_list.index(response)].setFillColor([1, 1, 1])
                    buttons[trial_list.index(response)].setLineColor([-1, -1, -1]) 
        else:
            if responses[-1] == 'CONFIRM':
                buttons[trial_list.index(response)].setLineColor([-1, -1, -1])
                buttons[trial_list.index(response)].setFillColor([1, 1, 1])
                trial_end = True
            else:
                if response in current_sel:
                    current_sel.remove(response)
                    buttons[trial_list.index(response)].setFillColor(init_button_color)
                    buttons[trial_list.index(response)].setLineColor([1, 1, 1])     
        
        if len(current_sel) == 1:
            draw_all(win, [buttons, button_text])
        else:
            draw_all(win, [buttons, button_text, conf_cover, trial_ins])        
        
        core.wait(.2)

    buttons[-1].setLineColor([1, 1, 1])
    buttons[-1].setFillColor(init_button_color)   
    return [current_sel, responses[1:-1], rts]        
    