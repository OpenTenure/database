@ECHO off
REM 2014-10-11
REM Windows batch script to merge/consolidate records extracted from another system during the process of consolidation. 
REM Before running this script, make sure the variable script_dir is correctlly set.

REM Configure variables to use for script
SET current_dir=%~dp0
SET script_dir=C:\Program Files\PostgreSQL\9.3\bin\
REM SET script_dir=c:\Program Files (x86)\PostgreSQL\9.2\bin\
SET psql="%script_dir%psql.exe"
SET pg_restore="%script_dir%pg_restore.exe"
SET data_path=%current_dir%data\
SET host=localhost
SET port=5432
SET dbname=sola
SET username=postgres
SET administrator=test-id
SET merge_consolidation_schema=Y
SET restore_extracted_file=Y

REM Set the consolidation process id
for /f "tokens=1-5 delims=./- " %%d in ("%date%") do set process_id=consolidation_%%g_%%f_%%e
for /f "tokens=1-5 delims=: " %%d in ("%time%") do set process_id=%process_id%_%%d_%%e


REM Prompt the user for variable override values
SET /p host= Host name [%host%] :
SET /p port= Port [%port%] :
SET /p dbname= Database name [%dbname%] :
SET /p username= Username [%username%] :
SET /p pword= DB Password [?] :
REM Get the password from the command line and set the PGPASSWORD environ variable
SET PGPASSWORD=%pword%


SET /p restore_extracted_file= Restore extracted file? (Y/N) [%restore_extracted_file%] :
IF /I "%restore_extracted_file%"=="N" GOTO QUESTION_MERGE_CONSOLIDATION_SCHEMA
SET /p extracted_file_name= Type the file of the extraction. It should be found in folder %data_path%. The name of the file only without extension and without the foldername. :
:QUESTION_MERGE_CONSOLIDATION_SCHEMA
SET /p merge_consolidation_schema= Merge consolidation schema? (Y/N) [%merge_consolidation_schema%] :
IF /I "%merge_consolidation_schema%"=="N" GOTO GO_ON
SET /p administrator= Type the id of the administrator of Sola [%administrator%] :

:GO_ON
SET LOG="%data_path%%process_id%.log"

echo.
echo.
echo.
echo.
IF /I "%restore_extracted_file%"=="N" GOTO SKIP_FILE_NAME
SET extracted_full_file_name="%data_path%%extracted_file_name%.backup"
echo Extracted file to be consolidated is : %extracted_full_file_name%
:SKIP_FILE_NAME
echo with log : %LOG%
echo Consolidation process started at %date% %time%
echo Consolidation process started at %date% %time% > %LOG% 2>&1
IF /I "%restore_extracted_file%"=="N" GOTO SKIP_RESTORE
echo --------------------------------------------------------------------------------
echo -------------------------------------------------------------------------------- >> %LOG% 2>&1
echo Restore started at %date% %time%
echo Restore started at %date% %time% >> %LOG% 2>&1

%pg_restore% -h %host% -p %port% -d %dbname% -U %username% -c -j 4 -v %extracted_full_file_name% >> %LOG% 2>&1

echo Restore finished at %date% %time%
echo Restore finished at %date% %time% >> %LOG% 2>&1
:SKIP_RESTORE
IF /I "%merge_consolidation_schema%"=="N" GOTO SKIP_MERGE
echo --------------------------------------------------------------------------------
echo -------------------------------------------------------------------------------- >> %LOG% 2>&1
echo Checking and merging the restored data started at %date% %time%
echo Checking and merging the restored data started at %date% %time% >> %LOG% 2>&1

echo Process ID %process_id% >> %LOG% 2>&1

%psql% --host=%host% --port=%port% --dbname=%dbname% --username=%username% --command="select system.consolidation_consolidate('%administrator%', '%process_id%')" --set=VERBOSITY=terse >> %LOG% 2>&1
echo Checking and merging the restored data finished at %date% %time%
echo Checking and merging the restored data finished at %date% %time% >> %LOG% 2>&1
echo --------------------------------------------------------------------------------
echo -------------------------------------------------------------------------------- >> %LOG% 2>&1
:SKIP_MERGE
echo Consolidation process finished at %date% %time%
echo Consolidation process finished at %date% %time% >> %LOG% 2>&1
echo.
echo.
echo Check log file "%LOG%" to find out if everything finished ok.

pause
