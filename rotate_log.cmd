@echo off
rem ======================================================================
:: 
::  [rotate_log]
::  Rotiert eine fortgeschriebene Datei.
::  WICHTIG: Funktioniert nur auf Deutschen Betriebssystemen, wegen der 
::           Interpretation der Ausgabe von 'date' und 'time'!
::
rem ======================================================================
::  History
::  V0.1 - 2011-04-02  Initialversion
rem ======================================================================
::
:: HELP:Das Skript rotiert eine fortgeschriebene Logdatei auf folgende Weise:
::  1. Verschiebt eine Datei.
::  2. Legt die Datei leer an, so dass in die neue Datei geloggt wird.
::  3. Packt die verschobene Datei.
::  4. Löscht alte gepackte Dateien.
::
:: SYNTAX:SYNTAX:
:: SYNTAX:rotate_log.cmd <filename> <dir> <n>
:: SYNTAX:   <filename>  - Name der Datei, die rotiert werden soll.
:: SYNTAX:        <dir>  - Verzeichnis in dem die Quelldatei liegt.
:: SYNTAX:          <n>  - Ganze Zahl. Anzahl an Generationen der gepackten Logfiles, 
:: SYNTAX:                 die aufgehoben werden sollen.
::

rem ======================================================================
::  CONFIG
rem ======================================================================
  :: FOLGENDE VARIABLEN SOLLTEN NICHT VERAENDER WERDEN
  :: Fetlegen des Namens der Konfigurationsdatei
  set scriptdir=%~dp0
  set cfgfile=%scriptdir%config.cmd
  set sTitle=[rotate_log]
  set LINE=--------------------------------------------------------------------
  set filename=%1%
  set dir=%2%
  set gen=%3%
    
  :: Mit Call die Konfiguration laden  
  call "%cfgfile%" 2>nul || (  
    echo.  
    echo ERROR - die Konfigurationsdatei
    echo %cfgfile%  
    echo wurde nicht gefunden. Exit.  
    pause   
  )

rem ======================================================================
::  MAIN
rem ======================================================================
  echo %LINE%
  echo %sTitile%
  echo %LINE%
  if "%filename%"=="" goto help
  if "%dir%"=="" goto showSyntax
  if "%gen%"=="" goto showSyntax

  :: generate date and time variables
  :: may need to swap around the k j i variables to get the yyyymmdd format
  for /F "tokens=3,4,5 delims=. " %%i in ('echo.^|date^|find "Aktuell" ') do set trdt=%%k%%j%%i
  :: the following should get the windows time to get the hhmmsstt format
  for /F "tokens=3,4,5 delims=:, " %%i in ('echo.^|time^|find "Aktuell" ') do set trtt=%%i%%j%%k
  set nftu=%trdt%_%trtt%
  
  :: change to the apache log file directory
  cd %dir%
  
  :: 1. Rotate
  echo %nftu% >> %filename%
  move %filename% %filename%.%nftu%
  
  :: 2. Create empty logfile
  type NUL > %filename%
  
  :: 3. ZIP file
  :: zip the files
  %SEVEN_ZIP_BIN% a -tzip %filename%.%nftu%.zip %filename%.%nftu%
  del /Q %filename%.%nftu%

  :: 4. Löscht alte gepackte Dateien
  :: make list of archive zip files
  type NUL > %filename%.%nftu%.archlist
  for /F "tokens=1,2 delims=[] " %%i in ('dir /B %filename%.*.zip ^| find /N "%filename%"') do echo  %%i = %%j>> %filename%.%nftu%.archlist

  :: count total number of files
  for /F "tokens=1 delims=" %%i in ('type %filename%.%nftu%.archlist ^| find /C "%filename%"') do set tnof=%%i

  :: setup for and create the deletion list
  set /a negtk=%gen%*-1
  set /a tntd=%tnof% - %gen%

  type NUL>%filename%.%nftu%.dellist
  for /L %%i in (%negtk%,1,%tntd%) do find " %%i = " %filename%.%nftu%.archlist >> %filename%.%nftu%.dellist

  :: del the old files
  for /F "tokens=3 delims= " %%i in ('find "%filename%" %filename%.%nftu%.dellist') do del /Q %%i

  :: remove temp files
  del /Q %filename%.%nftu%.archlist
  del /Q %filename%.%nftu%.dellist
  
  :: END
  goto END
  
  :help  
  echo.  
  for /F "tokens=2* delims=:" %%a in ('findstr "^::.*HELP:" "%0"') do echo %%a  
  
  :showSyntax  
  echo.  
  for /F "tokens=2* delims=:" %%a in ('findstr "^::.*SYNTAX:" "%0"') do echo.%%a  
  echo.  
  goto END  
    
   
rem ----------------------------------------------------------------------  
::  the end of all  
rem ----------------------------------------------------------------------  
  :END  
  echo %LINE%  
  echo %0 wurde beendet.     
   
rem ======================================================================  
::  EOF  
rem ======================================================================  
