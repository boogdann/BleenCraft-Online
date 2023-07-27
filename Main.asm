format PE GUI 4.0
entry Start

include 'win32a.inc'
include '\Units\Field\Field.const'
include '\Units\Blocks\Blocks.const'
include '\Units\Tools\Tools.const'
include '\Units\Obj3D\Obj3D.const'
section '.text' code readable writeable executable

Start:  
   stdcall Field.Initialize
   stdcall Blocks.GetDestroyTime, Blocks.LEAVES, Tools.AXE
   stdcall Field.SetBlockIndex, 1, 10, 5, 13
   mov    eax, 123
   stdcall Field.GetBlockIndex, 1, 10, 5
;  stdcall AddObject, arrPosition, arrTurn, arrVertex, arrVertexIndexes, arrScale, arrNormals
  stdcall Blocks.GetTextureHandle, 10
  invoke GetModuleHandle, 0
  mov [wc.hInstance], eax
  invoke LoadIcon, 0, IDI_APPLICATION
  mov [wc.hIcon], eax
  invoke  LoadCursor, 0, IDC_ARROW                    
  mov [wc.hCursor], eax
  invoke RegisterClass, wc                            
  test eax, eax
  jz error

  invoke CreateWindowEx, 0, _class, _title, WS_VISIBLE + WS_DLGFRAME + WS_SYSMENU,\
                         128, 128, 256, 192, NULL, NULL, [wc.hInstance], NULL
  test eax, eax
  jz error


msg_loop:
  invoke GetMessage, msg, NULL, 0, 0
  cmp eax, 1
  jb end_loop
  jne msg_loop
  invoke TranslateMessage, msg
  invoke DispatchMessage, msg
  jmp msg_loop

error:
  invoke MessageBox, NULL, _error, NULL, MB_ICONERROR + MB_OK

end_loop:
  invoke ExitProcess, [msg.wParam]

proc WindowProc uses ebx esi edi, hwnd, wmsg, wparam, lparam
  cmp [wmsg], WM_DESTROY
  je .wmdestroy
  
.defwndproc:
  invoke DefWindowProc, [hwnd], [wmsg], [wparam], [lparam]
  jmp .finish
  
.wmdestroy:
  invoke PostQuitMessage,0
  xor eax, eax
  
.finish:
  ret
endp
  
  include '\Units\Field\Field.code'
  include '\Units\Blocks\Blocks.code'
  include '\Units\Obj3D\Obj3D.code'
section '.data' data readable writeable
  
  arrPosition          dd       123, 123, 123
  arrTurn              dd       100, 100, 100
  arrScale             dd       999
  arrVertex            dd       2, 666, 666
  arrVertexIndexes     dd       2, 777, 777
  arrNormals           dd       2, 888, 888
  

  hHeap                dd       ?   
   
  _class TCHAR 'FASMWIN32', 0
  _title TCHAR 'Win32 program template', 0
  _error TCHAR 'Startup failed.', 0

  wc WNDCLASS 0, WindowProc, 0, 0, NULL, NULL, NULL, COLOR_BTNFACE + 1, NULL, _class
  msg MSG
;  include '\Units\Types\Types.type'
section '.idata' import data readable writeable

  include '\Units\Field\Field.di'
  include '\Units\Blocks\Blocks.di'
  include '\Units\Obj3D\Obj3D.di'
  include '\Units\Tools\Tools.di'
  
  library kernel32, 'KERNEL32.DLL',\
	  user32, 'USER32.DLL'
    
  include 'api\kernel32.inc'
  include 'api\user32.inc'
    
  include '\Units\Obj3D\Obj3D.du'
  include '\Units\Field\Field.du'
  include '\Units\Blocks\Blocks.du'
  include '\Units\Tools\Tools.du'