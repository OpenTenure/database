@ECHO off
REM 6 Feb 2014
REM Windows batch script to create the SOLA database and load it 
REM with configuration data. The scipt also de-compresses and
REM loads the Waiheke test data.
REM
REM The SQL files used by this batch can be generated using the
REM extract scripts from the scripts directory. The extract
REM scripts will export the schema, configuration and test data
REM from an existing SOLA database into the necessary SQL files. 

REM Configure variables to use for script
SET current_dir=%~dp0
SET psql="%current_dir%scripts\winos\bin\psql\psql.exe"
SET zip_exe="%current_dir%scripts\winos\bin\7z\7z.exe"
SET data_path=%current_dir%data\
SET BUILD_LOG="%current_dir%build.log"
SET host=localhost
SET port=5432
SET dbname=sola
SET username=postgres
SET createDb=N
SET fillWithSampleData=Y

REM Prompt the user for variable override values
SET /p host= Host name [%host%] :
SET /p port= Port [%port%] :
SET /p dbname= Database name [%dbname%] :
SET /p username= Username [%username%] :
SET /p pword= DB Password [?] :
SET /p createDb= Create or replace the database? (Y/N) [%createDb%] :
SET /p fillWithSampleData= Fill database with sample data? (Y/N) [%fillWithSampleData%] :

REM Get the password from the command line and set the PGPASSWORD environ variable
SET PGPASSWORD=%pword%

REM If the 7z data archive is password protected, prompt the user for the password.
REM DO NOT RECORD THE PASSWORD AS A DEFAULT VALUE IN THIS BATCH FILE!
REM SET /p archive_password= Test Data Archive Password [?] :

REM Start the build
echo.
echo.
echo Starting Build at %time%
echo Starting Build at %time% > %BUILD_LOG% 2>&1

REM Skip creating the database depending on the users choice 
IF /I "%createDb%"=="N" GOTO CREATE_SCHEMA

REM Create database passing in dbName as a variable
echo Creating database...
echo Creating database... >> %BUILD_LOG% 2>&1
%psql% --host=%host% --port=%port% --username=%username% --file=database.sql -v dbName=%dbname% >> %BUILD_LOG% 2>&1

REM Run the files to create the tables, functions and views, etc, of the database
REM and load the configuration data from the config directory. 
:CREATE_SCHEMA
for %%f in (schema\*.sql config\*.sql) do (
   echo Running %%f...
   echo ### Running %%f... >> %BUILD_LOG% 2>&1
   %psql% --host=%host% --port=%port% --dbname=%dbname% --username=%username% --file=%%f >NUL 2>> %BUILD_LOG%
)

IF /I "%fillWithSampleData%"=="N" GOTO FINISH
REM Extract the test data from the 7z archive and load it into the database. 
echo Extracting data files...
echo ### Extracting data files... >> %BUILD_LOG% 2>&1
%zip_exe% e -y -o"%data_path%" "%data_path%waiheke.7z" >> %BUILD_LOG% 2>&1
REM Use -p option if the archive is password protected as follows
REM %zip_exe% e -y -p%archive_password% -o%data_path% %data_path%waiheke.7z >> %BUILD_LOG% 2>&1

REM Load the SQL files containing the test data
for %%f in (data\*.sql) do (
   echo Loading %%f...
   echo ### Loading %%f... >> %BUILD_LOG% 2>&1
   %psql% --host=%host% --port=%port% --dbname=%dbname% --username=%username% --file=%%f >NUL 2>> %BUILD_LOG%
)

:FINISH
REM Report the finish time
echo Finished at %time% - Check build.log for errors!
echo Finished at %time% >> %BUILD_LOG% 2>&1
pause
