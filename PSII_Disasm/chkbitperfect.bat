@ECHO OFF

REM // build the ROM
call build %1

REM  // run fc
echo -------------------------------------------------------------
IF EXIST ps2built.bin ( fc /b ps2built.bin ps2original.bin
) ELSE echo ps2built.bin does not exist, probably due to an assembly error

REM // clean up after us
IF EXIST ps2.p del ps2.p
IF EXIST ps2.h del ps2.h
IF EXIST ps2.lst del ps2.lst
IF EXIST ps2built.bin del ps2built.bin
IF EXIST ps2built.prev.bin del ps2built.prev.bin
IF EXIST ps2.log ( IF "%1"=="-pe" del ps2.log )

REM // if someone ran this from Windows Explorer, prevent the window from disappearing immediately
pause
