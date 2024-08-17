INSERT INTO system.version SELECT '1506a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1506a');
-- Section template
ALTER TABLE opentenure.section_template ADD COLUMN item_order integer DEFAULT 1;
COMMENT ON COLUMN opentenure.section_template.item_order IS 'Section ordering number.';
ALTER TABLE opentenure.section_template_historic ADD COLUMN item_order integer;

UPDATE opentenure.section_template SET item_order = 1;
ALTER TABLE opentenure.section_template ALTER COLUMN item_order SET NOT NULL;

-- Section payload
ALTER TABLE opentenure.section_payload ADD COLUMN item_order integer DEFAULT 1;
COMMENT ON COLUMN opentenure.section_payload.item_order IS 'Section ordering number.';
ALTER TABLE opentenure.section_payload_historic ADD COLUMN item_order integer;

UPDATE opentenure.section_payload SET item_order = 1;
ALTER TABLE opentenure.section_payload ALTER COLUMN item_order SET NOT NULL;

-- Field template
ALTER TABLE opentenure.field_template ADD COLUMN item_order integer DEFAULT 1;
COMMENT ON COLUMN opentenure.field_template.item_order IS 'Field ordering number.';
ALTER TABLE opentenure.field_template_historic ADD COLUMN item_order integer;

UPDATE opentenure.field_template SET item_order = 1;
ALTER TABLE opentenure.field_template ALTER COLUMN item_order SET NOT NULL;

-- Field payload
ALTER TABLE opentenure.field_payload ADD COLUMN item_order integer DEFAULT 1;
COMMENT ON COLUMN opentenure.field_payload.item_order IS 'Field ordering number.';
ALTER TABLE opentenure.field_payload_historic ADD COLUMN item_order integer;

UPDATE opentenure.field_payload SET item_order = 1;
ALTER TABLE opentenure.field_payload ALTER COLUMN item_order SET NOT NULL;

-- Constraint option
ALTER TABLE opentenure.field_constraint_option ADD COLUMN item_order integer DEFAULT 1;
COMMENT ON COLUMN opentenure.field_constraint_option.item_order IS 'Field constraint option ordering number.';
ALTER TABLE opentenure.field_constraint_option_historic ADD COLUMN item_order integer;

UPDATE opentenure.field_constraint_option SET item_order = 1;
ALTER TABLE opentenure.field_constraint_option ALTER COLUMN item_order SET NOT NULL;
