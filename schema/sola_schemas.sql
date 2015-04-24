--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: address; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA address;


ALTER SCHEMA address OWNER TO postgres;

--
-- Name: SCHEMA address; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA address IS 'Extension to the LADM for capturing postal and physical addresses. Allows SOLA to support integration with external address validation services if required.';


--
-- Name: administrative; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA administrative;


ALTER SCHEMA administrative OWNER TO postgres;

--
-- Name: SCHEMA administrative; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA administrative IS 'The SOLA implementation of the LADM Administrative package. Models land use rights and restrictions how those rights and restrictions relate to property and people.';


--
-- Name: application; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA application;


ALTER SCHEMA application OWNER TO postgres;

--
-- Name: SCHEMA application; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA application IS 'Extension to the LADM used by SOLA to implement Case Management functionality.';


--
-- Name: bulk_operation; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA bulk_operation;


ALTER SCHEMA bulk_operation OWNER TO postgres;

--
-- Name: SCHEMA bulk_operation; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA bulk_operation IS 'Extension to the LADM used by SOLA to implement Bulk Operation functionality such as loading of shapefiles and documents.';


--
-- Name: cadastre; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA cadastre;


ALTER SCHEMA cadastre OWNER TO postgres;

--
-- Name: SCHEMA cadastre; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA cadastre IS 'The SOLA implementation of the LADM Spatial Unit Package. Represents parcels of land and water that can be associated to rights (a.k.a. Cadastre Objects) as well as general spatial or geographic features such as roads, hydro and place names, etc. General spatial features are also known as Spatial Units in SOLA.';


--
-- Name: document; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA document;


ALTER SCHEMA document OWNER TO postgres;

--
-- Name: SCHEMA document; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA document IS 'Extension to the LADM used by SOLA to store electronic copies of documentation provided in support of land related dealings. Allows SOLA to support integration with external Document Management Systems (DMS) if required.';


--
-- Name: opentenure; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA opentenure;


ALTER SCHEMA opentenure OWNER TO postgres;

--
-- Name: SCHEMA opentenure; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA opentenure IS 'This schema holds objects purely related to OpenTenure feature of SOLA';


--
-- Name: party; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA party;


ALTER SCHEMA party OWNER TO postgres;

--
-- Name: SCHEMA party; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA party IS 'The SOLA implementation of the LADM Party package. Represents people and organisations that are associated to land rights and/or land transactions.';


--
-- Name: source; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA source;


ALTER SCHEMA source OWNER TO postgres;

--
-- Name: SCHEMA source; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA source IS 'The SOLA implementation of the LADM LA_Source class. Represents metadata about documents provided to support land related dealings.';


--
-- Name: system; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA system;


ALTER SCHEMA system OWNER TO postgres;

--
-- Name: SCHEMA system; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA system IS 'Extension to the LADM that contains SOLA system configuration, business rules and user details.';


--
-- Name: transaction; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA transaction;


ALTER SCHEMA transaction OWNER TO postgres;

--
-- Name: SCHEMA transaction; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA transaction IS 'Extension to the LADM used by SOLA to track all changes made to data as a result of an application service.';


SET search_path = administrative, pg_catalog;

--
-- Name: ba_unit_name_is_valid(character varying, character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION ba_unit_name_is_valid(name_firstpart character varying, name_lastpart character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
  if name_firstpart is null then return false; end if;
  if name_lastpart is null then return false; end if;
  if name_firstpart not like 'N%' then return false; end if;
  if name_lastpart not similar to '[0-9]+' then return false; end if;
  return true;
end;
$$;


ALTER FUNCTION administrative.ba_unit_name_is_valid(name_firstpart character varying, name_lastpart character varying) OWNER TO postgres;

--
-- Name: FUNCTION ba_unit_name_is_valid(name_firstpart character varying, name_lastpart character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION ba_unit_name_is_valid(name_firstpart character varying, name_lastpart character varying) IS 'Checks if the first and last name for a BA Unit match the naming convention used by this SOLA implementation.';


--
-- Name: f_for_tbl_rrr_trg_change_from_pending(); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION f_for_tbl_rrr_trg_change_from_pending() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if old.status_code = 'pending' and new.status_code in ( 'current', 'historic') then
    update administrative.rrr set 
      status_code= 'previous', change_user=new.change_user
    where ba_unit_id= new.ba_unit_id and nr= new.nr and status_code = 'current';
  end if;
  return new;
end;
$$;


ALTER FUNCTION administrative.f_for_tbl_rrr_trg_change_from_pending() OWNER TO postgres;

--
-- Name: FUNCTION f_for_tbl_rrr_trg_change_from_pending(); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION f_for_tbl_rrr_trg_change_from_pending() IS 'Function triggered on an update to the RRR table that sets the status of any Current RRR matching the Nr of the RRR record being updated to Previous. Used to implement versioning of RRR records.';


--
-- Name: get_ba_unit_pending_action(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION get_ba_unit_pending_action(baunit_id character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
  return (SELECT rt.type_action_code
  FROM ((administrative.ba_unit_target bt INNER JOIN transaction.transaction t ON bt.transaction_id = t.id)
  INNER JOIN application.service s ON t.from_service_id = s.id)
  INNER JOIN application.request_type rt ON s.request_type_code = rt.code
  WHERE bt.ba_unit_id = baunit_id AND t.status_code = 'pending'
  LIMIT 1);
END;
$$;


ALTER FUNCTION administrative.get_ba_unit_pending_action(baunit_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_ba_unit_pending_action(baunit_id character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION get_ba_unit_pending_action(baunit_id character varying) IS 'Determines the action (New, Vary or Cancel) that applies to the BA Unit based on the service it is associated with.';


--
-- Name: get_calculated_area_size_action(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION get_calculated_area_size_action(co_list character varying) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN

  return (
          select coalesce(cast(sum(a.size)as float),0)
	  from cadastre.spatial_value_area a
	  where  a.type_code = 'officialArea'
	  and a.spatial_unit_id = ANY(string_to_array(co_list, ' '))
         );
END;
$$;


ALTER FUNCTION administrative.get_calculated_area_size_action(co_list character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_calculated_area_size_action(co_list character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION get_calculated_area_size_action(co_list character varying) IS 'Returns the sum of any official parcel areas (i.e. cadastre.spatial_value_area) associated to the BA Unit.';


--
-- Name: get_concatenated_name(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION get_concatenated_name(baunit_id character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
  rec record;
  name character varying;
  
BEGIN
  name = '';
   
	for rec in 
           Select pippo.firstpart||'/'||pippo.lastpart || ' ' || pippo.cadtype  as value
   from 
   administrative.ba_unit bu join
	   (select co.name_firstpart firstpart,
	   co.name_lastpart lastpart,
	    get_translation(cot.display_value, null) cadtype,
	   bsu.ba_unit_id unit_id
	   from administrative.ba_unit_contains_spatial_unit  bsu
	   join cadastre.cadastre_object co on (bsu.spatial_unit_id = co.id)
	   join cadastre.cadastre_object_type cot on (co.type_code = cot.code)) pippo
           on (bu.id = pippo.unit_id)
	   where bu.id = baunit_id
	loop
           name = name || ', ' || rec.value;
	end loop;

        if name = '' then
	  name = ' ';
       end if;

	if substr(name, 1, 1) = ',' then
          name = substr(name,2);
        end if;
return name;
END;

$$;


ALTER FUNCTION administrative.get_concatenated_name(baunit_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_concatenated_name(baunit_id character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION get_concatenated_name(baunit_id character varying) IS 'Returns a concatenated list of all cadastre objects associated to the BA Unit';


--
-- Name: get_objections(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION get_objections(namelastpart character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
  rec record;
  name character varying;
  
BEGIN
  name = '';
   
	for rec in 
       Select distinct to_char(s.lodging_datetime, 'YYYY/MM/DD') as value
       FROM cadastre.cadastre_object co, 
       cadastre.spatial_value_area sa, 
       administrative.ba_unit_contains_spatial_unit su, 
       application.application_property ap, 
       application.application aa, application.service s, 
       party.party pp, administrative.party_for_rrr pr, 
       administrative.rrr rrr, administrative.ba_unit bu
          WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text 
          AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
          AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) 
          AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'lodgeObjection'::text 
          AND s.status_code::text != 'cancelled'::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text 
          AND rrr.ba_unit_id::text = su.ba_unit_id::text 
          AND bu.id::text = su.ba_unit_id::text
          AND bu.name_lastpart = namelastpart
   	loop
           name = name || ', ' || rec.value;
	end loop;

        if name = '' then
	  name = 'No objections ';
       end if;

	if substr(name, 1, 1) = ',' then
          name = substr(name,2);
        end if;
return name;
END;
$$;


ALTER FUNCTION administrative.get_objections(namelastpart character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_objections(namelastpart character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION get_objections(namelastpart character varying) IS 'Returns a list of dates indicating when objections were lodged against the BA Unit. Used by Systematic Registration.';


--
-- Name: get_parcel_ownergender(character varying, character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION get_parcel_ownergender(gender character varying, query character varying) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE 

  rec record;
  total decimal =0;
  totFem decimal =0;
  totMale decimal =0;
  totMixed decimal =0;
  totJoint decimal =0;
  totEntity decimal =0;
  totNull decimal =0;
  parcel varchar;
  recExt   record;
  sqlSt varchar;
  statusFound	boolean;
  recToReturn	record;
  
BEGIN
     total = 0;
     sqlSt:= '';

     --sqlSt:= 'select sg.name   as area
	--		  from  
	--		  cadastre.spatial_unit_group sg 
	--		  where 
	--		  sg.hierarchy_level=3
	--		  order by area asc
    --';  
    --raise exception '%',sqlSt;
      -- statusFound = false;

    -- Loop through results
    
    --FOR recExt in EXECUTE sqlSt loop
    --statusFound = true; 
     
	for rec in 
	--statusFound = true; 
		SELECT distinct buExt.id as id, 
		(select count (*) from party.party pp,
		     administrative.ba_unit bu,
		     administrative.party_for_rrr pfr,
		     administrative.rrr rrr
		     WHERE buExt.id=bu.id 
		     and bu.id=rrr.ba_unit_id
		     and rrr.id = pfr.rrr_id
		     and pp.id = pfr.party_id
		     AND (rrr.type_code::text = 'ownership'::text 
		     OR rrr.type_code::text = 'apartment'::text 
		     OR rrr.type_code::text = 'commonOwnership'::text) 
		     and pp.gender_code = 'female') as female,
		(select count (*) from party.party pp,
		     administrative.ba_unit bu,
		     administrative.party_for_rrr pfr,
		     administrative.rrr rrr
		     WHERE buExt.id=bu.id 
		     and bu.id=rrr.ba_unit_id
		     and rrr.id = pfr.rrr_id
		     and pp.id = pfr.party_id
		     AND (rrr.type_code::text = 'ownership'::text 
		     OR rrr.type_code::text = 'apartment'::text 
		     OR rrr.type_code::text = 'commonOwnership'::text) 
		     and pp.gender_code ='male') as male,
		(select count (*) from party.party pp,
		     administrative.ba_unit bu,
		     administrative.party_for_rrr pfr,
		     administrative.rrr rrr
		     WHERE buExt.id=bu.id 
		     and bu.id=rrr.ba_unit_id
		     and rrr.id = pfr.rrr_id
		     and pp.id = pfr.party_id
		     AND (rrr.type_code::text = 'ownership'::text 
		     OR rrr.type_code::text = 'apartment'::text 
		     OR rrr.type_code::text = 'commonOwnership'::text) 
		     and pp.type_code ='nonNaturalPerson') as entity,
		     buExt.name_lastpart  as parcel
	             from party.party pp,
			administrative.ba_unit buExt,
			administrative.party_for_rrr pfr,
			administrative.rrr rrr
	WHERE buExt.id=rrr.ba_unit_id 
	and rrr.id = pfr.rrr_id
	and pp.id = pfr.party_id
	AND (rrr.type_code::text = 'ownership'::text 
	OR rrr.type_code::text = 'apartment'::text 
	OR rrr.type_code::text = 'commonOwnership'::text) 
	--AND buExt.name_lastpart = ''||recExt.area||''
		
       loop

		 if rec.female = 0 and rec.male != 0 then
		    totMale = totMale + 1;
		 end if;
		 if rec.female != 0 and rec.male = 0 then
		   totFem = totFem + 1;
		 end if;  
		 if rec.female = 1 and rec.male = 1 then
		   totJoint = totJoint+1;
		 end if;
		 if ((rec.female > 1 and rec.male >= 1)or (rec.female >= 1 and rec.male >1)) then
		   totMixed = totMixed+1;
		 end if; 
		 if ((rec.female = 0 and rec.male = 0) and rec.entity >0) then
		     totEntity =  totEntity + 1;
		 end if;
		 if (rec.female = 0 and rec.male = 0 and rec.entity =0) then
		     totNull =  totNull + 1;
		 end if;
		 total := totMale+totFem+totJoint+totMixed+totEntity+totNull;
        end loop; 
        

          --parcel = recExt.area;
                   parcel = 'Waiheke';
	  select into recToReturn
	        parcel::    varchar,
                total::     decimal,
		totFem::    decimal,
		totMale::   decimal,
		totMixed::  decimal,
		totJoint::  decimal,
		totEntity:: decimal,
		totNull::   decimal;
		                         
           return next recToReturn;
          statusFound = true;
          total     =0;
	  totFem    =0;
	  totMale   =0;
	  totMixed  =0;
	  totJoint  =0;
	  totEntity =0;
	  totNull   =0;
    --end loop;
   
    if (not statusFound) then
         parcel = 'none';
                
        select into recToReturn
	       	parcel::   varchar,
                total::    decimal,
		totFem::   decimal,
		totMale::  decimal,
		totMixed:: decimal,
		totJoint:: decimal,
		totEntity:: decimal,
		totNull::   decimal;
		                         
		                         
          return next recToReturn;

    end if;
    return;
END;
$$;


ALTER FUNCTION administrative.get_parcel_ownergender(gender character varying, query character varying) OWNER TO postgres;

--
-- Name: get_parcel_ownernames(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION get_parcel_ownernames(baunit_id character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
  rec record;
  name character varying;
  
BEGIN
  name = '';
   
	for rec in 
           select pp.name||' '||pp.last_name as value
		from party.party pp,
		     administrative.party_for_rrr  pr,
		     administrative.rrr rrr
		where pp.id=pr.party_id
		and   pr.rrr_id=rrr.id
		and   rrr.ba_unit_id= baunit_id
		and   (rrr.type_code='ownership'
		       or rrr.type_code='apartment'
		       or rrr.type_code='commonOwnership'
		       or rrr.type_code='stateOwnership')
		
	loop
           name = name || ', ' || rec.value;
	end loop;

        if name = '' then
	  name = 'No claimant identified ';
       end if;

	if substr(name, 1, 1) = ',' then
          name = substr(name,2);
        end if;
return name;
END;
$$;


ALTER FUNCTION administrative.get_parcel_ownernames(baunit_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_parcel_ownernames(baunit_id character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION get_parcel_ownernames(baunit_id character varying) IS 'Returns a list of names of people associated to the BA Unit as an owner.';


--
-- Name: getsysregmanagement(character varying, character varying, character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION getsysregmanagement(fromdate character varying, todate character varying, namelastpart character varying) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE 

       counter   decimal:=0 ;
       descr    varchar; 
       area    varchar; 

    
       rec     record;
       sqlSt varchar;
       managementFound boolean;
       recToReturn record;
    
BEGIN  
    
    sqlSt:= '';
    
    sqlSt:= 'SELECT  
		    count (distinct(aa.id)) counter,
		    get_translation(''Applications::::Pratiche'', NULL::character varying) descr,
		    1 as order,
		    get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    FROM  application.application aa,
			  application.service s
		    WHERE s.application_id = aa.id
		    AND   s.request_type_code::text = ''systematicRegn''::text
		    AND  (
		          (aa.lodging_datetime  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd''))
		           or
		          (aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd''))
		          )
             UNION
		     select count (distinct(aa.id)) counter,
		     get_translation(''Applications with spatial object::::Pratiche con particelle'', NULL::character varying) descr,
		     2 as order,
		     get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                 from application.application aa, 
		     administrative.ba_unit_contains_spatial_unit su, 
		     application.application_property ap,
		     application.service s
		 WHERE ap.ba_unit_id::text = su.ba_unit_id::text 
		 AND   aa.id::text = ap.application_id::text
		 AND   s.request_type_code::text = ''systematicRegn''::text
		 AND s.application_id = aa.id
		 AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
	     UNION
		select count (distinct(aa.id)) counter,
		 get_translation(''Applications completed::::Pratiche completate'', NULL::character varying) descr,
		 3 as order,
		    get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from application.application aa, application.service s where s.request_type_code::text = ''systematicRegn''::text
		 AND s.status_code=''completed''
		 AND s.application_id = aa.id
		 AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
             UNION
		select count(aa.id) counter,
		get_translation(''Applications approved::::Pratiche approvate'', NULL::character varying) descr,
		4 as order,
		 get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from application.application  aa, application.service s where s.request_type_code::text = ''systematicRegn''::text
		 AND aa.status_code=''approved'' 
		 AND s.application_id = aa.id
		 AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
	     UNION
		select count(aa.id) counter,
		 get_translation(''Application archived::::Pratiche archiviate'', NULL::character varying) descr,
		 5 as order,
		    get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from application.application  aa, application.service s where s.request_type_code::text = ''systematicRegn''::text
		 AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
		 AND aa.status_code=''archived'' 
		 AND s.application_id = aa.id 

          UNION
		select count(distinct(ss.id)) counter,
		get_translation(''Objections received::::Obiezioni ricevute'', NULL::character varying) descr,
	        6 as order,
		get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                from   source.source ss,
                        application.application_uses_source aus,
                        application.application  aa, application.service s 
                 where s.request_type_code::text = ''systematicRegn''::text
			AND s.application_id = aa.id
			AND   ss.recordation  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
			AND   aus.source_id=ss.id
			AND   aus.application_id=aa.id
			AND   ss.type_code=''objection''
	  UNION
		select count(distinct(ss.id)) counter,
		get_translation(''Objections solved::::Obiezioni risolte'', NULL::character varying) descr,
	        7 as order,
	        get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                from   source.source ss,
                        application.application_uses_source aus,
                        application.application  aa, application.service s 
                 where s.request_type_code::text = ''systematicRegn''::text
			AND s.application_id = aa.id
			AND   ss.recordation  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
			AND   aus.source_id=ss.id
			AND   aus.application_id=aa.id
			AND   ss.type_code=''objectionSolved''	     
			 
                UNION
		 select count(co.id) counter,
		 get_translation(''Parcels in public notification::::Particelle in pubblica notifica'', NULL::character varying) descr,
		 8 as order,
		 get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from cadastre.cadastre_object co, application.service s where s.request_type_code::text = ''systematicRegn''::text
                 AND co.name_lastpart in (select ss.reference_nr 
                                                        from   source.source ss 
                                                        where  ss.recordation  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
                                                        AND ss.expiration_date > now())
                                                          
               UNION
		select count(co.id) counter,
		get_translation(''Parcels with public notification completed::::Particelle con pubblica notifica completata'', NULL::character varying) descr,
		9 as order,
		 get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from cadastre.cadastre_object co, application.service s, application.application aa where s.request_type_code::text = ''systematicRegn''::text
					      AND s.application_id = aa.id
					      AND  co.name_lastpart in (select ss.reference_nr 
									from   source.source ss 
									where  ss.recordation  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
                                                                        AND ss.expiration_date <= now())
                                                  

	     UNION								
               select count(distinct(co.id)) counter,
               get_translation(''Parcels in approved applications::::Particelle in pratiche approvate'', NULL::character varying) descr,
	       10 as order,
		get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap, application.service s 
              where s.request_type_code::text = ''systematicRegn''::text
                                   AND s.application_id = aa.id
		 AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
		 AND ap.ba_unit_id::text = su.ba_unit_id::text 
				     AND   aa.id::text = ap.application_id::text
                             AND   co.id = su.spatial_unit_id
                             AND   aa.status_code::text = ''approved'' 
                                 

              UNION
		select coalesce(sum(sa.size), 0) counter,
		get_translation(''Area size of parcels in approved applications (m2)::::Area totale delle particelle in pratiche approvate (m2)'', NULL::character varying) descr,
	        11 as order,
	        get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap,
                                   cadastre.spatial_value_area sa, application.service s 
                where s.request_type_code::text = ''systematicRegn''::text
		 AND s.application_id = aa.id
		 AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
		 AND  ap.ba_unit_id::text = su.ba_unit_id::text 
                 AND   aa.id::text = ap.application_id::text
                 AND   co.id = su.spatial_unit_id
                 AND   sa.spatial_unit_id = su.spatial_unit_id
                 AND   aa.status_code::text = ''approved'' 
                     

         UNION        
                select count(distinct(co.id)) counter,
                get_translation(''Residential parcels in approved applications::::Particelle residenziali in pratiche approvate'', NULL::character varying) descr,
	        12 as order,
		get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap, application.service s 
               where s.request_type_code::text = ''systematicRegn''::text
               AND s.application_id = aa.id
               AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
	       AND  ap.ba_unit_id::text = su.ba_unit_id::text 
               AND   aa.id::text = ap.application_id::text
               AND   co.id = su.spatial_unit_id
               AND   aa.status_code::text = ''approved''
               AND   co.land_use_code=''residential'' 
                   
          UNION
              select coalesce(sum(sa.size), 0) counter,
              get_translation(''Area size of Residential parcels in approved applications (m2)::::Area totale delle particelle residenziali in pratiche approvate (m2)'', NULL::character varying) descr,
	      13 as order,
		get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap,
                                   cadastre.spatial_value_area sa, application.service s 
              where s.request_type_code::text = ''systematicRegn''::text
		 AND s.application_id = aa.id
		 AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
			AND  ap.ba_unit_id::text = su.ba_unit_id::text 
                 AND   aa.id::text = ap.application_id::text
                 AND   co.id = su.spatial_unit_id
                 AND   sa.spatial_unit_id = su.spatial_unit_id
                 AND   aa.status_code::text = ''approved''
                 AND   co.land_use_code=''residential'' 
                     
           UNION      
             select count(distinct(co.id)) counter,
             get_translation(''Commercial parcels in approved applications::::Particelle commerciali in pratiche approvate'', NULL::character varying) descr,
	     14 as order,
		get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap, application.service s 
             where s.request_type_code::text = ''systematicRegn''::text
		 AND s.application_id = aa.id 
		 AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
	         AND  ap.ba_unit_id::text = su.ba_unit_id::text 
                 AND   aa.id::text = ap.application_id::text
                 AND   co.id = su.spatial_unit_id
                 AND   aa.status_code::text = ''approved''
                 AND   co.land_use_code=''commercial''
                     
           UNION
             select coalesce(sum(sa.size), 0) counter,
             get_translation(''Area size of Commercial parcels in approved applications (m2)::::Area totale delle particelle commerciali in pratiche approvate (m2)'', NULL::character varying) descr,
	     15 as order,
		get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap,
                                   cadastre.spatial_value_area sa, application.service s 
             where s.request_type_code::text = ''systematicRegn''::text
		     AND s.application_id = aa.id
		     AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
		     AND  ap.ba_unit_id::text = su.ba_unit_id::text 
		     AND   aa.id::text = ap.application_id::text
		     AND   co.id = su.spatial_unit_id
		     AND   sa.spatial_unit_id = su.spatial_unit_id
		     AND   aa.status_code::text = ''approved''
                     AND   co.land_use_code=''commercial''
                       
             UNION       
		select count(distinct(co.id)) counter,
                get_translation(''Industrial parcels in approved applications::::Particelle industriali in pratiche approvate'', NULL::character varying) descr,
	        16 as order,
		get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap, application.service s 
                where s.request_type_code::text = ''systematicRegn''::text
			AND s.application_id = aa.id
			AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
			AND   ap.ba_unit_id::text = su.ba_unit_id::text 
                        AND   aa.id::text = ap.application_id::text
                        AND   co.id = su.spatial_unit_id
                        AND   aa.status_code::text = ''approved''
                        AND   co.land_use_code=''industrial''
                          

              UNION
		select coalesce(sum(sa.size), 0) counter,
                get_translation(''Area size of Industrial parcels in approved applications (m2)::::Area totale delle particelle industriali in pratiche approvate (m2)'', NULL::character varying) descr,
	        17 as order,
		get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap,
                                   cadastre.spatial_value_area sa, application.service s 
                where s.request_type_code::text = ''systematicRegn''::text
			AND s.application_id = aa.id
			AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
			AND   ap.ba_unit_id::text = su.ba_unit_id::text 
                        AND   aa.id::text = ap.application_id::text
                        AND   co.id = su.spatial_unit_id
                        AND   sa.spatial_unit_id = su.spatial_unit_id
                        AND   aa.status_code::text = ''approved''
                        AND   co.land_use_code=''industrial'' 
                            
         UNION
		select count(distinct(co.id)) counter,
                get_translation(''Agricultural parcels in approved applications::::Particelle agricole in pratiche approvate'', NULL::character varying) descr,
	        18 as order,
		get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap, application.service s 
                where s.request_type_code::text = ''systematicRegn''::text
			AND s.application_id = aa.id
			AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
			AND   ap.ba_unit_id::text = su.ba_unit_id::text 
                        AND   aa.id::text = ap.application_id::text
                        AND   co.id = su.spatial_unit_id
                        AND   aa.status_code::text = ''approved''
                        AND   co.land_use_code=''agricultural''
                            
          UNION
		select coalesce(sum(sa.size), 0) counter,
                get_translation(''Area size of Agricultural parcels in approved applications (m2)::::Area totale delle particelle agricole in pratiche approvate (m2)'', NULL::character varying) descr,
	        19 as order,
		get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap,
                                   cadastre.spatial_value_area sa, application.service s 
                where s.request_type_code::text = ''systematicRegn''::text
			AND   s.application_id = aa.id
			AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
			AND   ap.ba_unit_id::text = su.ba_unit_id::text 
                        AND   aa.id::text = ap.application_id::text
                        AND   co.id = su.spatial_unit_id
                        AND   sa.spatial_unit_id = su.spatial_unit_id
                        AND   aa.status_code::text = ''approved''
                        AND   co.land_use_code=''agricultural''
                            
          UNION
                SELECT     count(distinct(pp.id))  AS counter,
		   get_translation(gt.display_value, NULL::character varying)|| '' owners''  descr,
		   20 as order,
		   get_translation(''A. Totals on all systematic registrations::::A. Totali su tutte le registrazioni sistematiche   '', NULL::character varying) area
                    FROM party.gender_type gt, 
		   cadastre.cadastre_object co,
		   cadastre.spatial_value_area sa, 
		   administrative.ba_unit_contains_spatial_unit su, 
		   application.application_property ap, application.application aa, application.service s, party.party pp, administrative.party_for_rrr pr, 
		   administrative.rrr rrr
		  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = ''officialArea''::text 
		  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
                  AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
		  AND ap.ba_unit_id::text = su.ba_unit_id::text AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text 
		  AND s.request_type_code::text = ''systematicRegn''::text 
		  AND pp.id::text = pr.party_id::text 
		  AND pr.rrr_id::text = rrr.id::text AND rrr.ba_unit_id::text = su.ba_unit_id::text 
		  AND (rrr.type_code::text = ''ownership''::text OR rrr.type_code::text = ''apartment''::text OR rrr.type_code::text = ''commonOwnership''::text)
		  AND COALESCE(pp.gender_code, ''na''::character varying)::text = gt.code::text
		      
		  group by descr 
	
            UNION
		 select count(distinct(co.id)) counter,
		 get_translation(''Parcels in public notification::::Particelle in pubblica notifica'', NULL::character varying) descr,
		 21 as order,
		 co.name_lastpart  area
		 from cadastre.cadastre_object co, application.service s where s.request_type_code::text = ''systematicRegn''::text
                 AND co.name_lastpart in (select ss.reference_nr 
                                                        from   source.source ss 
                                                        where  ss.recordation  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
                                                        AND ss.expiration_date > now())
                 group by co.name_lastpart 
            UNION
		select count(distinct(co.id)) counter,
		get_translation(''Parcels with public notification completed::::Particelle con pubblica notifica completata'', NULL::character varying) descr,
		22 as order,
		 co.name_lastpart  area
		 from cadastre.cadastre_object co, application.service s, application.application aa where s.request_type_code::text = ''systematicRegn''::text
					      AND s.application_id = aa.id
					      AND  co.name_lastpart in (select ss.reference_nr 
									from   source.source ss 
									where  ss.recordation  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
                                                                        AND ss.expiration_date <= now())
                 group by co.name_lastpart                           

	     UNION								
               select count(distinct(co.id)) counter,
               get_translation(''Parcels in approved applications::::Particelle in pratiche approvate'', NULL::character varying) descr,
	       23 as order,
	       co.name_lastpart  area
		from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap, application.service s 
              where s.request_type_code::text = ''systematicRegn''::text
                                   AND s.application_id = aa.id
		 AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
		 AND ap.ba_unit_id::text = su.ba_unit_id::text 
				     AND   aa.id::text = ap.application_id::text
                             AND   co.id = su.spatial_unit_id
                             AND   aa.status_code::text = ''approved'' 
              group by co.name_lastpart

              UNION
		select coalesce(sum(sa.size), 0) counter,
		get_translation(''Area size of parcels in approved applications (m2)::::Area totale delle particelle in pratiche approvate (m2)'', NULL::character varying) descr,
	        24 as order,
		 co.name_lastpart  area
		from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap,
                                   cadastre.spatial_value_area sa, application.service s 
                where s.request_type_code::text = ''systematicRegn''::text
		 AND s.application_id = aa.id
		 AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
		 AND  ap.ba_unit_id::text = su.ba_unit_id::text 
                 AND   aa.id::text = ap.application_id::text
                 AND   co.id = su.spatial_unit_id
                 AND   sa.spatial_unit_id = su.spatial_unit_id
                 AND   aa.status_code::text = ''approved'' 
                group by co.name_lastpart 

         UNION        
                select count(distinct(co.id)) counter,
                get_translation(''Residential parcels in approved applications::::Particelle residenziali in pratiche approvate'', NULL::character varying) descr,
	        25 as order,
		 co.name_lastpart  area
		from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap, application.service s 
               where s.request_type_code::text = ''systematicRegn''::text
               AND s.application_id = aa.id
               AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
	       AND  ap.ba_unit_id::text = su.ba_unit_id::text 
               AND   aa.id::text = ap.application_id::text
               AND   co.id = su.spatial_unit_id
               AND   aa.status_code::text = ''approved''
               AND   co.land_use_code=''residential'' 
               group by co.name_lastpart
          UNION
              select coalesce(sum(sa.size), 0) counter,
              get_translation(''Area size of Residential parcels in approved applications (m2)::::Area totale delle particelle residenziali in pratiche approvate (m2)'', NULL::character varying) descr,
	      26 as order,
		 co.name_lastpart  area
		from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap,
                                   cadastre.spatial_value_area sa, application.service s 
              where s.request_type_code::text = ''systematicRegn''::text
		 AND s.application_id = aa.id
		 AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
			AND  ap.ba_unit_id::text = su.ba_unit_id::text 
                 AND   aa.id::text = ap.application_id::text
                 AND   co.id = su.spatial_unit_id
                 AND   sa.spatial_unit_id = su.spatial_unit_id
                 AND   aa.status_code::text = ''approved''
                 AND   co.land_use_code=''residential'' 
                 group by co.name_lastpart
           UNION      
             select count(distinct(co.id)) counter,
             get_translation(''Commercial parcels in approved applications::::Particelle commerciali in pratiche approvate'', NULL::character varying) descr,
	     27 as order,
		 co.name_lastpart  area
		from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap, application.service s 
             where s.request_type_code::text = ''systematicRegn''::text
		 AND s.application_id = aa.id 
		 AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
	         AND  ap.ba_unit_id::text = su.ba_unit_id::text 
                 AND   aa.id::text = ap.application_id::text
                 AND   co.id = su.spatial_unit_id
                 AND   aa.status_code::text = ''approved''
                 AND   co.land_use_code=''commercial''
             group by co.name_lastpart    
           UNION
             select coalesce(sum(sa.size), 0) counter,
             get_translation(''Area size of Commercial parcels in approved applications (m2)::::Area totale delle particelle commerciali in pratiche approvate (m2)'', NULL::character varying) descr,
	     28 as order,
             co.name_lastpart  area
		from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap,
                                   cadastre.spatial_value_area sa, application.service s 
             where s.request_type_code::text = ''systematicRegn''::text
		     AND s.application_id = aa.id
		     AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
		     AND  ap.ba_unit_id::text = su.ba_unit_id::text 
		     AND   aa.id::text = ap.application_id::text
		     AND   co.id = su.spatial_unit_id
		     AND   sa.spatial_unit_id = su.spatial_unit_id
		     AND   aa.status_code::text = ''approved''
                     AND   co.land_use_code=''commercial''
                  group by co.name_lastpart
             UNION       
		select count(distinct(co.id)) counter,
                get_translation(''Industrial parcels in approved applications::::Particelle industriali in pratiche approvate'', NULL::character varying) descr,
	        29 as order,
		 co.name_lastpart  area
		from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap, application.service s 
                where s.request_type_code::text = ''systematicRegn''::text
			AND s.application_id = aa.id
			AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
			AND   ap.ba_unit_id::text = su.ba_unit_id::text 
                        AND   aa.id::text = ap.application_id::text
                        AND   co.id = su.spatial_unit_id
                        AND   aa.status_code::text = ''approved''
                        AND   co.land_use_code=''industrial''
                        group by co.name_lastpart

              UNION
		select coalesce(sum(sa.size), 0) counter,
                get_translation(''Area size of Industrial parcels in approved applications (m2)::::Area totale delle particelle industriali in pratiche approvate (m2)'', NULL::character varying) descr,
	        30 as order,
		 co.name_lastpart  area
		from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap,
                                   cadastre.spatial_value_area sa, application.service s 
                where s.request_type_code::text = ''systematicRegn''::text
			AND s.application_id = aa.id
			AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
			AND   ap.ba_unit_id::text = su.ba_unit_id::text 
                        AND   aa.id::text = ap.application_id::text
                        AND   co.id = su.spatial_unit_id
                        AND   sa.spatial_unit_id = su.spatial_unit_id
                        AND   aa.status_code::text = ''approved''
                        AND   co.land_use_code=''industrial'' 
                        group by co.name_lastpart
         UNION
		select count(distinct(co.id)) counter,
                get_translation(''Agricultural parcels in approved applications::::Particelle agricole in pratiche approvate'', NULL::character varying) descr,
	        31 as order,
		 co.name_lastpart  area
		from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap, application.service s 
                where s.request_type_code::text = ''systematicRegn''::text
			AND s.application_id = aa.id
			AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
			AND   ap.ba_unit_id::text = su.ba_unit_id::text 
                        AND   aa.id::text = ap.application_id::text
                        AND   co.id = su.spatial_unit_id
                        AND   aa.status_code::text = ''approved''
                        AND   co.land_use_code=''agricultural''
                        group by co.name_lastpart
          UNION
		select coalesce(sum(sa.size), 0) counter,
                get_translation(''Area size of Agricultural parcels in approved applications (m2)::::Area totale delle particelle agricole in pratiche approvate (m2)'', NULL::character varying) descr,
	        32 as order,
		 co.name_lastpart  area
		from  cadastre.cadastre_object co,
                                   application.application  aa, 
                                   administrative.ba_unit_contains_spatial_unit su, 
                                   application.application_property ap,
                                   cadastre.spatial_value_area sa, application.service s 
                where s.request_type_code::text = ''systematicRegn''::text
			AND   s.application_id = aa.id
			AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
			AND   ap.ba_unit_id::text = su.ba_unit_id::text 
                        AND   aa.id::text = ap.application_id::text
                        AND   co.id = su.spatial_unit_id
                        AND   sa.spatial_unit_id = su.spatial_unit_id
                        AND   aa.status_code::text = ''approved''
                        AND   co.land_use_code=''agricultural''
                        group by co.name_lastpart
         
        UNION
                SELECT     count(distinct(pp.id))  AS counter,
		   get_translation(gt.display_value, NULL::character varying)|| '' owners''  descr,
		   33 as order,
		   co.name_lastpart  area
		   FROM party.gender_type gt, 
		   cadastre.cadastre_object co,
		   cadastre.spatial_value_area sa, 
		   administrative.ba_unit_contains_spatial_unit su, 
		   application.application_property ap, application.application aa, application.service s, party.party pp, administrative.party_for_rrr pr, 
		   administrative.rrr rrr
		  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = ''officialArea''::text 
		  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
                  AND   aa.change_time  between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
		  AND ap.ba_unit_id::text = su.ba_unit_id::text AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text 
		  AND s.request_type_code::text = ''systematicRegn''::text 
		  AND pp.id::text = pr.party_id::text 
		  AND pr.rrr_id::text = rrr.id::text AND rrr.ba_unit_id::text = su.ba_unit_id::text 
		  AND (rrr.type_code::text = ''ownership''::text OR rrr.type_code::text = ''apartment''::text OR rrr.type_code::text = ''commonOwnership''::text)
		  AND COALESCE(pp.gender_code, ''na''::character varying)::text = gt.code::text
		  group by co.name_lastpart, descr 
		 
                
   order by 4 asc, 3
';




    --raise exception '%',sqlSt;
    managementFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop

      counter:= rec.counter;
      descr:=   rec.descr;
      area:=  rec.area;

	  
	  select into recToReturn
	     counter::  decimal,
	     descr::varchar,
	     area::varchar;
	     
          return next recToReturn;
          managementFound = true;
    end loop;
   
    if (not managementFound) then
        RAISE EXCEPTION 'no_management_found';
    end if;
    return;
END;
$$;


ALTER FUNCTION administrative.getsysregmanagement(fromdate character varying, todate character varying, namelastpart character varying) OWNER TO postgres;

--
-- Name: FUNCTION getsysregmanagement(fromdate character varying, todate character varying, namelastpart character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION getsysregmanagement(fromdate character varying, todate character varying, namelastpart character varying) IS 'Used for systematic registration';


--
-- Name: getsysregprogress(character varying, character varying, character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION getsysregprogress(fromdate character varying, todate character varying, namelastpart character varying) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE 

       	block  			varchar;	
       	TotAppLod		decimal:=0 ;	
        TotParcLoaded		varchar:='none' ;	
        TotRecObj		decimal:=0 ;	
        TotSolvedObj		decimal:=0 ;	
        TotAppPDisp		decimal:=0 ;	
        TotPrepCertificate      decimal:=0 ;	
        TotIssuedCertificate	decimal:=0 ;	


        Total  			varchar;	
       	TotalAppLod		decimal:=0 ;	
        TotalParcLoaded		varchar:='none' ;	
        TotalRecObj		decimal:=0 ;	
        TotalSolvedObj		decimal:=0 ;	
        TotalAppPDisp		decimal:=0 ;	
        TotalPrepCertificate      decimal:=0 ;	
        TotalIssuedCertificate	decimal:=0 ;	


  
      
       rec     record;
       sqlSt varchar;
       workFound boolean;
       recToReturn record;

       recTotalToReturn record;

        -- From Neil's email 9 march 2013
	    -- PROGRESS REPORT
		--0. Block	
		--1. Total Number of Applications Lodged	
		--2. No of Parcel loaded	
		--3. No of Objections received
		--4. No of Objections resolved
		--5. No of Applications in Public Display	               
		--6. No of Applications with Prepared Certificate	
		--7. No of Applications with Issued Certificate	
		
    
BEGIN  


   sqlSt:= '';
    
  
 sqlSt:= 'select  distinct (co.name_lastpart)   as area
                   FROM   application.application aa,     
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = ''systematicRegn''::text
			    
    ';
    
    if namelastpart != '' then
         -- sqlSt:= sqlSt|| ' AND compare_strings('''||namelastpart||''', co.name_lastpart) ';
          sqlSt:= sqlSt|| ' AND  co.name_lastpart =  '''||namelastpart||'''';  --1. block
   
    end if;
    --raise exception '%',sqlSt;
       workFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop

    
    select  (      
                  ( SELECT  
		    count (distinct(aa.id)) 
		    FROM   application.application aa,     
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code='lodge'
		            --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
		            AND  co.name_lastpart = ''|| rec.area ||''
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    ) + 
	           ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application_historic aa,     
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   aa.action_code='lodge'
			    AND   s.request_type_code::text = 'systematicRegn'::text
		            --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
		            AND  co.name_lastpart = ''|| rec.area ||''
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    )
		    

	      ),  --- TotApp
          (           
	   
	   (
	    SELECT count (DISTINCT co.id)
	    FROM cadastre.cadastre_object co, 
		 cadastre.spatial_value_area sa, 
		 administrative.ba_unit_contains_spatial_unit su,
		 application.application aa, 
		 application.service s, 
		 administrative.ba_unit bu, 
		 transaction.transaction t 
		    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
		            --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
		            AND  co.name_lastpart = ''|| rec.area ||''
            AND sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text 
	    AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
	    AND s.status_code::text = 'completed'::text 
	    AND bu.id::text = su.ba_unit_id::text
	    )
            ||'/'||
	    (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
			    AND  co.name_lastpart = ''|| rec.area ||''
                            --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
                    	    
	     )

	   )
                 ,  ---TotParcelLoaded
                  
               (
                  SELECT 
                  (
	            (SELECT (COUNT(*)) 
			FROM  application.application aa, 
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			  -- AND compare_strings(''|| rec.area ||'', co.name_lastpart) 
                          AND  co.name_lastpart = ''|| rec.area ||'' 
			   AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
			  AND s.request_type_code::text = 'lodgeObjection'::text
			  AND s.status_code::text = 'lodged'::text
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		        ) +
		        (SELECT (COUNT(*)) 
			FROM  application.application aa, 
			   application.service_historic s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			   --AND compare_strings(''|| rec.area ||'', co.name_lastpart) 
                           AND  co.name_lastpart = ''|| rec.area ||'' 
			   AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
			  AND s.request_type_code::text = 'lodgeObjection'::text
			  AND s.status_code::text = 'lodged'::text
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		        )  
		   )  
		),  --TotLodgedObj

                (
	          SELECT (COUNT(*)) 
		   FROM  application.application aa, 
		   application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart) 
			    AND  co.name_lastpart = ''|| rec.area ||''
		            AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
		  AND s.request_type_code::text = 'lodgeObjection'::text
		  AND s.status_code::text = 'cancelled'::text
		  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		), --TotSolvedObj
			
		(
		SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart) 
			    AND  co.name_lastpart = ''|| rec.area ||''
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND co.name_lastpart in (
						      select ss.reference_nr 
						      from   source.source ss 
						      where ss.type_code='publicNotification'
						      AND ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                                     )
                 ),  ---TotAppPubDispl


                 (
                  select count(distinct (aa.id))
                   from application.service s, 
                   application.application aa, 
                   cadastre.cadastre_object co,
		   administrative.ba_unit_contains_spatial_unit su,
		   administrative.ba_unit bu,
                   transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart = ''|| rec.area ||'' 
			    AND s.request_type_code::text = 'systematicRegn'::text
		            AND co.name_lastpart in (
						      select ss.reference_nr 
						      from   source.source ss 
						      where ss.type_code='publicNotification'
						      and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                                      and   ss.reference_nr in ( select ss.reference_nr from   source.source ss 
										  where ss.type_code='title'
										  and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
										  and ss.reference_nr = ''|| rec.area ||''
                                                                                )   
					           )
	
                 ),  ---TotCertificatesPrepared
                 (select count (distinct(s.id))
                   FROM 
                   application.service s   --,
		   WHERE s.request_type_code::text = 'documentCopy'::text
		   AND s.lodging_datetime between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                   AND s.action_notes = ''|| rec.area ||'')  --TotCertificatesIssued

                    
              INTO       TotAppLod,
                         TotParcLoaded,
                         TotRecObj,
                         TotSolvedObj,
                         TotAppPDisp,
                         TotPrepCertificate,
                         TotIssuedCertificate
          ;        

                block = rec.area;
                TotAppLod = TotAppLod;
                TotParcLoaded = TotParcLoaded;
                TotRecObj = TotRecObj;
                TotSolvedObj = TotSolvedObj;
                TotAppPDisp = TotAppPDisp;
                TotPrepCertificate = TotPrepCertificate;
                TotIssuedCertificate = TotIssuedCertificate;
	  
	  select into recToReturn
	       	block::			varchar,
		TotAppLod::  		decimal,	
		TotParcLoaded::  	varchar,	
		TotRecObj::  		decimal,	
		TotSolvedObj::  	decimal,	
		TotAppPDisp::  		decimal,	
		TotPrepCertificate::  	decimal,	
		TotIssuedCertificate::  decimal;	
		                         
		return next recToReturn;
		workFound = true;
          
    end loop;
   
    if (not workFound) then
         block = 'none';
                
        select into recToReturn
	       	block::			varchar,
		TotAppLod::  		decimal,	
		TotParcLoaded::  	varchar,	
		TotRecObj::  		decimal,	
		TotSolvedObj::  	decimal,	
		TotAppPDisp::  		decimal,	
		TotPrepCertificate::  	decimal,	
		TotIssuedCertificate::  decimal;		
		                         
		return next recToReturn;

    end if;

------ TOTALS ------------------
                
              select  (      
                  ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code='lodge'
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    ) +
	           ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application_historic aa,
			  application.service s
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code='lodge'
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    )
		    

	      ),  --- TotApp

		   
	          (           
	   
	   (
	    SELECT count (DISTINCT co.id)
	    FROM cadastre.land_use_type lu, 
	    cadastre.spatial_value_area sa, 
	    application.application aa, 
	    application.service s, 
            cadastre.cadastre_object co,
	    administrative.ba_unit_contains_spatial_unit su,
	    administrative.ba_unit bu,
            transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND sa.type_code::text = 'officialArea'::text 
			    AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
	                    AND s.request_type_code::text = 'systematicRegn'::text 
	                    AND s.status_code::text = 'completed'::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text AND bu.id::text = su.ba_unit_id::text
	    )
            ||'/'||
	    (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
	    )

	   ),  ---TotParcelLoaded
                  
                    (
                  SELECT 
                  (
	            (SELECT (COUNT(*)) 
			FROM  application.application aa, 
			   application.service s
			  WHERE  s.application_id::text = aa.id::text 
			  AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
			  AND s.request_type_code::text = 'lodgeObjection'::text
			  AND s.status_code::text = 'lodged'::text
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		        ) +
		        (SELECT (COUNT(*)) 
			FROM  application.application aa, 
			   application.service_historic s
			  WHERE  s.application_id::text = aa.id::text 
			  AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
			  AND s.request_type_code::text = 'lodgeObjection'::text
			  AND s.status_code::text = 'lodged'::text
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		        )  
		   )  
		),  --TotLodgedObj

                (
	          SELECT (COUNT(*)) 
		   FROM  application.application aa, 
		   application.service s
		  WHERE  s.application_id::text = aa.id::text 
		  AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
		  AND s.request_type_code::text = 'lodgeObjection'::text
		  AND s.status_code::text = 'cancelled'::text
		  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		), --TotSolvedObj
		
		
		(
		SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s, 
			    cadastre.cadastre_object co,
			    administrative.ba_unit_contains_spatial_unit su,
			    administrative.ba_unit bu,
			    transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND co.name_lastpart in ( select ss.reference_nr 
		 				      from   source.source ss 
							where ss.type_code='publicNotification'
							AND ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                                     )
                 ),  ---TotAppPubDispl


                 (
                  select count(distinct (aa.id))
                   from application.service s, 
                   application.application aa, 
			    cadastre.cadastre_object co,
			    administrative.ba_unit_contains_spatial_unit su,
			    administrative.ba_unit bu,
			    transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND co.name_lastpart in ( select ss.reference_nr 
					              from   source.source ss 
					              where ss.type_code='publicNotification'
					              and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                                      and   ss.reference_nr in ( select ss.reference_nr from   source.source ss 
										 where ss.type_code='title'
										 and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
										)   
					            ) 
	         ),  ---TotCertificatesPrepared
                 (select count (distinct(s.id))
                   FROM 
                       application.service s   --,
		   WHERE s.request_type_code::text = 'documentCopy'::text
		   AND s.lodging_datetime between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                   AND s.action_notes is not null )  --TotCertificatesIssued

      

                     
              INTO       TotalAppLod,
                         TotalParcLoaded,
                         TotalRecObj,
                         TotalSolvedObj,
                         TotalAppPDisp,
                         TotalPrepCertificate,
                         TotalIssuedCertificate
               ;        
                Total = 'Total';
                TotalAppLod = TotalAppLod;
                TotalParcLoaded = TotalParcLoaded;
                TotalRecObj = TotalRecObj;
                TotalSolvedObj = TotalSolvedObj;
                TotalAppPDisp = TotalAppPDisp;
                TotalPrepCertificate = TotalPrepCertificate;
                TotalIssuedCertificate = TotalIssuedCertificate;
	  
	  select into recTotalToReturn
                Total::                 varchar, 
                TotalAppLod::  		decimal,	
		TotalParcLoaded::  	varchar,	
		TotalRecObj::  		decimal,	
		TotalSolvedObj::  	decimal,	
		TotalAppPDisp::  	decimal,	
		TotalPrepCertificate:: 	decimal,	
		TotalIssuedCertificate::  decimal;	

	                         
		return next recTotalToReturn;

                
    return;

END;
$$;


ALTER FUNCTION administrative.getsysregprogress(fromdate character varying, todate character varying, namelastpart character varying) OWNER TO postgres;

--
-- Name: FUNCTION getsysregprogress(fromdate character varying, todate character varying, namelastpart character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION getsysregprogress(fromdate character varying, todate character varying, namelastpart character varying) IS 'Indicates the number of applications at various stages of the systematic registration process.';


--
-- Name: getsysregstatus(character varying, character varying, character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION getsysregstatus(fromdate character varying, todate character varying, namelastpart character varying) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE 

       	block  			varchar;	
       	appLodgedNoSP 		decimal:=0 ;	
       	appLodgedSP   		decimal:=0 ;	
       	SPnoApp 		decimal:=0 ;	
       	appPendObj		decimal:=0 ;	
       	appIncDoc		decimal:=0 ;	
       	appPDisp		decimal:=0 ;	
       	appCompPDispNoCert	decimal:=0 ;	
       	appCertificate		decimal:=0 ;
       	appPrLand		decimal:=0 ;	
       	appPubLand		decimal:=0 ;	
       	TotApp			decimal:=0 ;	
       	TotSurvPar		decimal:=0 ;	



      
       rec     record;
       sqlSt varchar;
       statusFound boolean;
       recToReturn record;

        -- From Neil's email 9 march 2013
	    -- STATUS REPORT
		--Block	
		--1. Total Number of Applications	
		--2. No of Applications Lodged with Surveyed Parcel	
		--3. No of Applications Lodged no Surveyed Parcel	     
		--4. No of Surveyed Parcels with no application	
		--5. No of Applications with pending Objection	        
		--6. No of Applications with incomplete Documentation	
		--7. No of Applications in Public Display	               
		--8. No of Applications with Completed Public Display but Certificates not Issued	 
		--9. No of Applications with Issued Certificate	
		--10. No of Applications for Private Land	
		--11. No of Applications for Public Land 	
		--12. Total Number of Surveyed Parcels	

    
BEGIN  


    sqlSt:= '';
    
  
 sqlSt:= 'select   distinct (co.name_lastpart)   as area
                   FROM   application.application aa,     
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = ''systematicRegn''::text
			    
    ';
    
    if namelastpart != '' then
          --sqlSt:= sqlSt|| ' AND compare_strings('''||namelastpart||''', co.name_lastpart) ';
          sqlSt:= sqlSt|| ' AND  co.name_lastpart =  '''||namelastpart||'''';  --1. block
    
    end if;

    --raise exception '%',sqlSt;
       statusFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop

    
    select        ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    ),

		    (SELECT count (distinct(aa.id))
		     FROM application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			 AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )),

	          (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
			    AND   co.id not in (SELECT su.spatial_unit_id FROM administrative.ba_unit_contains_spatial_unit su)
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
	          ),

                 (
	          SELECT (COUNT(*)) 
		   FROM  application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
		  AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
		  AND s.request_type_code::text = 'lodgeObjection'::text
		  AND s.status_code::text != 'cancelled'::text
		  --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
		  AND  co.name_lastpart =  ''|| rec.area ||''
		  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		),


		  ( WITH appSys AS 	(SELECT  
		    distinct on (aa.id) aa.id as id
		    FROM  application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )),
		     sourceSys AS	
		     (
		     SELECT  DISTINCT (sc.id) FROM  application.application_uses_source a_s,
							   source.source sc,
							   appSys app
						where sc.type_code='systematicRegn'
						 and  sc.id = a_s.source_id
						 and a_s.application_id=app.id
						 AND  (
						  (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
						   or
						  (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
						  )
						
				)
		      SELECT 	CASE 	WHEN (SELECT (SUM(1) IS NULL) FROM appSys) THEN 0
				WHEN ((SELECT COUNT(*) FROM appSys) - (SELECT COUNT(*) FROM sourceSys) >= 0) THEN (SELECT COUNT(*) FROM appSys) - (SELECT COUNT(*) FROM sourceSys)
				ELSE 0
			END 
				  ),
     
                 (select count(distinct (aa.id))
                   from application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND co.name_lastpart in ( 
		                             select ss.reference_nr from   source.source ss 
					     where ss.type_code='publicNotification'
					     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.reference_nr = ''|| rec.area ||''   
					   )
		 ),

                 ( 
                   select count(distinct (aa.id))
                   from application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND co.name_lastpart in ( 
						      select ss.reference_nr 
						       from   source.source ss 
						       where ss.type_code='publicNotification'
						       and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
						       and   ss.reference_nr not in ( select ss.reference_nr from   source.source ss 
										     where ss.type_code='title'
										     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
										     and ss.reference_nr = ''|| rec.area ||''
	 								           )   
		                                     )
                 ),

                 (
                   select count(distinct (aa.id))
                   from application.application aa,
		          application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND co.name_lastpart in ( 
						      select ss.reference_nr 
						      from   source.source ss 
						      where ss.type_code='publicNotification'
						      and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
						      and   ss.reference_nr in ( select ss.reference_nr from   source.source ss 
										   where ss.type_code='title'
										   and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
										   and ss.reference_nr = ''|| rec.area ||''
									        )   
					            )  
                ),
		 (SELECT count (distinct (aa.id) )
			FROM cadastre.land_use_type lu, 
			cadastre.spatial_value_area sa, 
			party.party pp, administrative.party_for_rrr pr, 
			administrative.rrr rrr, 
			application.application aa,
		          application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND sa.spatial_unit_id::text = co.id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text 
			    AND sa.type_code::text = 'officialArea'::text 
			    AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
			    AND s.status_code::text = 'completed'::text 
			    AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text 
			    AND rrr.ba_unit_id::text = su.ba_unit_id::text
			    AND  (
		            (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		              or
		             (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		            )
			    AND 
			    (rrr.type_code::text = 'ownership'::text 
			     OR rrr.type_code::text = 'apartment'::text 
			     OR rrr.type_code::text = 'commonOwnership'::text 
			     ) 
		 ),		
		 ( SELECT count (distinct (aa.id) )
			FROM cadastre.land_use_type lu, 
			cadastre.spatial_value_area sa, 
			party.party pp, administrative.party_for_rrr pr, 
			administrative.rrr rrr,
			application.application aa,
		          application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND   sa.spatial_unit_id::text = co.id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text 
			    AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
			    AND s.status_code::text = 'completed'::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text 
			    AND rrr.ba_unit_id::text = su.ba_unit_id::text AND rrr.type_code::text = 'stateOwnership'::text AND bu.id::text = su.ba_unit_id::text
			    AND  (
		            (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		             or
		            (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		            ) 
	  	 ), 	
                 (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
		    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
	         )    
              INTO       TotApp,
                         appLodgedSP,
                         SPnoApp,
                         appPendObj,
                         appIncDoc,
                         appPDisp,
                         appCompPDispNoCert,
                         appCertificate,
                         appPrLand,
                         appPubLand,
                         TotSurvPar
                
              FROM        application.application aa,
		          application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			  
	  ;        

                block = rec.area;
                TotApp = TotApp;
		appLodgedSP = appLodgedSP;
		SPnoApp = SPnoApp;
                appPendObj = appPendObj;
		appIncDoc = appIncDoc;
		appPDisp = appPDisp;
		appCompPDispNoCert = appCompPDispNoCert;
		appCertificate = appCertificate;
		appPrLand = appPrLand;
		appPubLand = appPubLand;
		TotSurvPar = TotSurvPar;
		appLodgedNoSP = TotApp-appLodgedSP;
		


	  
	  select into recToReturn
	       	block::			varchar,
		TotApp::  		decimal,
		appLodgedSP::  		decimal,
		SPnoApp::  		decimal,
		appPendObj::  		decimal,
		appIncDoc::  		decimal,
		appPDisp::  		decimal,
		appCompPDispNoCert::  	decimal,
		appCertificate::  	decimal,
		appPrLand::  		decimal,
		appPubLand::  		decimal,
		TotSurvPar::  		decimal,
		appLodgedNoSP::  	decimal;

		                         
          return next recToReturn;
          statusFound = true;
          
    end loop;
   
    if (not statusFound) then
         block = 'none';
                
        select into recToReturn
	       	block::			varchar,
		TotApp::  		decimal,
		appLodgedSP::  		decimal,
		SPnoApp::  		decimal,
		appPendObj::  		decimal,
		appIncDoc::  		decimal,
		appPDisp::  		decimal,
		appCompPDispNoCert::  	decimal,
		appCertificate::  	decimal,
		appPrLand::  		decimal,
		appPubLand::  		decimal,
		TotSurvPar::  		decimal,
		appLodgedNoSP::  	decimal;

		                         
          return next recToReturn;

    end if;
    return;
END;
$$;


ALTER FUNCTION administrative.getsysregstatus(fromdate character varying, todate character varying, namelastpart character varying) OWNER TO postgres;

--
-- Name: FUNCTION getsysregstatus(fromdate character varying, todate character varying, namelastpart character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION getsysregstatus(fromdate character varying, todate character varying, namelastpart character varying) IS 'Indicates the number of applications at various states of the systematic registration process';


SET search_path = application, pg_catalog;

--
-- Name: get_concatenated_name(character varying); Type: FUNCTION; Schema: application; Owner: postgres
--

CREATE FUNCTION get_concatenated_name(service_id character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
  rec record;
  name character varying;
  
BEGIN
  name = '';
   
	for rec in 
	   Select bu.name_firstpart||'/'||bu.name_lastpart||' ( '||pippo.firstpart||'/'||pippo.lastpart || ' ' || pippo.cadtype||' )'  as value,
	        pippo.id
		from application.service s 
		join application.application_property ap on (s.application_id=ap.application_id)
		join administrative.ba_unit bu on (ap.name_firstpart||ap.name_lastpart=bu.name_firstpart||bu.name_lastpart)
		join (select co.name_firstpart firstpart,
			   co.name_lastpart lastpart,
			   get_translation(cot.display_value, null) cadtype,
			   bsu.ba_unit_id unit_id,
			   co.id id
			   from administrative.ba_unit_contains_spatial_unit  bsu
			   join cadastre.cadastre_object co on (bsu.spatial_unit_id = co.id)
			   join cadastre.cadastre_object_type cot on (co.type_code = cot.code)) pippo
			   on (bu.id = pippo.unit_id)
	   where s.id = service_id 
	    and (s.request_type_code = 'cadastreChange' or s.request_type_code = 'redefineCadastre' or s.request_type_code = 'newApartment' 
	   or s.request_type_code = 'newDigitalProperty' or s.request_type_code = 'newDigitalTitle' or s.request_type_code = 'newFreehold' 
	   or s.request_type_code = 'newOwnership' or s.request_type_code = 'newState')
	   and s.status_code != 'lodged'
	loop
	   name = name || ', ' || replace (rec.value,rec.id, '');
	end loop;

        if name = '' then
	  return name;
	end if;

	if substr(name, 1, 1) = ',' then
          name = substr(name,2);
        end if;
return name;
END;

$$;


ALTER FUNCTION application.get_concatenated_name(service_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_concatenated_name(service_id character varying); Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON FUNCTION get_concatenated_name(service_id character varying) IS 'Returns a concatenated list of all cadastre objects associated to the BA Unit referenced by the application.';


--
-- Name: get_work_summary(date, date); Type: FUNCTION; Schema: application; Owner: postgres
--

CREATE FUNCTION get_work_summary(from_date date, to_date date) RETURNS TABLE(req_type character varying, req_cat character varying, group_idx integer, in_progress_from integer, on_requisition_from integer, lodged integer, requisitioned integer, registered integer, cancelled integer, withdrawn integer, in_progress_to integer, on_requisition_to integer, overdue integer, overdue_apps text, requisition_apps text)
    LANGUAGE plpgsql
    AS $$
DECLARE 
   tmp_date DATE; 
BEGIN

   IF to_date IS NULL OR from_date IS NULL THEN
      RETURN;
   END IF; 

   -- Swap the dates so the to date is after the from date
   IF to_date < from_date THEN 
      tmp_date := from_date; 
      from_date := to_date; 
      to_date := tmp_date; 
   END IF; 
   
   -- Go through to the start of the next day. 
   to_date := to_date + 1; 

   RETURN query 
   
      -- Identifies all services lodged during the reporting period. Uses the
	  -- change_time instead of lodging_datetime to ensure all datetime comparisons 
	  -- across all subqueries yield consistent results 
      WITH service_lodged AS
	   ( SELECT ser.id, ser.application_id, ser.request_type_code
         FROM   application.service ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
		 AND    ser.rowversion = 1
		 UNION
         SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code
         FROM   application.service_historic ser_hist
         WHERE  ser_hist.change_time BETWEEN from_date AND to_date
		 AND    ser_hist.rowversion = 1),
		 
      -- Identifies all services cancelled during the reporting period. 	  
	  service_cancelled AS 
        (SELECT ser.id, ser.application_id, ser.request_type_code
         FROM   application.service ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
		 AND    ser.status_code = 'cancelled'
     -- Verify that the service actually changed status 
         AND  NOT EXISTS (SELECT ser_hist.status_code 
                          FROM application.service_historic ser_hist
                          WHERE ser_hist.id = ser.id
                          AND  (ser.rowversion - 1) = ser_hist.rowversion
                          AND  ser.status_code = ser_hist.status_code )
	 -- Check the history data for cancelled services as applications returned
	 -- from requisition can cause the cancelled service record to be updated. 
		UNION
		SELECT ser.id, ser.application_id, ser.request_type_code
         FROM   application.service_historic ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
		 AND    ser.status_code = 'cancelled'
     -- Verify that the service actually changed status. 
         AND  NOT EXISTS (SELECT ser_hist.status_code 
                          FROM application.service_historic ser_hist
                          WHERE ser_hist.id = ser.id
                          AND  (ser.rowversion - 1) = ser_hist.rowversion
                          AND  ser.status_code = ser_hist.status_code )),
		
      -- All services in progress at the end of the reporting period		
      service_in_progress AS (  
         SELECT ser.id, ser.application_id, ser.request_type_code, ser.expected_completion_date
	 FROM application.service ser
	 WHERE ser.change_time <= to_date
	 AND ser.status_code IN ('pending', 'lodged')
      UNION
	 SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
	        ser_hist.expected_completion_date
	 FROM  application.service_historic ser_hist,
	       application.service ser
	 WHERE ser_hist.change_time <= to_date
	 AND   ser.id = ser_hist.id
	 -- Filter out any services that have not been changed since the to_date as these
	 -- would have been picked up in the first select if they were still active
	 AND   ser.change_time > to_date
	 AND   ser_hist.status_code IN ('pending', 'lodged')
	 AND   ser_hist.rowversion = (SELECT MAX(ser_hist2.rowversion)
				      FROM  application.service_historic ser_hist2
				      WHERE ser_hist.id = ser_hist2.id
				      AND   ser_hist2.change_time <= to_date )),
	
    -- All services in progress at the start of the reporting period	
	service_in_progress_from AS ( 
     SELECT ser.id, ser.application_id, ser.request_type_code, ser.expected_completion_date
	 FROM application.service ser
	 WHERE ser.change_time <= from_date
	 AND ser.status_code IN ('pending', 'lodged')
     UNION
	 SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
	        ser_hist.expected_completion_date
	 FROM  application.service_historic ser_hist,
	       application.service ser
	 WHERE ser_hist.change_time <= from_date
	 AND   ser.id = ser_hist.id
	 -- Filter out any services that have not been changed since the from_date as these
	 -- would have been picked up in the first select if they were still active
	 AND   ser.change_time > from_date
	 AND   ser_hist.status_code IN ('pending', 'lodged')
	 AND   ser_hist.rowversion = (SELECT MAX(ser_hist2.rowversion)
				      FROM  application.service_historic ser_hist2
				      WHERE ser_hist.id = ser_hist2.id
				      AND   ser_hist2.change_time <= from_date )),
				      
    app_changed AS ( -- All applications that changed status during the reporting period
	                 -- If the application changed status more than once, it will be listed
					 -- multiple times
         SELECT app.id, 
	 -- Flag if the application was withdrawn
	 app.status_code,
	 CASE app.action_code WHEN 'withdrawn' THEN TRUE ELSE FALSE END AS withdrawn
	 FROM   application.application app
	 WHERE  app.change_time BETWEEN from_date AND to_date
	 -- Verify that the application actually changed status during the reporting period
	 -- rather than just being updated
	 AND  NOT EXISTS (SELECT app_hist.status_code 
			  FROM application.application_historic app_hist
			  WHERE app_hist.id = app.id
			  AND  (app.rowversion - 1) = app_hist.rowversion
			  AND  app.status_code = app_hist.status_code )
      UNION  
	 SELECT app_hist.id, 
	 app_hist.status_code,
	 CASE app_hist.action_code WHEN 'withdrawn' THEN TRUE ELSE FALSE END AS withdrawn
	 FROM  application.application_historic app_hist
	 WHERE app_hist.change_time BETWEEN from_date AND to_date
	 -- Verify that the application actually changed status during the reporting period
	 -- rather than just being updated
	 AND  NOT EXISTS (SELECT app_hist2.status_code 
			  FROM application.application_historic app_hist2
			  WHERE app_hist.id = app_hist2.id
			  AND  (app_hist.rowversion - 1) = app_hist2.rowversion
			  AND  app_hist.status_code = app_hist2.status_code )), 
                          
     app_in_progress AS ( -- All applications in progress at the end of the reporting period
	 SELECT app.id, app.status_code, app.expected_completion_date, app.nr
	 FROM application.application app
	 WHERE app.change_time <= to_date
	 AND app.status_code IN ('lodged', 'requisitioned')
	 UNION
	 SELECT app_hist.id, app_hist.status_code, app_hist.expected_completion_date, app_hist.nr
	 FROM  application.application_historic app_hist, 
	       application.application app
	 WHERE app_hist.change_time <= to_date
	 AND   app.id = app_hist.id
	 -- Filter out any applications that have not been changed since the to_date as these
	 -- would have been picked up in the first select if they were still active
	 AND   app.change_time > to_date
	 AND   app_hist.status_code IN ('lodged', 'requisitioned')
	 AND   app_hist.rowversion = (SELECT MAX(app_hist2.rowversion)
				      FROM  application.application_historic app_hist2
				      WHERE app_hist.id = app_hist2.id
				      AND   app_hist2.change_time <= to_date)),
					  
	app_in_progress_from AS ( -- All applications in progress at the start of the reporting period
	 SELECT app.id, app.status_code, app.expected_completion_date, app.nr
	 FROM application.application app
	 WHERE app.change_time <= from_date
	 AND app.status_code IN ('lodged', 'requisitioned')
	 UNION
	 SELECT app_hist.id, app_hist.status_code, app_hist.expected_completion_date, app_hist.nr
	 FROM  application.application_historic app_hist,
	       application.application app
	 WHERE app_hist.change_time <= from_date
	 AND   app.id = app_hist.id
	-- Filter out any applications that have not been changed since the from_date as these
	-- would have been picked up in the first select if they were still active
	 AND   app.change_time > from_date
	 AND   app_hist.status_code IN ('lodged', 'requisitioned')
	 AND   app_hist.rowversion = (SELECT MAX(app_hist2.rowversion)
				      FROM  application.application_historic app_hist2
				      WHERE app_hist.id = app_hist2.id
				      AND   app_hist2.change_time <= from_date))
   -- MAIN QUERY                         
   SELECT get_translation(req.display_value, null) AS req_type,
	  CASE req.request_category_code 
	     WHEN 'registrationServices' THEN get_translation(cat.display_value, null)
	     WHEN 'cadastralServices' THEN get_translation(cat.display_value, null)
	     ELSE 'Information Services'  END AS req_cat,
	     
	  CASE req.request_category_code 
	     WHEN 'registrationServices' THEN 1
             WHEN 'cadastralServices' THEN 2
	     ELSE 3 END AS group_idx,
		 
	  -- Count of the pending and lodged services associated with
	  -- lodged applications at the start of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress_from s, app_in_progress_from a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'
	  AND request_type_code = req.code)::INT AS in_progress_from,

	  -- Count of the services associated with requisitioned 
	  -- applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress_from s, app_in_progress_from a
	  WHERE s.application_id = a.id
          AND   a.status_code = 'requisitioned'
	  AND s.request_type_code = req.code)::INT AS on_requisition_from,
	     
	  -- Count the services lodged during the reporting period.
	 (SELECT COUNT(s.id) FROM service_lodged s
	  WHERE s.request_type_code = req.code)::INT AS lodged,
	  
      -- Count the applications that were requisitioned during the
	  -- reporting period. All of the services on the application
 	  -- are requisitioned unless they are cancelled. Use the
	  -- current set of services on the application, but ensure
	  -- the services where lodged before the end of the reporting
	  -- period and that they were not cancelled during the 
	  -- reporting period. 
	 (SELECT COUNT(s.id) FROM app_changed a, application.service s
          WHERE s.application_id = a.id
	  AND   a.status_code = 'requisitioned'
	  AND   s.lodging_datetime < to_date
	  AND   NOT EXISTS (SELECT can.id FROM service_cancelled can
                        WHERE s.id = can.id)	  
          AND   s.request_type_code = req.code)::INT AS requisitioned, 
          
	  -- Count the services on applications approved/completed 
	  -- during the reporting period. Note that services cannot be
	  -- changed after the application is approved, so checking the
	  -- current state of the services is valid. 
         (SELECT COUNT(s.id) FROM app_changed a, application.service s
	  WHERE s.application_id = a.id
	  AND   a.status_code = 'approved'
	  AND   s.status_code = 'completed'
	  AND   s.request_type_code = req.code)::INT AS registered,
	  
	  -- Count of the services associated with applications 
	  -- that have been lapsed or rejected + the count of 
	  -- services cancelled during the reporting period. Note that
      -- once annulled changes to the services are not possible so
      -- checking the current state of the services is valid.
      (SELECT COUNT(tmp.id) FROM  	  
        (SELECT s.id FROM app_changed a, application.service s
		  WHERE s.application_id = a.id
		  AND   a.status_code = 'annulled'
		  AND   a.withdrawn = FALSE
		  AND   s.request_type_code = req.code
          UNION		  
		  SELECT s.id FROM app_changed a, service_cancelled s
		  WHERE s.application_id = a.id
		  AND   a.status_code != 'annulled'
		  AND   s.request_type_code = req.code) AS tmp)::INT AS cancelled, 
	  
	  -- Count of the services associated with applications
	  -- that have been withdrawn during the reporting period
	  -- Note that once annulled changes to the services are
      -- not possible so checking the current state of the services is valid. 
         (SELECT COUNT(s.id) FROM app_changed a, application.service s
	  WHERE s.application_id = a.id
	  AND   a.status_code = 'annulled'
	  AND   a.withdrawn = TRUE
	  AND   s.status_code != 'cancelled'
	  AND   s.request_type_code = req.code)::INT AS withdrawn,

	  -- Count of the pending and lodged services associated with
	  -- lodged applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'
	  AND request_type_code = req.code)::INT AS in_progress_to,

	  -- Count of the services associated with requisitioned 
	  -- applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
	  WHERE s.application_id = a.id
          AND   a.status_code = 'requisitioned'
	  AND s.request_type_code = req.code)::INT AS on_requisition_to,

	  -- Count of the services that have exceeded thier expected
	  -- completion date and are overdue. Only counts the service 
	  -- as overdue if both the application and the service are overdue. 
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'              
	  AND   a.expected_completion_date < to_date
	  AND   s.expected_completion_date < to_date
	  AND   s.request_type_code = req.code)::INT AS overdue,  

	  -- The list of overdue applications 
	 (SELECT string_agg(a.nr, ', ') FROM app_in_progress a
          WHERE a.status_code = 'lodged' 
          AND   a.expected_completion_date < to_date
          AND   EXISTS (SELECT s.application_id FROM service_in_progress s
                        WHERE s.application_id = a.id
                        AND   s.expected_completion_date < to_date
                        AND   s.request_type_code = req.code)) AS overdue_apps,   

	  -- The list of applications on Requisition
	 (SELECT string_agg(a.nr, ', ') FROM app_in_progress a
          WHERE a.status_code = 'requisitioned' 
          AND   EXISTS (SELECT s.application_id FROM service_in_progress s
                        WHERE s.application_id = a.id
                        AND   s.request_type_code = req.code)) AS requisition_apps 						
   FROM  application.request_type req, 
	 application.request_category_type cat
   WHERE req.status = 'c'
   AND   cat.code = req.request_category_code					 
   ORDER BY group_idx, req_type;
	
   END; $$;


ALTER FUNCTION application.get_work_summary(from_date date, to_date date) OWNER TO postgres;

--
-- Name: FUNCTION get_work_summary(from_date date, to_date date); Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON FUNCTION get_work_summary(from_date date, to_date date) IS 'Returns a summary of the services processed for a specified reporting period. Used by the Lodgement Statistics Report.';


--
-- Name: getlodgement(character varying, character varying); Type: FUNCTION; Schema: application; Owner: postgres
--

CREATE FUNCTION getlodgement(fromdate character varying, todate character varying) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE 
    resultType  varchar;
    resultGroup varchar;
    resultTotal integer :=0 ;
    resultTotalPerc decimal:=0 ;
    resultDailyAvg  decimal:=0 ;
    resultTotalReq integer:=0 ;
    resultReqPerc  decimal:=0 ;
    TotalTot integer:=0 ;
    appoDiff integer:=0 ;
    rec     record;
    sqlSt varchar;
    lodgementFound boolean;
    recToReturn record;

    
BEGIN  
    appoDiff := (to_date(''|| toDate || '','yyyy-mm-dd') - to_date(''|| fromDate || '','yyyy-mm-dd'));
     if  appoDiff= 0 then 
            appoDiff:= 1;
     end if; 
    sqlSt:= '';
    
    sqlSt:= 'select   1 as order,
         get_translation(application.request_type.display_value, null) as type,
         application.request_type.request_category_code as group,
         count(application.service_historic.id) as total,
         round((CAST(count(application.service_historic.id) as decimal)
         /
         '||appoDiff||'
         ),2) as dailyaverage
from     application.service_historic,
         application.request_type
where    application.service_historic.request_type_code = application.request_type.code
         and
         application.service_historic.lodging_datetime between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
         and application.service_historic.action_code=''lodge''
         and application.service_historic.application_id in
	      (select distinct(application.application_historic.id)
	       from application.application_historic)
group by application.service_historic.request_type_code, application.request_type.display_value,
         application.request_type.request_category_code
union
select   2 as order,
         ''Total'' as type,
         ''All'' as group,
         count(application.service_historic.id) as total,
         round((CAST(count(application.service_historic.id) as decimal)
         /
         '||appoDiff||'
         ),2) as dailyaverage
from     application.service_historic,
         application.request_type
where    application.service_historic.request_type_code = application.request_type.code
         and
         application.service_historic.lodging_datetime between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
         and application.service_historic.application_id in
	      (select distinct(application.application_historic.id)
	       from application.application_historic)
order by 1,3,2;
';




  

    --raise exception '%',sqlSt;
    lodgementFound = false;
    -- Loop through results
         select   
         count(application.service_historic.id)
         into TotalTot
from     application.service_historic,
         application.request_type
where    application.service_historic.request_type_code = application.request_type.code
         and
         application.service_historic.lodging_datetime between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd')
         and application.service_historic.application_id in
	      (select distinct(application.application_historic.id)
	       from application.application_historic);

    
    FOR rec in EXECUTE sqlSt loop
            resultType:= rec.type;
	    resultGroup:= rec.group;
	    resultTotal:= rec.total;
	    if  TotalTot= 0 then 
               TotalTot:= 1;
            end if; 
	    resultTotalPerc:= round((CAST(rec.total as decimal)*100/TotalTot),2);
	    resultDailyAvg:= rec.dailyaverage;
            resultTotalReq:= 0;

           

            if rec.type = 'Total' then
                 select   count(application.service_historic.id) into resultTotalReq
		from application.service_historic
		where application.service_historic.action_code='lodge'
                      and
                      application.service_historic.lodging_datetime between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd')
                      and application.service_historic.application_id in
		      (select application.application_historic.id
		       from application.application_historic
		       where application.application_historic.action_code='requisition');
            else
                  select  count(application.service_historic.id) into resultTotalReq
		from application.service_historic
		where application.service_historic.action_code='lodge'
                      and
                      application.service_historic.lodging_datetime between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd')
                      and application.service_historic.application_id in
		      (select application.application_historic.id
		       from application.application_historic
		       where application.application_historic.action_code='requisition'
		      )   
		and   application.service_historic.request_type_code = rec.type     
		group by application.service_historic.request_type_code;
            end if;

             if  rec.total= 0 then 
               appoDiff:= 1;
             else
               appoDiff:= rec.total;
             end if; 
            resultReqPerc:= round((CAST(resultTotalReq as decimal)*100/appoDiff),2);

            if resultType is null then
              resultType :=0 ;
            end if;
	    if resultTotal is null then
              resultTotal  :=0 ;
            end if;  
	    if resultTotalPerc is null then
	         resultTotalPerc  :=0 ;
            end if;  
	    if resultDailyAvg is null then
	        resultDailyAvg  :=0 ;
            end if;  
	    if resultTotalReq is null then
	        resultTotalReq  :=0 ;
            end if;  
	    if resultReqPerc is null then
	        resultReqPerc  :=0 ;
            end if;  

	    if TotalTot is null then
	       TotalTot  :=0 ;
            end if;  
	  
          select into recToReturn resultType::varchar, resultGroup::varchar, resultTotal::integer, resultTotalPerc::decimal,resultDailyAvg::decimal,resultTotalReq::integer,resultReqPerc::decimal;
          return next recToReturn;
          lodgementFound = true;
    end loop;
   
    if (not lodgementFound) then
        RAISE EXCEPTION 'no_lodgement_found';
    end if;
    return;
END;
$$;


ALTER FUNCTION application.getlodgement(fromdate character varying, todate character varying) OWNER TO postgres;

--
-- Name: FUNCTION getlodgement(fromdate character varying, todate character varying); Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON FUNCTION getlodgement(fromdate character varying, todate character varying) IS 'Not used. Replaced by get_work_summary.';


--
-- Name: getlodgetiming(date, date); Type: FUNCTION; Schema: application; Owner: postgres
--

CREATE FUNCTION getlodgetiming(fromdate date, todate date) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE 
    timeDiff integer:=0 ;
BEGIN
timeDiff := toDate-fromDate;
if timeDiff<=0 then 
    timeDiff:= 1;
end if; 

return query
select 'Lodged not completed'::varchar as resultCode, count(1)::integer as resultTotal, (round(count(1)::numeric/timeDiff,1))::float as resultDailyAvg, 1 as ord 
from application.application
where lodging_datetime between fromdate and todate and status_code = 'lodged'
union
select 'Registered' as resultCode, count(1)::integer as resultTotal, (round(count(1)::numeric/timeDiff,1))::float as resultDailyAvg, 2 as ord 
from application.application
where lodging_datetime between fromdate and todate
union
select 'Rejected' as resultCode, count(1)::integer as resultTotal, (round(count(1)::numeric/timeDiff,1))::float as resultDailyAvg, 3 as ord 
from application.application
where lodging_datetime between fromdate and todate and status_code = 'annulled'
union
select 'On Requisition' as resultCode, count(1)::integer as resultTotal, (round(count(1)::numeric/timeDiff,1))::float as resultDailyAvg, 4 as ord 
from application.application
where lodging_datetime between fromdate and todate and status_code = 'requisitioned'
union
select 'Withdrawn' as resultCode, count(distinct id)::integer as resultTotal, (round(count(distinct id)::numeric/timeDiff,1))::float as resultDailyAvg, 5 as ord 
from application.application_historic
where change_time between fromdate and todate and action_code = 'withdraw'
order by ord;

END;
$$;


ALTER FUNCTION application.getlodgetiming(fromdate date, todate date) OWNER TO postgres;

--
-- Name: FUNCTION getlodgetiming(fromdate date, todate date); Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON FUNCTION getlodgetiming(fromdate date, todate date) IS 'Not used. Replaced by get_work_summary.';


SET search_path = bulk_operation, pg_catalog;

--
-- Name: clean_after_rollback(); Type: FUNCTION; Schema: bulk_operation; Owner: postgres
--

CREATE FUNCTION clean_after_rollback() RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
  rec record;
begin
  for rec in select id from cadastre.level 
    where id != 'cadastreObject' and id not in (select level_id from cadastre.spatial_unit) loop
    delete from cadastre.level where id = rec.id;
    delete from system.config_map_layer where added_from_bulk_operation and name = rec.id;
  end loop;
end;
$$;


ALTER FUNCTION bulk_operation.clean_after_rollback() OWNER TO postgres;

--
-- Name: FUNCTION clean_after_rollback(); Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON FUNCTION clean_after_rollback() IS 'Runs clean up tasks after the transaction of bulk operation is rolled back.';


--
-- Name: move_cadastre_objects(character varying, character varying); Type: FUNCTION; Schema: bulk_operation; Owner: postgres
--

CREATE FUNCTION move_cadastre_objects(transaction_id_v character varying, change_user_v character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare
  generate_name_first_part boolean;
  rec record;
  rec2 record;
  last_part varchar;
  first_part_counter integer;
  first_part  varchar;
  tmp_value integer;
  duplicate_seperator varchar;
  status varchar;
  geom_v geometry;
  tolerance double precision;
  survey_point_counter integer;
  transaction_has_pending boolean;
begin
  transaction_has_pending = false;
  duplicate_seperator = ' / ';
  tolerance = system.get_setting('map-tolerance')::double precision;
  generate_name_first_part = (select bulk_generate_first_part 
    from transaction.transaction 
    where id = transaction_id_v);
  first_part_counter = 1;
  for rec in select id, transaction_id, cadastre_object_type_code, name_firstpart, name_lastpart, geom, official_area
    from bulk_operation.spatial_unit_temporary where transaction_id = transaction_id_v loop
      status = 'current';
      if last_part is null then
        last_part = rec.name_lastpart;
        if generate_name_first_part then
          first_part_counter = (select coalesce(max(name_firstpart::integer), 0) 
            from cadastre.cadastre_object 
            where name_firstpart ~ '^[0-9]+$' and name_lastpart = last_part);
          first_part_counter = first_part_counter + 1;
        end if;
      end if;
      if not generate_name_first_part then
        first_part = rec.name_firstpart;
        -- It means the unicity of the cadastre object name is not garanteed so it has to be checked.
        -- Check first if the combination first_part, last_part is found in the cadastre_object table
        tmp_value = (select count(1)
          from cadastre.cadastre_object 
          where name_lastpart = last_part 
            and (name_firstpart = first_part
              or name_firstpart like first_part || duplicate_seperator || '%'));
        if tmp_value > 0 then
          tmp_value = tmp_value + 1;
          first_part = first_part || duplicate_seperator || tmp_value::varchar;
          status = 'pending';
        end if;
      else
        first_part = first_part_counter::varchar;
        first_part_counter = first_part_counter + 1;
      end if;
      geom_v = rec.geom;
      if st_isvalid(geom_v) and st_geometrytype(geom_v) = 'ST_Polygon' then
        if (select count(1) 
          from cadastre.cadastre_object 
          where geom_polygon && geom_v 
            and st_intersects(geom_polygon, st_buffer(geom_v, - tolerance))) > 0 then
          status = 'pending';
        end if;
        insert into cadastre.cadastre_object(id, type_code, status_code, transaction_id, name_firstpart, name_lastpart, geom_polygon, change_user)
        values(rec.id, rec.cadastre_object_type_code, status, transaction_id_v, first_part, last_part, geom_v, change_user_v);
        insert into cadastre.spatial_value_area(spatial_unit_id, type_code, size, change_user)
        values(rec.id, 'officialArea', coalesce(rec.official_area, st_area(geom_v)), change_user_v);
        insert into cadastre.spatial_value_area(spatial_unit_id, type_code, size, change_user)
        values(rec.id, 'calculatedArea', st_area(geom_v), change_user_v);
      else
        status = 'pending'; 
      end if;
      if status = 'pending' then
        transaction_has_pending = true;
        survey_point_counter = (select count(1) + 1 from cadastre.survey_point where transaction_id = transaction_id_v);
        for rec2 in select distinct geom from st_dumppoints(geom_v) loop
          insert into cadastre.survey_point(transaction_id, id, geom, original_geom, change_user)
          values(transaction_id_v, survey_point_counter::varchar, rec2.geom, rec2.geom, change_user_v);
          survey_point_counter = survey_point_counter + 1;
        end loop;
      end if;
    end loop;
    if not transaction_has_pending then
      update transaction.transaction set status_code = 'approved', change_user = change_user_v where id = transaction_id_v;
    end if;
    delete from bulk_operation.spatial_unit_temporary where transaction_id = transaction_id_v;
end;
$_$;


ALTER FUNCTION bulk_operation.move_cadastre_objects(transaction_id_v character varying, change_user_v character varying) OWNER TO postgres;

--
-- Name: FUNCTION move_cadastre_objects(transaction_id_v character varying, change_user_v character varying); Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON FUNCTION move_cadastre_objects(transaction_id_v character varying, change_user_v character varying) IS 'Moves cadastre objects from the Bulk Operation schema to the Cadastre schema.';


--
-- Name: move_other_objects(character varying, character varying); Type: FUNCTION; Schema: bulk_operation; Owner: postgres
--

CREATE FUNCTION move_other_objects(transaction_id_v character varying, change_user_v character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
  other_object_type varchar;
  level_id_v varchar;
  geometry_type varchar;
  geometry_type_for_structure varchar;
  query_name_v varchar;
  query_sql_template varchar;
begin
  query_sql_template = 'select id, label, st_asewkb(st_transform(geom, #{srid})) as the_geom from cadastre.spatial_unit 
where level_id = ''level_id_v'' and ST_Intersects(st_transform(geom, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))';
  other_object_type = (select type_code 
    from bulk_operation.spatial_unit_temporary 
    where transaction_id = transaction_id_v limit 1);
  geometry_type = (select st_geometrytype(geom) 
    from bulk_operation.spatial_unit_temporary 
    where transaction_id = transaction_id_v limit 1);
  geometry_type = lower(substring(geometry_type from 4));
  if (select count(*) from cadastre.structure_type where code = geometry_type) = 0 then
    insert into cadastre.structure_type(code, display_value, status)
    values(geometry_type, geometry_type, 'c');
  end if;
  level_id_v = (select id from cadastre.level where name = other_object_type or id = lower(other_object_type));
  if level_id_v is null then
    level_id_v = lower(other_object_type);
    insert into cadastre.level(id, type_code, name, structure_code, editable) 
    values(level_id_v, 'geographicLocator', other_object_type, geometry_type, true);
    if (select count(*) from system.config_map_layer where name = level_id_v) = 0 then
      -- A map layer is added here. For the symbology an sld file already predefined in gis component must be used.
      -- The sld file must be named after the geometry type + the word generic. 
      query_name_v = 'SpatialResult.get' || level_id_v;
      if (select count(*) from system.query where name = query_name_v) = 0 then
        -- A query is added here
        insert into system.query(name, sql) values(query_name_v, replace(query_sql_template, 'level_id_v', level_id_v));
      end if;
      if geometry_type like '%point' then
        geometry_type_for_structure = replace(geometry_type, 'point', 'Point');
      elseif geometry_type like '%linestring' then
        geometry_type_for_structure = replace(geometry_type, 'linestring', 'LineString');
      elseif geometry_type like '%polygon' then
        geometry_type_for_structure = replace(geometry_type, 'polygon', 'Polygon');
      else
        geometry_type_for_structure = 'Geometry';
      end if;
      geometry_type_for_structure  = replace(geometry_type_for_structure, 'multi', 'Multi');
      
      insert into system.config_map_layer(name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name, added_from_bulk_operation) 
      values(level_id_v, other_object_type, 'pojo', true, true, 1, 'generic-' || geometry_type || '.xml', 'theGeom:' || geometry_type_for_structure || ',label:""', query_name_v, true);
    end if;
  end if;
  insert into cadastre.spatial_unit(id, label, level_id, geom, transaction_id, change_user)
  select id, label, level_id_v, geom, transaction_id, change_user_v
  from bulk_operation.spatial_unit_temporary where transaction_id = transaction_id_v;
  update transaction.transaction set status_code = 'approved', change_user = change_user_v where id = transaction_id_v;
  delete from bulk_operation.spatial_unit_temporary where transaction_id = transaction_id_v;
end;
$$;


ALTER FUNCTION bulk_operation.move_other_objects(transaction_id_v character varying, change_user_v character varying) OWNER TO postgres;

--
-- Name: FUNCTION move_other_objects(transaction_id_v character varying, change_user_v character varying); Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON FUNCTION move_other_objects(transaction_id_v character varying, change_user_v character varying) IS 'Moves general spatial objects other than cadastre objects from the Bulk Operation schema to the Cadastre schema. If an appropriate level and/or structure type do not exist in the Cadastre schema, this function will add them.';


--
-- Name: move_spatial_units(character varying, character varying); Type: FUNCTION; Schema: bulk_operation; Owner: postgres
--

CREATE FUNCTION move_spatial_units(transaction_id_v character varying, change_user_v character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
  spatial_unit_type varchar;
begin
  spatial_unit_type = (select type_code 
    from bulk_operation.spatial_unit_temporary 
    where transaction_id = transaction_id_v limit 1);
  if spatial_unit_type is null then
    return;
  end if;
  if spatial_unit_type = 'cadastre_object' then
    execute bulk_operation.move_cadastre_objects(transaction_id_v, change_user_v);
  else
    execute bulk_operation.move_other_objects(transaction_id_v, change_user_v);
  end if;
end;
$$;


ALTER FUNCTION bulk_operation.move_spatial_units(transaction_id_v character varying, change_user_v character varying) OWNER TO postgres;

--
-- Name: FUNCTION move_spatial_units(transaction_id_v character varying, change_user_v character varying); Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON FUNCTION move_spatial_units(transaction_id_v character varying, change_user_v character varying) IS 'Moves all spatial data from teh Bulk Operation schema to the Cadastre schema using the move_cadastre_objects and move_other_objects functions. This function is called after the bulk opearation transaction is created by the Bulk Operation application';


SET search_path = cadastre, pg_catalog;

--
-- Name: add_topo_points(public.geometry, public.geometry); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION add_topo_points(source public.geometry, target public.geometry) RETURNS public.geometry
    LANGUAGE plpgsql
    AS $$
declare
  rec record;
  point_location float;
  point_to_add geometry;
  rings geometry[];
  nr_elements integer;
  tolerance double precision;
  i integer;
begin
  tolerance = system.get_setting('map-tolerance')::double precision;
  if st_geometrytype(target) = 'ST_LineString' then
    for rec in 
      select geom from St_DumpPoints(source) s
        where st_dwithin(target, s.geom, tolerance)
    loop
      if (select count(1) from st_dumppoints(target) t where st_dwithin(rec.geom, t.geom, tolerance))=0 then
        point_location = ST_Line_Locate_Point(target, rec.geom);
        --point_to_add = ST_Line_Interpolate_Point(target, point_location);
        target = ST_LineMerge(ST_Union(ST_Line_Substring(target, 0, point_location), ST_Line_Substring(target, point_location, 1)));
      end if;
    end loop;
  elsif st_geometrytype(target)= 'ST_Polygon' then
    select  array_agg(ST_ExteriorRing(geom)) into rings from ST_DumpRings(target);
    nr_elements = array_upper(rings, 1);
    for i in 1..nr_elements loop
      rings[i] = cadastre.add_topo_points(source, rings[i]);
    end loop;
    target = ST_MakePolygon(rings[1], rings[2:nr_elements]);
  end if;
  return target;
end;
$$;


ALTER FUNCTION cadastre.add_topo_points(source public.geometry, target public.geometry) OWNER TO postgres;

--
-- Name: FUNCTION add_topo_points(source public.geometry, target public.geometry); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION add_topo_points(source public.geometry, target public.geometry) IS 'Alters the topology of the target geometry by merging selected coordinates from the source geometry into the target geometry. Only those coordinates from the source geometry that are within the map-tolerance distance of the target geometry boundary are merged. Used during spatial editing of parcels to ensure parcels adjacent of the edit remain topologically consistent with any new parcels.';


--
-- Name: cadastre_object_name_is_valid(character varying, character varying); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
  if name_firstpart is null then return false; end if;
  if name_lastpart is null then return false; end if;
  if not (name_firstpart similar to 'Lot [0-9]+' or name_firstpart similar to '[0-9]+') then return false;  end if;
  if name_lastpart not similar to '(D|S)P [0-9 ]+' then return false;  end if;
  return true;
end;
$$;


ALTER FUNCTION cadastre.cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying) OWNER TO postgres;

--
-- Name: FUNCTION cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying) IS 'Verifies that the name assigned to a new cadastre object is consistent with the cadastre object naming rules.';


--
-- Name: f_for_tbl_cadastre_object_trg_geommodify(); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION f_for_tbl_cadastre_object_trg_geommodify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  rec record;
  rec_snap record;
  tolerance float;
  modified_geom geometry;
begin

  if new.status_code != 'current' then
    return new;
  end if;

  if new.type_code not in (select code from cadastre.cadastre_object_type where in_topology) then
    return new;
  end if;

  tolerance = coalesce(system.get_setting('map-tolerance')::double precision, 0.01);
  for rec in select co.id, co.geom_polygon 
                 from cadastre.cadastre_object co 
                 where  co.id != new.id and co.type_code = new.type_code and co.status_code = 'current'
                     and co.geom_polygon is not null 
                     and new.geom_polygon && co.geom_polygon 
                     and st_dwithin(new.geom_polygon, co.geom_polygon, tolerance)
  loop
    modified_geom = cadastre.add_topo_points(new.geom_polygon, rec.geom_polygon);
    if not st_equals(modified_geom, rec.geom_polygon) then
      update cadastre.cadastre_object 
        set geom_polygon= modified_geom, change_user= new.change_user 
      where id= rec.id;
    end if;
  end loop;
  return new;
end;
$$;


ALTER FUNCTION cadastre.f_for_tbl_cadastre_object_trg_geommodify() OWNER TO postgres;

--
-- Name: FUNCTION f_for_tbl_cadastre_object_trg_geommodify(); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION f_for_tbl_cadastre_object_trg_geommodify() IS 'Function triggered on insert or update to the cadastre_object table.  Uses the add_topo_points function to merge the topology of any parcels adjacent to parcel being updated. Only applied if the parcel being updated has a current status.';


--
-- Name: f_for_tbl_cadastre_object_trg_new(); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION f_for_tbl_cadastre_object_trg_new() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  if (select count(*)=0 from cadastre.spatial_unit where id=new.id) then
    insert into cadastre.spatial_unit(id, rowidentifier, level_id, change_user) 
    values(new.id, new.rowidentifier, 'cadastreObject', new.change_user);
  end if;
  return new;
END;

$$;


ALTER FUNCTION cadastre.f_for_tbl_cadastre_object_trg_new() OWNER TO postgres;

--
-- Name: FUNCTION f_for_tbl_cadastre_object_trg_new(); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION f_for_tbl_cadastre_object_trg_new() IS 'Function triggered on insert to the cadastre_object table.  Inserts a record in the spatial_unit table for the cadastre_object if no spatial_unit record for the new cadastre_object exists.';


--
-- Name: f_for_tbl_cadastre_object_trg_remove(); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION f_for_tbl_cadastre_object_trg_remove() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  delete from cadastre.spatial_unit where id=old.id;
  return old;
END;
$$;


ALTER FUNCTION cadastre.f_for_tbl_cadastre_object_trg_remove() OWNER TO postgres;

--
-- Name: FUNCTION f_for_tbl_cadastre_object_trg_remove(); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION f_for_tbl_cadastre_object_trg_remove() IS 'Function triggered on delete from the cadastre_object table. Cascade deletes the record in the spatial_unit table for the cadastre_object.';


--
-- Name: generate_spatial_unit_group_name(public.geometry, integer, character varying); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION generate_spatial_unit_group_name(geom_v public.geometry, hierarchy_level_v integer, label_v character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
  name_parent varchar;  
BEGIN
  if hierarchy_level_v = 0 then
    return label_v;
  end if;
  name_parent =  coalesce( (select name 
  from cadastre.spatial_unit_group 
  where hierarchy_level = hierarchy_level_v - 1 and st_intersects(st_centroid(geom_v), geom)), '');
  return name_parent || '/' || label_v;
END;
$$;


ALTER FUNCTION cadastre.generate_spatial_unit_group_name(geom_v public.geometry, hierarchy_level_v integer, label_v character varying) OWNER TO postgres;

--
-- Name: FUNCTION generate_spatial_unit_group_name(geom_v public.geometry, hierarchy_level_v integer, label_v character varying); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION generate_spatial_unit_group_name(geom_v public.geometry, hierarchy_level_v integer, label_v character varying) IS 'Determines the hierarchical name to assign a new Spatial Unit Group.';


--
-- Name: get_map_center_label(public.geometry); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION get_map_center_label(center_point public.geometry) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
begin
  return 'center label';
end;
$$;


ALTER FUNCTION cadastre.get_map_center_label(center_point public.geometry) OWNER TO postgres;

--
-- Name: FUNCTION get_map_center_label(center_point public.geometry); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION get_map_center_label(center_point public.geometry) IS 'Returns a value that is displayed in the centre of the Public Display Maps for Systematic Registration. This function has default code that should be updated for each implementation of SOLA.';


--
-- Name: get_new_cadastre_object_identifier_first_part(character varying, character varying); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION get_new_cadastre_object_identifier_first_part(last_part character varying, cadastre_object_type character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
begin
  return '1';
end;
$$;


ALTER FUNCTION cadastre.get_new_cadastre_object_identifier_first_part(last_part character varying, cadastre_object_type character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_new_cadastre_object_identifier_first_part(last_part character varying, cadastre_object_type character varying); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION get_new_cadastre_object_identifier_first_part(last_part character varying, cadastre_object_type character varying) IS 'Used to determine the value for the first name part for a new cadastre object. This function has default code that should be updated for each implementation of SOLA to match the cadastre object naming conventions used by the implementing organisation.';


--
-- Name: get_new_cadastre_object_identifier_last_part(public.geometry, character varying); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION get_new_cadastre_object_identifier_last_part(geom public.geometry, cadastre_object_type character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
begin
  return cadastre_object_type;
end;
$$;


ALTER FUNCTION cadastre.get_new_cadastre_object_identifier_last_part(geom public.geometry, cadastre_object_type character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_new_cadastre_object_identifier_last_part(geom public.geometry, cadastre_object_type character varying); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION get_new_cadastre_object_identifier_last_part(geom public.geometry, cadastre_object_type character varying) IS 'Used to determine the value for the last name part for a new cadastre object. This function has default code that should be updated for each implementation of SOLA to match the cadastre object naming conventions used by the implementing organisation.';


--
-- Name: snap_geometry_to_geometry(public.geometry, public.geometry, double precision, boolean); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION snap_geometry_to_geometry(INOUT geom_to_snap public.geometry, INOUT target_geom public.geometry, snap_distance double precision, change_target_if_needed boolean, OUT snapped boolean, OUT target_is_changed boolean) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
  i integer;
  nr_elements integer;
  rec record;
  rec2 record;
  point_location float;
  rings geometry[];
  
BEGIN
  target_is_changed = false;
  snapped = false;
  if st_geometrytype(geom_to_snap) not in ('ST_Point', 'ST_LineString', 'ST_Polygon') then
    raise exception 'geom_to_snap not supported. Only point, linestring and polygon is supported.';
  end if;
  if st_geometrytype(geom_to_snap) = 'ST_Point' then
    -- If the geometry to snap is POINT
    if st_geometrytype(target_geom) = 'ST_Point' then
      if st_dwithin(geom_to_snap, target_geom, snap_distance) then
        geom_to_snap = target_geom;
        snapped = true;
      end if;
    elseif st_geometrytype(target_geom) = 'ST_LineString' then
      -- Check first if there is any point of linestring where the point can be snapped.
      select t.* into rec from ST_DumpPoints(target_geom) t where st_dwithin(geom_to_snap, t.geom, snap_distance);
      if rec is not null then
        geom_to_snap = rec.geom;
        snapped = true;
        return;
      end if;
      --Check second if the point is within distance from linestring and get an interpolation point in the line.
      if st_dwithin(geom_to_snap, target_geom, snap_distance) then
        point_location = ST_Line_Locate_Point(target_geom, geom_to_snap);
        geom_to_snap = ST_Line_Interpolate_Point(target_geom, point_location);
        if change_target_if_needed then
          target_geom = ST_LineMerge(ST_Union(ST_Line_Substring(target_geom, 0, point_location), ST_Line_Substring(target_geom, point_location, 1)));
          target_is_changed = true;
        end if;
        snapped = true;  
      end if;
    elseif st_geometrytype(target_geom) = 'ST_Polygon' then
      select  array_agg(ST_ExteriorRing(geom)) into rings from ST_DumpRings(target_geom);
      nr_elements = array_upper(rings,1);
      i = 1;
      while i <= nr_elements loop
        select t.* into rec from cadastre.snap_geometry_to_geometry(geom_to_snap, rings[i], snap_distance, change_target_if_needed) t;
        if rec.snapped then
          geom_to_snap = rec.geom_to_snap;
          snapped = true;
          if change_target_if_needed then
            rings[i] = rec.target_geom;
            target_geom = ST_MakePolygon(rings[1], rings[2:nr_elements]);
            target_is_changed = rec.target_is_changed;
            return;
          end if;
        end if;
        i = i+1;
      end loop;
    end if;
  elseif st_geometrytype(geom_to_snap) = 'ST_LineString' then
    nr_elements = st_npoints(geom_to_snap);
    i = 1;
    while i <= nr_elements loop
      select t.* into rec
        from cadastre.snap_geometry_to_geometry(st_pointn(geom_to_snap,i), target_geom, snap_distance, change_target_if_needed) t;
      if rec.snapped then
        if rec.target_is_changed then
          target_geom= rec.target_geom;
          target_is_changed = true;
        end if;
        geom_to_snap = st_setpoint(geom_to_snap, i-1, rec.geom_to_snap);
        snapped = true;
      end if;
      i = i+1;
    end loop;
    -- For each point of the target checks if it can snap to the geom_to_snap
    for rec in select * from ST_DumpPoints(target_geom) t 
      where st_dwithin(geom_to_snap, t.geom, snap_distance) loop
      select t.* into rec2
        from cadastre.snap_geometry_to_geometry(rec.geom, geom_to_snap, snap_distance, true) t;
      if rec2.target_is_changed then
        geom_to_snap = rec2.target_geom;
        snapped = true;
      end if;
    end loop;
  elseif st_geometrytype(geom_to_snap) = 'ST_Polygon' then
    select  array_agg(ST_ExteriorRing(geom)) into rings from ST_DumpRings(geom_to_snap);
    nr_elements = array_upper(rings,1);
    i = 1;
    while i <= nr_elements loop
      select t.* into rec
        from cadastre.snap_geometry_to_geometry(rings[i], target_geom, snap_distance, change_target_if_needed) t;
      if rec.snapped then
        rings[i] = rec.geom_to_snap;
        if rec.target_is_changed then
          target_geom = rec.target_geom;
          target_is_changed = true;
        end if;
        snapped = true;
      end if;
      i= i+1;
    end loop;
    if snapped then
      geom_to_snap = ST_MakePolygon(rings[1], rings[2:nr_elements]);
    end if;
  end if;
  return;
END;
$$;


ALTER FUNCTION cadastre.snap_geometry_to_geometry(INOUT geom_to_snap public.geometry, INOUT target_geom public.geometry, snap_distance double precision, change_target_if_needed boolean, OUT snapped boolean, OUT target_is_changed boolean) OWNER TO postgres;

--
-- Name: FUNCTION snap_geometry_to_geometry(INOUT geom_to_snap public.geometry, INOUT target_geom public.geometry, snap_distance double precision, change_target_if_needed boolean, OUT snapped boolean, OUT target_is_changed boolean); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION snap_geometry_to_geometry(INOUT geom_to_snap public.geometry, INOUT target_geom public.geometry, snap_distance double precision, change_target_if_needed boolean, OUT snapped boolean, OUT target_is_changed boolean) IS 'Snaps one geometry to the other adding points if required. Not used by SOLA.';


SET search_path = opentenure, pg_catalog;

--
-- Name: f_for_trg_set_default(); Type: FUNCTION; Schema: opentenure; Owner: postgres
--

CREATE FUNCTION f_for_trg_set_default() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN  
  IF (TG_WHEN = 'AFTER') THEN
    IF (TG_OP = 'UPDATE' OR TG_OP = 'INSERT') THEN
        IF (NEW.is_default) THEN
            UPDATE opentenure.form_template SET is_default = 'f' WHERE is_default = 't' AND name != NEW.name;
        ELSE
	    IF (TG_OP = 'UPDATE' AND (SELECT COUNT(1) FROM opentenure.form_template WHERE is_default = 't' AND name != OLD.name) < 1) THEN
	         UPDATE opentenure.form_template SET is_default = 't' WHERE name = OLD.name;
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
$$;


ALTER FUNCTION opentenure.f_for_trg_set_default() OWNER TO postgres;

--
-- Name: FUNCTION f_for_trg_set_default(); Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON FUNCTION f_for_trg_set_default() IS 'This function is to set default flag and have at least 1 form as default.';


SET search_path = party, pg_catalog;

--
-- Name: is_rightholder(character varying); Type: FUNCTION; Schema: party; Owner: postgres
--

CREATE FUNCTION is_rightholder(id character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
  return (SELECT (CASE (SELECT COUNT(1) FROM administrative.party_for_rrr ap WHERE ap.party_id = id) WHEN 0 THEN false ELSE true END));
END;
$$;


ALTER FUNCTION party.is_rightholder(id character varying) OWNER TO postgres;

--
-- Name: FUNCTION is_rightholder(id character varying); Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON FUNCTION is_rightholder(id character varying) IS 'Indicates if the party is associated to one or more land rights as a rightholder.';


SET search_path = source, pg_catalog;

--
-- Name: f_for_tbl_source_trg_change_of_status(); Type: FUNCTION; Schema: source; Owner: postgres
--

CREATE FUNCTION f_for_tbl_source_trg_change_of_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if old.status_code is not null and old.status_code = 'pending' and new.status_code in ( 'current', 'historic') then
      update source.source set 
      status_code= 'previous', change_user=new.change_user
      where la_nr= new.la_nr and status_code = 'current';
  end if;
  return new;
end;
$$;


ALTER FUNCTION source.f_for_tbl_source_trg_change_of_status() OWNER TO postgres;

--
-- Name: FUNCTION f_for_tbl_source_trg_change_of_status(); Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON FUNCTION f_for_tbl_source_trg_change_of_status() IS 'Function triggered on update of the source table that updates the status of any previous version of a source record to Previous when the new source record receives a Current or Historic status.';


SET search_path = system, pg_catalog;

--
-- Name: check_brs(character varying, character varying[]); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION check_brs(br_target character varying, conditions character varying[]) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
  log_entry_moment varchar;  
  rec record;
  br_rec record;
  condition varchar[];
  modified_body varchar;
  passed_criticals boolean default true;
  end_result varchar default '';
  new_line varchar default '
';
BEGIN
  
  for rec in select br_v.id as id, br_v.severity_code, br.display_name as name, br.feedback, br_d.body as body
      from system.br_validation br_v
        inner join system.br on br_v.br_id = br.id
        inner join system.br_definition br_d on br.id = br_d.br_id and now() between br_d.active_from and br_d.active_until
      where br_v.target_code = br_target
      order by br_v.order_of_execution
  loop
    modified_body = rec.body;
    -- Replace parameters in the body
    if conditions is not null then
      foreach condition slice 1 in array conditions loop
        modified_body = replace(modified_body, '#{' || condition[1] || '}', quote_nullable(condition[2]));
      end loop;
    end if;
    -- Call the br
    for br_rec in execute modified_body loop
      if not br_rec.vl and rec.severity_code='critical' then
        passed_criticals = false;
      end if;
      end_result = end_result 
       || '    BR:' || rec.feedback
       || '    Severity:' || rec.severity_code 
       || '    Passed:' || case when br_rec.vl then 'Yes' else 'No' end 
       || new_line;
    end loop;
  end loop;
  
  return passed_criticals || '####' || end_result;
END;
$$;


ALTER FUNCTION system.check_brs(br_target character varying, conditions character varying[]) OWNER TO postgres;

--
-- Name: FUNCTION check_brs(br_target character varying, conditions character varying[]); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION check_brs(br_target character varying, conditions character varying[]) IS 'It checks the business rules. If one critical br is violated, it returns the result starting with false#### otherwise it starts with true####';


--
-- Name: consolidation_consolidate(character varying, character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION consolidation_consolidate(admin_user character varying, process_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  table_rec record;
  consolidation_schema varchar default 'consolidation';
  cols varchar;
  exception_text_msg varchar;
  br_validation_result varchar;
  steps_max integer;
BEGIN

  steps_max = (select count(*) + 4 + 1 from system.consolidation_config);

  -- Create progress
  execute system.process_progress_start(process_name, steps_max);

  BEGIN -- TRANSACTION TO CATCH EXCEPTION
    -- Checking business rules
    execute system.process_log_update('Validating consolidation schema against the other tables...');
    br_validation_result = system.check_brs('consolidation', null);  
    if br_validation_result like 'false####%' then
      execute system.process_log_update(substring(br_validation_result, 10));
      raise exception 'Validation failed!';
    else
      execute system.process_log_update(substring(br_validation_result, 9));
      execute system.process_log_update('Validation finished with success.');
    end if;
    execute system.process_log_update('Making the system not accessible for the users...');
    -- Make sola not accessible from all other users except the user running the consolidation.
    update system.appuser set active = false where id != admin_user;
    execute system.process_log_update('done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

    -- Disable triggers.
    execute system.process_log_update('disabling all triggers...');
    perform fn_triggerall(false);
    execute system.process_log_update('done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

    execute system.process_log_update('Move records from temporary consolidation schema to main tables.');
    -- For each table that is extracted and that has rows, insert the records into the main tables.
    for table_rec in select * from consolidation.config order by order_of_execution loop

      execute system.process_log_update('  - source table: "' || table_rec.source_table_name || '" destination table: "' || table_rec.target_table_name || '"... ');

      if table_rec.remove_before_insert then
        execute system.process_log_update('      deleting matching records in target table ...');
        execute 'delete from ' || table_rec.target_table_name ||
        ' where rowidentifier in (select rowidentifier from ' || table_rec.source_table_name || ')';
        execute system.process_log_update('      done');
      end if;
      cols = (select string_agg(column_name, ',')
        from information_schema.columns
        where table_schema || '.' || table_name = table_rec.target_table_name);

      execute system.process_log_update('      inserting records to target table ...');
      execute 'insert into ' || table_rec.target_table_name || '(' || cols || ') select ' || cols || ' from ' || table_rec.source_table_name;
      execute system.process_log_update('      done');
      execute system.process_log_update('  done');
      execute system.process_progress_set(process_name, system.process_progress_get(process_name)+2);
    
    end loop;
  
    -- Enable triggers.
    execute system.process_log_update('enabling all triggers...');
    perform fn_triggerall(true);
    execute system.process_log_update('done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

    -- Make sola accessible for all users.
    execute system.process_log_update('Making the system accessible for the users...');
    update system.appuser set active = true where id != admin_user;
    execute system.process_log_update('done');
    execute system.process_log_update('Finished with success!');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS exception_text_msg = MESSAGE_TEXT;  
    execute system.process_log_update('Consolidation failed. Reason: ' || exception_text_msg);
    RAISE;
  END;
END;
$$;


ALTER FUNCTION system.consolidation_consolidate(admin_user character varying, process_name character varying) OWNER TO postgres;

--
-- Name: FUNCTION consolidation_consolidate(admin_user character varying, process_name character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION consolidation_consolidate(admin_user character varying, process_name character varying) IS 'Moves records from the temporary consolidation schema into the main SOLA tables. Used by the bulk consolidation process.';


--
-- Name: consolidation_extract(character varying, boolean, character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION consolidation_extract(admin_user character varying, everything boolean, process_name character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
DECLARE
  table_rec record;
  consolidation_schema varchar default 'consolidation';
  sql_to_run varchar;
  order_of_exec int;
  steps_max integer;
BEGIN

  steps_max = (select (count(*) * 3) + 7 + 1 from system.consolidation_config);

  -- Create progress
  execute system.process_progress_start(process_name, steps_max);
  
  -- Prepare the process log
  execute system.process_log_update('Extraction process started.');
  if everything then
    execute system.process_log_update('Everything has to be extracted.');
  end if;
  execute system.process_log_update('');

  -- Make sola not accessible from all other users except the user running the consolidation.
  execute system.process_log_update('Making the system not accessible for the users...');
  update system.appuser set active = false where id != admin_user;
  execute system.process_log_update('done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  -- If everything is true it means all applications that have not a service 'recordTransfer' will get one.
  if everything then
    execute system.process_log_update('Marking the applications that are not yet marked for transfer...');
    update application.application set action_code = 'transfer', status_code='to-be-transferred' 
    where status_code not in ('to-be-transferred', 'transferred');
    execute system.process_log_update('done');    
  end if;
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  
  -- Drop schema consolidation if exists.
  execute system.process_log_update('Dropping schema consolidation...');
  execute 'DROP SCHEMA IF EXISTS ' || consolidation_schema || ' CASCADE;';    
  execute system.process_log_update('done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
      
  -- Make the schema.
  execute system.process_log_update('Creating schema consolidation...');
  execute 'CREATE SCHEMA ' || consolidation_schema || ';';
  execute system.process_log_update('done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  --Make table to define configuration for the the consolidation to the target database.
  execute system.process_log_update('Creating consolidation.config table...');
  execute 'create table ' || consolidation_schema || '.config (
    source_table_name varchar(100),
    target_table_name varchar(100),
    remove_before_insert boolean,
    order_of_execution int,
    status varchar(500)
  )';
  execute system.process_log_update('done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  execute system.process_log_update('Move records from main tables to consolidation schema.');
  order_of_exec = 1;
  for table_rec in select * from system.consolidation_config order by order_of_execution loop

    execute system.process_log_update('  - Table: ' || table_rec.schema_name || '.' || table_rec.table_name);
    -- Make the script to move the data to the consolidation schema.
    sql_to_run = 'create table ' || consolidation_schema || '.' || table_rec.table_name 
      || ' as select * from ' ||  table_rec.schema_name || '.' || table_rec.table_name
      || ' where rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=$1)';

    -- Add the condition to the end of the select statement if it is present
    if coalesce(table_rec.condition_sql, '') != '' then      
      sql_to_run = sql_to_run || ' and ' || table_rec.condition_sql;
    end if;

    -- Run the script
    execute system.process_log_update('      - move records...');
    execute sql_to_run using table_rec.schema_name || '.' || table_rec.table_name;
    execute system.process_log_update('      done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    
    -- Log extracted records
    if table_rec.log_in_extracted_rows then
      execute system.process_log_update('      - log extracted records...');
      execute 'insert into system.extracted_rows(table_name, rowidentifier)
        select $1, rowidentifier from ' || consolidation_schema || '.' || table_rec.table_name
        using table_rec.schema_name || '.' || table_rec.table_name;
      execute system.process_log_update('      done');
    end if;  
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    

    -- Make a record in the config table
    sql_to_run = 'insert into ' || consolidation_schema 
      || '.config(source_table_name, target_table_name, remove_before_insert, order_of_execution) values($1,$2,$3, $4)'; 
    execute system.process_log_update('      - update config table...');
    execute sql_to_run 
      using  consolidation_schema || '.' || table_rec.table_name, 
             table_rec.schema_name || '.' || table_rec.table_name, 
             table_rec.remove_before_insert,
             order_of_exec;
    execute system.process_log_update('      done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    order_of_exec = order_of_exec + 1;
  end loop;
  execute system.process_log_update('Done');


  -- Set the status of the applications that are in the consolidation schema to the previous status before they got the status
  -- to-be-transferred and unassign them.
  execute system.process_log_update('Set the status of the extracted applications to their previous status (before getting to be transferred status) and unassign them...');

  update consolidation.application set action_code = 'unAssign', assignee_id = null, assigned_datetime = null ,
    status_code = (select ah.status_code
      from application.application_historic ah
      where ah.id = application.id and ah.status_code not in ('to-be-transferred', 'transferred')
      order by ah.change_time desc limit 1);
  execute system.process_log_update('done');

  -- Set the status of the applications moved to consolidation schema to 'transferred' and unassign them.
  execute system.process_log_update('Unassign moved applications and set their status to ''transferred''...');
  update application.application set status_code='transferred', action_code = 'unAssign', assignee_id = null, assigned_datetime = null 
  where rowidentifier in (select rowidentifier from consolidation.application);
  execute system.process_log_update('done');

  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  -- Make sola accessible from all users.
  execute system.process_log_update('Making the system accessible for the users...');
  update system.appuser set active = true where id != admin_user;
  execute system.process_log_update('done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  -- return system.get_text_from_schema(consolidation_schema);
  return true;
END;
$_$;


ALTER FUNCTION system.consolidation_extract(admin_user character varying, everything boolean, process_name character varying) OWNER TO postgres;

--
-- Name: FUNCTION consolidation_extract(admin_user character varying, everything boolean, process_name character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION consolidation_extract(admin_user character varying, everything boolean, process_name character varying) IS 'Extracts the records from the database that are marked to be extracted.';


--
-- Name: get_already_consolidated_records(); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION get_already_consolidated_records(OUT result character varying, OUT records_found boolean) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare
  table_rec record;
  sql_st varchar;
  total_result varchar default '';
  table_result varchar;
  new_line varchar default '
';
BEGIN
  for table_rec 
    in select * from consolidation.config 
       where not remove_before_insert and target_table_name not like '%_historic' loop
    sql_st = 'select string_agg(rowidentifier, '','') from ' || table_rec.source_table_name 
      || ' where rowidentifier in (select rowidentifier from ' || table_rec.target_table_name || ')';
    execute sql_st into table_result;
    if table_result != '' then
      total_result = total_result || new_line || '  - table: ' || table_rec.target_table_name 
        || ' row ids:' || table_result;
    end if;
  end loop;
  if total_result != '' then
    total_result = 'Records already present in destination:' || total_result;
  end if;
  result = total_result;
  records_found = (total_result != '');
END;
$$;


ALTER FUNCTION system.get_already_consolidated_records(OUT result character varying, OUT records_found boolean) OWNER TO postgres;

--
-- Name: FUNCTION get_already_consolidated_records(OUT result character varying, OUT records_found boolean); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION get_already_consolidated_records(OUT result character varying, OUT records_found boolean) IS 'It retrieves the records that are already consolidated and being asked again for consolidation.';


--
-- Name: get_setting(character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION get_setting(setting_name character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
begin
  return (select vl from system.setting where name= setting_name);
end;
$$;


ALTER FUNCTION system.get_setting(setting_name character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_setting(setting_name character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION get_setting(setting_name character varying) IS 'Returns the value for a specified system setting.';


--
-- Name: process_log_update(character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION process_log_update(log_input character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
  log_entry_moment varchar;  
BEGIN
  log_entry_moment = to_char(clock_timestamp(), 'yyyy-MM-dd HH24:MI:ss.ms | ');
  raise notice '%', log_entry_moment || log_input;
END;
$$;


ALTER FUNCTION system.process_log_update(log_input character varying) OWNER TO postgres;

--
-- Name: FUNCTION process_log_update(log_input character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_log_update(log_input character varying) IS 'Updates the process log.';


--
-- Name: process_progress_get(character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION process_progress_get(process_id character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  sequence_prefix varchar default 'system.process_';
  vl double precision default 0;
BEGIN
  if (select count(1) from information_schema.sequences where sequence_schema || '.' || sequence_name = sequence_prefix || process_id)>0 then
    execute 'select last_value from ' || sequence_prefix || process_id into vl;
  end if;
  return vl;
END;
$$;


ALTER FUNCTION system.process_progress_get(process_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION process_progress_get(process_id character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_progress_get(process_id character varying) IS 'Gets the absolute value of the process progress.';


--
-- Name: process_progress_get_in_percentage(character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION process_progress_get_in_percentage(process_id character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  sequence_prefix varchar default 'system.process_';
  vl double precision default 1;
BEGIN
  if (select count(1) from information_schema.sequences where sequence_schema || '.' || sequence_name = sequence_prefix || process_id)>0 then
    execute 'select cast(100 * last_value::double precision/max_value::double precision as integer) from ' || sequence_prefix || process_id into vl;
  end if;
  return vl;
END;
$$;


ALTER FUNCTION system.process_progress_get_in_percentage(process_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION process_progress_get_in_percentage(process_id character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_progress_get_in_percentage(process_id character varying) IS 'Gets the value of the process progress in percentage.';


--
-- Name: process_progress_set(character varying, integer); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION process_progress_set(process_id character varying, progress_value integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  sequence_prefix varchar default 'system.process_';
  max_progress_value integer;
BEGIN
  if (select count(1) from information_schema.sequences where sequence_schema || '.' || sequence_name = sequence_prefix || process_id)=0 then
    return;
  end if;
  execute 'select max_value from ' || sequence_prefix || process_id into max_progress_value;
  if progress_value> max_progress_value then
    progress_value = max_progress_value;
  end if;
  perform setval(sequence_prefix || process_id, progress_value);
END;
$$;


ALTER FUNCTION system.process_progress_set(process_id character varying, progress_value integer) OWNER TO postgres;

--
-- Name: FUNCTION process_progress_set(process_id character varying, progress_value integer); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_progress_set(process_id character varying, progress_value integer) IS 'It sets a new value for the process progress.';


--
-- Name: process_progress_start(character varying, integer); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION process_progress_start(process_id character varying, max_value integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  sequence_prefix varchar default 'system.process_';
BEGIN
  execute system.process_progress_stop(process_id);
  execute 'CREATE SEQUENCE ' || sequence_prefix || process_id
   || ' INCREMENT 1 START 1 MINVALUE 1 MAXVALUE ' || max_value::varchar;   
END;
$$;


ALTER FUNCTION system.process_progress_start(process_id character varying, max_value integer) OWNER TO postgres;

--
-- Name: FUNCTION process_progress_start(process_id character varying, max_value integer); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_progress_start(process_id character varying, max_value integer) IS 'It starts a process progress counter.';


--
-- Name: process_progress_stop(character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION process_progress_stop(process_id character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  sequence_prefix varchar default 'system.process_';
BEGIN
  execute 'DROP SEQUENCE IF EXISTS ' || sequence_prefix || process_id;   
END;
$$;


ALTER FUNCTION system.process_progress_stop(process_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION process_progress_stop(process_id character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_progress_stop(process_id character varying) IS 'It stops a process progress counter.';


--
-- Name: setpassword(character varying, character varying, character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION setpassword(usrname character varying, pass character varying, changeuser character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  result int;
BEGIN
  update system.appuser set passwd = pass,
   change_user = changeuser  where username=usrName;
  GET DIAGNOSTICS result = ROW_COUNT;
  return result;
END;
$$;


ALTER FUNCTION system.setpassword(usrname character varying, pass character varying, changeuser character varying) OWNER TO postgres;

--
-- Name: FUNCTION setpassword(usrname character varying, pass character varying, changeuser character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION setpassword(usrname character varying, pass character varying, changeuser character varying) IS 'Changes the users password.';


SET search_path = address, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: address; Type: TABLE; Schema: address; Owner: postgres; Tablespace: 
--

CREATE TABLE address (
    id character varying(40) NOT NULL,
    description character varying(255),
    ext_address_id character varying(40),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE address.address OWNER TO postgres;

--
-- Name: TABLE address; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON TABLE address IS 'Describes a postal or physical address.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN address.id; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.id IS 'Address identifier.';


--
-- Name: COLUMN address.description; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.description IS 'The postal or physical address or if no formal addressing is used, a description or place name for the location.';


--
-- Name: COLUMN address.ext_address_id; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.ext_address_id IS 'Optional identifier for the address that may reference further address details from an external system (e.g. address validation database).';


--
-- Name: COLUMN address.rowidentifier; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.rowidentifier IS 'Identifies the all change records for the row in the address_historic table';


--
-- Name: COLUMN address.rowversion; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN address.change_action; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN address.change_user; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN address.change_time; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.change_time IS 'The date and time the row was last modified.';


--
-- Name: address_historic; Type: TABLE; Schema: address; Owner: postgres; Tablespace: 
--

CREATE TABLE address_historic (
    id character varying(40),
    description character varying(255),
    ext_address_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE address.address_historic OWNER TO postgres;

SET search_path = administrative, pg_catalog;

--
-- Name: ba_unit; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit (
    id character varying(40) NOT NULL,
    type_code character varying(20) DEFAULT 'basicPropertyUnit'::character varying NOT NULL,
    name character varying(255),
    name_firstpart character varying(20) NOT NULL,
    name_lastpart character varying(50) NOT NULL,
    creation_date timestamp without time zone,
    expiration_date timestamp without time zone,
    status_code character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    transaction_id character varying(40),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20)
);


ALTER TABLE administrative.ba_unit OWNER TO postgres;

--
-- Name: TABLE ba_unit; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit IS 'A Basic Administrative Unit a.k.a. BA Unit or Property. Used to link the rights and restrictions over one or more parcels to the parties that hold those rights and restrictions. A right must be homogeneous over the entire BA Unit. Implementation of the LADM LA_BAUnit class.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN ba_unit.id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.id IS 'LADM Definition: Identifier for the BA Unit.';


--
-- Name: COLUMN ba_unit.type_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.type_code IS 'LADM Definition: The type of BA Unit. E.g. basicPropertyUnit, administrativeUnit, etc.';


--
-- Name: COLUMN ba_unit.name; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.name IS 'LADM Definition: The name of the BA Unit. Usually a concatenation of the name_firstpart and name_lastpart formatted as required.';


--
-- Name: COLUMN ba_unit.name_firstpart; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.name_firstpart IS 'SOLA Extension: The first part of the name or reference assigned by the land administration agency to identify the property.';


--
-- Name: COLUMN ba_unit.name_lastpart; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.name_lastpart IS 'SOLA Extension: The remaining part of the name or reference assigned by the land administration agency to identify the property.';


--
-- Name: COLUMN ba_unit.creation_date; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.creation_date IS 'SOLA Extension: The datetime the BA Unit is formally recognised by the land administration agency (i.e. registered or issued).';


--
-- Name: COLUMN ba_unit.expiration_date; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.expiration_date IS 'SOLA Extension: The datetime the BA Unit was superseded and became historic.';


--
-- Name: COLUMN ba_unit.status_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.status_code IS 'LADM Definition: The status of the BA unit.';


--
-- Name: COLUMN ba_unit.transaction_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.transaction_id IS 'SOLA Extension: Reference to the SOLA transaction that created the BA Unit.';


--
-- Name: COLUMN ba_unit.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the ba_unit_as_party table';


--
-- Name: COLUMN ba_unit.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN ba_unit.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN ba_unit.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN ba_unit.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: COLUMN ba_unit.classification_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this Ba Unit. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';


--
-- Name: COLUMN ba_unit.redact_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this Ba Unit. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';


--
-- Name: ba_unit_area; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_area (
    id character varying(40) NOT NULL,
    ba_unit_id character varying(40) NOT NULL,
    type_code character varying(20) NOT NULL,
    size numeric(19,2) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_area OWNER TO postgres;

--
-- Name: TABLE ba_unit_area; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit_area IS 'Identifies the overall area of the BA Unit. This should be the sum of all parcel areas that are part of the BA Unit.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN ba_unit_area.id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.id IS 'Identifier for the BA Unit Area.';


--
-- Name: COLUMN ba_unit_area.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.ba_unit_id IS 'Identifier for the BA Unit this area value is associated to.';


--
-- Name: COLUMN ba_unit_area.type_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.type_code IS 'The type of area. E.g. officialArea, calculatedArea, etc.';


--
-- Name: COLUMN ba_unit_area.size; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.size IS 'The value of the area. Must be in metres squared and can be converted for display if requried.';


--
-- Name: COLUMN ba_unit_area.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.rowidentifier IS 'Identifies the all change records for the row in the ba_unit_area_historic table';


--
-- Name: COLUMN ba_unit_area.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN ba_unit_area.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN ba_unit_area.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN ba_unit_area.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.change_time IS 'The date and time the row was last modified.';


--
-- Name: ba_unit_area_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_area_historic (
    id character varying(40),
    ba_unit_id character varying(40),
    type_code character varying(20),
    size numeric(19,2),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_area_historic OWNER TO postgres;

--
-- Name: ba_unit_as_party; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_as_party (
    ba_unit_id character varying(40) NOT NULL,
    party_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL
);


ALTER TABLE administrative.ba_unit_as_party OWNER TO postgres;

--
-- Name: TABLE ba_unit_as_party; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit_as_party IS 'Associates BA Unit directly to Party. Implementation of the LADM LA_BAUnit to LA_Party relationship. Not used by SOLA.
Tags: LADM Reference Object, Not Used';


--
-- Name: COLUMN ba_unit_as_party.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_as_party.ba_unit_id IS 'Identifier for the BA Unit.';


--
-- Name: COLUMN ba_unit_as_party.party_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_as_party.party_id IS 'Identifier for the Party.';


--
-- Name: COLUMN ba_unit_as_party.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_as_party.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the ba_unit_as_party table';


--
-- Name: ba_unit_contains_spatial_unit; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_contains_spatial_unit (
    ba_unit_id character varying(40) NOT NULL,
    spatial_unit_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_contains_spatial_unit OWNER TO postgres;

--
-- Name: TABLE ba_unit_contains_spatial_unit; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit_contains_spatial_unit IS 'Associates BA Unit with Spatial Unit. Indicates the parcels that comprise the BA Unit. Implementation of the LA_BAUnit to LA_SpatialUnit relationship.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.ba_unit_id IS 'Identifier for the BA Unit.';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.spatial_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.spatial_unit_id IS 'Identifier for the Spatial Unit associated to the BA Unit.';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.rowidentifier IS 'Identifies the all change records for the row in the ba_unit_contains_spatial_unit_historic table';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.change_time IS 'The date and time the row was last modified.';


--
-- Name: ba_unit_contains_spatial_unit_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_contains_spatial_unit_historic (
    ba_unit_id character varying(40),
    spatial_unit_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_contains_spatial_unit_historic OWNER TO postgres;

--
-- Name: ba_unit_first_name_part_seq; Type: SEQUENCE; Schema: administrative; Owner: postgres
--

CREATE SEQUENCE ba_unit_first_name_part_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999
    CACHE 1
    CYCLE;


ALTER TABLE administrative.ba_unit_first_name_part_seq OWNER TO postgres;

--
-- Name: SEQUENCE ba_unit_first_name_part_seq; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON SEQUENCE ba_unit_first_name_part_seq IS 'Sequence number used as the basis for the BA Unit first name part. This sequence is used by the generate-baunit-nr business rule.';


--
-- Name: ba_unit_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_historic (
    id character varying(40),
    type_code character varying(20),
    name character varying(255),
    name_firstpart character varying(20),
    name_lastpart character varying(50),
    creation_date timestamp without time zone,
    expiration_date timestamp without time zone,
    status_code character varying(20),
    transaction_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20)
);


ALTER TABLE administrative.ba_unit_historic OWNER TO postgres;

--
-- Name: ba_unit_last_name_part_seq; Type: SEQUENCE; Schema: administrative; Owner: postgres
--

CREATE SEQUENCE ba_unit_last_name_part_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999
    CACHE 1
    CYCLE;


ALTER TABLE administrative.ba_unit_last_name_part_seq OWNER TO postgres;

--
-- Name: SEQUENCE ba_unit_last_name_part_seq; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON SEQUENCE ba_unit_last_name_part_seq IS 'Sequence number used as the basis for the BA Unit last name part. This sequence is used by the generate-baunit-nr business rule.';


--
-- Name: ba_unit_rel_type; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_rel_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) NOT NULL
);


ALTER TABLE administrative.ba_unit_rel_type OWNER TO postgres;

--
-- Name: TABLE ba_unit_rel_type; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit_rel_type IS 'Code list of BA Unit relationship types. Identifies the type of relationship between two BA Units. E.g. priorTitle, rootTitle, etc. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN ba_unit_rel_type.code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_rel_type.code IS 'The code for the relationship type.';


--
-- Name: COLUMN ba_unit_rel_type.display_value; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_rel_type.display_value IS 'Displayed value of the relationship type.';


--
-- Name: COLUMN ba_unit_rel_type.description; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_rel_type.description IS 'Description of the relationship type.';


--
-- Name: COLUMN ba_unit_rel_type.status; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_rel_type.status IS 'Status of the relationship type.';


--
-- Name: ba_unit_target; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_target (
    ba_unit_id character varying(40) NOT NULL,
    transaction_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_target OWNER TO postgres;

--
-- Name: TABLE ba_unit_target; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit_target IS 'Identifies existing BA Units that are included in a transaction. Used by SOLA to mark existing BA Units for cancellation when the transaction is approved. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN ba_unit_target.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.ba_unit_id IS 'Identifier for the BA Unit.';


--
-- Name: COLUMN ba_unit_target.transaction_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.transaction_id IS 'Identifier for the transaction to cancel the BA Unit.';


--
-- Name: COLUMN ba_unit_target.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.rowidentifier IS 'Identifies the all change records for the row in the ba_unit_target_historic table';


--
-- Name: COLUMN ba_unit_target.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN ba_unit_target.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN ba_unit_target.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN ba_unit_target.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.change_time IS 'The date and time the row was last modified.';


--
-- Name: ba_unit_target_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_target_historic (
    ba_unit_id character varying(40),
    transaction_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_target_historic OWNER TO postgres;

--
-- Name: ba_unit_type; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE administrative.ba_unit_type OWNER TO postgres;

--
-- Name: TABLE ba_unit_type; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit_type IS 'Code list of BA Unit types. E.g. priorTitle, rootTitle, etc. Implementation of the LADM LA_BAUnitType class.
Tags: LADM Reference Object, Reference Table';


--
-- Name: COLUMN ba_unit_type.code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_type.code IS 'LADM Defintion: The code for the BA Unit type.';


--
-- Name: COLUMN ba_unit_type.display_value; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_type.display_value IS 'LADM Defintion: Displayed value of the BA Unit type.';


--
-- Name: COLUMN ba_unit_type.description; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_type.description IS 'LADM Defintion: Description of the BA Unit type.';


--
-- Name: COLUMN ba_unit_type.status; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_type.status IS 'SOLA Extension: Status of the BA Unit type.';


--
-- Name: condition_for_rrr; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE condition_for_rrr (
    id character varying(40) NOT NULL,
    rrr_id character varying(40) NOT NULL,
    condition_code character varying(20),
    custom_condition_text character varying(500),
    condition_quantity integer,
    condition_unit character varying(15),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.condition_for_rrr OWNER TO postgres;

--
-- Name: TABLE condition_for_rrr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE condition_for_rrr IS 'Captures any statutory or agreed conditions in relation to an RRR. E.g. conditions of lease, etc. An RRR can have multiple conditions associated to it.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN condition_for_rrr.id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_for_rrr.id IS 'Identifier for the condition.';


--
-- Name: COLUMN condition_for_rrr.rrr_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_for_rrr.rrr_id IS 'Identifier of the RRR the condition relates to.';


--
-- Name: COLUMN condition_for_rrr.condition_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_for_rrr.condition_code IS 'The type of condition.';


--
-- Name: COLUMN condition_for_rrr.custom_condition_text; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_for_rrr.custom_condition_text IS 'User entered text describing the condition and/or updated or revised text obtained from the template condition text.';


--
-- Name: COLUMN condition_for_rrr.condition_quantity; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_for_rrr.condition_quantity IS 'A quantity value associted to the condition.';


--
-- Name: COLUMN condition_for_rrr.condition_unit; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_for_rrr.condition_unit IS 'The unit of measure applicable for the condition quantity.';


--
-- Name: COLUMN condition_for_rrr.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_for_rrr.rowidentifier IS 'Identifies the all change records for the row in the condition_for_rrr_historic table';


--
-- Name: COLUMN condition_for_rrr.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_for_rrr.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN condition_for_rrr.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_for_rrr.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN condition_for_rrr.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_for_rrr.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN condition_for_rrr.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_for_rrr.change_time IS 'The date and time the row was last modified.';


--
-- Name: condition_for_rrr_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE condition_for_rrr_historic (
    id character varying(40),
    rrr_id character varying(40),
    condition_code character varying(20),
    custom_condition_text character varying(500),
    condition_quantity integer,
    condition_unit character varying(15),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.condition_for_rrr_historic OWNER TO postgres;

--
-- Name: condition_type; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE condition_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(10000) NOT NULL,
    status character(1) NOT NULL
);


ALTER TABLE administrative.condition_type OWNER TO postgres;

--
-- Name: TABLE condition_type; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE condition_type IS 'Code list of condition types. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN condition_type.code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_type.code IS 'The code for the condition type.';


--
-- Name: COLUMN condition_type.display_value; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_type.display_value IS 'Displayed value of the condition type.';


--
-- Name: COLUMN condition_type.description; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_type.description IS 'The template text describing the condition.';


--
-- Name: COLUMN condition_type.status; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN condition_type.status IS 'Status of the condition type.';


--
-- Name: mortgage_isbased_in_rrr; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE mortgage_isbased_in_rrr (
    mortgage_id character varying(40) NOT NULL,
    rrr_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.mortgage_isbased_in_rrr OWNER TO postgres;

--
-- Name: TABLE mortgage_isbased_in_rrr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE mortgage_isbased_in_rrr IS 'Identifies RRR that is subject to mortgage. Implementation of the LA_Mortgage to LA_Right relationship. Not used by SOLA as the primary right will always be the subject of the mortgage.
Tags: LADM Reference Object, Change History, Not Used';


--
-- Name: COLUMN mortgage_isbased_in_rrr.mortgage_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.mortgage_id IS 'Identifier for the mortgage';


--
-- Name: COLUMN mortgage_isbased_in_rrr.rrr_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.rrr_id IS 'Identifier for the RRR associated to the mortgage.';


--
-- Name: COLUMN mortgage_isbased_in_rrr.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.rowidentifier IS 'Identifies the all change records for the row in the ba_unit_contains_spatial_unit_historic table';


--
-- Name: COLUMN mortgage_isbased_in_rrr.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN mortgage_isbased_in_rrr.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN mortgage_isbased_in_rrr.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN mortgage_isbased_in_rrr.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.change_time IS 'The date and time the row was last modified.';


--
-- Name: mortgage_isbased_in_rrr_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE mortgage_isbased_in_rrr_historic (
    mortgage_id character varying(40),
    rrr_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.mortgage_isbased_in_rrr_historic OWNER TO postgres;

--
-- Name: mortgage_type; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE mortgage_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) NOT NULL
);


ALTER TABLE administrative.mortgage_type OWNER TO postgres;

--
-- Name: TABLE mortgage_type; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE mortgage_type IS 'Code list of Mortgage types. E.g. levelPayment, linear, etc. Implementation of the LADM LA_MortgageType class.
Tags: LADM Reference Object, Reference Table';


--
-- Name: COLUMN mortgage_type.code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_type.code IS 'LADM Defintion: The code for the mortgage type.';


--
-- Name: COLUMN mortgage_type.display_value; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_type.display_value IS 'LADM Defintion: Displayed value of the mortgage type.';


--
-- Name: COLUMN mortgage_type.description; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_type.description IS 'LADM Defintion: Description of the mortgage type.';


--
-- Name: COLUMN mortgage_type.status; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_type.status IS 'SOLA Extension: Status of the mortgage type.';


--
-- Name: notation; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE notation (
    id character varying(40) NOT NULL,
    ba_unit_id character varying(40),
    rrr_id character varying(40),
    transaction_id character varying(40) NOT NULL,
    reference_nr character varying(15) NOT NULL,
    notation_text character varying(1000),
    notation_date timestamp without time zone,
    status_code character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20)
);


ALTER TABLE administrative.notation OWNER TO postgres;

--
-- Name: TABLE notation; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE notation IS 'Notations (a.k.a memorials) are text that summarise the affect a transaction has to a property/title. SOLA automatically creates template notations for every RRR change.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN notation.id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.id IS 'Identifier for the notation.';


--
-- Name: COLUMN notation.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.ba_unit_id IS 'Identifier of the BA Unit the notation is associated with. Only populated if the notation is linked directly to the BA Unit. NULL if the notation is associated with an RRR.';


--
-- Name: COLUMN notation.rrr_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.rrr_id IS 'Identifier of the RRR the notation is assocaited with. Must not be populated if ba_unit_id is populated.';


--
-- Name: COLUMN notation.transaction_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.transaction_id IS 'Identifier of the transaction that created the notation.';


--
-- Name: COLUMN notation.reference_nr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.reference_nr IS 'The notation reference number. Value determined using the generate-notation-reference-nr business rule.';


--
-- Name: COLUMN notation.notation_text; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.notation_text IS 'The text of the notation. Note that template notation text can be obtained from the request type (i.e. service) the notation has been created as part of.';


--
-- Name: COLUMN notation.notation_date; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.notation_date IS 'The date the notation is formalised/registered.';


--
-- Name: COLUMN notation.status_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.status_code IS 'The status of the notation.';


--
-- Name: COLUMN notation.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.rowidentifier IS 'Identifies the all change records for the row in the notation_historic table';


--
-- Name: COLUMN notation.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN notation.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN notation.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN notation.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN notation.classification_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this Notation. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';


--
-- Name: COLUMN notation.redact_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this Notation. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';


--
-- Name: notation_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE notation_historic (
    id character varying(40),
    ba_unit_id character varying(40),
    rrr_id character varying(40),
    transaction_id character varying(40),
    reference_nr character varying(15),
    notation_text character varying(1000),
    notation_date timestamp without time zone,
    status_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20)
);


ALTER TABLE administrative.notation_historic OWNER TO postgres;

--
-- Name: notation_reference_nr_seq; Type: SEQUENCE; Schema: administrative; Owner: postgres
--

CREATE SEQUENCE notation_reference_nr_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999
    CACHE 1
    CYCLE;


ALTER TABLE administrative.notation_reference_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE notation_reference_nr_seq; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON SEQUENCE notation_reference_nr_seq IS 'Sequence number used as the basis for the Notation Nr field. This sequence is used by the generate-notation-reference-nr business rule.';


--
-- Name: notifiable_party_for_baunit; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE notifiable_party_for_baunit (
    party_id character varying(40) NOT NULL,
    target_party_id character varying(40) NOT NULL,
    baunit_name character varying(40) NOT NULL,
    application_id character varying(40) NOT NULL,
    service_id character varying(40) NOT NULL,
    cancel_service_id character varying(40),
    status character varying(40) DEFAULT 'c'::character varying NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.notifiable_party_for_baunit OWNER TO postgres;

--
-- Name: TABLE notifiable_party_for_baunit; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE notifiable_party_for_baunit IS 'Parties to be informed about transaction on baunit.';


--
-- Name: notifiable_party_for_baunit_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE notifiable_party_for_baunit_historic (
    party_id character varying(40),
    target_party_id character varying(40),
    baunit_name character varying(40),
    application_id character varying(40),
    service_id character varying(40),
    cancel_service_id character varying(40),
    status character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.notifiable_party_for_baunit_historic OWNER TO postgres;

--
-- Name: party_for_rrr; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE party_for_rrr (
    rrr_id character varying(40) NOT NULL,
    party_id character varying(40) NOT NULL,
    share_id character varying(40),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.party_for_rrr OWNER TO postgres;

--
-- Name: TABLE party_for_rrr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE party_for_rrr IS 'Identifies the parties involved in each RRR. Also identifies the share each party has in the RRR if the RRR is subject to shared allocation.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN party_for_rrr.rrr_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.rrr_id IS 'Identifier for the RRR.';


--
-- Name: COLUMN party_for_rrr.party_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.party_id IS 'Identifier for the party associated to the RRR.';


--
-- Name: COLUMN party_for_rrr.share_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.share_id IS 'Identifier for the share the party has in the RRR. Not populated unless the RRR is subject to a shared allocation. E.g. Mortgage RRR does not have shares.';


--
-- Name: COLUMN party_for_rrr.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.rowidentifier IS 'Identifies the all change records for the row in the party_for_rrr_historic table';


--
-- Name: COLUMN party_for_rrr.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party_for_rrr.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party_for_rrr.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN party_for_rrr.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.change_time IS 'The date and time the row was last modified.';


--
-- Name: party_for_rrr_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE party_for_rrr_historic (
    rrr_id character varying(40),
    party_id character varying(40),
    share_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.party_for_rrr_historic OWNER TO postgres;

--
-- Name: required_relationship_baunit; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE required_relationship_baunit (
    from_ba_unit_id character varying(40) NOT NULL,
    to_ba_unit_id character varying(40) NOT NULL,
    relation_code character varying(20) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.required_relationship_baunit OWNER TO postgres;

--
-- Name: TABLE required_relationship_baunit; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE required_relationship_baunit IS 'Identifies relationships between BA Units. Implementation of the LADM LA_RequiredRelationshipBAUnit class. Used by SOLA to represent a range of relationships such as linking a new BA Unit to the BA Unit it supersedes (a.k.a Prior Title) as well as geographic relationships such as all property within a village, or all villages within a region or island, etc. 
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN required_relationship_baunit.from_ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.from_ba_unit_id IS 'The originating BA Unit (a.k.a. parent BA Unit). Usually a parent BA Unit will have multiple child BA Units associted to it. E.g. Island/region is the parent BA Unit for a town';


--
-- Name: COLUMN required_relationship_baunit.to_ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.to_ba_unit_id IS 'The target BA Unit (a.k.a. child BA Unit). For any given relationship type, the child BA Unit will usually only have one logical parent BA Unit. E.g. A new title is the child BA Unit of the original title that is being superseded.';


--
-- Name: COLUMN required_relationship_baunit.relation_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.relation_code IS 'Code that identifies the type of relationship between the two BA Units.';


--
-- Name: COLUMN required_relationship_baunit.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.rowidentifier IS 'Identifies the all change records for the row in the required_relationship_baunit_historic table';


--
-- Name: COLUMN required_relationship_baunit.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN required_relationship_baunit.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN required_relationship_baunit.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN required_relationship_baunit.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.change_time IS 'The date and time the row was last modified.';


--
-- Name: required_relationship_baunit_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE required_relationship_baunit_historic (
    from_ba_unit_id character varying(40),
    to_ba_unit_id character varying(40),
    relation_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.required_relationship_baunit_historic OWNER TO postgres;

--
-- Name: rrr; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE rrr (
    id character varying(40) NOT NULL,
    ba_unit_id character varying(40) NOT NULL,
    nr character varying(20) NOT NULL,
    type_code character varying(20) NOT NULL,
    status_code character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    transaction_id character varying(40) NOT NULL,
    registration_date timestamp without time zone,
    expiration_date timestamp without time zone,
    share double precision,
    amount numeric(29,2),
    due_date date,
    mortgage_interest_rate numeric(5,2),
    mortgage_ranking integer,
    mortgage_type_code character varying(20),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20)
);


ALTER TABLE administrative.rrr OWNER TO postgres;

--
-- Name: TABLE rrr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE rrr IS 'RRR are the specific rights, restrictions and responsibilities that can be registered on a property e.g. freehold ownership, lease, mortgage, caveat, etc. Implementation of the LADM LA_RRR class.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN rrr.id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.id IS 'LADM Definition: Identifier for the RRR';


--
-- Name: COLUMN rrr.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.ba_unit_id IS 'LADM Definition: Identifier for the BA Unit the RRR applies to.';


--
-- Name: COLUMN rrr.nr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.nr IS 'SOLA Extension: Number to identify the RRR. Determined by the generate-rrr-nr business rule. This value is used to track the different versions of the RRR as it is edited over time.';


--
-- Name: COLUMN rrr.type_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.type_code IS 'LADM Definition: The type of RRR. E.g. freehold ownership, lease, mortage, caveat, etc.';


--
-- Name: COLUMN rrr.status_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.status_code IS 'SOLA Extension: The status of the RRR.';


--
-- Name: COLUMN rrr.is_primary; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.is_primary IS 'SOLA Extension. Flag it indicate if the RRR is the primary RRR for the BA Unit. One one of the current RRRs on the BA Unit can be flagged as the primary RRR.';


--
-- Name: COLUMN rrr.transaction_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.transaction_id IS 'SOLA Extension: Identifier of the transaction that created the RRR.';


--
-- Name: COLUMN rrr.registration_date; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.registration_date IS 'SOLA Extension: The date and time the RRR was formally registered by the Land Administration Agency.';


--
-- Name: COLUMN rrr.expiration_date; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.expiration_date IS 'LADM Definition: The date and time defining when the RRR remains in force to. Implementation of the LADM LA_RRR.timespec field.';


--
-- Name: COLUMN rrr.share; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.share IS 'LADM Defintion: Share of the RRR expressed as a fraction with numerator and denominator. Not used by SOLA as shares in rights are represetned in the rrr_share table. This avoids having multiple RRR of the same type on the BA Unit that only differ by share amounts.';


--
-- Name: COLUMN rrr.amount; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.amount IS 'LADM Definition: The value of the mortgage. SOLA Extension: The amount associated with the RRR. E.g the value of the mortgage, the rental amount for a lease, etc.';


--
-- Name: COLUMN rrr.due_date; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.due_date IS 'SOLA Extension: The date of the next payment for the RRR. E.g. the lease rental due date.';


--
-- Name: COLUMN rrr.mortgage_interest_rate; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.mortgage_interest_rate IS 'LADM Definition: The interest rate of the mortgage as a percentage.';


--
-- Name: COLUMN rrr.mortgage_ranking; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.mortgage_ranking IS 'LADM Definition: The ranking order if more than one mortgage applies to the right.';


--
-- Name: COLUMN rrr.mortgage_type_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.mortgage_type_code IS 'LADM Definition: The type of mortgage.';


--
-- Name: COLUMN rrr.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the rrr_historic table';


--
-- Name: COLUMN rrr.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN rrr.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN rrr.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN rrr.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: COLUMN rrr.classification_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this RRR. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';


--
-- Name: COLUMN rrr.redact_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this RRR. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';


--
-- Name: rrr_group_type; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE rrr_group_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) NOT NULL
);


ALTER TABLE administrative.rrr_group_type OWNER TO postgres;

--
-- Name: TABLE rrr_group_type; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE rrr_group_type IS 'Code list of RRR group types. Used to identify if an RRR is a responsibility, right or restriction. SOLA''s representation of the LADM LA_Responsibility, LA_Right and LA_Restriction classes.
Tags: LADM Reference Object, Reference Table';


--
-- Name: COLUMN rrr_group_type.code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_group_type.code IS 'LADM Defintion: The code for the RRR group type.';


--
-- Name: COLUMN rrr_group_type.display_value; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_group_type.display_value IS 'LADM Defintion: Displayed value of the RRR group type.';


--
-- Name: COLUMN rrr_group_type.description; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_group_type.description IS 'LADM Defintion: Description of the RRR group type.';


--
-- Name: COLUMN rrr_group_type.status; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_group_type.status IS 'SOLA Extension: Status of the RRR group type.';


--
-- Name: rrr_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE rrr_historic (
    id character varying(40),
    ba_unit_id character varying(40),
    nr character varying(20),
    type_code character varying(20),
    status_code character varying(20),
    is_primary boolean,
    transaction_id character varying(40),
    registration_date timestamp without time zone,
    expiration_date timestamp without time zone,
    share double precision,
    amount numeric(29,2),
    due_date date,
    mortgage_interest_rate numeric(5,2),
    mortgage_ranking integer,
    mortgage_type_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20)
);


ALTER TABLE administrative.rrr_historic OWNER TO postgres;

--
-- Name: rrr_nr_seq; Type: SEQUENCE; Schema: administrative; Owner: postgres
--

CREATE SEQUENCE rrr_nr_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999
    CACHE 1
    CYCLE;


ALTER TABLE administrative.rrr_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE rrr_nr_seq; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON SEQUENCE rrr_nr_seq IS 'Sequence number used as the basis for the RRR Nr field. This sequence is used by the generate-rrr-nr business rule.';


--
-- Name: rrr_share; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE rrr_share (
    rrr_id character varying(40) NOT NULL,
    id character varying(40) NOT NULL,
    nominator smallint NOT NULL,
    denominator smallint NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.rrr_share OWNER TO postgres;

--
-- Name: TABLE rrr_share; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE rrr_share IS 'Identifies the share a party has in an RRR. Implementation of the LADM LA_RRR.share field.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN rrr_share.rrr_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.rrr_id IS 'Identifier of the RRR the share is assocaited with.';


--
-- Name: COLUMN rrr_share.id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.id IS 'Identifier for the RRR share.';


--
-- Name: COLUMN rrr_share.nominator; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.nominator IS 'Nominiator part of the share (i.e. top number of fraction)';


--
-- Name: COLUMN rrr_share.denominator; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.denominator IS 'Denominator part of the share (i.e. bottom number of fraction)';


--
-- Name: COLUMN rrr_share.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.rowidentifier IS 'Identifies the all change records for the row in the rrr_share_historic table';


--
-- Name: COLUMN rrr_share.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN rrr_share.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN rrr_share.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN rrr_share.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.change_time IS 'The date and time the row was last modified.';


--
-- Name: rrr_share_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE rrr_share_historic (
    rrr_id character varying(40),
    id character varying(40),
    nominator smallint,
    denominator smallint,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.rrr_share_historic OWNER TO postgres;

--
-- Name: rrr_type; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE rrr_type (
    code character varying(20) NOT NULL,
    rrr_group_type_code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    share_check boolean NOT NULL,
    party_required boolean NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    rrr_panel_code character varying(20)
);


ALTER TABLE administrative.rrr_type OWNER TO postgres;

--
-- Name: TABLE rrr_type; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE rrr_type IS 'Code list of RRR types. E.g. freehold owernship, lease, mortgage, caveat, etc. Implementation of the LADM LA_ResponsibilityType, LA_RightType and LA_RestrictionType classes.
Tags: LADM Reference Object, Reference Table';


--
-- Name: COLUMN rrr_type.code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.code IS 'LADM Defintion: The code for the RRR type.';


--
-- Name: COLUMN rrr_type.rrr_group_type_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.rrr_group_type_code IS 'LADM Defintion: Identifies if the RRR type is a right, restriction or a responsibility.';


--
-- Name: COLUMN rrr_type.display_value; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.display_value IS 'LADM Defintion: Displayed value of the RRR type.';


--
-- Name: COLUMN rrr_type.is_primary; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.is_primary IS 'SOLA Extension: Flag to indicate if the RRR type is a primary RRR.';


--
-- Name: COLUMN rrr_type.share_check; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.share_check IS 'LADM Defintion: Flag to indicate the that the sum of all shares for the RRR must be checked to ensure it equals 1.';


--
-- Name: COLUMN rrr_type.party_required; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.party_required IS 'LADM Defintion: Flag to indicate at least one party must be associated with this RRR.';


--
-- Name: COLUMN rrr_type.description; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.description IS 'LADM Defintion: Description of the RRR type.';


--
-- Name: COLUMN rrr_type.status; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.status IS 'SOLA Extension: Status of the RRR type.';


--
-- Name: COLUMN rrr_type.rrr_panel_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.rrr_panel_code IS 'SOLA Extension. Used to identify the SOLA panel class to display to the user when they view or edit the RRR.';


--
-- Name: source_describes_ba_unit; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE source_describes_ba_unit (
    source_id character varying(40) NOT NULL,
    ba_unit_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.source_describes_ba_unit OWNER TO postgres;

--
-- Name: TABLE source_describes_ba_unit; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE source_describes_ba_unit IS 'Associates a BA Unit with one or more source (a.k.a. document) records. Implementation of the LADM LA_BAUnit to LA_AdministrativeSource relationship.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN source_describes_ba_unit.source_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.source_id IS 'Identifier for the source associated with the BA Unit.';


--
-- Name: COLUMN source_describes_ba_unit.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.ba_unit_id IS 'Identifier for the BA Unit.';


--
-- Name: COLUMN source_describes_ba_unit.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.rowidentifier IS 'Identifies the all change records for the row in the source_describes_ba_unit_historic table';


--
-- Name: COLUMN source_describes_ba_unit.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN source_describes_ba_unit.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN source_describes_ba_unit.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN source_describes_ba_unit.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.change_time IS 'The date and time the row was last modified.';


--
-- Name: source_describes_ba_unit_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE source_describes_ba_unit_historic (
    source_id character varying(40),
    ba_unit_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.source_describes_ba_unit_historic OWNER TO postgres;

--
-- Name: source_describes_rrr; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE source_describes_rrr (
    rrr_id character varying(40) NOT NULL,
    source_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.source_describes_rrr OWNER TO postgres;

--
-- Name: TABLE source_describes_rrr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE source_describes_rrr IS 'Associates a RRR with one or more source (a.k.a. document) records. Implementation of the LADM LA_RRR to LA_AdministrativeSource relationship.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN source_describes_rrr.rrr_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.rrr_id IS 'Identifier for the RRR.';


--
-- Name: COLUMN source_describes_rrr.source_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.source_id IS 'Identifier for the source associated with the RRR.';


--
-- Name: COLUMN source_describes_rrr.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.rowidentifier IS 'Identifies the all change records for the row in the source_describes_ba_unit_historic table';


--
-- Name: COLUMN source_describes_rrr.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN source_describes_rrr.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN source_describes_rrr.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN source_describes_rrr.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.change_time IS 'The date and time the row was last modified.';


--
-- Name: source_describes_rrr_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE source_describes_rrr_historic (
    rrr_id character varying(40),
    source_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.source_describes_rrr_historic OWNER TO postgres;

SET search_path = application, pg_catalog;

--
-- Name: application; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application (
    id character varying(40) NOT NULL,
    nr character varying(15) NOT NULL,
    agent_id character varying(40),
    contact_person_id character varying(40) NOT NULL,
    lodging_datetime timestamp without time zone DEFAULT now() NOT NULL,
    expected_completion_date date DEFAULT now() NOT NULL,
    assignee_id character varying(40),
    assigned_datetime timestamp without time zone,
    location public.geometry,
    services_fee numeric(20,2) DEFAULT 0 NOT NULL,
    tax numeric(20,2) DEFAULT 0 NOT NULL,
    total_fee numeric(20,2) DEFAULT 0 NOT NULL,
    total_amount_paid numeric(20,2) DEFAULT 0 NOT NULL,
    fee_paid boolean DEFAULT false NOT NULL,
    action_code character varying(20) DEFAULT 'lodge'::character varying NOT NULL,
    action_notes character varying(255),
    status_code character varying(20) DEFAULT 'lodged'::character varying NOT NULL,
    receipt_reference character varying(100),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20),
    CONSTRAINT application_check_assigned CHECK ((((assignee_id IS NULL) AND (assigned_datetime IS NULL)) OR ((assignee_id IS NOT NULL) AND (assigned_datetime IS NOT NULL)))),
    CONSTRAINT enforce_dims_location CHECK ((public.st_ndims(location) = 2)),
    CONSTRAINT enforce_geotype_location CHECK (((public.geometrytype(location) = 'MULTIPOINT'::text) OR (location IS NULL))),
    CONSTRAINT enforce_srid_location CHECK ((public.st_srid(location) = 2193)),
    CONSTRAINT enforce_valid_location CHECK (public.st_isvalid(location))
);


ALTER TABLE application.application OWNER TO postgres;

--
-- Name: TABLE application; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE application IS 'Applications capture details and manage requests received by the land administration agency to change, update or report on land registry and/or cadastre information. Applications have a lifecycle and transition into different states as the land administration agency processes the request that instigated the application. The primary role of an application is to implement case management functionality in SOLA.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN application.id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.id IS 'Identifier for the application.';


--
-- Name: COLUMN application.nr; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.nr IS 'The application number displayed to end users. Generated by the generate-application-nr business rule when the application record is initially saved.';


--
-- Name: COLUMN application.agent_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.agent_id IS 'Identifier of the party (individual or organization) that is requesting information or changes to the land registry and/or cadastre information recorded in SOLA. This could be a lawyer or surveyor under instruction from the property owner, the property owner themselves or a third party with a vested interest in a particular property.';


--
-- Name: COLUMN application.contact_person_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.contact_person_id IS 'The person to contact in regard to the application. This person is considered the applicant.';


--
-- Name: COLUMN application.lodging_datetime; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.lodging_datetime IS 'The lodging date and time of the application. This date identifies when the application is officially accepted by the land administration agency.';


--
-- Name: COLUMN application.expected_completion_date; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.expected_completion_date IS 'The date the application should be completed by. This value is determined from the maximum service expected completion date associated with the application.';


--
-- Name: COLUMN application.assignee_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.assignee_id IS 'The identifier of the user assigned to the application. If this value is null, then the application is unassigned.';


--
-- Name: COLUMN application.assigned_datetime; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.assigned_datetime IS 'The date and time the application was last assigned to a user.';


--
-- Name: COLUMN application.location; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.location IS 'The approximate geographic location of the application. The user may indicate more than one point if the application affects a large number of parcels.';


--
-- Name: COLUMN application.services_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.services_fee IS 'The sum of all service fees.';


--
-- Name: COLUMN application.tax; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.tax IS 'The tax applicable based on the services fee.';


--
-- Name: COLUMN application.total_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.total_fee IS 'The sum of the services_fee and tax.';


--
-- Name: COLUMN application.total_amount_paid; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.total_amount_paid IS 'The amount paid by the applicant. Usually will be the full amount (total_fee), but can be a partial payment if the land administration agency accepts partial payments.';


--
-- Name: COLUMN application.fee_paid; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.fee_paid IS 'Flag to indicate a sufficient amount (or all) of the fee has been paid. Once set, the application can be assigned and worked on.';


--
-- Name: COLUMN application.action_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.action_code IS 'The last action that happended to the application. E.g. lodged, assigned, validated, approved, etc.';


--
-- Name: COLUMN application.action_notes; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.action_notes IS 'Optional description of the action.';


--
-- Name: COLUMN application.status_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.status_code IS 'The status of the application.';


--
-- Name: COLUMN application.receipt_reference; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.receipt_reference IS 'The number of the receipt issued as proof of payment. If more than one receipt is issued in the case of part payments, the receipts numbers can be listed in this feild separated by commas.';


--
-- Name: COLUMN application.rowidentifier; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.rowidentifier IS 'Identifies the all change records for the row in the application_historic table';


--
-- Name: COLUMN application.rowversion; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN application.change_action; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN application.change_user; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN application.change_time; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN application.classification_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this Application/Job. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';


--
-- Name: COLUMN application.redact_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this Application/Job. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';


--
-- Name: service; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE service (
    id character varying(40) NOT NULL,
    application_id character varying(40),
    request_type_code character varying(20) NOT NULL,
    service_order integer DEFAULT 0 NOT NULL,
    lodging_datetime timestamp without time zone DEFAULT now() NOT NULL,
    expected_completion_date date NOT NULL,
    status_code character varying(20) DEFAULT 'lodged'::character varying NOT NULL,
    action_code character varying(20) DEFAULT 'lodge'::character varying NOT NULL,
    action_notes character varying(255),
    base_fee numeric(20,2) DEFAULT 0 NOT NULL,
    area_fee numeric(20,2) DEFAULT 0 NOT NULL,
    value_fee numeric(20,2) DEFAULT 0 NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.service OWNER TO postgres;

--
-- Name: TABLE service; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE service IS 'Used to control the type of change an application can make to the land registry and/or cadastre information recorded in SOLA. Services broadly identify the actions the land administration agency will undertake for the application. Every application lodged in SOLA must include at least one service. SOLA includes a default set of request types that can be reconfigured to match those services required by the land administration agency.  
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN service.id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.id IS 'Identifier for the service.';


--
-- Name: COLUMN service.application_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.application_id IS 'Identifier for the application the service is associated with.';


--
-- Name: COLUMN service.request_type_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.request_type_code IS 'The request type identifying the purpose of the service.';


--
-- Name: COLUMN service.service_order; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.service_order IS 'The relative order of the service within the application. Can be used to imply a workflow sequence for application related tasks.';


--
-- Name: COLUMN service.lodging_datetime; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.lodging_datetime IS 'The date the service was lodged on the application. Typically will match the application lodgement_datetime, but may vary if a service is added after the application is lodged.';


--
-- Name: COLUMN service.expected_completion_date; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.expected_completion_date IS 'Date when the service is expected to be completed by. Calculated using the service lodging_datetime and the nr_days_to_complete for the service request type.';


--
-- Name: COLUMN service.status_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.status_code IS 'Service status code.';


--
-- Name: COLUMN service.action_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.action_code IS 'Service action code. Indicates the last action to occur on the service. E.g. lodge, start, complete, cancel, etc.';


--
-- Name: COLUMN service.action_notes; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.action_notes IS 'Provides extra detail related to the last action to occur on the service. Not Used.';


--
-- Name: COLUMN service.base_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.base_fee IS 'The fixed fee charged for the service. Obtained from the base_fee value in request_type.';


--
-- Name: COLUMN service.area_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.area_fee IS 'The area fee charged for the service. Calculated from the sum of all areas listed for properties on the application multiplied by the request_type.area_base_fee.';


--
-- Name: COLUMN service.value_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.value_fee IS 'The value fee charged for the service. Calculated from the sum of all values listed for properties on the application multiplied by the request_type.value_base_fee.';


SET search_path = cadastre, pg_catalog;

--
-- Name: cadastre_object; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object (
    id character varying(40) NOT NULL,
    type_code character varying(20) DEFAULT 'parcel'::character varying NOT NULL,
    building_unit_type_code character varying(20),
    approval_datetime timestamp without time zone,
    historic_datetime timestamp without time zone,
    source_reference character varying(100),
    name_firstpart character varying(20) NOT NULL,
    name_lastpart character varying(50) NOT NULL,
    status_code character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    geom_polygon public.geometry,
    transaction_id character varying(40) NOT NULL,
    land_use_code character varying(255) DEFAULT 'residential'::character varying,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20),
    CONSTRAINT enforce_dims_geom_polygon CHECK ((public.st_ndims(geom_polygon) = 2)),
    CONSTRAINT enforce_geotype_geom_polygon CHECK (((public.geometrytype(geom_polygon) = 'POLYGON'::text) OR (geom_polygon IS NULL))),
    CONSTRAINT enforce_srid_geom_polygon CHECK ((public.st_srid(geom_polygon) = 2193)),
    CONSTRAINT enforce_valid_geom_polygon CHECK (public.st_isvalid(geom_polygon))
);


ALTER TABLE cadastre.cadastre_object OWNER TO postgres;

--
-- Name: TABLE cadastre_object; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE cadastre_object IS 'Specialization of Spatial Unit that represents primary cadastral features such as parcels. Parcels captured in SOLA should have a spatial definition that illustrates the shape and geographic location of the parcel although this is not a mandatory requirement. Parcels without a spatial definition may be referred to as aspatial or textual parcels.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN cadastre_object.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.id IS 'Identifier for the cadastre object.';


--
-- Name: COLUMN cadastre_object.type_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.type_code IS 'The type of cadastre object. E.g. parcel, building unit, etc.';


--
-- Name: COLUMN cadastre_object.building_unit_type_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.building_unit_type_code IS 'The building unit subtype if applicable. Not used by SOLA.';


--
-- Name: COLUMN cadastre_object.approval_datetime; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.approval_datetime IS 'The datetime the cadastre object was approved/registered.';


--
-- Name: COLUMN cadastre_object.historic_datetime; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.historic_datetime IS 'The datetime the cadastre object was superseded and became historic.';


--
-- Name: COLUMN cadastre_object.source_reference; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.source_reference IS 'Used to indicate the original source of the cadastre object. Can be a map reference or a reference to the system the geometry was migrated from.';


--
-- Name: COLUMN cadastre_object.name_firstpart; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.name_firstpart IS 'The first part of the name or reference assigned by the land administration agency to identify the cadastre object. E.g. lot number, etc';


--
-- Name: COLUMN cadastre_object.name_lastpart; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.name_lastpart IS 'The remaining part of the name or reference assigned by the land administration agency to identify the cadastre object. E.g. survey plan number, map number, section reference, etc.';


--
-- Name: COLUMN cadastre_object.status_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.status_code IS 'The status of the cadastre object.';


--
-- Name: COLUMN cadastre_object.geom_polygon; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.geom_polygon IS 'The PostGIS geometry for the cadastre object. Must be a ploygon. Multipolygon geometries are not currently supported by SOLA.';


--
-- Name: COLUMN cadastre_object.transaction_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.transaction_id IS 'Reference to the SOLA transaction that created the cadastre object.';


--
-- Name: COLUMN cadastre_object.land_use_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.land_use_code IS 'Code to indicate the general purpose of the cadastre object. E.g. Commerical, Residential, Industrial, etc.';


--
-- Name: COLUMN cadastre_object.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.rowidentifier IS 'Identifies the all change records for the row in the cadastre_object_historic table';


--
-- Name: COLUMN cadastre_object.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN cadastre_object.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN cadastre_object.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN cadastre_object.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN cadastre_object.classification_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this Parcel. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';


--
-- Name: COLUMN cadastre_object.redact_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this Parcel. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';


--
-- Name: land_use_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE land_use_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.land_use_type OWNER TO postgres;

--
-- Name: TABLE land_use_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE land_use_type IS 'Code list of land use types. Identifies the general purpose of a cadastre object or property. E.g. Commerical, Residential, Industrial, etc. Implementation of the LADM ExtLandUse class. 
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN land_use_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN land_use_type.code IS 'LADM Definition: The code for the land use type.';


--
-- Name: COLUMN land_use_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN land_use_type.display_value IS 'LADM Definition: Displayed value of the land use type.';


--
-- Name: COLUMN land_use_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN land_use_type.description IS 'LADM Definition: Description of the land use type.';


--
-- Name: COLUMN land_use_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN land_use_type.status IS 'SOLA Extension: Status of the land use type';


--
-- Name: spatial_value_area; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_value_area (
    spatial_unit_id character varying(40) NOT NULL,
    type_code character varying(20) NOT NULL,
    size numeric(29,2) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE cadastre.spatial_value_area OWNER TO postgres;

--
-- Name: TABLE spatial_value_area; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE spatial_value_area IS 'Identifies the area of a 2 dimensional spatial unit.
Implementation of the LADM LA_AreaValue class.  
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN spatial_value_area.spatial_unit_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.spatial_unit_id IS 'Spatial unit identifier.';


--
-- Name: COLUMN spatial_value_area.type_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.type_code IS 'The type of the spatial value area. E.g. officialArea, calculatedArea, etc.';


--
-- Name: COLUMN spatial_value_area.size; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.size IS 'The value of the area. Must be in metres squared and can be converted for display if requried.';


--
-- Name: COLUMN spatial_value_area.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.rowidentifier IS 'Identifies the all change records for the row in the spatial_value_area_historic table';


--
-- Name: COLUMN spatial_value_area.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_value_area.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_value_area.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_value_area.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.change_time IS 'The date and time the row was last modified.';


SET search_path = party, pg_catalog;

--
-- Name: party; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party (
    id character varying(40) NOT NULL,
    ext_id character varying(255),
    type_code character varying(20) NOT NULL,
    name character varying(255),
    last_name character varying(50),
    fathers_name character varying(50),
    fathers_last_name character varying(50),
    alias character varying(50),
    gender_code character varying(20),
    address_id character varying(40),
    id_type_code character varying(20),
    id_number character varying(20),
    email character varying(50),
    mobile character varying(15),
    phone character varying(15),
    fax character varying(15),
    preferred_communication_code character varying(20),
    birth_date date,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20),
    CONSTRAINT party_id_is_present CHECK ((((id_type_code IS NULL) AND (id_number IS NULL)) OR ((id_type_code IS NOT NULL) AND (id_number IS NOT NULL))))
);


ALTER TABLE party.party OWNER TO postgres;

--
-- Name: TABLE party; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE party IS 'An individual, group or organisation that is associated in some way with land office services. Implementation of the LADM LA_Party class.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN party.id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.id IS 'LADM Definition: Identifier for the party.';


--
-- Name: COLUMN party.ext_id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.ext_id IS 'SOLA Extension: An identifier for the party from some external system such as a customer relationship management (CRM) system.';


--
-- Name: COLUMN party.type_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.type_code IS 'LADM Definition: The type of the party. E.g. naturalPerson, nonNaturalPerson, etc.';


--
-- Name: COLUMN party.name; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.name IS 'LADM Definition: The first name(s) for the party or the group or organisation name.';


--
-- Name: COLUMN party.last_name; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.last_name IS 'SOLA Extension: The last name for the party or blank for groups and organisations.';


--
-- Name: COLUMN party.fathers_name; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.fathers_name IS 'SOLA Extension: The first name of the father for the party. Relevant where the fathers first name forms part of the name for the party.';


--
-- Name: COLUMN party.fathers_last_name; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.fathers_last_name IS 'SOLA Extension: The last name of the father for the party. Relevant where the fathers last name forms part of the name for the party.';


--
-- Name: COLUMN party.alias; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.alias IS 'SOLA Extension: Any alias for the party. A party can have more than one alias. If so, the aliases should be separated by a comma.';


--
-- Name: COLUMN party.gender_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.gender_code IS 'SOLA Extension: Identifies the gender for the party. If the party is of type naturalPerson then a gender code must be specified.';


--
-- Name: COLUMN party.address_id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.address_id IS 'SOLA Extension: Identifier for the contact address of the party.';


--
-- Name: COLUMN party.id_type_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.id_type_code IS 'SOLA Extension: Used to indicate the type of id used to verify the identity of the party.';


--
-- Name: COLUMN party.id_number; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.id_number IS 'SOLA Extension: The number from the id used to verify the identity of the party.';


--
-- Name: COLUMN party.email; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.email IS 'SOLA Extension: The party''s contact email address.';


--
-- Name: COLUMN party.mobile; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.mobile IS 'SOLA Extension: The party''s contact mobile phone number.';


--
-- Name: COLUMN party.phone; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.phone IS 'SOLA Extension: The party''s main contact phone number. I.e. landline.';


--
-- Name: COLUMN party.fax; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.fax IS 'SOLA Extension: The party''s fax number.';


--
-- Name: COLUMN party.preferred_communication_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.preferred_communication_code IS 'SOLA Extension: Used to indicate the party''s preferred means of communication with the land administration agency.';


--
-- Name: COLUMN party.birth_date; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.birth_date IS 'SOLA Extension: Date of birth.';


--
-- Name: COLUMN party.rowidentifier; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the party_historic table';


--
-- Name: COLUMN party.rowversion; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party.change_action; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party.change_user; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN party.change_time; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: COLUMN party.classification_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this Party. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';


--
-- Name: COLUMN party.redact_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this Party. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';


SET search_path = transaction, pg_catalog;

--
-- Name: transaction; Type: TABLE; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE TABLE transaction (
    id character varying(40) NOT NULL,
    from_service_id character varying(40),
    status_code character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    approval_datetime timestamp without time zone,
    bulk_generate_first_part boolean DEFAULT false NOT NULL,
    is_bulk_operation boolean DEFAULT false NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE transaction.transaction OWNER TO postgres;

--
-- Name: TABLE transaction; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON TABLE transaction IS 'Transactions are used to group changes to registered data (i.e. Property, RRR and Parcels). Each service initiates a transaction that is then recorded against any data edits made by the user. When the service is complete and the application approved, the data associated with the transction can be approved/registered as well. If the user chooses to reject their changes prior to approval, the transaction can be used to determine which data edits need to be removed from the system without affecting the currently registered data. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN transaction.id; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.id IS 'Identifier for the transaction.';


--
-- Name: COLUMN transaction.from_service_id; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.from_service_id IS 'The identifier of the service that initiated the transaction. NULL if the transaction has been created using other means. E.g. for migration or bulk data loading purposes.';


--
-- Name: COLUMN transaction.status_code; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.status_code IS 'The status of the transaction';


--
-- Name: COLUMN transaction.approval_datetime; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.approval_datetime IS 'The date and time the transaction is approved.';


--
-- Name: COLUMN transaction.bulk_generate_first_part; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.bulk_generate_first_part IS 'Flag used by the bulk operations functionality to determine if the first_namepart for cadastre objects should be automatically generated.';


--
-- Name: COLUMN transaction.is_bulk_operation; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.is_bulk_operation IS 'Flag used to indicate the transaction was created in support of a bulk operation.';


--
-- Name: COLUMN transaction.rowidentifier; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.rowidentifier IS 'Identifies the all change records for the row in the transaction_historic table';


--
-- Name: COLUMN transaction.rowversion; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN transaction.change_action; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN transaction.change_user; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN transaction.change_time; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.change_time IS 'The date and time the row was last modified.';


SET search_path = administrative, pg_catalog;

--
-- Name: sys_reg_owner_name; Type: VIEW; Schema: administrative; Owner: postgres
--

CREATE VIEW sys_reg_owner_name AS
    SELECT (((pp.name)::text || ' '::text) || (COALESCE(pp.last_name, ''::character varying))::text) AS value, (pp.name)::text AS name, (COALESCE(pp.last_name, ''::character varying))::text AS last_name, co.id, co.name_firstpart, co.name_lastpart, public.get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, sa.size, CASE WHEN ((COALESCE(co.land_use_code, 'residential'::character varying))::text = 'residential'::text) THEN sa.size ELSE (0)::numeric END AS residential, CASE WHEN ((COALESCE(co.land_use_code, 'residential'::character varying))::text = 'agricultural'::text) THEN sa.size ELSE (0)::numeric END AS agricultural, CASE WHEN ((COALESCE(co.land_use_code, 'residential'::character varying))::text = 'commercial'::text) THEN sa.size ELSE (0)::numeric END AS commercial, CASE WHEN ((COALESCE(co.land_use_code, 'residential'::character varying))::text = 'industrial'::text) THEN sa.size ELSE (0)::numeric END AS industrial FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, ba_unit_contains_spatial_unit su, application.application aa, application.service s, party.party pp, party_for_rrr pr, rrr rrr, ba_unit bu, transaction.transaction t WHERE (((((((((((((((sa.spatial_unit_id)::text = (co.id)::text) AND ((sa.type_code)::text = 'officialArea'::text)) AND ((su.spatial_unit_id)::text = (sa.spatial_unit_id)::text)) AND ((bu.transaction_id)::text = (t.id)::text)) AND ((t.from_service_id)::text = (s.id)::text)) AND ((s.application_id)::text = (aa.id)::text)) AND ((s.request_type_code)::text = 'systematicRegn'::text)) AND ((s.status_code)::text = 'completed'::text)) AND ((pp.id)::text = (pr.party_id)::text)) AND ((pr.rrr_id)::text = (rrr.id)::text)) AND ((rrr.ba_unit_id)::text = (su.ba_unit_id)::text)) AND ((((rrr.type_code)::text = 'ownership'::text) OR ((rrr.type_code)::text = 'apartment'::text)) OR ((rrr.type_code)::text = 'commonOwnership'::text))) AND ((bu.id)::text = (su.ba_unit_id)::text)) AND ((COALESCE(co.land_use_code, 'residential'::character varying))::text = (lu.code)::text)) UNION SELECT DISTINCT 'No Claimant '::text AS value, 'No Claimant '::text AS name, 'No Claimant '::text AS last_name, co.id, co.name_firstpart, co.name_lastpart, public.get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, sa.size, CASE WHEN ((COALESCE(co.land_use_code, 'residential'::character varying))::text = 'residential'::text) THEN sa.size ELSE (0)::numeric END AS residential, CASE WHEN ((COALESCE(co.land_use_code, 'residential'::character varying))::text = 'agricultural'::text) THEN sa.size ELSE (0)::numeric END AS agricultural, CASE WHEN ((COALESCE(co.land_use_code, 'residential'::character varying))::text = 'commercial'::text) THEN sa.size ELSE (0)::numeric END AS commercial, CASE WHEN ((COALESCE(co.land_use_code, 'residential'::character varying))::text = 'industrial'::text) THEN sa.size ELSE (0)::numeric END AS industrial FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, ba_unit_contains_spatial_unit su, application.application aa, party.party pp, party_for_rrr pr, rrr rrr, application.service s, ba_unit bu, transaction.transaction t WHERE ((((((((((((sa.spatial_unit_id)::text = (co.id)::text) AND ((COALESCE(co.land_use_code, 'residential'::character varying))::text = (lu.code)::text)) AND ((sa.type_code)::text = 'officialArea'::text)) AND ((bu.id)::text = (su.ba_unit_id)::text)) AND ((su.spatial_unit_id)::text = (sa.spatial_unit_id)::text)) AND ((bu.transaction_id)::text = (t.id)::text)) AND ((t.from_service_id)::text = (s.id)::text)) AND (NOT ((su.ba_unit_id)::text IN (SELECT rrr_1.ba_unit_id FROM rrr rrr_1, party.party pp_1, party_for_rrr pr_1 WHERE (((((((rrr_1.type_code)::text = 'ownership'::text) OR ((rrr_1.type_code)::text = 'apartment'::text)) OR ((rrr_1.type_code)::text = 'commonOwnership'::text)) OR ((rrr_1.type_code)::text = 'stateOwnership'::text)) AND ((pp_1.id)::text = (pr_1.party_id)::text)) AND ((pr_1.rrr_id)::text = (rrr_1.id)::text)))))) AND ((s.application_id)::text = (aa.id)::text)) AND ((s.request_type_code)::text = 'systematicRegn'::text)) AND ((s.status_code)::text = 'completed'::text)) ORDER BY 3, 2;


ALTER TABLE administrative.sys_reg_owner_name OWNER TO postgres;

--
-- Name: VIEW sys_reg_owner_name; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON VIEW sys_reg_owner_name IS 'Used by systematic registration to identify the owners for each property subject to SR.';


--
-- Name: sys_reg_state_land; Type: VIEW; Schema: administrative; Owner: postgres
--

CREATE VIEW sys_reg_state_land AS
    SELECT (((pp.name)::text || ' '::text) || (COALESCE(pp.last_name, ' '::character varying))::text) AS value, co.id, co.name_firstpart, co.name_lastpart, public.get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, sa.size, CASE WHEN ((COALESCE(co.land_use_code, 'residential'::character varying))::text = 'residential'::text) THEN sa.size ELSE (0)::numeric END AS residential, CASE WHEN ((COALESCE(co.land_use_code, 'residential'::character varying))::text = 'agricultural'::text) THEN sa.size ELSE (0)::numeric END AS agricultural, CASE WHEN ((COALESCE(co.land_use_code, 'residential'::character varying))::text = 'commercial'::text) THEN sa.size ELSE (0)::numeric END AS commercial, CASE WHEN ((COALESCE(co.land_use_code, 'residential'::character varying))::text = 'industrial'::text) THEN sa.size ELSE (0)::numeric END AS industrial FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, ba_unit_contains_spatial_unit su, application.application aa, application.service s, party.party pp, party_for_rrr pr, rrr rrr, ba_unit bu, transaction.transaction t WHERE (((((((((((((((sa.spatial_unit_id)::text = (co.id)::text) AND ((COALESCE(co.land_use_code, 'residential'::character varying))::text = (lu.code)::text)) AND ((sa.type_code)::text = 'officialArea'::text)) AND ((su.spatial_unit_id)::text = (sa.spatial_unit_id)::text)) AND ((bu.transaction_id)::text = (t.id)::text)) AND ((t.from_service_id)::text = (s.id)::text)) AND ((s.application_id)::text = (aa.id)::text)) AND ((s.request_type_code)::text = 'systematicRegn'::text)) AND ((s.status_code)::text = 'completed'::text)) AND ((pp.id)::text = (pr.party_id)::text)) AND ((pr.rrr_id)::text = (rrr.id)::text)) AND ((rrr.ba_unit_id)::text = (su.ba_unit_id)::text)) AND ((rrr.type_code)::text = 'stateOwnership'::text)) AND ((bu.id)::text = (su.ba_unit_id)::text)) ORDER BY (((pp.name)::text || ' '::text) || (COALESCE(pp.last_name, ' '::character varying))::text);


ALTER TABLE administrative.sys_reg_state_land OWNER TO postgres;

--
-- Name: VIEW sys_reg_state_land; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON VIEW sys_reg_state_land IS 'Used by systematic registration to identify state land under SR.';


--
-- Name: systematic_registration_listing; Type: VIEW; Schema: administrative; Owner: postgres
--

CREATE VIEW systematic_registration_listing AS
    SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart, sa.size, public.get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, (((bu.name_firstpart)::text || '/'::text) || (bu.name_lastpart)::text) AS name FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, ba_unit_contains_spatial_unit su, application.application aa, application.service s, ba_unit bu, transaction.transaction t WHERE (((((((((((sa.spatial_unit_id)::text = (co.id)::text) AND ((bu.transaction_id)::text = (t.id)::text)) AND ((t.from_service_id)::text = (s.id)::text)) AND ((sa.type_code)::text = 'officialArea'::text)) AND ((su.spatial_unit_id)::text = (sa.spatial_unit_id)::text)) AND ((s.application_id)::text = (aa.id)::text)) AND ((s.request_type_code)::text = 'systematicRegn'::text)) AND ((s.status_code)::text = 'completed'::text)) AND ((COALESCE(co.land_use_code, 'residential'::character varying))::text = (lu.code)::text)) AND ((bu.id)::text = (su.ba_unit_id)::text));


ALTER TABLE administrative.systematic_registration_listing OWNER TO postgres;

--
-- Name: VIEW systematic_registration_listing; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON VIEW systematic_registration_listing IS 'Used by systematic registration to list parcels subject to SR.';


SET search_path = application, pg_catalog;

--
-- Name: application_action_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_action_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status_to_set character varying(20),
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE application.application_action_type OWNER TO postgres;

--
-- Name: TABLE application_action_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE application_action_type IS 'Code list of action types.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN application_action_type.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_action_type.code IS 'The code for the application action type.';


--
-- Name: COLUMN application_action_type.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_action_type.display_value IS 'Displayed value of the application action type.';


--
-- Name: COLUMN application_action_type.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_action_type.status IS 'Status of the application action type';


--
-- Name: COLUMN application_action_type.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_action_type.description IS 'Description of the application action type.';


--
-- Name: application_historic; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_historic (
    id character varying(40),
    nr character varying(15),
    agent_id character varying(40),
    contact_person_id character varying(40),
    lodging_datetime timestamp without time zone,
    expected_completion_date date,
    assignee_id character varying(40),
    assigned_datetime timestamp without time zone,
    location public.geometry,
    services_fee numeric(20,2),
    tax numeric(20,2),
    total_fee numeric(20,2),
    total_amount_paid numeric(20,2),
    fee_paid boolean,
    action_code character varying(20),
    action_notes character varying(255),
    status_code character varying(20),
    receipt_reference character varying(100),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20),
    CONSTRAINT enforce_dims_location CHECK ((public.st_ndims(location) = 2)),
    CONSTRAINT enforce_geotype_location CHECK (((public.geometrytype(location) = 'MULTIPOINT'::text) OR (location IS NULL))),
    CONSTRAINT enforce_srid_location CHECK ((public.st_srid(location) = 2193)),
    CONSTRAINT enforce_valid_location CHECK (public.st_isvalid(location))
);


ALTER TABLE application.application_historic OWNER TO postgres;

--
-- Name: application_nr_seq; Type: SEQUENCE; Schema: application; Owner: postgres
--

CREATE SEQUENCE application_nr_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999
    CACHE 1
    CYCLE;


ALTER TABLE application.application_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE application_nr_seq; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON SEQUENCE application_nr_seq IS 'Sequence number used as the basis for the Application nr field. This sequence is used by the generate-application-nr business rule.';


--
-- Name: application_property; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_property (
    id character varying(40) NOT NULL,
    application_id character varying(40) NOT NULL,
    name_firstpart character varying(20) NOT NULL,
    name_lastpart character varying(20) NOT NULL,
    area numeric(20,2) DEFAULT 0 NOT NULL,
    total_value numeric(20,2) DEFAULT 0 NOT NULL,
    verified_exists boolean DEFAULT false NOT NULL,
    verified_location boolean DEFAULT false NOT NULL,
    ba_unit_id character varying(40),
    land_use_code character varying(20),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.application_property OWNER TO postgres;

--
-- Name: TABLE application_property; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE application_property IS 'Captures details of property associated to an application.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN application_property.id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.id IS 'Identifier for the application property.';


--
-- Name: COLUMN application_property.application_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.application_id IS 'Identifier for the application the record is associated to.';


--
-- Name: COLUMN application_property.name_firstpart; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.name_firstpart IS 'The first part of the name or reference assigned by the land administration agency to identify the property.';


--
-- Name: COLUMN application_property.name_lastpart; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.name_lastpart IS 'The remaining part of the name or reference assigned by the land administration agency to identify the property.';


--
-- Name: COLUMN application_property.area; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.area IS 'The area of the property. This value should be square meters and converted if required for display to the user. e.g. Converted on display into and imperial acres, roods and perches value.';


--
-- Name: COLUMN application_property.total_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.total_value IS 'The land or property value (may vary from jurisdiction to jurisdiction) on which a proportionate service fee can be calculated.';


--
-- Name: COLUMN application_property.verified_exists; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.verified_exists IS 'Flag to indicate if the property details provided for the application match an existing property record in the BA Unit table. ';


--
-- Name: COLUMN application_property.verified_location; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.verified_location IS 'Flag to indicate if the property details provided for the application reference an existing parcel record in the Cadastre Object table.';


--
-- Name: COLUMN application_property.ba_unit_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.ba_unit_id IS 'Reference to a record in the BA Unit table that matches the property details provided for the application.';


--
-- Name: COLUMN application_property.land_use_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.land_use_code IS 'Code to indicate the general purpose of the property. E.g. Commerical, Residential, Industrial, etc.';


--
-- Name: COLUMN application_property.rowidentifier; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.rowidentifier IS 'Identifies the all change records for the row in the application_property_historic table';


--
-- Name: COLUMN application_property.rowversion; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN application_property.change_action; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN application_property.change_user; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN application_property.change_time; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.change_time IS 'The date and time the row was last modified.';


--
-- Name: application_property_historic; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_property_historic (
    id character varying(40),
    application_id character varying(40),
    name_firstpart character varying(20),
    name_lastpart character varying(20),
    area numeric(20,2),
    total_value numeric(20,2),
    verified_exists boolean,
    verified_location boolean,
    ba_unit_id character varying(40),
    land_use_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.application_property_historic OWNER TO postgres;

--
-- Name: application_spatial_unit; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_spatial_unit (
    application_id character varying(40) NOT NULL,
    spatial_unit_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.application_spatial_unit OWNER TO postgres;

--
-- Name: TABLE application_spatial_unit; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE application_spatial_unit IS 'Captures details of parcels (a.k.a. Cadastre Objects or Spatial Units) associated to an application.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN application_spatial_unit.application_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_spatial_unit.application_id IS 'Identifier for the application the record is associated to.';


--
-- Name: COLUMN application_spatial_unit.spatial_unit_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_spatial_unit.spatial_unit_id IS 'Identifier of the parcel (a.k.a Cadastre Objects or Spatial Units) associated to the application.';


--
-- Name: COLUMN application_spatial_unit.rowidentifier; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_spatial_unit.rowidentifier IS 'Identifies the all change records for the row in the application_spatial_unit_historic table';


--
-- Name: COLUMN application_spatial_unit.rowversion; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_spatial_unit.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN application_spatial_unit.change_action; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_spatial_unit.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN application_spatial_unit.change_user; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_spatial_unit.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN application_spatial_unit.change_time; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_spatial_unit.change_time IS 'The date and time the row was last modified.';


--
-- Name: application_spatial_unit_historic; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_spatial_unit_historic (
    application_id character varying(40),
    spatial_unit_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.application_spatial_unit_historic OWNER TO postgres;

--
-- Name: application_status_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_status_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE application.application_status_type OWNER TO postgres;

--
-- Name: TABLE application_status_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE application_status_type IS 'Code list of application status types.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN application_status_type.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_status_type.code IS 'The code for the application status type.';


--
-- Name: COLUMN application_status_type.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_status_type.display_value IS 'Displayed value of the application status type.';


--
-- Name: COLUMN application_status_type.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_status_type.status IS 'Status of the application status type';


--
-- Name: COLUMN application_status_type.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_status_type.description IS 'Description of the application status type.';


--
-- Name: application_uses_source; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_uses_source (
    application_id character varying(40) NOT NULL,
    source_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.application_uses_source OWNER TO postgres;

--
-- Name: TABLE application_uses_source; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE application_uses_source IS 'Links the application to the sources (a.k.a. documents) submitted with the application. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN application_uses_source.application_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.application_id IS 'Identifier for the application the record is associated to.';


--
-- Name: COLUMN application_uses_source.source_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.source_id IS 'Identifier of the source associated to the application.';


--
-- Name: COLUMN application_uses_source.rowidentifier; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.rowidentifier IS 'Identifies the all change records for the row in the application_spatial_unit_historic table';


--
-- Name: COLUMN application_uses_source.rowversion; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN application_uses_source.change_action; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN application_uses_source.change_user; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN application_uses_source.change_time; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.change_time IS 'The date and time the row was last modified.';


--
-- Name: application_uses_source_historic; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_uses_source_historic (
    application_id character varying(40),
    source_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.application_uses_source_historic OWNER TO postgres;

SET search_path = party, pg_catalog;

--
-- Name: group_party; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE group_party (
    id character varying(40) NOT NULL,
    type_code character varying(20) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.group_party OWNER TO postgres;

--
-- Name: TABLE group_party; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE group_party IS 'Groups any number of parties into a distinct entity. Implementation of the LADM LA_GroupParty class. Not used by SOLA
Tags: LADM Reference Object, Change History, Not Used';


--
-- Name: COLUMN group_party.id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.id IS 'LADM Definition: Identifier for the group party.';


--
-- Name: COLUMN group_party.type_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.type_code IS 'LADM Definition: The type of the group party. E.g. family, tribe, association, etc.';


--
-- Name: COLUMN group_party.rowidentifier; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the group_party_historic table';


--
-- Name: COLUMN group_party.rowversion; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN group_party.change_action; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN group_party.change_user; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN group_party.change_time; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: party_member; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_member (
    party_id character varying(40) NOT NULL,
    group_id character varying(40) NOT NULL,
    share double precision,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.party_member OWNER TO postgres;

--
-- Name: TABLE party_member; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE party_member IS 'Identifies the parties belonging to a group party. Implementation of the LADM LA_PartyMember class. Not used by SOLA.
Tags: LADM Reference Object, Change History, Not Used';


--
-- Name: COLUMN party_member.party_id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.party_id IS 'LADM Definition: Identifier for the party.';


--
-- Name: COLUMN party_member.group_id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.group_id IS 'LADM Definition: Identifier of the group party';


--
-- Name: COLUMN party_member.share; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.share IS 'LADM Definition: The share of a RRR held by a party member expressed as a fraction with a numerator and a denominator.';


--
-- Name: COLUMN party_member.rowidentifier; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the party_member_historic table';


--
-- Name: COLUMN party_member.rowversion; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party_member.change_action; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party_member.change_user; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN party_member.change_time; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.change_time IS 'SOLA Extension: The date and time the row was last modified.';


SET search_path = application, pg_catalog;

--
-- Name: cancel_notification; Type: VIEW; Schema: application; Owner: postgres
--

CREATE VIEW cancel_notification AS
    SELECT pp.name AS partyname, pp.last_name AS partylastname, tpp.name AS targetpartyname, tpp.last_name AS targetpartylastname, npbu.party_id, npbu.target_party_id, npbu.baunit_name, npbu.service_id, npbu.cancel_service_id, gpp.id AS grouppartyid, gpp.name AS grouppartyname, gpp.last_name AS grouppartylastname FROM party.party pp, party.party tpp, party.party gpp, administrative.notifiable_party_for_baunit npbu, application aa, service s, party.group_party gp WHERE ((((((((s.application_id)::text = (aa.id)::text) AND ((s.id)::text = (npbu.cancel_service_id)::text)) AND (((pp.id)::text = (npbu.party_id)::text) AND ((tpp.id)::text = (npbu.target_party_id)::text))) AND ((gpp.id)::text = (gp.id)::text)) AND ((pp.id)::text IN (SELECT pm.party_id FROM party.party_member pm WHERE ((pm.group_id)::text = (gp.id)::text)))) AND ((tpp.id)::text IN (SELECT pm.party_id FROM party.party_member pm WHERE ((pm.group_id)::text = (gp.id)::text)))) AND ((s.request_type_code)::text = 'cancelRelationship'::text));


ALTER TABLE application.cancel_notification OWNER TO postgres;

--
-- Name: request_category_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE request_category_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE application.request_category_type OWNER TO postgres;

--
-- Name: TABLE request_category_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE request_category_type IS 'Code list of request category types. Request category types group the request types into logical groupings such as request types for registration or cadastral changes.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN request_category_type.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_category_type.code IS 'The code for the request category type.';


--
-- Name: COLUMN request_category_type.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_category_type.display_value IS 'Displayed value of the request category type.';


--
-- Name: COLUMN request_category_type.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_category_type.description IS 'Description of the request category type.';


--
-- Name: COLUMN request_category_type.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_category_type.status IS 'Status of the request category type';


--
-- Name: request_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE request_type (
    code character varying(20) NOT NULL,
    request_category_code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    nr_days_to_complete integer DEFAULT 0 NOT NULL,
    base_fee numeric(20,2) DEFAULT 0 NOT NULL,
    area_base_fee numeric(20,2) DEFAULT 0 NOT NULL,
    value_base_fee numeric(20,2) DEFAULT 0 NOT NULL,
    nr_properties_required integer DEFAULT 0 NOT NULL,
    notation_template character varying(1000),
    rrr_type_code character varying(20),
    type_action_code character varying(20),
    display_group_name character varying(500),
    service_panel_code character varying(20)
);


ALTER TABLE application.request_type OWNER TO postgres;

--
-- Name: TABLE request_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE request_type IS 'Code list of request types. Request types identify the different types of services provided by the land administration agency. SOLA includes a default set of request types that can be reconfigured to match those required by the land administration agency. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN request_type.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.code IS 'The code for the request type.';


--
-- Name: COLUMN request_type.request_category_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.request_category_code IS 'The code for the request category type.';


--
-- Name: COLUMN request_type.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.display_value IS 'Displayed value of the request type.';


--
-- Name: COLUMN request_type.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.description IS 'Description of the request type.';


--
-- Name: COLUMN request_type.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.status IS 'Status of the request type';


--
-- Name: COLUMN request_type.nr_days_to_complete; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.nr_days_to_complete IS 'The number of days it should take for the service to be completed.  Can be used to manage and monitor transaction throughput targets for the land administration agency.';


--
-- Name: COLUMN request_type.base_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.base_fee IS 'The fixed fee component charged for the service or 0 if there is no fixed fee.';


--
-- Name: COLUMN request_type.area_base_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.area_base_fee IS 'The fee component charged for each square metre of the property or 0 if no area fee applies.';


--
-- Name: COLUMN request_type.value_base_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.value_base_fee IS 'The fee component charged against the value of the property or 0 if no value fee applies.';


--
-- Name: COLUMN request_type.nr_properties_required; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.nr_properties_required IS 'The minimum number of properties that must be referenced by the application before services of this type can be processed.';


--
-- Name: COLUMN request_type.notation_template; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.notation_template IS 'Template text to use when completing the details of RRR records created by the service.';


--
-- Name: COLUMN request_type.rrr_type_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.rrr_type_code IS 'Used by the Property Details screen to identify the type of RRR affected by the service. If null, the Property Details screen will allow the user to process all RRR types.';


--
-- Name: COLUMN request_type.type_action_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.type_action_code IS 'Used by teh Property Details screen to identify what action applies to the RRR affected by the service. One of new, vary or cancel. If null, the Property Details screen will allow the user to create or vary RRRs matching the rrr_type_code.';


--
-- Name: COLUMN request_type.display_group_name; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.display_group_name IS 'SOLA Extension. Used to group request types that have a similar purpose (e.g. Mortgage types or Systematic Registration types). Used by the Add Service dialog to group the request types for display.';


--
-- Name: COLUMN request_type.service_panel_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.service_panel_code IS 'SOLA Extension. Used to identify the SOLA panel class to display to the user when they start the service';


--
-- Name: request_type_requires_source_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE request_type_requires_source_type (
    source_type_code character varying(20) NOT NULL,
    request_type_code character varying(20) NOT NULL
);


ALTER TABLE application.request_type_requires_source_type OWNER TO postgres;

--
-- Name: TABLE request_type_requires_source_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE request_type_requires_source_type IS 'Identifies the types of sources (a.k.a. documents) that must be provided before a service can be processed by the land administration agency.
Tags: FLOSS SOLA Extension';


--
-- Name: COLUMN request_type_requires_source_type.source_type_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type_requires_source_type.source_type_code IS 'The source type required by the request type.';


--
-- Name: COLUMN request_type_requires_source_type.request_type_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type_requires_source_type.request_type_code IS 'The request type that requries the source to be present on the application.';


--
-- Name: service_action_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE service_action_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status_to_set character varying(20),
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE application.service_action_type OWNER TO postgres;

--
-- Name: TABLE service_action_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE service_action_type IS 'Code list of service action types. Service actions identify the actions user can perform against services. E.g. lodge, start, revert, cancel, complete.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN service_action_type.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_action_type.code IS 'The code for the service action type.';


--
-- Name: COLUMN service_action_type.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_action_type.display_value IS 'Displayed value of the service action type.';


--
-- Name: COLUMN service_action_type.status_to_set; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_action_type.status_to_set IS 'The status to set on the service when the service action is applied.';


--
-- Name: COLUMN service_action_type.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_action_type.status IS 'Status of the service action type';


--
-- Name: COLUMN service_action_type.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_action_type.description IS 'Description of the service action type.';


--
-- Name: service_historic; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE service_historic (
    id character varying(40),
    application_id character varying(40),
    request_type_code character varying(20),
    service_order integer,
    lodging_datetime timestamp without time zone,
    expected_completion_date date,
    status_code character varying(20),
    action_code character varying(20),
    action_notes character varying(255),
    base_fee numeric(20,2),
    area_fee numeric(20,2),
    value_fee numeric(20,2),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.service_historic OWNER TO postgres;

--
-- Name: service_status_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE service_status_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE application.service_status_type OWNER TO postgres;

--
-- Name: TABLE service_status_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE service_status_type IS 'Code list of service status types.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN service_status_type.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_status_type.code IS 'The code for the service status type.';


--
-- Name: COLUMN service_status_type.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_status_type.display_value IS 'Displayed value of the service status type.';


--
-- Name: COLUMN service_status_type.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_status_type.status IS 'Status of the service status type';


--
-- Name: COLUMN service_status_type.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_status_type.description IS 'Description of the service status type.';


--
-- Name: systematic_registration_certificates; Type: VIEW; Schema: application; Owner: postgres
--

CREATE VIEW systematic_registration_certificates AS
    SELECT aa.nr, co.name_firstpart, co.name_lastpart, su.ba_unit_id FROM application_status_type ast, cadastre.cadastre_object co, administrative.ba_unit bu, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application aa, service s, transaction.transaction t WHERE (((((((((((sa.spatial_unit_id)::text = (co.id)::text) AND ((sa.type_code)::text = 'officialArea'::text)) AND ((su.spatial_unit_id)::text = (sa.spatial_unit_id)::text)) AND ((su.ba_unit_id)::text = (bu.id)::text)) AND ((bu.transaction_id)::text = (t.id)::text)) AND ((t.from_service_id)::text = (s.id)::text)) AND ((s.application_id)::text = (aa.id)::text)) AND ((s.request_type_code)::text = 'systematicRegn'::text)) AND ((aa.status_code)::text = (ast.code)::text)) AND ((aa.status_code)::text = 'approved'::text));


ALTER TABLE application.systematic_registration_certificates OWNER TO postgres;

--
-- Name: VIEW systematic_registration_certificates; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON VIEW systematic_registration_certificates IS 'Used by systematic registration to identify parcels that require a certificate to be generated.';


--
-- Name: type_action; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE type_action (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE application.type_action OWNER TO postgres;

--
-- Name: TABLE type_action; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE type_action IS 'Code list of request type actions. Identifies what actions the Property Details screen should support for RRRs when processing a service. One of new, vary or cancel. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN type_action.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN type_action.code IS 'The code for the request type action.';


--
-- Name: COLUMN type_action.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN type_action.display_value IS 'Displayed value of the request type action.';


--
-- Name: COLUMN type_action.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN type_action.description IS 'Description of the request type action.';


--
-- Name: COLUMN type_action.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN type_action.status IS 'Status of the request type action.';


SET search_path = bulk_operation, pg_catalog;

--
-- Name: spatial_unit_temporary; Type: TABLE; Schema: bulk_operation; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_temporary (
    id character varying(40) NOT NULL,
    transaction_id character varying(40) NOT NULL,
    type_code character varying(20) NOT NULL,
    cadastre_object_type_code character varying(20),
    name_firstpart character varying(20),
    name_lastpart character varying(50),
    geom public.geometry NOT NULL,
    official_area numeric(29,2),
    label character varying(100),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom))
);


ALTER TABLE bulk_operation.spatial_unit_temporary OWNER TO postgres;

--
-- Name: TABLE spatial_unit_temporary; Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON TABLE spatial_unit_temporary IS 'Used as a staging area when loading spatial objects with the bulk operations functionality. Data in this table is validated and any field values generated (e.g. name_firstpart) prior to transferring the data into the cadastre object table.  
Tags: FLOSS SOLA Extension';


--
-- Name: COLUMN spatial_unit_temporary.id; Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_temporary.id IS 'Identifier for the record.';


--
-- Name: COLUMN spatial_unit_temporary.transaction_id; Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_temporary.transaction_id IS 'The identifier of the transation associated to the bulk operation.';


--
-- Name: COLUMN spatial_unit_temporary.type_code; Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_temporary.type_code IS 'The type of object that will be uploaded.';


--
-- Name: COLUMN spatial_unit_temporary.cadastre_object_type_code; Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_temporary.cadastre_object_type_code IS 'The type of the cadastre object. Only applicable if the type_code is cadastre_object.';


--
-- Name: COLUMN spatial_unit_temporary.name_firstpart; Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_temporary.name_firstpart IS 'The first part of the name for the cadastre object. Only applicable if the type_code is cadastre_object.';


--
-- Name: COLUMN spatial_unit_temporary.name_lastpart; Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_temporary.name_lastpart IS 'The last or remaining part of the name for the cadastre object. Only applicable if the type_code is cadastre_object.';


--
-- Name: COLUMN spatial_unit_temporary.geom; Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_temporary.geom IS 'The geometry for the spaital unit.';


--
-- Name: COLUMN spatial_unit_temporary.official_area; Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_temporary.official_area IS 'The official area for the cadastre object. Only applicable if the type_code is cadastre_object.';


--
-- Name: COLUMN spatial_unit_temporary.label; Type: COMMENT; Schema: bulk_operation; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_temporary.label IS 'The label to use for the spatial unit. Only applicable if the type_code IS NOT cadastre_object.';


SET search_path = cadastre, pg_catalog;

--
-- Name: area_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE area_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 'c'::bpchar NOT NULL
);


ALTER TABLE cadastre.area_type OWNER TO postgres;

--
-- Name: TABLE area_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE area_type IS 'Code list of area types. Identifies the types of area (calculated, official, survey defined, etc) that can be recorded for a parcel (a.k.a. cadastre object). Implementation of the LADM LA_AreaType class.
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN area_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN area_type.code IS 'LADM Definition: The code for the area type.';


--
-- Name: COLUMN area_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN area_type.display_value IS 'LADM Definition: Displayed value of the area type.';


--
-- Name: COLUMN area_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN area_type.description IS 'LADM Definition: Description of the area type.';


--
-- Name: COLUMN area_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN area_type.status IS 'SOLA Extension: Status of the area type';


--
-- Name: building_unit_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE building_unit_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.building_unit_type OWNER TO postgres;

--
-- Name: TABLE building_unit_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE building_unit_type IS 'Code list of building unit types. Identifies the types of building unit that can exist on a parcel. Implementation of the LADM LA_BuildingUnitType class. Not used by SOLA.
Tags: Reference Table, LADM Reference Object, Not Used';


--
-- Name: COLUMN building_unit_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN building_unit_type.code IS 'LADM Definition: The code for the building unit type.';


--
-- Name: COLUMN building_unit_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN building_unit_type.display_value IS 'LADM Definition: Displayed value of the building unit type.';


--
-- Name: COLUMN building_unit_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN building_unit_type.description IS 'LADM Definition: Description of the building unit type.';


--
-- Name: COLUMN building_unit_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN building_unit_type.status IS 'SOLA Extension: Status of the building unit type';


--
-- Name: cadastre_object_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object_historic (
    id character varying(40),
    type_code character varying(20),
    building_unit_type_code character varying(20),
    approval_datetime timestamp without time zone,
    historic_datetime timestamp without time zone,
    source_reference character varying(100),
    name_firstpart character varying(20),
    name_lastpart character varying(50),
    status_code character varying(20),
    geom_polygon public.geometry,
    transaction_id character varying(40),
    land_use_code character varying(255),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20),
    CONSTRAINT enforce_dims_geom_polygon CHECK ((public.st_ndims(geom_polygon) = 2)),
    CONSTRAINT enforce_geotype_geom_polygon CHECK (((public.geometrytype(geom_polygon) = 'POLYGON'::text) OR (geom_polygon IS NULL))),
    CONSTRAINT enforce_srid_geom_polygon CHECK ((public.st_srid(geom_polygon) = 2193)),
    CONSTRAINT enforce_valid_geom_polygon CHECK (public.st_isvalid(geom_polygon))
);


ALTER TABLE cadastre.cadastre_object_historic OWNER TO postgres;

--
-- Name: cadastre_object_node_target; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object_node_target (
    transaction_id character varying(40) NOT NULL,
    node_id character varying(40) NOT NULL,
    geom public.geometry NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((public.geometrytype(geom) = 'POINT'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom))
);


ALTER TABLE cadastre.cadastre_object_node_target OWNER TO postgres;

--
-- Name: TABLE cadastre_object_node_target; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE cadastre_object_node_target IS 'Used to store coordinate details for new or modified nodes during the Redefine Cadastre process.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN cadastre_object_node_target.transaction_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.transaction_id IS 'Identifier for the transaction the node is associated with.';


--
-- Name: COLUMN cadastre_object_node_target.node_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.node_id IS 'Identifier for the node.';


--
-- Name: COLUMN cadastre_object_node_target.geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.geom IS 'The geometry of the node containing the coordinate details.';


--
-- Name: COLUMN cadastre_object_node_target.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.rowidentifier IS 'Identifies the all change records for the row in the cadastre_object_node_target_historic table';


--
-- Name: COLUMN cadastre_object_node_target.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN cadastre_object_node_target.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN cadastre_object_node_target.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN cadastre_object_node_target.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.change_time IS 'The date and time the row was last modified.';


--
-- Name: cadastre_object_node_target_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object_node_target_historic (
    transaction_id character varying(40),
    node_id character varying(40),
    geom public.geometry,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((public.geometrytype(geom) = 'POINT'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom))
);


ALTER TABLE cadastre.cadastre_object_node_target_historic OWNER TO postgres;

--
-- Name: cadastre_object_target; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object_target (
    transaction_id character varying(40) NOT NULL,
    cadastre_object_id character varying(40) NOT NULL,
    geom_polygon public.geometry,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom_polygon CHECK ((public.st_ndims(geom_polygon) = 2)),
    CONSTRAINT enforce_geotype_geom_polygon CHECK (((public.geometrytype(geom_polygon) = 'POLYGON'::text) OR (geom_polygon IS NULL))),
    CONSTRAINT enforce_srid_geom_polygon CHECK ((public.st_srid(geom_polygon) = 2193)),
    CONSTRAINT enforce_valid_geom_polygon CHECK (public.st_isvalid(geom_polygon))
);


ALTER TABLE cadastre.cadastre_object_target OWNER TO postgres;

--
-- Name: TABLE cadastre_object_target; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE cadastre_object_target IS 'Used to identify cadastre objects that are being changed or cancelled by a cadastre related transaction (i.e. Change Cadastre or Redefine Cadastre). These changes are considered pending/unofficial and do not affect the registered state of the cadastre object until the transaction is approved. Note that new cadastre objects are created in the cadastre_object table with a status of pending and they are not recorded in this table. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN cadastre_object_target.transaction_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.transaction_id IS 'Identifier for the transaction the cadastre object is being affected by.';


--
-- Name: COLUMN cadastre_object_target.cadastre_object_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.cadastre_object_id IS 'Identifier for the cadastre object.';


--
-- Name: COLUMN cadastre_object_target.geom_polygon; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.geom_polygon IS 'The new geometry of the cadastre object as a result of the cadastre transaction.';


--
-- Name: COLUMN cadastre_object_target.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.rowidentifier IS 'Identifies the all change records for the row in the cadastre_object_target_historic table';


--
-- Name: COLUMN cadastre_object_target.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN cadastre_object_target.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN cadastre_object_target.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN cadastre_object_target.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.change_time IS 'The date and time the row was last modified.';


--
-- Name: cadastre_object_target_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object_target_historic (
    transaction_id character varying(40),
    cadastre_object_id character varying(40),
    geom_polygon public.geometry,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom_polygon CHECK ((public.st_ndims(geom_polygon) = 2)),
    CONSTRAINT enforce_geotype_geom_polygon CHECK (((public.geometrytype(geom_polygon) = 'POLYGON'::text) OR (geom_polygon IS NULL))),
    CONSTRAINT enforce_srid_geom_polygon CHECK ((public.st_srid(geom_polygon) = 2193)),
    CONSTRAINT enforce_valid_geom_polygon CHECK (public.st_isvalid(geom_polygon))
);


ALTER TABLE cadastre.cadastre_object_target_historic OWNER TO postgres;

--
-- Name: cadastre_object_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) NOT NULL,
    in_topology boolean DEFAULT false NOT NULL
);


ALTER TABLE cadastre.cadastre_object_type OWNER TO postgres;

--
-- Name: TABLE cadastre_object_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE cadastre_object_type IS 'Code list of cadastre object types. E.g. parcel, building_unit, road, etc. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN cadastre_object_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_type.code IS 'The code for the cadastre object type.';


--
-- Name: COLUMN cadastre_object_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_type.display_value IS 'Displayed value of the cadastre object type.';


--
-- Name: COLUMN cadastre_object_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_type.description IS 'Description of the cadastre object type.';


--
-- Name: COLUMN cadastre_object_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_type.status IS 'Status of the cadastre object type';


--
-- Name: COLUMN cadastre_object_type.in_topology; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_type.in_topology IS 'Flag to indicate that all cadastre objects of this type must obey topological conventions such as no gaps or overlaps between objects with the same type.';


--
-- Name: dimension_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE dimension_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.dimension_type OWNER TO postgres;

--
-- Name: TABLE dimension_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE dimension_type IS 'Code list of dimension types. Identifies the number of dimensions used to define a spatial unit. E.g. 1D, 2D, etc. Implementation of the LADM LA_DimensionType class. SOLA assumes all spatial units are 2D. 
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN dimension_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN dimension_type.code IS 'LADM Definition: The code for the dimension type.';


--
-- Name: COLUMN dimension_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN dimension_type.display_value IS 'LADM Definition: Displayed value of the dimension type.';


--
-- Name: COLUMN dimension_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN dimension_type.description IS 'LADM Definition: Description of the dimension type.';


--
-- Name: COLUMN dimension_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN dimension_type.status IS 'SOLA Extension: Status of the dimension type';


--
-- Name: spatial_unit_group; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_group (
    id character varying(40) NOT NULL,
    hierarchy_level integer NOT NULL,
    label character varying(50),
    name character varying(50),
    reference_point public.geometry,
    geom public.geometry,
    found_in_spatial_unit_group_id character varying(40),
    seq_nr integer,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_dims_reference_point CHECK ((public.st_ndims(reference_point) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((public.geometrytype(geom) = 'POLYGON'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_geotype_reference_point CHECK (((public.geometrytype(reference_point) = 'POINT'::text) OR (reference_point IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_srid_reference_point CHECK ((public.st_srid(reference_point) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom)),
    CONSTRAINT enforce_valid_reference_point CHECK (public.st_isvalid(reference_point))
);


ALTER TABLE cadastre.spatial_unit_group OWNER TO postgres;

--
-- Name: TABLE spatial_unit_group; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE spatial_unit_group IS 'Any number of spatial units considered as a single entity. 
Implementation of the LADM LA_SpatialUnitGroup class. 
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN spatial_unit_group.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.id IS 'LADM Definition: Spatial unit group identifier.';


--
-- Name: COLUMN spatial_unit_group.hierarchy_level; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.hierarchy_level IS 'LADM Definition: The level in the hierarchy of the administrative or zoning subdivision.';


--
-- Name: COLUMN spatial_unit_group.label; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.label IS 'LADM Definition: Short textual description of the spaital unit group.';


--
-- Name: COLUMN spatial_unit_group.name; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.name IS 'LADM Definition: The name of the spatial unit group.';


--
-- Name: COLUMN spatial_unit_group.reference_point; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.reference_point IS 'LADM Definition: The coordinates of a point inside the spatial unit group.';


--
-- Name: COLUMN spatial_unit_group.geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.geom IS 'SOLA Extension: The geometry for the spatial unit group. Can be any geometry type.';


--
-- Name: COLUMN spatial_unit_group.found_in_spatial_unit_group_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.found_in_spatial_unit_group_id IS 'LADM Definition: The identifier of the parent spatial unit group that this group is part of.';


--
-- Name: COLUMN spatial_unit_group.seq_nr; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.seq_nr IS 'SOLA Extension: Used to assist with number sequencing and naming of spatial units within the spatial unit group.';


--
-- Name: COLUMN spatial_unit_group.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the spatial_unit_group_historic table';


--
-- Name: COLUMN spatial_unit_group.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_unit_group.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_unit_group.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_unit_group.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: hierarchy; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW hierarchy AS
    SELECT sug.id, sug.label, sug.geom, (sug.hierarchy_level)::character varying AS filter_category FROM spatial_unit_group sug;


ALTER TABLE cadastre.hierarchy OWNER TO postgres;

--
-- Name: VIEW hierarchy; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW hierarchy IS 'First (highest) level of the hierarchical spatial unit group object of a hierarchical structure such as administrative rights.';


--
-- Name: hierarchy_level; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE hierarchy_level (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.hierarchy_level OWNER TO postgres;

--
-- Name: TABLE hierarchy_level; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE hierarchy_level IS 'Code list of hierarchy levels. Used by Systematic Registration functionalty when defining Spatial Unit Groups. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN hierarchy_level.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN hierarchy_level.code IS 'The code for the hierarchy level.';


--
-- Name: COLUMN hierarchy_level.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN hierarchy_level.display_value IS 'Displayed value of the hierarchy level.';


--
-- Name: COLUMN hierarchy_level.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN hierarchy_level.description IS 'Description of the hierarchy level.';


--
-- Name: COLUMN hierarchy_level.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN hierarchy_level.status IS 'Status of the hierarchy level';


--
-- Name: legal_space_utility_network; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE legal_space_utility_network (
    id character varying(40) NOT NULL,
    ext_physical_network_id character varying(40),
    status_code character varying(20),
    type_code character varying(20) NOT NULL,
    geom public.geometry,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom))
);


ALTER TABLE cadastre.legal_space_utility_network OWNER TO postgres;

--
-- Name: TABLE legal_space_utility_network; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE legal_space_utility_network IS 'LADM Defintion: A utility network concerns legal space, which does not necessarily coincide with the physical space of a utility network. Implementation of the LADM LA_LegalSpaceUtilityNetwork class. Not used by SOLA. 
Tags: LADM Reference Object, Change History, Not Used';


--
-- Name: COLUMN legal_space_utility_network.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.id IS 'LADM Definition: Legal space utility network identifier.';


--
-- Name: COLUMN legal_space_utility_network.ext_physical_network_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.ext_physical_network_id IS 'LADM Definition: External identifier for a physical utility network.';


--
-- Name: COLUMN legal_space_utility_network.status_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.status_code IS 'LADM Definition: Status code for the legal space utility network.';


--
-- Name: COLUMN legal_space_utility_network.type_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.type_code IS 'LADM Definition: Type code for the legal space utility network.';


--
-- Name: COLUMN legal_space_utility_network.geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.geom IS 'LADM Definition: Not provided.';


--
-- Name: COLUMN legal_space_utility_network.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the legal_space_utility_network_historic table';


--
-- Name: COLUMN legal_space_utility_network.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN legal_space_utility_network.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN legal_space_utility_network.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN legal_space_utility_network.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: legal_space_utility_network_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE legal_space_utility_network_historic (
    id character varying(40),
    ext_physical_network_id character varying(40),
    status_code character varying(20),
    type_code character varying(20),
    geom public.geometry,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom))
);


ALTER TABLE cadastre.legal_space_utility_network_historic OWNER TO postgres;

--
-- Name: level; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE level (
    id character varying(40) NOT NULL,
    name character varying(50),
    register_type_code character varying(20) DEFAULT 'all'::character varying NOT NULL,
    structure_code character varying(20),
    type_code character varying(20),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    editable boolean DEFAULT false NOT NULL
);


ALTER TABLE cadastre.level OWNER TO postgres;

--
-- Name: TABLE level; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE level IS 'LADM Definition: A set of spatial units, with geometric, and/or topological, and/or thematic coherence. 
EXAMPLE 1 - One level for an urban cadastre and another level for a rural cadastre.
EXAMPLE 2 - One level with rights and another with restrictions.
EXAMPLE 3 - One level with formal rights, a second level with informal rights and a third level with customary rights.
EXAMPLE 4 - One level with point based spaital units, a second level with line based spatial units, and a third level with polygon based spatial features.
Implementation of the LADM LA_Level class. Used by SOLA to identify the set of spatial features for each layer displayed in the Map Viewer. 
Tags: Reference Table, LADM Reference Object, Change History';


--
-- Name: COLUMN level.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.id IS 'LADM Definition: Level identifier.';


--
-- Name: COLUMN level.name; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.name IS 'LADM Definition: The name of the level.';


--
-- Name: COLUMN level.register_type_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.register_type_code IS 'LADM Definition: The register type of the content of the level. E.g. all, forest, mining, rural, urban, etc';


--
-- Name: COLUMN level.structure_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.structure_code IS 'LADM Definition: Code for the structure of the level geometry. E.g. point, polygon, sketch, etc.';


--
-- Name: COLUMN level.type_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.type_code IS 'LADM Definition: The type of content of the level.';


--
-- Name: COLUMN level.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the level_historic table';


--
-- Name: COLUMN level.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN level.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN level.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN level.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: COLUMN level.editable; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.editable IS 'It shows if the spatial units of this level are editable from the spatial unit editor.';


--
-- Name: level_config_map_layer; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE level_config_map_layer (
    level_id character varying(40) NOT NULL,
    config_map_layer_name character varying(40) NOT NULL
);


ALTER TABLE cadastre.level_config_map_layer OWNER TO postgres;

--
-- Name: TABLE level_config_map_layer; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE level_config_map_layer IS 'It provides for each level which layers in the map are used for visualisation';


--
-- Name: level_content_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE level_content_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.level_content_type OWNER TO postgres;

--
-- Name: TABLE level_content_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE level_content_type IS 'Code list of level content types. E.g. geographicLocator, building, customary, primaryRight, etc. Implementation of the LADM LA_LevelContentType class. 
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN level_content_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level_content_type.code IS 'LADM Definition: The code for the level content type.';


--
-- Name: COLUMN level_content_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level_content_type.display_value IS 'LADM Definition: Displayed value of the level content type.';


--
-- Name: COLUMN level_content_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level_content_type.description IS 'LADM Definition: Description of the level content type.';


--
-- Name: COLUMN level_content_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level_content_type.status IS 'SOLA Extension: Status of the level content type';


--
-- Name: level_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE level_historic (
    id character varying(40),
    name character varying(50),
    register_type_code character varying(20),
    structure_code character varying(20),
    type_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    editable boolean DEFAULT false NOT NULL
);


ALTER TABLE cadastre.level_historic OWNER TO postgres;

--
-- Name: COLUMN level_historic.editable; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level_historic.editable IS 'It shows if the spatial units of this level are editable from the spatial unit editor.';


--
-- Name: spatial_unit; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit (
    id character varying(40) NOT NULL,
    dimension_code character varying(20) DEFAULT '2D'::character varying NOT NULL,
    label character varying(255),
    surface_relation_code character varying(20) DEFAULT 'onSurface'::character varying NOT NULL,
    level_id character varying(40),
    land_use_code character varying(20),
    reference_point public.geometry,
    geom public.geometry,
    transaction_id character varying(40),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_dims_reference_point CHECK ((public.st_ndims(reference_point) = 2)),
    CONSTRAINT enforce_geotype_reference_point CHECK (((public.geometrytype(reference_point) = 'POINT'::text) OR (reference_point IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_srid_reference_point CHECK ((public.st_srid(reference_point) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom)),
    CONSTRAINT enforce_valid_reference_point CHECK (public.st_isvalid(reference_point))
);


ALTER TABLE cadastre.spatial_unit OWNER TO postgres;

--
-- Name: TABLE spatial_unit; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE spatial_unit IS 'Single area (or multiple areas) of land, water or a single volume (or multiple volumes) of space. 
Implementation of the LADM LA_SpatialUnit class. Can be used by SOLA to represent geographic features such as place names and roading centrelines that are not considered as cadastre objects.  
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN spatial_unit.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.id IS 'LADM Definition: Spatial unit identifier.';


--
-- Name: COLUMN spatial_unit.dimension_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.dimension_code IS 'LADM Definition: Code for dimension.';


--
-- Name: COLUMN spatial_unit.label; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.label IS 'LADM Definition:  Label for the spatial unit. Used by SOLA as the label to display for the feature in the Map Viewer.';


--
-- Name: COLUMN spatial_unit.surface_relation_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.surface_relation_code IS 'LADM Definition: Code indicating if the spatial unit is above or below the surface.';


--
-- Name: COLUMN spatial_unit.level_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.level_id IS 'LADM Definition: The identifier for the level.';


--
-- Name: COLUMN spatial_unit.land_use_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.land_use_code IS 'SOLA Extension: Code to indicate the general purpose of the cadastre object. E.g. Commerical, Residential, Industrial, etc.';


--
-- Name: COLUMN spatial_unit.reference_point; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.reference_point IS 'LADM Definition: The coordinates of a point inside the spatial unit. Only used by SOLA to define point geometries like place names.';


--
-- Name: COLUMN spatial_unit.geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.geom IS 'SOLA Extension: The geometry for the spatial unit. Can be any geometry type.';


--
-- Name: COLUMN spatial_unit.transaction_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.transaction_id IS 'SOLA Extension: The identifier of the bulk operation transaction that loaded the spatial unit.';


--
-- Name: COLUMN spatial_unit.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the spatial_unit_historic table';


--
-- Name: COLUMN spatial_unit.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_unit.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_unit.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_unit.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: place_name; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW place_name AS
    SELECT su.id, su.label, su.geom FROM level l, spatial_unit su WHERE (((l.id)::text = (su.level_id)::text) AND ((l.name)::text = 'Place Names'::text));


ALTER TABLE cadastre.place_name OWNER TO postgres;

--
-- Name: VIEW place_name; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW place_name IS 'View for retrieving place name features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: register_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE register_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) NOT NULL
);


ALTER TABLE cadastre.register_type OWNER TO postgres;

--
-- Name: TABLE register_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE register_type IS 'Code list of register types. E.g. all, forest, mining, rural, urban, etc. Implementation of the LADM LA_RegisterType class. 
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN register_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN register_type.code IS 'LADM Definition: The code for the register type.';


--
-- Name: COLUMN register_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN register_type.display_value IS 'LADM Definition: Displayed value of the register type.';


--
-- Name: COLUMN register_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN register_type.description IS 'LADM Definition: Description of the register type.';


--
-- Name: COLUMN register_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN register_type.status IS 'SOLA Extension: Status of the register type';


--
-- Name: road; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW road AS
    SELECT su.id, su.label, su.geom FROM level l, spatial_unit su WHERE (((l.id)::text = (su.level_id)::text) AND ((l.name)::text = 'Roads'::text));


ALTER TABLE cadastre.road OWNER TO postgres;

--
-- Name: VIEW road; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW road IS 'View for retrieving road and road centreline features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: spatial_unit_address; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_address (
    spatial_unit_id character varying(40) NOT NULL,
    address_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE cadastre.spatial_unit_address OWNER TO postgres;

--
-- Name: TABLE spatial_unit_address; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE spatial_unit_address IS 'Associates a spatial unit to one or more address records. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN spatial_unit_address.spatial_unit_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.spatial_unit_id IS 'Spatial unit identifier.';


--
-- Name: COLUMN spatial_unit_address.address_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.address_id IS 'Address identifier';


--
-- Name: COLUMN spatial_unit_address.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.rowidentifier IS 'Identifies the all change records for the row in the spatial_unit_address_historic table';


--
-- Name: COLUMN spatial_unit_address.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_unit_address.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_unit_address.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_unit_address.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.change_time IS 'The date and time the row was last modified.';


--
-- Name: spatial_unit_address_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_address_historic (
    spatial_unit_id character varying(40),
    address_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE cadastre.spatial_unit_address_historic OWNER TO postgres;

--
-- Name: spatial_unit_group_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_group_historic (
    id character varying(40),
    hierarchy_level integer,
    label character varying(50),
    name character varying(50),
    reference_point public.geometry,
    geom public.geometry,
    found_in_spatial_unit_group_id character varying(40),
    seq_nr integer,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_dims_reference_point CHECK ((public.st_ndims(reference_point) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((public.geometrytype(geom) = 'POLYGON'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_geotype_reference_point CHECK (((public.geometrytype(reference_point) = 'POINT'::text) OR (reference_point IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_srid_reference_point CHECK ((public.st_srid(reference_point) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom)),
    CONSTRAINT enforce_valid_reference_point CHECK (public.st_isvalid(reference_point))
);


ALTER TABLE cadastre.spatial_unit_group_historic OWNER TO postgres;

--
-- Name: spatial_unit_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_historic (
    id character varying(40),
    dimension_code character varying(20),
    label character varying(255),
    surface_relation_code character varying(20),
    level_id character varying(40),
    land_use_code character varying(20),
    reference_point public.geometry,
    geom public.geometry,
    transaction_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_dims_reference_point CHECK ((public.st_ndims(reference_point) = 2)),
    CONSTRAINT enforce_geotype_reference_point CHECK (((public.geometrytype(reference_point) = 'POINT'::text) OR (reference_point IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_srid_reference_point CHECK ((public.st_srid(reference_point) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom)),
    CONSTRAINT enforce_valid_reference_point CHECK (public.st_isvalid(reference_point))
);


ALTER TABLE cadastre.spatial_unit_historic OWNER TO postgres;

--
-- Name: spatial_unit_in_group; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_in_group (
    spatial_unit_group_id character varying(40) NOT NULL,
    spatial_unit_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE cadastre.spatial_unit_in_group OWNER TO postgres;

--
-- Name: TABLE spatial_unit_in_group; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE spatial_unit_in_group IS 'Associates a spatial unit group to one or more spatial units.
Implementation of the LADM LA_SpatialUnitGroup and LA_SpatialUnit relationship.  
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN spatial_unit_in_group.spatial_unit_group_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.spatial_unit_group_id IS 'Spatial unit group identifier';


--
-- Name: COLUMN spatial_unit_in_group.spatial_unit_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.spatial_unit_id IS 'Spatial unit identifier.';


--
-- Name: COLUMN spatial_unit_in_group.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.rowidentifier IS 'Identifies the all change records for the row in the spatial_unit_in_group_historic table';


--
-- Name: COLUMN spatial_unit_in_group.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_unit_in_group.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_unit_in_group.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_unit_in_group.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.change_time IS 'The date and time the row was last modified.';


--
-- Name: spatial_unit_in_group_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_in_group_historic (
    spatial_unit_group_id character varying(40),
    spatial_unit_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE cadastre.spatial_unit_in_group_historic OWNER TO postgres;

--
-- Name: spatial_value_area_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_value_area_historic (
    spatial_unit_id character varying(40),
    type_code character varying(20),
    size numeric(29,2),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE cadastre.spatial_value_area_historic OWNER TO postgres;

--
-- Name: structure_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE structure_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.structure_type OWNER TO postgres;

--
-- Name: TABLE structure_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE structure_type IS 'Code list of structure types. E.g. point, polygon, sketch, text, etc. Implementation of the LADM LA_StructureType class. 
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN structure_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN structure_type.code IS 'LADM Definition: The code for the structure type.';


--
-- Name: COLUMN structure_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN structure_type.display_value IS 'LADM Definition: Displayed value of the structure type.';


--
-- Name: COLUMN structure_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN structure_type.description IS 'LADM Definition: Description of the structure type.';


--
-- Name: COLUMN structure_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN structure_type.status IS 'SOLA Extension: Status of the structure type';


--
-- Name: surface_relation_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE surface_relation_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.surface_relation_type OWNER TO postgres;

--
-- Name: TABLE surface_relation_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE surface_relation_type IS 'Code list of surface relation types. E.g. onSurface, above, below, mixed, etc. Implementation of the LADM LA_SurfaceRelationType class. 
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN surface_relation_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN surface_relation_type.code IS 'LADM Definition: The code for the surface relation type.';


--
-- Name: COLUMN surface_relation_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN surface_relation_type.display_value IS 'LADM Definition: Displayed value of the surface relation type.';


--
-- Name: COLUMN surface_relation_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN surface_relation_type.description IS 'LADM Definition: Description of the surface relation type.';


--
-- Name: COLUMN surface_relation_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN surface_relation_type.status IS 'SOLA Extension: Status of the surface relation type';


--
-- Name: survey_control; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW survey_control AS
    SELECT su.id, su.label, su.geom FROM level l, spatial_unit su WHERE (((l.id)::text = (su.level_id)::text) AND ((l.name)::text = 'Survey Control'::text));


ALTER TABLE cadastre.survey_control OWNER TO postgres;

--
-- Name: VIEW survey_control; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW survey_control IS 'View for retrieving survey control features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: survey_point; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE survey_point (
    transaction_id character varying(40) NOT NULL,
    id character varying(40) NOT NULL,
    boundary boolean DEFAULT true NOT NULL,
    linked boolean DEFAULT false NOT NULL,
    geom public.geometry NOT NULL,
    original_geom public.geometry NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_dims_original_geom CHECK ((public.st_ndims(original_geom) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((public.geometrytype(geom) = 'POINT'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_geotype_original_geom CHECK (((public.geometrytype(original_geom) = 'POINT'::text) OR (original_geom IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_srid_original_geom CHECK ((public.st_srid(original_geom) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom)),
    CONSTRAINT enforce_valid_original_geom CHECK (public.st_isvalid(original_geom))
);


ALTER TABLE cadastre.survey_point OWNER TO postgres;

--
-- Name: TABLE survey_point; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE survey_point IS 'Used to store new survey point details (i.e. boundary and traverse) when capturing a survey plan into SOLA. Survey points can be used to define new cadastre objects. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN survey_point.transaction_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.transaction_id IS 'Identifier of the transaction that created the survey point.';


--
-- Name: COLUMN survey_point.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.id IS 'Identifier for the survey point.';


--
-- Name: COLUMN survey_point.boundary; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.boundary IS 'Flag to indicate if the survey point is a boundary point (true) or traverse point (false).';


--
-- Name: COLUMN survey_point.linked; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.linked IS 'Flag to indicate if the new survey point has been linked to an existing cadastre object boundary node.';


--
-- Name: COLUMN survey_point.geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.geom IS 'Geometry representing the current position of the survey point.';


--
-- Name: COLUMN survey_point.original_geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.original_geom IS 'Geometry representing the original position of the survey point i.e. before it was linked to an existing cadastre object boundary node.';


--
-- Name: COLUMN survey_point.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.rowidentifier IS 'Identifies the all change records for the row in the survey_point_historic table';


--
-- Name: COLUMN survey_point.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN survey_point.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN survey_point.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN survey_point.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.change_time IS 'The date and time the row was last modified.';


--
-- Name: survey_point_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE survey_point_historic (
    transaction_id character varying(40),
    id character varying(40),
    boundary boolean,
    linked boolean,
    geom public.geometry,
    original_geom public.geometry,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_dims_original_geom CHECK ((public.st_ndims(original_geom) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((public.geometrytype(geom) = 'POINT'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_geotype_original_geom CHECK (((public.geometrytype(original_geom) = 'POINT'::text) OR (original_geom IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_srid_original_geom CHECK ((public.st_srid(original_geom) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom)),
    CONSTRAINT enforce_valid_original_geom CHECK (public.st_isvalid(original_geom))
);


ALTER TABLE cadastre.survey_point_historic OWNER TO postgres;

--
-- Name: utility_network_status_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE utility_network_status_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.utility_network_status_type OWNER TO postgres;

--
-- Name: TABLE utility_network_status_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE utility_network_status_type IS 'Code list of utility network status types. E.g. inUse, outOfUse, planned, etc. 
Implementation of the LADM LA_UtilityNetworkStatusType class. Not used by SOLA.
Tags: Reference Table, LADM Reference Object, Not Used';


--
-- Name: COLUMN utility_network_status_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_status_type.code IS 'LADM Definition: The code for the utility network status type.';


--
-- Name: COLUMN utility_network_status_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_status_type.display_value IS 'LADM Definition: Displayed value of the utility network status type.';


--
-- Name: COLUMN utility_network_status_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_status_type.description IS 'LADM Definition: Description of the utility network status type.';


--
-- Name: COLUMN utility_network_status_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_status_type.status IS 'SOLA Extension: Status of the utility network status type';


--
-- Name: utility_network_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE utility_network_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) NOT NULL
);


ALTER TABLE cadastre.utility_network_type OWNER TO postgres;

--
-- Name: TABLE utility_network_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE utility_network_type IS 'Code list of utility network types. E.g. gas, oil, water, etc. 
Implementation of the LADM LA_UtilityNetworkType class. Not used by SOLA.
Tags: Reference Table, LADM Reference Object, Not Used';


--
-- Name: COLUMN utility_network_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_type.code IS 'LADM Definition: The code for the utility network type.';


--
-- Name: COLUMN utility_network_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_type.display_value IS 'LADM Definition: Displayed value of the utility network type.';


--
-- Name: COLUMN utility_network_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_type.description IS 'LADM Definition: Description of the utility network type.';


--
-- Name: COLUMN utility_network_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_type.status IS 'SOLA Extension: Status of the utility network type';


SET search_path = document, pg_catalog;

--
-- Name: document; Type: TABLE; Schema: document; Owner: postgres; Tablespace: 
--

CREATE TABLE document (
    id character varying(40) NOT NULL,
    nr character varying(15) NOT NULL,
    extension character varying(5) NOT NULL,
    mime_type character varying(255),
    body bytea NOT NULL,
    description character varying(100),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE document.document OWNER TO postgres;

--
-- Name: TABLE document; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON TABLE document IS 'Extension to the LADM used by SOLA to store electronic copies of documentation provided in support of land related dealings.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN document.id; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.id IS 'Identifier for the document.';


--
-- Name: COLUMN document.nr; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.nr IS 'Unique number to identify the document. Determined by the Digital Archive EJB when saving the document record.';


--
-- Name: COLUMN document.extension; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.extension IS 'The file extension of the electronic file. E.g. pdf, tiff, doc, etc';


--
-- Name: COLUMN document.mime_type; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.mime_type IS 'Mime type of the file.';


--
-- Name: COLUMN document.body; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.body IS 'The content of the electronic file.';


--
-- Name: COLUMN document.description; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.description IS 'A descriptive name to help recognizs the file such as the original file name.';


--
-- Name: COLUMN document.rowidentifier; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.rowidentifier IS 'Identifies the all change records for the row in the document_historic table';


--
-- Name: COLUMN document.rowversion; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN document.change_action; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN document.change_user; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN document.change_time; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.change_time IS 'The date and time the row was last modified.';


--
-- Name: document_chunk; Type: TABLE; Schema: document; Owner: postgres; Tablespace: 
--

CREATE TABLE document_chunk (
    id character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    document_id character varying(40) NOT NULL,
    claim_id character varying(40),
    start_position bigint NOT NULL,
    size bigint NOT NULL,
    body bytea NOT NULL,
    md5 character varying(50),
    creation_time timestamp without time zone DEFAULT now() NOT NULL,
    user_name character varying(50) NOT NULL
);


ALTER TABLE document.document_chunk OWNER TO postgres;

--
-- Name: TABLE document_chunk; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON TABLE document_chunk IS 'Holds temporary pieces of a document uploaded on the server. In case of large files, document can be split into smaller pieces (chunks) allowing reliable upload. After all pieces uploaded, client will instruct server to create a document and remove temporary files stored in this table.';


--
-- Name: COLUMN document_chunk.id; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_chunk.id IS 'Unique ID of the chunk';


--
-- Name: COLUMN document_chunk.document_id; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_chunk.document_id IS 'Document ID, which will be used to create final document object. Used to group all chunks together.';


--
-- Name: COLUMN document_chunk.claim_id; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_chunk.claim_id IS 'Claim ID. Used to clean the table when saving claim. It will guarantee that no orphan chunks left in the table.';


--
-- Name: COLUMN document_chunk.start_position; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_chunk.start_position IS 'Staring position of the byte in the source/destination document';


--
-- Name: COLUMN document_chunk.size; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_chunk.size IS 'Size of the chunk in bytes.';


--
-- Name: COLUMN document_chunk.body; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_chunk.body IS 'The content of the chunk.';


--
-- Name: COLUMN document_chunk.md5; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_chunk.md5 IS 'Checksum of the chunk, calculated using MD5.';


--
-- Name: COLUMN document_chunk.creation_time; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_chunk.creation_time IS 'Date and time when chuck was created.';


--
-- Name: COLUMN document_chunk.user_name; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_chunk.user_name IS 'User''s id (name), who has loaded the chunk';


--
-- Name: document_historic; Type: TABLE; Schema: document; Owner: postgres; Tablespace: 
--

CREATE TABLE document_historic (
    id character varying(40),
    nr character varying(15),
    extension character varying(5),
    mime_type character varying(255),
    body bytea,
    description character varying(100),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE document.document_historic OWNER TO postgres;

--
-- Name: document_nr_seq; Type: SEQUENCE; Schema: document; Owner: postgres
--

CREATE SEQUENCE document_nr_seq
    START WITH 100
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 99999999
    CACHE 1
    CYCLE;


ALTER TABLE document.document_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE document_nr_seq; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON SEQUENCE document_nr_seq IS 'Sequence number used as the basis for the document Nr field. This sequence is used by the Digital Archive EJB.';


SET search_path = opentenure, pg_catalog;

--
-- Name: attachment; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE attachment (
    id character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    type_code character varying(20) NOT NULL,
    reference_nr character varying(255),
    document_date date,
    description character varying(255),
    body bytea NOT NULL,
    size bigint NOT NULL,
    mime_type character varying(255) NOT NULL,
    file_name character varying(255) NOT NULL,
    file_extension character varying(5) NOT NULL,
    user_name character varying(50) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.attachment OWNER TO postgres;

--
-- Name: TABLE attachment; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE attachment IS 'Extension to the LADM used by SOLA to store claim files attachments.';


--
-- Name: COLUMN attachment.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.id IS 'Identifier for the attachment.';


--
-- Name: COLUMN attachment.type_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.type_code IS 'Attached document type code.';


--
-- Name: COLUMN attachment.reference_nr; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.reference_nr IS 'Document reference number.';


--
-- Name: COLUMN attachment.document_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.document_date IS 'Document date.';


--
-- Name: COLUMN attachment.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.description IS 'Short document description.';


--
-- Name: COLUMN attachment.body; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.body IS 'Binary content of the attachment.';


--
-- Name: COLUMN attachment.size; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.size IS 'File size.';


--
-- Name: COLUMN attachment.mime_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.mime_type IS 'Mime type of the attachment.';


--
-- Name: COLUMN attachment.file_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.file_name IS 'Actual file name of the attachment.';


--
-- Name: COLUMN attachment.file_extension; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.file_extension IS 'File extension of the attachment. E.g. pdf, tiff, doc, etc';


--
-- Name: COLUMN attachment.user_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.user_name IS 'User''s ID, who has created the attachment.';


--
-- Name: COLUMN attachment.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.rowidentifier IS 'Identifies the all change records for the row in the document_historic table';


--
-- Name: COLUMN attachment.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN attachment.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN attachment.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN attachment.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment.change_time IS 'The date and time the row was last modified.';


--
-- Name: attachment_chunk; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE attachment_chunk (
    id character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    attachment_id character varying(40) NOT NULL,
    claim_id character varying(40),
    start_position bigint NOT NULL,
    size bigint NOT NULL,
    body bytea NOT NULL,
    md5 character varying(50),
    creation_time timestamp without time zone DEFAULT now() NOT NULL,
    user_name character varying(50) NOT NULL
);


ALTER TABLE opentenure.attachment_chunk OWNER TO postgres;

--
-- Name: TABLE attachment_chunk; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE attachment_chunk IS 'Holds temporary pieces of attachment uploaded on the server. In case of large files, document can be split into smaller pieces (chunks) allowing reliable upload. After all pieces uploaded, client will instruct server to create a document and remove temporary files stored in this table.';


--
-- Name: COLUMN attachment_chunk.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.id IS 'Unique ID of the chunk';


--
-- Name: COLUMN attachment_chunk.attachment_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.attachment_id IS 'Attachment ID, which will be used to create final document object. Used to group all chunks together.';


--
-- Name: COLUMN attachment_chunk.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.claim_id IS 'Claim ID. Used to clean the table when saving claim. It will guarantee that no orphan chunks left in the table.';


--
-- Name: COLUMN attachment_chunk.start_position; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.start_position IS 'Staring position of the byte in the source/destination document';


--
-- Name: COLUMN attachment_chunk.size; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.size IS 'Size of the chunk in bytes.';


--
-- Name: COLUMN attachment_chunk.body; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.body IS 'The content of the chunk.';


--
-- Name: COLUMN attachment_chunk.md5; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.md5 IS 'Checksum of the chunk, calculated using MD5.';


--
-- Name: COLUMN attachment_chunk.creation_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.creation_time IS 'Date and time when chuck was created.';


--
-- Name: COLUMN attachment_chunk.user_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN attachment_chunk.user_name IS 'User''s id (name), who has loaded the chunk';


--
-- Name: attachment_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE attachment_historic (
    id character varying(40),
    type_code character varying(20),
    reference_nr character varying(255),
    document_date date,
    description character varying(255),
    body bytea,
    size bigint,
    mime_type character varying(255),
    file_name character varying(255),
    file_extension character varying(5),
    user_name character varying(50),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.attachment_historic OWNER TO postgres;

--
-- Name: TABLE attachment_historic; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE attachment_historic IS 'Historic table for opentenure.attachment. Keeps all changes done to the main table.';


--
-- Name: claim; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim (
    id character varying(40) NOT NULL,
    nr character varying(15) NOT NULL,
    lodgement_date timestamp without time zone,
    challenge_expiry_date timestamp without time zone,
    decision_date timestamp without time zone,
    description character varying(250),
    challenged_claim_id character varying(40),
    claimant_id character varying(40) NOT NULL,
    mapped_geometry public.geometry,
    gps_geometry public.geometry,
    status_code character varying(20) DEFAULT 'created'::character varying NOT NULL,
    recorder_name character varying(50) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    type_code character varying(20),
    start_date date,
    land_use_code character varying(20),
    notes character varying(1000),
    north_adjacency character varying(500),
    south_adjacency character varying(500),
    east_adjacency character varying(500),
    west_adjacency character varying(500),
    assignee_name character varying(50),
    rejection_reason_code character varying(20),
    claim_area bigint DEFAULT 0,
    CONSTRAINT enforce_geotype_gps_geometry CHECK ((((public.geometrytype(gps_geometry) = 'POLYGON'::text) OR (public.geometrytype(gps_geometry) = 'POINT'::text)) OR (gps_geometry IS NULL))),
    CONSTRAINT enforce_geotype_mapped_geometry CHECK ((((public.geometrytype(mapped_geometry) = 'POLYGON'::text) OR (public.geometrytype(mapped_geometry) = 'POINT'::text)) OR (mapped_geometry IS NULL))),
    CONSTRAINT enforce_valid_gps_geometry CHECK (public.st_isvalid(gps_geometry)),
    CONSTRAINT enforce_valid_mapped_geometry CHECK (public.st_isvalid(mapped_geometry))
);


ALTER TABLE opentenure.claim OWNER TO postgres;

--
-- Name: TABLE claim; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE claim IS 'Main table to store claim and claim challenge information submitted by the community recorders. SOLA Open Tenure extention.';


--
-- Name: COLUMN claim.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.id IS 'Identifier for the claim.';


--
-- Name: COLUMN claim.nr; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.nr IS 'Auto generated claim number. Generated by the generate-claim-nr business rule when the claim record is initially saved.';


--
-- Name: COLUMN claim.lodgement_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.lodgement_date IS 'The lodgement date and time of the claim.';


--
-- Name: COLUMN claim.challenge_expiry_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.challenge_expiry_date IS 'Expiration date when challenge claim can be submitted.';


--
-- Name: COLUMN claim.decision_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.decision_date IS 'The decision date on the claim by the authority.';


--
-- Name: COLUMN claim.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.description IS 'Free description of the claim.';


--
-- Name: COLUMN claim.challenged_claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.challenged_claim_id IS 'The identifier of the challenged claim. If this value is provided, it means the record is a claim challenge type.';


--
-- Name: COLUMN claim.claimant_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.claimant_id IS 'The identifier of the claimant.';


--
-- Name: COLUMN claim.mapped_geometry; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.mapped_geometry IS 'Claimed property geometry calculated using system SRID';


--
-- Name: COLUMN claim.gps_geometry; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.gps_geometry IS 'Claimed property geometry in Lat/Long format';


--
-- Name: COLUMN claim.status_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.status_code IS 'The status of the claim.';


--
-- Name: COLUMN claim.recorder_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.recorder_name IS 'User''s ID, who has created the claim.';


--
-- Name: COLUMN claim.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.rowidentifier IS 'Identifies the all change records for the row in the claim_historic table.';


--
-- Name: COLUMN claim.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN claim.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN claim.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN claim.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN claim.type_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.type_code IS 'Type of claim (e.g. ownership, usufruct, occupation).';


--
-- Name: COLUMN claim.start_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.start_date IS 'Start date of right (occupation)';


--
-- Name: COLUMN claim.land_use_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.land_use_code IS 'Land use code';


--
-- Name: COLUMN claim.notes; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.notes IS 'Any note that could be usefully stored as part of the claim';


--
-- Name: COLUMN claim.north_adjacency; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.north_adjacency IS 'Optional information about adjacency on the north';


--
-- Name: COLUMN claim.south_adjacency; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.south_adjacency IS 'Optional information about adjacency on the south';


--
-- Name: COLUMN claim.east_adjacency; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.east_adjacency IS 'Optional information about adjacency on the east';


--
-- Name: COLUMN claim.west_adjacency; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.west_adjacency IS 'Optional information about adjacency on the west';


--
-- Name: COLUMN claim.assignee_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.assignee_name IS 'User name who is assigned to work with claim';


--
-- Name: COLUMN claim.rejection_reason_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.rejection_reason_code IS 'Rejection reason code.';


--
-- Name: COLUMN claim.claim_area; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.claim_area IS 'Claim area in square meters.';


--
-- Name: claim_comment; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_comment (
    id character varying(40) NOT NULL,
    claim_id character varying(40) NOT NULL,
    comment character varying(500) NOT NULL,
    comment_user character varying(50) NOT NULL,
    creation_time timestamp without time zone DEFAULT now() NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.claim_comment OWNER TO postgres;

--
-- Name: COLUMN claim_comment.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.id IS 'Identifier for the claim comment.';


--
-- Name: COLUMN claim_comment.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.claim_id IS 'Identifier for the claim.';


--
-- Name: COLUMN claim_comment.comment; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.comment IS 'Comment text.';


--
-- Name: COLUMN claim_comment.comment_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.comment_user IS 'The user id who has created comment.';


--
-- Name: COLUMN claim_comment.creation_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.creation_time IS 'The date and time when comment was created.';


--
-- Name: COLUMN claim_comment.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.rowidentifier IS 'Identifies the all change records for the row in the claim_historic table.';


--
-- Name: COLUMN claim_comment.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN claim_comment.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN claim_comment.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN claim_comment.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_comment.change_time IS 'The date and time the row was last modified.';


--
-- Name: claim_comment_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_comment_historic (
    id character varying(40),
    claim_id character varying(40),
    comment character varying(500),
    comment_user character varying(50),
    creation_time timestamp without time zone,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.claim_comment_historic OWNER TO postgres;

--
-- Name: claim_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_historic (
    id character varying(40),
    nr character varying(15),
    lodgement_date timestamp without time zone,
    challenge_expiry_date timestamp without time zone,
    decision_date timestamp without time zone,
    description character varying(250),
    challenged_claim_id character varying(40),
    claimant_id character varying(40),
    mapped_geometry public.geometry,
    gps_geometry public.geometry,
    status_code character varying(20),
    recorder_name character varying(50),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    type_code character varying(20),
    notes character varying(1000),
    start_date date,
    north_adjacency character varying(500),
    south_adjacency character varying(500),
    east_adjacency character varying(500),
    west_adjacency character varying(500),
    assignee_name character varying(50),
    land_use_code character varying(20),
    rejection_reason_code character varying(20),
    claim_area bigint
);


ALTER TABLE opentenure.claim_historic OWNER TO postgres;

--
-- Name: TABLE claim_historic; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE claim_historic IS 'Historic table for the main table with claims opentenure.claim. Keeps all changes done to the main table.';


--
-- Name: claim_location; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_location (
    id character varying(40) NOT NULL,
    claim_id character varying(40) NOT NULL,
    mapped_location public.geometry NOT NULL,
    gps_location public.geometry,
    description character varying(500),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_geotype_gps_location CHECK ((((public.geometrytype(gps_location) = 'POLYGON'::text) OR (public.geometrytype(gps_location) = 'POINT'::text)) OR (gps_location IS NULL))),
    CONSTRAINT enforce_geotype_mapped_location CHECK (((public.geometrytype(mapped_location) = 'POLYGON'::text) OR (public.geometrytype(mapped_location) = 'POINT'::text))),
    CONSTRAINT enforce_valid_gps_location CHECK (public.st_isvalid(gps_location)),
    CONSTRAINT enforce_valid_mapped_location CHECK (public.st_isvalid(mapped_location))
);


ALTER TABLE opentenure.claim_location OWNER TO postgres;

--
-- Name: COLUMN claim_location.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.id IS 'Identifier for the claim location.';


--
-- Name: COLUMN claim_location.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.claim_id IS 'Identifier for the claim.';


--
-- Name: COLUMN claim_location.mapped_location; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.mapped_location IS 'Additional claim location geometry.';


--
-- Name: COLUMN claim_location.gps_location; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.gps_location IS 'Additional claim location geometry in Lat/Long format.';


--
-- Name: COLUMN claim_location.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.description IS 'Claim location description.';


--
-- Name: COLUMN claim_location.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.rowidentifier IS 'Identifies the all change records for the row in the claim_historic table.';


--
-- Name: COLUMN claim_location.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN claim_location.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN claim_location.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN claim_location.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_location.change_time IS 'The date and time the row was last modified.';


--
-- Name: claim_location_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_location_historic (
    id character varying(40),
    claim_id character varying(40),
    mapped_location public.geometry,
    gps_location public.geometry,
    description character varying(500),
    rowidentifier character varying(40),
    rowversion integer NOT NULL,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.claim_location_historic OWNER TO postgres;

--
-- Name: claim_nr_seq; Type: SEQUENCE; Schema: opentenure; Owner: postgres
--

CREATE SEQUENCE claim_nr_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999
    CACHE 1
    CYCLE;


ALTER TABLE opentenure.claim_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE claim_nr_seq; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON SEQUENCE claim_nr_seq IS 'Sequence number used as the basis for the claim nr field. This sequence is used by the generate-claim-nr business rule.';


--
-- Name: claim_share; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_share (
    id character varying(40) NOT NULL,
    claim_id character varying(40) NOT NULL,
    nominator smallint,
    denominator smallint,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    percentage double precision
);


ALTER TABLE opentenure.claim_share OWNER TO postgres;

--
-- Name: TABLE claim_share; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE claim_share IS 'Identifies the share a party has in a claim.';


--
-- Name: COLUMN claim_share.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.id IS 'Identifier for the claim share.';


--
-- Name: COLUMN claim_share.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.claim_id IS 'Identifier of the claim the share is assocaited with.';


--
-- Name: COLUMN claim_share.nominator; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.nominator IS 'Nominiator part of the share (i.e. top number of fraction)';


--
-- Name: COLUMN claim_share.denominator; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.denominator IS 'Denominator part of the share (i.e. bottom number of fraction)';


--
-- Name: COLUMN claim_share.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.rowidentifier IS 'Identifies the all change records for the row in the claim_share_historic table';


--
-- Name: COLUMN claim_share.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN claim_share.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN claim_share.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN claim_share.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN claim_share.percentage; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.percentage IS 'Percentage of the share. Another form of nominator/denominator presentation.';


--
-- Name: claim_share_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_share_historic (
    id character varying(40),
    claim_id character varying(40),
    nominator smallint,
    denominator smallint,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    percentage double precision
);


ALTER TABLE opentenure.claim_share_historic OWNER TO postgres;

--
-- Name: claim_status; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_status (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE opentenure.claim_status OWNER TO postgres;

--
-- Name: TABLE claim_status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE claim_status IS 'Code list of claim status.';


--
-- Name: COLUMN claim_status.code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_status.code IS 'The code for the claim status.';


--
-- Name: COLUMN claim_status.display_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_status.display_value IS 'Displayed value of the claim status.';


--
-- Name: COLUMN claim_status.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_status.status IS 'Status of the service claim.';


--
-- Name: COLUMN claim_status.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_status.description IS 'Description of the claim status.';


--
-- Name: claim_uses_attachment; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_uses_attachment (
    claim_id character varying(40) NOT NULL,
    attachment_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.claim_uses_attachment OWNER TO postgres;

--
-- Name: TABLE claim_uses_attachment; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE claim_uses_attachment IS 'Links the claim to the attachment submitted with the claim. SOLA Open Tenure extension.';


--
-- Name: COLUMN claim_uses_attachment.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.claim_id IS 'Identifier for the claim the record is associated to.';


--
-- Name: COLUMN claim_uses_attachment.attachment_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.attachment_id IS 'Identifier of the attachment associated to the claim.';


--
-- Name: COLUMN claim_uses_attachment.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.rowidentifier IS 'Unique row identifier.';


--
-- Name: COLUMN claim_uses_attachment.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN claim_uses_attachment.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN claim_uses_attachment.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN claim_uses_attachment.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_uses_attachment.change_time IS 'The date and time the row was last modified.';


--
-- Name: claim_uses_attachment_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE claim_uses_attachment_historic (
    claim_id character varying(40),
    attachment_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer NOT NULL,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.claim_uses_attachment_historic OWNER TO postgres;

--
-- Name: TABLE claim_uses_attachment_historic; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE claim_uses_attachment_historic IS 'Historic table for opentenure.claim_uses_attachment. Keeps all changes done to the main table.';


--
-- Name: field_constraint; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_constraint (
    id character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    error_msg character varying(255) NOT NULL,
    format character varying(255),
    min_value numeric(20,10),
    max_value numeric(20,10),
    field_constraint_type character varying(255) NOT NULL,
    field_template_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.field_constraint OWNER TO postgres;

--
-- Name: TABLE field_constraint; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_constraint IS 'Dynamic form field constraint.';


--
-- Name: COLUMN field_constraint.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.id IS 'Primary key.';


--
-- Name: COLUMN field_constraint.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.name IS 'Field name to be used as UI component name.';


--
-- Name: COLUMN field_constraint.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.display_name IS 'Value to be used as a visible text (header) of UI component.';


--
-- Name: COLUMN field_constraint.error_msg; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.error_msg IS 'Error message to display in case of constraint violation.';


--
-- Name: COLUMN field_constraint.format; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.format IS 'Regular expression, used to check field value';


--
-- Name: COLUMN field_constraint.min_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.min_value IS 'Minimum field value, used in range constraint.';


--
-- Name: COLUMN field_constraint.max_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.max_value IS 'Maximum field value, used in range constraint.';


--
-- Name: COLUMN field_constraint.field_constraint_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.field_constraint_type IS 'Type of constraint.';


--
-- Name: COLUMN field_constraint.field_template_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint.field_template_id IS 'Field template id, which constraint relates to.';


--
-- Name: field_constraint_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_constraint_historic (
    id character varying(40),
    name character varying(255),
    display_name character varying(255),
    error_msg character varying(255),
    format character varying(255),
    min_value numeric(20,10),
    max_value numeric(20,10),
    field_constraint_type character varying(255),
    field_template_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.field_constraint_historic OWNER TO postgres;

--
-- Name: field_constraint_option; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_constraint_option (
    id character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    field_constraint_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.field_constraint_option OWNER TO postgres;

--
-- Name: TABLE field_constraint_option; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_constraint_option IS 'Dynamic form field constraint option, used to limit field values.';


--
-- Name: COLUMN field_constraint_option.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.id IS 'Primary key.';


--
-- Name: COLUMN field_constraint_option.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.name IS 'Field name to be used as UI component name.';


--
-- Name: COLUMN field_constraint_option.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.display_name IS 'Value to be used as a visible text of UI component.';


--
-- Name: COLUMN field_constraint_option.field_constraint_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.field_constraint_id IS 'Field constraint ID.';


--
-- Name: COLUMN field_constraint_option.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN field_constraint_option.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN field_constraint_option.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN field_constraint_option.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN field_constraint_option.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_option.change_time IS 'The date and time the row was last modified.';


--
-- Name: field_constraint_option_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_constraint_option_historic (
    id character varying(40),
    name character varying(255),
    display_name character varying(255),
    field_constraint_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.field_constraint_option_historic OWNER TO postgres;

--
-- Name: field_constraint_type; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_constraint_type (
    code character varying(255) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 'c'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE opentenure.field_constraint_type OWNER TO postgres;

--
-- Name: TABLE field_constraint_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_constraint_type IS 'Reference table for the field constraint types, used in dynamic forms.';


--
-- Name: COLUMN field_constraint_type.code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_type.code IS 'The code for the constraint type.';


--
-- Name: COLUMN field_constraint_type.display_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_type.display_value IS 'Displayed value of the constraint type.';


--
-- Name: COLUMN field_constraint_type.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_type.status IS 'Status of the constraint type.';


--
-- Name: COLUMN field_constraint_type.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_constraint_type.description IS 'Description of the constraint type.';


--
-- Name: field_payload; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_payload (
    id character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    field_type character varying(255) NOT NULL,
    section_element_payload_id character varying(40) NOT NULL,
    string_payload character varying(2048),
    big_decimal_payload numeric(20,10),
    boolean_payload boolean,
    field_value_type character varying(255) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.field_payload OWNER TO postgres;

--
-- Name: TABLE field_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_payload IS 'Dynamic form field payload.';


--
-- Name: COLUMN field_payload.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.id IS 'Primary key.';


--
-- Name: COLUMN field_payload.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.name IS 'Field name to be used as UI component name.';


--
-- Name: COLUMN field_payload.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.display_name IS 'Value to be used as a visible text of UI component.';


--
-- Name: COLUMN field_payload.field_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.field_type IS 'Field type code.';


--
-- Name: COLUMN field_payload.section_element_payload_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.section_element_payload_id IS 'Section element id.';


--
-- Name: COLUMN field_payload.string_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.string_payload IS 'String field value.';


--
-- Name: COLUMN field_payload.big_decimal_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.big_decimal_payload IS 'Decimal or integer field value.';


--
-- Name: COLUMN field_payload.boolean_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.boolean_payload IS 'Boolean field value.';


--
-- Name: COLUMN field_payload.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN field_payload.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN field_payload.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN field_payload.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN field_payload.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_payload.change_time IS 'The date and time the row was last modified.';


--
-- Name: field_payload_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_payload_historic (
    id character varying(40),
    name character varying(255),
    display_name character varying(255),
    field_type character varying(255),
    section_element_payload_id character varying(40),
    string_payload character varying(2048),
    big_decimal_payload numeric(20,10),
    boolean_payload boolean,
    field_value_type character varying(255),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.field_payload_historic OWNER TO postgres;

--
-- Name: field_template; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_template (
    id character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    hint character varying(255),
    field_type character varying(255) NOT NULL,
    section_template_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.field_template OWNER TO postgres;

--
-- Name: TABLE field_template; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_template IS 'Dynamic form field template.';


--
-- Name: COLUMN field_template.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.id IS 'Primary key.';


--
-- Name: COLUMN field_template.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.name IS 'Field name to be used as UI component name.';


--
-- Name: COLUMN field_template.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.display_name IS 'Value to be used as a visible text (header) of UI component.';


--
-- Name: COLUMN field_template.hint; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.hint IS 'Field hint to be used for UI component.';


--
-- Name: COLUMN field_template.field_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.field_type IS 'Field type code.';


--
-- Name: COLUMN field_template.section_template_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.section_template_id IS 'Section template ID.';


--
-- Name: COLUMN field_template.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN field_template.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN field_template.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN field_template.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN field_template.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_template.change_time IS 'The date and time the row was last modified.';


--
-- Name: field_template_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_template_historic (
    id character varying(40),
    name character varying(255),
    display_name character varying(255),
    hint character varying(255),
    field_type character varying(255),
    section_template_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.field_template_historic OWNER TO postgres;

--
-- Name: field_type; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_type (
    code character varying(255) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 'c'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE opentenure.field_type OWNER TO postgres;

--
-- Name: TABLE field_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_type IS 'Reference table for the field types, used in dynamic forms.';


--
-- Name: COLUMN field_type.code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_type.code IS 'The code for the field type.';


--
-- Name: COLUMN field_type.display_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_type.display_value IS 'Displayed value of the field type.';


--
-- Name: COLUMN field_type.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_type.status IS 'Status of the field type.';


--
-- Name: COLUMN field_type.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_type.description IS 'Description of the field type.';


--
-- Name: field_value_type; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE field_value_type (
    code character varying(255) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 'c'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE opentenure.field_value_type OWNER TO postgres;

--
-- Name: TABLE field_value_type; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE field_value_type IS 'Reference table for the field value types, used in dynamic forms.';


--
-- Name: COLUMN field_value_type.code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_value_type.code IS 'The code for the field value type.';


--
-- Name: COLUMN field_value_type.display_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_value_type.display_value IS 'Displayed value of the field value type.';


--
-- Name: COLUMN field_value_type.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_value_type.status IS 'Status of the field value type.';


--
-- Name: COLUMN field_value_type.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN field_value_type.description IS 'Description of the field value type.';


--
-- Name: form_payload; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE form_payload (
    id character varying(40) NOT NULL,
    claim_id character varying(40) NOT NULL,
    form_template_name character varying(255) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.form_payload OWNER TO postgres;

--
-- Name: TABLE form_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE form_payload IS 'Dynamic form payload.';


--
-- Name: COLUMN form_payload.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.id IS 'Primary key.';


--
-- Name: COLUMN form_payload.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.claim_id IS 'Foreign key to the parent claim object.';


--
-- Name: COLUMN form_payload.form_template_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.form_template_name IS 'Foreign key to relevant dynamic form template.';


--
-- Name: COLUMN form_payload.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN form_payload.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN form_payload.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN form_payload.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN form_payload.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_payload.change_time IS 'The date and time the row was last modified.';


--
-- Name: form_payload_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE form_payload_historic (
    id character varying(40),
    claim_id character varying(40),
    form_template_name character varying(255),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.form_payload_historic OWNER TO postgres;

--
-- Name: form_template; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE form_template (
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.form_template OWNER TO postgres;

--
-- Name: TABLE form_template; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE form_template IS 'Dynamic form template.';


--
-- Name: COLUMN form_template.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.display_name IS 'Form name, which can be used for displaying on the UI.';


--
-- Name: COLUMN form_template.is_default; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.is_default IS 'Indicates whether form is default for all new claims.';


--
-- Name: COLUMN form_template.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN form_template.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN form_template.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN form_template.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN form_template.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN form_template.change_time IS 'The date and time the row was last modified.';


--
-- Name: form_template_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE form_template_historic (
    name character varying(255),
    display_name character varying(255),
    is_default boolean,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.form_template_historic OWNER TO postgres;

--
-- Name: party; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE party (
    id character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    name character varying(255) NOT NULL,
    last_name character varying(50),
    id_type_code character varying(20),
    id_number character varying(20),
    birth_date date,
    gender_code character varying(20),
    mobile_phone character varying(15),
    phone character varying(15),
    email character varying(50),
    address character varying(255),
    user_name character varying(50) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    is_person boolean DEFAULT true NOT NULL
);


ALTER TABLE opentenure.party OWNER TO postgres;

--
-- Name: TABLE party; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE party IS 'Extension to the LADM used by SOLA to store party information (cliamant or owner).';


--
-- Name: COLUMN party.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.id IS 'Unique identifier for the party.';


--
-- Name: COLUMN party.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.name IS 'First name of party.';


--
-- Name: COLUMN party.last_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.last_name IS 'Last name of claimant.';


--
-- Name: COLUMN party.id_type_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.id_type_code IS 'ID document type code';


--
-- Name: COLUMN party.id_number; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.id_number IS 'ID document number.';


--
-- Name: COLUMN party.birth_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.birth_date IS 'Date of birth of the party.';


--
-- Name: COLUMN party.gender_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.gender_code IS 'Gender code of the party.';


--
-- Name: COLUMN party.mobile_phone; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.mobile_phone IS 'Mobile phone number of the party.';


--
-- Name: COLUMN party.phone; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.phone IS 'Landline phone number of the party.';


--
-- Name: COLUMN party.email; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.email IS 'Email address of the party.';


--
-- Name: COLUMN party.address; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.address IS 'Living address of the party.';


--
-- Name: COLUMN party.user_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.user_name IS 'User name who has created the record.';


--
-- Name: COLUMN party.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.rowidentifier IS 'Identifies the all change records for the row in the document_historic table';


--
-- Name: COLUMN party.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN party.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN party.is_person; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party.is_person IS 'Indicates if record is for individual or company (legal entity)';


--
-- Name: party_for_claim_share; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE party_for_claim_share (
    party_id character varying(40) NOT NULL,
    claim_share_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.party_for_claim_share OWNER TO postgres;

--
-- Name: TABLE party_for_claim_share; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE party_for_claim_share IS 'Identifies parties involved in the claim share.';


--
-- Name: COLUMN party_for_claim_share.party_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.party_id IS 'Identifier for the party.';


--
-- Name: COLUMN party_for_claim_share.claim_share_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.claim_share_id IS 'Identifier of the claim share.';


--
-- Name: COLUMN party_for_claim_share.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.rowidentifier IS 'Identifies the all change records for the row in the party_for_claim_share_historic table';


--
-- Name: COLUMN party_for_claim_share.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party_for_claim_share.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party_for_claim_share.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN party_for_claim_share.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_claim_share.change_time IS 'The date and time the row was last modified.';


--
-- Name: party_for_claim_share_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE party_for_claim_share_historic (
    party_id character varying(40),
    claim_share_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.party_for_claim_share_historic OWNER TO postgres;

--
-- Name: party_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE party_historic (
    id character varying(40),
    name character varying(255),
    last_name character varying(50),
    id_type_code character varying(20),
    id_number character varying(20),
    birth_date date,
    gender_code character varying(20),
    mobile_phone character varying(15),
    phone character varying(15),
    email character varying(50),
    address character varying(255),
    user_name character varying(50),
    rowidentifier character varying(40),
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    is_person boolean
);


ALTER TABLE opentenure.party_historic OWNER TO postgres;

--
-- Name: TABLE party_historic; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE party_historic IS 'Historic table for opentenure.party. Keeps all changes done to the main table.';


--
-- Name: rejection_reason; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE rejection_reason (
    code character varying(20) NOT NULL,
    display_value character varying(2000) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE opentenure.rejection_reason OWNER TO postgres;

--
-- Name: TABLE rejection_reason; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE rejection_reason IS 'Rejection reason codes';


--
-- Name: COLUMN rejection_reason.code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN rejection_reason.code IS 'The code for the rejection reason.';


--
-- Name: COLUMN rejection_reason.display_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN rejection_reason.display_value IS 'Displayed value of the rejection reason.';


--
-- Name: COLUMN rejection_reason.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN rejection_reason.status IS 'Status of the rejection reason.';


--
-- Name: COLUMN rejection_reason.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN rejection_reason.description IS 'Description of the rejection reason.';


--
-- Name: section_element_payload; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE section_element_payload (
    id character varying(40) NOT NULL,
    section_payload_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.section_element_payload OWNER TO postgres;

--
-- Name: TABLE section_element_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE section_element_payload IS 'Dynamic form section element payload.';


--
-- Name: COLUMN section_element_payload.section_payload_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_element_payload.section_payload_id IS 'Section payload ID.';


--
-- Name: COLUMN section_element_payload.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_element_payload.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN section_element_payload.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_element_payload.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN section_element_payload.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_element_payload.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN section_element_payload.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_element_payload.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN section_element_payload.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_element_payload.change_time IS 'The date and time the row was last modified.';


--
-- Name: section_element_payload_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE section_element_payload_historic (
    id character varying(40),
    section_payload_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.section_element_payload_historic OWNER TO postgres;

--
-- Name: section_payload; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE section_payload (
    id character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    element_name character varying(255) NOT NULL,
    element_display_name character varying(255) NOT NULL,
    min_occurrences integer NOT NULL,
    max_occurrences integer NOT NULL,
    form_payload_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.section_payload OWNER TO postgres;

--
-- Name: TABLE section_payload; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE section_payload IS 'Dynamic form section payload.';


--
-- Name: COLUMN section_payload.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.id IS 'Primary key.';


--
-- Name: COLUMN section_payload.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.name IS 'Section name to be used as UI component name.';


--
-- Name: COLUMN section_payload.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.display_name IS 'Value to be used as a visible text (header) of UI component.';


--
-- Name: COLUMN section_payload.element_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.element_name IS 'Section element name to be used as UI component name.';


--
-- Name: COLUMN section_payload.element_display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.element_display_name IS 'Text value to be used as a visible label of the section element UI component.';


--
-- Name: COLUMN section_payload.min_occurrences; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.min_occurrences IS 'Minimum occurane of the section elements on the form.';


--
-- Name: COLUMN section_payload.max_occurrences; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.max_occurrences IS 'Maximum occurane of the section elements on the form. If max > 1, UI will be shown as a table.';


--
-- Name: COLUMN section_payload.form_payload_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.form_payload_id IS 'Foreign key reference to form payload.';


--
-- Name: COLUMN section_payload.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN section_payload.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN section_payload.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN section_payload.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN section_payload.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_payload.change_time IS 'The date and time the row was last modified.';


--
-- Name: section_payload_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE section_payload_historic (
    id character varying(40),
    name character varying(255),
    display_name character varying(255),
    element_name character varying(255),
    element_display_name character varying(255),
    min_occurrences integer,
    max_occurrences integer,
    form_payload_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.section_payload_historic OWNER TO postgres;

--
-- Name: section_template; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE section_template (
    id character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    error_msg character varying(255) NOT NULL,
    min_occurrences integer NOT NULL,
    max_occurrences integer NOT NULL,
    form_template_name character varying(255) NOT NULL,
    element_name character varying(255) NOT NULL,
    element_display_name character varying(255) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.section_template OWNER TO postgres;

--
-- Name: TABLE section_template; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE section_template IS 'Sections of dynamic form template.';


--
-- Name: COLUMN section_template.name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.name IS 'Section name to be used as UI component name.';


--
-- Name: COLUMN section_template.display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.display_name IS 'Value to be used as a visible text (header) of UI component.';


--
-- Name: COLUMN section_template.error_msg; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.error_msg IS 'Error message to show when min/max conditions are not met.';


--
-- Name: COLUMN section_template.min_occurrences; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.min_occurrences IS 'Minimum occurane of the section elements on the form.';


--
-- Name: COLUMN section_template.max_occurrences; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.max_occurrences IS 'Maximum occurane of the section elements on the form. If max > 1, UI will be shown as a table.';


--
-- Name: COLUMN section_template.form_template_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.form_template_name IS 'Foreign key reference to form template.';


--
-- Name: COLUMN section_template.element_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.element_name IS 'Section element name to be used as UI component name.';


--
-- Name: COLUMN section_template.element_display_name; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.element_display_name IS 'Text value to be used as a visible label of the section element UI component.';


--
-- Name: COLUMN section_template.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';


--
-- Name: COLUMN section_template.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN section_template.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN section_template.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN section_template.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN section_template.change_time IS 'The date and time the row was last modified.';


--
-- Name: section_template_historic; Type: TABLE; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE TABLE section_template_historic (
    id character varying(40),
    name character varying(255),
    display_name character varying(255),
    error_msg character varying(255),
    min_occurrences integer,
    max_occurrences integer,
    form_template_name character varying(255),
    element_name character varying(255),
    element_display_name character varying(255),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE opentenure.section_template_historic OWNER TO postgres;

SET search_path = party, pg_catalog;

--
-- Name: communication_type; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE communication_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE party.communication_type OWNER TO postgres;

--
-- Name: TABLE communication_type; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE communication_type IS 'Code list of communication types. Used to identify the types of communication that can be used between the land administration agency and their clients.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN communication_type.code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN communication_type.code IS 'The code for the communication type.';


--
-- Name: COLUMN communication_type.display_value; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN communication_type.display_value IS 'Displayed value of the communication type.';


--
-- Name: COLUMN communication_type.status; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN communication_type.status IS 'Status of the communication type';


--
-- Name: COLUMN communication_type.description; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN communication_type.description IS 'Description of the communication type.';


--
-- Name: gender_type; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE gender_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE party.gender_type OWNER TO postgres;

--
-- Name: TABLE gender_type; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE gender_type IS 'Code list of gender types. Used to identify the gender of the party where the party represents an individual.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN gender_type.code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN gender_type.code IS 'The code for the gender type.';


--
-- Name: COLUMN gender_type.display_value; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN gender_type.display_value IS 'Displayed value of the gender type.';


--
-- Name: COLUMN gender_type.status; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN gender_type.status IS 'Status of the gender type';


--
-- Name: COLUMN gender_type.description; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN gender_type.description IS 'Description of the gender type.';


--
-- Name: group_party_historic; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE group_party_historic (
    id character varying(40),
    type_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.group_party_historic OWNER TO postgres;

--
-- Name: group_party_type; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE group_party_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE party.group_party_type OWNER TO postgres;

--
-- Name: TABLE group_party_type; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE group_party_type IS 'Code list of group party type types. Implementation of the LADM LA_GroupPartyType class. Not used by SOLA.
Tags: Reference Table, LADM Reference Object, Not Used';


--
-- Name: COLUMN group_party_type.code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party_type.code IS 'LADM Definition: The code for the group party type.';


--
-- Name: COLUMN group_party_type.display_value; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party_type.display_value IS 'LADM Definition: Displayed value of the group party type.';


--
-- Name: COLUMN group_party_type.status; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party_type.status IS 'SOLA Extension: Status of the group party type';


--
-- Name: COLUMN group_party_type.description; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party_type.description IS 'LADM Definition: Description of the group party type.';


--
-- Name: id_type; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE id_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE party.id_type OWNER TO postgres;

--
-- Name: TABLE id_type; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE id_type IS 'Code list of id types. Used to identify the types of id that can be used to verify the identity of an individual, group or organisation. E.g. nationalId, nationalPassport, driverLicense, etc.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN id_type.code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN id_type.code IS 'The code for the id type.';


--
-- Name: COLUMN id_type.display_value; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN id_type.display_value IS 'Displayed value of the id type.';


--
-- Name: COLUMN id_type.status; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN id_type.status IS 'Status of the id type';


--
-- Name: COLUMN id_type.description; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN id_type.description IS 'Description of the id type.';


--
-- Name: party_historic; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_historic (
    id character varying(40),
    ext_id character varying(255),
    type_code character varying(20),
    name character varying(255),
    last_name character varying(50),
    fathers_name character varying(50),
    fathers_last_name character varying(50),
    alias character varying(50),
    gender_code character varying(20),
    address_id character varying(40),
    id_type_code character varying(20),
    id_number character varying(20),
    email character varying(50),
    mobile character varying(15),
    phone character varying(15),
    fax character varying(15),
    preferred_communication_code character varying(20),
    birth_date date,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20)
);


ALTER TABLE party.party_historic OWNER TO postgres;

--
-- Name: party_member_historic; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_member_historic (
    party_id character varying(40),
    group_id character varying(40),
    share double precision,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.party_member_historic OWNER TO postgres;

--
-- Name: party_role; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_role (
    party_id character varying(40) NOT NULL,
    type_code character varying(20) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.party_role OWNER TO postgres;

--
-- Name: TABLE party_role; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE party_role IS 'Identifies the roles a party has in relation to the land office transactions and data. Implementation of the LADM LA_Party.role feild.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN party_role.party_id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.party_id IS 'LADM Definition: Identifier for the party.';


--
-- Name: COLUMN party_role.type_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.type_code IS 'SOLA Extension: The type of role the party holds';


--
-- Name: COLUMN party_role.rowidentifier; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the party_role_historic table';


--
-- Name: COLUMN party_role.rowversion; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party_role.change_action; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party_role.change_user; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN party_role.change_time; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: party_role_historic; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_role_historic (
    party_id character varying(40),
    type_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.party_role_historic OWNER TO postgres;

--
-- Name: party_role_type; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_role_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE party.party_role_type OWNER TO postgres;

--
-- Name: TABLE party_role_type; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE party_role_type IS 'Code list of party role types. Used to identify the types of role a party can have in relation to land office transactions and data. E.g. applicant, bank, lodgingAgent, etc. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN party_role_type.code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role_type.code IS 'The code for the party role type.';


--
-- Name: COLUMN party_role_type.display_value; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role_type.display_value IS 'Displayed value of the party role type.';


--
-- Name: COLUMN party_role_type.status; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role_type.status IS 'Status of the party role type';


--
-- Name: COLUMN party_role_type.description; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role_type.description IS 'Description of the party role type.';


--
-- Name: party_type; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE party.party_type OWNER TO postgres;

--
-- Name: TABLE party_type; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE party_type IS 'Code list of party type types. Implementation of the LADM LA_PartyType class.
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN party_type.code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_type.code IS 'LADM Definition: The code for the party type.';


--
-- Name: COLUMN party_type.display_value; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_type.display_value IS 'LADM Definition: Displayed value of the party type.';


--
-- Name: COLUMN party_type.status; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_type.status IS 'SOLA Extension: Status of the party type';


--
-- Name: COLUMN party_type.description; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_type.description IS 'LADM Definition: Description of the party type.';


--
-- Name: source_describes_party; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE source_describes_party (
    source_id character varying(40) NOT NULL,
    party_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.source_describes_party OWNER TO postgres;

--
-- Name: TABLE source_describes_party; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE source_describes_party IS 'Implements the many-to-many relationship identifying administrative source instances with party instances

LADM Reference Object 
Relationship LA_AdministrativeSource - LA_PARTY
LADM Definition
Not Defined';


--
-- Name: source_describes_party_historic; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE source_describes_party_historic (
    source_id character varying(40),
    party_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.source_describes_party_historic OWNER TO postgres;

SET search_path = source, pg_catalog;

--
-- Name: administrative_source_type; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE administrative_source_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) NOT NULL,
    description character varying(1000),
    is_for_registration boolean DEFAULT false
);


ALTER TABLE source.administrative_source_type OWNER TO postgres;

--
-- Name: TABLE administrative_source_type; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE administrative_source_type IS 'Code list of administrative source types. Used by SOLA to identify document types.
Implementation of the LADM LA_AdministrativeSourceType class.
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN administrative_source_type.code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN administrative_source_type.code IS 'LADM Definition: The code for the administrative source type.';


--
-- Name: COLUMN administrative_source_type.display_value; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN administrative_source_type.display_value IS 'LADM Definition: Displayed value of the administrative source type.';


--
-- Name: COLUMN administrative_source_type.status; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN administrative_source_type.status IS 'SOLA Extension: Status of the administrative source type';


--
-- Name: COLUMN administrative_source_type.description; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN administrative_source_type.description IS 'LADM Definition: Description of the administrative source type.';


--
-- Name: COLUMN administrative_source_type.is_for_registration; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN administrative_source_type.is_for_registration IS 'SOLA Extension: Flag that identifies whether documents of this type must be formally registered in SOLA before they can be used in rights registration. E.g. Power of Attorney documents must be registered in SOLA before they can be associated with transfer transactions, etc.';


--
-- Name: archive; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE archive (
    id character varying(40) NOT NULL,
    name character varying(50) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.archive OWNER TO postgres;

--
-- Name: TABLE archive; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE archive IS 'Represents an archive where collections of physical documents may be kept such as a filing cabinet, library or storage unit. May also refer to digital archives if applicable. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN archive.id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.id IS 'Identifier for the archive.';


--
-- Name: COLUMN archive.name; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.name IS 'Description of the archive and/or it''s location. ';


--
-- Name: COLUMN archive.rowidentifier; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.rowidentifier IS 'Identifies the all change records for the row in the archive_historic table';


--
-- Name: COLUMN archive.rowversion; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN archive.change_action; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN archive.change_user; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN archive.change_time; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.change_time IS 'The date and time the row was last modified.';


--
-- Name: archive_historic; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE archive_historic (
    id character varying(40),
    name character varying(50),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.archive_historic OWNER TO postgres;

--
-- Name: availability_status_type; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE availability_status_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 'c'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE source.availability_status_type OWNER TO postgres;

--
-- Name: TABLE availability_status_type; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE availability_status_type IS 'Code list of availability status types. Indicates if a  document is available, archived, destroyed or incomplete. Implementation of the LADM LA_AvailabilityStatusType class.
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN availability_status_type.code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN availability_status_type.code IS 'LADM Definition: The code for the availability status type.';


--
-- Name: COLUMN availability_status_type.display_value; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN availability_status_type.display_value IS 'LADM Definition: Displayed value of the availability status type.';


--
-- Name: COLUMN availability_status_type.status; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN availability_status_type.status IS 'SOLA Extension: Status of the availability status type';


--
-- Name: COLUMN availability_status_type.description; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN availability_status_type.description IS 'LADM Definition: Description of the availability status type.';


--
-- Name: power_of_attorney; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE power_of_attorney (
    id character varying(40) NOT NULL,
    person_name character varying(500) NOT NULL,
    attorney_name character varying(500) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.power_of_attorney OWNER TO postgres;

--
-- Name: TABLE power_of_attorney; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE power_of_attorney IS 'An extension of the soure.source table that captures details for power of attorney documents. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN power_of_attorney.id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.id IS 'Identifier for the power of attorney record. Matches the source identifier for the power of attorney record.';


--
-- Name: COLUMN power_of_attorney.person_name; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.person_name IS 'The name of the person that is granting the power of attorney (a.k.a. grantor).';


--
-- Name: COLUMN power_of_attorney.attorney_name; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.attorney_name IS 'The name of the person that will act on behalf of the grantor as their attorney.';


--
-- Name: COLUMN power_of_attorney.rowidentifier; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.rowidentifier IS 'Identifies the all change records for the row in the power_of_attorney_historic table';


--
-- Name: COLUMN power_of_attorney.rowversion; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN power_of_attorney.change_action; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN power_of_attorney.change_user; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN power_of_attorney.change_time; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.change_time IS 'The date and time the row was last modified.';


--
-- Name: power_of_attorney_historic; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE power_of_attorney_historic (
    id character varying(40),
    person_name character varying(500),
    attorney_name character varying(500),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.power_of_attorney_historic OWNER TO postgres;

--
-- Name: presentation_form_type; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE presentation_form_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE source.presentation_form_type OWNER TO postgres;

--
-- Name: TABLE presentation_form_type; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE presentation_form_type IS 'Code list of presentation form types. Indicates the original format of the document when presented to the land office (e.g. Hardcopy, digital, image, video, etc). Implementation of the LADM CI_PresentationFormCode class.
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN presentation_form_type.code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN presentation_form_type.code IS 'LADM Definition: The code for the presentation form type.';


--
-- Name: COLUMN presentation_form_type.display_value; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN presentation_form_type.display_value IS 'LADM Definition: Displayed value of the presentation form type.';


--
-- Name: COLUMN presentation_form_type.status; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN presentation_form_type.status IS 'SOLA Extension: Status of the presentation form type';


--
-- Name: COLUMN presentation_form_type.description; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN presentation_form_type.description IS 'LADM Definition: Description of the presentation form type.';


--
-- Name: source; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE source (
    id character varying(40) NOT NULL,
    maintype character varying(20),
    la_nr character varying(20) NOT NULL,
    reference_nr character varying(255),
    archive_id character varying(40),
    acceptance date,
    recordation date,
    submission date DEFAULT now(),
    expiration_date date,
    ext_archive_id character varying(40),
    availability_status_code character varying(20) DEFAULT 'available'::character varying NOT NULL,
    type_code character varying(20) NOT NULL,
    content character varying(4000),
    status_code character varying(20),
    transaction_id character varying(40),
    owner_name character varying(255),
    version character varying(10),
    description character varying(255),
    signing_date date,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20)
);


ALTER TABLE source.source OWNER TO postgres;

--
-- Name: TABLE source; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE source IS 'Represents metadata about documents or recognised facts that provide the basis for the recording of a registration, cadastre change, right, responsibility or administrative action by the land office. Implementation of the LADM LA_Source class.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN source.id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.id IS 'LADM Definition: Source identifier.';


--
-- Name: COLUMN source.maintype; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.maintype IS 'LADM Definition: The type of the representation of the content of the source.';


--
-- Name: COLUMN source.la_nr; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.la_nr IS 'SOLA Extension: Reference number or identifier assigned to the document by the land office.';


--
-- Name: COLUMN source.reference_nr; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.reference_nr IS 'SOLA Extension: Reference number or identifier assigned to the document by an external agency.';


--
-- Name: COLUMN source.archive_id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.archive_id IS 'SOLA Extension: Archive identifier for the source. ';


--
-- Name: COLUMN source.acceptance; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.acceptance IS 'LADM Definition: The date of force of law of the source by an authority.';


--
-- Name: COLUMN source.recordation; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.recordation IS 'LADM Definition: The date of formalization by the source agency.';


--
-- Name: COLUMN source.submission; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.submission IS 'LADM Definition: The date of submission of the source by a party.';


--
-- Name: COLUMN source.expiration_date; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.expiration_date IS 'SOLA Extension: The date the document expires and is no longer enforceable.';


--
-- Name: COLUMN source.ext_archive_id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.ext_archive_id IS 'SOLA Extension: Identifier of the source in an external document management system. Used by SOLA to reference the digital copy of the document in the document table.';


--
-- Name: COLUMN source.availability_status_code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.availability_status_code IS 'LADM Definition: The code describing the availability status of the document.';


--
-- Name: COLUMN source.type_code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.type_code IS 'LADM Definition: The type of document.';


--
-- Name: COLUMN source.content; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.content IS 'LADM Definition: The content of the source. Not used by SOLA as digital copies of documents are stored in the document table.';


--
-- Name: COLUMN source.status_code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.status_code IS 'SOLA Extension: Status (pending, current, historic) of the source. Only used for transactioned documents such as power of attorney.';


--
-- Name: COLUMN source.transaction_id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.transaction_id IS 'SOLA Extension: Reference to the transaction used to register the document in SOLA. Only used for transactioned documents such as power of attorney.';


--
-- Name: COLUMN source.owner_name; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.owner_name IS 'SOLA Extension: The name of the firm or bank that created the document (a.k.a. Source Agency).';


--
-- Name: COLUMN source.version; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.version IS 'SOLA Extension: The document version.';


--
-- Name: COLUMN source.signing_date; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.signing_date IS 'SOLA Extension: The date the document was signed by all parties.';


--
-- Name: COLUMN source.rowidentifier; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.rowidentifier IS 'Identifies the all change records for the row in the source_historic table';


--
-- Name: COLUMN source.rowversion; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN source.change_action; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN source.change_user; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN source.change_time; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN source.classification_code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this Source. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';


--
-- Name: COLUMN source.redact_code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this Source. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';


--
-- Name: source_historic; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE source_historic (
    id character varying(40),
    maintype character varying(20),
    la_nr character varying(20),
    reference_nr character varying(255),
    archive_id character varying(40),
    acceptance date,
    recordation date,
    submission date,
    expiration_date date,
    ext_archive_id character varying(40),
    availability_status_code character varying(20),
    type_code character varying(20),
    content character varying(4000),
    status_code character varying(20),
    transaction_id character varying(40),
    owner_name character varying(255),
    version character varying(10),
    description character varying(255),
    signing_date date,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    classification_code character varying(20),
    redact_code character varying(20)
);


ALTER TABLE source.source_historic OWNER TO postgres;

--
-- Name: source_la_nr_seq; Type: SEQUENCE; Schema: source; Owner: postgres
--

CREATE SEQUENCE source_la_nr_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999
    CACHE 1
    CYCLE;


ALTER TABLE source.source_la_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE source_la_nr_seq; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON SEQUENCE source_la_nr_seq IS 'Sequence number used as the basis for the Source nr field. This sequence is used by the generate-source-nr business rule.';


--
-- Name: spatial_source; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_source (
    id character varying(40) NOT NULL,
    procedure character varying(255),
    type_code character varying(20) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.spatial_source OWNER TO postgres;

--
-- Name: TABLE spatial_source; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE spatial_source IS 'A spatial source may be the final (sometimes formal) documents, or all documents related to a survey. Sometimes serveral documents are the result of a single survey. A spatial source may be official or not (i.e. a registered survey plan or an aerial photograph). Implementation of the LADM LA_Source class. Not used by SOLA.
Tags: LADM Reference Object, Change History, Not Used';


--
-- Name: COLUMN spatial_source.id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.id IS 'LADM Definition: Spatial source identifier.';


--
-- Name: COLUMN spatial_source.procedure; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.procedure IS 'LADM Definition:  Procedures, steps or method adopted';


--
-- Name: COLUMN spatial_source.type_code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.type_code IS 'LADM Definition: Code type assigned to the source.';


--
-- Name: COLUMN spatial_source.rowidentifier; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.rowidentifier IS 'Identifies the all change records for the row in the spatial_source_historic table';


--
-- Name: COLUMN spatial_source.rowversion; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_source.change_action; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_source.change_user; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_source.change_time; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.change_time IS 'The date and time the row was last modified.';


--
-- Name: spatial_source_historic; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_source_historic (
    id character varying(40),
    procedure character varying(255),
    type_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.spatial_source_historic OWNER TO postgres;

--
-- Name: spatial_source_measurement; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_source_measurement (
    spatial_source_id character varying(40) NOT NULL,
    id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.spatial_source_measurement OWNER TO postgres;

--
-- Name: TABLE spatial_source_measurement; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE spatial_source_measurement IS 'The observations and measurements as a basis of mapping, and as a basis for historical reconstruction of the location of (parts of) the spatial unit in the field. Implementation of the LADM OM_Observation class. Not used by SOLA.
Tags: LADM Reference Object, Change History, Not Used';


--
-- Name: COLUMN spatial_source_measurement.spatial_source_id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.spatial_source_id IS 'LADM Definition: Spatial source identifier.';


--
-- Name: COLUMN spatial_source_measurement.id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.id IS 'LADM Definition: Spatial source measurement identifier.';


--
-- Name: COLUMN spatial_source_measurement.rowidentifier; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.rowidentifier IS 'Identifies the all change records for the row in the spatial_source_measurement_historic table';


--
-- Name: COLUMN spatial_source_measurement.rowversion; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_source_measurement.change_action; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_source_measurement.change_user; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_source_measurement.change_time; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.change_time IS 'The date and time the row was last modified.';


--
-- Name: spatial_source_measurement_historic; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_source_measurement_historic (
    spatial_source_id character varying(40),
    id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.spatial_source_measurement_historic OWNER TO postgres;

--
-- Name: spatial_source_type; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_source_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE source.spatial_source_type OWNER TO postgres;

--
-- Name: TABLE spatial_source_type; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE spatial_source_type IS 'Code list of spatial source types. Implementation of the LADM LA_SpatialSourceType class. Not used by SOLA.
Tags: Reference Table, LADM Reference Object, Not Used';


--
-- Name: COLUMN spatial_source_type.code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_type.code IS 'LADM Definition: The code for the spatial source type.';


--
-- Name: COLUMN spatial_source_type.display_value; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_type.display_value IS 'LADM Definition: Displayed value of the spatial source type.';


--
-- Name: COLUMN spatial_source_type.status; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_type.status IS 'SOLA Extension: Status of the spatial source type';


--
-- Name: COLUMN spatial_source_type.description; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_type.description IS 'LADM Definition: Description of the spatial source type.';


SET search_path = system, pg_catalog;

--
-- Name: approle_appgroup; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE approle_appgroup (
    approle_code character varying(20) NOT NULL,
    appgroup_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE system.approle_appgroup OWNER TO postgres;

--
-- Name: TABLE approle_appgroup; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE approle_appgroup IS 'Associates the application security roles to the groups. One role can exist in many groups.
Tags: FLOSS SOLA Extension, User Admin';


--
-- Name: COLUMN approle_appgroup.approle_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.approle_code IS 'Code for the security role.';


--
-- Name: COLUMN approle_appgroup.appgroup_id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.appgroup_id IS 'Identifier for the group the role is associated to.';


--
-- Name: COLUMN approle_appgroup.rowidentifier; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.rowidentifier IS 'Identifies the all change records for the row in the system.approle_appgroup_historic table';


--
-- Name: COLUMN approle_appgroup.rowversion; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN approle_appgroup.change_action; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN approle_appgroup.change_user; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN approle_appgroup.change_time; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.change_time IS 'The date and time the row was last modified.';


--
-- Name: appuser; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE appuser (
    id character varying(40) NOT NULL,
    username character varying(40) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    email character varying(40),
    mobile_number character varying(20),
    activation_code character varying(40),
    passwd character varying(100) DEFAULT public.uuid_generate_v1() NOT NULL,
    active boolean DEFAULT true NOT NULL,
    description character varying(255),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    activation_expiration timestamp without time zone
);


ALTER TABLE system.appuser OWNER TO postgres;

--
-- Name: TABLE appuser; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE appuser IS 'The list of users that can have access to the SOLA application.
Tags: FLOSS SOLA Extension, User Admin';


--
-- Name: COLUMN appuser.id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.id IS 'The SOLA user identifier.';


--
-- Name: COLUMN appuser.username; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.username IS 'The user name assigned to the SOLA user.';


--
-- Name: COLUMN appuser.first_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.first_name IS 'The first name of the SOLA user.';


--
-- Name: COLUMN appuser.last_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.last_name IS 'The last name of the SOLA user.';


--
-- Name: COLUMN appuser.activation_expiration; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.activation_expiration IS 'Account activation timeout. It can be used to delete account if it was not activated in time.';


--
-- Name: appuser_appgroup; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE appuser_appgroup (
    appuser_id character varying(40) NOT NULL,
    appgroup_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE system.appuser_appgroup OWNER TO postgres;

--
-- Name: TABLE appuser_appgroup; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE appuser_appgroup IS 'Associates users to groups. Each user can be assigned multiple groups.
Tags: FLOSS SOLA Extension, User Admin';


--
-- Name: COLUMN appuser_appgroup.appuser_id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.appuser_id IS 'Identifier for the SOLA user.';


--
-- Name: COLUMN appuser_appgroup.appgroup_id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.appgroup_id IS 'Identifier for the group the user is associated to.';


--
-- Name: COLUMN appuser_appgroup.rowidentifier; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.rowidentifier IS 'Identifies the all change records for the row in the system.appuser_appgroup_historic table';


--
-- Name: COLUMN appuser_appgroup.rowversion; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN appuser_appgroup.change_action; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN appuser_appgroup.change_user; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN appuser_appgroup.change_time; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.change_time IS 'The date and time the row was last modified.';


--
-- Name: appuser_historic; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE appuser_historic (
    id character varying(40),
    username character varying(40),
    first_name character varying(30),
    last_name character varying(30),
    email character varying(40),
    mobile_number character varying(20),
    activation_code character varying(40),
    passwd character varying(100) DEFAULT public.uuid_generate_v1() NOT NULL,
    active boolean DEFAULT true NOT NULL,
    description character varying(255),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    activation_expiration timestamp without time zone
);


ALTER TABLE system.appuser_historic OWNER TO postgres;

--
-- Name: setting; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE setting (
    name character varying(50) NOT NULL,
    vl character varying(2000) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    description character varying(555) NOT NULL
);


ALTER TABLE system.setting OWNER TO postgres;

--
-- Name: TABLE setting; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE setting IS 'Contains global settings for the SOLA application. Refer to the Administration Guide or the ConfigConstants class in the Common Utilities project for a list of the recognized settings. Note that not all possible settings are listed in the settings table. Settings may be omitted from this table if the default value applies.
Tags: FLOSS SOLA Extension, Reference Table, System Configuration';


--
-- Name: COLUMN setting.name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN setting.name IS 'Identifier/name for the setting';


--
-- Name: COLUMN setting.vl; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN setting.vl IS 'The value for the setting.';


--
-- Name: COLUMN setting.active; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN setting.active IS 'Indicates if the setting is active or not. If not active, the default value for the setting will apply.';


--
-- Name: COLUMN setting.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN setting.description IS 'Description of the setting. ';


--
-- Name: user_roles; Type: VIEW; Schema: system; Owner: postgres
--

CREATE VIEW user_roles AS
    SELECT u.username, rg.approle_code AS rolename FROM ((appuser u JOIN appuser_appgroup ug ON ((((u.id)::text = (ug.appuser_id)::text) AND u.active))) JOIN approle_appgroup rg ON (((ug.appgroup_id)::text = (rg.appgroup_id)::text)));


ALTER TABLE system.user_roles OWNER TO postgres;

--
-- Name: VIEW user_roles; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON VIEW user_roles IS 'Determines the application security roles assigned to each user. Referenced by the SolaRealm security configuration in Glassfish.';


--
-- Name: user_pword_expiry; Type: VIEW; Schema: system; Owner: postgres
--

CREATE VIEW user_pword_expiry AS
    WITH pw_change_all AS (SELECT u.username, u.change_time, u.change_user, u.rowversion FROM appuser u WHERE (NOT (EXISTS (SELECT uh2.id FROM appuser_historic uh2 WHERE ((((uh2.username)::text = (u.username)::text) AND (uh2.rowversion = (u.rowversion - 1))) AND ((uh2.passwd)::text = (u.passwd)::text))))) UNION SELECT uh.username, uh.change_time, uh.change_user, uh.rowversion FROM appuser_historic uh WHERE (NOT (EXISTS (SELECT uh2.id FROM appuser_historic uh2 WHERE ((((uh2.username)::text = (uh.username)::text) AND (uh2.rowversion = (uh.rowversion - 1))) AND ((uh2.passwd)::text = (uh.passwd)::text)))))), pw_change AS (SELECT pall.username AS uname, pall.change_time AS last_pword_change, pall.change_user AS pword_change_user FROM pw_change_all pall WHERE (pall.rowversion = (SELECT max(p2.rowversion) AS max FROM pw_change_all p2 WHERE ((p2.username)::text = (pall.username)::text)))) SELECT p.uname, p.last_pword_change, p.pword_change_user, CASE WHEN (EXISTS (SELECT r.username FROM user_roles r WHERE (((r.username)::text = (p.uname)::text) AND ((r.rolename)::text = ANY (ARRAY[('ManageSecurity'::character varying)::text, ('NoPasswordExpiry'::character varying)::text]))))) THEN true ELSE false END AS no_pword_expiry, CASE WHEN (s.vl IS NULL) THEN NULL::integer ELSE (((p.last_pword_change)::date - (now())::date) + (s.vl)::integer) END AS pword_expiry_days FROM (pw_change p LEFT JOIN setting s ON ((((s.name)::text = 'pword-expiry-days'::text) AND s.active)));


ALTER TABLE system.user_pword_expiry OWNER TO postgres;

--
-- Name: VIEW user_pword_expiry; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON VIEW user_pword_expiry IS 'Determines the number of days until the users password expires. Once the number of days reaches 0, users will not be able to log into SOLA unless they have the ManageSecurity role (i.e. role to change manage user accounts) or the NoPasswordExpiry role. To configure the number of days before a password expires, set the pword-expiry-days setting in system.setting table. If this setting is not in place, then a password expiry does not apply.';


--
-- Name: active_users; Type: VIEW; Schema: system; Owner: postgres
--

CREATE VIEW active_users AS
    SELECT u.username, u.passwd FROM appuser u, user_pword_expiry ex WHERE (((u.active = true) AND ((ex.uname)::text = (u.username)::text)) AND ((COALESCE(ex.pword_expiry_days, 1) > 0) OR (ex.no_pword_expiry = true)));


ALTER TABLE system.active_users OWNER TO postgres;

--
-- Name: VIEW active_users; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON VIEW active_users IS 'Identifies the users currently active in the system. If the users password has expired, then they are treated as inactive users, unless they are System Administrators. This view is intended to replace the system.appuser table in the SolaRealm configuration in Glassfish.';


--
-- Name: appgroup; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE appgroup (
    id character varying(40) NOT NULL,
    name character varying(600) NOT NULL,
    description character varying(1000)
);


ALTER TABLE system.appgroup OWNER TO postgres;

--
-- Name: TABLE appgroup; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE appgroup IS 'Groups application security roles to simplify assignment of roles to individual system users. 
Tags: FLOSS SOLA Extension, User Admin';


--
-- Name: COLUMN appgroup.id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appgroup.id IS 'Identifier for the appgroup.';


--
-- Name: COLUMN appgroup.name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appgroup.name IS 'The name assigned to the appgroup.';


--
-- Name: COLUMN appgroup.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appgroup.description IS 'Describes the purpose of the appgroup and should also indicate when it applies.';


--
-- Name: approle; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE approle (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) NOT NULL,
    description character varying(5000)
);


ALTER TABLE system.approle OWNER TO postgres;

--
-- Name: TABLE approle; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE approle IS 'Contains the list of application security roles used to restrict access to different parts of the application, both on the server and client side. 
Tags: FLOSS SOLA Extension, Reference Table, User Admin';


--
-- Name: COLUMN approle.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle.code IS 'Code for the security role. Must match exactly the code value used within the SOLA source code to reference the role.';


--
-- Name: COLUMN approle.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle.display_value IS 'The text value that will be displayed to the user.';


--
-- Name: COLUMN approle.status; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle.status IS 'The status of the role.';


--
-- Name: COLUMN approle.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle.description IS 'Describes the purpose of the role and should also indicate when it applies.';


--
-- Name: approle_appgroup_historic; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE approle_appgroup_historic (
    approle_code character varying(20),
    appgroup_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE system.approle_appgroup_historic OWNER TO postgres;

--
-- Name: appuser_appgroup_historic; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE appuser_appgroup_historic (
    appuser_id character varying(40),
    appgroup_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE system.appuser_appgroup_historic OWNER TO postgres;

--
-- Name: appuser_setting; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE appuser_setting (
    user_id character varying(40) NOT NULL,
    name character varying(50) NOT NULL,
    vl character varying(2000) NOT NULL,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE system.appuser_setting OWNER TO postgres;

--
-- Name: TABLE appuser_setting; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE appuser_setting IS 'Software settings specific for a user within the SOLA application. Not used by SOLA.
Tags: FLOSS SOLA Extension, User Admin, Not Used';


--
-- Name: COLUMN appuser_setting.user_id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_setting.user_id IS 'Identifier of the user the setting applies to.';


--
-- Name: COLUMN appuser_setting.name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_setting.name IS 'The name of the setting.';


--
-- Name: COLUMN appuser_setting.vl; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_setting.vl IS 'The value of the setting';


--
-- Name: COLUMN appuser_setting.active; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_setting.active IS 'Flag to indicate if the setting is active or not.';


--
-- Name: br; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE br (
    id character varying(100) NOT NULL,
    display_name character varying(250) DEFAULT public.uuid_generate_v1() NOT NULL,
    technical_type_code character varying(20) NOT NULL,
    feedback character varying(2000),
    description character varying(1000),
    technical_description character varying(1000)
);


ALTER TABLE system.br OWNER TO postgres;

--
-- Name: TABLE br; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE br IS 'Provides a description of the business rules used by SOLA.
Tags: FLOSS SOLA Extension, Business Rules';


--
-- Name: COLUMN br.id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br.id IS 'The name of the business rule';


--
-- Name: COLUMN br.display_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br.display_name IS 'The display name for the business rule.';


--
-- Name: COLUMN br.technical_type_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br.technical_type_code IS 'Indicates which engine must be used to run the business rule (sql or drools). Note that SOLA does not currently implement any Drools rules.';


--
-- Name: COLUMN br.feedback; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br.feedback IS 'The message that should be displayed to the user if the rule is not complied with.';


--
-- Name: COLUMN br.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br.description IS 'A description of the business rule. Intended for system administrators and end users.';


--
-- Name: COLUMN br.technical_description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br.technical_description IS 'A technical description of the business rule including any parameters the rule expects. Intended for developers.';


--
-- Name: br_definition; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE br_definition (
    br_id character varying(100) NOT NULL,
    active_from date NOT NULL,
    active_until date DEFAULT 'infinity'::date NOT NULL,
    body character varying(4000) NOT NULL
);


ALTER TABLE system.br_definition OWNER TO postgres;

--
-- Name: TABLE br_definition; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE br_definition IS 'Contains the code definition for business rules used by SOLA. These rules can be assigned an active date range allowing new rules to superseed old rules at specific dates. 
Tags: FLOSS SOLA Extension, Business Rules';


--
-- Name: COLUMN br_definition.br_id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_definition.br_id IS 'Identifier for the business rule';


--
-- Name: COLUMN br_definition.active_from; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_definition.active_from IS 'The date this version of the rule is active from.';


--
-- Name: COLUMN br_definition.active_until; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_definition.active_until IS 'The date until this version of the rule is active.';


--
-- Name: COLUMN br_definition.body; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_definition.body IS 'The definition of the rule. Either SQL commands or Drools XML.';


--
-- Name: br_current; Type: VIEW; Schema: system; Owner: postgres
--

CREATE VIEW br_current AS
    SELECT b.id, b.technical_type_code, b.feedback, bd.body FROM (br b JOIN br_definition bd ON (((b.id)::text = (bd.br_id)::text))) WHERE ((now() >= bd.active_from) AND (now() <= bd.active_until));


ALTER TABLE system.br_current OWNER TO postgres;

--
-- Name: VIEW br_current; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON VIEW br_current IS 'Determines the currently active business rules based on the active_from, active_to date range';


--
-- Name: br_validation; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE br_validation (
    id character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    br_id character varying(100) NOT NULL,
    target_code character varying(20) NOT NULL,
    target_application_moment character varying(20),
    target_service_moment character varying(20),
    target_reg_moment character varying(20),
    target_request_type_code character varying(20),
    target_rrr_type_code character varying(20),
    severity_code character varying(20) NOT NULL,
    order_of_execution integer DEFAULT 0 NOT NULL,
    CONSTRAINT br_validation_application_moment_valid CHECK ((((target_code)::text <> 'application'::text) OR ((((target_code)::text = 'application'::text) AND (target_service_moment IS NULL)) AND (target_reg_moment IS NULL)))),
    CONSTRAINT br_validation_reg_moment_valid CHECK ((((target_code)::text = ANY (ARRAY[('application'::character varying)::text, ('service'::character varying)::text])) OR ((((target_code)::text <> ALL (ARRAY[('application'::character varying)::text, ('service'::character varying)::text])) AND (target_service_moment IS NULL)) AND (target_application_moment IS NULL)))),
    CONSTRAINT br_validation_rrr_rrr_type_valid CHECK (((target_rrr_type_code IS NULL) OR ((target_rrr_type_code IS NOT NULL) AND ((target_code)::text = 'rrr'::text)))),
    CONSTRAINT br_validation_service_moment_valid CHECK ((((target_code)::text <> 'service'::text) OR ((((target_code)::text = 'service'::text) AND (target_application_moment IS NULL)) AND (target_reg_moment IS NULL)))),
    CONSTRAINT br_validation_service_request_type_valid CHECK (((target_request_type_code IS NULL) OR ((target_request_type_code IS NOT NULL) AND ((target_code)::text <> 'application'::text))))
);


ALTER TABLE system.br_validation OWNER TO postgres;

--
-- Name: TABLE br_validation; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE br_validation IS 'Identifies the set of rules to execute based on the user action being peformed. E.g. approval of an application, cancellation of a service, etc. 
Tags: FLOSS SOLA Extension, Business Rules';


--
-- Name: COLUMN br_validation.id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.id IS 'Identifier for the br validation';


--
-- Name: COLUMN br_validation.br_id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.br_id IS 'The business rule referenced by this br validation record.';


--
-- Name: COLUMN br_validation.target_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.target_code IS 'The entity that is the target of the validation E.g. application, service, rrr, etc.';


--
-- Name: COLUMN br_validation.target_application_moment; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.target_application_moment IS 'Identifies the application action the rule applies to. E.g. approve, validate, etc. Only valid if target_code is application.';


--
-- Name: COLUMN br_validation.target_service_moment; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.target_service_moment IS 'Identifies the service action the rule applies to. E.g. complete, start, cancel, etc. Only valid if the target_code is service.';


--
-- Name: COLUMN br_validation.target_reg_moment; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.target_reg_moment IS 'Identifies the entity status the rule applies to. E.g. current, pending, etc. Only valid if target_code is one of ba_unit, cadastre_object, source, rrr or bulkOperationSpatial.';


--
-- Name: COLUMN br_validation.target_request_type_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.target_request_type_code IS 'Used as an additional filter for the set of business rules to run by ensuring the rule is only executed if the service type (a.k.a. request_type) matches the specified value.';


--
-- Name: COLUMN br_validation.target_rrr_type_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.target_rrr_type_code IS 'Used as an additional filter for the set of business rules to run by ensuring the rule is only executed if the rrr type matches the specified value.';


--
-- Name: COLUMN br_validation.severity_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.severity_code IS 'The severity of the business rule failure.';


--
-- Name: COLUMN br_validation.order_of_execution; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.order_of_execution IS 'Number used to order the execution of business rules in the rule set.';


--
-- Name: br_report; Type: VIEW; Schema: system; Owner: postgres
--

CREATE VIEW br_report AS
    SELECT b.id, b.technical_type_code, b.feedback, b.description, CASE WHEN ((bv.target_code)::text = 'application'::text) THEN bv.target_application_moment WHEN ((bv.target_code)::text = 'service'::text) THEN bv.target_service_moment ELSE bv.target_reg_moment END AS moment_code, bd.body, bv.severity_code, bv.target_code, bv.target_request_type_code, bv.target_rrr_type_code, bv.order_of_execution FROM ((br b LEFT JOIN br_validation bv ON (((b.id)::text = (bv.br_id)::text))) JOIN br_definition bd ON (((b.id)::text = (bd.br_id)::text))) WHERE ((now() >= bd.active_from) AND (now() <= bd.active_until)) ORDER BY b.id;


ALTER TABLE system.br_report OWNER TO postgres;

--
-- Name: VIEW br_report; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON VIEW br_report IS 'Used in the generation of the Admin Business Rules Report that presents summary details for all active business rules in the system.';


--
-- Name: br_severity_type; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE br_severity_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) NOT NULL,
    description character varying(1000)
);


ALTER TABLE system.br_severity_type OWNER TO postgres;

--
-- Name: TABLE br_severity_type; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE br_severity_type IS 'The severity types applicable to the SOLA business rules.
Tags: FLOSS SOLA Extension, Reference Table, Business Rules';


--
-- Name: COLUMN br_severity_type.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_severity_type.code IS 'Code for the severity type.';


--
-- Name: COLUMN br_severity_type.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_severity_type.display_value IS 'The text value that will be displayed to the user.';


--
-- Name: COLUMN br_severity_type.status; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_severity_type.status IS 'The status of the severity type.';


--
-- Name: COLUMN br_severity_type.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_severity_type.description IS 'A description of the severity type.';


--
-- Name: br_technical_type; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE br_technical_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) NOT NULL,
    description character varying(1000)
);


ALTER TABLE system.br_technical_type OWNER TO postgres;

--
-- Name: TABLE br_technical_type; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE br_technical_type IS 'Codes use for each type of rule implementation supported by SOLA. Curently SQL and Drools, however no Drools rules have been developed.
Tags: FLOSS SOLA Extension, Reference Table, Business Rules';


--
-- Name: COLUMN br_technical_type.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_technical_type.code IS 'Code for the technical type.';


--
-- Name: COLUMN br_technical_type.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_technical_type.display_value IS 'The text value that will be displayed to the user.';


--
-- Name: COLUMN br_technical_type.status; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_technical_type.status IS 'The status of the technical type.';


--
-- Name: COLUMN br_technical_type.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_technical_type.description IS 'A description of the technical type.';


--
-- Name: br_validation_target_type; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE br_validation_target_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) NOT NULL,
    description character varying(5000)
);


ALTER TABLE system.br_validation_target_type OWNER TO postgres;

--
-- Name: TABLE br_validation_target_type; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE br_validation_target_type IS 'Lists potential targets for the business rules.
Tags: FLOSS SOLA Extension, Reference Table, Business Rules';


--
-- Name: COLUMN br_validation_target_type.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation_target_type.code IS 'Code for the validation target type.';


--
-- Name: COLUMN br_validation_target_type.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation_target_type.display_value IS 'The text value that will be displayed to the user.';


--
-- Name: COLUMN br_validation_target_type.status; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation_target_type.status IS 'The status of the validation target type.';


--
-- Name: COLUMN br_validation_target_type.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation_target_type.description IS 'A description of the validation target type.';


--
-- Name: config_map_layer; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE config_map_layer (
    name character varying(50) NOT NULL,
    title character varying(100) NOT NULL,
    type_code character varying(20) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    visible_in_start boolean DEFAULT true NOT NULL,
    item_order integer DEFAULT 0 NOT NULL,
    style character varying(4000),
    url character varying(500),
    wms_layers character varying(500),
    wms_version character varying(10),
    wms_format character varying(15),
    wms_data_source character varying(200),
    pojo_structure character varying(500),
    pojo_query_name character varying(100),
    pojo_query_name_for_select character varying(100),
    shape_location character varying(500),
    security_user character varying(30),
    security_password character varying(30),
    added_from_bulk_operation boolean DEFAULT false NOT NULL,
    use_in_public_display boolean DEFAULT false NOT NULL,
    use_for_ot boolean DEFAULT false NOT NULL,
    CONSTRAINT config_map_layer_fields_required CHECK (CASE WHEN ((type_code)::text = 'wms'::text) THEN ((url IS NOT NULL) AND (wms_layers IS NOT NULL)) WHEN ((type_code)::text = 'pojo'::text) THEN (((pojo_query_name IS NOT NULL) AND (pojo_structure IS NOT NULL)) AND (style IS NOT NULL)) WHEN ((type_code)::text = 'shape'::text) THEN ((shape_location IS NOT NULL) AND (style IS NOT NULL)) ELSE NULL::boolean END)
);


ALTER TABLE system.config_map_layer OWNER TO postgres;

--
-- Name: TABLE config_map_layer; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE config_map_layer IS 'Identifies the layers available for display in the SOLA Map Viewer.
Tags: FLOSS SOLA Extension, Reference Table, Map Configuration';


--
-- Name: COLUMN config_map_layer.name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.name IS 'Name assigned to the map layer.';


--
-- Name: COLUMN config_map_layer.title; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.title IS 'The title used for the layer when it is displayed in the map control.';


--
-- Name: COLUMN config_map_layer.type_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.type_code IS 'Indicates the source of data for the map layer. One of pojo (Plain Old Java Object - SOLA specific), wms (Web Map Service), shape (Shapefile)';


--
-- Name: COLUMN config_map_layer.active; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.active IS 'Flag to indicate if the layer is active. Inactive layers are not displayed in the map layer control.';


--
-- Name: COLUMN config_map_layer.visible_in_start; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.visible_in_start IS 'Flag to indicate if the layer should be turned on and display when the map initially displays';


--
-- Name: COLUMN config_map_layer.item_order; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.item_order IS 'The order to use for display of layers in the layer control. The layer with the lowest number will be displayed at the bottom of the layer control.';


--
-- Name: COLUMN config_map_layer.style; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.style IS 'An SLD document representing the styles to use for display of the layer features in the map.';


--
-- Name: COLUMN config_map_layer.url; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.url IS 'The URL identifying the data source for a WMS layer.';


--
-- Name: COLUMN config_map_layer.wms_layers; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.wms_layers IS 'The names of the layers to request when obtaining data from a Web Map Service. Layer names must be separated with a comma.';


--
-- Name: COLUMN config_map_layer.wms_version; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.wms_version IS 'The version of the WMS server. Values can be one of 1.0.0, 1.1.0, 1.1.1, 1.3.0.';


--
-- Name: COLUMN config_map_layer.wms_format; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.wms_format IS 'Format of the output for the WMS layer. Allowed values are as defined by the WMS server capabilities. E.g. image/png or image/jpeg.';


--
-- Name: COLUMN config_map_layer.wms_data_source; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.wms_data_source IS 'Description to display in the Map when the WMS layer is turned on.';


--
-- Name: COLUMN config_map_layer.pojo_structure; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.pojo_structure IS 'Plain old java object structure. Must be specified in the same format as requried by the Geotools featuretype definition. E.g. theGeom:Polygon,label:""';


--
-- Name: COLUMN config_map_layer.pojo_query_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.pojo_query_name IS 'The name of the query (i.e. system.query) used to retrieve features for this layer.';


--
-- Name: COLUMN config_map_layer.pojo_query_name_for_select; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.pojo_query_name_for_select IS 'The name of the query to use to select objects corresponding to the layer. Can be used for any layer type';


--
-- Name: COLUMN config_map_layer.shape_location; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.shape_location IS 'The location of the shapefile. Used for layers of type shape. THe client application must have access to the shape file location.';


--
-- Name: COLUMN config_map_layer.security_user; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.security_user IS 'The username to access a secure wms layer. Not currently used.';


--
-- Name: COLUMN config_map_layer.security_password; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.security_password IS 'The password to access a secure wms layer. Not currently used.';


--
-- Name: COLUMN config_map_layer.added_from_bulk_operation; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.added_from_bulk_operation IS 'Flag to indicate the layer was added when using the SOLA Bulk Operation feature.';


--
-- Name: COLUMN config_map_layer.use_in_public_display; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.use_in_public_display IS 'Flag to indicate if the layer must be visible when printing the public display map. Not relevant for other kinds of map operations.';


--
-- Name: COLUMN config_map_layer.use_for_ot; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.use_for_ot IS 'Flag to indicate if the layer must be visible on open tenure map.';


--
-- Name: config_map_layer_metadata; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE config_map_layer_metadata (
    name_layer character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    value character varying(100) NOT NULL
);


ALTER TABLE system.config_map_layer_metadata OWNER TO postgres;

--
-- Name: config_map_layer_type; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE config_map_layer_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) NOT NULL,
    description character varying(555)
);


ALTER TABLE system.config_map_layer_type OWNER TO postgres;

--
-- Name: TABLE config_map_layer_type; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE config_map_layer_type IS 'Lists the map layer types for the config_map_layer table.
Tags: FLOSS SOLA Extension, Reference Table, Map Configuration';


--
-- Name: COLUMN config_map_layer_type.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer_type.code IS 'Code for the map layer type.';


--
-- Name: COLUMN config_map_layer_type.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer_type.display_value IS 'The text value that will be displayed to the user.';


--
-- Name: COLUMN config_map_layer_type.status; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer_type.status IS 'The status of the map layer type.';


--
-- Name: COLUMN config_map_layer_type.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer_type.description IS 'A description of the map layer type.';


--
-- Name: config_panel_launcher; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE config_panel_launcher (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    launch_group character varying(20) NOT NULL,
    panel_class character varying(100),
    message_code character varying(50),
    card_name character varying(50)
);


ALTER TABLE system.config_panel_launcher OWNER TO postgres;

--
-- Name: TABLE config_panel_launcher; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE config_panel_launcher IS 'Configuration data used by the PanelLauncher to determine the appropriate panel or form to display to the user when starting a Service or opening an RRR. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN config_panel_launcher.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_panel_launcher.code IS 'The code for the panel to launch';


--
-- Name: COLUMN config_panel_launcher.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_panel_launcher.display_value IS 'The user friendly name for the panel to launch';


--
-- Name: COLUMN config_panel_launcher.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_panel_launcher.description IS 'Description for the panel to launch';


--
-- Name: COLUMN config_panel_launcher.status; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_panel_launcher.status IS 'Status of this configuration record.';


--
-- Name: COLUMN config_panel_launcher.launch_group; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_panel_launcher.launch_group IS 'The launch group for the panel.';


--
-- Name: COLUMN config_panel_launcher.panel_class; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_panel_launcher.panel_class IS 'The full package and class name for the panel to launch. e.g. org.sola.clients.swing.desktop.administrative.PropertyPanel';


--
-- Name: COLUMN config_panel_launcher.message_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_panel_launcher.message_code IS 'The code of the message to display when opening the panel. See the ClientMessage class for a list of codes. ';


--
-- Name: COLUMN config_panel_launcher.card_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_panel_launcher.card_name IS 'The MainContentPanel card name for the panel to launch';


--
-- Name: consolidation_config; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE consolidation_config (
    id character varying(100) NOT NULL,
    schema_name character varying(100) NOT NULL,
    table_name character varying(100) NOT NULL,
    condition_description character varying(1000) NOT NULL,
    condition_sql character varying(1000),
    remove_before_insert boolean DEFAULT false NOT NULL,
    order_of_execution integer NOT NULL,
    log_in_extracted_rows boolean DEFAULT true NOT NULL
);


ALTER TABLE system.consolidation_config OWNER TO postgres;

--
-- Name: TABLE consolidation_config; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE consolidation_config IS 'This table contains the list of instructions to run the consolidation process.';


--
-- Name: COLUMN consolidation_config.schema_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN consolidation_config.schema_name IS 'Name of the source schema.';


--
-- Name: COLUMN consolidation_config.table_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN consolidation_config.table_name IS 'Name of the source table.';


--
-- Name: COLUMN consolidation_config.condition_description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN consolidation_config.condition_description IS 'Description of the condition has to be applied to rows of the source table for extraction.';


--
-- Name: COLUMN consolidation_config.condition_sql; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN consolidation_config.condition_sql IS 'The SQL implementation of the condition.';


--
-- Name: COLUMN consolidation_config.remove_before_insert; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN consolidation_config.remove_before_insert IS 'True - The records in the destination will be removed if they are found in the new extract. The check is done in rowidentifier.';


--
-- Name: COLUMN consolidation_config.order_of_execution; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN consolidation_config.order_of_execution IS 'Order of execution of the extract.';


--
-- Name: COLUMN consolidation_config.log_in_extracted_rows; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN consolidation_config.log_in_extracted_rows IS 'True - If the records has to be logged in the extracted rows table.';


--
-- Name: crs; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE crs (
    srid integer NOT NULL,
    from_long double precision,
    to_long double precision,
    item_order integer NOT NULL
);


ALTER TABLE system.crs OWNER TO postgres;

--
-- Name: TABLE crs; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE crs IS 'Identifies the coordinate reference system(s) (CRS) available to the Map Viewer. If there is more than one CRS defined, the user has the option to select the CRS to use for displaying features in the Map Viewer. The CRS with the lowest item_order will be the default CRS and used for the initial display of the map. The extent values defined in the system.setting table must be in the context of the default CRS. The from_long, to_long values define valid longitude values for each CRS in WGS84. These values can be used for various purposes such as assigning or transforming geometries into the appropraite storage CRS before being saved to the database.
Tags: FLOSS SOLA Extension, Reference Table, Map Configuration';


--
-- Name: COLUMN crs.srid; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN crs.srid IS 'The Spatial Reference Identifier (SRID) for the CRS.';


--
-- Name: COLUMN crs.from_long; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN crs.from_long IS 'The longitude in WGS84 identifying the where the CRS is valid from.';


--
-- Name: COLUMN crs.to_long; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN crs.to_long IS 'The longitude in WGS84 identifying the where the CRS is valid to.';


--
-- Name: COLUMN crs.item_order; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN crs.item_order IS 'Identifies the order the CRS is displayed in the drop down menu on the Map Viewer. The CRS with the lowest item order will be used as the default CRS for the initial display of the map.';


--
-- Name: email; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE email (
    id character varying(40) NOT NULL,
    recipient character varying(255) NOT NULL,
    recipient_name character varying(255),
    cc character varying(5000),
    bcc character varying(5000),
    subject character varying(250) NOT NULL,
    body character varying(8000) NOT NULL,
    attachment bytea,
    attachment_mime_type character varying(250),
    attachment_name character varying(250),
    time_to_send timestamp without time zone DEFAULT now() NOT NULL,
    attempt integer DEFAULT 1 NOT NULL,
    error character varying(5000)
);


ALTER TABLE system.email OWNER TO postgres;

--
-- Name: TABLE email; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE email IS 'Table for email messages to be sent.';


--
-- Name: COLUMN email.id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.id IS 'Unique identifier of the record.';


--
-- Name: COLUMN email.recipient; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.recipient IS 'Email address of recipient.';


--
-- Name: COLUMN email.recipient_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.recipient_name IS 'Name of recipient.';


--
-- Name: COLUMN email.cc; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.cc IS 'List of names and email address to send a copy of the message';


--
-- Name: COLUMN email.bcc; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.bcc IS 'List of names and email address to send a blind copy of the message';


--
-- Name: COLUMN email.subject; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.subject IS 'Subject of the message';


--
-- Name: COLUMN email.body; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.body IS 'Message body';


--
-- Name: COLUMN email.attachment; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.attachment IS 'Attachment file to send';


--
-- Name: COLUMN email.attachment_mime_type; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.attachment_mime_type IS 'attachment_mime_type';


--
-- Name: COLUMN email.attachment_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.attachment_name IS 'Attachment file name';


--
-- Name: COLUMN email.time_to_send; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.time_to_send IS 'Date and time when to send the message.';


--
-- Name: COLUMN email.attempt; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.attempt IS 'Number of attempt of sending message.';


--
-- Name: COLUMN email.error; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN email.error IS 'Error message received when sending the message.';


--
-- Name: extracted_rows; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE extracted_rows (
    table_name character varying(200) NOT NULL,
    rowidentifier character varying(40) NOT NULL
);


ALTER TABLE system.extracted_rows OWNER TO postgres;

--
-- Name: TABLE extracted_rows; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE extracted_rows IS 'It logs every record that has been extracted from this database for consolidation purposes.';


--
-- Name: COLUMN extracted_rows.table_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN extracted_rows.table_name IS 'The table where the record has been found. It has to be absolute table name including the schema name.';


--
-- Name: COLUMN extracted_rows.rowidentifier; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN extracted_rows.rowidentifier IS 'The rowidentifier of the record. Carefull: It is the rowidentifier and not the id.';


--
-- Name: language; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE language (
    code character varying(7) NOT NULL,
    display_value character varying(250) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    item_order integer DEFAULT 1 NOT NULL,
    ltr boolean DEFAULT true NOT NULL
);


ALTER TABLE system.language OWNER TO postgres;

--
-- Name: TABLE language; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE language IS 'Lists the languages configured for the SOLA application
Tags: FLOSS SOLA Extension, Reference Table, System Configuration';


--
-- Name: COLUMN language.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN language.code IS 'Code for the langauge.';


--
-- Name: COLUMN language.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN language.display_value IS 'The text value that will be displayed to the user.';


--
-- Name: COLUMN language.active; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN language.active IS 'Indicates if the language is current active or not.';


--
-- Name: COLUMN language.is_default; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN language.is_default IS 'Indicates the default language used by SOLA. Only one record in the table should have is_default = true.';


--
-- Name: COLUMN language.item_order; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN language.item_order IS 'The order the langages should be displayed. The lowest order number will display the langage at the top of the language list. Also identifies the order that all localized string values must store their language translations.';


--
-- Name: COLUMN language.ltr; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN language.ltr IS 'Indicates text direction. If true, then left to right should applied, otherwise right to left.';


--
-- Name: map_search_option; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE map_search_option (
    code character varying(20) NOT NULL,
    title character varying(50) NOT NULL,
    query_name character varying(100) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    min_search_str_len smallint DEFAULT 3 NOT NULL,
    zoom_in_buffer numeric(20,2) DEFAULT 50 NOT NULL,
    description character varying(500)
);


ALTER TABLE system.map_search_option OWNER TO postgres;

--
-- Name: TABLE map_search_option; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE map_search_option IS 'Identifies the map search options supported in the Map Viewer along with their configuration details. 
Tags: FLOSS SOLA Extension, Reference Table, Map Configuration';


--
-- Name: COLUMN map_search_option.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.code IS 'The code for the map search option.';


--
-- Name: COLUMN map_search_option.title; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.title IS 'The title displayed to the user for the map search option.';


--
-- Name: COLUMN map_search_option.query_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.query_name IS 'The query (i.e. system.query) that will be used for retrieving the search results. The query requires only one parameter : search_string. Map search queries must be defined to use this parameter and return 3 fields; id - unique id for the matched item, label - the value to display to the user, the_geom: the WKB of the matched geometry.';


--
-- Name: COLUMN map_search_option.active; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.active IS 'Indicates the Map Search Option is active or not.';


--
-- Name: COLUMN map_search_option.min_search_str_len; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.min_search_str_len IS 'The minimum number of characters required for the search string.';


--
-- Name: COLUMN map_search_option.zoom_in_buffer; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.zoom_in_buffer IS 'The buffer distance to use when zooming the map to display the selected object. The units of this value are dependent on the coordinate system of the map (usually meters).';


--
-- Name: COLUMN map_search_option.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.description IS 'A description for the search option.';


--
-- Name: panel_launcher_group; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE panel_launcher_group (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE system.panel_launcher_group OWNER TO postgres;

--
-- Name: TABLE panel_launcher_group; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE panel_launcher_group IS 'Used to group the panel launcher configuration values to make the PanelLancher logic flexible. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN panel_launcher_group.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN panel_launcher_group.code IS 'The code for the panel launcher group';


--
-- Name: COLUMN panel_launcher_group.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN panel_launcher_group.display_value IS 'The user friendly name for the panel launcher group';


--
-- Name: COLUMN panel_launcher_group.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN panel_launcher_group.description IS 'Description for the panel launcher group';


--
-- Name: COLUMN panel_launcher_group.status; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN panel_launcher_group.status IS 'Status of this panel launcher group';


--
-- Name: process_consolidate; Type: SEQUENCE; Schema: system; Owner: postgres
--

CREATE SEQUENCE process_consolidate
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 349
    CACHE 1;


ALTER TABLE system.process_consolidate OWNER TO postgres;

--
-- Name: process_extract; Type: SEQUENCE; Schema: system; Owner: postgres
--

CREATE SEQUENCE process_extract
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 683
    CACHE 1;


ALTER TABLE system.process_extract OWNER TO postgres;

--
-- Name: query; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE query (
    name character varying(100) NOT NULL,
    sql character varying(4000) NOT NULL,
    description character varying(1000)
);


ALTER TABLE system.query OWNER TO postgres;

--
-- Name: TABLE query; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE query IS 'Defines SQL queries that can be executed dynamically by the Search EJB. Also defines queries to retrieve spatial features for each map layer.
Tags: FLOSS SOLA Extension, Reference Table, System Configuration';


--
-- Name: COLUMN query.name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query.name IS 'Identifier/name for the query';


--
-- Name: COLUMN query.sql; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query.sql IS 'The SQL query definition. These SQL queries are executed using MyBatis, so it is possible to identify query parameters using the #{param} syntax.';


--
-- Name: COLUMN query.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query.description IS 'Technical description for the query.';


--
-- Name: query_field; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE query_field (
    query_name character varying(100) NOT NULL,
    index_in_query integer NOT NULL,
    name character varying(100) NOT NULL,
    display_value character varying(200)
);


ALTER TABLE system.query_field OWNER TO postgres;

--
-- Name: TABLE query_field; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE query_field IS 'Optionally defines the fields returned by the queries listed in the system.query table. It is not necessary to specify query fields for every dynamic query. Query fields are only required where the results displayed to the user will vary and localization of the field titles is required. For example the Information Tool in the map displays different result fields for each map layer in the same form.
Tags: FLOSS SOLA Extension, Reference Table, System Configuration';


--
-- Name: COLUMN query_field.query_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query_field.query_name IS 'Identifier/name for the query';


--
-- Name: COLUMN query_field.index_in_query; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query_field.index_in_query IS 'Indicates the position of the result field in the query result set. The index is zero based. The number must not exceed the number of fields in the select part of the query.';


--
-- Name: COLUMN query_field.name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query_field.name IS 'Identifier/name for the query field';


--
-- Name: COLUMN query_field.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query_field.display_value IS 'The title to display for the query field when presenting results to the user. This value supports localization.';


--
-- Name: version; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE version (
    version_num character varying(50) NOT NULL
);


ALTER TABLE system.version OWNER TO postgres;

--
-- Name: TABLE version; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE version IS 'Identifies all changesets that have been applied to the SOLA database. The latest changeset applied to the database will indicate the current version of the SOLA database and code. Changesets are named using the year, month and a sequence character. E.g. The first changeset in Feb 2014 is 1402a, the second changeset in Feb 2014 is 1402b, etc. The sequence character must restart for each new month. E.g. in March 2014 the first changeset is 1403a. 
Tags: FLOSS SOLA Extension, System Configuration';


--
-- Name: COLUMN version.version_num; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN version.version_num IS 'The version number for the changeset.';


SET search_path = transaction, pg_catalog;

--
-- Name: reg_status_type; Type: TABLE; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE TABLE reg_status_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) NOT NULL
);


ALTER TABLE transaction.reg_status_type OWNER TO postgres;

--
-- Name: TABLE reg_status_type; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON TABLE reg_status_type IS 'Code list of registration status types. E.g. current, historic, pending, previous. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN reg_status_type.code; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN reg_status_type.code IS 'The code for the registration status type.';


--
-- Name: COLUMN reg_status_type.display_value; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN reg_status_type.display_value IS 'Displayed value of the registration status type.';


--
-- Name: COLUMN reg_status_type.description; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN reg_status_type.description IS 'Description of the registration status type.';


--
-- Name: COLUMN reg_status_type.status; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN reg_status_type.status IS 'Status of the registration status type';


--
-- Name: transaction_historic; Type: TABLE; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE TABLE transaction_historic (
    id character varying(40),
    from_service_id character varying(40),
    status_code character varying(20),
    approval_datetime timestamp without time zone,
    bulk_generate_first_part boolean,
    is_bulk_operation boolean,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE transaction.transaction_historic OWNER TO postgres;

--
-- Name: transaction_source; Type: TABLE; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE TABLE transaction_source (
    transaction_id character varying(40) NOT NULL,
    source_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE transaction.transaction_source OWNER TO postgres;

--
-- Name: TABLE transaction_source; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON TABLE transaction_source IS 'Associates transactions to source (a.k.a. documents) that justify the transaction. Used by the Cadastre Change and Cadastre Redefintion services.  
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN transaction_source.transaction_id; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.transaction_id IS 'Identifier for the transaction.';


--
-- Name: COLUMN transaction_source.source_id; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.source_id IS 'The identifier of the source associated to the transation.';


--
-- Name: COLUMN transaction_source.rowidentifier; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.rowidentifier IS 'Identifies the all change records for the row in the transaction_source_historic table';


--
-- Name: COLUMN transaction_source.rowversion; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN transaction_source.change_action; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN transaction_source.change_user; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN transaction_source.change_time; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.change_time IS 'The date and time the row was last modified.';


--
-- Name: transaction_source_historic; Type: TABLE; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE TABLE transaction_source_historic (
    transaction_id character varying(40),
    source_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE transaction.transaction_source_historic OWNER TO postgres;

--
-- Name: transaction_status_type; Type: TABLE; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE TABLE transaction_status_type (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    description character varying(1000),
    status character(1) NOT NULL
);


ALTER TABLE transaction.transaction_status_type OWNER TO postgres;

--
-- Name: TABLE transaction_status_type; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON TABLE transaction_status_type IS 'Code list of transaction status types. E.g. pending, approved, cancelled, completed. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN transaction_status_type.code; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_status_type.code IS 'The code for the transaction status type.';


--
-- Name: COLUMN transaction_status_type.display_value; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_status_type.display_value IS 'Displayed value of the transaction status type.';


--
-- Name: COLUMN transaction_status_type.description; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_status_type.description IS 'Description of the transaction status type.';


--
-- Name: COLUMN transaction_status_type.status; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_status_type.status IS 'Status of the transaction status type';


SET search_path = address, pg_catalog;

--
-- Name: address_pkey; Type: CONSTRAINT; Schema: address; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address
    ADD CONSTRAINT address_pkey PRIMARY KEY (id);


SET search_path = administrative, pg_catalog;

--
-- Name: ba_unit_area_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_area
    ADD CONSTRAINT ba_unit_area_pkey PRIMARY KEY (id);


--
-- Name: ba_unit_as_party_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_as_party
    ADD CONSTRAINT ba_unit_as_party_pkey PRIMARY KEY (ba_unit_id, party_id);


--
-- Name: ba_unit_contains_spatial_unit_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_contains_spatial_unit
    ADD CONSTRAINT ba_unit_contains_spatial_unit_pkey PRIMARY KEY (ba_unit_id, spatial_unit_id);


--
-- Name: ba_unit_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit
    ADD CONSTRAINT ba_unit_pkey PRIMARY KEY (id);


--
-- Name: ba_unit_rel_type_display_value_unique; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_rel_type
    ADD CONSTRAINT ba_unit_rel_type_display_value_unique UNIQUE (display_value);


--
-- Name: ba_unit_rel_type_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_rel_type
    ADD CONSTRAINT ba_unit_rel_type_pkey PRIMARY KEY (code);


--
-- Name: ba_unit_target_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_target
    ADD CONSTRAINT ba_unit_target_pkey PRIMARY KEY (ba_unit_id, transaction_id);


--
-- Name: ba_unit_type_display_value_unique; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_type
    ADD CONSTRAINT ba_unit_type_display_value_unique UNIQUE (display_value);


--
-- Name: ba_unit_type_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_type
    ADD CONSTRAINT ba_unit_type_pkey PRIMARY KEY (code);


--
-- Name: condition_for_rrr_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY condition_for_rrr
    ADD CONSTRAINT condition_for_rrr_pkey PRIMARY KEY (id);


--
-- Name: condition_type_display_value_unique; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY condition_type
    ADD CONSTRAINT condition_type_display_value_unique UNIQUE (display_value);


--
-- Name: condition_type_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY condition_type
    ADD CONSTRAINT condition_type_pkey PRIMARY KEY (code);


--
-- Name: mortgage_isbased_in_rrr_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mortgage_isbased_in_rrr
    ADD CONSTRAINT mortgage_isbased_in_rrr_pkey PRIMARY KEY (mortgage_id, rrr_id);


--
-- Name: mortgage_type_display_value_unique; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mortgage_type
    ADD CONSTRAINT mortgage_type_display_value_unique UNIQUE (display_value);


--
-- Name: mortgage_type_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mortgage_type
    ADD CONSTRAINT mortgage_type_pkey PRIMARY KEY (code);


--
-- Name: notation_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY notation
    ADD CONSTRAINT notation_pkey PRIMARY KEY (id);


--
-- Name: notifiable_party_for_baunit_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY notifiable_party_for_baunit
    ADD CONSTRAINT notifiable_party_for_baunit_pkey PRIMARY KEY (party_id, target_party_id, baunit_name);


--
-- Name: party_for_rrr_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_for_rrr
    ADD CONSTRAINT party_for_rrr_pkey PRIMARY KEY (rrr_id, party_id);


--
-- Name: required_relationship_baunit_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY required_relationship_baunit
    ADD CONSTRAINT required_relationship_baunit_pkey PRIMARY KEY (from_ba_unit_id, to_ba_unit_id);


--
-- Name: rrr_group_type_display_value_unique; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rrr_group_type
    ADD CONSTRAINT rrr_group_type_display_value_unique UNIQUE (display_value);


--
-- Name: rrr_group_type_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rrr_group_type
    ADD CONSTRAINT rrr_group_type_pkey PRIMARY KEY (code);


--
-- Name: rrr_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rrr
    ADD CONSTRAINT rrr_pkey PRIMARY KEY (id);


--
-- Name: rrr_share_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rrr_share
    ADD CONSTRAINT rrr_share_pkey PRIMARY KEY (rrr_id, id);


--
-- Name: rrr_type_display_value_unique; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rrr_type
    ADD CONSTRAINT rrr_type_display_value_unique UNIQUE (display_value);


--
-- Name: rrr_type_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rrr_type
    ADD CONSTRAINT rrr_type_pkey PRIMARY KEY (code);


--
-- Name: source_describes_ba_unit_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY source_describes_ba_unit
    ADD CONSTRAINT source_describes_ba_unit_pkey PRIMARY KEY (source_id, ba_unit_id);


--
-- Name: source_describes_rrr_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY source_describes_rrr
    ADD CONSTRAINT source_describes_rrr_pkey PRIMARY KEY (rrr_id, source_id);


SET search_path = application, pg_catalog;

--
-- Name: application_action_type_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_action_type
    ADD CONSTRAINT application_action_type_display_value_unique UNIQUE (display_value);


--
-- Name: application_action_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_action_type
    ADD CONSTRAINT application_action_type_pkey PRIMARY KEY (code);


--
-- Name: application_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application
    ADD CONSTRAINT application_pkey PRIMARY KEY (id);


--
-- Name: application_property_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_property
    ADD CONSTRAINT application_property_pkey PRIMARY KEY (id);


--
-- Name: application_property_property_once; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_property
    ADD CONSTRAINT application_property_property_once UNIQUE (application_id, name_firstpart, name_lastpart);


--
-- Name: application_spatial_unit_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_spatial_unit
    ADD CONSTRAINT application_spatial_unit_pkey PRIMARY KEY (application_id, spatial_unit_id);


--
-- Name: application_status_type_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_status_type
    ADD CONSTRAINT application_status_type_display_value_unique UNIQUE (display_value);


--
-- Name: application_status_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_status_type
    ADD CONSTRAINT application_status_type_pkey PRIMARY KEY (code);


--
-- Name: application_uses_source_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_uses_source
    ADD CONSTRAINT application_uses_source_pkey PRIMARY KEY (application_id, source_id);


--
-- Name: request_category_type_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY request_category_type
    ADD CONSTRAINT request_category_type_display_value_unique UNIQUE (display_value);


--
-- Name: request_category_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY request_category_type
    ADD CONSTRAINT request_category_type_pkey PRIMARY KEY (code);


--
-- Name: request_type_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY request_type
    ADD CONSTRAINT request_type_display_value_unique UNIQUE (display_value);


--
-- Name: request_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY request_type
    ADD CONSTRAINT request_type_pkey PRIMARY KEY (code);


--
-- Name: request_type_requires_source_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY request_type_requires_source_type
    ADD CONSTRAINT request_type_requires_source_type_pkey PRIMARY KEY (source_type_code, request_type_code);


--
-- Name: service_action_type_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY service_action_type
    ADD CONSTRAINT service_action_type_display_value_unique UNIQUE (display_value);


--
-- Name: service_action_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY service_action_type
    ADD CONSTRAINT service_action_type_pkey PRIMARY KEY (code);


--
-- Name: service_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_pkey PRIMARY KEY (id);


--
-- Name: service_status_type_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY service_status_type
    ADD CONSTRAINT service_status_type_display_value_unique UNIQUE (display_value);


--
-- Name: service_status_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY service_status_type
    ADD CONSTRAINT service_status_type_pkey PRIMARY KEY (code);


--
-- Name: type_action_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY type_action
    ADD CONSTRAINT type_action_display_value_unique UNIQUE (display_value);


--
-- Name: type_action_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY type_action
    ADD CONSTRAINT type_action_pkey PRIMARY KEY (code);


SET search_path = bulk_operation, pg_catalog;

--
-- Name: spatial_unit_temporary_pkey; Type: CONSTRAINT; Schema: bulk_operation; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_unit_temporary
    ADD CONSTRAINT spatial_unit_temporary_pkey PRIMARY KEY (id);


SET search_path = cadastre, pg_catalog;

--
-- Name: area_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY area_type
    ADD CONSTRAINT area_type_display_value_unique UNIQUE (display_value);


--
-- Name: area_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY area_type
    ADD CONSTRAINT area_type_pkey PRIMARY KEY (code);


--
-- Name: building_unit_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY building_unit_type
    ADD CONSTRAINT building_unit_type_display_value_unique UNIQUE (display_value);


--
-- Name: building_unit_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY building_unit_type
    ADD CONSTRAINT building_unit_type_pkey PRIMARY KEY (code);


--
-- Name: cadastre_object_name; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_name UNIQUE (name_firstpart, name_lastpart);


--
-- Name: cadastre_object_node_target_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cadastre_object_node_target
    ADD CONSTRAINT cadastre_object_node_target_pkey PRIMARY KEY (transaction_id, node_id);


--
-- Name: cadastre_object_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_pkey PRIMARY KEY (id);


--
-- Name: cadastre_object_target_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cadastre_object_target
    ADD CONSTRAINT cadastre_object_target_pkey PRIMARY KEY (transaction_id, cadastre_object_id);


--
-- Name: cadastre_object_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cadastre_object_type
    ADD CONSTRAINT cadastre_object_type_display_value_unique UNIQUE (display_value);


--
-- Name: cadastre_object_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cadastre_object_type
    ADD CONSTRAINT cadastre_object_type_pkey PRIMARY KEY (code);


--
-- Name: config_map_layer_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY level_config_map_layer
    ADD CONSTRAINT config_map_layer_pkey PRIMARY KEY (level_id, config_map_layer_name);


--
-- Name: dimension_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dimension_type
    ADD CONSTRAINT dimension_type_display_value_unique UNIQUE (display_value);


--
-- Name: dimension_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dimension_type
    ADD CONSTRAINT dimension_type_pkey PRIMARY KEY (code);


--
-- Name: hierarchy_level_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY hierarchy_level
    ADD CONSTRAINT hierarchy_level_display_value_unique UNIQUE (display_value);


--
-- Name: hierarchy_level_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY hierarchy_level
    ADD CONSTRAINT hierarchy_level_pkey PRIMARY KEY (code);


--
-- Name: land_use_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY land_use_type
    ADD CONSTRAINT land_use_type_display_value_unique UNIQUE (display_value);


--
-- Name: land_use_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY land_use_type
    ADD CONSTRAINT land_use_type_pkey PRIMARY KEY (code);


--
-- Name: legal_space_utility_network_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY legal_space_utility_network
    ADD CONSTRAINT legal_space_utility_network_pkey PRIMARY KEY (id);


--
-- Name: level_content_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY level_content_type
    ADD CONSTRAINT level_content_type_display_value_unique UNIQUE (display_value);


--
-- Name: level_content_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY level_content_type
    ADD CONSTRAINT level_content_type_pkey PRIMARY KEY (code);


--
-- Name: level_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY level
    ADD CONSTRAINT level_pkey PRIMARY KEY (id);


--
-- Name: register_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY register_type
    ADD CONSTRAINT register_type_display_value_unique UNIQUE (display_value);


--
-- Name: register_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY register_type
    ADD CONSTRAINT register_type_pkey PRIMARY KEY (code);


--
-- Name: spatial_unit_address_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_unit_address
    ADD CONSTRAINT spatial_unit_address_pkey PRIMARY KEY (spatial_unit_id, address_id);


--
-- Name: spatial_unit_group_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_unit_group
    ADD CONSTRAINT spatial_unit_group_pkey PRIMARY KEY (id);


--
-- Name: spatial_unit_in_group_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_unit_in_group
    ADD CONSTRAINT spatial_unit_in_group_pkey PRIMARY KEY (spatial_unit_group_id, spatial_unit_id);


--
-- Name: spatial_unit_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_unit
    ADD CONSTRAINT spatial_unit_pkey PRIMARY KEY (id);


--
-- Name: spatial_value_area_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_value_area
    ADD CONSTRAINT spatial_value_area_pkey PRIMARY KEY (spatial_unit_id, type_code);


--
-- Name: structure_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY structure_type
    ADD CONSTRAINT structure_type_display_value_unique UNIQUE (display_value);


--
-- Name: structure_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY structure_type
    ADD CONSTRAINT structure_type_pkey PRIMARY KEY (code);


--
-- Name: surface_relation_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY surface_relation_type
    ADD CONSTRAINT surface_relation_type_display_value_unique UNIQUE (display_value);


--
-- Name: surface_relation_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY surface_relation_type
    ADD CONSTRAINT surface_relation_type_pkey PRIMARY KEY (code);


--
-- Name: survey_point_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY survey_point
    ADD CONSTRAINT survey_point_pkey PRIMARY KEY (transaction_id, id);


--
-- Name: utility_network_status_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY utility_network_status_type
    ADD CONSTRAINT utility_network_status_type_display_value_unique UNIQUE (display_value);


--
-- Name: utility_network_status_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY utility_network_status_type
    ADD CONSTRAINT utility_network_status_type_pkey PRIMARY KEY (code);


--
-- Name: utility_network_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY utility_network_type
    ADD CONSTRAINT utility_network_type_display_value_unique UNIQUE (display_value);


--
-- Name: utility_network_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY utility_network_type
    ADD CONSTRAINT utility_network_type_pkey PRIMARY KEY (code);


SET search_path = document, pg_catalog;

--
-- Name: document_nr_unique; Type: CONSTRAINT; Schema: document; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT document_nr_unique UNIQUE (nr);


--
-- Name: document_pkey; Type: CONSTRAINT; Schema: document; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT document_pkey PRIMARY KEY (id);


--
-- Name: id_pkey_document_chunk; Type: CONSTRAINT; Schema: document; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document_chunk
    ADD CONSTRAINT id_pkey_document_chunk PRIMARY KEY (id);


--
-- Name: start_unique_document_chunk; Type: CONSTRAINT; Schema: document; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document_chunk
    ADD CONSTRAINT start_unique_document_chunk UNIQUE (document_id, start_position);


SET search_path = opentenure, pg_catalog;

--
-- Name: attachment_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attachment
    ADD CONSTRAINT attachment_pkey PRIMARY KEY (id);


--
-- Name: claim_comment_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim_comment
    ADD CONSTRAINT claim_comment_pkey PRIMARY KEY (id);


--
-- Name: claim_location_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim_location
    ADD CONSTRAINT claim_location_pkey PRIMARY KEY (id);


--
-- Name: claim_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT claim_pkey PRIMARY KEY (id);


--
-- Name: claim_share_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim_share
    ADD CONSTRAINT claim_share_pkey PRIMARY KEY (id);


--
-- Name: claim_status_display_value_unique; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim_status
    ADD CONSTRAINT claim_status_display_value_unique UNIQUE (display_value);


--
-- Name: claim_status_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim_status
    ADD CONSTRAINT claim_status_pkey PRIMARY KEY (code);


--
-- Name: claim_uses_attachment_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY claim_uses_attachment
    ADD CONSTRAINT claim_uses_attachment_pkey PRIMARY KEY (claim_id, attachment_id);


--
-- Name: claimant_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party
    ADD CONSTRAINT claimant_pkey PRIMARY KEY (id);


--
-- Name: field_constraint_option_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_constraint_option
    ADD CONSTRAINT field_constraint_option_pkey PRIMARY KEY (id);


--
-- Name: field_constraint_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_constraint
    ADD CONSTRAINT field_constraint_pkey PRIMARY KEY (id);


--
-- Name: field_constraint_type_display_value_unique; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_constraint_type
    ADD CONSTRAINT field_constraint_type_display_value_unique UNIQUE (display_value);


--
-- Name: field_constraint_type_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_constraint_type
    ADD CONSTRAINT field_constraint_type_pkey PRIMARY KEY (code);


--
-- Name: field_payload_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_payload
    ADD CONSTRAINT field_payload_pkey PRIMARY KEY (id);


--
-- Name: field_template_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_template
    ADD CONSTRAINT field_template_pkey PRIMARY KEY (id);


--
-- Name: field_type_display_value_unique; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_type
    ADD CONSTRAINT field_type_display_value_unique UNIQUE (display_value);


--
-- Name: field_type_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_type
    ADD CONSTRAINT field_type_pkey PRIMARY KEY (code);


--
-- Name: field_value_type_display_value_unique; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_value_type
    ADD CONSTRAINT field_value_type_display_value_unique UNIQUE (display_value);


--
-- Name: field_value_type_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY field_value_type
    ADD CONSTRAINT field_value_type_pkey PRIMARY KEY (code);


--
-- Name: form_payload_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY form_payload
    ADD CONSTRAINT form_payload_pkey PRIMARY KEY (id);


--
-- Name: form_template_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY form_template
    ADD CONSTRAINT form_template_pkey PRIMARY KEY (name);


--
-- Name: id_pkey_document_chunk; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attachment_chunk
    ADD CONSTRAINT id_pkey_document_chunk PRIMARY KEY (id);


--
-- Name: party_for_claim_share_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_for_claim_share
    ADD CONSTRAINT party_for_claim_share_pkey PRIMARY KEY (party_id, claim_share_id);


--
-- Name: rejection_reason_display_value_unique; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rejection_reason
    ADD CONSTRAINT rejection_reason_display_value_unique UNIQUE (display_value);


--
-- Name: rejection_reason_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rejection_reason
    ADD CONSTRAINT rejection_reason_pkey PRIMARY KEY (code);


--
-- Name: section_element_payload_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY section_element_payload
    ADD CONSTRAINT section_element_payload_pkey PRIMARY KEY (id);


--
-- Name: section_payload_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY section_payload
    ADD CONSTRAINT section_payload_pkey PRIMARY KEY (id);


--
-- Name: section_template_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY section_template
    ADD CONSTRAINT section_template_pkey PRIMARY KEY (id);


--
-- Name: start_unique_document_chunk; Type: CONSTRAINT; Schema: opentenure; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attachment_chunk
    ADD CONSTRAINT start_unique_document_chunk UNIQUE (attachment_id, start_position);


SET search_path = party, pg_catalog;

--
-- Name: communication_type_display_value_unique; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY communication_type
    ADD CONSTRAINT communication_type_display_value_unique UNIQUE (display_value);


--
-- Name: communication_type_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY communication_type
    ADD CONSTRAINT communication_type_pkey PRIMARY KEY (code);


--
-- Name: gender_type_display_value_unique; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY gender_type
    ADD CONSTRAINT gender_type_display_value_unique UNIQUE (display_value);


--
-- Name: gender_type_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY gender_type
    ADD CONSTRAINT gender_type_pkey PRIMARY KEY (code);


--
-- Name: group_party_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY group_party
    ADD CONSTRAINT group_party_pkey PRIMARY KEY (id);


--
-- Name: group_party_type_display_value_unique; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY group_party_type
    ADD CONSTRAINT group_party_type_display_value_unique UNIQUE (display_value);


--
-- Name: group_party_type_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY group_party_type
    ADD CONSTRAINT group_party_type_pkey PRIMARY KEY (code);


--
-- Name: id_type_display_value_unique; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY id_type
    ADD CONSTRAINT id_type_display_value_unique UNIQUE (display_value);


--
-- Name: id_type_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY id_type
    ADD CONSTRAINT id_type_pkey PRIMARY KEY (code);


--
-- Name: party_member_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_member
    ADD CONSTRAINT party_member_pkey PRIMARY KEY (party_id, group_id);


--
-- Name: party_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_pkey PRIMARY KEY (id);


--
-- Name: party_role_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_role
    ADD CONSTRAINT party_role_pkey PRIMARY KEY (party_id, type_code);


--
-- Name: party_role_type_display_value_unique; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_role_type
    ADD CONSTRAINT party_role_type_display_value_unique UNIQUE (display_value);


--
-- Name: party_role_type_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_role_type
    ADD CONSTRAINT party_role_type_pkey PRIMARY KEY (code);


--
-- Name: party_type_display_value_unique; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_type
    ADD CONSTRAINT party_type_display_value_unique UNIQUE (display_value);


--
-- Name: party_type_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_type
    ADD CONSTRAINT party_type_pkey PRIMARY KEY (code);


--
-- Name: source_describes_party_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY source_describes_party
    ADD CONSTRAINT source_describes_party_pkey PRIMARY KEY (source_id, party_id);


SET search_path = source, pg_catalog;

--
-- Name: administrative_source_type_display_value_unique; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY administrative_source_type
    ADD CONSTRAINT administrative_source_type_display_value_unique UNIQUE (display_value);


--
-- Name: administrative_source_type_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY administrative_source_type
    ADD CONSTRAINT administrative_source_type_pkey PRIMARY KEY (code);


--
-- Name: archive_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY archive
    ADD CONSTRAINT archive_pkey PRIMARY KEY (id);


--
-- Name: availability_status_type_display_value_unique; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY availability_status_type
    ADD CONSTRAINT availability_status_type_display_value_unique UNIQUE (display_value);


--
-- Name: availability_status_type_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY availability_status_type
    ADD CONSTRAINT availability_status_type_pkey PRIMARY KEY (code);


--
-- Name: power_of_attorney_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY power_of_attorney
    ADD CONSTRAINT power_of_attorney_pkey PRIMARY KEY (id);


--
-- Name: presentation_form_type_display_value_unique; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY presentation_form_type
    ADD CONSTRAINT presentation_form_type_display_value_unique UNIQUE (display_value);


--
-- Name: presentation_form_type_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY presentation_form_type
    ADD CONSTRAINT presentation_form_type_pkey PRIMARY KEY (code);


--
-- Name: source_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_pkey PRIMARY KEY (id);


--
-- Name: spatial_source_measurement_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_source_measurement
    ADD CONSTRAINT spatial_source_measurement_pkey PRIMARY KEY (spatial_source_id, id);


--
-- Name: spatial_source_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_source
    ADD CONSTRAINT spatial_source_pkey PRIMARY KEY (id);


--
-- Name: spatial_source_type_display_value_unique; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_source_type
    ADD CONSTRAINT spatial_source_type_display_value_unique UNIQUE (display_value);


--
-- Name: spatial_source_type_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_source_type
    ADD CONSTRAINT spatial_source_type_pkey PRIMARY KEY (code);


SET search_path = system, pg_catalog;

--
-- Name: appgroup_name_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appgroup
    ADD CONSTRAINT appgroup_name_unique UNIQUE (name);


--
-- Name: appgroup_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appgroup
    ADD CONSTRAINT appgroup_pkey PRIMARY KEY (id);


--
-- Name: approle_appgroup_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY approle_appgroup
    ADD CONSTRAINT approle_appgroup_pkey PRIMARY KEY (approle_code, appgroup_id);


--
-- Name: approle_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY approle
    ADD CONSTRAINT approle_display_value_unique UNIQUE (display_value);


--
-- Name: approle_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY approle
    ADD CONSTRAINT approle_pkey PRIMARY KEY (code);


--
-- Name: appuser_appgroup_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appuser_appgroup
    ADD CONSTRAINT appuser_appgroup_pkey PRIMARY KEY (appuser_id, appgroup_id);


--
-- Name: appuser_email_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appuser
    ADD CONSTRAINT appuser_email_unique UNIQUE (email);


--
-- Name: appuser_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appuser
    ADD CONSTRAINT appuser_pkey PRIMARY KEY (id);


--
-- Name: appuser_setting_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appuser_setting
    ADD CONSTRAINT appuser_setting_pkey PRIMARY KEY (user_id, name);


--
-- Name: appuser_username_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appuser
    ADD CONSTRAINT appuser_username_unique UNIQUE (username);


--
-- Name: br_definition_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_definition
    ADD CONSTRAINT br_definition_pkey PRIMARY KEY (br_id, active_from);


--
-- Name: br_display_name_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br
    ADD CONSTRAINT br_display_name_unique UNIQUE (display_name);


--
-- Name: br_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br
    ADD CONSTRAINT br_pkey PRIMARY KEY (id);


--
-- Name: br_severity_type_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_severity_type
    ADD CONSTRAINT br_severity_type_display_value_unique UNIQUE (display_value);


--
-- Name: br_severity_type_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_severity_type
    ADD CONSTRAINT br_severity_type_pkey PRIMARY KEY (code);


--
-- Name: br_technical_type_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_technical_type
    ADD CONSTRAINT br_technical_type_display_value_unique UNIQUE (display_value);


--
-- Name: br_technical_type_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_technical_type
    ADD CONSTRAINT br_technical_type_pkey PRIMARY KEY (code);


--
-- Name: br_validation_app_moment_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_app_moment_unique UNIQUE (br_id, target_code, target_application_moment);


--
-- Name: br_validation_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_pkey PRIMARY KEY (id);


--
-- Name: br_validation_reg_moment_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_reg_moment_unique UNIQUE (br_id, target_code, target_reg_moment);


--
-- Name: br_validation_service_moment_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_service_moment_unique UNIQUE (br_id, target_code, target_service_moment, target_request_type_code);


--
-- Name: br_validation_target_type_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_validation_target_type
    ADD CONSTRAINT br_validation_target_type_display_value_unique UNIQUE (display_value);


--
-- Name: br_validation_target_type_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_validation_target_type
    ADD CONSTRAINT br_validation_target_type_pkey PRIMARY KEY (code);


--
-- Name: config_map_layer_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY config_map_layer
    ADD CONSTRAINT config_map_layer_pkey PRIMARY KEY (name);


--
-- Name: config_map_layer_title_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY config_map_layer
    ADD CONSTRAINT config_map_layer_title_unique UNIQUE (title);


--
-- Name: config_map_layer_type_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY config_map_layer_type
    ADD CONSTRAINT config_map_layer_type_display_value_unique UNIQUE (display_value);


--
-- Name: config_map_layer_type_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY config_map_layer_type
    ADD CONSTRAINT config_map_layer_type_pkey PRIMARY KEY (code);


--
-- Name: config_panel_launcher_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY config_panel_launcher
    ADD CONSTRAINT config_panel_launcher_display_value_unique UNIQUE (display_value);


--
-- Name: config_panel_launcher_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY config_panel_launcher
    ADD CONSTRAINT config_panel_launcher_pkey PRIMARY KEY (code);


--
-- Name: consolidation_config_lkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY consolidation_config
    ADD CONSTRAINT consolidation_config_lkey UNIQUE (schema_name, table_name);


--
-- Name: consolidation_config_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY consolidation_config
    ADD CONSTRAINT consolidation_config_pkey PRIMARY KEY (id);


--
-- Name: crs_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY crs
    ADD CONSTRAINT crs_pkey PRIMARY KEY (srid);


--
-- Name: email_pk_id; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY email
    ADD CONSTRAINT email_pk_id PRIMARY KEY (id);


--
-- Name: extracted_rows_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY extracted_rows
    ADD CONSTRAINT extracted_rows_pkey PRIMARY KEY (table_name, rowidentifier);


--
-- Name: language_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_display_value_unique UNIQUE (display_value);


--
-- Name: language_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_pkey PRIMARY KEY (code);


--
-- Name: map_search_option_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY map_search_option
    ADD CONSTRAINT map_search_option_pkey PRIMARY KEY (code);


--
-- Name: map_search_option_title_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY map_search_option
    ADD CONSTRAINT map_search_option_title_unique UNIQUE (title);


--
-- Name: panel_launcher_group_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY panel_launcher_group
    ADD CONSTRAINT panel_launcher_group_display_value_unique UNIQUE (display_value);


--
-- Name: panel_launcher_group_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY panel_launcher_group
    ADD CONSTRAINT panel_launcher_group_pkey PRIMARY KEY (code);


--
-- Name: pk_config_map_layer_metadata; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY config_map_layer_metadata
    ADD CONSTRAINT pk_config_map_layer_metadata PRIMARY KEY (name_layer, name);


--
-- Name: query_field_display_value; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY query_field
    ADD CONSTRAINT query_field_display_value UNIQUE (query_name, display_value);


--
-- Name: query_field_name; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY query_field
    ADD CONSTRAINT query_field_name UNIQUE (query_name, name);


--
-- Name: query_field_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY query_field
    ADD CONSTRAINT query_field_pkey PRIMARY KEY (query_name, index_in_query);


--
-- Name: query_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY query
    ADD CONSTRAINT query_pkey PRIMARY KEY (name);


--
-- Name: setting_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (name);


--
-- Name: version_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY version
    ADD CONSTRAINT version_pkey PRIMARY KEY (version_num);


SET search_path = transaction, pg_catalog;

--
-- Name: reg_status_type_display_value_unique; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reg_status_type
    ADD CONSTRAINT reg_status_type_display_value_unique UNIQUE (display_value);


--
-- Name: reg_status_type_pkey; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reg_status_type
    ADD CONSTRAINT reg_status_type_pkey PRIMARY KEY (code);


--
-- Name: transaction_from_service_id_unique; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_from_service_id_unique UNIQUE (from_service_id);


--
-- Name: transaction_pkey; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- Name: transaction_source_pkey; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transaction_source
    ADD CONSTRAINT transaction_source_pkey PRIMARY KEY (transaction_id, source_id);


--
-- Name: transaction_status_type_display_value_unique; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transaction_status_type
    ADD CONSTRAINT transaction_status_type_display_value_unique UNIQUE (display_value);


--
-- Name: transaction_status_type_pkey; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transaction_status_type
    ADD CONSTRAINT transaction_status_type_pkey PRIMARY KEY (code);


SET search_path = address, pg_catalog;

--
-- Name: address_historic_index_on_rowidentifier; Type: INDEX; Schema: address; Owner: postgres; Tablespace: 
--

CREATE INDEX address_historic_index_on_rowidentifier ON address_historic USING btree (rowidentifier);


--
-- Name: address_index_on_rowidentifier; Type: INDEX; Schema: address; Owner: postgres; Tablespace: 
--

CREATE INDEX address_index_on_rowidentifier ON address USING btree (rowidentifier);


SET search_path = administrative, pg_catalog;

--
-- Name: ba_unit_area_ba_unit_id_fk77_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_area_ba_unit_id_fk77_ind ON ba_unit_area USING btree (ba_unit_id);


--
-- Name: ba_unit_area_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_area_historic_index_on_rowidentifier ON ba_unit_area_historic USING btree (rowidentifier);


--
-- Name: ba_unit_area_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_area_index_on_rowidentifier ON ba_unit_area USING btree (rowidentifier);


--
-- Name: ba_unit_area_type_code_fk78_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_area_type_code_fk78_ind ON ba_unit_area USING btree (type_code);


--
-- Name: ba_unit_as_party_ba_unit_id_fk71_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_as_party_ba_unit_id_fk71_ind ON ba_unit_as_party USING btree (ba_unit_id);


--
-- Name: ba_unit_as_party_party_id_fk72_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_as_party_party_id_fk72_ind ON ba_unit_as_party USING btree (party_id);


--
-- Name: ba_unit_contains_spatial_unit_ba_unit_id_fk68_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_contains_spatial_unit_ba_unit_id_fk68_ind ON ba_unit_contains_spatial_unit USING btree (ba_unit_id);


--
-- Name: ba_unit_contains_spatial_unit_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_contains_spatial_unit_historic_index_on_rowidentifier ON ba_unit_contains_spatial_unit_historic USING btree (rowidentifier);


--
-- Name: ba_unit_contains_spatial_unit_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_contains_spatial_unit_index_on_rowidentifier ON ba_unit_contains_spatial_unit USING btree (rowidentifier);


--
-- Name: ba_unit_contains_spatial_unit_spatial_unit_id_fk69_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_contains_spatial_unit_spatial_unit_id_fk69_ind ON ba_unit_contains_spatial_unit USING btree (spatial_unit_id);


--
-- Name: ba_unit_contains_spatial_unit_spatial_unit_id_fk70_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_contains_spatial_unit_spatial_unit_id_fk70_ind ON ba_unit_contains_spatial_unit USING btree (spatial_unit_id);


--
-- Name: ba_unit_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_historic_index_on_rowidentifier ON ba_unit_historic USING btree (rowidentifier);


--
-- Name: ba_unit_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_index_on_rowidentifier ON ba_unit USING btree (rowidentifier);


--
-- Name: ba_unit_status_code_fk39_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_status_code_fk39_ind ON ba_unit USING btree (status_code);


--
-- Name: ba_unit_target_ba_unit_id_fk83_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_target_ba_unit_id_fk83_ind ON ba_unit_target USING btree (ba_unit_id);


--
-- Name: ba_unit_target_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_target_historic_index_on_rowidentifier ON ba_unit_target_historic USING btree (rowidentifier);


--
-- Name: ba_unit_target_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_target_index_on_rowidentifier ON ba_unit_target USING btree (rowidentifier);


--
-- Name: ba_unit_target_transaction_id_fk84_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_target_transaction_id_fk84_ind ON ba_unit_target USING btree (transaction_id);


--
-- Name: ba_unit_transaction_id_fk40_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_transaction_id_fk40_ind ON ba_unit USING btree (transaction_id);


--
-- Name: ba_unit_type_code_fk38_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_type_code_fk38_ind ON ba_unit USING btree (type_code);


--
-- Name: condition_for_rrr_condition_code_fk85_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX condition_for_rrr_condition_code_fk85_ind ON condition_for_rrr USING btree (condition_code);


--
-- Name: condition_for_rrr_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX condition_for_rrr_historic_index_on_rowidentifier ON condition_for_rrr_historic USING btree (rowidentifier);


--
-- Name: condition_for_rrr_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX condition_for_rrr_index_on_rowidentifier ON condition_for_rrr USING btree (rowidentifier);


--
-- Name: condition_for_rrr_rrr_id_fk86_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX condition_for_rrr_rrr_id_fk86_ind ON condition_for_rrr USING btree (rrr_id);


--
-- Name: mortgage_isbased_in_rrr_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX mortgage_isbased_in_rrr_historic_index_on_rowidentifier ON mortgage_isbased_in_rrr_historic USING btree (rowidentifier);


--
-- Name: mortgage_isbased_in_rrr_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX mortgage_isbased_in_rrr_index_on_rowidentifier ON mortgage_isbased_in_rrr USING btree (rowidentifier);


--
-- Name: mortgage_isbased_in_rrr_mortgage_id_fk47_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX mortgage_isbased_in_rrr_mortgage_id_fk47_ind ON mortgage_isbased_in_rrr USING btree (mortgage_id);


--
-- Name: mortgage_isbased_in_rrr_rrr_id_fk46_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX mortgage_isbased_in_rrr_rrr_id_fk46_ind ON mortgage_isbased_in_rrr USING btree (rrr_id);


--
-- Name: notation_ba_unit_id_fk75_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notation_ba_unit_id_fk75_ind ON notation USING btree (ba_unit_id);


--
-- Name: notation_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notation_historic_index_on_rowidentifier ON notation_historic USING btree (rowidentifier);


--
-- Name: notation_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notation_index_on_rowidentifier ON notation USING btree (rowidentifier);


--
-- Name: notation_rrr_id_fk76_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notation_rrr_id_fk76_ind ON notation USING btree (rrr_id);


--
-- Name: notation_status_code_fk74_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notation_status_code_fk74_ind ON notation USING btree (status_code);


--
-- Name: notation_transaction_id_fk73_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notation_transaction_id_fk73_ind ON notation USING btree (transaction_id);


--
-- Name: notifiable_party_for_baunit_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notifiable_party_for_baunit_historic_index_on_rowidentifier ON notifiable_party_for_baunit_historic USING btree (rowidentifier);


--
-- Name: notifiable_party_for_baunit_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notifiable_party_for_baunit_index_on_rowidentifier ON notifiable_party_for_baunit USING btree (rowidentifier);


--
-- Name: party_for_rrr_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX party_for_rrr_historic_index_on_rowidentifier ON party_for_rrr_historic USING btree (rowidentifier);


--
-- Name: party_for_rrr_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX party_for_rrr_index_on_rowidentifier ON party_for_rrr USING btree (rowidentifier);


--
-- Name: party_for_rrr_party_id_fk82_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX party_for_rrr_party_id_fk82_ind ON party_for_rrr USING btree (party_id);


--
-- Name: party_for_rrr_rrr_id_fk80_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX party_for_rrr_rrr_id_fk80_ind ON party_for_rrr USING btree (rrr_id, share_id);


--
-- Name: party_for_rrr_rrr_id_fk81_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX party_for_rrr_rrr_id_fk81_ind ON party_for_rrr USING btree (rrr_id);


--
-- Name: required_relationship_baunit_from_ba_unit_id_fk52_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX required_relationship_baunit_from_ba_unit_id_fk52_ind ON required_relationship_baunit USING btree (from_ba_unit_id);


--
-- Name: required_relationship_baunit_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX required_relationship_baunit_historic_index_on_rowidentifier ON required_relationship_baunit_historic USING btree (rowidentifier);


--
-- Name: required_relationship_baunit_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX required_relationship_baunit_index_on_rowidentifier ON required_relationship_baunit USING btree (rowidentifier);


--
-- Name: required_relationship_baunit_relation_code_fk54_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX required_relationship_baunit_relation_code_fk54_ind ON required_relationship_baunit USING btree (relation_code);


--
-- Name: required_relationship_baunit_to_ba_unit_id_fk53_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX required_relationship_baunit_to_ba_unit_id_fk53_ind ON required_relationship_baunit USING btree (to_ba_unit_id);


--
-- Name: rrr_ba_unit_id_fk42_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_ba_unit_id_fk42_ind ON rrr USING btree (ba_unit_id);


--
-- Name: rrr_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_historic_index_on_rowidentifier ON rrr_historic USING btree (rowidentifier);


--
-- Name: rrr_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_index_on_rowidentifier ON rrr USING btree (rowidentifier);


--
-- Name: rrr_mortgage_type_code_fk45_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_mortgage_type_code_fk45_ind ON rrr USING btree (mortgage_type_code);


--
-- Name: rrr_share_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_share_historic_index_on_rowidentifier ON rrr_share_historic USING btree (rowidentifier);


--
-- Name: rrr_share_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_share_index_on_rowidentifier ON rrr_share USING btree (rowidentifier);


--
-- Name: rrr_share_rrr_id_fk79_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_share_rrr_id_fk79_ind ON rrr_share USING btree (rrr_id);


--
-- Name: rrr_status_code_fk43_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_status_code_fk43_ind ON rrr USING btree (status_code);


--
-- Name: rrr_transaction_id_fk44_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_transaction_id_fk44_ind ON rrr USING btree (transaction_id);


--
-- Name: rrr_type_code_fk41_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_type_code_fk41_ind ON rrr USING btree (type_code);


--
-- Name: rrr_type_config_panel_launcher_fkey_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_type_config_panel_launcher_fkey_ind ON rrr_type USING btree (rrr_panel_code);


--
-- Name: rrr_type_rrr_group_type_code_fk22_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_type_rrr_group_type_code_fk22_ind ON rrr_type USING btree (rrr_group_type_code);


--
-- Name: source_describes_ba_unit_ba_unit_id_fk50_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_ba_unit_ba_unit_id_fk50_ind ON source_describes_ba_unit USING btree (ba_unit_id);


--
-- Name: source_describes_ba_unit_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_ba_unit_historic_index_on_rowidentifier ON source_describes_ba_unit_historic USING btree (rowidentifier);


--
-- Name: source_describes_ba_unit_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_ba_unit_index_on_rowidentifier ON source_describes_ba_unit USING btree (rowidentifier);


--
-- Name: source_describes_ba_unit_source_id_fk51_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_ba_unit_source_id_fk51_ind ON source_describes_ba_unit USING btree (source_id);


--
-- Name: source_describes_rrr_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_rrr_historic_index_on_rowidentifier ON source_describes_rrr_historic USING btree (rowidentifier);


--
-- Name: source_describes_rrr_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_rrr_index_on_rowidentifier ON source_describes_rrr USING btree (rowidentifier);


--
-- Name: source_describes_rrr_rrr_id_fk48_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_rrr_rrr_id_fk48_ind ON source_describes_rrr USING btree (rrr_id);


--
-- Name: source_describes_rrr_source_id_fk49_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_rrr_source_id_fk49_ind ON source_describes_rrr USING btree (source_id);


SET search_path = application, pg_catalog;

--
-- Name: application_action_code_fk16_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_action_code_fk16_ind ON application USING btree (action_code);


--
-- Name: application_action_type_status_to_set_fk17_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_action_type_status_to_set_fk17_ind ON application_action_type USING btree (status_to_set);


--
-- Name: application_agent_id_fk8_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_agent_id_fk8_ind ON application USING btree (agent_id);


--
-- Name: application_assignee_id_fk15_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_assignee_id_fk15_ind ON application USING btree (assignee_id);


--
-- Name: application_contact_person_id_fk14_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_contact_person_id_fk14_ind ON application USING btree (contact_person_id);


--
-- Name: application_historic_id_idx; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_historic_id_idx ON application_historic USING btree (id);


--
-- Name: application_historic_id_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_historic_id_ind ON application_historic USING btree (id);


--
-- Name: application_historic_index_on_location; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_historic_index_on_location ON application_historic USING gist (location);


--
-- Name: application_historic_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_historic_index_on_rowidentifier ON application_historic USING btree (rowidentifier);


--
-- Name: application_index_on_location; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_index_on_location ON application USING gist (location);


--
-- Name: application_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_index_on_rowidentifier ON application USING btree (rowidentifier);


--
-- Name: application_property_application_id_fk123_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_property_application_id_fk123_ind ON application_property USING btree (application_id);


--
-- Name: application_property_ba_unit_id_fk124_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_property_ba_unit_id_fk124_ind ON application_property USING btree (ba_unit_id);


--
-- Name: application_property_historic_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_property_historic_index_on_rowidentifier ON application_property_historic USING btree (rowidentifier);


--
-- Name: application_property_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_property_index_on_rowidentifier ON application_property USING btree (rowidentifier);


--
-- Name: application_property_land_use_code_fk125_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_property_land_use_code_fk125_ind ON application_property USING btree (land_use_code);


--
-- Name: application_spatial_unit_application_id_fk130_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_spatial_unit_application_id_fk130_ind ON application_spatial_unit USING btree (application_id);


--
-- Name: application_spatial_unit_historic_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_spatial_unit_historic_index_on_rowidentifier ON application_spatial_unit_historic USING btree (rowidentifier);


--
-- Name: application_spatial_unit_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_spatial_unit_index_on_rowidentifier ON application_spatial_unit USING btree (rowidentifier);


--
-- Name: application_spatial_unit_spatial_unit_id_fk131_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_spatial_unit_spatial_unit_id_fk131_ind ON application_spatial_unit USING btree (spatial_unit_id);


--
-- Name: application_status_code_fk18_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_status_code_fk18_ind ON application USING btree (status_code);


--
-- Name: application_uses_source_application_id_fk126_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_uses_source_application_id_fk126_ind ON application_uses_source USING btree (application_id);


--
-- Name: application_uses_source_historic_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_uses_source_historic_index_on_rowidentifier ON application_uses_source_historic USING btree (rowidentifier);


--
-- Name: application_uses_source_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_uses_source_index_on_rowidentifier ON application_uses_source USING btree (rowidentifier);


--
-- Name: application_uses_source_source_id_fk127_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_uses_source_source_id_fk127_ind ON application_uses_source USING btree (source_id);


--
-- Name: request_type_config_panel_launcher_fkey_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX request_type_config_panel_launcher_fkey_ind ON request_type USING btree (service_panel_code);


--
-- Name: request_type_request_category_code_fk20_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX request_type_request_category_code_fk20_ind ON request_type USING btree (request_category_code);


--
-- Name: request_type_requires_source_type_request_type_code_fk129_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX request_type_requires_source_type_request_type_code_fk129_ind ON request_type_requires_source_type USING btree (request_type_code);


--
-- Name: request_type_requires_source_type_source_type_code_fk128_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX request_type_requires_source_type_source_type_code_fk128_ind ON request_type_requires_source_type USING btree (source_type_code);


--
-- Name: request_type_rrr_type_code_fk21_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX request_type_rrr_type_code_fk21_ind ON request_type USING btree (rrr_type_code);


--
-- Name: request_type_type_action_code_fk23_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX request_type_type_action_code_fk23_ind ON request_type USING btree (type_action_code);


--
-- Name: service_action_code_fk25_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_action_code_fk25_ind ON service USING btree (action_code);


--
-- Name: service_action_type_status_to_set_fk26_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_action_type_status_to_set_fk26_ind ON service_action_type USING btree (status_to_set);


--
-- Name: service_application_historic_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_application_historic_ind ON service_historic USING btree (application_id);


--
-- Name: service_application_id_fk7_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_application_id_fk7_ind ON service USING btree (application_id);


--
-- Name: service_historic_id_idx; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_historic_id_idx ON service_historic USING btree (id);


--
-- Name: service_historic_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_historic_index_on_rowidentifier ON service_historic USING btree (rowidentifier);


--
-- Name: service_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_index_on_rowidentifier ON service USING btree (rowidentifier);


--
-- Name: service_request_type_code_fk19_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_request_type_code_fk19_ind ON service USING btree (request_type_code);


--
-- Name: service_status_code_fk24_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_status_code_fk24_ind ON service USING btree (status_code);


SET search_path = bulk_operation, pg_catalog;

--
-- Name: spatial_unit_temporary_cadastre_object_type_code_fk133_ind; Type: INDEX; Schema: bulk_operation; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_temporary_cadastre_object_type_code_fk133_ind ON spatial_unit_temporary USING btree (cadastre_object_type_code);


--
-- Name: spatial_unit_temporary_index_on_geom; Type: INDEX; Schema: bulk_operation; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_temporary_index_on_geom ON spatial_unit_temporary USING gist (geom);


--
-- Name: spatial_unit_temporary_index_on_rowidentifier; Type: INDEX; Schema: bulk_operation; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_temporary_index_on_rowidentifier ON spatial_unit_temporary USING btree (rowidentifier);


--
-- Name: spatial_unit_temporary_transaction_id_fk132_ind; Type: INDEX; Schema: bulk_operation; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_temporary_transaction_id_fk132_ind ON spatial_unit_temporary USING btree (transaction_id);


SET search_path = cadastre, pg_catalog;

--
-- Name: cadastre_object_building_unit_type_code_fk64_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_building_unit_type_code_fk64_ind ON cadastre_object USING btree (building_unit_type_code);


--
-- Name: cadastre_object_historic_index_on_geom_polygon; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_historic_index_on_geom_polygon ON cadastre_object_historic USING gist (geom_polygon);


--
-- Name: cadastre_object_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_historic_index_on_rowidentifier ON cadastre_object_historic USING btree (rowidentifier);


--
-- Name: cadastre_object_id_fk61_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_id_fk61_ind ON cadastre_object USING btree (id);


--
-- Name: cadastre_object_index_on_geom_polygon; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_index_on_geom_polygon ON cadastre_object USING gist (geom_polygon);


--
-- Name: cadastre_object_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_index_on_rowidentifier ON cadastre_object USING btree (rowidentifier);


--
-- Name: cadastre_object_node_target_historic_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_node_target_historic_index_on_geom ON cadastre_object_node_target_historic USING gist (geom);


--
-- Name: cadastre_object_node_target_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_node_target_historic_index_on_rowidentifier ON cadastre_object_node_target_historic USING btree (rowidentifier);


--
-- Name: cadastre_object_node_target_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_node_target_index_on_geom ON cadastre_object_node_target USING gist (geom);


--
-- Name: cadastre_object_node_target_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_node_target_index_on_rowidentifier ON cadastre_object_node_target USING btree (rowidentifier);


--
-- Name: cadastre_object_node_target_transaction_id_fk102_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_node_target_transaction_id_fk102_ind ON cadastre_object_node_target USING btree (transaction_id);


--
-- Name: cadastre_object_status_code_fk63_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_status_code_fk63_ind ON cadastre_object USING btree (status_code);


--
-- Name: cadastre_object_target_cadastre_object_id_fk97_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_target_cadastre_object_id_fk97_ind ON cadastre_object_target USING btree (cadastre_object_id);


--
-- Name: cadastre_object_target_historic_index_on_geom_polygon; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_target_historic_index_on_geom_polygon ON cadastre_object_target_historic USING gist (geom_polygon);


--
-- Name: cadastre_object_target_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_target_historic_index_on_rowidentifier ON cadastre_object_target_historic USING btree (rowidentifier);


--
-- Name: cadastre_object_target_index_on_geom_polygon; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_target_index_on_geom_polygon ON cadastre_object_target USING gist (geom_polygon);


--
-- Name: cadastre_object_target_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_target_index_on_rowidentifier ON cadastre_object_target USING btree (rowidentifier);


--
-- Name: cadastre_object_target_transaction_id_fk98_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_target_transaction_id_fk98_ind ON cadastre_object_target USING btree (transaction_id);


--
-- Name: cadastre_object_transaction_id_fk65_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_transaction_id_fk65_ind ON cadastre_object USING btree (transaction_id);


--
-- Name: cadastre_object_type_code_fk62_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_type_code_fk62_ind ON cadastre_object USING btree (type_code);


--
-- Name: legal_space_utility_network_historic_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_historic_index_on_geom ON legal_space_utility_network_historic USING gist (geom);


--
-- Name: legal_space_utility_network_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_historic_index_on_rowidentifier ON legal_space_utility_network_historic USING btree (rowidentifier);


--
-- Name: legal_space_utility_network_id_fk94_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_id_fk94_ind ON legal_space_utility_network USING btree (id);


--
-- Name: legal_space_utility_network_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_index_on_geom ON legal_space_utility_network USING gist (geom);


--
-- Name: legal_space_utility_network_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_index_on_rowidentifier ON legal_space_utility_network USING btree (rowidentifier);


--
-- Name: legal_space_utility_network_status_code_fk95_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_status_code_fk95_ind ON legal_space_utility_network USING btree (status_code);


--
-- Name: legal_space_utility_network_type_code_fk96_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_type_code_fk96_ind ON legal_space_utility_network USING btree (type_code);


--
-- Name: level_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX level_historic_index_on_rowidentifier ON level_historic USING btree (rowidentifier);


--
-- Name: level_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX level_index_on_rowidentifier ON level USING btree (rowidentifier);


--
-- Name: level_register_type_code_fk58_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX level_register_type_code_fk58_ind ON level USING btree (register_type_code);


--
-- Name: level_structure_code_fk59_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX level_structure_code_fk59_ind ON level USING btree (structure_code);


--
-- Name: level_type_code_fk60_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX level_type_code_fk60_ind ON level USING btree (type_code);


--
-- Name: spatial_unit_address_address_id_fk90_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_address_address_id_fk90_ind ON spatial_unit_address USING btree (address_id);


--
-- Name: spatial_unit_address_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_address_historic_index_on_rowidentifier ON spatial_unit_address_historic USING btree (rowidentifier);


--
-- Name: spatial_unit_address_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_address_index_on_rowidentifier ON spatial_unit_address USING btree (rowidentifier);


--
-- Name: spatial_unit_address_spatial_unit_id_fk89_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_address_spatial_unit_id_fk89_ind ON spatial_unit_address USING btree (spatial_unit_id);


--
-- Name: spatial_unit_dimension_code_fk55_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_dimension_code_fk55_ind ON spatial_unit USING btree (dimension_code);


--
-- Name: spatial_unit_group_found_in_spatial_unit_group_id_fk91_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_found_in_spatial_unit_group_id_fk91_ind ON spatial_unit_group USING btree (found_in_spatial_unit_group_id);


--
-- Name: spatial_unit_group_historic_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_historic_index_on_geom ON spatial_unit_group_historic USING gist (geom);


--
-- Name: spatial_unit_group_historic_index_on_reference_point; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_historic_index_on_reference_point ON spatial_unit_group_historic USING gist (reference_point);


--
-- Name: spatial_unit_group_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_historic_index_on_rowidentifier ON spatial_unit_group_historic USING btree (rowidentifier);


--
-- Name: spatial_unit_group_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_index_on_geom ON spatial_unit_group USING gist (geom);


--
-- Name: spatial_unit_group_index_on_reference_point; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_index_on_reference_point ON spatial_unit_group USING gist (reference_point);


--
-- Name: spatial_unit_group_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_index_on_rowidentifier ON spatial_unit_group USING btree (rowidentifier);


--
-- Name: spatial_unit_historic_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_historic_index_on_geom ON spatial_unit_historic USING gist (geom);


--
-- Name: spatial_unit_historic_index_on_reference_point; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_historic_index_on_reference_point ON spatial_unit_historic USING gist (reference_point);


--
-- Name: spatial_unit_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_historic_index_on_rowidentifier ON spatial_unit_historic USING btree (rowidentifier);


--
-- Name: spatial_unit_in_group_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_in_group_historic_index_on_rowidentifier ON spatial_unit_in_group_historic USING btree (rowidentifier);


--
-- Name: spatial_unit_in_group_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_in_group_index_on_rowidentifier ON spatial_unit_in_group USING btree (rowidentifier);


--
-- Name: spatial_unit_in_group_spatial_unit_group_id_fk92_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_in_group_spatial_unit_group_id_fk92_ind ON spatial_unit_in_group USING btree (spatial_unit_group_id);


--
-- Name: spatial_unit_in_group_spatial_unit_id_fk93_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_in_group_spatial_unit_id_fk93_ind ON spatial_unit_in_group USING btree (spatial_unit_id);


--
-- Name: spatial_unit_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_index_on_geom ON spatial_unit USING gist (geom);


--
-- Name: spatial_unit_index_on_reference_point; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_index_on_reference_point ON spatial_unit USING gist (reference_point);


--
-- Name: spatial_unit_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_index_on_rowidentifier ON spatial_unit USING btree (rowidentifier);


--
-- Name: spatial_unit_land_use_code_fk66_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_land_use_code_fk66_ind ON spatial_unit USING btree (land_use_code);


--
-- Name: spatial_unit_level_id_fk57_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_level_id_fk57_ind ON spatial_unit USING btree (level_id);


--
-- Name: spatial_unit_surface_relation_code_fk56_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_surface_relation_code_fk56_ind ON spatial_unit USING btree (surface_relation_code);


--
-- Name: spatial_unit_transaction_id_fk67_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_transaction_id_fk67_ind ON spatial_unit USING btree (transaction_id);


--
-- Name: spatial_value_area_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_value_area_historic_index_on_rowidentifier ON spatial_value_area_historic USING btree (rowidentifier);


--
-- Name: spatial_value_area_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_value_area_index_on_rowidentifier ON spatial_value_area USING btree (rowidentifier);


--
-- Name: spatial_value_area_spatial_unit_id_fk87_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_value_area_spatial_unit_id_fk87_ind ON spatial_value_area USING btree (spatial_unit_id);


--
-- Name: spatial_value_area_type_code_fk88_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_value_area_type_code_fk88_ind ON spatial_value_area USING btree (type_code);


--
-- Name: survey_point_historic_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_historic_index_on_geom ON survey_point_historic USING gist (geom);


--
-- Name: survey_point_historic_index_on_original_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_historic_index_on_original_geom ON survey_point_historic USING gist (original_geom);


--
-- Name: survey_point_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_historic_index_on_rowidentifier ON survey_point_historic USING btree (rowidentifier);


--
-- Name: survey_point_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_index_on_geom ON survey_point USING gist (geom);


--
-- Name: survey_point_index_on_original_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_index_on_original_geom ON survey_point USING gist (original_geom);


--
-- Name: survey_point_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_index_on_rowidentifier ON survey_point USING btree (rowidentifier);


--
-- Name: survey_point_transaction_id_fk99_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_transaction_id_fk99_ind ON survey_point USING btree (transaction_id);


SET search_path = document, pg_catalog;

--
-- Name: document_historic_index_on_rowidentifier; Type: INDEX; Schema: document; Owner: postgres; Tablespace: 
--

CREATE INDEX document_historic_index_on_rowidentifier ON document_historic USING btree (rowidentifier);


--
-- Name: document_index_on_rowidentifier; Type: INDEX; Schema: document; Owner: postgres; Tablespace: 
--

CREATE INDEX document_index_on_rowidentifier ON document USING btree (rowidentifier);


SET search_path = opentenure, pg_catalog;

--
-- Name: unique_field_constraint_name_idx; Type: INDEX; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_field_constraint_name_idx ON field_constraint USING btree (name, field_template_id);


--
-- Name: unique_field_constraint_option_name_idx; Type: INDEX; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_field_constraint_option_name_idx ON field_constraint_option USING btree (name, field_constraint_id);


--
-- Name: unique_field_payload_name_idx; Type: INDEX; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_field_payload_name_idx ON field_payload USING btree (name, section_element_payload_id);


--
-- Name: unique_field_template_name_idx; Type: INDEX; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_field_template_name_idx ON field_template USING btree (name, section_template_id);


--
-- Name: unique_section_payload_name_idx; Type: INDEX; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_section_payload_name_idx ON section_payload USING btree (name, form_payload_id);


--
-- Name: unique_section_template_name_idx; Type: INDEX; Schema: opentenure; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_section_template_name_idx ON section_template USING btree (name, form_template_name);


SET search_path = party, pg_catalog;

--
-- Name: group_party_historic_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX group_party_historic_index_on_rowidentifier ON group_party_historic USING btree (rowidentifier);


--
-- Name: group_party_id_fk32_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX group_party_id_fk32_ind ON group_party USING btree (id);


--
-- Name: group_party_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX group_party_index_on_rowidentifier ON group_party USING btree (rowidentifier);


--
-- Name: group_party_type_code_fk33_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX group_party_type_code_fk33_ind ON group_party USING btree (type_code);


--
-- Name: party_address_id_fk10_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_address_id_fk10_ind ON party USING btree (address_id);


--
-- Name: party_gender_code_fk13_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_gender_code_fk13_ind ON party USING btree (gender_code);


--
-- Name: party_historic_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_historic_index_on_rowidentifier ON party_historic USING btree (rowidentifier);


--
-- Name: party_id_type_code_fk12_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_id_type_code_fk12_ind ON party USING btree (id_type_code);


--
-- Name: party_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_index_on_rowidentifier ON party USING btree (rowidentifier);


--
-- Name: party_member_group_id_fk35_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_member_group_id_fk35_ind ON party_member USING btree (group_id);


--
-- Name: party_member_historic_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_member_historic_index_on_rowidentifier ON party_member_historic USING btree (rowidentifier);


--
-- Name: party_member_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_member_index_on_rowidentifier ON party_member USING btree (rowidentifier);


--
-- Name: party_member_party_id_fk34_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_member_party_id_fk34_ind ON party_member USING btree (party_id);


--
-- Name: party_preferred_communication_code_fk11_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_preferred_communication_code_fk11_ind ON party USING btree (preferred_communication_code);


--
-- Name: party_role_historic_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_role_historic_index_on_rowidentifier ON party_role_historic USING btree (rowidentifier);


--
-- Name: party_role_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_role_index_on_rowidentifier ON party_role USING btree (rowidentifier);


--
-- Name: party_role_party_id_fk36_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_role_party_id_fk36_ind ON party_role USING btree (party_id);


--
-- Name: party_role_type_code_fk37_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_role_type_code_fk37_ind ON party_role USING btree (type_code);


--
-- Name: party_type_code_fk9_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_type_code_fk9_ind ON party USING btree (type_code);


--
-- Name: source_describes_party_historic_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_party_historic_index_on_rowidentifier ON source_describes_party_historic USING btree (rowidentifier);


--
-- Name: source_describes_party_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_party_index_on_rowidentifier ON source_describes_party USING btree (rowidentifier);


--
-- Name: source_describes_party_party_id_fk41_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_party_party_id_fk41_ind ON source_describes_party USING btree (party_id);


--
-- Name: source_describes_party_source_id_fk42_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_party_source_id_fk42_ind ON source_describes_party USING btree (source_id);


SET search_path = source, pg_catalog;

--
-- Name: archive_historic_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX archive_historic_index_on_rowidentifier ON archive_historic USING btree (rowidentifier);


--
-- Name: archive_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX archive_index_on_rowidentifier ON archive USING btree (rowidentifier);


--
-- Name: power_of_attorney_historic_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX power_of_attorney_historic_index_on_rowidentifier ON power_of_attorney_historic USING btree (rowidentifier);


--
-- Name: power_of_attorney_id_fk31_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX power_of_attorney_id_fk31_ind ON power_of_attorney USING btree (id);


--
-- Name: power_of_attorney_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX power_of_attorney_index_on_rowidentifier ON power_of_attorney USING btree (rowidentifier);


--
-- Name: source_archive_id_fk0_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_archive_id_fk0_ind ON source USING btree (archive_id);


--
-- Name: source_availability_status_code_fk2_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_availability_status_code_fk2_ind ON source USING btree (availability_status_code);


--
-- Name: source_historic_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_historic_index_on_rowidentifier ON source_historic USING btree (rowidentifier);


--
-- Name: source_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_index_on_rowidentifier ON source USING btree (rowidentifier);


--
-- Name: source_maintype_fk1_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_maintype_fk1_ind ON source USING btree (maintype);


--
-- Name: source_status_code_fk4_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_status_code_fk4_ind ON source USING btree (status_code);


--
-- Name: source_transaction_id_fk5_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_transaction_id_fk5_ind ON source USING btree (transaction_id);


--
-- Name: source_type_code_fk3_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_type_code_fk3_ind ON source USING btree (type_code);


--
-- Name: spatial_source_historic_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_historic_index_on_rowidentifier ON spatial_source_historic USING btree (rowidentifier);


--
-- Name: spatial_source_id_fk28_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_id_fk28_ind ON spatial_source USING btree (id);


--
-- Name: spatial_source_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_index_on_rowidentifier ON spatial_source USING btree (rowidentifier);


--
-- Name: spatial_source_measurement_historic_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_measurement_historic_index_on_rowidentifier ON spatial_source_measurement_historic USING btree (rowidentifier);


--
-- Name: spatial_source_measurement_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_measurement_index_on_rowidentifier ON spatial_source_measurement USING btree (rowidentifier);


--
-- Name: spatial_source_measurement_spatial_source_id_fk30_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_measurement_spatial_source_id_fk30_ind ON spatial_source_measurement USING btree (spatial_source_id);


--
-- Name: spatial_source_type_code_fk29_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_type_code_fk29_ind ON spatial_source USING btree (type_code);


SET search_path = system, pg_catalog;

--
-- Name: approle_appgroup_appgroup_id_fk118_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX approle_appgroup_appgroup_id_fk118_ind ON approle_appgroup USING btree (appgroup_id);


--
-- Name: approle_appgroup_approle_code_fk117_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX approle_appgroup_approle_code_fk117_ind ON approle_appgroup USING btree (approle_code);


--
-- Name: approle_appgroup_historic_index_on_rowidentifier; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX approle_appgroup_historic_index_on_rowidentifier ON approle_appgroup_historic USING btree (rowidentifier);


--
-- Name: appuser_appgroup_appgroup_id_fk120_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX appuser_appgroup_appgroup_id_fk120_ind ON appuser_appgroup USING btree (appgroup_id);


--
-- Name: appuser_appgroup_appuser_id_fk119_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX appuser_appgroup_appuser_id_fk119_ind ON appuser_appgroup USING btree (appuser_id);


--
-- Name: appuser_appgroup_historic_index_on_rowidentifier; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX appuser_appgroup_historic_index_on_rowidentifier ON appuser_appgroup_historic USING btree (rowidentifier);


--
-- Name: appuser_historic_index_on_rowidentifier; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX appuser_historic_index_on_rowidentifier ON appuser_historic USING btree (rowidentifier);


--
-- Name: appuser_index_on_rowidentifier; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX appuser_index_on_rowidentifier ON appuser USING btree (rowidentifier);


--
-- Name: appuser_setting_user_id_fk103_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX appuser_setting_user_id_fk103_ind ON appuser_setting USING btree (user_id);


--
-- Name: br_definition_br_id_fk116_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_definition_br_id_fk116_ind ON br_definition USING btree (br_id);


--
-- Name: br_technical_type_code_fk107_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_technical_type_code_fk107_ind ON br USING btree (technical_type_code);


--
-- Name: br_validation_br_id_fk108_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_br_id_fk108_ind ON br_validation USING btree (br_id);


--
-- Name: br_validation_severity_code_fk109_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_severity_code_fk109_ind ON br_validation USING btree (severity_code);


--
-- Name: br_validation_target_application_moment_fk113_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_target_application_moment_fk113_ind ON br_validation USING btree (target_application_moment);


--
-- Name: br_validation_target_code_fk110_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_target_code_fk110_ind ON br_validation USING btree (target_code);


--
-- Name: br_validation_target_reg_moment_fk115_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_target_reg_moment_fk115_ind ON br_validation USING btree (target_reg_moment);


--
-- Name: br_validation_target_request_type_code_fk111_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_target_request_type_code_fk111_ind ON br_validation USING btree (target_request_type_code);


--
-- Name: br_validation_target_rrr_type_code_fk112_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_target_rrr_type_code_fk112_ind ON br_validation USING btree (target_rrr_type_code);


--
-- Name: br_validation_target_service_moment_fk114_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_target_service_moment_fk114_ind ON br_validation USING btree (target_service_moment);


--
-- Name: config_map_layer_metadata_name_fk_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX config_map_layer_metadata_name_fk_ind ON config_map_layer_metadata USING btree (name);


--
-- Name: config_map_layer_pojo_query_name_fk105_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX config_map_layer_pojo_query_name_fk105_ind ON config_map_layer USING btree (pojo_query_name);


--
-- Name: config_map_layer_pojo_query_name_for_select_fk106_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX config_map_layer_pojo_query_name_for_select_fk106_ind ON config_map_layer USING btree (pojo_query_name_for_select);


--
-- Name: config_map_layer_type_code_fk104_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX config_map_layer_type_code_fk104_ind ON config_map_layer USING btree (type_code);


--
-- Name: config_panel_launcher_launch_group_fkey_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX config_panel_launcher_launch_group_fkey_ind ON config_panel_launcher USING btree (launch_group);


--
-- Name: map_search_option_query_name_fk122_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX map_search_option_query_name_fk122_ind ON map_search_option USING btree (query_name);


--
-- Name: query_field_query_name_fk121_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX query_field_query_name_fk121_ind ON query_field USING btree (query_name);


SET search_path = transaction, pg_catalog;

--
-- Name: transaction_from_service_id_fk6_ind; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_from_service_id_fk6_ind ON transaction USING btree (from_service_id);


--
-- Name: transaction_historic_index_on_rowidentifier; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_historic_index_on_rowidentifier ON transaction_historic USING btree (rowidentifier);


--
-- Name: transaction_index_on_rowidentifier; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_index_on_rowidentifier ON transaction USING btree (rowidentifier);


--
-- Name: transaction_source_historic_index_on_rowidentifier; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_source_historic_index_on_rowidentifier ON transaction_source_historic USING btree (rowidentifier);


--
-- Name: transaction_source_index_on_rowidentifier; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_source_index_on_rowidentifier ON transaction_source USING btree (rowidentifier);


--
-- Name: transaction_source_source_id_fk101_ind; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_source_source_id_fk101_ind ON transaction_source USING btree (source_id);


--
-- Name: transaction_source_transaction_id_fk100_ind; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_source_transaction_id_fk100_ind ON transaction_source USING btree (transaction_id);


--
-- Name: transaction_status_code_fk27_ind; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_status_code_fk27_ind ON transaction USING btree (status_code);


SET search_path = address, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: address; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON address FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: address; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON address FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


SET search_path = administrative, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON notifiable_party_for_baunit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON ba_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON ba_unit_area FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON ba_unit_contains_spatial_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON ba_unit_target FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON condition_for_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON mortgage_isbased_in_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON notation FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party_for_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON required_relationship_baunit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON rrr_share FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON source_describes_ba_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON source_describes_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON notifiable_party_for_baunit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON ba_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON ba_unit_area FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON ba_unit_contains_spatial_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON ba_unit_target FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON condition_for_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON mortgage_isbased_in_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON notation FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party_for_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON required_relationship_baunit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON rrr_share FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON source_describes_ba_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON source_describes_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: trg_change_from_pending; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER trg_change_from_pending BEFORE UPDATE ON rrr FOR EACH ROW EXECUTE PROCEDURE f_for_tbl_rrr_trg_change_from_pending();


SET search_path = application, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON application FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON application_property FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON application_spatial_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON application_uses_source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON service FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON application FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON application_property FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON application_spatial_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON application_uses_source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON service FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


SET search_path = bulk_operation, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: bulk_operation; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_unit_temporary FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


SET search_path = cadastre, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON cadastre_object FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON cadastre_object_node_target FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON cadastre_object_target FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON legal_space_utility_network FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON level FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_unit_address FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_unit_group FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_unit_in_group FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_value_area FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON survey_point FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON cadastre_object FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON cadastre_object_node_target FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON cadastre_object_target FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON legal_space_utility_network FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON level FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_unit_address FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_unit_group FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_unit_in_group FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_value_area FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON survey_point FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: trg_geommodify; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER trg_geommodify AFTER INSERT OR UPDATE OF geom_polygon ON cadastre_object FOR EACH ROW EXECUTE PROCEDURE f_for_tbl_cadastre_object_trg_geommodify();


--
-- Name: trg_new; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER trg_new BEFORE INSERT ON cadastre_object FOR EACH ROW EXECUTE PROCEDURE f_for_tbl_cadastre_object_trg_new();


--
-- Name: trg_remove; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER trg_remove AFTER DELETE ON cadastre_object FOR EACH ROW EXECUTE PROCEDURE f_for_tbl_cadastre_object_trg_remove();


SET search_path = document, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: document; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON document FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: document; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON document FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


SET search_path = opentenure, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON claim FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON attachment FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON claim_uses_attachment FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON claim_share FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party_for_claim_share FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON claim_location FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON claim_comment FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON form_template FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON section_template FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON form_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON section_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON field_template FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON field_constraint FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON field_constraint_option FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON section_element_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON field_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON claim FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON attachment FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON claim_uses_attachment FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON claim_share FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party_for_claim_share FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON claim_location FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON claim_comment FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON form_template FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON section_template FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON form_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON section_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON field_template FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON field_constraint FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON field_constraint_option FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON section_element_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON field_payload FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: set_default; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER set_default AFTER INSERT OR DELETE OR UPDATE ON form_template FOR EACH ROW EXECUTE PROCEDURE f_for_trg_set_default();


SET search_path = party, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON source_describes_party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON group_party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party_member FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party_role FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON source_describes_party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON group_party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party_member FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party_role FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


SET search_path = source, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON archive FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON power_of_attorney FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_source_measurement FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON archive FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON power_of_attorney FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_source_measurement FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: trg_change_of_status; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER trg_change_of_status BEFORE UPDATE ON source FOR EACH ROW EXECUTE PROCEDURE f_for_tbl_source_trg_change_of_status();


SET search_path = system, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: system; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON appuser FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: system; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON approle_appgroup FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: system; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON appuser_appgroup FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: system; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON appuser FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: system; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON approle_appgroup FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: system; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON appuser_appgroup FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


SET search_path = transaction, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: transaction; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON transaction FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: transaction; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON transaction_source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: transaction; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON transaction FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: transaction; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON transaction_source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


SET search_path = administrative, pg_catalog;

--
-- Name: ba_unit_area_ba_unit_id_fk77; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_area
    ADD CONSTRAINT ba_unit_area_ba_unit_id_fk77 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_area_type_code_fk78; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_area
    ADD CONSTRAINT ba_unit_area_type_code_fk78 FOREIGN KEY (type_code) REFERENCES cadastre.area_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ba_unit_as_party_ba_unit_id_fk71; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_as_party
    ADD CONSTRAINT ba_unit_as_party_ba_unit_id_fk71 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_as_party_party_id_fk72; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_as_party
    ADD CONSTRAINT ba_unit_as_party_party_id_fk72 FOREIGN KEY (party_id) REFERENCES party.party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_contains_spatial_unit_ba_unit_id_fk68; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_contains_spatial_unit
    ADD CONSTRAINT ba_unit_contains_spatial_unit_ba_unit_id_fk68 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_contains_spatial_unit_spatial_unit_id_fk69; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_contains_spatial_unit
    ADD CONSTRAINT ba_unit_contains_spatial_unit_spatial_unit_id_fk69 FOREIGN KEY (spatial_unit_id) REFERENCES cadastre.spatial_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_contains_spatial_unit_spatial_unit_id_fk70; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_contains_spatial_unit
    ADD CONSTRAINT ba_unit_contains_spatial_unit_spatial_unit_id_fk70 FOREIGN KEY (spatial_unit_id) REFERENCES cadastre.cadastre_object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_status_code_fk39; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit
    ADD CONSTRAINT ba_unit_status_code_fk39 FOREIGN KEY (status_code) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ba_unit_target_ba_unit_id_fk83; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_target
    ADD CONSTRAINT ba_unit_target_ba_unit_id_fk83 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_target_transaction_id_fk84; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_target
    ADD CONSTRAINT ba_unit_target_transaction_id_fk84 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_transaction_id_fk40; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit
    ADD CONSTRAINT ba_unit_transaction_id_fk40 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_type_code_fk38; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit
    ADD CONSTRAINT ba_unit_type_code_fk38 FOREIGN KEY (type_code) REFERENCES ba_unit_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: condition_for_rrr_condition_code_fk85; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY condition_for_rrr
    ADD CONSTRAINT condition_for_rrr_condition_code_fk85 FOREIGN KEY (condition_code) REFERENCES condition_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: condition_for_rrr_rrr_id_fk86; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY condition_for_rrr
    ADD CONSTRAINT condition_for_rrr_rrr_id_fk86 FOREIGN KEY (rrr_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mortgage_isbased_in_rrr_mortgage_id_fk47; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY mortgage_isbased_in_rrr
    ADD CONSTRAINT mortgage_isbased_in_rrr_mortgage_id_fk47 FOREIGN KEY (mortgage_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mortgage_isbased_in_rrr_rrr_id_fk46; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY mortgage_isbased_in_rrr
    ADD CONSTRAINT mortgage_isbased_in_rrr_rrr_id_fk46 FOREIGN KEY (rrr_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notation_ba_unit_id_fk75; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY notation
    ADD CONSTRAINT notation_ba_unit_id_fk75 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notation_rrr_id_fk76; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY notation
    ADD CONSTRAINT notation_rrr_id_fk76 FOREIGN KEY (rrr_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notation_status_code_fk74; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY notation
    ADD CONSTRAINT notation_status_code_fk74 FOREIGN KEY (status_code) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: notation_transaction_id_fk73; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY notation
    ADD CONSTRAINT notation_transaction_id_fk73 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_for_rrr_party_id_fk82; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY party_for_rrr
    ADD CONSTRAINT party_for_rrr_party_id_fk82 FOREIGN KEY (party_id) REFERENCES party.party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_for_rrr_rrr_id_fk80; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY party_for_rrr
    ADD CONSTRAINT party_for_rrr_rrr_id_fk80 FOREIGN KEY (rrr_id, share_id) REFERENCES rrr_share(rrr_id, id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_for_rrr_rrr_id_fk81; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY party_for_rrr
    ADD CONSTRAINT party_for_rrr_rrr_id_fk81 FOREIGN KEY (rrr_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: required_relationship_baunit_from_ba_unit_id_fk52; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY required_relationship_baunit
    ADD CONSTRAINT required_relationship_baunit_from_ba_unit_id_fk52 FOREIGN KEY (from_ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: required_relationship_baunit_relation_code_fk54; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY required_relationship_baunit
    ADD CONSTRAINT required_relationship_baunit_relation_code_fk54 FOREIGN KEY (relation_code) REFERENCES ba_unit_rel_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: required_relationship_baunit_to_ba_unit_id_fk53; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY required_relationship_baunit
    ADD CONSTRAINT required_relationship_baunit_to_ba_unit_id_fk53 FOREIGN KEY (to_ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rrr_ba_unit_id_fk42; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr
    ADD CONSTRAINT rrr_ba_unit_id_fk42 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rrr_mortgage_type_code_fk45; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr
    ADD CONSTRAINT rrr_mortgage_type_code_fk45 FOREIGN KEY (mortgage_type_code) REFERENCES mortgage_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rrr_share_rrr_id_fk79; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr_share
    ADD CONSTRAINT rrr_share_rrr_id_fk79 FOREIGN KEY (rrr_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rrr_status_code_fk43; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr
    ADD CONSTRAINT rrr_status_code_fk43 FOREIGN KEY (status_code) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rrr_transaction_id_fk44; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr
    ADD CONSTRAINT rrr_transaction_id_fk44 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rrr_type_code_fk41; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr
    ADD CONSTRAINT rrr_type_code_fk41 FOREIGN KEY (type_code) REFERENCES rrr_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rrr_type_config_panel_launcher_fkey; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr_type
    ADD CONSTRAINT rrr_type_config_panel_launcher_fkey FOREIGN KEY (rrr_panel_code) REFERENCES system.config_panel_launcher(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rrr_type_rrr_group_type_code_fk22; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr_type
    ADD CONSTRAINT rrr_type_rrr_group_type_code_fk22 FOREIGN KEY (rrr_group_type_code) REFERENCES rrr_group_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: source_describes_ba_unit_ba_unit_id_fk50; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY source_describes_ba_unit
    ADD CONSTRAINT source_describes_ba_unit_ba_unit_id_fk50 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: source_describes_ba_unit_source_id_fk51; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY source_describes_ba_unit
    ADD CONSTRAINT source_describes_ba_unit_source_id_fk51 FOREIGN KEY (source_id) REFERENCES source.source(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: source_describes_rrr_rrr_id_fk48; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY source_describes_rrr
    ADD CONSTRAINT source_describes_rrr_rrr_id_fk48 FOREIGN KEY (rrr_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: source_describes_rrr_source_id_fk49; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY source_describes_rrr
    ADD CONSTRAINT source_describes_rrr_source_id_fk49 FOREIGN KEY (source_id) REFERENCES source.source(id) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = application, pg_catalog;

--
-- Name: application_action_code_fk16; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application
    ADD CONSTRAINT application_action_code_fk16 FOREIGN KEY (action_code) REFERENCES application_action_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_action_type_status_to_set_fk17; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_action_type
    ADD CONSTRAINT application_action_type_status_to_set_fk17 FOREIGN KEY (status_to_set) REFERENCES application_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_agent_id_fk8; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application
    ADD CONSTRAINT application_agent_id_fk8 FOREIGN KEY (agent_id) REFERENCES party.party(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_assignee_id_fk15; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application
    ADD CONSTRAINT application_assignee_id_fk15 FOREIGN KEY (assignee_id) REFERENCES system.appuser(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_contact_person_id_fk14; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application
    ADD CONSTRAINT application_contact_person_id_fk14 FOREIGN KEY (contact_person_id) REFERENCES party.party(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_property_application_id_fk123; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_property
    ADD CONSTRAINT application_property_application_id_fk123 FOREIGN KEY (application_id) REFERENCES application(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_property_ba_unit_id_fk124; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_property
    ADD CONSTRAINT application_property_ba_unit_id_fk124 FOREIGN KEY (ba_unit_id) REFERENCES administrative.ba_unit(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_property_land_use_code_fk125; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_property
    ADD CONSTRAINT application_property_land_use_code_fk125 FOREIGN KEY (land_use_code) REFERENCES cadastre.land_use_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_spatial_unit_application_id_fk130; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_spatial_unit
    ADD CONSTRAINT application_spatial_unit_application_id_fk130 FOREIGN KEY (application_id) REFERENCES application(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_spatial_unit_spatial_unit_id_fk131; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_spatial_unit
    ADD CONSTRAINT application_spatial_unit_spatial_unit_id_fk131 FOREIGN KEY (spatial_unit_id) REFERENCES cadastre.cadastre_object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_status_code_fk18; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application
    ADD CONSTRAINT application_status_code_fk18 FOREIGN KEY (status_code) REFERENCES application_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_uses_source_application_id_fk126; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_uses_source
    ADD CONSTRAINT application_uses_source_application_id_fk126 FOREIGN KEY (application_id) REFERENCES application(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_uses_source_source_id_fk127; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_uses_source
    ADD CONSTRAINT application_uses_source_source_id_fk127 FOREIGN KEY (source_id) REFERENCES source.source(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: request_type_config_panel_launcher_fkey; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY request_type
    ADD CONSTRAINT request_type_config_panel_launcher_fkey FOREIGN KEY (service_panel_code) REFERENCES system.config_panel_launcher(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: request_type_request_category_code_fk20; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY request_type
    ADD CONSTRAINT request_type_request_category_code_fk20 FOREIGN KEY (request_category_code) REFERENCES request_category_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: request_type_requires_source_type_request_type_code_fk129; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY request_type_requires_source_type
    ADD CONSTRAINT request_type_requires_source_type_request_type_code_fk129 FOREIGN KEY (request_type_code) REFERENCES request_type(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: request_type_requires_source_type_source_type_code_fk128; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY request_type_requires_source_type
    ADD CONSTRAINT request_type_requires_source_type_source_type_code_fk128 FOREIGN KEY (source_type_code) REFERENCES source.administrative_source_type(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: request_type_rrr_type_code_fk21; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY request_type
    ADD CONSTRAINT request_type_rrr_type_code_fk21 FOREIGN KEY (rrr_type_code) REFERENCES administrative.rrr_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: request_type_type_action_code_fk23; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY request_type
    ADD CONSTRAINT request_type_type_action_code_fk23 FOREIGN KEY (type_action_code) REFERENCES type_action(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: service_action_code_fk25; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_action_code_fk25 FOREIGN KEY (action_code) REFERENCES service_action_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: service_action_type_status_to_set_fk26; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY service_action_type
    ADD CONSTRAINT service_action_type_status_to_set_fk26 FOREIGN KEY (status_to_set) REFERENCES service_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: service_application_id_fk7; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_application_id_fk7 FOREIGN KEY (application_id) REFERENCES application(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: service_request_type_code_fk19; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_request_type_code_fk19 FOREIGN KEY (request_type_code) REFERENCES request_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: service_status_code_fk24; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_status_code_fk24 FOREIGN KEY (status_code) REFERENCES service_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


SET search_path = bulk_operation, pg_catalog;

--
-- Name: spatial_unit_temporary_cadastre_object_type_code_fk133; Type: FK CONSTRAINT; Schema: bulk_operation; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_temporary
    ADD CONSTRAINT spatial_unit_temporary_cadastre_object_type_code_fk133 FOREIGN KEY (cadastre_object_type_code) REFERENCES cadastre.cadastre_object_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_unit_temporary_transaction_id_fk132; Type: FK CONSTRAINT; Schema: bulk_operation; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_temporary
    ADD CONSTRAINT spatial_unit_temporary_transaction_id_fk132 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = cadastre, pg_catalog;

--
-- Name: cadastre_object_building_unit_type_code_fk64; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_building_unit_type_code_fk64 FOREIGN KEY (building_unit_type_code) REFERENCES building_unit_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cadastre_object_id_fk61; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_id_fk61 FOREIGN KEY (id) REFERENCES spatial_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cadastre_object_node_target_transaction_id_fk102; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object_node_target
    ADD CONSTRAINT cadastre_object_node_target_transaction_id_fk102 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cadastre_object_status_code_fk63; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_status_code_fk63 FOREIGN KEY (status_code) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cadastre_object_target_cadastre_object_id_fk97; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object_target
    ADD CONSTRAINT cadastre_object_target_cadastre_object_id_fk97 FOREIGN KEY (cadastre_object_id) REFERENCES cadastre_object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cadastre_object_target_transaction_id_fk98; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object_target
    ADD CONSTRAINT cadastre_object_target_transaction_id_fk98 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cadastre_object_transaction_id_fk65; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_transaction_id_fk65 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cadastre_object_type_code_fk62; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_type_code_fk62 FOREIGN KEY (type_code) REFERENCES cadastre_object_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: legal_space_utility_network_id_fk94; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY legal_space_utility_network
    ADD CONSTRAINT legal_space_utility_network_id_fk94 FOREIGN KEY (id) REFERENCES cadastre_object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: legal_space_utility_network_status_code_fk95; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY legal_space_utility_network
    ADD CONSTRAINT legal_space_utility_network_status_code_fk95 FOREIGN KEY (status_code) REFERENCES utility_network_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: legal_space_utility_network_type_code_fk96; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY legal_space_utility_network
    ADD CONSTRAINT legal_space_utility_network_type_code_fk96 FOREIGN KEY (type_code) REFERENCES utility_network_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: level_config_map_layer_level_id_fk; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY level_config_map_layer
    ADD CONSTRAINT level_config_map_layer_level_id_fk FOREIGN KEY (level_id) REFERENCES level(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: level_config_map_layer_name_fk; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY level_config_map_layer
    ADD CONSTRAINT level_config_map_layer_name_fk FOREIGN KEY (config_map_layer_name) REFERENCES system.config_map_layer(name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: level_register_type_code_fk58; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY level
    ADD CONSTRAINT level_register_type_code_fk58 FOREIGN KEY (register_type_code) REFERENCES register_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: level_structure_code_fk59; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY level
    ADD CONSTRAINT level_structure_code_fk59 FOREIGN KEY (structure_code) REFERENCES structure_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: level_type_code_fk60; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY level
    ADD CONSTRAINT level_type_code_fk60 FOREIGN KEY (type_code) REFERENCES level_content_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_unit_address_address_id_fk90; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_address
    ADD CONSTRAINT spatial_unit_address_address_id_fk90 FOREIGN KEY (address_id) REFERENCES address.address(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_unit_address_spatial_unit_id_fk89; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_address
    ADD CONSTRAINT spatial_unit_address_spatial_unit_id_fk89 FOREIGN KEY (spatial_unit_id) REFERENCES spatial_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_unit_dimension_code_fk55; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit
    ADD CONSTRAINT spatial_unit_dimension_code_fk55 FOREIGN KEY (dimension_code) REFERENCES dimension_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_unit_group_found_in_spatial_unit_group_id_fk91; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_group
    ADD CONSTRAINT spatial_unit_group_found_in_spatial_unit_group_id_fk91 FOREIGN KEY (found_in_spatial_unit_group_id) REFERENCES spatial_unit_group(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_unit_in_group_spatial_unit_group_id_fk92; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_in_group
    ADD CONSTRAINT spatial_unit_in_group_spatial_unit_group_id_fk92 FOREIGN KEY (spatial_unit_group_id) REFERENCES spatial_unit_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_unit_in_group_spatial_unit_id_fk93; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_in_group
    ADD CONSTRAINT spatial_unit_in_group_spatial_unit_id_fk93 FOREIGN KEY (spatial_unit_id) REFERENCES spatial_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_unit_land_use_code_fk66; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit
    ADD CONSTRAINT spatial_unit_land_use_code_fk66 FOREIGN KEY (land_use_code) REFERENCES land_use_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_unit_level_id_fk57; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit
    ADD CONSTRAINT spatial_unit_level_id_fk57 FOREIGN KEY (level_id) REFERENCES level(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_unit_surface_relation_code_fk56; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit
    ADD CONSTRAINT spatial_unit_surface_relation_code_fk56 FOREIGN KEY (surface_relation_code) REFERENCES surface_relation_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_unit_transaction_id_fk67; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit
    ADD CONSTRAINT spatial_unit_transaction_id_fk67 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_value_area_spatial_unit_id_fk87; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_value_area
    ADD CONSTRAINT spatial_value_area_spatial_unit_id_fk87 FOREIGN KEY (spatial_unit_id) REFERENCES spatial_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_value_area_type_code_fk88; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_value_area
    ADD CONSTRAINT spatial_value_area_type_code_fk88 FOREIGN KEY (type_code) REFERENCES area_type(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_point_transaction_id_fk99; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY survey_point
    ADD CONSTRAINT survey_point_transaction_id_fk99 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = opentenure, pg_catalog;

--
-- Name: claim_claimant_id_fk8; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT claim_claimant_id_fk8 FOREIGN KEY (claimant_id) REFERENCES party(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: claim_comment_claim_id_fk8; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim_comment
    ADD CONSTRAINT claim_comment_claim_id_fk8 FOREIGN KEY (claim_id) REFERENCES claim(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: claim_fk_type_code; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT claim_fk_type_code FOREIGN KEY (type_code) REFERENCES administrative.rrr_type(code);


--
-- Name: claim_location_claim_id_fk8; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim_location
    ADD CONSTRAINT claim_location_claim_id_fk8 FOREIGN KEY (claim_id) REFERENCES claim(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: claim_share_claim_id_fk12; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim_share
    ADD CONSTRAINT claim_share_claim_id_fk12 FOREIGN KEY (claim_id) REFERENCES claim(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: claim_status_code_fk18; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT claim_status_code_fk18 FOREIGN KEY (status_code) REFERENCES claim_status(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: claim_uses_attachment_claim_id_fk126; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim_uses_attachment
    ADD CONSTRAINT claim_uses_attachment_claim_id_fk126 FOREIGN KEY (claim_id) REFERENCES claim(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: field_constraint_field_constraint_type_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_constraint
    ADD CONSTRAINT field_constraint_field_constraint_type_fkey FOREIGN KEY (field_constraint_type) REFERENCES field_constraint_type(code) ON DELETE CASCADE;


--
-- Name: field_constraint_field_template_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_constraint
    ADD CONSTRAINT field_constraint_field_template_id_fkey FOREIGN KEY (field_template_id) REFERENCES field_template(id) ON DELETE CASCADE;


--
-- Name: field_constraint_option_field_constraint_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_constraint_option
    ADD CONSTRAINT field_constraint_option_field_constraint_id_fkey FOREIGN KEY (field_constraint_id) REFERENCES field_constraint(id) ON DELETE CASCADE;


--
-- Name: field_payload_field_type_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_payload
    ADD CONSTRAINT field_payload_field_type_fkey FOREIGN KEY (field_type) REFERENCES field_type(code) ON DELETE CASCADE;


--
-- Name: field_payload_field_value_type_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_payload
    ADD CONSTRAINT field_payload_field_value_type_fkey FOREIGN KEY (field_value_type) REFERENCES field_value_type(code) ON DELETE CASCADE;


--
-- Name: field_payload_section_element_payload_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_payload
    ADD CONSTRAINT field_payload_section_element_payload_id_fkey FOREIGN KEY (section_element_payload_id) REFERENCES section_element_payload(id) ON DELETE CASCADE;


--
-- Name: field_template_field_type_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_template
    ADD CONSTRAINT field_template_field_type_fkey FOREIGN KEY (field_type) REFERENCES field_type(code) ON DELETE CASCADE;


--
-- Name: field_template_section_template_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY field_template
    ADD CONSTRAINT field_template_section_template_id_fkey FOREIGN KEY (section_template_id) REFERENCES section_template(id) ON DELETE CASCADE;


--
-- Name: fk_challenged_claim; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT fk_challenged_claim FOREIGN KEY (challenged_claim_id) REFERENCES claim(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_claim_land_use_type; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT fk_claim_land_use_type FOREIGN KEY (land_use_code) REFERENCES cadastre.land_use_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_claim_rejection_reason_code; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    ADD CONSTRAINT fk_claim_rejection_reason_code FOREIGN KEY (rejection_reason_code) REFERENCES rejection_reason(code);


--
-- Name: fk_document_type_code; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY attachment
    ADD CONSTRAINT fk_document_type_code FOREIGN KEY (type_code) REFERENCES source.administrative_source_type(code);


--
-- Name: form_payload_claim_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY form_payload
    ADD CONSTRAINT form_payload_claim_id_fkey FOREIGN KEY (claim_id) REFERENCES claim(id) ON DELETE CASCADE;


--
-- Name: form_payload_form_template_name_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY form_payload
    ADD CONSTRAINT form_payload_form_template_name_fkey FOREIGN KEY (form_template_name) REFERENCES form_template(name) ON DELETE CASCADE;


--
-- Name: party_for_claim_share_claim_id_fk43; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY party_for_claim_share
    ADD CONSTRAINT party_for_claim_share_claim_id_fk43 FOREIGN KEY (claim_share_id) REFERENCES claim_share(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_for_claim_share_party_id_fk23; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY party_for_claim_share
    ADD CONSTRAINT party_for_claim_share_party_id_fk23 FOREIGN KEY (party_id) REFERENCES party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: section_element_payload_section_payload_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY section_element_payload
    ADD CONSTRAINT section_element_payload_section_payload_id_fkey FOREIGN KEY (section_payload_id) REFERENCES section_payload(id) ON DELETE CASCADE;


--
-- Name: section_payload_form_payload_id_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY section_payload
    ADD CONSTRAINT section_payload_form_payload_id_fkey FOREIGN KEY (form_payload_id) REFERENCES form_payload(id) ON DELETE CASCADE;


--
-- Name: section_template_form_template_name_fkey; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY section_template
    ADD CONSTRAINT section_template_form_template_name_fkey FOREIGN KEY (form_template_name) REFERENCES form_template(name) ON DELETE CASCADE;


SET search_path = party, pg_catalog;

--
-- Name: group_party_id_fk32; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY group_party
    ADD CONSTRAINT group_party_id_fk32 FOREIGN KEY (id) REFERENCES party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_party_type_code_fk33; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY group_party
    ADD CONSTRAINT group_party_type_code_fk33 FOREIGN KEY (type_code) REFERENCES group_party_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: party_address_id_fk10; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_address_id_fk10 FOREIGN KEY (address_id) REFERENCES address.address(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: party_gender_code_fk13; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_gender_code_fk13 FOREIGN KEY (gender_code) REFERENCES gender_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: party_id_type_code_fk12; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_id_type_code_fk12 FOREIGN KEY (id_type_code) REFERENCES id_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: party_member_group_id_fk35; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party_member
    ADD CONSTRAINT party_member_group_id_fk35 FOREIGN KEY (group_id) REFERENCES group_party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_member_party_id_fk34; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party_member
    ADD CONSTRAINT party_member_party_id_fk34 FOREIGN KEY (party_id) REFERENCES party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_preferred_communication_code_fk11; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_preferred_communication_code_fk11 FOREIGN KEY (preferred_communication_code) REFERENCES communication_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: party_role_party_id_fk36; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party_role
    ADD CONSTRAINT party_role_party_id_fk36 FOREIGN KEY (party_id) REFERENCES party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_role_type_code_fk37; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party_role
    ADD CONSTRAINT party_role_type_code_fk37 FOREIGN KEY (type_code) REFERENCES party_role_type(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_type_code_fk9; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_type_code_fk9 FOREIGN KEY (type_code) REFERENCES party_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: source_describes_party_party_id_fk41; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY source_describes_party
    ADD CONSTRAINT source_describes_party_party_id_fk41 FOREIGN KEY (party_id) REFERENCES party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: source_describes_party_source_id_fk42; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY source_describes_party
    ADD CONSTRAINT source_describes_party_source_id_fk42 FOREIGN KEY (source_id) REFERENCES source.source(id) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = source, pg_catalog;

--
-- Name: power_of_attorney_id_fk31; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY power_of_attorney
    ADD CONSTRAINT power_of_attorney_id_fk31 FOREIGN KEY (id) REFERENCES source(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: source_archive_id_fk0; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_archive_id_fk0 FOREIGN KEY (archive_id) REFERENCES archive(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: source_availability_status_code_fk2; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_availability_status_code_fk2 FOREIGN KEY (availability_status_code) REFERENCES availability_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: source_maintype_fk1; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_maintype_fk1 FOREIGN KEY (maintype) REFERENCES presentation_form_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: source_status_code_fk4; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_status_code_fk4 FOREIGN KEY (status_code) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: source_transaction_id_fk5; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_transaction_id_fk5 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: source_type_code_fk3; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_type_code_fk3 FOREIGN KEY (type_code) REFERENCES administrative_source_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_source_id_fk28; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY spatial_source
    ADD CONSTRAINT spatial_source_id_fk28 FOREIGN KEY (id) REFERENCES source(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_source_measurement_spatial_source_id_fk30; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY spatial_source_measurement
    ADD CONSTRAINT spatial_source_measurement_spatial_source_id_fk30 FOREIGN KEY (spatial_source_id) REFERENCES spatial_source(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_source_type_code_fk29; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY spatial_source
    ADD CONSTRAINT spatial_source_type_code_fk29 FOREIGN KEY (type_code) REFERENCES spatial_source_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


SET search_path = system, pg_catalog;

--
-- Name: approle_appgroup_appgroup_id_fk118; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY approle_appgroup
    ADD CONSTRAINT approle_appgroup_appgroup_id_fk118 FOREIGN KEY (appgroup_id) REFERENCES appgroup(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: approle_appgroup_approle_code_fk117; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY approle_appgroup
    ADD CONSTRAINT approle_appgroup_approle_code_fk117 FOREIGN KEY (approle_code) REFERENCES approle(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: appuser_appgroup_appgroup_id_fk120; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY appuser_appgroup
    ADD CONSTRAINT appuser_appgroup_appgroup_id_fk120 FOREIGN KEY (appgroup_id) REFERENCES appgroup(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: appuser_appgroup_appuser_id_fk119; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY appuser_appgroup
    ADD CONSTRAINT appuser_appgroup_appuser_id_fk119 FOREIGN KEY (appuser_id) REFERENCES appuser(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: appuser_setting_user_id_fk103; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY appuser_setting
    ADD CONSTRAINT appuser_setting_user_id_fk103 FOREIGN KEY (user_id) REFERENCES appuser(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: br_definition_br_id_fk116; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_definition
    ADD CONSTRAINT br_definition_br_id_fk116 FOREIGN KEY (br_id) REFERENCES br(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: br_technical_type_code_fk107; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br
    ADD CONSTRAINT br_technical_type_code_fk107 FOREIGN KEY (technical_type_code) REFERENCES br_technical_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_br_id_fk108; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_br_id_fk108 FOREIGN KEY (br_id) REFERENCES br(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_severity_code_fk109; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_severity_code_fk109 FOREIGN KEY (severity_code) REFERENCES br_severity_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_target_application_moment_fk113; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_target_application_moment_fk113 FOREIGN KEY (target_application_moment) REFERENCES application.application_action_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_target_code_fk110; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_target_code_fk110 FOREIGN KEY (target_code) REFERENCES br_validation_target_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_target_reg_moment_fk115; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_target_reg_moment_fk115 FOREIGN KEY (target_reg_moment) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_target_request_type_code_fk111; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_target_request_type_code_fk111 FOREIGN KEY (target_request_type_code) REFERENCES application.request_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_target_rrr_type_code_fk112; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_target_rrr_type_code_fk112 FOREIGN KEY (target_rrr_type_code) REFERENCES administrative.rrr_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_target_service_moment_fk114; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_target_service_moment_fk114 FOREIGN KEY (target_service_moment) REFERENCES application.service_action_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: config_map_layer_metadata_name_fk; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY config_map_layer_metadata
    ADD CONSTRAINT config_map_layer_metadata_name_fk FOREIGN KEY (name_layer) REFERENCES config_map_layer(name) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: config_map_layer_pojo_query_name_fk105; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY config_map_layer
    ADD CONSTRAINT config_map_layer_pojo_query_name_fk105 FOREIGN KEY (pojo_query_name) REFERENCES query(name) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: config_map_layer_pojo_query_name_for_select_fk106; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY config_map_layer
    ADD CONSTRAINT config_map_layer_pojo_query_name_for_select_fk106 FOREIGN KEY (pojo_query_name_for_select) REFERENCES query(name) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: config_map_layer_type_code_fk104; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY config_map_layer
    ADD CONSTRAINT config_map_layer_type_code_fk104 FOREIGN KEY (type_code) REFERENCES config_map_layer_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: config_panel_launcher_launch_group_fkey; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY config_panel_launcher
    ADD CONSTRAINT config_panel_launcher_launch_group_fkey FOREIGN KEY (launch_group) REFERENCES panel_launcher_group(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: map_search_option_query_name_fk122; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY map_search_option
    ADD CONSTRAINT map_search_option_query_name_fk122 FOREIGN KEY (query_name) REFERENCES query(name) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: query_field_query_name_fk121; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY query_field
    ADD CONSTRAINT query_field_query_name_fk121 FOREIGN KEY (query_name) REFERENCES query(name) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = transaction, pg_catalog;

--
-- Name: transaction_from_service_id_fk6; Type: FK CONSTRAINT; Schema: transaction; Owner: postgres
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_from_service_id_fk6 FOREIGN KEY (from_service_id) REFERENCES application.service(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transaction_source_source_id_fk101; Type: FK CONSTRAINT; Schema: transaction; Owner: postgres
--

ALTER TABLE ONLY transaction_source
    ADD CONSTRAINT transaction_source_source_id_fk101 FOREIGN KEY (source_id) REFERENCES source.source(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_source_transaction_id_fk100; Type: FK CONSTRAINT; Schema: transaction; Owner: postgres
--

ALTER TABLE ONLY transaction_source
    ADD CONSTRAINT transaction_source_transaction_id_fk100 FOREIGN KEY (transaction_id) REFERENCES transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_status_code_fk27; Type: FK CONSTRAINT; Schema: transaction; Owner: postgres
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_status_code_fk27 FOREIGN KEY (status_code) REFERENCES transaction_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: system; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA system FROM PUBLIC;
REVOKE ALL ON SCHEMA system FROM postgres;
GRANT ALL ON SCHEMA system TO postgres;


--
-- PostgreSQL database dump complete
--

