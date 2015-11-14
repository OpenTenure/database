@ECHO off
REM 6 Feb 2014
REM Windows batch script that uses the PostgreSQL pg_dump utility
REM to extract table data from the SOLA database into plain text 
REM SQL files. The SQL files are then compressed using 7z. The 7z 
REM file can then be used to load the other sola databases with 
REM test data using the create_database script.  
REM 
REM 7z supports password encryption and this script can be modified
REM to password encrypt the 7z archive if requried.
REM
REM The documents table can grow to be extremely large which may
REM cause this script to take a very long time to complete. The 
REM user is given the option to extract documents or not. By 
REM default, the document table is skipped. 
REM
REM Configure variables to use for script
SET current_dir=%~dp0
SET pg_dump="%current_dir%\bin\psql\pg_dump"
SET data_path=%current_dir%..\..\data\
SET zip_exe="%current_dir%bin\7z\7z.exe"
SET EXTRACT_LOG="%current_dir%data.log"
SET host=localhost
SET port=5432
SET db_name=sola
SET username=postgres
SET dumpdocs=N
SET dumpot=N

REM Prompt the user for variable override values
SET /p host= Host name [%host%] :
SET /p port= Port [%port%] :
SET /p db_name= Database name [%db_name%] :
SET /p username= Username [%username%] :
SET /p pword= DB Password [?] :

REM If the 7z data archive requires password encryption, prompt the user 
REM for the password.
REM DO NOT RECORD THE PASSWORD AS A DEFAULT VALUE IN THIS BATCH FILE!
REM SET /p archive_password= Test Data Archive Password [?] :

REM Set the PGPASSWORD environ variable
SET PGPASSWORD=%pword%

REM Start the Extract
echo.
echo.
echo Starting Extract at %time%
echo Starting Extract at %time% > %EXTRACT_LOG% 2>&1

echo Dumping opentenure tables...
echo ### Dumping opentenure tables... >> %EXTRACT_LOG% 2>&1 
%pg_dump% -h %host% -p %port% -U %username% -a -b ^
    --column-inserts --disable-dollar-quoting --disable-triggers ^
    -t opentenure.form_template -t opentenure.section_template -t opentenure.field_template ^
	-t opentenure.field_constraint ^ -t opentenure.field_constraint_option ^
	-f "dynamic_forms.sql" %db_name% >> %EXTRACT_LOG% 2>&1
	
REM Report the finish time
echo Finished at %time% - Check data.log for errors!
echo Finished at %time% >> %EXTRACT_LOG% 2>&1
pause