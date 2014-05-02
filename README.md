<h1>Documentation</h1>
<p>cmd Scripts for Windows for doing daily, weekly, monthly and yearly backups of a specific path in multiple generations. The script uses the windows standard command line tool 'robocopy' to create the backups.</p>

<h2>Syntax</h2>
<p>Since the comments in the scripts are in german, this documentation explains the same in english.</p>
<pre>
  backup_fhw.cmd &lt;src&gt; &lt;dst&gt; &lt;n&gt;|m [-i] [-z [-d][-c]] 
                  &lt;src&gt; - Source directory. Will be backed up with all sub directories.
                  &lt;dst&gt; - Destination direcotry to hold the backup.
                    &lt;n&gt; - Number of generations to create for the backup. 
                          Every generation is a subdirectory of &lt;dst&gt;.
                          The script reads the last created generation from the file
                          'generation' in &lt;dst&gt; and adds 1 to that number. 
                          If the new generation is greater than &lt;n> the new generation
                          will be changed to 1 and the subdirectory 1 of &lt;dst&gt; will be
                          overwritten since this is the oldest generation.
                     -m - Manual backup. Overwrites the last manual backup in the
                          subdirectory 'manuell' of &lt;dst&gt;.
                     -i - If not set the script stopps Services configured in file 
                          'config.cmd' and restarts them after backup.
                          If set the script stops no services during the backup.
                     -z - If set the backup in &lt;dst&gt; will be created as a zip archive.
                     -d - Effective only if '-z' was set. 
                          If set only the zip archive remains at &lt;dst&gt; after backup.
                     -c - Effective only if '-z' was set.
                          Creates a copy of the created zip archive to the file 
                          'current.zip'. So the file 'current.zip' always contains
                          the last backup.
</pre>

<h2>Examples</h2>
<p>Use the windows task sheduler for calling the the script 'backup_fhw.cmd' in the period you want.</p>
<h3>Daily backup</h3>
<p>This keeps 7 generations of the source folder.</p>
<pre>
  C:\backup_fhw\backup_fhw.cmd c:\xampp f:\backup_fhw\daily 7
</pre>
<h3>Weekly backup</h3>
<p>This keeps 4 generations of the source folder only zipped and copies the newest zip archive also to 'current.zip'.</p>
<pre>  
  C:\backup_fhw\backup_fhw.cmd c:\xampp f:\backup_fhw\weekly 4 -z -d -c
</pre>
<h3>Manual backup</h3>
<p>This overwrites the manual backup in the subdirectory 'manuell' in the destination directory.</p>
<pre>
  C:\backup_fhw\backup_fhw.cmd c:\xampp f:\backup_fhw -m
</pre>
