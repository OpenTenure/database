INSERT INTO system.version SELECT '1707a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1707a');
