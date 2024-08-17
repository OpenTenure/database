SET search_path = opentenure, pg_catalog;


ALTER TABLE claim
DROP COLUMN IF EXISTS issuance_date,
DROP COLUMN IF EXISTS termination_date,
DROP COLUMN IF EXISTS termination_reason_code,
DROP COLUMN IF EXISTS create_transaction,
DROP COLUMN IF EXISTS terminate_transaction;

ALTER TABLE claim
ADD issuance_date timestamp without time zone,
ADD termination_date date,
ADD termination_reason_code character varying(20),
ADD create_transaction character varying(40),
ADD terminate_transaction character varying(40);

ALTER TABLE claim_historic
DROP COLUMN IF EXISTS issuance_date,
DROP COLUMN IF EXISTS termination_date,
DROP COLUMN IF EXISTS termination_reason_code,
DROP COLUMN IF EXISTS create_transaction,
DROP COLUMN IF EXISTS terminate_transaction;

ALTER TABLE claim_historic
ADD issuance_date timestamp without time zone,
ADD termination_date date,
ADD termination_reason_code character varying(20),
ADD create_transaction character varying(40),
ADD terminate_transaction character varying(40);

ALTER TABLE claim_share
DROP COLUMN IF EXISTS status,
DROP COLUMN IF EXISTS registration_date,
DROP COLUMN IF EXISTS termination_date;

ALTER TABLE claim_share
ADD COLUMN status character(1) DEFAULT 'a'::bpchar NOT NULL,
ADD COLUMN  registration_date date,
ADD COLUMN termination_date date;

ALTER TABLE claim_share_historic
DROP COLUMN IF EXISTS status,
DROP COLUMN IF EXISTS registration_date,
DROP COLUMN IF EXISTS termination_date;

ALTER TABLE claim_share_historic
ADD COLUMN status character(1) DEFAULT 'a'::bpchar NOT NULL,
ADD COLUMN  registration_date date,
ADD COLUMN termination_date date;

--
-- Name: COLUMN claim.issuance_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.issuance_date IS 'Claim issuance date';


--
-- Name: COLUMN claim.termination_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.termination_date IS 'Date when claim was terminated';


--
-- Name: COLUMN claim.termination_reason_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.termination_reason_code IS 'Termination reason code';


--
-- Name: COLUMN claim.create_transaction; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.create_transaction IS 'Transaction code, used to create claim. It used for split/merge transaction to link parent and children claims.';
--
-- Name: COLUMN claim.terminate_transaction; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.terminate_transaction IS 'Transaction code, used to terminate claim. It used for split/merge transaction to link parent and children claims.';

--
-- Name: COLUMN claim_share.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.status IS 'Indicating the status of the share. a - active (approved), h - historic, p - pending.';


--
-- Name: COLUMN claim_share.registration_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.registration_date IS 'Registration date of the share. For initial claims must be equal to the date of the claim approval';


--
-- Name: COLUMN claim_share.termination_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim_share.termination_date IS 'Termination date of the share (when share became historic)';

--
-- Name: party_for_restriction; Type: TABLE; Schema: opentenure; Owner: postgres
--

DROP TABLE IF EXISTS party_for_restriction;

CREATE TABLE party_for_restriction (
    party_id character varying(40) NOT NULL,
    restriction_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party_for_restriction OWNER TO postgres;

--
-- Name: TABLE party_for_restriction; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE party_for_restriction IS 'Identifies parties involved in the restriction.';


--
-- Name: COLUMN party_for_restriction.party_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_restriction.party_id IS 'Identifier for the party.';


--
-- Name: COLUMN party_for_restriction.restriction_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_restriction.restriction_id IS 'Identifier of the restriction.';


--
-- Name: COLUMN party_for_restriction.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_restriction.rowidentifier IS 'Identifies the all change records for the row in the party_for_claim_share_historic table';


--
-- Name: COLUMN party_for_restriction.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_restriction.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party_for_restriction.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_restriction.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party_for_restriction.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_restriction.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN party_for_restriction.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN party_for_restriction.change_time IS 'The date and time the row was last modified.';


--
-- Name: party_for_restriction_historic; Type: TABLE; Schema: opentenure; Owner: postgres
--
DROP TABLE IF EXISTS party_for_restriction_historic;

CREATE TABLE party_for_restriction_historic (
    party_id character varying(40),
    restriction_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party_for_restriction_historic OWNER TO postgres;

--
-- Name: restriction; Type: TABLE; Schema: opentenure; Owner: postgres
--
DROP TABLE IF EXISTS restriction;

CREATE TABLE restriction (
    id character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    claim_id character varying(40) NOT NULL,
    type_code character varying(20) NOT NULL,
    amount numeric(29,2),
    start_date date,
    end_date date,
    interest_rate numeric(5,2),
    registration_date timestamp without time zone DEFAULT now() NOT NULL,
    termination_date timestamp without time zone,
    status character(1) DEFAULT 'a'::bpchar NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE restriction OWNER TO postgres;

--
-- Name: TABLE restriction; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE restriction IS 'Various claim restrictions.';


--
-- Name: COLUMN restriction.id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.id IS 'Unique identifier for the restriction.';


--
-- Name: COLUMN restriction.claim_id; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.claim_id IS 'Claim ID.';


--
-- Name: COLUMN restriction.type_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.type_code IS 'Restriction type code.';


--
-- Name: COLUMN restriction.amount; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.amount IS 'Mortgage amount';


--
-- Name: COLUMN restriction.start_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.start_date IS 'Restriction start date. For mortgage start date of payment.';


--
-- Name: COLUMN restriction.end_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.end_date IS 'Restriction end date.';


--
-- Name: COLUMN restriction.interest_rate; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.interest_rate IS 'Mortgage interest rate.';


--
-- Name: COLUMN restriction.registration_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.registration_date IS 'Date when restriction was registered.';


--
-- Name: COLUMN restriction.termination_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.termination_date IS 'Date when restriction was terminated.';


--
-- Name: COLUMN restriction.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.status IS 'Indicating the status of the restriction. a - active (approved), h - historic, p - pending.';


--
-- Name: COLUMN restriction.rowidentifier; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.rowidentifier IS 'Identifies the all change records for the row in the document_historic table';


--
-- Name: COLUMN restriction.rowversion; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN restriction.change_action; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN restriction.change_user; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN restriction.change_time; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN restriction.change_time IS 'The date and time the row was last modified.';


--
-- Name: restriction_historic; Type: TABLE; Schema: opentenure; Owner: postgres
--

DROP TABLE IF EXISTS restriction_historic;

CREATE TABLE restriction_historic (
    id character varying(40),
    claim_id character varying(40),
    type_code character varying(20),
    amount numeric(29,2),
    start_date date,
    end_date date,
    interest_rate numeric(5,2),
    registration_date timestamp without time zone,
    termination_date timestamp without time zone,
    status character(1),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE restriction_historic OWNER TO postgres;

--
-- Name: termination_reason; Type: TABLE; Schema: opentenure; Owner: postgres
--

DROP TABLE IF EXISTS termination_reason;

CREATE TABLE termination_reason (
    code character varying(20) NOT NULL,
    display_value character varying(500) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(1000)
);


ALTER TABLE termination_reason OWNER TO postgres;

--
-- Name: TABLE termination_reason; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON TABLE termination_reason IS 'Code list of termination reasons which can happen to the claim.';


--
-- Name: COLUMN termination_reason.code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN termination_reason.code IS 'The code for the termination reason.';


--
-- Name: COLUMN termination_reason.display_value; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN termination_reason.display_value IS 'Displayed value of the termination reason.';


--
-- Name: COLUMN termination_reason.status; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN termination_reason.status IS 'Status of the termination reason.';


--
-- Name: COLUMN termination_reason.description; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN termination_reason.description IS 'Description of the termination reason.';

--
-- Name: party_for_restriction_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres
--
ALTER TABLE ONLY party_for_restriction
	DROP CONSTRAINT IF EXISTS party_for_restriction_pkey;
	
ALTER TABLE ONLY party_for_restriction
    ADD CONSTRAINT party_for_restriction_pkey PRIMARY KEY (party_id, restriction_id);

--
-- Name: restriction_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY restriction
	DROP CONSTRAINT IF EXISTS restriction_pkey;
	
ALTER TABLE ONLY restriction
    ADD CONSTRAINT restriction_pkey PRIMARY KEY (id);

--
-- Name: termination_reason_display_value_unique; Type: CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY termination_reason
    DROP CONSTRAINT IF EXISTS termination_reason_display_value_unique;

ALTER TABLE ONLY termination_reason
    ADD CONSTRAINT termination_reason_display_value_unique UNIQUE (display_value);


--
-- Name: termination_reason_pkey; Type: CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY termination_reason
    DROP CONSTRAINT IF EXISTS termination_reason_pkey;

ALTER TABLE ONLY termination_reason
    ADD CONSTRAINT termination_reason_pkey PRIMARY KEY (code);

--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON restriction FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party_for_restriction FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();

--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON restriction FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: opentenure; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party_for_restriction FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();

--
-- Name: fk_claim_termination_reason; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--

ALTER TABLE ONLY claim
    DROP CONSTRAINT IF EXISTS fk_claim_termination_reason;
ALTER TABLE ONLY claim
    ADD CONSTRAINT fk_claim_termination_reason FOREIGN KEY (termination_reason_code) REFERENCES termination_reason(code);

--
-- Name: party_for_restriction_party_id_fk; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--
ALTER TABLE ONLY party_for_restriction
    DROP CONSTRAINT IF EXISTS party_for_restriction_party_id_fk;

ALTER TABLE ONLY party_for_restriction
    ADD CONSTRAINT party_for_restriction_party_id_fk FOREIGN KEY (party_id) REFERENCES party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_for_restriction_restriction_id_fk; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--
ALTER TABLE ONLY party_for_restriction
    DROP CONSTRAINT IF EXISTS party_for_restriction_restriction_id_fk;


ALTER TABLE ONLY party_for_restriction
    ADD CONSTRAINT party_for_restriction_restriction_id_fk FOREIGN KEY (restriction_id) REFERENCES restriction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: restriction_claim_id_fk; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--
ALTER TABLE ONLY restriction
    DROP CONSTRAINT IF EXISTS restriction_claim_id_fk;


ALTER TABLE ONLY restriction
    ADD CONSTRAINT restriction_claim_id_fk FOREIGN KEY (claim_id) REFERENCES claim(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: restriction_type_fk; Type: FK CONSTRAINT; Schema: opentenure; Owner: postgres
--
ALTER TABLE ONLY restriction
    DROP CONSTRAINT IF EXISTS restriction_type_fk;

ALTER TABLE ONLY restriction
    ADD CONSTRAINT restriction_type_fk FOREIGN KEY (type_code) REFERENCES administrative.rrr_type(code);

--
-- Name: COLUMN claim.issuance_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.issuance_date IS 'Claim issuance date';


--
-- Name: COLUMN claim.termination_date; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.termination_date IS 'Date when claim was terminated';


--
-- Name: COLUMN claim.termination_reason_code; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.termination_reason_code IS 'Termination reason code';


--
-- Name: COLUMN claim.create_transaction; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.create_transaction IS 'Transaction code, used to create claim. It used for split/merge transaction to link parent and children claims.';


--
-- Name: COLUMN claim.terminate_transaction; Type: COMMENT; Schema: opentenure; Owner: postgres
--

COMMENT ON COLUMN claim.terminate_transaction IS 'Transaction code, used to terminate claim. It used for split/merge transaction to link parent and children claims.';
--
INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('signed_cert', 'Signed certificate', 'c', '', false) ON CONFLICT (code) DO NOTHING;
--
UPDATE party.gender_type SET status='x' WHERE code = 'na';
--
INSERT INTO system.setting (name, vl, active, description) VALUES ('docs_for_issuing_cert', 'signed_cert', true, 'List of document type codes, required to set certificate issued status') ON CONFLICT (name) DO NOTHING;
INSERT INTO system.setting (name, vl, active, description) VALUES ('claim_certificate_report_url', '/reports/cert/ClaimCertificate', true, '	URL to the claim certificate report, hosted on the reporting server') ON CONFLICT (name) DO NOTHING;
DELETE FROM system.setting  WHERE name IN (SELECT name FROM system.setting WHERE name = 'claim_cetificate_report_url');
UPDATE system.setting SET vl='/reports/community_server' WHERE name = 'reports_folder_url';
UPDATE system.setting SET vl=' 	/reports/cert/Claim_certificate' WHERE name = 'claim_certificate_report_url';
UPDATE system.setting SET vl='1' WHERE name = 'enable-reports';
UPDATE system.setting SET vl='0' WHERE name = 'email-enable-email-service';
UPDATE system.setting SET vl='POLYGON((109.74609411031194 0.09813301791300173,109.7153231752756 -0.023668551286050537,109.7384013765506 -0.07837241202817027,109.740110872944 -0.12068238290721188,109.90806889334426 -0.13350357426959336,109.90550464876313 -0.10615169209230177,109.84994601605841 -0.045464626171931775,109.83797954132254 0.022487850017511038,109.86490410947373 0.023342598144547932,109.87131472093999 0.09086766813866418,109.74609411031194 0.09813301791300173))' WHERE name = 'ot-community-area';
UPDATE system.setting SET vl='0' WHERE name = 'email-enable-email-service';
UPDATE system.setting SET vl='C:\Program Files\PostgreSQL\9.5\bin' WHERE name = 'db-utilities-folder';
--
INSERT INTO system.version SELECT '1708a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1708a');



