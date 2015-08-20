INSERT INTO system.version SELECT '1507b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1507b');
INSERT INTO system.setting(name, vl, active, description) VALUES ('requires_spatial', '1', 't', 'Indicates whether spatial representation of the parcel is required (mandatory). If values is 0, spatial part can be omitted, otherwise validation will request it.');
