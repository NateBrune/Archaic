:entry
    JSR device_discovery  
    JSR init_vram          ; Setup LEM
    SET PUSH, 0x8800
    JSR paint_bg
    SET PUSH, 0x7800       ; How to BOR the string
    SET PUSH, [op_arg_magic]       ; Says that there is an optional argument
    SET PUSH, MainMenu_Welcome_str
    SET PUSH, 0x7800dd       ; How to BOR the string
    SET PUSH, [op_arg_magic]       ; Says that there is an optional argument
    SET PUSH, MainMenu_Welcome_str
    JSR print_str
    SUB PC, 1
:init_vram
    SET PUSH, B
    SET B, [vram]
    SET PUSH, 0 ; Return value
    SET PUSH, 0x7349
    SET PUSH, 0xf615
    JSR find_device
    ADD SP, 2
    HWI, POP
    SET B, POP
    SET PC, POP

; Prints string directly to the screen, no new line
; Z+2 = BOR Z+0, Z+2  ; color 
; Z+1 = Optional argument magic
; ^ Optional ^
; Z+0 = Pointer to string
:print_str
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, J
    SET PUSH, I
    SET I, [vram]
    SET J, [Z+0]
    IFE [Z+1], [op_arg_magic]
    SET PC, printloopcolor

:printloopdefault
    IFE [J], 0
    SET PC, .EndPrintLoop
    BOR [J], [system_colors]
    STI, [I], [J]
    SET PC, printloopdefault
:printloopcolor
    IFE [J], 0
    SET PC, .EndPrintLoop
    BOR [J], [Z+2]
    STI, [I], [J]
    SET PC, printloopcolor
:.EndPrintLoop ;finished
    SET I, POP
    SET J, POP
    SET Z, POP
    SET PC, POP

; Prints string directly to the screen, no new line
; Z+0 = Paint color
:paint_bg
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, I
    SET I, [vram]
    SET PUSH, X
    SET X, [vram]
    ADD X, 0x0180             ; 0x0180 is the full length of the screen

:paintloop
    IFE I, X                  ; If we reached the end of the buffer
    SET PC, .EndPaintLoop
    STI, [I], [Z+0]
    SET PC, paintloop
:.EndPaintLoop ;finished
    SET X, POP
    SET I, POP
    SET Z, POP
    SET PC, POP

; device discovery
:device_discovery
    SET PUSH, I
    SET PUSH, A
    SET PUSH, B
    SET PUSH, C
    SET PUSH, J
    SET PUSH, X
    SET PUSH, Y
    SET PUSH, Z
    HWN I
:device_loop
    SUB I, 1
    HWQ I
    
    SET J, known_devices
    SET Z, 0    ; counter for inner loop

:device_loop2
    IFE A, [J]  ; compare the device ID with the known device IDs
    IFE B, [J+1]
    SET [discovered_devices + I], J
    ADD J, 35   ; move J to location of next device in known_devices
    
    ADD Z, 1
    IFN Z, [known_device_count]   ; continue in inner loop for each known device
    SET PC, device_loop2
    
    IFE I, 0    ; if we've reached the end of devices, return
    SET PC, doneDeviceLoop
    SET PC, device_loop
:doneDeviceLoop
    SET Z, POP
    SET Y, POP
    SET X, POP
    SET J, POP
    SET C, POP
    SET B, POP
    SET A, POP
    SET I, POP
    SET PC, POP ; pop pop ( Community )
; Find Device 
; Z+2 = location to store device index, or 0xffff if not found
; Z+1 = device ID 1
; Z+0 = device ID 2
; Z+0 = location to store device index, or 0xffff if not found
:find_device
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, Y
    SET PUSH, X
    SET PUSH, I
    SET [C], 0xffff
    SET X, discovered_devices
    SET I, 0

:find_device_loop
    SET Y, [X]
    IFE [Y], [Z+1]
    IFE [Y+1], [Z+0]
    SET [Z+2], I     ; Return Value
    ADD I, 1
    ADD X, 1
    IFL I, 16
    SET PC, find_device_loop
    SET I, POP
    SET X, POP
    SET Y, POP
    SET Z, POP
    SET PC, POP

; 35 bytes each
:known_devices
    DAT 0xf615, 0x7349, 0 ;"  X. LEM-1802 Monitor           ", 0
    DAT 0x7406, 0x30cf, 0 ;"  X. Generic Keyboard           ", 0
    DAT 0xb402, 0x12d0, 0 ;"  X. Generic Clock              ", 0
    DAT 0x4cae, 0x74fa, 0 ;"  X. HMD2043 Harold Media Drive ", 0
    DAT 0xbf3c, 0x42ba, 0 ;"  X. SPED3 Display              ", 0

:known_device_count
    DAT 5

:discovered_devices
    DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

:vram
    DAT 0x5000
:op_arg_magic
    DAT 0x4545;
:system_colors
    DAT 0xf000
:UI_Bar
    DAT "                              ", 0
:MainMenu_Welcome_str
    DAT "     Welcome to Archaic!      ", 0

