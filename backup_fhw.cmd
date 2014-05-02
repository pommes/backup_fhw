@echo off  
rem ======================================================================  
::  
::  [backup_fhw]  
::  Sichert das FHW-Web
::  
rem ----------------------------------------------------------------------  
::  History  
::  V0.1 - 2010-09-19  Initialversion  
::  V0.2 - 2010-10-03  Das Generationenfile wird im Zielverzeichnis abgelegt,
::                     damit sich unterschiedliche Backups nicht stoeren.
::  V0.3 - 2011-03-11  Flags als Parameter ermöglicht und Flag für Ignore
::                     Server stop "-i" hinzugefügt.
::  V0.4 - 2011-04-05  Flag für ZIP Backup "-z" und "-d" hinzugefügt.
rem ======================================================================  
:: 
:: HELP:Das Skript sichert das FHW-Web mit robocopy in mehreren Generationen.
::
:: SYNTAX:SYNTAX:
:: SYNTAX:backup_fhw.cmd <quelle> <ziel> <n>|m [-i] [-z [-d][-c]] 
:: SYNTAX:  <quelle>  - Quellverzeichnis das mit all seinen Unterverzeichnissen 
:: SYNTAX:              gesichert wird.
:: SYNTAX:    <ziel>  - Zielverzeichnis, in das die Sicherung erzeugt wird.
:: SYNTAX:       <n>  - Ganze Zahl. Anzahl an Generationen, die angelegt werden sollen.
:: SYNTAX:              Das Skript prueft anhand der Datei "generation" die letzte 
:: SYNTAX:              angelegte Generation und addiert diese Zahl mit 1.
:: SYNTAX:              Ist die neue Generation groesser als <n>, so ist die neue 
:: SYNTAX:              Generation 1. Die Nummer der errechneten Generation ist ein
:: SYNTAX:              Unterverzeichnis von <ziel>.
:: SYNTAX:         m  - Manuelle Sicherung. ueberschreibt die letzte manuelle Sicherung
:: SYNTAX:              im Unterverzeichnis "manuell" von <ziel>.
:: SYNTAX:         -i - Falls gesetzt werden die Server während des Backups nicht 
:: SYNTAX:              gestoppt.
:: SYNTAX:         -z - Falls gesetzt wird das Backup im Zielordner als ZIP-Version zur
:: SYNTAX:              Verfügung gestellt.
:: SYNTAX:         -d - Hat nur Wirkung, falls "-i" gesetzt. Falls gesetzt wird das 
:: SYNTAX:              Backup nach dem Zippen gelöscht, so dass nur die gezippte 
:: SYNTAX:              Version bleibt.
:: SYNTAX:         -c - Hat nur Wirkung, falls "-i" gesetzt. Kopiert die erstellte ZIP
:: SYNTAX:              Datei nach "current.zip", damit diese immer aktuell ist.
:: SYNTAX:              Das kann für den Download des letzten Backups genutzt werden.
   
rem ----------------------------------------------------------------------  
::  CONFIG  
rem ----------------------------------------------------------------------    
  :: FOLGENDE VARIABLEN SOLLTEN NICHT VERAENDERT WERDEN
  :: Festlegen des Namens der Konfigurationsdatei
  set scriptdir=%~dp0
  set cfgfile=%scriptdir%config.cmd
  set sTitle=[backup_fhw]  
  set LINE=-------------------------------------------------------------------  
  set src=%1%
  set dst=%2%
  set gen=%3%
  set generationfile=%dst%\generation
  
  :: Mit Call die Konfiguration laden  
  call "%cfgfile%" 2>nul || (  
    echo.  
    echo ERROR - die Konfigurationsdatei
    echo %cfgfile%  
    echo wurde nicht gefunden. Exit.  
    pause   
  )
   
rem ----------------------------------------------------------------------  
::  MAIN  
rem ----------------------------------------------------------------------    
  echo %LINE%  
  echo %sTitle%  
  echo %LINE%  
  if "%src%"=="" goto help  
  if "%dst%"=="" goto showSyntax 
  if "%gen%"=="" goto showSyntax 
    
  :: Parameter auswerten
  if "%gen%"=="m" goto var_is_m
    set manual=0
	set /a gen+=0
	if %gen%==0 goto err_var
	  goto var_end
	:err_var
	  echo FEHLER: Der dritte Parameter muss "m" lauten oder eine Zahl sein.
	  goto END
  :var_is_m
    set manual=1
  :var_end
  
  :: Flags auswerten
  set flag_i=0  
  set flag_z=0
  set flag_d=0
  set flag_c=0
  for %%A in (%*) do (
    if "%%A"=="-i" set flag_i=1
	if "%%A"=="-z" set flag_z=1
	if "%%A"=="-d" set flag_d=1
	if "%%A"=="-c" set flag_c=1
  )
  
  :: Debug
  if %debug%==0 goto dbg1_end
    echo Parameter:
    echo src=%src%
	echo dst=%dst%
	echo gen=%gen%
	echo Manuelle Sicherung = %manual%
	echo flag_i = %flag_i%
  :dbg1_end
  
  :: Pruefe ob schon eine Generation existiert, sonst fange bei 1 an.
  if exist %generationfile% goto liesgeneration  
    echo 0 > %generationfile%
  goto liesgeneration 
  
  :: Lies die letzte Generation aus der Datei aus
  :: und leg die nächste Generation fest
  :: Falls generation größer als gen, setzen generationa auf 1
  :liesgeneration
  FOR /f %%f IN (%generationfile%) DO set generation=%%f
  set /a generation+=1
  if %generation%==0 goto err_generation
  goto generation_check_end
  :err_generation
      echo FEHLER: Die Datei %generationfile% ist korrupt. Sie enthaelt einen nicht numerischen Wert.
	  goto END
  :generation_check_end
  if %generation% LEQ %gen% goto next_gen_valid
    set /a generation=1
  :next_gen_valid
  
  :: Debug
  if %debug%==0 goto dbg2_end
    echo Naechste Generation=%generation%
  :dbg2_end
  
  :: Stoppe Dienste nur wenn flag_i nicht übergeben wurde
  if %flag_i%==1 goto stop_service_end
    net stop "%SRVNAME_HTTP%"
    net stop "%SRVNAME_FTP%"
    net stop "%SRVNAME_DB%"
	
	:: Rolliere logs
	cd %scriptdir%
	call rotate_log.cmd access.log "C:\xampp\apache\logs" 10
	cd %scriptdir%
	call rotate_log.cmd error.log "C:\xampp\apache\logs" 10
	
  :stop_service_end
  
  :: Erzeuge Backup
  if %manual%==1 goto backup_manual
    c:\Windows\System32\robocopy "%src%" "%dst%/%generation%" /MIR /FFT /Z /R:0 /W:1 /NDL /LOG:"%dst%/%generation%".log /ETA
	::echo %date% %time% > "%dst%/%generation%.txt"
	:: Merke aktuelle Generationsnummer in Datei
    echo %generation% > %generationfile% 
    goto backup_end
  :backup_manual
    c:\Windows\System32\robocopy "%src%" "%dst%/manuell" /MIR /FFT /Z /R:0 /W:1 /NDL /LOG:"%dst%/manuell".log /ETA
	::echo %date% %time% > "%dst%/manuell.txt"
  :backup_end
  
   
  :: Starte Dienste nur falls flag_i nicht gesetzt
  if %flag_i%==1 goto start_service_end
    net start "%SRVNAME_HTTP%"
    net start "%SRVNAME_FTP%"
    net start "%SRVNAME_DB%"   
  :start_service_end
 
 
  :: Erstelle eine ZIP-Version des Backups für den Download falls flag_z gesetzt.
  if %flag_z%==0 goto zip_end
    if %manual%==1 goto zip_manual
	  :: Erstelle ZIP des Backup-Verzeichnisses
	  set zip_current=%dst%\%generation%.zip
      %SEVEN_ZIP_BIN% a -tzip %zip_current%  %dst%\%generation%\*	  
	  if %flag_d%==0 goto zip_current
	    :: Lösche Backup, so dass nur ZIP Version erhalten bleibt
		rmdir /s /q %dst%\%generation%
	  goto zip_current
	:zip_manual
	  :: Erstelle ZIP des Backup-Verzeichnisses
	  set zip_current=%dst%\manuell.zip
	  %SEVEN_ZIP_BIN% a -tzip %zip_current% %dst%\manuell\*
	  if %flag_d%==0 goto zip_current
	    :: Lösche Backup, so dass nur ZIP Version erhalten bleibt
		rmdir /s /q %dst%\manuell	
    :zip_current	
      if %flag_c%==0 goto zip_end
	  :: Kopiere aktuelle ZIP-Datei nach current.zip	
	  copy %zip_current% %dst%\current.zip	  
	  date /T > %dst%\current.txt
	  time /T >> %dst%\current.txt
	  echo %zip_current% >> %dst%\current.txt
  :zip_end
 
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
