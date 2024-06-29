INSERT INTO system.version SELECT '2403a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '2403a');

DELETE FROM system.setting WHERE name IN ('claim_certificate_report_url','cs_server_url','enable-reports','report_server_pass','report_server_url','report_server_user','reports_folder_url');
UPDATE system.setting SET name = 'docs-for-issuing-cert' WHERE name = 'docs_for_issuing_cert' and NOT EXISTS (select name from system.setting where name = 'docs-for-issuing-cert');
DELETE FROM system.setting WHERE name = 'docs_for_issuing_cert';
INSERT INTO system.setting(name, vl, active, description) VALUES ('reports-folder-path', '../../cs_reports', 't', 'Relative or absolute path to the reports folder. Relative path will be calculated from the deployment folder of the application (WAR file).');
INSERT INTO system.setting(name, vl, active, description) VALUES ('claim-certificate-id', 'ClaimCertificate', 't', 'Report id, used for claim certificate.');
INSERT INTO system.setting(name, vl, active, description) VALUES ('ot-use-background-google-map', '0', 't', 'This flag indicates whether to use Google map layer as a background on the certificate or not. If 1 is set, then it will be used, 0 is not so use it.');
INSERT INTO system.setting(name, vl, active, description) VALUES ('ot-use-background-wms-map', '0', 't', 'This flag indicates whether to use WMS map layer as a background on the certificate or not. If 1 is set, then it will be used, 0 is not so use it. If both WMS and Google layer ("ot-use-background-google-map") are enabled, then Google layer will have the preference.');
INSERT INTO system.setting(name, vl, active, description) VALUES ('ot-wms-server-url', '', 't', 'Server URL hosting WMS layer for using it as a background on the certificate. Do not enter "wms" as the end. Example for GeoServer - http://localhost:8080/geoserver/opentenure');
INSERT INTO system.setting(name, vl, active, description) VALUES ('ot-wms-bg-layer-name', '', 't', 'WMS background layer name for using on the certificate. Make sure that the layer is published in WGS84 (4326).');

ALTER TABLE system.setting ADD COLUMN read_only boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN system.setting.read_only IS 'Indicates whether the setting is editable by the user.';

UPDATE system.setting SET read_only = 't' WHERE name IN ('system-id','product-code','reports-folder-path');

CREATE TABLE system.report_group
(
  code character varying(20) NOT NULL, 
  display_value character varying(500) NOT NULL,
  status character(1) NOT NULL DEFAULT 'c'::bpchar, 
  description character varying(5000),
  CONSTRAINT report_groupe_pkey PRIMARY KEY (code),
  CONSTRAINT report_group_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.report_group
  OWNER TO postgres;
COMMENT ON TABLE system.report_group
  IS 'Contains a list of groups for grouping reports under the the main menu.';
COMMENT ON COLUMN system.report_group.code IS 'Code for the report group.';
COMMENT ON COLUMN system.report_group.display_value IS 'The text value that will be displayed as a menu item under the main Reports menu.';
COMMENT ON COLUMN system.report_group.status IS 'The status of the group.';
COMMENT ON COLUMN system.report_group.description IS 'A description of the report group.';

INSERT INTO system.report_group (code, display_value, status, description) VALUES ('claims', 'Claims', 'c', 'Claims statistics');
INSERT INTO system.report_group (code, display_value, status, description) VALUES ('public-display', 'Public Display', 'c', 'Public display reports');

CREATE TABLE system.report
(
  id character varying(40) NOT NULL DEFAULT uuid_generate_v1(), 
  display_name character varying(5000) NOT NULL, 
  file_name character varying(250) NOT NULL, 
  group_code character varying(20), 
  description character varying(10000), 
  display_in_menu boolean NOT NULL DEFAULT true, 
  CONSTRAINT report_pkey PRIMARY KEY (id),
  CONSTRAINT group_code_fk107 FOREIGN KEY (group_code)
      REFERENCES system.report_group (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT report_display_value_unique UNIQUE (display_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.report
  OWNER TO postgres;
COMMENT ON TABLE system.report
  IS 'Contains a list of reports, avaialble to the users.';
COMMENT ON COLUMN system.report.id IS 'Unique identifier of the record.';
COMMENT ON COLUMN system.report.display_name IS 'The display name of the report.';
COMMENT ON COLUMN system.report.file_name IS 'File name of the report. The system will search for this name and execute a report.';
COMMENT ON COLUMN system.report.group_code IS 'The report group code, used for grouping report. If the value is empty, the report will appear immediately under the Reports menu.';
COMMENT ON COLUMN system.report.description IS 'Short report description.';
COMMENT ON COLUMN system.report.display_in_menu IS 'A flag indicating whether to display this report item under the menu or not. It is used for the certificate report, to hide it from the menu.';

INSERT INTO system.report (id, display_name, file_name, group_code, description, display_in_menu) 
  VALUES ('ClaimCertificate', 'Claim Certificate', 'ClaimCertificate.jasper', null, 'Claim certificate report', 'f');
INSERT INTO system.report (id, display_name, file_name, group_code, description, display_in_menu) 
  VALUES ('ClaimLandUse', 'Claims by land use', 'ClaimsByLanduse.jasper', 'claims', 'Summary of claims by land use', 't');
INSERT INTO system.report (id, display_name, file_name, group_code, description, display_in_menu) 
  VALUES ('ClaimsByGender', 'Claims by gender', 'ClaimsByGender.jasper', 'claims', 'Claims by gender', 't');
INSERT INTO system.report (id, display_name, file_name, group_code, description, display_in_menu) 
  VALUES ('ClaimsSummary', 'Claims summary', 'ClaimsSummary.jasper', 'claims', 'Summary of claims', 't');
INSERT INTO system.report (id, display_name, file_name, group_code, description, display_in_menu) 
  VALUES ('ClaimStatus', 'Claims by status', 'ClaimsByStatus.jasper', 'claims', 'Summary of claims and challenges by status', 't');
INSERT INTO system.report (id, display_name, file_name, group_code, description, display_in_menu) 
  VALUES ('ClaimTypes', 'Claims by type', 'ClaimsByType.jasper', 'claims', 'Summary of claims by claim type', 't');
INSERT INTO system.report (id, display_name, file_name, group_code, description, display_in_menu) 
  VALUES ('PublicDisplayClaimsListByName', 'Claims by claimant name', 'PublicDisplayClaimsListByName.jasper', 'public-display', 'Claim listing by claimant name', 't');
INSERT INTO system.report (id, display_name, file_name, group_code, description, display_in_menu) 
  VALUES ('PublicDisplayClaimsListByNumber', 'Claims by number', 'PublicDisplayClaimsListByNumber.jasper', 'public-display', 'Claim listing by number', 't');

-- Projects

CREATE TABLE system.project
(
  id character varying(40) NOT NULL DEFAULT uuid_generate_v1(), 
  display_name character varying NOT NULL, 
  boundary geometry, 
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), 
  rowversion integer NOT NULL DEFAULT 0, 
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, 
  change_user character varying(50),
  change_time timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT project_pkey PRIMARY KEY (id),
  CONSTRAINT project_display_name_unique UNIQUE (display_name),
  CONSTRAINT project_enforce_boundary_geotype CHECK (geometrytype(boundary) = 'POLYGON'::text OR geometrytype(boundary) = 'MULTIPOLYGON'::text OR boundary IS NULL),
  CONSTRAINT project_enforce_valid_boundary CHECK (st_isvalid(boundary))
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.project
  OWNER TO postgres;
COMMENT ON TABLE system.project
  IS 'Adjudication projects.';
COMMENT ON COLUMN system.project.id IS 'Primary key.';
COMMENT ON COLUMN system.project.display_name IS 'Displayed name of the project.';
COMMENT ON COLUMN system.project.boundary IS 'Project boundary.';
COMMENT ON COLUMN system.project.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';
COMMENT ON COLUMN system.project.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN system.project.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN system.project.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN system.project.change_time IS 'The date and time the row was last modified.';

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON system.project
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON system.project
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_for_trg_track_history();

CREATE TABLE system.project_historic
(
  id character varying(40),
  display_name character varying,
  boundary geometry,
  rowidentifier character varying(40),
  rowversion integer,
  change_action character(1),
  change_user character varying(50),
  change_time timestamp without time zone,
  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.project_historic
  OWNER TO postgres;

CREATE TABLE system.project_appuser
(
  project_id character varying(40) NOT NULL, -- Project id.
  appuser_id character varying(40) NOT NULL, -- User id.
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), -- Identifies the all change records for the row in the form historic table.
  rowversion integer NOT NULL DEFAULT 0, -- Sequential value indicating the number of times this row has been modified.
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, -- Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).
  change_user character varying(50), -- The user id of the last person to modify the row.
  change_time timestamp without time zone NOT NULL DEFAULT now(), -- The date and time the row was last modified.
  CONSTRAINT project_appuser_pkey PRIMARY KEY (project_id, appuser_id),
  CONSTRAINT fk_project_appuser_appuser_id FOREIGN KEY (appuser_id)
      REFERENCES system.appuser (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_project_appuser_project_id FOREIGN KEY (project_id)
      REFERENCES system.project (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.project_appuser
  OWNER TO postgres;
COMMENT ON TABLE system.project_appuser
  IS 'Users who can access adjudication projects.';
COMMENT ON COLUMN system.project_appuser.project_id IS 'Project id.';
COMMENT ON COLUMN system.project_appuser.appuser_id IS 'User id.';
COMMENT ON COLUMN system.project_appuser.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';
COMMENT ON COLUMN system.project_appuser.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN system.project_appuser.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN system.project_appuser.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN system.project_appuser.change_time IS 'The date and time the row was last modified.';

CREATE TABLE system.project_appuser_historic
(
  project_id character varying(40),
  appuser_id character varying(40),
  rowidentifier character varying(40),
  rowversion integer,
  change_action character(1),
  change_user character varying(50),
  change_time timestamp without time zone,
  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.project_appuser_historic
  OWNER TO postgres;

CREATE TABLE system.project_map_layer
(
  project_id character varying(40) NOT NULL, -- Project id.
  layer_id character varying(50) NOT NULL, -- Map layer id.
  layer_order integer NOT NULL DEFAULT 0, -- Map layer order.
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), -- Identifies the all change records for the row in the form historic table.
  rowversion integer NOT NULL DEFAULT 0, -- Sequential value indicating the number of times this row has been modified.
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, -- Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).
  change_user character varying(50), -- The user id of the last person to modify the row.
  change_time timestamp without time zone NOT NULL DEFAULT now(), -- The date and time the row was last modified.
  CONSTRAINT project_map_layer_pkey PRIMARY KEY (project_id, layer_id),
  CONSTRAINT fk_project_map_layer_layer_id FOREIGN KEY (layer_id)
      REFERENCES system.config_map_layer (name) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_project_map_layer_project_id FOREIGN KEY (project_id)
      REFERENCES system.project (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.project_map_layer
  OWNER TO postgres;
COMMENT ON TABLE system.project_map_layer
  IS 'Map layers, accessible for adjudication projects.';
COMMENT ON COLUMN system.project_map_layer.project_id IS 'Project id.';
COMMENT ON COLUMN system.project_map_layer.layer_id IS 'Map layer id.';
COMMENT ON COLUMN system.project_map_layer.layer_order IS 'Map layer order.';
COMMENT ON COLUMN system.project_map_layer.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';
COMMENT ON COLUMN system.project_map_layer.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN system.project_map_layer.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN system.project_map_layer.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN system.project_map_layer.change_time IS 'The date and time the row was last modified.';

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON system.project_map_layer
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON system.project_map_layer
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_for_trg_track_history();

CREATE TABLE system.project_map_layer_historic
(
  project_id character varying(40),
  layer_id character varying(40),
  layer_order integer,
  rowidentifier character varying(40),
  rowversion integer,
  change_action character(1),
  change_user character varying(50),
  change_time timestamp without time zone,
  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.project_map_layer_historic
  OWNER TO postgres;

CREATE TABLE system.project_setting
(
  project_id character varying(40) NOT NULL, -- Project ID
  name character varying(50) NOT NULL, -- Identifier/name for the setting
  vl character varying(1000000) NOT NULL, -- The value for the setting.
  CONSTRAINT project_setting_pkey PRIMARY KEY (project_id, name),
  CONSTRAINT fk_project_setting_project FOREIGN KEY (project_id)
      REFERENCES system.project (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_project_setting_setting FOREIGN KEY (name)
      REFERENCES system.setting (name) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.project_setting
  OWNER TO postgres;
COMMENT ON TABLE system.project_setting
  IS 'Contains project specific settings, which will override global system settings.';
COMMENT ON COLUMN system.project_setting.project_id IS 'Project ID';
COMMENT ON COLUMN system.project_setting.name IS 'Identifier/name for the setting';
COMMENT ON COLUMN system.project_setting.vl IS 'The value for the setting.';

-- Create default project
INSERT INTO system.project(id, display_name, boundary) VALUES ('default-project', 'Default', ST_GeomFromText((SELECT vl FROM system.setting WHERE name = 'ot-community-area'), 4326));

-- Delete community area setting
DELETE FROM system.setting WHERE name = 'ot-community-area';

ALTER TABLE opentenure.claim
  ADD COLUMN project_id character varying(40);
ALTER TABLE opentenure.claim
  ADD CONSTRAINT fk_claim_project FOREIGN KEY (project_id) REFERENCES system.project (id) ON UPDATE CASCADE ON DELETE RESTRICT;
COMMENT ON COLUMN opentenure.claim.project_id IS 'Project ID';

ALTER TABLE opentenure.claim_historic
  ADD COLUMN project_id character varying(40);

ALTER TABLE opentenure.administrative_boundary
  ADD COLUMN project_id character varying(40);
ALTER TABLE opentenure.administrative_boundary
  ADD CONSTRAINT fk_admin_boundary_project FOREIGN KEY (project_id) REFERENCES system.project (id) ON UPDATE CASCADE ON DELETE RESTRICT;
COMMENT ON COLUMN opentenure.administrative_boundary.project_id IS 'Project ID';

ALTER TABLE opentenure.administrative_boundary_historic
  ADD COLUMN project_id character varying(40);

-- Move all claims and admin boundaries into default project
UPDATE opentenure.claim SET project_id = 'default-project';
UPDATE opentenure.administrative_boundary SET project_id = 'default-project';

ALTER TABLE opentenure.claim
   ALTER COLUMN project_id SET NOT NULL;

ALTER TABLE opentenure.administrative_boundary
   ALTER COLUMN project_id SET NOT NULL;

-- Assign users to the default project
INSERT INTO system.project_appuser(project_id, appuser_id)
    SELECT 'default-project', id FROM system.appuser;

-- Link map layers to the default project
INSERT INTO system.project_map_layer(project_id, layer_id, layer_order)
    SELECT 'default-project', name, item_order FROM system.config_map_layer;

CREATE OR REPLACE FUNCTION opentenure.get_full_admin_boundary_name(
    admin_id character varying)
  RETURNS character varying AS
$BODY$
begin
  return (WITH RECURSIVE administrative_boundaries AS (
 SELECT a.id, a.name::varchar(1000), 1 as level
   FROM opentenure.administrative_boundary a
   WHERE a.parent_id is null
 UNION 
 SELECT b.id, (b.name::varchar || ', ' || ab.name)::varchar(1000) as name, ab.level + 1 as level
   FROM opentenure.administrative_boundary b inner join administrative_boundaries ab on b.parent_id = ab.id 
 )
 SELECT name as full_location FROM administrative_boundaries where id= admin_id);
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION opentenure.get_full_admin_boundary_name(character varying)
  OWNER TO postgres;
COMMENT ON FUNCTION opentenure.get_full_admin_boundary_name(character varying) IS 'Returns fulladministrative boundary name.';

INSERT INTO system.setting(name, vl, active, description) VALUES ('project-language','en-US',TRUE,'Language code, used as the main project language. For instance it can be used as the language for printing forms, demanding them to use project language locale for its localization.');
INSERT INTO system.setting(name, vl, active, description) VALUES ('client-tiles-layer-name','',TRUE,'Tiles layer name for mobile client to pull offline map layer.');
INSERT INTO system.setting(name, vl, active, description) VALUES ('client-tiles-server-type','geoserver',TRUE,'Tiles server type for mobile client to pull offline map layer. Allowed vaules - geoserver, wtms, tms');
INSERT INTO system.setting(name, vl, active, description) VALUES ('client-tiles-server-url','',TRUE,'Tiles server URL for mobile client to pull offline map layer.');
