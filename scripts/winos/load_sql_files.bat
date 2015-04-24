@ECHO off
REM 11 Feb 2014
REM This script can be used to load a number of .sql files from the local
REM directory into the SOLA database. 
REM
REM Configure variables to use for script
SET current_dir=%~dp0
SET psql="%current_dir%bin\psql\psql.exe"
SET LOAD_LOG="%current_dir%load_files.log"
SET host=localhost
SET port=5432
SET dbName=sola
SET username=postgres

REM Prompt the user for variable override values
SET /p host= Host name [%host%] :
SET /p port= Port [%port%] :
SET /p dbName= Database name [%dbName%] :
SET /p username= Username [%username%] :
SET /p pword= DB Password [?] :

REM Get the password from the command line and set the PGPASSWORD environ variable
SET PGPASSWORD=%pword%

REM Start the load
echo.
echo.
echo Starting Load at %time%
echo Starting Load at %time% > %LOAD_LOG% 2>&1

for %%f in (*.sql) do (
   echo Loading %%f...
   echo ### Loading %%f... >> %LOAD_LOG% 2>&1
   
REM The script assumes it is located in the /scripts/winos folder. If 
REM you move this script, update the psql variable to correctly incdicate
REM the location of the psql binary.
   %psql% --host=%host% --port=%port% --dbname=%dbname% --username=%username% --file=%%f >NUL 2>> %LOAD_LOG%
)

REM Report the finish time
echo Finished at %time% - Check load_files.log for errors!
echo Finished at %time% >> %LOAD_LOG% 2>&1
pause