-- SQL to retrieve the definitions of SOLA functions in the public schema
-- This script excludes comments that may be added to the functions. 
SELECT pg_get_functiondef(oid) 
FROM pg_proc 
WHERE proname 
IN ('f_for_trg_track_changes', 'f_for_trg_track_history',
    'fn_triggerall','clean_db', 'compare_strings',
    'get_geometry_with_srid', 'get_translation', 
    'clean_db_foreign_constraints', 'clean_db_triggers') 
AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname='public');