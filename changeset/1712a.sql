INSERT INTO system.version SELECT '1712a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1712a');

CREATE TABLE opentenure.administrative_boundary_type
(
  code character varying(20) NOT NULL, 
  display_value character varying(500) NOT NULL,
  status character(1) NOT NULL DEFAULT 't'::bpchar, 
  level smallint NOT NULL DEFAULT 1,
  description character varying(1000), 
  CONSTRAINT administrative_boundary_type_pkey PRIMARY KEY (code),
  CONSTRAINT administrative_boundary_type_display_value_unique UNIQUE (display_value),
  CONSTRAINT administrative_boundary_type_level_unique UNIQUE (level)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opentenure.administrative_boundary_type
  OWNER TO postgres;
COMMENT ON TABLE opentenure.administrative_boundary_type
  IS 'Code list of administrative boundary types.';
COMMENT ON COLUMN opentenure.administrative_boundary_type.code IS 'The code of the boundary type.';
COMMENT ON COLUMN opentenure.administrative_boundary_type.display_value IS 'Displayed value of the boundary type.';
COMMENT ON COLUMN opentenure.administrative_boundary_type.status IS 'Status of the type.';
COMMENT ON COLUMN opentenure.administrative_boundary_type.level IS 'Boundary level. Smaller number means higher level.';
COMMENT ON COLUMN opentenure.administrative_boundary_type.description IS 'Description of the boundary type.';


CREATE TABLE opentenure.administrative_boundary_status
(
  code character varying(20) NOT NULL, 
  display_value character varying(500) NOT NULL,
  status character(1) NOT NULL DEFAULT 't'::bpchar, 
  description character varying(1000), 
  CONSTRAINT administrative_boundary_status_pkey PRIMARY KEY (code),
  CONSTRAINT administrative_boundary_status_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opentenure.administrative_boundary_status
  OWNER TO postgres;
COMMENT ON TABLE opentenure.administrative_boundary_status
  IS 'Code list of administrative boundary statuses.';
COMMENT ON COLUMN opentenure.administrative_boundary_status.code IS 'The code of the boundary status.';
COMMENT ON COLUMN opentenure.administrative_boundary_status.display_value IS 'Displayed value of the boundary status.';
COMMENT ON COLUMN opentenure.administrative_boundary_status.status IS 'Status of the record.';
COMMENT ON COLUMN opentenure.administrative_boundary_status.description IS 'Description of the boundary status.';


CREATE TABLE opentenure.administrative_boundary
(
  id character varying(40) NOT NULL,
  name character varying(255) NOT NULL,
  type_code character varying(20) NOT NULL, 
  authority_name character varying(255),
  parent_id character varying(40),
  recorder_name character varying(50) NOT NULL,
  geom geometry,
  status_code character varying(20) NOT NULL DEFAULT 'pending', 
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), 
  rowversion integer NOT NULL DEFAULT 0, 
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, 
  change_user character varying(50), 
  change_time timestamp without time zone NOT NULL DEFAULT now(), 
  CONSTRAINT administrative_boundary_pkey PRIMARY KEY (id),
  CONSTRAINT administrative_boundary_parent_id_fk FOREIGN KEY (parent_id)
      REFERENCES opentenure.administrative_boundary (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT administrative_boundary_status_code_fk FOREIGN KEY (status_code)
      REFERENCES opentenure.administrative_boundary_status (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT administrative_boundary_type_code_fk FOREIGN KEY (type_code)
      REFERENCES opentenure.administrative_boundary_type (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT enforce_geom_geometry CHECK (geometrytype(geom) = 'POLYGON'::text OR geom IS NULL),
  CONSTRAINT enforce_valid_geom CHECK (st_isvalid(geom))
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opentenure.administrative_boundary
  OWNER TO postgres;
COMMENT ON TABLE opentenure.administrative_boundary
  IS 'Administrative boundaries, such as villages, distrcits, etc.';
COMMENT ON COLUMN opentenure.administrative_boundary.id IS 'Identifier for the boundary.';
COMMENT ON COLUMN opentenure.administrative_boundary.name IS 'Official boundary name.';
COMMENT ON COLUMN opentenure.administrative_boundary.type_code IS 'Boundary type code';
COMMENT ON COLUMN opentenure.administrative_boundary.authority_name IS 'Authority name, rulling the boundary';
COMMENT ON COLUMN opentenure.administrative_boundary.parent_id IS 'Parent boundary ID.';
COMMENT ON COLUMN opentenure.administrative_boundary.recorder_name IS 'Boundary recorder name';
COMMENT ON COLUMN opentenure.administrative_boundary.geom IS 'Actual geometry of the boundary.';
COMMENT ON COLUMN opentenure.administrative_boundary.status_code IS 'Status code of the boundary.';
COMMENT ON COLUMN opentenure.administrative_boundary.rowidentifier IS 'Identifies the all change records for the row in the claim_share_historic table';
COMMENT ON COLUMN opentenure.administrative_boundary.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.administrative_boundary.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.administrative_boundary.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.administrative_boundary.change_time IS 'The date and time the row was last modified.';

CREATE TABLE opentenure.administrative_boundary_historic
(
  id character varying(40),
  name character varying(255),
  type_code character varying(20), 
  authority_name character varying(255),
  parent_id character varying(40),
  recorder_name character varying(50),
  geom geometry,
  status_code character varying(20), 
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
ALTER TABLE opentenure.administrative_boundary_historic
  OWNER TO postgres;
COMMENT ON TABLE opentenure.administrative_boundary_historic
  IS 'Historic for administrative boundaries table.';

-- DROP TRIGGER __track_changes ON opentenure.administrative_boundary;

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.administrative_boundary
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_for_trg_track_changes();

-- DROP TRIGGER __track_history ON opentenure.administrative_boundary;

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.administrative_boundary
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_for_trg_track_history();


ALTER TABLE opentenure.claim ADD COLUMN boundary_id character varying(40);
ALTER TABLE opentenure.claim ADD CONSTRAINT fk_claim_administrative_boundary FOREIGN KEY (boundary_id) REFERENCES opentenure.administrative_boundary (id) ON UPDATE NO ACTION ON DELETE NO ACTION;

COMMENT ON COLUMN opentenure.claim.boundary_id IS 'Administrative boundary id';

ALTER TABLE opentenure.claim_historic ADD COLUMN boundary_id character varying(40);
