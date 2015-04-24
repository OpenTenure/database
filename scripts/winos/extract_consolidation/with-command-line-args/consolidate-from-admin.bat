@ECHO off
REM 2015-01-11
REM Windows batch script to merge/consolidate records extracted from another system during the process of consolidation. 
REM Do not forget to set the password of the database connection. Search in this file for <PASSWORD COMES HERE>.
REM This file expects command line arguments listed here below: 

REM User running the consolidations
SET administrator=%1

REM merge_consolidation_schema Y/N
SET merge_consolidation_schema=%2

REM extracted_file_name. "N/A" if there is not extracted file present. It means the step of restore will be skipped.
SET extracted_file_name=%3

REM process_id
SET process_id=%4

REM Set the backup folder
SET folder_backup=%5

REM Set the log folder
SET folder_log=%6

REM Utility configuration
SET script_dir=C:\Program Files\PostgreSQL\9.3\bin\
REM SET script_dir=c:\Program Files (x86)\PostgreSQL\9.2\bin\
SET psql="%script_dir%psql.exe"
SET pg_restore="%script_dir%pg_restore.exe"

REM Database configuration
SET host=localhost
SET port=5432
SET dbname=sola
SET username=postgres
SET pword=<PASSWORD COMES HERE>

SET LOG="%folder_log%\%process_id%.log"

IF /I "%extracted_file_name%"=="N/A" GOTO SKIP_FILE_NAME
SET extracted_full_file_name="%folder_backup%\%extracted_file_name%.backup"
:SKIP_FILE_NAME
echo Consolidation process started at %date% %time% > %LOG% 2>&1
IF /I "%restore_extracted_file%"=="N/A" GOTO SKIP_RESTORE
echo -------------------------------------------------------------------------------- >> %LOG% 2>&1
echo Restore started at %date% %time% >> %LOG% 2>&1

%pg_restore% -h %host% -p %port% -d %dbname% -U %username% -c -j 4 -v %extracted_full_file_name% >> %LOG% 2>&1

echo Restore finished at %date% %time% >> %LOG% 2>&1
:SKIP_RESTORE
IF /I "%merge_consolidation_schema%"=="N" GOTO SKIP_MERGE
echo -------------------------------------------------------------------------------- >> %LOG% 2>&1
echo Checking and merging the restored data started at %date% %time% >> %LOG% 2>&1

echo Process ID %process_id% >> %LOG% 2>&1

%psql% --host=%host% --port=%port% --dbname=%dbname% --username=%username% --command="select system.consolidation_consolidate('%administrator%', '%process_id%')" --set=VERBOSITY=terse >> %LOG% 2>&1
echo Checking and merging the restored data finished at %date% %time% >> %LOG% 2>&1
echo -------------------------------------------------------------------------------- >> %LOG% 2>&1
:SKIP_MERGE
echo Consolidation process finished at %date% %time% >> %LOG% 2>&1
