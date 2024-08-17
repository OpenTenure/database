Database repository for the SOLA Community Server open source project. This repository contains sql scripts
and OS batch/command files for building and populating the SOLA Community Server 
PostgreSQL database.

SOLA Community Server uses multiple Git repositories for managing its code base.
The code repository is the super/parent repository. Refer to the 
README in that repository for details on all SOLA Community Server Git repositories. 

> Batch and Shell Command Files

Batch and shell command files supported by this repository include;

1)  create_database: Builds the SOLA Community Server database and loads it with 
    configuration and test data using SQL script files located 
    in the schema, config and data folders.
2)  extract_schema: Uses pg_dump to extract the schema of an 
    existing database and update the SQL files in the schema 
    folder.
3)  extract_config: Uses pg_dump to extract data from the 
    reference data tables and system tables of an existing 
    database and updates the SQL files in the config folder.
4)  extract_data: Uses pg_dump to extract data from an existing 
    database, compresses the SQL files with 7z and updates the 
    7z file in the data folder.
5)  gen_data_dictionary: Uses SchemaSpy and Graphvis to generate
    a data dictionary in HTML format from the metadata of an  
    existing SOLA Community Server database. 

Windows Batch and Bash shell files for the above are located in 
the scripts/winos and scripts/linux folders. Note that the 
gen_data_dictionary is currently only supported on Windows.
The Bash shell files can also be customized for use on MacOS by 
setting the appropriate installation locations for the psql, 
pg_dump and zip_exe variables.  

> Managing Database Changes

All changes to the database must be captured as a changeset script 
in the changeset folder. The steps required when implementing 
new database changes are;

1)  Create a new ticket in Lighthouse to describe the database 
    change that is being made. This will allocate a ticket number.
2)  Create and run your new changeset script against your local 
    development database to apply the change. 
	- The changeset script must be named using the Changeset 
      Naming Convention described below. 
	- Any new objects added to the database (e.g. tables, columns, 
      views, functions, etc) must include suitable database 
      comments to describe them. 
    - The changeset script must also update the system.version 
	  table with the new version number implied by the changeset 
      script file name.
3)  Depending on the changes that were applied, run the necessary 
    extract scripts and re-generate the data dictionary to ensure 
    all changes are included in the primary source SQL files. 
4)  Commit changes in git and push to Github.

For general development, it will not be necessary for other developers 
to re-run any of the changeset scripts – they will just run the 
create_database script to pick up any changes in the primary source SQL 
files. The changeset scripts become important when it is necessary 
to upgrade an existing production databases. In this case the DBA will 
need to determine the changeset scripts to apply to upgrade their database 
with new features. 

> Changeset Naming Convention

Scripts should be named as <year><month><sequence char>_<Lighthouse ticket 
number>. The date fields will be based around the date the Lighthouse ticket
is initially fixed. E.g. If Lighthouse ticket 298 is fixed on the 12th Feb 
2014, the changeset script name is 1402a_298.sql. The next script created 
in Feb would be 1402b_<ticket number>, etc. 

The version number part of the script name is the date and sequence char 
(e.g. 1402a). The version number must be added to the system.version 
table when the changeset script executes. 