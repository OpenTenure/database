#!/bin/bash
# 21 Feb 2014
# Linux/MacOS Bash script to create the SOLA database 
# and load it with configuration data. The scipt also 
# de-compresses and loads the Waiheke test data.
#
# The SQL files used by this batch can be generated using the
# extract scripts from the scripts directory. The extract
# scripts will export the schema, configuration and test data
# from an existing SOLA database into the necessary SQL files. 

# Configure variables to use for script:

# The current directory where this command has been executed from
current_dir=$(pwd)  
# Default install location for psql on linux/Debian. This location
# may need to be modified if a different version of postgresql
# is being used and/or it is installed in a custom location.
psql="/usr/lib/postgresql/9.3/bin/psql"
# Default install location for p7zip on linux/Debian. This location
# may need to be modified if a custom install location is used
# and/or a different archiver (e.g. Keka on MacOS) is used to unzip 
# the data files.  Note that p7zip is also available for MacOS.
zip_exe="/usr/bin/7z"
data_path="$current_dir/data/"
BUILD_LOG="$current_dir/build.log"

# Default DB connection values
host=localhost
port=5432
dbname=sola
username=postgres
createDb=n

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
read -p "Create or replace the database? (y/n) [$createDb] : " input
createDb=${input:-$createDb}

# Get the password from the command line and set the PGPASSWORD environ variable
PGPASSWORD=$pword

# If the 7z data archive is password protected, prompt the user for the password.
# DO NOT RECORD THE PASSWORD AS A DEFAULT VALUE IN THIS BATCH FILE!
# read -p "Test Data Archive Password [?] : " archive_password

# Start the build
echo 
echo 
echo "Starting Build at $(date)"
echo "Starting Build at $(date)" > $BUILD_LOG 2>&1

# Skip creating the database depending on the users choice 
if [ $createDb == "y" ]; then
   # Create database passing in dbName as a variable
   echo "Creating database..."
   echo "Creating database..." >> %BUILD_LOG% 2>&1
   $psql --host=$host --port=$port --username=$username --file=database.sql -v dbName=$dbname >>$BUILD_LOG 2>&1
fi

# Run the files to create the tables, functions and views, etc, of the database
# and load the configuration data from the config directory. 
for sqlfile in schema/*.sql config/*.sql
do
   echo "Running $sqlfile..."
   echo "### Running $sqlfile..." >> $BUILD_LOG 2>&1
   $psql --host=$host --port=$port --dbname=$dbname --username=$username --file="$sqlfile" > /dev/null 2>> $BUILD_LOG
done

# Extract the test data from the 7z archive and load it into the database.
echo 
echo "Extracting data files..."
echo "### Extracting data files..." >> $BUILD_LOG 2>&1
$zip_exe e -y -o"$data_path" "$data_path/waiheke.7z" >> $BUILD_LOG 2>&1
# Use -p option if the archive is password protected as follows
# $zip_exe e -y -p$archive_password -o"$data_path" "$data_path/waiheke.7z" >> $BUILD_LOG 2>&1

# Load the SQL files containing the test data
for sqlfile in data/*.sql
do
   echo "Loading $sqlfile..."
   echo "### Loading $sqlfile" >> $BUILD_LOG 2>&1
   $psql --host=$host --port=$port --dbname=$dbname --username=$username --file="$sqlfile" > /dev/null 2>> $BUILD_LOG
done

#Clear the pg password from the shell
unset PGPASSWORD

# Report the finish time
echo "Finished at $(date) - Check build.log for errors!"
echo "Finished at $(date)" >> $BUILD_LOG 2>&1
read -p "Press [Enter] key to continue..."