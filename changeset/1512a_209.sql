INSERT INTO system.version SELECT '1512a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1512a');

ALTER TABLE opentenure.claim_location DROP CONSTRAINT enforce_geotype_gps_location;

ALTER TABLE opentenure.claim_location DROP CONSTRAINT enforce_geotype_mapped_location;
ALTER TABLE opentenure.claim_location ADD CONSTRAINT enforce_geotype_mapped_location CHECK (geometrytype(mapped_location) = 'POLYGON'::text OR geometrytype(mapped_location) = 'POINT'::text OR geometrytype(mapped_location) = 'LINESTRING'::text);

ALTER TABLE opentenure.claim_location DROP CONSTRAINT enforce_valid_gps_location;

ALTER TABLE opentenure.claim DROP CONSTRAINT enforce_geotype_mapped_geometry;
ALTER TABLE opentenure.claim ADD CONSTRAINT enforce_geotype_mapped_geometry CHECK (geometrytype(mapped_geometry) = 'POLYGON'::text OR geometrytype(mapped_geometry) = 'POINT'::text OR geometrytype(mapped_geometry) = 'LINESTRING'::text OR mapped_geometry IS NULL);

INSERT INTO system.setting(name, vl, active, description) VALUES ('ot-title-plan-crs-wkt', '', 't', 'Custom Coordinate Reference System in WKT format of the map image, generated for claim certificate in OpenTenure');
INSERT INTO system.setting(name, vl, active, description) VALUES ('claim_cetificate_report_url', '/reports/cert/Claim_certificate', 't', 'URL to the claim certificate report, hosted on the reporting server');
INSERT INTO system.setting(name, vl, active, description) VALUES ('enable-reports', '1', 't', 'Indicates whether reports are enabled or disabled. 1 - enabled, 0 - disabled');
INSERT INTO system.setting(name, vl, active, description) VALUES ('community-name', 'Open Community', 't', 'Community name');

ALTER TABLE opentenure.party ADD CONSTRAINT fk_party_id_type FOREIGN KEY (id_type_code) REFERENCES party.id_type (code) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE opentenure.party ADD CONSTRAINT fk_party_gender FOREIGN KEY (gender_code) REFERENCES party.gender_type (code) ON UPDATE NO ACTION ON DELETE NO ACTION;
