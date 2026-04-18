%%time
# version: 04, for Downloading Trx from WH335 **********************
# created by JimShen on Feb.23.2023
# Please Notice SETUP:  Browser zoom rate 80%;  display resolution 1920x1080;  scaling setup

import pyautogui
import pyperclip
import win32gui
import win32com.client
import pymsgbox
import time
import datetime
from datetime import timedelta

begin = time.time()

# move the mouse to screen edge to break the process
pyautogui.FAILSAFE = True
pyautogui.PAUSE = 1

# change desktop screen resolution
# devmode = pywintypes.DEVMODEType()
# # screenSize = [1280,800]
# screenSize = [1920,1080]
# devmode.PelsWidth = screenSize[0]
# devmode.PelsHeight = screenSize[1]
# devmode.Fields = win32con.DM_PELSWIDTH | win32con.DM_PELSHEIGHT
# win32api.ChangeDisplaySettings(devmode,0) 

# 以下为将浏览器窗口最大化
def get_all_hwnd(hwnd, mouse):
    if (win32gui.IsWindow(hwnd) and
        win32gui.IsWindowEnabled(hwnd) and
        win32gui.IsWindowVisible(hwnd)):
        hwnd_map.update({hwnd: win32gui.GetWindowText(hwnd)})

hwnd_map = {}
win32gui.EnumWindows(get_all_hwnd, 0)
for h, t in hwnd_map.items():
    if t :
        if t == 'AT_Trx - Jupyter Notebook — Mozilla Firefox': 
            # h 为想要放到最前面的窗口句柄
            # print(h,'&&',t)

            win32gui.BringWindowToTop(h)
            shell = win32com.client.Dispatch("WScript.Shell")
            shell.SendKeys('%')

            # 被其他窗口遮挡，调用后放到最前面
            win32gui.SetForegroundWindow(h)

            # 解决被最小化的情况
 #          win32gui.ShowWindow(h, win32con.SW_RESTORE)
 #          win32gui.ShowWindow(h, win32con.SW_SHOWMAXIMIZED)
    
    
# confirm Ashton HJ webwise login ready or not 
msgbox = pymsgbox.confirm(text="Have you already signed in Ashton HJ webwise?",
               title='Notice:',buttons=['Y','N'])
if msgbox == "N":
    pymsgbox.alert('Pleas sign in Ashton HJ first, thanks!','Notice','OK')
    exit(0)
elif msgbox == "Y":
    pymsgbox.alert("Pleas waiting the program will start in 5 seconds !!!!!",'WARNING!!!!!!!!','OK')
    time.sleep(3)
else:
    pass

# def functions *****************************************************************************************************
#  1. paste function()
def paste(text):
    pyperclip.copy(text)
    pyautogui.hotkey('ctrl', 'v')
    
    
    
#  1.1. export to excel -- FOR KNQMAN export
def export_to_excel_KNQMAN():
    while True:
        export_pos = pyautogui.locateCenterOnScreen('export.png', confidence=0.9, grayscale=True,
                                                    region=(0,0,1920,1080))
        if export_pos:
            break
    pyautogui.moveTo([export_pos[0], export_pos[1]])
    pyautogui.click()
    
    # save as and key in file name
    while True:
        filename_pos = pyautogui.locateCenterOnScreen('SaveAsFilename.png', confidence=0.8, grayscale=True,
                                                      region=(0,0,1920,1080))
        if filename_pos:
            break
    time.sleep(0.5)
    pyautogui.moveTo([filename_pos[0] + 78, filename_pos[1]])
    pyautogui.click(clicks=2)

#  2. export to excel
def export_to_excel():
    while True:
        export_pos = pyautogui.locateCenterOnScreen('export.png', confidence=0.9, grayscale=True,
                                                    region=(0,0,1920,1080))
        if export_pos:
            break
    pyautogui.moveTo([export_pos[0], export_pos[1]])
    pyautogui.click()


#     # click ok
#     while True:
#         OK_pos = pyautogui.locateCenterOnScreen('OK.png',confidence=0.8,grayscale=True,
#                                                         region=(0,0,1920,1080))
#         if OK_pos:
#             break
#     time.sleep(0.5)
#     pyautogui.moveTo([OK_pos[0],OK_pos[1]])
#     pyautogui.click()
    
    # save as and key in file name
    while True:
        filename_pos = pyautogui.locateCenterOnScreen('SaveAsFilename.png', confidence=0.8, grayscale=True,
                                                      region=(0,0,1920,1080))
        if filename_pos:
            break
    time.sleep(0.5)
    pyautogui.moveTo([filename_pos[0] + 78, filename_pos[1]])
    pyautogui.click(clicks=2)

    
def find_saveas_yes():
    while True:
        chineseYes_pos = pyautogui.locateCenterOnScreen('chineseYes.png', confidence=0.8, grayscale=True,
                                                        region=(0,0,1920,1080))
        if chineseYes_pos:
            break
    pyautogui.moveTo([chineseYes_pos[0], chineseYes_pos[1]])
    pyautogui.click() 
    
    
def find_save_button():
    while True:
        save_pos = pyautogui.locateCenterOnScreen('save.png', confidence=0.8, grayscale=True,
                                                  region=(0,0,1920,1080))
        if save_pos:
            break
    pyautogui.moveTo([save_pos[0], save_pos[1]])
    pyautogui.click()   
    

def HJ_Query_Button():
    HJQueryButton_pos = pyautogui.locateCenterOnScreen('HJQueryButton.png', confidence=0.8, grayscale=True,
                                                       region=(0,0,1920,1080))
    pyautogui.moveTo([HJQueryButton_pos[0], HJQueryButton_pos[1]])
    pyautogui.click()
    time.sleep(2)    



# move to Ashton HJ screen
AT_HJ_pos = pyautogui.locateCenterOnScreen('AT_HJ.png', confidence=0.8, grayscale=True,
                                           region=(0,0,1920,1080))
pyautogui.moveTo([AT_HJ_pos[0], AT_HJ_pos[1]])
pyautogui.click()
time.sleep(0.5)

# Downloading AT_MAPICS_HJ_KNQMAN.xlsx *****************************************************************************************

pentagram_pos = pyautogui.locateCenterOnScreen('AT_pentagram.png', confidence=0.8, grayscale=True,
                                               region=(0,213,40,600))
pyautogui.moveTo([pentagram_pos[0], pentagram_pos[1]])
pyautogui.click()
time.sleep(1.5)
KNQMAN_pos = pyautogui.locateCenterOnScreen('KNQMAN.png', confidence=0.8, grayscale=True,
                                            region=(0,210,261,800))
pyautogui.moveTo([KNQMAN_pos[0], KNQMAN_pos[1]])
pyautogui.click()
time.sleep(4)

# Show Only Items With a Mapics Variance
pyautogui.moveTo([313, 588])
pyautogui.click(clicks=3)
pyautogui.typewrite('N', 0.0001)


# Show Only Items With a KNQMAN Variance
pyautogui.moveTo([313, 644])
pyautogui.click(clicks=3)
pyautogui.typewrite('N', 0.0001)
pyautogui.press('enter')
time.sleep(2)

export_to_excel_KNQMAN()
pyautogui.keyDown('capslock')
pyautogui.typewrite('AT_MAPICS_HJ_KNQMAN', 0.0001)
pyautogui.keyUp('capslock')
pyautogui.press('enter')
time.sleep(1.5)
find_saveas_yes()
time.sleep(0.5)


# Downloading ATSTO.xlsx ********************************************************************************************

ATSTO_sign_pos = pyautogui.locateCenterOnScreen('ATSTO_sign.png', confidence=0.7, grayscale=True,
                                                region=(0,213,40,900))
pyautogui.moveTo([ATSTO_sign_pos[0], ATSTO_sign_pos[1]])
pyautogui.click()
time.sleep(1.5)

HJ_Query_Button()

export_to_excel()
pyautogui.keyDown("capslock")
pyautogui.typewrite('ATSTO', 0.0001)
pyautogui.keyUp("capslock")
pyautogui.press('enter')
time.sleep(1)
time.sleep(1.5)
find_saveas_yes()
time.sleep(0.5)


# Downloading AT_STO_FOR_DAMAGED.xlsx ********************************************************************************************

export_to_excel()
pyautogui.keyDown("capslock")
pyautogui.typewrite('AT_STO_FOR_DAMAGED', 0.0001)
pyautogui.keyUp("capslock")
pyautogui.press('enter')
time.sleep(1.5)
find_saveas_yes()
time.sleep(0.5)


# Downloading AT_SN.xlsx ********************************************************************************************

pentagram_pos = pyautogui.locateCenterOnScreen('AT_pentagram.png', confidence=0.7, grayscale=True,
                                               region=(0,213,40,600))
pyautogui.moveTo([pentagram_pos[0], pentagram_pos[1]])
pyautogui.click()
time.sleep(1)

ATSN_sign_pos = pyautogui.locateCenterOnScreen('SearchForActiveSN.png', confidence=0.7, grayscale=True,
                                               region=(0,213,259,900))
pyautogui.moveTo([ATSN_sign_pos[0], ATSN_sign_pos[1]])
pyautogui.click()
time.sleep(1.5)


# Serial Status
pyautogui.moveTo([222, 600])
pyautogui.click(clicks=3)
pyautogui.typewrite('In Warehouse', 0.0001)
pyautogui.press('enter')
time.sleep(1.5)

export_to_excel()
pyautogui.typewrite('AT_SN', 0.0001)
pyautogui.press('enter')
time.sleep(1.5)
find_saveas_yes()
time.sleep(0.5)

# M%.xlsx downloading
while True:
    leftArrow_pos = pyautogui.locateCenterOnScreen('leftArrow.png', confidence=0.8, grayscale=True,
                                                   region=(0,0,1920,1080))
    if leftArrow_pos:
        break        
pyautogui.moveTo([leftArrow_pos[0], leftArrow_pos[1]])
pyautogui.click()
time.sleep(0.5)

# Item Number entry: M%
pyautogui.moveTo([164, 893])
pyautogui.click(clicks=2)
pyautogui.keyDown('capslock')
pyautogui.typewrite('M%', 0.0001)
pyautogui.keyUp('capslock')
pyautogui.press('enter')

export_to_excel()
pyautogui.keyDown('capslock')
pyautogui.typewrite('M%', 0.0001)
pyautogui.keyUp('capslock')
pyautogui.press('enter')
time.sleep(1.5)
find_saveas_yes()
time.sleep(0.5)


# Downloading AT_SN-2.xlsx ********************************************************************************************

while True:
    leftArrow_pos = pyautogui.locateCenterOnScreen('leftArrow.png', confidence=0.8, grayscale=True,
                                                   region=(0,0,1920,1080))
    if leftArrow_pos:
        break        
pyautogui.moveTo([leftArrow_pos[0], leftArrow_pos[1]])
pyautogui.click()
time.sleep(0.5)

# Serial Status
pyautogui.moveTo([222, 600])
pyautogui.click(clicks=3)
pyautogui.typewrite('Loaded', 0.0001)
pyautogui.moveTo([164, 893])
pyautogui.click(clicks=3)
pyautogui.typewrite('%', 0.0001)
pyautogui.press('enter')

export_to_excel()
pyautogui.typewrite('AT_SN-2', 0.0001)
pyautogui.press('enter')
time.sleep(1.5)
find_saveas_yes()
time.sleep(0.5)

# Downloading AT_SN-3.xlsx ********************************************************************************************

while True:
    leftArrow_pos = pyautogui.locateCenterOnScreen('leftArrow.png', confidence=0.9, grayscale=True,
                                                   region=(0,0,1920,1080))
    if leftArrow_pos:
        break
pyautogui.moveTo([leftArrow_pos[0], leftArrow_pos[1]])
pyautogui.click()
time.sleep(0.5)

# Serial Status
pyautogui.moveTo([222, 600])
pyautogui.click(clicks=3)
pyautogui.typewrite('Hold', 0.0001)
pyautogui.press('enter')

export_to_excel()
pyautogui.typewrite('AT_SN-3', 0.0001)
pyautogui.press('enter')
time.sleep(1.5)
find_saveas_yes()
time.sleep(0.5)

# Downloading AT_ORPHANED.xlsx ********************************************************************************************

while True:
    leftArrow_pos = pyautogui.locateCenterOnScreen('leftArrow.png', confidence=0.8, grayscale=True,
                                                   region=(0,0,1920,1080))
    if leftArrow_pos:
        break
pyautogui.moveTo([leftArrow_pos[0], leftArrow_pos[1]])
pyautogui.click()
time.sleep(0.5)

# Serial Status
pyautogui.moveTo([222, 600])
pyautogui.click(clicks=3)
pyautogui.typewrite('Orphaned', 0.0001)
pyautogui.press('enter')

export_to_excel()
pyautogui.typewrite('AT_ORPHANED', 0.0001)
pyautogui.press('enter')
time.sleep(1.5)
find_saveas_yes()
time.sleep(0.5)

# Downloading AT_SNA.xlsx ********************************************************************************************
pentagram_pos = pyautogui.locateCenterOnScreen('AT_pentagram.png', confidence=0.8, grayscale=True,
                                               region=(0,213,40,600))
pyautogui.moveTo([pentagram_pos[0], pentagram_pos[1]])
pyautogui.click()
time.sleep(1)

AT_SNA_pos = pyautogui.locateCenterOnScreen('AT_SNA.png', confidence=0.8, grayscale=True,
                                            region=(0,213,259,900))
pyautogui.moveTo([AT_SNA_pos[0], AT_SNA_pos[1]])
pyautogui.click()
time.sleep(1.5)


# Serial Status
pyautogui.moveTo([200, 403])
pyautogui.click(clicks=3)
pyautogui.typewrite('Finished Goods', 0.0001)
pyautogui.press('enter')
time.sleep(1)

export_to_excel()
pyautogui.typewrite('AT_SNA', 0.0001)
pyautogui.press('enter')
time.sleep(1.5)
find_saveas_yes()
time.sleep(0.5)

# Downloading AT347.xlsx ********************************************************************************************

pentagram_pos = pyautogui.locateCenterOnScreen('AT_pentagram.png', confidence=0.7, grayscale=True,
                                               region=(0,213,40,600))
pyautogui.moveTo([pentagram_pos[0], pentagram_pos[1]])
pyautogui.click()
time.sleep(1)

AT_Trx_pos = pyautogui.locateCenterOnScreen('AT_Trx.png', confidence=0.7, grayscale=True,
                                            region=(0,213,259,900))
pyautogui.moveTo([AT_Trx_pos[0], AT_Trx_pos[1]])
pyautogui.click()
time.sleep(1.5)


# Start Date:
now = datetime.datetime.now()
last_week_start = (now - timedelta (days=12-now.weekday ()+1)).strftime("%m/%d/%Y")
pyautogui.moveTo([200, 685])
pyautogui.click(clicks=3)
paste(last_week_start) 

# transaction type:
pyautogui.moveTo([200, 910])
pyautogui.click(clicks=3)
pyautogui.typewrite('347', 0.0001)
pyautogui.press('enter')
time.sleep(5)

export_to_excel()
pyautogui.typewrite('AT347', 0.0001)
pyautogui.press('enter')
time.sleep(1.5)
find_saveas_yes()
time.sleep(3)

# Downloading AT151-183.xlsx ********************************************************************************************

while True:
    leftArrow_pos = pyautogui.locateCenterOnScreen('leftArrow.png', confidence=0.9, grayscale=True,
                                                   region=(0,0,1920,1080))
    if leftArrow_pos:
        break
pyautogui.moveTo([leftArrow_pos[0], leftArrow_pos[1]])
pyautogui.click()
time.sleep(0.5)

# transaction type:
pyautogui.moveTo([200, 910])
pyautogui.click(clicks=3)
pyautogui.typewrite('151', 0.0001)

pyautogui.moveTo([200, 967])
pyautogui.click(clicks=3)
pyautogui.typewrite('183', 0.0001)
pyautogui.press('enter')
time.sleep(5)

export_to_excel()
pyautogui.typewrite('AT151-183', 0.0001)
pyautogui.press('enter')
time.sleep(1.5)
find_saveas_yes()
time.sleep(3)

# Downloading AT161-165.xlsx ********************************************************************************************

while True:
    leftArrow_pos = pyautogui.locateCenterOnScreen('leftArrow.png', confidence=0.8, grayscale=True,
                                                   region=(0,0,1920,1080))
    if leftArrow_pos:
        break
pyautogui.moveTo([leftArrow_pos[0], leftArrow_pos[1]])
pyautogui.click()
time.sleep(0.5)

# transaction type:
pyautogui.moveTo([200, 910])
pyautogui.click(clicks=3)
pyautogui.typewrite('161', 0.0001)

pyautogui.moveTo([200, 967])
pyautogui.click(clicks=3)
pyautogui.typewrite('165', 0.0001)
pyautogui.press('enter')
time.sleep(5)

export_to_excel()
pyautogui.typewrite('AT161-165', 0.0001)
pyautogui.press('enter')
time.sleep(1.5)
find_saveas_yes()
time.sleep(0.5)


endtime=time.time()
pyautogui.alert(text ='Downloaded successfully in {}s!'.format(round(endtime - begin, 2)),
                title='Notice', button='OK')