INSERT INTO system.version SELECT '1606a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1606a');

INSERT INTO system.setting(name, vl, active, description) VALUES ('offline-mode', '0', 't', 'Indicates whether Community Server is connected to the Internet or not. 0 - connected, 1 - not connected');
