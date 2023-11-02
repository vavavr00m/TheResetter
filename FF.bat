::ACKNOWLEDGMENT
::@Matt - Auto-elevate batch script - https://stackoverflow.com/a/12264592/21996598
::@angelofmercy - https://cgpeers.to/user.php?id=623829 - for the original script
::@llexandro - https://cgpeers.to/user.php?id=379971 - for sharing the script
::@MC ND - How to use a wildcard in folder path - https://stackoverflow.com/a/25794897
::@Mofi - How to kill multiple processes with space in filename - https://stackoverflow.com/a/67106787/11432377
::@dbenham - How to make a batch delete itself - https://stackoverflow.com/a/20333575/21996598
::@vavavr00m - https://github.com/vavavr00m - Adaptation

::::::::::::::::::::::::::::::::::::::::::::
:: Elevate.cmd - Version 4
:: Automatically check & get admin rights
:: see "https://stackoverflow.com/a/12264592/1016343" for description
::::::::::::::::::::::::::::::::::::::::::::
 @echo off
 CLS
 ECHO.
 ECHO =============================
 ECHO Running Admin shell
 ECHO =============================

:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~dpnx0"
 rem this works also from cmd shell, other than %~0
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO.
  ECHO **************************************
  ECHO Invoking UAC for Privilege Escalation
  ECHO **************************************

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"
  
  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

 ::::::::::::::::::::::::::::
 ::START
 ::::::::::::::::::::::::::::

set choicepath=

for /d %%a in (
  "%programfiles%\Filter Forge *"
) do (
	rem Searching for Filter Forge in Program Files...
	if exist "%%~fa\Bin\Filter Forge.exe" ( 
		echo Found - Filter Forge
		rem Setting theFolder to "%%~fa\Bin\Filter Forge.exe"
		set "theFolder=%%~fa\Bin\Filter Forge.exe
		if defined theFolder ( echo Set - theFolder to "%theFolder%" ) else ( echo Unable to set variable - theFolder. Exiting.. && pause>nul && goto eof )
	) else ( 
		echo Not found - Filter Forge
	)
)
rem Setting process list...
echo\
set Processes="Filter Forge x64.exe|Filter Forge x64.exe","Filter Forge.exe|Filter Forge.exe","Photoshop.exe|Photoshop.exe"
set choicepath=kill
if defined choicepath ( echo Set - choicepath to %choicepath% ) else ( echo Unable to set variable - choicepath )
if defined Processes ( echo Set - Processes to %Processes% && goto :CHECK_PROCESSES ) else ( echo Unable to set variable - Processes )
exit /b 0

:CHECK_PROCESSES
echo\
setlocal EnableExtensions DisableDelayedExpansion
for %%G in (%Processes%) do for /F "eol=| tokens=1* delims=|" %%H in (%%G) do (
    %SystemRoot%\System32\tasklist.exe /NH /FI "imagename eq %%H" 2>nul | %SystemRoot%\System32\find.exe /I "%%H" >nul
    if not errorlevel 1 (
        echo Running - %%I
        color 0C
		if %choicepath%==kill ( echo\ && echo Terminating - %%I && %SystemRoot%\System32\taskkill.exe /f /IM "%%H" >nul )
		if %choicepath%==relaunch ( goto eof )
    ) else (
		color 0A
        echo Not running - %%I
    )
)
if %choicepath%==kill ( goto :DELETE_FOLDERS )
if %choicepath%==relaunch ( goto :START_PROGRAM )
endlocal
exit /b 0

:DELETE_FOLDERS
echo\
FOR %%b in ("%programdata%\Filter Forge Data","%programdata%\G6zG65RmQZCmtZ07R","%programdata%\hzd3LK31QZCmtZ07Rj","%appdata%\Filter Forge Data") do ( 
    if exist "%%~b" ( echo Deleting - "%%~b" && rd /s /q "%%~b" 
		if exist "%%~b" ( echo Error deleting - "%%~b" )
	) else ( echo Nonexistent - "%%~b" )
)
set choicepath=relaunch
goto :CHECK_PROCESSES
exit /b 0

:START_PROGRAM
if exist "%theFolder%" ( echo\ && echo Launching - Filter Forge && start "" /min "%theFolder%" )
echo\ && echo END

REM This will delete the script
(goto) 2>nul & del "%~f0"

exit /b 0
