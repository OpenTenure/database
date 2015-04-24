These scripts are for the same functionality as the scripts on the parent folder, but the parameters
are being passed as arguments.

The database connection is setup in the scripts.

These scripts can be called from the AdminEJB by supplying the necessary parameters.
From command line they can be called: 

1. extract-from-admin.bat 
    <admin-user> 
    <Everything Y/N> 
    <generate_consolidation_schema Y/N> 
    <dump_to_file Y/N> 
    <extracted_file_name> 
    <backup_folder> 
    <log_folder>

2. consolidate-from-admin.bat 
    <admin-user> 
    <merge_consolidation_schema Y/N> 
    <extracted_file_name N/A if the file does not exist>
    <process_id>
    <backup_folder> 
    <log_folder>
