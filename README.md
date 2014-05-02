backup_fhw
==========

cmd Scripts for Windows for doing daily, weekly, monthly and yearly backups of a specific path.

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
