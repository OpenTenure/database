#!/bin/bash
# 21 Feb 2014
# Linux/MacOS Bash script that uses the PostgreSQL pg_dump utility
# to extract configuration data from the SOLA database into plain 
# text SQL files. The files can then be used by the create_database 
# script to load configuration for other SOLA databases. 
#
# IMPORTANT - pg_dump was changed in PostgreSQL 9.3 to require
# the database parameter to be explicitly identified with 
# the -d option. Use this script when extracting from 
# PostgreSQL 9.3 and above. 
#
# Note that the Localizer tool can also be used to generate the
# reference_data.sql and business_rules.sql files.
 
# Configure variables to use for script:

# The current directory where this command has been executed from
current_dir=$(pwd)  
# Default install location for pg_dump on linux/Debian. This location
# may need to be modified if a different version of postgresql
# is being used and/or it is installed in a custom location.
pg_dump="/usr/lib/postgresql/9.3/bin/pg_dump"
config_path="$current_dir/../../config/"
EXTRACT_LOG="$current_dir/config.log"

# Default DB connection values
host=localhost
port=5432
dbname=sola
username=postgres

# Prompt the user for variable override values
read -p "Host name [$host] : " input
host=${input:-$host}
read -p "Port [$port] : " input
port=${input:-$port}
read -p "Database name [$dbname] : " input
dbname=${input:-$dbname}
read -p "Username [$username] : " input
username=${input:-$username}
read -p "DB Password [?] : " pword

# Get the password from the command line and set the PGPASSWORD environ variable
PGPASSWORD=$pword

# Start the Extract
echo 
echo 
echo "Starting Extract at $(date)"
echo "Starting Extract at $(date)" > $EXTRACT_LOG 2>&1

# Dump the contents of all tables that support localization
echo "Dumping reference tables..."
echo "### Dumping reference tables..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -d $dbname -a -b -F p \
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t administrative.ba_unit_rel_type -t administrative.ba_unit_type \
	-t administrative.condition_type -t administrative.mortgage_type \
	-t administrative.rrr_group_type -t administrative.rrr_type \
	-t application.application_status_type -t application.service_status_type \
	-t application.service_action_type -t application.type_action \
	-t application.application_action_type -t application.request_category_type \
	-t application.request_type -t cadastre.area_type \
	-t cadastre.building_unit_type -t cadastre.dimension_type \
	-t cadastre.hierarchy_level -t cadastre.land_use_type \
	-t cadastre.level_content_type -t cadastre.register_type \
	-t cadastre.structure_type -t cadastre.surface_relation_type \
	-t cadastre.utility_network_status_type -t cadastre.utility_network_type \
	-t cadastre.cadastre_object_type -t party.communication_type \
	-t opentenure.claim_status -t opentenure.rejection_reason -t opentenure.land_use \
	-t opentenure.field_type -t opentenure.field_constraint_type -t opentenure.field_value_type \
	-t party.gender_type -t party.group_party_type \
	-t party.id_type -t party.party_type \
	-t party.party_role_type -t source.administrative_source_type \
	-t source.availability_status_type -t source.presentation_form_type \
	-t source.spatial_source_type -t system.approle \
	-t system.br_severity_type -t system.br_technical_type \
	-t system.br_validation_target_type -t system.language \
	-t transaction.reg_status_type -t transaction.transaction_status_type \
	-f "$config_path/reference_tables.sql" >> $EXTRACT_LOG 2>&1
	
echo "Dumping system tables..."
echo "### Dumping system tables..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -d $dbname -a -b -F p \
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t system.config_map_layer_type -t system.query \
    -t system.config_map_layer -t system.consolidation_config \
	-t system.crs -t system.map_search_option \
    -t system.query_field -t system.setting -t system.version \
	-t system.config_panel_launcher -t system.panel_launcher_group \
	-t system.config_map_layer_metadata \
	-f "$config_path/system.sql" >> $EXTRACT_LOG 2>&1
	
echo "Dumping user tables..."
echo "### Dumping user tables..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -d $dbname -a -b -F p \
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t system.appuser -t system.appgroup \
	-t system.appuser_appgroup -t system.approle_appgroup \
	-t system.appuser_setting \
	-f "$config_path/users.sql" >> $EXTRACT_LOG 2>&1

echo "Dumping unlocalized reference tables..."
echo "### Dumping unlocalized reference tables..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -d $dbname -a -b -F p \
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t cadastre.level -t application.request_type_requires_source_type \
	-f "$config_path/unlocalized_reference_tables.sql" >> $EXTRACT_LOG 2>&1	
	
echo "Dumping business rule tables..."
echo "### Dumping business rule tables..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -d $dbname -a -b -F p \
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t system.br -t system.br_definition -t system.br_validation \
	-f "$config_path/business_rules.sql" >> $EXTRACT_LOG 2>&1

#Clear the pg password from the shell
unset PGPASSWORD

# Report the finish time
echo "Finished at $(date) - Check config.log for errors!"
echo "Finished at $(date)" >> $EXTRACT_LOG 2>&1
read -p "Press [Enter] key to continue..."