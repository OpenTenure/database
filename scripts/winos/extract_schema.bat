@ECHO off
REM 11 Feb 2014
REM Windows batch script that uses the PostgreSQL pg_dump utility
REM to extract the SOLA schema into plain text SQL files. The 
REM create_database script can then be used to re-create or upgrade
REM the SOLA database on other computers as required.    
REM 
REM Configure variables to use for script
SET current_dir=%~dp0
SET pg_dump="%current_dir%bin\psql\pg_dump"
REM SET pg_dump="C:\Program Files\PostgreSQL\9.3\bin\pg_dump"
SET schema_path=%current_dir%..\..\schema\
SET EXTRACT_LOG="%current_dir%schema.log"
SET host=localhost
SET port=5432
SET db_name=sola
SET username=postgres

REM Prompt the user for variable override values
SET /p host= Host name [%host%] :
SET /p port= Port [%port%] :
SET /p db_name= Database name [%db_name%] :
SET /p username= Username [%username%] :
SET /p pword= DB Password [?] :

REM get the password from the command line and set the PGPASSWORD environ variable
SET PGPASSWORD=%pword%

REM Start the Extract
echo.
echo.
echo Starting extract at %time%
echo Starting extract at %time% > %EXTRACT_LOG% 2>&1

REM Dump the main SOLA schemas except for the public schema. This schema
REM includes the postgis and UUID extension functions which do not need to be 
REM dumped. There are 10 functions in the public schema that have been created
REM for SOLA. Updates to these functions require manual updating of the public.sql
REM file in the schema directory. 
echo Dumping SOLA schemas...
echo ### Dumping SOLA schemas... >> %EXTRACT_LOG% 2>&1 
%pg_dump% -h %host% -p %port% -U %username% -F p --schema-only ^
    -n address -n party -n document -n transaction -n source ^
	-n cadastre -n system -n administrative -n application ^
	-n bulk_operation -n opentenure ^
	-f "%schema_path%sola_schemas.sql" %db_name% >> %EXTRACT_LOG% 2>&1
	
REM Echo a message to the user so they do not forget about the SOLA functions 
REM in the public schema. 
echo.
echo.
echo IMPORTANT!
echo If you have changed any of the following functions in the public
echo schema, you will need to manually extract those function definitions
echo and replace them in the schema/public.sql script file
echo.
echo - public.f_for_trg_track_changes  - public.f_for_trg_track_history
echo - public.fn_triggerall            - public.clean_db
echo - public.compare_strings          - public.get_geometry_with_srid
echo - public.get_translation          - public.clean_db_foreign_constraints
echo - public.clean_db_triggers
echo.
echo.
echo ### IMPORTANT! - Update schema/public.sql if you have changed one >> %EXTRACT_LOG% 2>&1 
echo                  of the SOLA functions in the public schema >> %EXTRACT_LOG% 2>&1 

REM Report the finish time
echo Finished at %time% - Check schema.log for errors!
echo Finished at %time% >> %EXTRACT_LOG% 2>&1
pause
