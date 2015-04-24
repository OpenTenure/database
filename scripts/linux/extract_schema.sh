#!/bin/bash
# 21 Feb 2014
# Linux/MacOS Bash script that uses the PostgreSQL pg_dump utility
# to extract the SOLA schema into plain text SQL files. The 
# create_database script can then be used to re-create or upgrade
# the SOLA database on other computers as required.    

# IMPORTANT - pg_dump was changed in PostgreSQL 9.3 to require
# the database parameter to be explicitly identified with 
# the -d option. Use this script when extracting from 
# PostgreSQL 9.2 and below. 
 
# Configure variables to use for script:

# The current directory where this command has been executed from
current_dir=$(pwd)  
# Default install location for pg_dump on linux/Debian. This location
# may need to be modified if a different version of postgresql
# is being used and/or it is installed in a custom location.
pg_dump="/usr/lib/postgresql/9.2/bin/pg_dump"
schema_path="$current_dir/../../schema/"
EXTRACT_LOG="$current_dir/schema.log"

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

# Dump the main SOLA schemas except for the public schema. This schema
# includes the postgis and UUID extension functions which do not need to be 
# dumped. There are 10 functions in the public schema that have been created
# for SOLA. Updates to these functions require manual updating of the public.sql
# file in the schema directory. 
echo "Dumping SOLA schemas..."
echo "### Dumping SOLA schemas..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -F p --schema-only \
    -n address -n party -n document -n transaction -n source \
	-n cadastre -n system -n administrative -n application \
	-n bulk_operation -n opentenure \
	-f "$schema_path/sola_schemas.sql" $dbname >> $EXTRACT_LOG 2>&1
	
# Echo a message to the user so they do not forget about the SOLA functions 
# in the public schema. 
echo
echo
echo "IMPORTANT!"
echo "If you have changed any of the following functions in the public"
echo "schema, you will need to manually extract those function definitions"
echo "and replace them in the schema/public.sql script file"
echo
echo "- public.f_for_trg_track_changes  - public.f_for_trg_track_history"
echo "- public.fn_triggerall            - public.clean_db"
echo "- public.compare_strings          - public.get_geometry_with_srid"
echo "- public.get_translation          - public.clean_db_foreign_constraints"
echo "- public.clean_db_triggers"
echo
echo
echo "### IMPORTANT! - Update schema/public.sql if you have changed one" >> $EXTRACT_LOG 2>&1 
echo "                 of the SOLA functions in the public schema" >> $EXTRACT_LOG 2>&1 

#Clear the pg password from the shell
unset PGPASSWORD

# Report the finish time
echo "Finished at $(date) - Check schema.log for errors!"
echo "Finished at $(date)" >> $EXTRACT_LOG 2>&1
read -p "Press [Enter] key to continue..."