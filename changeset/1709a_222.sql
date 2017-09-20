SET search_path = opentenure, pg_catalog;
--
INSERT INTO claim_status VALUES ('issued', 'Issued', 'c', 'Final status for the claim, indicating it is issued to the owner') ON CONFLICT (code) DO NOTHING;
INSERT INTO claim_status VALUES ('historic', 'Historic', 'c', 'Historic status, indicating that parcel was split or merged.') ON CONFLICT (code) DO NOTHING;
--
INSERT INTO system.version SELECT '1709a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1708a');
