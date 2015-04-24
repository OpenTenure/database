@ECHO off
REM 2014-10-11
REM Windows batch script to extract the data during the process of consolidation. 
REM Before running this script, make sure the variable script_dir is correctlly set.

REM Configure variables to use for script
SET current_dir=%~dp0
SET data_dir=%current_dir%data\
SET script_dir=C:\Program Files\PostgreSQL\9.3\bin\
REM SET script_dir=c:\Program Files (x86)\PostgreSQL\9.2\bin\
SET psql="%script_dir%psql.exe"
SET pg_dump="%script_dir%pg_dump.exe"
SET host=localhost
SET port=5432
SET dbname=sola
SET username=postgres
SET administrator=test-id
SET everything=N
SET generate_consolidation_schema=Y
SET dump_to_file=Y
REM Set the file name
for /f "tokens=1-5 delims=./- " %%d in ("%date%") do set extracted_file_name=extract_%%g_%%f_%%e
for /f "tokens=1-5 delims=: " %%d in ("%time%") do set extracted_file_name=%extracted_file_name%_%%d_%%e



REM Prompt the user for variable override values
SET /p host= Host name [%host%] :
SET /p port= Port [%port%] :
SET /p dbname= Database name [%dbname%] :
SET /p username= Username [%username%] :
SET /p pword= DB Password [?] :
SET /p generate_consolidation_schema= Generate consolidation schema? (Y/N) [%generate_consolidation_schema%] :
IF /I "%generate_consolidation_schema%"=="N" GOTO QUESTION_EXTRACTED_FILE_NAME
SET /p administrator= Type the id of the administrator of Sola [%administrator%] :
SET /p everything= Must be extracted everything? (Y/N) [%everything%] :
:QUESTION_EXTRACTED_FILE_NAME
SET /p dump_to_file= Dump to file? (Y/N) [%dump_to_file%] :
IF /I "%dump_to_file%"=="N" GOTO CONTINUE_1
SET /p extracted_file_name= File name to be extracted without extension [%extracted_file_name%] :
:CONTINUE_1
SET LOG="%data_dir%%extracted_file_name%.log"
SET extracted_full_file_name="%data_dir%%extracted_file_name%.backup"

REM Get the password from the command line and set the PGPASSWORD environ variable
SET PGPASSWORD=%pword%

echo.
echo.
echo.
echo.
IF /I "%dump_to_file%"=="N" GOTO CONTINUE_2
echo Extracted file is : %extracted_full_file_name%
:CONTINUE_2
echo Log file : %LOG%
echo Extraction process started at %date% %time%
echo Extraction process started at %date% %time% > %LOG% 2>&1
IF /I "%generate_consolidation_schema%"=="N" GOTO DUMP_TO_FILE_MOMENT
echo Everything will be extracted: %everything%
echo Everything will be extracted: %everything%  >> %LOG% 2>&1
echo --------------------------------------------------------------------------------
echo -------------------------------------------------------------------------------- >> %LOG% 2>&1
echo Generate consolidation schema started at %date% %time%
echo Generate consolidation schema started at %date% %time% >> %LOG% 2>&1
%psql% --host=%host% --port=%port% --dbname=%dbname% --username=%username% --command="select system.consolidation_extract('%administrator%', 'y'=lower('%everything%'), '%extracted_file_name%')" --set=VERBOSITY=terse >> %LOG% 2>&1
echo Generate consolidation schema finished at %date% %time%
echo Generate consolidation schema finished at %date% %time% >> %LOG% 2>&1
echo --------------------------------------------------------------------------------
:DUMP_TO_FILE_MOMENT
IF /I "%dump_to_file%"=="N" GOTO FINISH
echo -------------------------------------------------------------------------------- >> %LOG% 2>&1

echo Dump to file started at %date% %time%
echo Dump to file started at %date% %time% >> %LOG% 2>&1
%pg_dump% -h %host% -p %port% -U %username% -Fc -n "consolidation" --no-owner --verbose -x -f %extracted_full_file_name% %dbname%  >> %LOG% 2>&1

echo Dump to file finished at %date% %time%
echo Dump to file finished at %date% %time% >> %LOG% 2>&1
echo --------------------------------------------------------------------------------
echo -------------------------------------------------------------------------------- >> %LOG% 2>&1
:FINISH
echo Extraction process finished at %date% %time%
echo Extraction process finished at %date% %time% >> %LOG% 2>&1
echo.
echo.
echo Check log file "%LOG%" to find out if everything finished ok.

pause
