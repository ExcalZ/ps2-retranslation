@ECHO OFF

REM // make sure we can write to the file ps2built.bin
REM // also make a backup to ps2built.prev.bin
IF NOT EXIST ps2built.bin goto LABLNOCOPY
IF EXIST ps2built.prev.bin del ps2built.prev.bin
IF EXIST ps2built.prev.bin goto LABLNOCOPY
move /Y ps2built.bin ps2built.prev.bin
IF EXIST ps2built.bin goto LABLERROR3
:LABLNOCOPY

REM // delete some intermediate assembler output just in case
IF EXIST ps2.p del ps2.p
IF EXIST ps2.p goto LABLERROR2
IF EXIST ps2.h del ps2.h
IF EXIST ps2.h goto LABLERROR1

REM // clear the output window
REM cls

REM // run the assembler
REM // -xx shows the most detailed error output
REM // -E creates log file for errors/warnings
REM // -A gives us a small speedup
set AS_MSGPATH=AS/win32
set USEANSI=n

REM // allow the user to choose to output error messages to file by supplying the -logerrors parameter
IF "%1"=="-logerrors" ( "AS/win32/asw.exe" -xx -c -E -A -L ps2.asm ) ELSE "AS/win32/asw.exe" -xx -c -E -A -L ps2.asm

REM // if there were errors, a log file is produced
IF EXIST ps2.log goto LABLERROR4

REM // combine the assembler output into a rom
IF EXIST ps2.p "AS/win32/ps2p2bin" ps2.p ps2built.bin ps2.h

REM // done -- pause if we seem to have failed, then exit
IF NOT EXIST ps2.p goto LABLPAUSE
IF NOT EXIST ps2built.bin goto LABLPAUSE
fixheader ps2built.bin
exit /b
:LABLPAUSE

pause


exit /b

:LABLERROR1
echo Failed to build because write access to ps2.h was denied.
pause


exit /b

:LABLERROR2
echo Failed to build because write access to ps2.p was denied.
pause


exit /b

:LABLERROR3
echo Failed to build because write access to ps2built.bin was denied.
pause

exit /b

:LABLERROR4
REM // display a noticeable message
echo.
echo ***************************************************************************
echo *                                                                         *
echo *   There were build errors/warnings. See ps2.log for more details.   *
echo *                                                                         *
echo ***************************************************************************
echo.
pause

