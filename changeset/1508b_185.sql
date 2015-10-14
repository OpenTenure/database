INSERT INTO system.version SELECT '1508b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1508b');
ALTER TABLE system.config_map_layer_metadata ADD COLUMN for_client boolean DEFAULT 'f';
COMMENT ON COLUMN system.config_map_layer_metadata.for_client IS 'Indicates whether an option is for use by the client or server. If true, it''s supposed to be used by the client map control, otherwise option is sent to the server.';
ALTER TABLE system.config_map_layer_metadata DROP CONSTRAINT config_map_layer_metadata_name_fk;
ALTER TABLE system.config_map_layer_metadata ADD CONSTRAINT config_map_layer_metadata_name_fk FOREIGN KEY (name_layer)
      REFERENCES system.config_map_layer (name) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE system.config_map_layer ALTER COLUMN use_for_ot SET DEFAULT true;