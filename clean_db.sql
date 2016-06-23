SET session_replication_role = replica;

delete from opentenure.claim_comment;
delete from opentenure.claim_comment_historic;
delete from opentenure.claim_uses_attachment;
delete from opentenure.claim_uses_attachment_historic;
delete from opentenure.attachment_chunk;
delete from opentenure.attachment;
delete from opentenure.attachment_historic;
delete from opentenure.claim_location;
delete from opentenure.claim_location_historic;
delete from opentenure.party_for_claim_share;
delete from opentenure.party_for_claim_share_historic;
delete from opentenure.claim_share;
delete from opentenure.claim_share_historic;
delete from opentenure.claim;
delete from opentenure.claim_historic;
delete from opentenure.party;
delete from opentenure.party_historic;
ALTER SEQUENCE opentenure.claim_nr_seq RESTART WITH 1;

-- Dynamic forms data
delete from opentenure.field_payload;
delete from opentenure.field_payload_historic;
delete from opentenure.section_element_payload;
delete from opentenure.section_element_payload_historic;
delete from opentenure.section_payload;
delete from opentenure.section_payload_historic;
delete from opentenure.form_payload;
delete from opentenure.form_payload_historic;

-- Dynamic forms structure
delete from opentenure.field_constraint_option;
delete from opentenure.field_constraint_option_historic;
delete from opentenure.field_constraint;
delete from opentenure.field_constraint_historic;
delete from opentenure.field_template;
delete from opentenure.field_template_historic;
delete from opentenure.section_template;
delete from opentenure.section_template_historic;
delete from opentenure.form_template;
delete from opentenure.form_template_historic;

-- Users
--delete from system.appuser where username != 'test';
--delete from system.appuser_historic;

vacuum full;

SET session_replication_role = DEFAULT;