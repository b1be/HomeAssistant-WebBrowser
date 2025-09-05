configfilename.s = ProgramFilename()+".conf"
addr.s = Space(0)
ExamineDesktops()
x = DesktopWidth(0)/2 - 400
y = DesktopHeight(0)/2 - 300
w = 800
h = 600
m = #PB_Window_Normal
tmpweb = #Null
systrayicon = #Null
systraymenu = #Null
tmpwin = #Null
Quit = #False
showwindow = 0
logoimg = #Null
logoimgwin = #Null

Procedure Config(rewrite = #False)
  Shared configfilename
  Shared addr.s
  Shared x,y,w,h,m
  
  Select rewrite
      Case #False
  
  If FileSize(configfilename) <= 0    
    cf = CreateFile(#PB_Any,configfilename,#PB_File_SharedRead|#PB_File_SharedWrite|#PB_Ascii)
    WriteStringN(cf,"server = https://demo.home-assistant.io")
    WriteStringN(cf,"window = "+Str(x)+","+Str(y)+","+Str(w)+","+Str(h)+","+Str(m))
    CloseFile(cf)
    cf = #Null
  EndIf
  
  If FileSize(configfilename) > 0
    cf = ReadFile(#PB_Any,configfilename,#PB_File_SharedRead|#PB_Ascii)
    While Not Eof(cf)
      rs.s=ReadString(cf)
       Select UCase(LTrim(RTrim(StringField(rs.s,1,"="))))
        Case "SERVER"
          addr.s=LTrim(RTrim(StringField(rs.s,2,"=")))
        Case "WINDOW"
          x = Val(StringField(StringField(rs.s,2,"="),1,","))
          y = Val(StringField(StringField(rs.s,2,"="),2,","))
          w = Val(StringField(StringField(rs.s,2,"="),3,","))
          h = Val(StringField(StringField(rs.s,2,"="),4,","))
          m = Val(StringField(StringField(rs.s,2,"="),5,","))
      EndSelect
    Wend
    CloseFile(cf)
    cf = #Null
  EndIf
     Case #True      
        cf = CreateFile(#PB_Any,configfilename,#PB_File_SharedRead|#PB_File_SharedWrite|#PB_Ascii)
        WriteStringN(cf,"server = "+addr.s)
        WriteStringN(cf,"window = "+Str(x)+","+Str(y)+","+Str(w)+","+Str(h)+","+Str(m))
        CloseFile(cf)
        cf = #Null      
  
  EndSelect
EndProcedure

Procedure SizeWindowHandler()    
 Shared tmpweb
 Shared addr.s
 Shared x,y,w,h,m
 m = GetWindowState(EventWindow())
 Select m
     Case 0
 w = WindowWidth(EventWindow())
 h = WindowHeight(EventWindow())
 x = WindowX(EventWindow())
 y = WindowY(EventWindow())
     Default
        :
 EndSelect
 ResizeGadget(tmpweb, #PB_Ignore, #PB_Ignore,WindowWidth(EventWindow()) , WindowHeight(EventWindow()))
 Config(#True)
EndProcedure

Procedure WindowHandler()    
 Shared tmpweb
 Shared addr.s 
 Shared x,y,w,h,m
 m = GetWindowState(EventWindow())
 Select m
     Case 0
 w = WindowWidth(EventWindow())
 h = WindowHeight(EventWindow())
 x = WindowX(EventWindow())
 y = WindowY(EventWindow())
    Default
      :
 EndSelect
 Config(#True)
EndProcedure

UsePNGImageDecoder()
Config()

tmpwin = OpenWindow(#PB_Any,x,y,w,h,"HomeAssistant-Web",#PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget|m)
CompilerSelect #PB_Compiler_OS
 CompilerCase #PB_OS_Windows
   tmpweb = WebGadget(#PB_Any,0,0,WindowWidth(tmpwin),WindowHeight(tmpwin),addr.s,#PB_Web_Edge) 
 CompilerDefault
  tmpweb = WebGadget(#PB_Any,0,0,WindowWidth(tmpwin),WindowHeight(tmpwin),addr.s)
CompilerEndSelect

logoimg = CatchImage(#PB_Any,?logo)
logoimgwin = CatchImage(#PB_Any,?logo)
StartDrawing(ImageOutput(logoimgwin))
FillArea(ImageHeight(logoimgwin)/2,ImageWidth(logoimgwin)/2,#Black)
StopDrawing()


systrayicon = AddSysTrayIcon(#PB_Any, WindowID(tmpwin), ImageID(logoimg))
systraymenu = CreatePopupImageMenu(#PB_Any, #PB_Menu_SysTrayLook)
MenuItem(0, "• Hide &Window"+Chr(9)+"H",ImageID(logoimgwin))
MenuBar()
MenuItem(1, "E&xit"+Chr(9)+"X",ImageID(logoimg))

  ; Associate the menu to the systray
  SysTrayIconMenu(systrayicon, MenuID(systraymenu))

BindEvent(#PB_Event_SizeWindow, @SizeWindowHandler())
BindEvent(#PB_Event_MoveWindow, @WindowHandler())
BindEvent(#PB_Event_MaximizeWindow, @WindowHandler())
BindEvent(#PB_Event_MinimizeWindow, @WindowHandler())

Repeat
  Delay(1)
  ev = WaitWindowEvent(1)
  Select ev
    Case #PB_Event_CloseWindow
      showwindow = 1
      HideWindow(tmpwin,showwindow)
      SetMenuItemText(systraymenu,0,"√ Show &Window"+Chr(9)+"S")     
    Case #PB_Event_Menu
      Select EventMenu()
        Case 0          
          showwindow = 1 - showwindow
          HideWindow(tmpwin,showwindow)
          Select showwindow
            Case 1
              SetMenuItemText(systraymenu,0,"√ Show &Window"+Chr(9)+"S")
            Case 0
              SetMenuItemText(systraymenu,0,"• Hide &Window"+Chr(9)+"H") 
          EndSelect
        Case 1
          Quit = #True
      EndSelect
    Case #PB_Event_SysTray
      Select EventType()
        Case #PB_EventType_LeftClick
          DisplayPopupMenu(systraymenu,WindowID(tmpwin))
        Case #PB_EventType_LeftDoubleClick
          HideWindow(tmpwin,#False)
      EndSelect    
  EndSelect
Until Quit = #True

End

DataSection
  logo:
  IncludeBinary "logo.png"  
EndDataSection
; IDE Options = PureBasic 6.21 (Windows - x86)
; CursorPosition = 135
; FirstLine = 107
; Folding = -
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; SharedUCRT
; EnableOnError
; UseIcon = logo.ico
; Executable = HassIOx86C.exe
; CompileSourceDirectory
; Compiler = PureBasic 6.21 - C Backend (Windows - x64)
; EnablePurifier