backup_fhw
==========

cmd Scripts for Windows for doing daily, weekly, monthly and yearly backups of a specific path in multiple generations.

Syntax
  backup_fhw.cmd <quelle> <ziel> <n>|m [-i] [-z [-d][-c]] 
              <quelle>  - Quellverzeichnis das mit all seinen Unterverzeichnissen 
                                gesichert wird.
                <ziel>  - Zielverzeichnis, in das die Sicherung erzeugt wird.
                   <n>  - Ganze Zahl. Anzahl an Generationen, die angelegt werden sollen.
                          Das Skript prueft anhand der Datei "generation" die letzte 
                          angelegte Generation und addiert diese Zahl mit 1.
                          Ist die neue Generation groesser als <n>, so ist die neue 
                          Generation 1. Die Nummer der errechneten Generation ist ein
                          Unterverzeichnis von <ziel>.
                     -m - Manuelle Sicherung. ueberschreibt die letzte manuelle Sicherung
                          im Unterverzeichnis "manuell" von <ziel>.
                     -i - Falls gesetzt werden die Server während des Backups nicht 
                          gestoppt.
                     -z - Falls gesetzt wird das Backup im Zielordner als ZIP-Version zur
                          Verfügung gestellt.
                          Hat nur Wirkung, falls "-i" gesetzt. Falls gesetzt wird das 
                          Backup nach dem Zippen gelöscht, so dass nur die gezippte 
                          Version bleibt.
                     -c - Hat nur Wirkung, falls "-i" gesetzt. Kopiert die erstellte ZIP
                          Datei nach "current.zip", damit diese immer aktuell ist.
                          Das kann für den Download des letzten Backups genutzt werden.
