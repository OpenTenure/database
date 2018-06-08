--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = system, pg_catalog;

--
-- Data for Name: config_map_layer_type; Type: TABLE DATA; Schema: system; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE config_map_layer_type DISABLE TRIGGER ALL;

INSERT INTO config_map_layer_type (code, display_value, status, description) VALUES ('wms', 'WMS server with layers::::Server WMS con layer::::::::::::Servidor WMS con capas::::::::WMS server with layers::::::::', 'c', '');
INSERT INTO config_map_layer_type (code, display_value, status, description) VALUES ('shape', 'Shapefile::::Shapefile::::::::::::Formato Shapefile::::::::Arquivo de forma::::::::', 'c', '');
INSERT INTO config_map_layer_type (code, display_value, status, description) VALUES ('pojo', 'Pojo layer::::Pojo layer::::::::::::Capa Pojo::::::::Pojo layer::::::::', 'c', '');
INSERT INTO config_map_layer_type (code, display_value, status, description) VALUES ('pojo_public_display', 'Pojo layer used for public display::::::::::::::::Capa Pojo utilizado para la visualización pública::::::::Pojo layer used for public display::::::::', 'c', 'It is an extension of pojo layer. It is used only during the public display map generation.::::::::::::::::Es una extensión de la capa de pojo. Se utiliza sólo durante la generación pública de la exhibición del mapa.::::::::It is an extension of pojo layer. It is used only during the public display map generation.::::::::');


ALTER TABLE config_map_layer_type ENABLE TRIGGER ALL;

--
-- Data for Name: query; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE query DISABLE TRIGGER ALL;

INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getParcels', 'select co.id, co.name_firstpart || ''/'' || co.name_lastpart as label,  st_asewkb(st_transform(co.geom_polygon, #{srid})) as the_geom from cadastre.cadastre_object co where type_code= ''parcel'' and status_code= ''current'' and ST_Intersects(st_transform(co.geom_polygon, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) and st_area(co.geom_polygon)> power(5 * #{pixel_res}, 2)', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getParcelsPending', 'select co.id, co.name_firstpart || ''/'' || co.name_lastpart as label,  st_asewkb(st_transform(co.geom_polygon, #{srid})) as the_geom  from cadastre.cadastre_object co  where type_code= ''parcel'' and status_code= ''pending''   and ST_Intersects(st_transform(co.geom_polygon, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) union select co.id, co.name_firstpart || ''/'' || co.name_lastpart as label,  st_asewkb(co_t.geom_polygon) as the_geom  from cadastre.cadastre_object co inner join cadastre.cadastre_object_target co_t on co.id = co_t.cadastre_object_id and co_t.geom_polygon is not null where ST_Intersects(co_t.geom_polygon, ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))       and co_t.transaction_id in (select id from transaction.transaction where status_code not in (''approved'')) ', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getSurveyControls', 'select id, label, st_asewkb(st_transform(geom, #{srid})) as the_geom from cadastre.survey_control  where ST_Intersects(st_transform(geom, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getRoads', 'select id, label, st_asewkb(st_transform(geom, #{srid})) as the_geom from cadastre.road where ST_Intersects(st_transform(geom, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) and st_area(geom)> power(5 * #{pixel_res}, 2)', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getPlaceNames', 'select id, label, st_asewkb(st_transform(geom, #{srid})) as the_geom from cadastre.place_name where ST_Intersects(st_transform(geom, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getApplications', 'select id, nr as label, st_asewkb(st_transform(location, #{srid})) as the_geom from application.application where ST_Intersects(st_transform(location, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_parcel', 'select co.id, co.name_firstpart || ''/'' || co.name_lastpart as parcel_nr,      (select string_agg(ba.name_firstpart || ''/'' || ba.name_lastpart, '','')      from administrative.ba_unit_contains_spatial_unit bas, administrative.ba_unit ba      where spatial_unit_id= co.id and bas.ba_unit_id= ba.id) as ba_units,      ( SELECT spatial_value_area.size FROM cadastre.spatial_value_area      WHERE spatial_value_area.type_code=''officialArea'' and spatial_value_area.spatial_unit_id = co.id) AS area_official_sqm,       st_asewkb(st_transform(co.geom_polygon, #{srid})) as the_geom      from cadastre.cadastre_object co      where type_code= ''parcel'' and status_code= ''current''      and ST_Intersects(st_transform(co.geom_polygon, #{srid}), ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_parcel_pending', 'select co.id, co.name_firstpart || ''/'' || co.name_lastpart as parcel_nr,       ( SELECT spatial_value_area.size FROM cadastre.spatial_value_area         WHERE spatial_value_area.type_code=''officialArea'' and spatial_value_area.spatial_unit_id = co.id) AS area_official_sqm,   st_asewkb(st_transform(co.geom_polygon, #{srid})) as the_geom    from cadastre.cadastre_object co  where type_code= ''parcel'' and ((status_code= ''pending''    and ST_Intersects(st_transform(co.geom_polygon, #{srid}), ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid})))   or (co.id in (select cadastre_object_id           from cadastre.cadastre_object_target co_t inner join transaction.transaction t on co_t.transaction_id=t.id           where ST_Intersects(st_transform(co.geom_polygon, #{srid}), ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid})) and t.status_code not in (''approved''))))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_place_name', 'select id, label,  st_asewkb(st_transform(geom, #{srid})) as the_geom from cadastre.place_name where ST_Intersects(st_transform(geom, #{srid}), ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_road', 'select id, label,  st_asewkb(st_transform(geom, #{srid})) as the_geom from cadastre.road where ST_Intersects(st_transform(geom, #{srid}), ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_application', 'select id, nr,  st_asewkb(st_transform(location, #{srid})) as the_geom from application.application where ST_Intersects(st_transform(location, #{srid}), ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_survey_control', 'select id, label,  st_asewkb(st_transform(geom, #{srid})) as the_geom from cadastre.survey_control where ST_Intersects(st_transform(geom, #{srid}), ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getParcelsHistoricWithCurrentBA', 'select co.id, co.name_firstpart || ''/'' || co.name_lastpart as label,  st_asewkb(st_transform(co.geom_polygon, #{srid})) as the_geom from cadastre.cadastre_object co inner join administrative.ba_unit_contains_spatial_unit ba_co on co.id = ba_co.spatial_unit_id   inner join administrative.ba_unit ba_unit on ba_unit.id= ba_co.ba_unit_id where co.type_code=''parcel'' and co.status_code= ''historic'' and ba_unit.status_code = ''current'' and ST_Intersects(st_transform(co.geom_polygon, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 'select co.id, co.name_firstpart || ''/'' || co.name_lastpart as parcel_nr,         (select string_agg(ba.name_firstpart || ''/'' || ba.name_lastpart, '','')           from administrative.ba_unit_contains_spatial_unit bas, administrative.ba_unit ba           where spatial_unit_id= co.id and bas.ba_unit_id= ba.id) as ba_units,         (SELECT spatial_value_area.size      FROM cadastre.spatial_value_area           WHERE spatial_value_area.type_code=''officialArea'' and spatial_value_area.spatial_unit_id = co.id) AS area_official_sqm,         st_asewkb(st_transform(co.geom_polygon, #{srid})) as the_geom        from cadastre.cadastre_object co inner join administrative.ba_unit_contains_spatial_unit ba_co on co.id = ba_co.spatial_unit_id   inner join administrative.ba_unit ba_unit on ba_unit.id= ba_co.ba_unit_id where co.type_code=''parcel'' and co.status_code= ''historic'' and ba_unit.status_code = ''current''       and ST_Intersects(st_transform(co.geom_polygon, #{srid}), ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('map_search.cadastre_object_by_number', 'select id, name_firstpart || ''/ '' || name_lastpart as label, st_asewkb(st_transform(geom_polygon, #{srid})) as the_geom  from cadastre.cadastre_object  where status_code= ''current'' and compare_strings(#{search_string}, name_firstpart || '' '' || name_lastpart) limit 30', NULL);
INSERT INTO query (name, sql, description) VALUES ('map_search.cadastre_object_by_baunit', 'select distinct co.id,  ba_unit.name_firstpart || ''/ '' || ba_unit.name_lastpart || '' > '' || co.name_firstpart || ''/ '' || co.name_lastpart as label,  st_asewkb(st_transform(geom_polygon, #{srid})) as the_geom from cadastre.cadastre_object  co    inner join administrative.ba_unit_contains_spatial_unit bas on co.id = bas.spatial_unit_id     inner join administrative.ba_unit on ba_unit.id = bas.ba_unit_id  where (co.status_code= ''current'' or ba_unit.status_code= ''current'')    and compare_strings(#{search_string}, ba_unit.name_firstpart || '' '' || ba_unit.name_lastpart) limit 30', NULL);
INSERT INTO query (name, sql, description) VALUES ('map_search.cadastre_object_by_baunit_owner', 'select distinct co.id,  coalesce(party.name, '''') || '' '' || coalesce(party.last_name, '''') || '' > '' || co.name_firstpart || ''/ '' || co.name_lastpart as label,  st_asewkb(st_transform(co.geom_polygon, #{srid})) as the_geom  from cadastre.cadastre_object  co     inner join administrative.ba_unit_contains_spatial_unit bas on co.id = bas.spatial_unit_id     inner join administrative.ba_unit on bas.ba_unit_id= ba_unit.id     inner join administrative.rrr on (ba_unit.id = rrr.ba_unit_id and rrr.status_code = ''current'' and rrr.type_code = ''ownership'')     inner join administrative.party_for_rrr pfr on rrr.id = pfr.rrr_id     inner join party.party on pfr.party_id= party.id where (co.status_code= ''current'' or ba_unit.status_code= ''current'')     and compare_strings(#{search_string}, coalesce(party.name, '''') || '' '' || coalesce(party.last_name, '''')) limit 30', NULL);
INSERT INTO query (name, sql, description) VALUES ('system_search.cadastre_object_by_baunit_id', 'SELECT id,  name_firstpart || ''/ '' || name_lastpart as label, st_asewkb(st_transform(geom_polygon, #{srid})) as the_geom  FROM cadastre.cadastre_object WHERE transaction_id IN (  SELECT cot.transaction_id FROM (administrative.ba_unit_contains_spatial_unit ba_su     INNER JOIN cadastre.cadastre_object co ON ba_su.spatial_unit_id = co.id)     INNER JOIN cadastre.cadastre_object_target cot ON co.id = cot.cadastre_object_id     WHERE ba_su.ba_unit_id = #{search_string})  AND (SELECT COUNT(1) FROM administrative.ba_unit_contains_spatial_unit WHERE spatial_unit_id = cadastre_object.id) = 0 AND status_code = ''current''', 'Query used by BaUnitBean.loadNewParcels');
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getParcelNodes', 'select distinct st_astext(st_transform(geom, #{srid})) as id, '''' as label, st_asewkb(st_transform(geom, #{srid})) as the_geom from (select (ST_DumpPoints(geom_polygon)).* from cadastre.cadastre_object co  where type_code= ''parcel'' and status_code= ''current''  and ST_Intersects(st_transform(co.geom_polygon, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))) tmp_table ', NULL);
INSERT INTO query (name, sql, description) VALUES ('public_display.parcels', 'select co.id, co.name_firstpart as label,  st_asewkb(st_transform(co.geom_polygon, #{srid})) as the_geom from cadastre.cadastre_object co where type_code= ''parcel'' and status_code= ''current'' and name_lastpart = #{name_lastpart} and ST_Intersects(st_transform(co.geom_polygon, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', 'Query is used from public display map. It retrieves parcels being of a certain area (name_lastpart).');
INSERT INTO query (name, sql, description) VALUES ('public_display.parcels_next', 'SELECT co_next.id, co_next.name_firstpart as label,  st_asewkb(st_transform(co_next.geom_polygon, #{srid})) as the_geom  from cadastre.cadastre_object co_next, cadastre.cadastre_object co where co.type_code= ''parcel'' and co.status_code= ''current'' and co_next.type_code= ''parcel'' and co_next.status_code= ''current'' and co.name_lastpart = #{name_lastpart} and co_next.name_lastpart != #{name_lastpart} and st_dwithin(st_transform(co.geom_polygon, #{srid}), st_transform(co_next.geom_polygon, #{srid}), 5) and ST_Intersects(st_transform(co_next.geom_polygon, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', ' Query is used from public display map. It retrieves parcels being near the parcels of the layer public-display-parcels.');
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getHierarchy', 'select id, label, st_asewkb(geom) as the_geom, filter_category  from cadastre.hierarchy where ST_Intersects(geom, ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) and st_area(geom)> power(5 * #{pixel_res}, 2)', 'Query is used from Spatial Unit Group Editor to edit hierarchy records');
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getRoadCenterlines', 'select id, label, st_asewkb(st_transform(geom, #{srid})) as the_geom from cadastre.spatial_unit where level_id = ''road-centerline'' and ST_Intersects(st_transform(geom, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getHouseNum', 'select su.id, su.label,  st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''House Number'' and ST_Intersects(su.reference_point, ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('map_search.locality', 'SELECT co.id, a.description as label, st_asewkb(co.geom_polygon) as the_geom 
  FROM cadastre.cadastre_object co, cadastre.spatial_unit_address sa,
       address.address a
  WHERE co.id = sa.spatial_unit_id
  AND   a.id = sa.address_id  
  AND compare_strings(#{search_string}, a.description)
  AND co.geom_polygon IS NOT NULL
  ORDER BY a.description', NULL);


ALTER TABLE query ENABLE TRIGGER ALL;

--
-- Data for Name: config_map_layer; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE config_map_layer DISABLE TRIGGER ALL;

INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, wms_data_source, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password, added_from_bulk_operation, use_in_public_display, use_for_ot) VALUES ('claims-orthophoto', 'Claims::::::::::::::::::::::::::::::::::::အဆိုပြုမှုများ', 'wms', true, false, 12, '', 'http://ot.flossola.org/geoserver/opentenure/wms', 'opentenure:claims_kebbi', '1.1.1', 'image/png', '', '', NULL, NULL, '', '', '', false, false, true);


ALTER TABLE config_map_layer ENABLE TRIGGER ALL;

--
-- Data for Name: config_map_layer_metadata; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE config_map_layer_metadata DISABLE TRIGGER ALL;

INSERT INTO config_map_layer_metadata (name_layer, name, value, for_client) VALUES ('claims-orthophoto', 'transparent', 'true', false);
INSERT INTO config_map_layer_metadata (name_layer, name, value, for_client) VALUES ('claims-orthophoto', 'LEGEND_OPTIONS', 'fontSize:12', false);
INSERT INTO config_map_layer_metadata (name_layer, name, value, for_client) VALUES ('claims-orthophoto', 'singleTile', 'true', true);


ALTER TABLE config_map_layer_metadata ENABLE TRIGGER ALL;

--
-- Data for Name: panel_launcher_group; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE panel_launcher_group DISABLE TRIGGER ALL;

INSERT INTO panel_launcher_group (code, display_value, description, status) VALUES ('recordRelationship', 'Record Relationship::::::::تسجيل العلاقة::::::::::::::::Cadastrar Relacionamento::::::::记录关系', 'Panels used for relationship services::::::::لوحة تستخدم لحدمات العلاقات::::::::::::::::Panels used for relationship services::::::::用于关系服务的面板', 'c');
INSERT INTO panel_launcher_group (code, display_value, description, status) VALUES ('cancelRelationship', 'Cancel Relationship::::::::الغاء الصلة::::::::::::::::Cancelar Relacionamento::::::::取消关系', 'Panels used for cancel relationship services::::::::لوحة تستخدم  لخدمات الغاء الملكية::::::::::::::::Panels used for cancel relationship services::::::::用于取消关系服务的面板', 'c');
INSERT INTO panel_launcher_group (code, display_value, description, status) VALUES ('nullConstructor', 'Nullary Constructor::::::::منشئ بدون مدخلات::::::::Nullary Constructor::::::::Nullary Constructor::::::::默认的构造函数', 'Panels that do not take any constructor arguments::::::::لوحة لا تأخد اية مدخلات عند المنشئ::::::::Paneles que no tienen ningún argumento del constructor::::::::Panels that do not take any constructor arguments::::::::不带任何构造函数参数的面板', 'c');
INSERT INTO panel_launcher_group (code, display_value, description, status) VALUES ('documentServices', 'Document Services::::::::خدمات الوثيقة::::::::Servicios de Documento::::::::Document Services::::::::文件服务', 'Panels used for document services::::::::لوحة تستخدم لخدمات الوثائق::::::::Paneles utilizados para servicios de documentos::::::::Panels used for document services::::::::用于文档服务的面板', 'c');
INSERT INTO panel_launcher_group (code, display_value, description, status) VALUES ('cadastreServices', 'Cadastre Services::::::::خدمات المساحة::::::::Servicios de catastro::::::::Cadastre Services::::::::地籍服务', 'Panels used for cadastre services::::::::لوحة تستخدم لخدمات المساحة::::::::Paneles usados para servicios de catastro::::::::Panels used for cadastre services::::::::用于地籍服务的面板', 'c');
INSERT INTO panel_launcher_group (code, display_value, description, status) VALUES ('propertyServices', 'Property Services::::::::خدمات  الأملاك::::::::Servicios de propiedad::::::::Property Services::::::::财产服务', 'Panels used for property services::::::::لوحة تستخدم لخدمات الاملاك::::::::Paneles usados por los servicios de propiedad::::::::Panels used for property services::::::::用于财产服务的面板', 'c');
INSERT INTO panel_launcher_group (code, display_value, description, status) VALUES ('newPropServices', 'New Property Services::::::::خدمات ملكية جديدة::::::::Nuevos Servicios de Propiedad::::::::New Property Services::::::::新的财产服务', 'Panels used for new property services::::::::لوحة تستخدم لخدمات ملكيات جديدة ::::::::Paneles usados por los nuevos servicios de propiedad::::::::Panels used for new property services::::::::用于新的财产服务的面板', 'c');
INSERT INTO panel_launcher_group (code, display_value, description, status) VALUES ('generalRRR', 'General RRR::::::::  (الحقوق , القيود , )::::::::General RRR::::::::General RRR::::::::普通 RRR', 'Panels used for general RRRs::::::::لوحة تستخدم لخدمات الحقوق العامة::::::::Paneles usados por General RRRs::::::::Panels used for general RRRs::::::::用于普通权利限制与责任的面板', 'c');
INSERT INTO panel_launcher_group (code, display_value, description, status) VALUES ('leaseRRR', 'Lease RRR::::::::أيجار RRR::::::::Arrendamiento RRR::::::::Lease RRR::::::::租赁权利限制域责任', 'Panels used for Lease RRR::::::::لوحة تستخدم لخدمات  حقوق الأيجار::::::::Paneles usados por Arrendamiento RRR::::::::Panels used for Lease RRR::::::::用于租赁权利限制与责任的面板', 'c');


ALTER TABLE panel_launcher_group ENABLE TRIGGER ALL;

--
-- Data for Name: config_panel_launcher; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE config_panel_launcher DISABLE TRIGGER ALL;

INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('partySearch', 'Party Search Panel::::::::::::::::::::::::Party Search Panel::::::::', '', 'c', 'nullConstructor', 'org.sola.clients.swing.desktop.party.PartySearchPanelForm', 'cliprgs008', 'searchPersons');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('cancelRelationship', 'Cancel Relationship::::::::الغاء الصلة::::::::::::::::Cancelar Relacionamento::::::::取消关系', '', 'c', 'cancelRelationship', 'org.sola.clients.swing.desktop.administrative.CancelPersonRelationshipPanel', 'cliprgs009', 'cancelRelationship');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('recordRelationship', 'Record Relationship::::::::تسجيل العلاقة::::::::::::::::Cadastrar Relacionamento::::::::记录关系', '', 'c', 'recordRelationship', 'org.sola.clients.swing.desktop.administrative.RecordPersonRelationshipPanel', 'cliprgs009', 'recordRelationship');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('documentTrans', 'Document Transaction Panel::::::::لوحة حركات الوثيقة::::::::Panel de Transacción de Documentos::::::::Document Transaction Panel::::::::文件交易面板', '', 'c', 'documentServices', 'org.sola.clients.swing.desktop.source.TransactionedDocumentsPanel', 'cliprgs016', 'transactionedDocumentPanel');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('documentSearch', 'Document Search Panel::::::::لوحة البحث عن الوثائق::::::::Panel de Busqueda de Documentos::::::::Document Search Panel::::::::文档搜索面板', '', 'c', 'nullConstructor', 'org.sola.clients.swing.desktop.source.DocumentSearchForm', 'cliprgs007', 'documentsearch');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('map', 'Map Panel::::::::لوحة الخارطة::::::::Panel de Mapas::::::::Map Panel::::::::地图面板', '', 'c', 'nullConstructor', 'org.sola.clients.swing.desktop.cadastre.MapPanelForm', 'cliprgs004', 'map');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('applicationSearch', 'Application Search Panel::::::::لوحة البحث عن طلب::::::::Panel de Busqueda de Aplicaciones::::::::Application Search Panel::::::::申请搜索面板', '', 'c', 'nullConstructor', 'org.sola.clients.swing.desktop.application.ApplicationSearchPanel', 'cliprgs003', 'appsearch');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('cadastreTransMap', 'Cadastre Transaction Map Panel::::::::لوحة حركات خارطة المساحة::::::::Panel de Mapas de Transacciones Catastrales::::::::Cadastre Transaction Map Panel::::::::地籍交易图面板', '', 'c', 'cadastreServices', 'org.sola.clients.swing.desktop.cadastre.CadastreTransactionMapPanel', 'cliprgs017', 'cadastreChange');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('property', 'Property Panel::::::::لوحة الملكيات::::::::Panel de Propiedades::::::::Property Panel::::::::财产面板', '', 'c', 'propertyServices', 'org.sola.clients.swing.desktop.administrative.PropertyPanel', 'cliprgs009', 'propertyPanel');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('newProperty', 'New Property Panel::::::::لوحة ملكية جديدة::::::::Nuevo Panel de Propiedades::::::::New Property Panel::::::::新的财产面板', '', 'c', 'newPropServices', 'org.sola.clients.swing.desktop.administrative.PropertyPanel', 'cliprgs009', 'propertyPanel');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('propertySearch', 'Property Search Panel::::::::لوحة البحث عن ملكية::::::::Panel de Busqueda de Propiedades::::::::Property Search Panel::::::::财产搜索面板', '', 'c', 'nullConstructor', 'org.sola.clients.swing.desktop.administrative.BaUnitSearchPanel', 'cliprgs006', 'baunitsearch');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('simpleRight', 'Simple Right Panel::::::::لوحة الحق البسيط::::::::Panel de Derechos Simples::::::::Simple Right Panel::::::::简单的权利面板', '', 'c', 'generalRRR', 'org.sola.clients.swing.desktop.administrative.SimpleRightPanel', NULL, 'simpleRightPanel');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('simpleRightholder', 'Simple Rightholder Panel::::::::لوحة أصحاب الحق البسيط::::::::Panel Titular del derecho simple::::::::Simple Rightholder Panel::::::::简单的权利所有者面板', '', 'c', 'generalRRR', 'org.sola.clients.swing.desktop.administrative.SimpleRightholderPanel', NULL, 'simpleOwnershipPanel');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('mortgage', 'Mortgage Panel::::::::لوحة الرهن::::::::Panel de Hipotecas::::::::Mortgage Panel::::::::抵押面板', '', 'c', 'generalRRR', 'org.sola.clients.swing.desktop.administrative.MortgagePanel', NULL, 'mortgagePanel');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('lease', 'Lease Panel::::::::لوحة الأيجار::::::::Panel de Arrendamientos::::::::Lease Panel::::::::租赁面板', '', 'c', 'leaseRRR', 'org.sola.clients.swing.desktop.administrative.LeasePanel', NULL, 'leasePanel');
INSERT INTO config_panel_launcher (code, display_value, description, status, launch_group, panel_class, message_code, card_name) VALUES ('ownership', 'Ownership Share Panel::::::::لوحة ملكية الحصص::::::::Panel de propiedades participativas::::::::Ownership Share Panel::::::::所有权共享面板', '', 'c', 'generalRRR', 'org.sola.clients.swing.desktop.administrative.OwnershipPanel', NULL, 'ownershipPanel');


ALTER TABLE config_panel_launcher ENABLE TRIGGER ALL;

--
-- Data for Name: consolidation_config; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE consolidation_config DISABLE TRIGGER ALL;

INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application', 'application', 'application', 'Applications that have the status = “to-be-transferred”.', 'status_code = ''to-be-transferred'' and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.application'')', false, 1, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.service', 'application', 'service', 'Every service that belongs to the application being selected for transfer.', 'application_id in (select id from consolidation.application) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.service'')', false, 2, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('transaction.transaction', 'transaction', 'transaction', 'Every record that references a record in consolidation.service.', 'from_service_id in (select id from consolidation.service) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''transaction.transaction'')', false, 3, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('transaction.transaction_source', 'transaction', 'transaction_source', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''transaction.transaction_source'')', false, 4, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_target', 'cadastre', 'cadastre_object_target', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.cadastre_object_target'')', false, 5, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_node_target', 'cadastre', 'cadastre_object_node_target', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.cadastre_object_node_target'')', false, 6, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_uses_source', 'application', 'application_uses_source', 'Every record that belongs to the application being selected for transfer.', 'application_id in (select id from consolidation.application) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.application_uses_source'')', false, 7, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_property', 'application', 'application_property', 'Every record that belongs to the application being selected for transfer.', 'application_id in (select id from consolidation.application) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.application_property'')', false, 8, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_spatial_unit', 'application', 'application_spatial_unit', 'Every record that belongs to the application being selected for transfer.', 'application_id in (select id from consolidation.application) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.application_spatial_unit'')', false, 9, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit', 'cadastre', 'spatial_unit', 'Every record that is referenced from application_spatial_unit or that is a targeted from a service already extracted or created from a service already extracted in consolidation schema.', '(id in (select spatial_unit_id from consolidation.application_spatial_unit) 
or id in (select id from cadastre.cadastre_object where transaction_id in (select id from consolidation.transaction))
or id in (select cadastre_object_id from consolidation.cadastre_object_target)
) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.spatial_unit'')', false, 10, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_in_group', 'cadastre', 'spatial_unit_in_group', 'Every record that references a record in consolidation.spatial_unit', 'spatial_unit_id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.spatial_unit_in_group'')', false, 11, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.cadastre_object', 'cadastre', 'cadastre_object', 'Every record that is also in consolidation.spatial_unit', 'id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.cadastre_object'')', false, 12, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_address', 'cadastre', 'spatial_unit_address', 'Every record that references a record in consolidation.spatial_unit.', 'spatial_unit_id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.spatial_unit_address'')', false, 13, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_value_area', 'cadastre', 'spatial_value_area', 'Every record that references a record in consolidation.spatial_unit.', 'spatial_unit_id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.spatial_value_area'')', false, 14, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.survey_point', 'cadastre', 'survey_point', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.survey_point'')', false, 15, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.legal_space_utility_network', 'cadastre', 'legal_space_utility_network', 'Every record that is also in consolidation.spatial_unit', 'id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.legal_space_utility_network'')', false, 16, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_group', 'cadastre', 'spatial_unit_group', 'Every record', NULL, true, 17, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_contains_spatial_unit', 'administrative', 'ba_unit_contains_spatial_unit', 'Every record that references a record in consolidation.cadastre_object.', 'spatial_unit_id in (select id from consolidation.cadastre_object) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit_contains_spatial_unit'')', false, 18, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.source_historic', 'source', 'source_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.source)', true, 43, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_target', 'administrative', 'ba_unit_target', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit_target'')', false, 19, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit', 'administrative', 'ba_unit', 'Every record that is referenced by consolidation.application_property or consolidation.ba_unit_contains_spatial_unit or consolidation.ba_unit_target.', '(id in (select ba_unit_id from consolidation.application_property) or id in (select ba_unit_id from consolidation.ba_unit_contains_spatial_unit) or id in (select ba_unit_id from consolidation.ba_unit_target)) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit'')', false, 20, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.required_relationship_baunit', 'administrative', 'required_relationship_baunit', 'Every record that references a record in consolidation.ba_unit.', 'from_ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.required_relationship_baunit'')', false, 21, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_area', 'administrative', 'ba_unit_area', 'Every record that references a record in consolidation.ba_unit.', 'ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit_area'')', false, 22, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_as_party', 'administrative', 'ba_unit_as_party', 'Every record that references a record in consolidation.ba_unit.', 'ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit_as_party'')', false, 23, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.source_describes_ba_unit', 'administrative', 'source_describes_ba_unit', 'Every record that references a record in consolidation.ba_unit.', 'ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.source_describes_ba_unit'')', false, 24, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.rrr', 'administrative', 'rrr', 'Every record that references a record in consolidation.ba_unit.', 'ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.rrr'')', false, 25, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.rrr_share', 'administrative', 'rrr_share', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.rrr_share'')', false, 26, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.party_for_rrr', 'administrative', 'party_for_rrr', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.party_for_rrr'')', false, 27, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.condition_for_rrr', 'administrative', 'condition_for_rrr', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.condition_for_rrr'')', false, 28, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.mortgage_isbased_in_rrr', 'administrative', 'mortgage_isbased_in_rrr', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.mortgage_isbased_in_rrr'')', false, 29, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.source_describes_rrr', 'administrative', 'source_describes_rrr', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.source_describes_rrr'')', false, 30, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.notation', 'administrative', 'notation', 'Every record that references a record in consolidation.ba_unit or consolidation.rrr or consolidation.transaction.', '(ba_unit_id in (select id from consolidation.ba_unit) or rrr_id in (select id from consolidation.rrr) or transaction_id in (select id from consolidation.transaction)) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.notation'')', false, 31, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.source', 'source', 'source', 'Every source that is referenced from the consolidation.application_uses_source 
or consolidation.transaction_source
or source that references consolidation.transaction or source that is referenced from consolidation.source_describes_ba_unit or source that is referenced from consolidation.source_describes_rrr.', 'id in (select source_id from consolidation.application_uses_source)
or id in (select source_id from consolidation.transaction_source)
or transaction_id in (select id from consolidation.transaction)
or id in (select source_id from consolidation.source_describes_ba_unit)
or id in (select source_id from consolidation.source_describes_rrr) ', true, 32, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.power_of_attorney', 'source', 'power_of_attorney', 'Every record that is also in consolidation.source.', 'id in (select id from consolidation.source)', true, 33, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.spatial_source', 'source', 'spatial_source', 'Every record that is also in consolidation.source.', 'id in (select id from consolidation.source)', true, 34, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.spatial_source_measurement', 'source', 'spatial_source_measurement', 'Every record that references a record in consolidation.spatial_source.', 'spatial_source_id in (select id from consolidation.spatial_source)', true, 35, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.archive', 'source', 'archive', 'Every record that is referenced from a record in consolidation.source.', 'id in (select archive_id from consolidation.source) ', true, 36, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('document.document', 'document', 'document', 'Every record that is referenced by consolidation.source.', 'id in (select ext_archive_id from consolidation.source)', true, 37, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.party', 'party', 'party', 'Every record that is referenced by consolidation.application or consolidation.ba_unit_as_party or consolidation.party_for_rrr.', 'id in (select agent_id from consolidation.application) or id in (select contact_person_id from consolidation.application) or id in (select agent_id from consolidation.application) or id in (select party_id from consolidation.party_for_rrr) or id in (select party_id from consolidation.ba_unit_as_party)', true, 38, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.group_party', 'party', 'group_party', 'Every record that is also in consolidation.party.', 'id in (select id from consolidation.party)', true, 39, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.party_member', 'party', 'party_member', 'Every record that references a record in consolidation.party.', 'party_id in (select id from consolidation.party)', true, 40, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.party_role', 'party', 'party_role', 'Every record that references a record in consolidation.party.', 'party_id in (select id from consolidation.party)', true, 41, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('address.address', 'address', 'address', 'Every record that is referenced by consolidation.party or consolidation.spatial_unit_address.', 'id in (select address_id from consolidation.party) or id in (select address_id from consolidation.spatial_unit_address)', true, 42, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.survey_point_historic', 'cadastre', 'survey_point_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.survey_point)', false, 44, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_value_area_historic', 'cadastre', 'spatial_value_area_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_value_area)', false, 45, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_address_historic', 'cadastre', 'spatial_unit_address_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_unit_address)', false, 46, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.spatial_source_measurement_historic', 'source', 'spatial_source_measurement_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_source_measurement)', false, 47, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.spatial_source_historic', 'source', 'spatial_source_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_source)', true, 48, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.source_describes_rrr_historic', 'administrative', 'source_describes_rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.source_describes_rrr)', false, 49, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.rrr_historic', 'administrative', 'rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.rrr)', false, 50, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.required_relationship_baunit_historic', 'administrative', 'required_relationship_baunit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.required_relationship_baunit)', false, 51, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.power_of_attorney_historic', 'source', 'power_of_attorney_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.power_of_attorney)', true, 52, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.party_role_historic', 'party', 'party_role_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.party_role)', true, 53, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.party_member_historic', 'party', 'party_member_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.party_member)', true, 54, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.party_for_rrr_historic', 'administrative', 'party_for_rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.party_for_rrr)', false, 55, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.legal_space_utility_network_historic', 'cadastre', 'legal_space_utility_network_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.legal_space_utility_network)', false, 56, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.group_party_historic', 'party', 'group_party_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.group_party)', true, 57, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.condition_for_rrr_historic', 'administrative', 'condition_for_rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.condition_for_rrr)', false, 58, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_historic', 'cadastre', 'cadastre_object_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.cadastre_object)', false, 59, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_target_historic', 'administrative', 'ba_unit_target_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.ba_unit_target)', false, 60, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_contains_spatial_unit_historic', 'administrative', 'ba_unit_contains_spatial_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.ba_unit_contains_spatial_unit)', false, 61, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_area_historic', 'administrative', 'ba_unit_area_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.ba_unit_area)', false, 62, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.archive_historic', 'source', 'archive_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.archive)', true, 63, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_property_historic', 'application', 'application_property_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.application_property)', false, 64, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_historic', 'application', 'application_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.application)', false, 65, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('transaction.transaction_source_historic', 'transaction', 'transaction_source_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.transaction_source)', false, 66, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('transaction.transaction_historic', 'transaction', 'transaction_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.transaction)', false, 67, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_in_group_historic', 'cadastre', 'spatial_unit_in_group_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_unit_in_group)', false, 68, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_group_historic', 'cadastre', 'spatial_unit_group_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_unit_group)', false, 69, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_historic', 'cadastre', 'spatial_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_unit)', false, 70, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.source_describes_ba_unit_historic', 'administrative', 'source_describes_ba_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.source_describes_ba_unit)', false, 71, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.service_historic', 'application', 'service_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.service)', false, 72, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.rrr_share_historic', 'administrative', 'rrr_share_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.rrr_share)', false, 73, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.party_historic', 'party', 'party_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.party)', true, 74, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.notation_historic', 'administrative', 'notation_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.notation)', false, 75, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.mortgage_isbased_in_rrr_historic', 'administrative', 'mortgage_isbased_in_rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.mortgage_isbased_in_rrr)', false, 76, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('document.document_historic', 'document', 'document_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.document)', true, 77, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_target_historic', 'cadastre', 'cadastre_object_target_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.cadastre_object_target)', false, 78, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_node_target_historic', 'cadastre', 'cadastre_object_node_target_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.cadastre_object_node_target)', false, 79, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_historic', 'administrative', 'ba_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.ba_unit)', false, 80, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_uses_source_historic', 'application', 'application_uses_source_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.application_uses_source)', false, 81, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_spatial_unit_historic', 'application', 'application_spatial_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.application_spatial_unit)', false, 82, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('address.address_historic', 'address', 'address_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.address)', false, 83, false);


ALTER TABLE consolidation_config ENABLE TRIGGER ALL;

--
-- Data for Name: crs; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE crs DISABLE TRIGGER ALL;

INSERT INTO crs (srid, from_long, to_long, item_order) VALUES (2193, 0, 171805.08555444199, 1);


ALTER TABLE crs ENABLE TRIGGER ALL;

--
-- Data for Name: map_search_option; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE map_search_option DISABLE TRIGGER ALL;

INSERT INTO map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description) VALUES ('NUMBER', 'Number', 'map_search.cadastre_object_by_number', true, 3, 50.00, NULL);
INSERT INTO map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description) VALUES ('BAUNIT', 'Property number', 'map_search.cadastre_object_by_baunit', true, 3, 50.00, NULL);
INSERT INTO map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description) VALUES ('OWNER_OF_BAUNIT', 'Property owner', 'map_search.cadastre_object_by_baunit_owner', true, 3, 50.00, NULL);
INSERT INTO map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description) VALUES ('LOCALITY', 'Locality', 'map_search.locality', true, 3, 100.00, NULL);


ALTER TABLE map_search_option ENABLE TRIGGER ALL;

--
-- Data for Name: query_field; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE query_field DISABLE TRIGGER ALL;

INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel', 1, 'parcel_nr', 'Parcel number::::Numero Particella');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel', 2, 'ba_units', 'Properties::::Proprieta');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel', 3, 'area_official_sqm', 'Official area (m2)::::Area ufficiale (m2)');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel', 4, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_pending', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_pending', 1, 'parcel_nr', 'Parcel number::::Numero Particella');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_pending', 2, 'area_official_sqm', 'Official area (m2)::::Area ufficiale (m2)');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_pending', 3, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_place_name', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_place_name', 1, 'label', 'Name::::Nome');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_place_name', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_road', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_road', 1, 'label', 'Name::::Nome');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_road', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_application', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_application', 1, 'nr', 'Number::::Numero');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_application', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_survey_control', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_survey_control', 1, 'label', 'Label::::Etichetta');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_survey_control', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 1, 'parcel_nr', 'Parcel number::::Numero Particella');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 2, 'ba_units', 'Properties::::Proprieta');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 3, 'area_official_sqm', 'Official area (m2)::::Area ufficiale (m2)');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 4, 'the_geom', NULL);


ALTER TABLE query_field ENABLE TRIGGER ALL;

--
-- Data for Name: setting; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE setting DISABLE TRIGGER ALL;

INSERT INTO setting (name, vl, active, description) VALUES ('system-id', '', true, 'A unique number that identifies the installed SOLA system. This unique number is used in the br that generate unique identifiers.');
INSERT INTO setting (name, vl, active, description) VALUES ('max-file-size', '10000', true, 'Maximum file size in KB for uploading.');
INSERT INTO setting (name, vl, active, description) VALUES ('max-uploading-daily-limit', '100000', true, 'Maximum size of files uploaded daily.');
INSERT INTO setting (name, vl, active, description) VALUES ('moderation-days', '30', true, 'Duration of moderation time in days');
INSERT INTO setting (name, vl, active, description) VALUES ('email-admin-address', '', true, 'Email address of server administrator. If empty, no notifications will be sent');
INSERT INTO setting (name, vl, active, description) VALUES ('email-admin-name', '', true, 'Name of server administrator');
INSERT INTO setting (name, vl, active, description) VALUES ('email-body-format', 'html', true, 'Message body format. text - for simple text format, html - for html format');
INSERT INTO setting (name, vl, active, description) VALUES ('email-send-interval1', '1', true, 'Time interval in minutes for the first attempt to send email message.');
INSERT INTO setting (name, vl, active, description) VALUES ('email-send-attempts1', '2', true, 'Number of attempts to send email with first interval');
INSERT INTO setting (name, vl, active, description) VALUES ('email-send-interval2', '120', true, 'Time interval in minutes for the second attempt to send email message.');
INSERT INTO setting (name, vl, active, description) VALUES ('email-send-attempts2', '2', true, 'Number of attempts to send email with second interval');
INSERT INTO setting (name, vl, active, description) VALUES ('email-send-interval3', '1440', true, 'Time interval in minutes for the third attempt to send email message.');
INSERT INTO setting (name, vl, active, description) VALUES ('email-send-attempts3', '1', true, 'Number of attempts to send email with third interval');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-user-registration-subject', 'New user registration', true, 'Subject text for new user registration on OpenTenure Web-site. Sent to administrator.');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-user-registration-body', 'New user "#{userName}" has been registered registered on SOLA OpenTenure Web-site.', true, 'Message text for new user registration on OpenTenure Web-site');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-failed-send-subject', 'Delivery failure', true, 'Subject text for delivery failure of message');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-failed-send-body', 'Message send to the user #{userName} has been failed to deliver after number of attempts with the following error: <br/>#{error}', true, 'Message text for delivery failure');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-reg-subject', 'SOLA OpenTenure - registration', true, 'Subject text for new user registration on OpenTenure Web-site. Sent to user.');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-pswd-restore-subject', 'SOLA OpenTenure - password restore', true, 'Password restore subject');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-submit-subject', 'SOLA OpenTenure - new claim submitted', true, 'New claim subject text');
INSERT INTO setting (name, vl, active, description) VALUES ('account-activation-timeout', '70', true, 'Account activation timeout in hours. After this time, activation should expire.');
INSERT INTO setting (name, vl, active, description) VALUES ('email-service-interval', '10', true, 'Time interval in seconds for email service to check and process scheduled messages.');
INSERT INTO setting (name, vl, active, description) VALUES ('pword-expiry-days', '90', false, 'The number of days a users password remains valid');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-pswd-restore-body', 'Dear #{userFullName},<br /><br />You have requested to restore the password. If you didn''t ask for this action, just ignore this message. Otherwise, follow <a href="#{passwordRestoreLink}">this link</a> to reset your password.<br /><br />Regards,<br />SOLA OpenTenure Team', true, 'Message text for password restore');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-withdraw-body', 'Dear #{userFirstName},<br /><br />
Claim <a href="#{claimLink}"><b>##{claimNumber}</b></a> has been withdrawn by community recorder.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', true, 'Claim withdrawal notice body');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-withdraw-subject', 'SOLA OpenTenure - claim withdrawal', true, 'Claim withdrawal notice subject');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-submit-body', 'Dear #{userFullName},<br /><br />
New claim <b>##{claimNumber}</b> has been submitted. 
You can follow its status by <a href="#{claimLink}">this address</a>.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', true, 'New claim body text');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-reject-subject', 'SOLA OpenTenure - claim rejection', true, 'Claim rejection notice subject');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-approve-review-body', 'Dear #{userFirstName},<br /><br />
Claim <a href="#{claimLink}"><b>##{claimNumber}</b></a> has passed review stage with success.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', true, 'Claim review approval notice body');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-approve-review-subject', 'SOLA OpenTenure - claim review approval', true, 'Claim review approval notice subject');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-approve-moderation-body', 'Dear #{userFirstName},<br /><br />
Claim <a href="#{claimLink}"><b>##{claimNumber}</b></a> has been approved.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', true, 'Claim moderation approval notice body');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-approve-moderation-subject', 'SOLA OpenTenure - claim moderation approval', true, 'Claim moderation approval notice subject');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-updated-body', 'Dear #{userFullName},<br /><br />Claim <b>##{claimNumber}</b> has been updated. Follow <a href="#{claimLink}">this link</a> to check claim status and updated information.<br /><br />Regards,<br />SOLA OpenTenure Team', true, 'Claim update body text');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-challenge-submitted-body', 'Dear #{userFullName},<br /><br />
New claim challenge <a href="#{challengeLink}"><b>##{challengeNumber}</b></a> has been submitted 
to challenge the claim <a href="#{claimLink}"><b>##{claimNumber}</b></a>.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', true, 'New claim challenge body text');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-challenge-updated-body', 'Dear #{userFullName},<br /><br />
Claim challenge <b>##{challengeNumber}</b> has been updated. 
Follow <a href="#{challengeLink}">this link</a> to check updated information.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', true, 'Claim challenge update body text');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-challenge-submitted-subject', 'SOLA OpenTenure - new claim challenge to the claim ##{claimNumber}', true, 'New claim challenge subject text');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-challenge-updated-subject', 'SOLA OpenTenure - claim challenge ##{challengeNumber} update', true, 'Claim challenge update subject text');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-updated-subject', 'SOLA OpenTenure - claim ##{claimNumber} update', true, 'Claim update subject text');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-challenge-approve-review-body', 'Dear #{userFirstName},<br /><br />
Claim challenge <a href="#{challengeLink}"><b>##{challengeNumber}</b></a> has passed review stage.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', true, 'Claim challenge review approval notice body');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-challenge-approve-review-subject', 'SOLA OpenTenure - claim challenge review', true, 'Claim challenge review approval notice subject');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-challenge-approve-moderation-body', 'Dear #{userFirstName},<br /><br />
Claim challenge <a href="#{challengeLink}"><b>##{challengeNumber}</b></a> has been moderated.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', true, 'Claim challenge moderation approval notice body');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-challenge-approve-moderation-subj', 'SOLA OpenTenure - claim challenge moderation', true, 'Claim challenge moderation approval notice subject');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-reject-body', 'Dear #{userFirstName},<br /><br />
Claim <a href="#{claimLink}"><b>##{claimNumber}</b></a> has been rejected with the following reason:<br /><br />
<i>"#{claimRejectionReason}"</i><br /> <br /> 
The following comments were recorded on the claim:<br />#{claimComments}<br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', true, 'Claim rejection notice body');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-challenge-reject-body', 'Dear #{userFirstName},<br /><br />
Claim challenge <a href="#{challengeLink}"><b>##{challengeNumber}</b></a> has been rejected with the following reason:<br /><br />
<i>"#{challengeRejectionReason}"</i><br /> <br />
Claim challenge comments:<br />#{challengeComments}<br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', true, 'Claim challenge rejection notice body');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-challenge-reject-subject', 'SOLA OpenTenure - claim challenge rejection', true, 'Claim challenge rejection notice subject');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-challenge-withdraw-body', 'Dear #{userFirstName},<br /><br />
Claim challenge <a href="#{challengeLink}"><b>##{challengeNumber}</b></a> has been withdrawn by community recorder.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', true, 'Claim challenge withdrawal notice body');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-claim-challenge-withdraw-subject', 'SOLA OpenTenure - claim challenge withdrawal', true, 'Claim withdrawal notice subject');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-notifiable-submit-body', 'Dear #{notifiablePartyName},<p></p> this is to inform you that one <b>#{actionToNotify}</b> action has been requested 
				<br>by <b>#{targetPartyName}</b> 
				<br>on the following property: <b>#{baUnitName}</b>. <p></p><p></p>Regards,<br />#{sendingOffice}', true, 'Action on Interest body text');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-notifiable-subject', 'SOLA REGISTRY - #{actionToNotify} action on property #{baUnitName}', true, 'Action on Interest subject text');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-user-activation-body', 'Dear #{userFullName},<p></p>Your account has been activated. 
<p></p>Please use <b>#{userName}</b> to login.<p></p><p></p>Regards,<br />SOLA OpenTenure Team', true, 'Message text to notify Community member account activation on the Community Server Web-site');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-user-activation-subject', 'SOLA OpenTenure account activation', true, 'Subject text to notify Community member account activation on the Community Server Web-site');
INSERT INTO setting (name, vl, active, description) VALUES ('email-msg-reg-body', 'Dear #{userFullName},<p></p>You have registered on SOLA OpenTenure Web-site. Before you can use your account, it will be reviewed and approved by Community Technologist. 
Upon account approval, you will receive notification message.<p></p>Your user name is<br />#{userName}<p></p><p></p>Regards,<br />SOLA OpenTenure Team', true, 'Message text for new user registration on OpenTenure Web-site. Sent to user.');
INSERT INTO setting (name, vl, active, description) VALUES ('email-mailer-jndi-name', 'mail/sola', true, 'Configured mailer service JNDI name');
INSERT INTO setting (name, vl, active, description) VALUES ('product-name', 'SOLA Community Server', true, 'SOLA product name');
INSERT INTO setting (name, vl, active, description) VALUES ('product-code', 'scs', true, 'SOLA product code. sr - SOLA Registry, ssr - SOLA Systematic Registration, ssl - SOLA State Land, scs - SOLA Community Server');
INSERT INTO setting (name, vl, active, description) VALUES ('moderation_date', '2015-01-01', true, 'Closing date of public display for the claims. Date must be set in the format "yyyy-mm-dd". If date is not set or in the past, "moderation-days" setting will be used for calculating closing date.');
INSERT INTO setting (name, vl, active, description) VALUES ('requires_spatial', '0', true, 'Indicates whether spatial representation of the parcel is required (mandatory). If values is 0, spatial part can be omitted, otherwise validation will request it.');
INSERT INTO setting (name, vl, active, description) VALUES ('report_server_user', 'jasperadmin', true, 'Reporting server user name.');
INSERT INTO setting (name, vl, active, description) VALUES ('report_server_pass', 'jasperadmin', true, 'Reporting server user password.');
INSERT INTO setting (name, vl, active, description) VALUES ('report_server_url', 'http://localhost:8080/jasperserver', true, 'Reporting server URL.');
INSERT INTO setting (name, vl, active, description) VALUES ('community-name', 'Open Community', true, 'Community name');
INSERT INTO setting (name, vl, active, description) VALUES ('ot-title-plan-crs-wkt', '', true, 'Custom Coordinate Reference System in WKT format of the map image, generated for claim certificate in OpenTenure');
INSERT INTO setting (name, vl, active, description) VALUES ('offline-mode', '0', true, 'Indicates whether Community Server is connected to the Internet or not. 0 - connected, 1 - not connected');
INSERT INTO setting (name, vl, active, description) VALUES ('docs_for_issuing_cert', 'signed_cert', true, 'List of document type codes, required to set certificate issued status');
INSERT INTO setting (name, vl, active, description) VALUES ('reports_folder_url', '/reports/community_server', true, 'Folder URL on the reporting server containing reports to display on the menu.');
INSERT INTO setting (name, vl, active, description) VALUES ('email-enable-email-service', '0', true, 'Enables or disables email service. 1 - enable, 0 - disable');
INSERT INTO setting (name, vl, active, description) VALUES ('claim_certificate_report_url', '/reports/cert/Claim_certificate', true, '	URL to the claim certificate report, hosted on the reporting server');
INSERT INTO setting (name, vl, active, description) VALUES ('enable-reports', '0', true, 'Indicates whether reports are enbled or disabled. 1 - enabled, 0 - disabled');
INSERT INTO setting (name, vl, active, description) VALUES ('db-utilities-folder', 'C:\Program Files\PostgreSQL\9.5\bin', true, 'Full path to PostgreSQL utilities (bin) folder (e.g. C:\Program Files\PostgreSQL\9.1\bin). Used for backup/restore implementation of SOLA Web admin application');
INSERT INTO setting (name, vl, active, description) VALUES ('ot-community-area', 'POLYGON((-12.209399245759217 8.646044458409799,-11.991389297028434 8.647741560571333,-11.99310591079809 8.499725679896729,-12.211802505036012 8.49938612785351,-12.209399245759217 8.646044458409799))', true, 'Open Tenure community area where parcels can be claimed');
INSERT INTO setting (name, vl, active, description) VALUES ('boundary-print-crs-description', 'Unit: degree<br>Geodetic CRS: WGS 84<br>Datum: World Geodetic System 1984<br>Ellipsoid: WGS 84<br>Prime meridian: Greenwich', true, 'Description of Coordinate Reference System, which will be listed in the legend area.');
INSERT INTO setting (name, vl, active, description) VALUES ('boundary-print-produced-by', 'Community Server of OpenTenure solution', true, 'Name of report producer. In real environment can be Ministry''s name.');
INSERT INTO setting (name, vl, active, description) VALUES ('boundary-print-country-name', '', true, 'Country name for adding at the end of the boundary location description');
INSERT INTO setting (name, vl, active, description) VALUES ('ot-title-plan-crs-proj4', '', true, 'Custom Coordinate Reference System in Proj4 format, used for generating map image for claim certificate or boundary in OpenTenure. It should match to ot-title-plan-crs-wkt setting. If not provided, WGS84 will be used as default.');


ALTER TABLE setting ENABLE TRIGGER ALL;

--
-- Data for Name: version; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE version DISABLE TRIGGER ALL;

INSERT INTO version (version_num) VALUES ('1504a');
INSERT INTO version (version_num) VALUES ('1506a');
INSERT INTO version (version_num) VALUES ('1507a');
INSERT INTO version (version_num) VALUES ('1507b');
INSERT INTO version (version_num) VALUES ('1508a');
INSERT INTO version (version_num) VALUES ('1508b');
INSERT INTO version (version_num) VALUES ('1511a');
INSERT INTO version (version_num) VALUES ('1512a');
INSERT INTO version (version_num) VALUES ('1606a');
INSERT INTO version (version_num) VALUES ('1712a');
INSERT INTO version (version_num) VALUES ('1709a');
INSERT INTO version (version_num) VALUES ('1708a');
INSERT INTO version (version_num) VALUES ('1805a');


ALTER TABLE version ENABLE TRIGGER ALL;

--
-- PostgreSQL database dump complete
--

