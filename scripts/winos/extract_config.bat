@ECHO off
REM 11 Feb 2014
REM Windows batch script that uses the PostgreSQL pg_dump utility
REM to extract configuration data from the SOLA database into plain 
REM text SQL files. The files can then be used by the create_database 
REM script to load configuration for other SOLA databases. 
REM
REM Note that the Localizer tool can also be used to generate the
REM reference_data.sql and business_rules.sql files. 
REM 
REM Configure variables to use for script
SET current_dir=%~dp0
SET pg_dump="%current_dir%bin\psql\pg_dump"
REM SET pg_dump="C:\Program Files\PostgreSQL\9.3\bin\pg_dump"
SET config_path=%current_dir%..\..\config\
SET EXTRACT_LOG="%current_dir%config.log"
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

REM Set the PGPASSWORD environ variable
SET PGPASSWORD=%pword%

REM Start the Extract
echo.
echo.
echo Starting Extract at %time%
echo Starting Extract at %time% > %EXTRACT_LOG% 2>&1

REM Dump the contents of all tables that support localization
echo Dumping reference tables...
echo ### Dumping reference tables... >> %EXTRACT_LOG% 2>&1 

%pg_dump% -h %host% -p %port% -U %username% -a -b -F p ^
    --column-inserts --disable-dollar-quoting --disable-triggers ^
    -t administrative.ba_unit_rel_type -t administrative.ba_unit_type ^
	-t administrative.condition_type -t administrative.mortgage_type ^
	-t administrative.rrr_group_type -t administrative.rrr_type ^
	-t application.application_status_type -t application.service_status_type ^
	-t application.service_action_type -t application.type_action ^
	-t application.application_action_type -t application.request_category_type ^
	-t application.request_type -t cadastre.area_type ^
	-t cadastre.building_unit_type -t cadastre.dimension_type ^
	-t cadastre.hierarchy_level -t cadastre.land_use_type ^
	-t cadastre.level_content_type -t cadastre.register_type ^
	-t cadastre.structure_type -t cadastre.surface_relation_type ^
	-t cadastre.utility_network_status_type -t cadastre.utility_network_type ^
	-t cadastre.cadastre_object_type -t party.communication_type ^
	-t opentenure.claim_status -t opentenure.rejection_reason -t opentenure.field_constraint_type ^
	-t opentenure.field_type -t opentenure.field_value_type ^
	-t party.gender_type -t party.group_party_type ^
	-t party.id_type -t party.party_type ^
	-t party.party_role_type -t source.administrative_source_type ^
	-t source.availability_status_type -t source.presentation_form_type ^
	-t source.spatial_source_type -t system.approle ^
	-t system.br_severity_type -t system.br_technical_type ^
	-t system.br_validation_target_type -t system.language ^
	-t transaction.reg_status_type -t transaction.transaction_status_type ^
	-t opentenure.administrative_boundary_type -t opentenure.administrative_boundary_status ^
	-f "%config_path%reference_tables.sql" %db_name% >> %EXTRACT_LOG% 2>&1
	
echo Dumping system tables...
echo ### Dumping system tables... >> %EXTRACT_LOG% 2>&1 
%pg_dump% -h %host% -p %port% -U %username% -a -b -F p ^
    --column-inserts --disable-dollar-quoting --disable-triggers ^
    -t system.config_map_layer_type -t system.query ^
    -t system.config_map_layer -t system.consolidation_config ^
	-t system.crs -t system.map_search_option ^
    -t system.query_field -t system.setting -t system.version ^
	-t system.config_panel_launcher -t system.panel_launcher_group ^
	-t system.config_map_layer_metadata ^
	-f "%config_path%system.sql" %db_name% >> %EXTRACT_LOG% 2>&1
	
echo Dumping user tables...
echo ### Dumping user tables... >> %EXTRACT_LOG% 2>&1 
%pg_dump% -h %host% -p %port% -U %username% -a -b -F p ^
    --column-inserts --disable-dollar-quoting --disable-triggers ^
    -t system.appuser -t system.appgroup ^
	-t system.appuser_appgroup -t system.approle_appgroup ^
	-t system.appuser_setting ^
	-f "%config_path%users.sql" %db_name% >> %EXTRACT_LOG% 2>&1

echo Dumping unlocalized reference tables...
echo ### Dumping unlocalized reference tables... >> %EXTRACT_LOG% 2>&1 
%pg_dump% -h %host% -p %port% -U %username% -a -b -F p ^
    --column-inserts --disable-dollar-quoting --disable-triggers ^
    -t cadastre.level -t application.request_type_requires_source_type ^
	-f "%config_path%unlocalized_reference_tables.sql" %db_name% >> %EXTRACT_LOG% 2>&1	
	
echo Dumping business rule tables...
echo ### Dumping business rule tables... >> %EXTRACT_LOG% 2>&1 
%pg_dump% -h %host% -p %port% -U %username% -a -b -F p ^
    --column-inserts --disable-dollar-quoting --disable-triggers ^
    -t system.br -t system.br_definition -t system.br_validation ^
	-f "%config_path%business_rules.sql" %db_name% >> %EXTRACT_LOG% 2>&1

REM Report the finish time
echo Finished at %time% - Check config.log for errors!
echo Finished at %time% >> %EXTRACT_LOG% 2>&1
pause
