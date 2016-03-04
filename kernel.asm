:entry
    JSR device_discovery  
    JSR init_vram          ; Setup LEM
    SET PUSH, mon_str
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
:print_str
    SET PUSH, Z
    SET Z, SP
    SET PUSH, I
    SET I, [vram]
    SET PUSH, J
    SET J, [Z+2]

:printloop
    IFE [J], 0
    SET PC, EndLoop
    BOR [J], 0xf000
    STI, [I], [J]
    SET PC, printloop
:EndLoop ;finished
    SET J, POP
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
	DAT 0xf615, 0x7349, "  X. LEM-1802 Monitor           ", 0
	DAT 0x7406, 0x30cf, "  X. Generic Keyboard           ", 0
	DAT 0xb402, 0x12d0, "  X. Generic Clock              ", 0
	DAT 0x4cae, 0x74fa, "  X. HMD2043 Harold Media Drive ", 0
	DAT 0xbf3c, 0x42ba, "  X. SPED3 Display              ", 0

:known_device_count
	DAT 5

:discovered_devices
	DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

:vram
	DAT 0x5000
:mon_str
	DAT "Hello World!" 0

