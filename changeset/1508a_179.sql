INSERT INTO system.version SELECT '1508a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1508a');
INSERT INTO system.setting(name, vl, active, description) VALUES ('report_server_url', 'http://localhost:8080/jasperserver', 't', 'Reporting server URL.');
INSERT INTO system.setting(name, vl, active, description) VALUES ('report_server_user', 'jasperadmin', 't', 'Reporting server user name.');
INSERT INTO system.setting(name, vl, active, description) VALUES ('report_server_pass', 'jasperadmin', 't', 'Reporting server user password.');
INSERT INTO system.setting(name, vl, active, description) VALUES ('reports_folder_url', '/reports', 't', 'Folder URL on the reporting server containing reports to display on the menu.');
INSERT INTO system.approle (code, display_value, status, description) VALUES ('ViewReports', 'View Community Server reports', 'c', 'View Community Server reports');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) VALUES ('ViewReports', 'super-group-id');