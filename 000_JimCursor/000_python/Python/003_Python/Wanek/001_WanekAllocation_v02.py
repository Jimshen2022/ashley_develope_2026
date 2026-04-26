##### %%time
# version: 05--- developing..... to solve allocation qty > open demand qty 
# for Luanna maintain hotloading allocation list into HJ **********************
# created by JimShen on Feb.22.2023

import pandas as pd
import pyautogui
import pyperclip
import win32gui
import win32con
import win32com.client
import win32api
import pywintypes
import pymsgbox
import time


pyautogui.FAILSAFE = True
pyautogui.PAUSE = 1

# 修改桌面分辨率
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
        if t == 'Wanek_hotloading_allocation_v02 - Jupyter Notebook — Mozilla Firefox':
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
    

# confirm Wanek HJ webwise hotloading item allocation page is ready or not 
msgbox = pymsgbox.confirm(text="Have you already signed in Wanek HJ Item Allocation webpage?",
               title='Notice:',buttons=['Y','N'])
if msgbox == "N":
    pymsgbox.alert('Pleas sign in Wanek HJ HotLoading Items Allocation (page2237)','Notice','OK')
    exit(0)
elif msgbox == "Y":
    pymsgbox.alert("Pleas switch to HJ Item Allocation screen in 5 seconds !!!!!",'WARNING!!!!!!!!','OK')
    time.sleep(5)
else:
    pass

# paste()
def paste(text):
    pyperclip.copy(text)
    pyautogui.hotkey('ctrl','v')

# import excel file Wanek_Allocation_List.xlsx into df that will be entered into excel:
df = pd.read_excel(r'C:\Users\jishen\Downloads\Wanek_Allocation_List.xlsx',sheet_name=0,skiprows=1,
                   dtype={'Item':str,'Priority':str,'WHs':str,'Total':str,'Destination':str})
df['Due'] = pd.to_datetime(df['Due'],errors='coerce')
df['Due'] = df['Due'].dt.strftime('%m/%d/%Y')


# import excel file Allocated_List.xlsx into df2 then loaded into dictionary:
df2 = pd.read_excel(r'C:\Users\jishen\Downloads\Allocated_List.xlsx',sheet_name=0,usecols='B,D',dtype={'Production Item':str})
df2['*MFG Date'] = pd.to_datetime(df2['*MFG Date'],errors='coerce')
df2['*MFG Date'] = df2['*MFG Date'].dt.strftime('%m/%d/%Y')
df2 = df2[df2['*MFG Date']==df['Due'][0]]
df2.reset_index(inplace=True)
df2.drop(columns='index',inplace=True)

d={}
d2={}
# df3=pd.DataFrame()  
for x in range(df2.shape[0]):
    d[df2['Production Item'][x]] = ''

# go through df each item number: *********************************************************    
for i in range(df.shape[0]):
    # if the item number ever been maintained then go to next item number
    if df['Item'][i] in d2:
        continue
    
    # if item in d:
    if df['Item'][i] in d:
        
        # click refresh button 
        pyautogui.moveTo([1543,199],duration=0.0001)
        time.sleep(0.0001)
        pyautogui.click()
        time.sleep(0.5)  
             
        
        while True:
            additems_pos = pyautogui.locateCenterOnScreen('additems.png',confidence=0.8,grayscale=True,
                                                              region=(1240,143,435,154))
            if additems_pos:
                break
        pyautogui.moveTo([additems_pos[0],additems_pos[1]])
        pyautogui.click()
        time.sleep(1.5)
        
        # enter item number 
        pyautogui.moveTo([332,361])
        pyautogui.click()
        paste(df['Item'][i])

        # enter WHs
        pyautogui.moveTo([339,472])
        pyautogui.click(clicks=3)
        if df['WHs'][i]=='1':
            pass
        elif df['WHs'][i]=='5':
                pyautogui.typewrite('5',0.0001)
        elif df['WHs'][i]=='15':
                pyautogui.typewrite('15',0.0001)
        elif df['WHs'][i]=='17':
                pyautogui.typewrite('17',0.0001)
        elif df['WHs'][i]=='28':
                pyautogui.typewrite('28',0.0001)
        elif df['WHs'][i]=='42':
                pyautogui.typewrite('42',0.0001)
        elif df['WHs'][i]=='335':
                pyautogui.typewrite('335',0.0001)
        elif df['WHs'][i]=='ECR':
                pyautogui.typewrite('ecr',0.0001)
        elif df['WHs'][i]=='Direct Customer':
                pyautogui.typewrite('direct',0.0001)
        elif df['WHs'][i]=='12':
                pyautogui.typewrite('12',0.0001)
        elif df['WHs'][i]=='20':
                pyautogui.typewrite('20',0.0001)                
        elif df['WHs'][i]=='49':
                pyautogui.typewrite('49',0.0001)
        elif df['WHs'][i]=='50':
                pyautogui.typewrite('50',0.0001)
        elif df['WHs'][i]=='60':
                pyautogui.typewrite('60',0.0001)
        elif df['WHs'][i]=='70':
                pyautogui.typewrite('70',0.0001)   
        elif df['WHs'][i]=='101':
                pyautogui.typewrite('101',0.0001) 
        elif df['WHs'][i]=='213':
                pyautogui.typewrite('213',0.0001) 
        elif df['WHs'][i]=='215':
                pyautogui.typewrite('215',0.0001) 
        elif df['WHs'][i]=='242':
                pyautogui.typewrite('242',0.0001) 
        else:
            pass

        # enter Allocation Qty 
        pyautogui.moveTo([332,526])
        pyautogui.click()
        paste(df['Total'][i]) 

        # enter Sequence 
        pyautogui.moveTo([335,578])
        pyautogui.click(clicks=3)
        paste(df['Priority'][i]) 
        pyautogui.press('enter')

        #  	3230223  for 2/25/2023  allocation already exist, please use GO TO Allocation Item!
     
        while True:
            alreadyexist_pos = pyautogui.locateCenterOnScreen('alreadyexist.png',confidence=0.8,grayscale=True,
                                                              region=(0,183,600,247))
            if alreadyexist_pos:
                break
        pyautogui.moveTo([alreadyexist_pos[0],alreadyexist_pos[1]])
        pyautogui.click()
        
        # wait for next screen: whse list for allocation
        while True:
            returnbacktolist_pos = pyautogui.locateCenterOnScreen('returnbacktolist.png',confidence=0.9,grayscale=True,
                                                        region=(1240,143,435,154))
            if returnbacktolist_pos:
                break

        for j in range(df.shape[0]):
            if df['Item'][i]== df['Item'][j]:
                # page2238 outbound warehouse list (look for destination whse)       
                if df['WHs'][j] == '1':
                    whs_pos = pyautogui.locateCenterOnScreen('1.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '101':
                    whs_pos = pyautogui.locateCenterOnScreen('101.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '12':
                    whs_pos = pyautogui.locateCenterOnScreen('12.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '15':
                    whs_pos = pyautogui.locateCenterOnScreen('15.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '17':
                    whs_pos = pyautogui.locateCenterOnScreen('17.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '20':
                    whs_pos = pyautogui.locateCenterOnScreen('20.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '213':
                    whs_pos = pyautogui.locateCenterOnScreen('213.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '215':
                    whs_pos = pyautogui.locateCenterOnScreen('215.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '242':
                    whs_pos = pyautogui.locateCenterOnScreen('242.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '28':
                    whs_pos = pyautogui.locateCenterOnScreen('28.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '335':
                    whs_pos = pyautogui.locateCenterOnScreen('335.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '42':
                    whs_pos = pyautogui.locateCenterOnScreen('42.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '49':
                    whs_pos = pyautogui.locateCenterOnScreen('49.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '5':
                    whs_pos = pyautogui.locateCenterOnScreen('5.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '50':
                    whs_pos = pyautogui.locateCenterOnScreen('50.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '60':
                    whs_pos = pyautogui.locateCenterOnScreen('60.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == '70':
                    whs_pos = pyautogui.locateCenterOnScreen('70.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == 'Direct Customer':
                    whs_pos = pyautogui.locateCenterOnScreen('DirectCustomer.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                elif df['WHs'][j] == 'ECR':
                    whs_pos = pyautogui.locateCenterOnScreen('ECR.png',confidence=0.9,grayscale=True,region=(140,371,165,527))       
                else:
                    pass
                    # click whs_pos -- allocation qty
                if whs_pos == None:
                    cancel_pos = pyautogui.locateCenterOnScreen('cancelsign.png',confidence=0.8,grayscale=True,
                                                    region=(1099,148,544,172))
                    pyautogui.moveTo(cancel_pos)    # click "cancel" 
                    pyautogui.click() 
                    time.sleep(1.5)


                else:
                    pyautogui.moveTo(804,whs_pos[1])  # move to allocation qty
                    pyautogui.click(clicks=2)
                    paste(df['Total'][j])

                    pyautogui.press('tab')    # move to sequence   
                    paste(df['Priority'][j])    # sequence=priority 

                    pyautogui.moveTo([1374,199])    # item allocation click button "save" 
                    pyautogui.click() 
                    pyautogui.press('enter')
                    time.sleep(1.25)    #  current is still in item allocation whse list screen
                   
        btlist_pos = pyautogui.locateCenterOnScreen('rbtolist.png',confidence=0.9,grayscale=True,
                                                    region=(899,148,544,172))
        pyautogui.moveTo(btlist_pos)    # click "return back to list" 
        pyautogui.click() 
        time.sleep(1.25)
        d2[df['Item'][i]] = 1    # put item number into dictionary  
    
    # judge next step is add new item or exists item
    if df['Item'][i] not in d2 and list(df['Item']).count(df['Item'][i]) == 1:
        # click refresh button 
        pyautogui.moveTo([1543,199],duration=0.0001)
#         time.sleep(0.0001)
        pyautogui.click()
        time.sleep(0.5)  
        
        while True:
            additems_pos = pyautogui.locateCenterOnScreen('additems.png',confidence=0.8,grayscale=True,
                                                              region=(1240,143,435,154))
            if additems_pos:
                break
        pyautogui.moveTo([additems_pos[0],additems_pos[1]])
        pyautogui.click()
        time.sleep(1.25)

        # enter item number 
        pyautogui.moveTo([332,361])
        pyautogui.click()
        paste(df['Item'][i])
        
        # enter WHs
        pyautogui.moveTo([339,472])
        pyautogui.click(clicks=3)
        if df['WHs'][i]=='1':
            pass
        elif df['WHs'][i]=='5':
                pyautogui.typewrite('5',0.0001)
        elif df['WHs'][i]=='15':
                pyautogui.typewrite('15',0.0001)
        elif df['WHs'][i]=='17':
                pyautogui.typewrite('17',0.0001)
        elif df['WHs'][i]=='28':
                pyautogui.typewrite('28',0.0001)
        elif df['WHs'][i]=='42':
                pyautogui.typewrite('42',0.0001)
        elif df['WHs'][i]=='335':
                pyautogui.typewrite('335',0.0001)
        elif df['WHs'][i]=='ECR':
                pyautogui.typewrite('ecr',0.0001)
        elif df['WHs'][i]=='Direct Customer':
                pyautogui.typewrite('direct',0.0001)
        elif df['WHs'][i]=='12':
                pyautogui.typewrite('12',0.0001)
        elif df['WHs'][i]=='20':
                pyautogui.typewrite('20',0.0001)                
        elif df['WHs'][i]=='49':
                pyautogui.typewrite('49',0.0001)
        elif df['WHs'][i]=='50':
                pyautogui.typewrite('50',0.0001)
        elif df['WHs'][i]=='60':
                pyautogui.typewrite('60',0.0001)
        elif df['WHs'][i]=='70':
                pyautogui.typewrite('70',0.0001)   
        elif df['WHs'][i]=='101':
                pyautogui.typewrite('101',0.0001) 
        elif df['WHs'][i]=='213':
                pyautogui.typewrite('213',0.0001) 
        elif df['WHs'][i]=='215':
                pyautogui.typewrite('215',0.0001) 
        elif df['WHs'][i]=='242':
                pyautogui.typewrite('242',0.0001) 
        else:
            pass

        # enter Allocation Qty 
        pyautogui.moveTo([332,526])
        pyautogui.click()
        paste(df['Total'][i]) 
        
        # enter Sequence 
        pyautogui.moveTo([335,578])
        pyautogui.click(clicks=3)
        paste(df['Priority'][i]) 
        pyautogui.press('enter')
        time.sleep(2)
        
        try:
            adsucc_pos = pyautogui.locateCenterOnScreen('adsucc.png',confidence=0.9,grayscale=True,
                                                        region=(0,183,600,247))
            # click  	Added successful. Please Click and allocate other warehouse.  
            pyautogui.moveTo([adsucc_pos[0],adsucc_pos[1]])
            pyautogui.click()
            time.sleep(1.55)            
            # click return back to list 
            pyautogui.moveTo([1287,198])
            pyautogui.click()
            time.sleep(1.25)
            d2[df['Item'][i]] = 1  
            
            
        except:    
            morthandeman_pos = pyautogui.locateCenterOnScreen('MoreThenDemand.png',confidence=0.9,grayscale=True,
                                                        region=(0,183,600,247))
            pyautogui.moveTo([morthandeman_pos[0],morthandeman_pos[1]])
            pyautogui.click()
            time.sleep(0.25)
            backarrow_pos = pyautogui.locateCenterOnScreen('backarrow.png',confidence=0.9,grayscale=True,
                                                        region=(0,183,600,247))
            pyautogui.moveTo([backarrow_pos[0],backarrow_pos[1]])
            pyautogui.click()
            time.sleep(0.25)
            
#             df3 = pd.concat([pd.DataFrame([df.iloc[i,:]]), df3], sort=False)
            
   
            
    if df['Item'][i] not in d2 and list(df['Item']).count(df['Item'][i]) > 1:       
         # click refresh button 
        pyautogui.moveTo([1543,199],duration=0.0001)
#         time.sleep(0.0001)
        pyautogui.click()
        time.sleep(0.5)
        
        while True:
            additems_pos = pyautogui.locateCenterOnScreen('additems.png',confidence=0.8,grayscale=True,
                                                              region=(1240,143,435,154))
            if additems_pos:
                break
        pyautogui.moveTo([additems_pos[0],additems_pos[1]])
        pyautogui.click()
        time.sleep(1.25)

        # enter item number 
        pyautogui.moveTo([332,361])
        pyautogui.click()
        paste(df['Item'][i])

        # enter WHs
        pyautogui.moveTo([339,472])
        pyautogui.click(clicks=3)
        if df['WHs'][i]=='1':
            pass
        elif df['WHs'][i]=='5':
                pyautogui.typewrite('5',0.0001)
        elif df['WHs'][i]=='15':
                pyautogui.typewrite('15',0.0001)
        elif df['WHs'][i]=='17':
                pyautogui.typewrite('17',0.0001)
        elif df['WHs'][i]=='28':
                pyautogui.typewrite('28',0.0001)
        elif df['WHs'][i]=='42':
                pyautogui.typewrite('42',0.0001)
        elif df['WHs'][i]=='335':
                pyautogui.typewrite('335',0.0001)
        elif df['WHs'][i]=='ECR':
                pyautogui.typewrite('ecr',0.0001)
        elif df['WHs'][i]=='Direct Customer':
                pyautogui.typewrite('direct',0.0001)
        elif df['WHs'][i]=='12':
                pyautogui.typewrite('12',0.0001)
        elif df['WHs'][i]=='20':
                pyautogui.typewrite('20',0.0001)                
        elif df['WHs'][i]=='49':
                pyautogui.typewrite('49',0.0001)
        elif df['WHs'][i]=='50':
                pyautogui.typewrite('50',0.0001)
        elif df['WHs'][i]=='60':
                pyautogui.typewrite('60',0.0001)
        elif df['WHs'][i]=='70':
                pyautogui.typewrite('70',0.0001)   
        elif df['WHs'][i]=='101':
                pyautogui.typewrite('101',0.0001) 
        elif df['WHs'][i]=='213':
                pyautogui.typewrite('213',0.0001) 
        elif df['WHs'][i]=='215':
                pyautogui.typewrite('215',0.0001) 
        elif df['WHs'][i]=='242':
                pyautogui.typewrite('242',0.0001) 
        else:
            pass

        # enter Allocation Qty 
        pyautogui.moveTo([332,526])
        pyautogui.click()
        paste(df['Total'][i]) 

        # enter Sequence 
        pyautogui.moveTo([335,578])
        pyautogui.click(clicks=3)
        paste(df['Priority'][i]) 
        pyautogui.press('enter')
        time.sleep(2)

        try:
            adsucc_pos2 = pyautogui.locateCenterOnScreen('adsucc.png',confidence=0.7,grayscale=True,
                                                        region=(0,183,600,247))
            # click  	Added successful. Please Click and allocate other warehouse.  
            pyautogui.moveTo([adsucc_pos2[0],adsucc_pos2[1]])
            pyautogui.click()
            time.sleep(1.25)            
            d2[df['Item'][i]] = 1  
            
            
        except:    
            morthandeman_pos2 = pyautogui.locateCenterOnScreen('MoreThenDemand.png',confidence=0.8,grayscale=True,
                                                        region=(0,183,600,247))
            pyautogui.moveTo([morthandeman_pos2[0],morthandeman_pos2[1]])
            pyautogui.click()
            time.sleep(0.25)
            backarrow_pos2 = pyautogui.locateCenterOnScreen('backarrow.png',confidence=0.8,grayscale=True,
                                                        region=(0,183,600,247))
            pyautogui.moveTo([backarrow_pos2[0],backarrow_pos2[1]])
            pyautogui.click()
            time.sleep(0.25)
#             df3 = pd.concat([pd.DataFrame([df.iloc[i,:]]), df3], sort=False)
            continue          
        n=0
        for j in range(df.shape[0]):
            if df['Item'][i]== df['Item'][j]:
                n +=1
                if n ==1:
                    continue
                else:

                    # page2238 outbound warehouse list (look for destination whse)       
                    if df['WHs'][j] == '1':
                        whs_pos = pyautogui.locateCenterOnScreen('1.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '101':
                        whs_pos = pyautogui.locateCenterOnScreen('101.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '12':
                        whs_pos = pyautogui.locateCenterOnScreen('12.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '15':
                        whs_pos = pyautogui.locateCenterOnScreen('15.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '17':
                        whs_pos = pyautogui.locateCenterOnScreen('17.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '20':
                        whs_pos = pyautogui.locateCenterOnScreen('20.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '213':
                        whs_pos = pyautogui.locateCenterOnScreen('213.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '215':
                        whs_pos = pyautogui.locateCenterOnScreen('215.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '242':
                        whs_pos = pyautogui.locateCenterOnScreen('242.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '28':
                        whs_pos = pyautogui.locateCenterOnScreen('28.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '335':
                        whs_pos = pyautogui.locateCenterOnScreen('335.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '42':
                        whs_pos = pyautogui.locateCenterOnScreen('42.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '49':
                        whs_pos = pyautogui.locateCenterOnScreen('49.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '5':
                        whs_pos = pyautogui.locateCenterOnScreen('5.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '50':
                        whs_pos = pyautogui.locateCenterOnScreen('50.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '60':
                        whs_pos = pyautogui.locateCenterOnScreen('60.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == '70':
                        whs_pos = pyautogui.locateCenterOnScreen('70.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == 'Direct Customer':
                        whs_pos = pyautogui.locateCenterOnScreen('DirectCustomer.png',confidence=0.9,grayscale=True,region=(140,371,165,527))
                    elif df['WHs'][j] == 'ECR':
                        whs_pos = pyautogui.locateCenterOnScreen('ECR.png',confidence=0.9,grayscale=True,region=(140,371,165,527))       
                    else:
                        pass

                    # if whse_pos can't be found then go to next 
                    if whs_pos == None:
                        cancel_pos = pyautogui.locateCenterOnScreen('cancelsign.png',confidence=0.8,grayscale=True,
                                                        region=(1099,148,544,172))
                        pyautogui.moveTo(cancel_pos)    # click "cancel" 
                        pyautogui.click() 
                        time.sleep(0.5)

                    else:
                        pyautogui.moveTo(804,whs_pos[1])  # move to allocation qty
                        pyautogui.click(clicks=2)
                        paste(df['Total'][j])

                        pyautogui.press('tab')    # move to sequence   
                        paste(df['Priority'][j])    # sequence=priority 

                        pyautogui.moveTo([1374,199])    # item allocation click button "save" 
                        pyautogui.click() 
                        time.sleep(1.25)    #  current is still in item allocation whse list screen
                   

        btlist_pos = pyautogui.locateCenterOnScreen('rbtolist.png',confidence=0.8,grayscale=True,
                                                    region=(1020,148,544,172))
        pyautogui.moveTo(btlist_pos)    # click "return back to list" 
        pyautogui.click() 
        time.sleep(1.5)
        d2[df['Item'][i]] = 1
        
#  df3.to_excel(r'C:\Users\jishen\Downloads\WN3_AllocationOverCO.xlsx', sheet_name='OverCO')         
pyautogui.alert(text = 'total finished {} rows records, please compare your excel file and HJ data '.format(df.shape[0]),
                title='Notice',button='OK')