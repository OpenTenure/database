#!/bin/bash
# 21 Feb 2014
# Linux/MacOS Bash script that uses the PostgreSQL pg_dump utility
# to extract table data from the SOLA database into plain text 
# SQL files. The SQL files are then compressed using 7z. The 7z 
# file can then be used to load the other sola databases with 
# test data using the create_database script.  
# 
# 7z supports password encryption and this script can be modified
# to password encrypt the 7z archive if required.
#
# The documents table can grow to be extremely large which may
# cause this script to take a very long time to complete. The 
# user is given the option to extract documents or not. By 
# default, the document table is skipped. 
#
# IMPORTANT - pg_dump was changed in PostgreSQL 9.3 to require
# the database parameter to be explicitly identified with 
# the -d option. Use this script when extracting from 
# PostgreSQL 9.3 and above. 
#
# Configure variables to use for script:

# The current directory where this command has been executed from
current_dir=$(pwd)  
# Default install location for pg_dump on linux/Debian. This location
# may need to be modified if a different version of postgresql
# is being used and/or it is installed in a custom location.
pg_dump="/usr/lib/postgresql/9.3/bin/pg_dump"
data_path="$current_dir/../../data/"
# Default install location for p7zip on linux/Debian. This location
# may need to be modified if a custom install location is used
# and/or a different archiver (e.g. Keka on MacOS) is used to unzip 
# the data files.  Note that p7zip is also available for MacOS.
zip_exe="/usr/bin/7z"
EXTRACT_LOG="$current_dir/data.log"

# Default DB connection values
host=localhost
port=5432
dbname=sola
username=postgres
dumpdocs=n

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
read -p "Do you want to extract the document table? (y/n) [$dumpdocs] : " input
dumpdocs=${input:-$dumpdocs}

# If the 7z data archive requires password encryption, prompt the user 
# for the password.
# DO NOT RECORD THE PASSWORD AS A DEFAULT VALUE IN THIS BATCH FILE!
# read -p "Test Data Archive Password [?] : " archive_password

# Get the password from the command line and set the PGPASSWORD environ variable
PGPASSWORD=$pword

# Start the Extract
echo 
echo 
echo "Starting Extract at $(date)"
echo "Starting Extract at $(date)" > $EXTRACT_LOG 2>&1

# Dump data from each schema into a plain text SQL file
echo "Dumping address tables..."
echo "### Dumping address tables..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -d $dbname -a -b -F p \
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t address.address \
	-f "$data_path/01_address.sql" >> $EXTRACT_LOG 2>&1

echo "Dumping party tables..."
echo "### Dumping party tables..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -d $dbname -a -b -F p \
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t party.party  -t party.party_role \
	-f "$data_path/02_party.sql" >> $EXTRACT_LOG 2>&1

# Skip dumping documents unless the user has explicitly chosen to do so 
if [ $dumpdocs == "y" ]; then
   echo "Dumping document tables..."
   echo "### Dumping document tables..." >> $EXTRACT_LOG 2>&1 
   $pg_dump -h $host -p $port -U $username -d $dbname -a -b \
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t document.document \
	-f "$data_path/03_document.sql" >> $EXTRACT_LOG 2>&1
fi

echo "Dumping transaction tables..."
echo "### Dumping transaction tables..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -d $dbname -a -b \
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t transaction.transaction -t transaction.transaction_source \
	-f "$data_path/04_transaction.sql" >> $EXTRACT_LOG 2>&1
	
echo "Dumping source tables..."
echo "### Dumping source tables..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -d $dbname -a -b \
    --column-inserts --disable-dollar-quoting --disable-triggers \
	-t source.archive -t source.source -t application.application_uses_source \
	-t administrative.source_describes_rrr -t source.power_of_attorney \
    -t administrative.source_describes_ba_unit -t source.spatial_source \
    -t source.spatial_source_measurement \
    -f "$data_path/05_source.sql" >> $EXTRACT_LOG 2>&1
	
echo "Dumping cadastre tables..."
echo "### Dumping cadastre tables..." >> $EXTRACT_LOG 2>&1
$pg_dump -h $host -p $port -U $username -d $dbname -a -b -F p\
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t cadastre.cadastre_object -t cadastre.spatial_unit \
	-t cadastre.spatial_value_area -t cadastre.spatial_unit_group \
	-t cadastre.spatial_unit_in_group -t cadastre.cadastre_object_node_target \
    -t cadastre.cadastre_object_target -t cadastre.spatial_unit_address \
    -t cadastre.survey_point \
	-f "$data_path/06_cadastre.sql" >> $EXTRACT_LOG 2>&1
	
echo "Dumping administrative tables..."
echo "### Dumping administrative tables..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -d $dbname -a -b \
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t administrative.ba_unit -t administrative.required_relationship_baunit \
    -t administrative.ba_unit_area -t administrative.rrr -t administrative.rrr_share \
    -t administrative.party_for_rrr -t administrative.notation \
    -t administrative.ba_unit_contains_spatial_unit -t administrative.ba_unit_as_party \
    -t administrative.ba_unit_target -t administrative.condition_for_rrr \
    -t administrative.mortgage_isbased_in_rrr \
	-f "$data_path/07_administrative.sql" >> $EXTRACT_LOG 2>&1
	
echo "Dumping application tables..."
echo "### Dumping application tables..." >> $EXTRACT_LOG 2>&1
$pg_dump -h $host -p $port -U $username -d $dbname -a -b \
    --column-inserts --disable-dollar-quoting --disable-triggers \
	-t application.application -t application.application_property \
	-t application.service -t application.application_spatial_unit \
    -f "$data_path/08_application.sql" >> $EXTRACT_LOG 2>&1	
	
echo "Dumping bulk operation tables..."
echo "### Dumping bulk operation tables..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -d $dbname -a -b \
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t bulk_operation.spatial_unit_temporary \
	-f "$data_path/09_bulk_operation.sql" >> $EXTRACT_LOG 2>&1

echo "Dumping opentenure tables..."
echo "### Dumping opentenure tables..." >> $EXTRACT_LOG 2>&1 
$pg_dump -h $host -p $port -U $username -d $dbname -a -b \
    --column-inserts --disable-dollar-quoting --disable-triggers \
    -t opentenure.attachment -t opentenure.attachment_chunk -t opentenure.claim \
	-t opentenure.claim_comment -t opentenure.claim_location -t opentenure.claim_share \
	-t opentenure.claim_uses_attachment -t opentenure.field_constraint \
	-t opentenure.field_constraint_option -t opentenure.field_payload -t opentenure.field_template \
	-t opentenure.form_payload -t opentenure.form_template -t opentenure.party \
	-t opentenure.party_for_claim_share -t opentenure.section_element_payload \
	-t opentenure.section_payload -t opentenure.section_template \
	-f "$data_path/10_opentenure.sql" >> $EXTRACT_LOG 2>&1
	
# Compress the test/demo data using 7z. 
echo "Compressing data files..."
echo "### Compressing data files..." >> $EXTRACT_LOG 2>&1
$zip_exe a -y "$data_path/waiheke.7z" "$data_path/*.sql" >> $EXTRACT_LOG 2>&1
# Use -p option if the archive needs to be password protected as follows
# $zip_exe a -y -p$archive_password "$data_path/waiheke.7z" "$data_path/*.sql" >> $EXTRACT_LOG 2>&1

#Clear the pg password from the shell
unset PGPASSWORD

# Report the finish time
echo "Finished at $(date) - Check data.log for errors!"
echo "Finished at $(date)" >> $EXTRACT_LOG 2>&1
read -p "Press [Enter] key to continue..."