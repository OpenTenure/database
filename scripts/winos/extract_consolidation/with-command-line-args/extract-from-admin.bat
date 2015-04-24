@ECHO off
REM 2015-01-11
REM Windows batch script to extract the data during the process of consolidation. 
REM Before running this script, make sure the variable script_dir is correctlly set.

REM Configure variables to use for script
SET script_dir=C:\Program Files\PostgreSQL\9.3\bin\
REM SET script_dir=c:\Program Files (x86)\PostgreSQL\9.2\bin\
SET psql="%script_dir%psql.exe"
SET pg_dump="%script_dir%pg_dump.exe"

SET host=localhost
SET port=5432
SET dbname=sola
SET username=postgres
SET pword=PRGS143
SET administrator=%1

REM everything Y/N
SET everything=%2

REM generate_consolidation_schema Y/N
SET generate_consolidation_schema=%3

REM dump_to_file Y/N
SET dump_to_file=%4

REM Set the file name
SET extracted_file_name=%5

REM Set the backup folder
SET folder_backup=%6

REM Set the log folder
SET folder_log=%7

SET LOG="%folder_log%\%extracted_file_name%.log"
SET extracted_full_file_name="%folder_backup%\%extracted_file_name%.backup"

REM Set the PGPASSWORD environement variable
SET PGPASSWORD=%pword%

echo Extraction process started at %date% %time% > %LOG% 2>&1
IF /I "%generate_consolidation_schema%"=="N" GOTO DUMP_TO_FILE_MOMENT
echo Everything will be extracted: %everything%  >> %LOG% 2>&1
echo -------------------------------------------------------------------------------- >> %LOG% 2>&1
echo Generate consolidation schema started at %date% %time% >> %LOG% 2>&1
%psql% --host=%host% --port=%port% --dbname=%dbname% --username=%username% --command="select system.consolidation_extract('%administrator%', 'y'=lower('%everything%'), '%extracted_file_name%')" --set=VERBOSITY=terse >> %LOG% 2>&1
echo Generate consolidation schema finished at %date% %time% >> %LOG% 2>&1
echo --------------------------------------------------------------------------------
:DUMP_TO_FILE_MOMENT
IF /I "%dump_to_file%"=="N" GOTO FINISH
echo -------------------------------------------------------------------------------- >> %LOG% 2>&1

echo Dump to file started at %date% %time% >> %LOG% 2>&1
%pg_dump% -h %host% -p %port% -U %username% -Fc -n "consolidation" --no-owner --verbose -x -f %extracted_full_file_name% %dbname%  >> %LOG% 2>&1

echo Dump to file finished at %date% %time% >> %LOG% 2>&1
echo -------------------------------------------------------------------------------- >> %LOG% 2>&1
:FINISH
echo Extraction process finished at %date% %time% >> %LOG% 2>&1
