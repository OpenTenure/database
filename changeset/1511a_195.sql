INSERT INTO system.version SELECT '1511a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1511a');

CREATE SEQUENCE opentenure.form_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 1
  CACHE 1
  CYCLE;
ALTER TABLE opentenure.form_nr_seq
  OWNER TO postgres;
COMMENT ON SEQUENCE opentenure.form_nr_seq
  IS 'Sequence number used to generate dynamiic form number.';

CREATE OR REPLACE FUNCTION opentenure.generate_form_name()
  RETURNS character varying AS
$BODY$
begin
  return ('F' || to_char(now(), 'yymm-') || trim(to_char(nextval('opentenure.form_nr_seq'), '0000')));
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION opentenure.generate_form_name()
  OWNER TO postgres;
COMMENT ON FUNCTION opentenure.generate_form_name() IS 'Generates dynamic form name.';

-- Function: opentenure.f_for_trg_set_default()

-- DROP FUNCTION opentenure.f_for_trg_set_default();

CREATE OR REPLACE FUNCTION opentenure.f_for_trg_set_default()
  RETURNS trigger AS
$BODY$
BEGIN  
  IF (TG_WHEN = 'AFTER') THEN
    IF (TG_OP = 'UPDATE' OR TG_OP = 'INSERT') THEN
        IF (NEW.is_default) THEN
            UPDATE opentenure.form_template SET is_default = 'f' WHERE is_default = 't' AND name != NEW.name;
        ELSE
	    IF (TG_OP = 'UPDATE' AND (SELECT COUNT(1) FROM opentenure.form_template WHERE is_default = 't' AND name != OLD.name) < 1) THEN
	         UPDATE opentenure.form_template SET is_default = 't' WHERE name = OLD.name;
	    ELSIF (TG_OP = 'INSERT' AND (SELECT COUNT(1) FROM opentenure.form_template WHERE is_default = 't') < 1) THEN
		 UPDATE opentenure.form_template SET is_default = 't' WHERE name = NEW.name;
	    END IF;
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        IF ((SELECT COUNT(1) FROM opentenure.form_template WHERE is_default = 't' AND name != OLD.name) < 1) THEN
	     UPDATE opentenure.form_template SET is_default = 't' WHERE name IN (SELECT name FROM opentenure.form_template WHERE name != OLD.name LIMIT 1);
        END IF;
    END IF;
    RETURN NULL;
  END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION opentenure.f_for_trg_set_default()
  OWNER TO postgres;
COMMENT ON FUNCTION opentenure.f_for_trg_set_default() IS 'This function is to set default flag and have at least 1 form as default.';

ALTER TABLE opentenure.claim DROP CONSTRAINT enforce_geotype_gps_geometry;
ALTER TABLE opentenure.claim DROP CONSTRAINT enforce_valid_gps_geometry;
