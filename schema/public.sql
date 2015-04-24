-- Function public.f_for_trg_track_changes --
CREATE OR REPLACE FUNCTION public.f_for_trg_track_changes(

) RETURNS trigger 
AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF (NEW.rowversion != OLD.rowversion) THEN
            RAISE EXCEPTION 'row_has_different_change_time';
        END IF;
        IF (NEW.change_action != 'd') THEN
            NEW.change_action := 'u';
        END IF;
        IF OLD.rowversion > 200000000 THEN
            NEW.rowversion = 1;
        ELSE
            NEW.rowversion = OLD.rowversion + 1;
        END IF;
    ELSIF (TG_OP = 'INSERT') THEN
        NEW.change_action := 'i';
        NEW.rowversion = 1;
    END IF;
    NEW.change_time := now();
    IF NEW.change_user is null then
      NEW.change_user = 'db:' || current_user;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION public.f_for_trg_track_changes(

) IS 'This function is called from triggers in every table that has the columns to track changes. <br/>
If the change_user is null then it is filled with the value from the database user prefixed by ''db:''.
It also checks if the record has been already updated from another client application by checking the rowversion.';
    
-- Function public.f_for_trg_track_history --
CREATE OR REPLACE FUNCTION public.f_for_trg_track_history(

) RETURNS trigger 
AS $$
DECLARE
    table_name_main varchar;
    table_name_historic varchar;
    insert_col_part varchar;
    values_part varchar;
BEGIN
    table_name_main = TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME;
    table_name_historic = table_name_main || '_historic';
    insert_col_part = (select string_agg(column_name, ',') 
      from information_schema.columns  
      where table_schema= TG_TABLE_SCHEMA and table_name = TG_TABLE_NAME);
    values_part = '$1.' || replace(insert_col_part, ',' , ',$1.');

    IF (TG_OP = 'DELETE') THEN
        OLD.change_action := 'd';
    END IF;
    EXECUTE 'INSERT INTO ' || table_name_historic || '(' || insert_col_part || ') SELECT ' || values_part || ';' USING OLD;
    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION public.f_for_trg_track_history(

) IS 'This function is called after a change is happening in a table to push the former values to the historic keeping table.';
    
-- Function public.fn_triggerall --
CREATE OR REPLACE FUNCTION public.fn_triggerall(
 doenable bool
) RETURNS integer 
AS $$
DECLARE
  rec RECORD;
BEGIN
  FOR rec IN select * from information_schema.tables where table_type = 'BASE TABLE' and table_schema not in ('pg_catalog', 'information_schema')
  LOOP
    IF DoEnable THEN
      EXECUTE 'ALTER TABLE "'  || rec.table_schema || '"."' ||  rec.table_name || '" ENABLE TRIGGER ALL';
    ELSE
      EXECUTE 'ALTER TABLE "'  || rec.table_schema || '"."' ||  rec.table_name || '" DISABLE TRIGGER ALL';
    END IF; 
  END LOOP; 
  RETURN 1;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION public.fn_triggerall(
 doenable bool
) IS 'This function can be used to disable all triggers in the database.

<b>How to use </b>
to call to disable all triggers in all schemas in db
select fn_triggerall(false);

to call to enable all triggers in all schemas in db
select fn_triggerall(true);
';
    
-- Function public.clean_db --
CREATE OR REPLACE FUNCTION public.clean_db(
 schema_name varchar
) RETURNS integer 
AS $$
DECLARE
  rec RECORD;

BEGIN
  FOR rec IN select * from information_schema.tables 
	where table_type = 'BASE TABLE' and table_schema = schema_name and table_name not in ('geometry_columns', 'spatial_ref_sys')
  LOOP
      EXECUTE 'DROP TABLE IF EXISTS "'  || rec.table_schema || '"."' ||  rec.table_name || '" CASCADE;';
  END LOOP;
  FOR rec IN select '"' || routine_schema || '"."' || routine_name || '"'  as full_name 
        from information_schema.routines  where routine_schema='public' 
            and data_type = 'trigger' and routine_name not in ('postgis_cache_bbox', 'checkauthtrigger', 'f_for_trg_track_history', 'f_for_trg_track_changes')
  LOOP
      EXECUTE 'DROP FUNCTION IF EXISTS '  || rec.full_name || '() CASCADE;';    
  END LOOP;
  RETURN 1; 
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION public.clean_db(
 schema_name varchar
) IS 'This function will delete any table and function in a schema that does not belong to the standard postgis template.';
    
-- Function public.compare_strings --
 CREATE OR REPLACE FUNCTION compare_strings(string1 character varying, string2 character varying)
  RETURNS boolean AS
$BODY$
  DECLARE
    rec record;
    result boolean;
  BEGIN
      result = false;
      for rec in select regexp_split_to_table(lower(string1),'[^a-z0-9\\s]') as word loop
          if rec.word != '' then 
            if not string2 ~* rec.word then
                return false;
            end if;
            result = true;
          end if;
      end loop;
      return result;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION compare_strings(character varying, character varying)
  OWNER TO postgres;
COMMENT ON FUNCTION compare_strings(character varying, character varying) IS E'Special string compare function. Allows spaces to be recognized as valid search parameters when entered as \s';
    
-- Function public.get_geometry_with_srid --
CREATE OR REPLACE FUNCTION public.get_geometry_with_srid(
 geom geometry
) RETURNS geometry 
AS $$
declare
  srid_found integer;
  x float;
begin
  if (select count(*) from system.crs) = 1 then
    return geom;
  end if;
  x = st_x(st_transform(st_centroid(geom), 4326));
  srid_found = (select srid from system.crs where x >= from_long and x < to_long );
  return st_transform(geom, srid_found);
end;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION public.get_geometry_with_srid(
 geom geometry
) IS 'This function assigns a srid found in the settings to the geometry passed as parameter. The srid is chosen based in the longitude where the centroid of the geometry is.';
    
-- Function public.get_translation --
CREATE OR REPLACE FUNCTION public.get_translation(
 mixed_value varchar
  , language_code varchar
) RETURNS varchar 
AS $$
DECLARE
  delimiter_word varchar;
  language_index integer;
  result varchar;
BEGIN
  if mixed_value is null then
    return mixed_value;
  end if;
  delimiter_word = '::::';
  language_index = (select item_order from system.language where lower(code)=lower(language_code));
  result = split_part(mixed_value, delimiter_word, language_index);
  if result is null or result = '' then
    language_index = (select item_order from system.language where is_default limit 1);
    result = split_part(mixed_value, delimiter_word, language_index);
    if result is null or result = '' then
      result = mixed_value;
    end if;
  end if;
  return result;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION public.get_translation(
 mixed_value varchar
  , language_code varchar
) IS 'This function is used to translate the values that are supposed to be multilingual like the reference data values (display_value)';
    
-- Function public.clean_db_foreign_constraints --
CREATE OR REPLACE FUNCTION public.clean_db_foreign_constraints(

) RETURNS void 
AS $$
declare
  rec record;
begin
  for rec in select * from information_schema.table_constraints where constraint_type = 'FOREIGN KEY' loop
    execute 'ALTER TABLE "' || rec.table_schema || '"."' ||  rec.table_name || '" DROP CONSTRAINT "' || rec.constraint_name || '"'; 
    execute 'DROP INDEX IF EXISTS ' || rec.constraint_name || '_ind';
  end loop;
end;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION public.clean_db_foreign_constraints(

) IS 'This function can be used to drop all foreign key constraints from the database.';
    
-- Function public.clean_db_triggers --
CREATE OR REPLACE FUNCTION public.clean_db_triggers(

) RETURNS void 
AS $$
declare
  rec record;
begin
  for rec in SELECT distinct event_object_schema, event_object_table, trigger_name FROM information_schema.triggers 
    where trigger_name not in ('__track_changes', '__track_history') loop
    execute 'DROP TRIGGER "' || rec.trigger_name || '" ON "' || rec.event_object_schema || '"."' ||  rec.event_object_table || '" CASCADE;'; 
  end loop;
  for rec in select '"' || routine_schema || '"."' || routine_name || '"'  as full_name 
        from information_schema.routines  where routine_schema='public' 
            and data_type = 'trigger' and routine_name not in ('postgis_cache_bbox', 'checkauthtrigger', 'f_for_trg_track_history', 'f_for_trg_track_changes' )
  loop
      execute 'DROP FUNCTION IF EXISTS '  || rec.full_name || '() CASCADE;';
  end loop;
end;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION public.clean_db_triggers(

) IS 'This function removes all triggers and their related functions in the database. It assumes that the trigger functions are found in the public schema.';