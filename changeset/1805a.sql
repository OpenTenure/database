INSERT INTO system.version SELECT '1805a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1805a');

INSERT INTO system.setting (name, vl, active, description) VALUES ('ot-title-plan-crs-proj4', '', 't', 'Custom Coordinate Reference System in Proj4 format, used for generating map image for claim certificate or boundary in OpenTenure. It should match to ot-title-plan-crs-wkt setting. If not provided, WGS84 will be used as default.');
INSERT INTO system.setting (name, vl, active, description) VALUES ('boundary-print-produced-by', 'Community Server of OpenTenure solution', 't', 'Name of report producer. In real environment can be Ministry''s name.');
INSERT INTO system.setting (name, vl, active, description) VALUES ('boundary-print-crs-description', 'Unit: degree<br>Geodetic CRS: WGS 84<br>Datum: World Geodetic System 1984<br>Ellipsoid: WGS 84<br>Prime meridian: Greenwich', 't', 'Description of Coordinate Reference System, which will be listed in the legend area.');
INSERT INTO system.setting (name, vl, active, description) VALUES ('boundary-print-country-name', '', 't', 'Country name for adding at the end of the boundary location description');


