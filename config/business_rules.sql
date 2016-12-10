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
-- Data for Name: br; Type: TABLE DATA; Schema: system; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE br DISABLE TRIGGER ALL;

INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-rrr-nr', 'generate-rrr-nr', 'sql', '', NULL, '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-baunit-nr', 'generate-baunit-nr', 'sql', '', NULL, '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-cadastre-object-firstpart', 'generate-cadastre-object-firstpart', 'sql', '', NULL, 'It accepts parameters #{last_part} = The last part of the identifier and #{cadastre_object_type} = The type of the cadastre object.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-application-nr', 'generate-application-nr', 'sql', '...::::::::...::::::::...::::::::...::::::::...', NULL, '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br8-check-has-services', 'application-br8-check-has-services', 'sql', 'An application must have at least one service::::Заявление должно иметь хотя бы одну услугу.::::الطلب يجب ان يحتوي على خدمة واحدة على الاقل.::::La demande doit contenir au moins un service::::Una aplicación debe tener por lo menos un servicio::::::::O pedido deve ter pelo menos um serviço::::::::每项申请必须提供至少一次服务', NULL, 'Checks that an application has at least one service. When this rule fails you should add a service to the application or cancel the application.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-on-approve-check-services-status', 'application-on-approve-check-services-status', 'sql', 'All services in the application must have the status ''cancelled'' or ''completed''.::::Все услуги в заявлении должны иметь статус ''Отменен'' или ''Завершен''.::::جميع الخدمات في الطلب ايجب ان تكون حالتها : مكتملة  أو  ملغاة::::Tous les services de la demande doivent avoir le statut "annulé" ou "exécuté".::::Todos los servicios de la solicitud debe tener el estado "Cancelado" o "terminado".::::::::Todos os serviços do pedido devem ter o estado "cancelado" ou "concluído".::::::::申请中的所有服务必须处于“被取消”或“已完成”状态。', NULL, 'Checks the service.status_code for all instances of service related to the application');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-on-approve-check-systematic-reg-no-objection', 'application-on-approve-check-systematic-reg-no-objection', 'sql', 'There must be no objection against the systematic registration::::Не должно быть каких-либо обжалований по системной регистрации.::::يجب ان لا يوجد اعتراض على التسجيل المنتظم::::Il ne doit pas y avoir d''objection à l''enregistrement systématique.::::No debe haber ninguna objeción contra el registro sistemático::::::::Não deve haver nenhuma objeção no registro regular::::::::针对系统登记不得有异议。', NULL, 'Checks the absence of objections for systematic registration service related to the application');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('bulk-spatial-geom-not-valid', 'bulk-spatial-geom-not-valid', 'sql', 'Cadastre objects must have a valid closed polygon. ::::Кадастровые объекты должны иметь корректный завершенный полигон.::::كينونات المساحة يجب ان يكون لها مضلع مغلق::::::::Los objetos de Catastro deben tener un polígono cerrado válida.::::::::Objetos de cadastro devem ter um polígono fechado válido.::::::::地籍目标必须是一个有效的封闭多边形。', NULL, '#{id}(transaction_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('power-of-attorney-owner-check', 'power-of-attorney-owner-check', 'sql', 'Name of person identified in Power of Attorney should match a (one of the) current owner(s)::::Имя лица указанного в доверенности должно совпадать с именем одного из владельцев.::::الاسم المحدد في الوكالة يجب ان يطابق احد اسماء المالكين::::Le nom de la personne identifiée dans la procuration doit correspondre à un des propriétaires actuels.::::Nombre de la persona identificada en poder notarial debe coincidir con una (uno de los) propietario actual (es)::::::::Nome da pessoa identificada na Procuração deve corresponder ao (um dos) atual proprietário(s)::::::::委托书中证明人的姓名应和现有所有权人相配。', NULL, '#{id}(application.service.id)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('power-of-attorney-service-has-document', 'power-of-attorney-service-has-document', 'sql', 'Service ''req_type'' must have must have one associated Power of Attorney document::::Услуга ''req_type''  должна иметь одну доверенность.::::خدمة ''req_type'' يجب ان ترتبط بوكالة::::Le service ''req_type'' doit avoir un document de procuration associé.::::Servicio ''req_type'' debe tener asociado un documento de poder legal::::::::Serviço ''req_type'' deve ter uma Procuração associada::::::::服务 “请求_类型”必须具备一份相关的委托书文件。', NULL, '#{id}(application.service.id)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('cadastre-redefinition-target-geometries-dont-overlap', 'cadastre-redefinition-target-geometries-dont-overlap', 'sql', 'New polygons do not overlap with each other.::::Новые полигоны не пересекаются друг с другом.::::المضلعات الجديدة لا يجب ان تتداخل::::Les nouveaux polygones ne doivent pas se superposer.::::Nuevos polígonos no se solapan unos con otros.::::::::Novos polígonos não se sobrepõem uns com os outros.::::::::新的多边形不要与任何一个相交叠。', NULL, '#{id} is the parameter asked. It is the transaction id.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('cadastre-object-check-name', 'cadastre-object-check-name', 'sql', 'The parcel (cadastre object) should have a valid form of description (appellation)::::Участок (кадастровый объект) должен иметь корректное описание (наименование).::::القطعة او الكائن المكاني يجب ان يكون لها  وصف او تسمية صحيحة::::La parcelle (objet cadastrale) doit avoir une forme de descriptif (appellation) valide.::::La parcela (objeto catastro) debería tener una forma válida de descripción (denominación).::::::::A parcela (objeto do cadastro) deve ter uma forma válida de inscrição (denominação)::::::::宗地 (地籍目标)应具有一个有效的描述形式 (名目)。', NULL, '#{id}(cadastre.cadastre_object.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('new-cadastre-objects-present', 'new-cadastre-objects-present', 'sql', 'New cadastral objects must be defined::::Новые кадастровые объекты должны быть определены.::::يجب تحديد كائن مساحة جديد::::Les nouveaux objets cadastres doivent être définis.::::Los nuevos objetos catastrales deben estar definidos::::::::Novos objetos de cadastro devem ser definidos::::::::新的地籍目标必须明确。', NULL, '#{id}(transaction_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-not-transferred', 'application-not-transferred', 'sql', 'An application should not be already transferred to another system.::::::::الطلب لا يمكن ان يكون قد تم نقله سابقا  الى نظام آخر::::::::Una aplicación no debe ser transferido a otro sistema.::::::::O pedido ainda não deve ser transferido para outro sistema.::::::::一项申请不应被转换到另一个系统。', NULL, 'The application should not have the status transferred.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-baunit-has-parcels', 'application-baunit-has-parcels', 'sql', 'Title must have Parcels::::Недвижимость должна иметь участок::::سند الملكية يجب ان يحتوي على قطع::::Un titre doit contenir au moins un numéro de parcelle::::El título debe tener parcelas::::::::Título deve ter Parcelas::::::::财产必须有几块宗地。', NULL, '#{id}(application.service.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('service-on-complete-without-transaction', 'service-on-complete-without-transaction', 'sql', 'Service ''req_type'' must have been started and some changes made in the system::::Услуга ''req_type''  должна быть запущена и сделаны какие-либо изменения.::::يجب ان تكون  اخدمة ''req_type'' قد بدأت وهناك تغييرات غلى النظام::::Le service ''req_type'' doit avoir commencé et des changements faits dans le système.::::Servicio ''req_type'' debe haber sido iniciado y realizado algunos cambios en el sistema::::::::Serviço ''req_type'' deve ter sido iniciado e realizado algumas modificações no sistema::::::::服务 “请求_类型”必须启动并在系统中作些改变。', NULL, '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('ba_unit-spatial_unit-area-comparison', 'ba_unit-spatial_unit-area-comparison', 'sql', 'Title area should only differ from parcel area(s) by less than 1%::::Площадь недвижимости не должна отличаться от ее земельного участка более чем на 1%.::::المساحة في سند الملكية لا يجب ان تختلف باكثر من 1% من مساحة القطعة (القطع)::::La superficie indiquée sur le titre ne doit varier de plus d''1% par rapport à la superficie de la parcel.::::Área de título sólo debe diferir de la superficie de la parcela (s) en menos de 1%::::::::Área de título só deve diferir da área(s) da parcela por menos de 1%::::::::财产面积与宗地面积相差应该不超过1%。', NULL, '#{id}(administrative.ba_unit.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('consolidation-not-again', 'Records are unique', 'sql', 'Records being consolidated must not be present in the destination. 
result::::::::السجلات تحت الدمج لا يجب ان تظهر في نتائج الوجهة ::::::::Los registros que se están consolidando no deben estar presentes en el destino.
result::::::::Registros sendo consolidados não devem estar presente no destino.
resultado::::::::合并的记录不必出现在最终目标中。', '', '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('cadastre-redefinition-union-old-new-the-same', 'cadastre-redefinition-union-old-new-the-same', 'sql', 'The union of the new polygons must be the same as the union of the old polygons::::Объединение новых полигонов должно быть таким же как объединение старых полигонов.::::الاتحاد من المضلعات الجديدة يجب أن تكون نفس الاتحاد من المضلعات القديمة::::L''union des nouveaux polygones doit être le même que l''union des anciens polygones.::::La unión de los nuevos polígonos debe ser la misma que la unión de los antiguos polígonos::::::::A união dos novos polígonos deve ser a mesma que a união dos antigos polígonos::::::::新多边形的联合必须与旧的多边形一样。', NULL, '#{id} is the parameter asked. It is the transaction id.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('new-cadastre-objects-do-not-overlap', 'new-cadastre-objects-do-not-overlap', 'sql', 'The new parcel polygons must not overlap::::Новые участки не должны пересекаться.::::مضلعات القطعة الجديدة يجب ان لا تتداخل::::Les polygones des nouvelles parcelles ne doivent pas se superposer.::::Los nuevos polígonos de parcelas no deben solaparse::::::::Os polígonos das novas parcelas não devem se sobrepor.::::::::新宗地多边形不能重叠。', NULL, '#{id}(transaction_id) is requested. Check the union of new co has the same area as the sum of all areas of new co-s, which means the new co-s don''t overlap');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('target-parcels-check-nopending', 'target-parcels-check-nopending', 'sql', 'There should be no pending changes for any of target parcels::::Целевые участки не должны иметь каких-либо незавершенных изменений.::::يجب ان لا يوجد اية تغييرات معلقة على القطعة المستهدفة::::Il ne doit pas y avoir de changement en attente pour aucune des parcelles cibles.::::No debe haber cambios pendientes para cualquiera de las parcelas de destino::::::::Não deve haver alterações pendentes para qualquer das parcelas alvo::::::::对任何目标地块不应该有未决的变化。', NULL, '#{id}(cadastre.cadastre_object.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('target-parcels-present', 'target-parcels-present', 'sql', 'Target parcel(s) must be selected::::Целевые участки должны быть выбраны.::::يجب اختيار القطعة المستهدفة::::Le(s) parcelle(s) doivent être sélectionnées.::::Se debe seleccionar la Parcela Objetivo(s)::::::::Parcela(s) alvo deve ser selecionada::::::::必须选定目标宗地。', NULL, '#{id}(transaction_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('bulk-spatial-geom-overlaps-with-loading-geom', 'bulk-spatial-geom-overlaps-with-loading-geom', 'sql', 'New cadastre objects must not overlap with other new cadastre objects. ::::Новые кадастровые объекты не должны пересекаться с другими новыми объектами.::::الكينونات المساحية الجديدة لا يجب ان تتداخل مع كينونات مساحة  جديدة أخرى::::::::Nuevos objetos catastrales no deben solaparse con otros nuevos objetos catastrales.::::::::Novos objetos de cadastro não devem se sobrepor com outros novos objetos de cadastro.::::::::新的地籍目标不能与其他新的地籍目标相交叠。 ', NULL, '#{id}(transaction_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-claim-nr', 'generate-claim-nr', 'sql', '', '', '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-process-progress-consolidate-max', 'generate-process-progress-consolidate-max', 'sql', '...::::::::...::::::::...::::::::...::::::::...', '-- Calculate the max the process progress can be. 
  Increments:
  - 10 the upload
  - 2 script to schema only
  - 2 script to table data only for each table
  - 2 for each br validation
  - 1 for writting the validation result to log
  In consolidaton method
  - 4 once
  - 2 for each table
 ', '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-notation-reference-nr', 'generate-notation-reference-nr', 'sql', '', NULL, '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-cadastre-object-lastpart', 'generate-cadastre-object-lastpart', 'sql', '', NULL, 'It accepts parameters #{geom} = The geometry of the new cadastre object and #{cadastre_object_type} = The type of the cadastre object.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('ba_unit-has-compatible-cadastre-object', 'ba_unit-has-compatible-cadastre-object', 'sql', 'Title should have compatible parcel (or cadastre object) description (appellation)::::Недвижимость должна иметь совместимый тип земельного участка.::::سند الملكية يجب ان يحتوي على وصف\ اسم   قطعة متوافقة::::Le titre doit avoir un descriptif (appellation) de parcelle (ou objet cadastre) compatible.::::Un Título debe tener una descripción (denominación) de parcela compatible (u objeto catastralo)::::::::Título deve ter descrição (denominação) da parcela compatível (ou objeto do cadastro)::::::::产权应兼具地块(或地籍目标)描述(称谓)。', NULL, '#{id}(administrative.ba_unit.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('newtitle-br22-check-different-owners', 'newtitle-br22-check-different-owners', 'sql', 'Owners of new titles should be the same as owners of underlying titles::::Владельцы новых объектов недвижимости должны быть такие же как в родительских объектах.::::المالكون في سند الملكية الجديد يجب ان يكونوا نفس المالكين من السندات السابقة::::Les propriétaires des nouveaux titres doivent être les mêmes que les propriétaires des titres sous-jacents.::::Los propietarios de los nuevos títulos deben ser los mismos que los propietarios de títulos subyacentes::::::::Os proprietários de novos títulos devem ser os mesmos que os proprietários de títulos subjacentes::::::::新的产权所有者必须与基础产权的所有者相同。', NULL, '#{id}(baunit_id) is requested.
Check that new title owners are the same as underlying titles owners (Give WARNING if > 0)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('target-parcels-check-isapolygon', 'target-parcels-check-isapolygon', 'sql', 'The union of the target parcels must be a polygon::::Объединение целевых участков должно быть полигоном.::::الاتحاد بين القطع يجب ان يكون مضلع::::L''union des parcelles cibles doit être un polygone.::::La unión de las parcelas de destino debe ser un polígono::::::::A união das parcelas alvo deve ser um polígono::::::::目标地块的联合必须是一个多边形。', NULL, '#{id}(cadastre.cadastre_object.transaction_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('survey-points-present', 'survey-points-present', 'sql', 'There are at least 3 survey points present::::По крайней мере должны быть определены 3 точки съемки.::::هناك على الاقل ثلاث نقاط مساحة موجودة::::Il doit y avoir au moins 3 points de levé.::::Hay por lo menos presentes 3 puntos de topografía::::::::Existem pelo menos três pontos de medição presentes.::::::::至少要呈现三个调查点。', NULL, '#{id}(transaction_id) is requested. Check there are survey points attached with the cadastre change.
 At least 3 points has to be attached to complete a polygon.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('rrr-must-have-parties', 'rrr-must-have-parties', 'sql', 'These rights (and restrictions) must have a recorded party (or parties)::::Данные права (или ограничения) должны иметь правообладателей.::::هذه الحقوق او القيود يجب ان يكون عليها اطراف معرفون::::Ces droits (et restrictions) doivent avoir une partie ou des parties enregistrées::::Estos derechos (y restricciones) deben tener una parte (o partes) registrada ::::::::Estes direitos (e restrições) devem ter uma parte registrada (ou partes)::::::::这些权利(和限制) 必须有一个或多个记录对象。', NULL, '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('source-attach-in-transaction-no-pendings', 'source-attach-in-transaction-no-pendings', 'sql', 'Document (source file) must not be duplicated::::Документ не должен дублироваться.::::يجب عدم تكرار الوثيقة  (ملف المصدر)::::Le document (fichier source) ne doit pas être dupliqué.::::Documento (archivo de origen) no debe estar duplicado::::::::Documento (arquivo de origem) não deve ser duplicado::::::::文件 (来源文件夹) 必须不能被复制', NULL, '#{id}(source.source.id) is requested. It checks if the source has already a record with the status pending.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('bulk-spatial-name-unique', 'bulk-spatial-name-unique', 'sql', 'Cadastre objects with must have unique names.::::Кадастровые объекты должны иметь уникальные коды.::::كينونات المساحة يجب ان يكون لها اسماء غير مكررة::::::::Objetos Catastrales deben tener nombres únicos.::::::::Objetos de cadastro deve ter um nome único.::::::::地籍目标必须有独特的名称。', NULL, '#{id}(transaction_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('spatial-unit-group-name-unique', 'spatial-unit-group-name-unique', 'sql', 'Spatial unit groups must be unique.::::Пространственные группы должны быть уникальны.::::مجموعة الوحدات المكانية يجب ان لا تتكرر::::::::Grupos de unidades espaciales deben ser únicos.::::::::Grupo de unidade espacial deves ser único.::::::::空间单元组必须是独一无二的。', NULL, 'There is no parameter required.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('consolidation-db-structure-the-same', 'bfe8e722-99dd-11e3-8b71-a36603d16f1c', 'sql', 'The structure of the tables in the source and target database are the same.::::::::هيكلية الجداول من المصدر والهدف هي نفسها::::::::La estructura de las tablas de la base de datos de origen y destino son los mismos.::::::::A estrutura das tabelas no banco de dados de origem e de destino são as mesmas.::::::::来源和目标数据库中表格结构是相同的。', NULL, 'It controls if every source table in consolidation schema is the same as the corresponding target table.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('consolidation-extraction-file-name', 'Consolidation extraction file name', 'sql', '111.0::::::::::::::::::::::::111.0::::::::111.0', 'Generates the name of the extraction file for the consolidation. The extension is not part of this generation.', '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('cancel-relation-notification', '5c93e7ba-bce3-11e4-9033-6300da0026fa', 'sql', 'Cancel notification for the services of the application::::::::ملاحظة الغاء للخدمات على الطلب ::::::::::::::::Cancel notification for the services of the application::::::::取消申请服务的通知', NULL, '#{id}(application_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('service-has-person-verification', 'service-has-person-verification', 'sql', 'Within the application for the service a personal identification verification should be attached.::::В заявлении должен присутствовать документ удостоверяющий личность.::::ضمن الطلب ولاجل الخدمة يجب  ارفاق وثيقة تعريف بالشخصية::::Pour la demande d''un service, la vérification de l''identification personnelle doit être attachée.::::Dentro de la aplicación para el servicio, se debe agregar una verificación de identificación personal.::::::::No pedido, para a realização do serviço, uma identificação pessoal deve ser anexada para verificação.::::::::申请内要附上个人身份证明。', NULL, '#{id}(application.service.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('ba_unit-has-cadastre-object', 'ba_unit-has-cadastre-object', 'sql', 'Title must have an associated parcel (or cadastre object)::::Недвижимость должна иметь земельный участок (или кадастровый объект).::::سند الملكية يجب ان يحتوي على قطعة  او كائن مساحة::::Le titre doit avoir une parcelle associée (ou objet cadastre)::::Un Título debe tener una parcela asociada (u objeto catastral)::::::::Título deve ter uma parcela associada (ou objeto de cadastro)::::::::财产必须具备一个相关地块（或地籍目标）。', NULL, '#{id}(administrative.ba_unit.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('area-check-percentage-newareas-oldareas', 'area-check-percentage-newareas-oldareas', 'sql', 'The difference between the total of the new parcels official areas and the total of the old parcels official areas should not be greater than 0.1%::::Разница между общей официальной площадью новых участков и площадью старых участков не должна превышать 0.1%.::::الفرق بين مجموع مساحات  القطع الجديدة الرسمية  ومجموع المساحات السابقة للقطع القديمة يجب ان لا يتجاوز 0.1 %::::La différence entre la superficie totale officielle des nouvelles parcelles et la superficie totale officielle des anciennes parcelles ne doit pas être supérieur à 0.1%.::::La diferencia entre el area total oficial de las nuevas parcelas y el total de las antiguas áreas oficiales de las parcelas no debe ser mayor que 0,1%::::::::A diferença entre o total das novas áreas das parcelas oficiais e o total das áreas das parcelas oficiais antigas, não deve ser superior a 0,1%::::::::新宗地的登记总面积和旧宗地的总面积之差不应超过 0.1%。', NULL, '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('ba_unit-has-several-mortgages-with-same-rank', 'ba_unit-has-several-mortgages-with-same-rank', 'sql', 'The rank of a new mortgage must not be the same as an existing mortgage registered on the same title::::Рейтинг новой ипотеки не должен быть таким же как у существующей ипотеки для данной недвижимости.::::رتبة الرهن يجب ان لا تساوي نفس رتبة الرهن  الحالي::::Le rang de la nouvelle hypothèque ne doit pas être le même qu''une hypothèque existante enregistrée sur le même titre.::::El rango de una nueva hipoteca no debe ser el mismo que una hipoteca existente registrado en el mismo título::::::::A classificação de uma nova hipoteca, não deve ser a mesma que uma hipoteca existente registada no mesmo título::::::::新的抵押权排序不必与现行的登记在同一产权下的抵押相同。', NULL, '#{id}(administrative.rrr.id) is requested.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('rrr-has-pending', 'rrr-has-pending', 'sql', 'There are no other pending actions on the rights and restrictions being changed or removed on this application::::Нет никаких изменений в правах и ограничениях, сделанных из текущего заявления::::لا يوجد حركات بحاجة لتنفيذ على الحقوق او القيود لهذا الطلب::::Il n''y a pas d''autre actions en attente sur les droits et restrictions en cours de changement ou supprimé de cette application.::::No hay otras acciones pendientes en los derechos y restricciones siendo alterada o eliminada en esta solicitud::::::::Não há outras ações pendentes sobre os direitos e restrições sendo alterados ou removidos neste pedido::::::::在申请中没有其他有关产权和限制的待定操作被改变或消除。', NULL, '#{id}(administrative.rrr.id) is requested. It checks if for the target rrr there is already a pending edit or record.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('ba_unit-has-caveat', 'ba_unit-has-caveat', 'sql', 'Caveat should not prevent registration proceeding.::::Арест не должен ограничивать дальнейшую регистрацию.::::القيود لا يجب ان تعطل عملية التسجيل::::Un caveat ne doit pas empêcher de procéder à l''enregistrement.::::Una Salvedad no debe impedir un procedimiento de registro.::::::::Embargo não deve impedir a continuidade da inscrição.::::::::附加权利不应阻止登记的进行。', NULL, '#{id}(administrative.rrr.id) is requested.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('bulk-spatial-geom-overlaps-with-existing', 'bulk-spatial-geom-overlaps-with-existing', 'sql', 'Cadastre objects must not overlap with existing cadastre objects. ::::Кадастровые объекты не должны пересекаться с существующими кадастровыми объектами.::::كينونات المساحة يجب ان لا تتداخل::::::::Objetos Catastro no deben solaparse con objetos catastrales existentes.::::::::Objetos de cadastro não devem se sobrepor com objetos de cadastro existentes.::::::::地籍目标必须不能与现有的地籍目标相交叠。', NULL, '#{id}(transaction_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-process-progress-extract-max', 'generate-process-progress-extract-max', 'sql', '...::::::::...::::::::...::::::::...::::::::...', '-- Calculate the max the process progress can be.
Increments of the progress in the extraction method
 - 7 times once
 - 3 times for each table
Increments of the progress in the method to convert schema to text
 - 2 for the schema generation only and save as file
 - 5 increments for each table to convert to text and save as file
 - 10 increments for the compression of files', '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-source-nr', 'generate-source-nr', 'sql', '', NULL, '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br2-check-title-documents-not-old', 'application-br2-check-title-documents-not-old', 'sql', 'The scanned image of the title should be less than one week old.::::Отсканированная копия права собственности должна быть сделана менее недели назад.::::عمر صورة السند الممسوح يجب ان تكون اقل من أسبوع::::L''image scannée du titre ne doit pas être antérieur à une semaine.::::La imagen escaneada del título debe tener menos de una semana de haberse realizado::::::::A imagem digitalizada do título deve ter menos de uma semana.::::::::产权图像必须是一周之内扫描的。', NULL, 'Checks recorded date (recordation) against date at time of validation. Current allowable date difference is one week.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br4-check-sources-date-not-in-the-future', 'application-br4-check-sources-date-not-in-the-future', 'sql', 'Documents should have dates formalised by source agency that are not in the future.::::Документы должны иметь дату документа меньше текущей.::::تواريخ الوثائق المعتمدة من الوكالة المصدر يجب ان لا تكون في المستقبل::::Les documents doivent avoir des dates formalisées par l''agence source qui ne sont pas dans le future.::::Los documentos deben tener fechas formalizados por la agencia de origen que no están en el futuro.::::::::Os documentos devem ter datas formalizadas pela agência de origem que não estejam no futuro.::::::::文件应由来源机构标注正式日期以显示那不是在未来。', NULL, 'Checks the date of the document as recorded at lodgement (source.recordation) and checks it is not a date in the future');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('ba_unit-has-a-valid-primary-right', 'ba_unit-has-a-valid-primary-right', 'sql', 'A title must have a valid primary right::::Недвижимость должна иметь первичное право собственности.::::سند الملكية يجب ان يحتوي على حق اساسي صالح::::Un titre doit avoir un droit principal valide.::::Un título debe tener un derecho primario válido::::::::O título deve ter um direito fundamental válido::::::::一项产权必须具有正当的初始权利。', NULL, '#{id}(baunit_id) is requested.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('required-sources-are-present', 'required-sources-are-present', 'sql', 'All documents required for the service ''req_type'' are present.::::Должны присутствовать все документы необходимые для услуги ''req_type'' .::::جميع الوثائق المطلوبة لخدمة  ''req_type''  موجودة::::Tous les documents requis pour le service ''req_type'' sont présents.::::Todos los documentos necesarios para el servicio''req_type'' están presentes.::::::::Todos os documentos necessários para o ''req_type'' estão presentes.::::::::所有需要作为服务“请求_类型”的文件都要呈现。', NULL, 'Checks that all required documents for any of the services in an application are recorded. Null value is returned if there are no required documents');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('area-check-percentage-newofficialarea-calculatednewarea', 'area-check-percentage-newofficialarea-calculatednewarea', 'sql', 'The difference between the new official parcel area and the new calculated area should be less than 1%::::Разница между новой официальной площади участка и новой вычисленной площади не должны быть более 1%.::::..القرث بين مساحة القطعة الجديدو الرسمي والمساحة الجديدة المحتسبة يجب ان لا يتجاوز 1%::::La différence entre la superficie officielle de la nouvelle parcelle et la superficie calculée doit être inférieur à 1%.::::La diferencia entre la nueva area oficial de la parcela y la nueva área calculada debe ser inferior a 1%::::::::A diferença entre a nova superfície da parcela oficial e a nova zona de cálculo deve ser inferior a 1%::::::::新宗地的登记总面积和新计算的面积之差不应超过 0.1%。', NULL, '#{id}(cadastre.cadastre_object.id) is requested. 
 Check new official area - calculated new area / new official area in percentage (Give in WARNING description, percentage & parcel if percentage > 1%)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('rrr-shares-total-check', 'rrr-shares-total-check', 'sql', 'The sum of the shares (in ownership rights) must total to 1::::Сумма долей права собственности должна ровняться 1.::::مجموع الحصص في اصحاب الحقوق يجب ان يساوي واحد صحيح::::La somme des parts (du droit de propriété) doit être égale à 1.::::La suma de las acciones (en los derechos de propiedad) debe sumar 1::::::::A soma das divisões (em direitos de posse) deve totalizar 1::::::::（所有权）份额的加总必须等于1。', NULL, '#{id}(administrative.rrr.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('source-attach-in-transaction-allowed-type', 'source-attach-in-transaction-allowed-type', 'sql', 'Document to be registered must have an allowable and current source type::::Документы для регистрации должны иметь допустимый тип.::::الوثيقة المراد تسجيلها يجب ان يكون لها نوع مصدر حالي مسموح به::::Le document à enregistrer doit avoir un type de source courant et disponible.::::El documento a ser registrado debe tener un tipo de origen permitido y actualizado::::::::Documento a ser registrado deve ter um tipo de origem admissível e atual::::::::待登记的文件必须有允许的和当前的来源类型。', NULL, '#{id}(source.source.id) is requested. It checks if the source has a type which has the is_for_registration attribute true.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br6-check-new-title-service-is-needed', 'application-br6-check-new-title-service-is-needed', 'sql', 'An application can be associated with a property which should have a digital title record.::::Заявление должно содержать недвижимость которая имеет электронную запись в базе.::::الطلب يجب ارتباطه بملكية لها سند ملكية الكتروني::::Une demande peut être associée à une propriété qui doit avoir une trace de titre numérique.::::Una aplicación puede estar asociada con una propiedad que debe tener un registro de título digitales ..::::::::Um pedido pode ser associado a uma propriedade que deve possuir um registro digital do título.::::::::申请可以和有数字产权记录的财产一起进行。', NULL, 'Rule checks to see if there is a ba_unit record for the property identified for the application at lodgement');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('newtitle-br24-check-rrr-accounted', 'newtitle-br24-check-rrr-accounted', 'sql', 'All rights and restrictions from existing title(s) must be accounted for in the new titles created in this application.::::Все права и ограничения существующих объектов недвижимости должны быть учтены в новых объектах недвижимости, создаваемых в этом заявлении.::::جميع الحقوق او القيود من السندات الحالية يجب مراعاتها في  السندات الجديدة::::Tous les droits et restrictions du/des titre(s) existant(s) doivent être pris en compte dans les titres créés dans la demande.::::Todos los derechos y restricciones de título existente (s) deben tenerse una cuenta en los nuevos títulos creados en esta aplicación.::::::::Todos os direitos e restrições de título(s) existente(s) devem ser contabilizados nos novos títulos criados neste pedido.::::::::所有来自现存产权的权利和限制必须在创建的新申请中进行产权说明。', NULL, '#{id}(application_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br1-check-required-sources-are-present', 'application-br1-check-required-sources-are-present', 'sql', 'All documents required for the services in this application are present.::::Все документы, необходимые для указанных услуг должны присутствовать в заявлении.::::جميع الوثائق المطلوبة للخدمة  موجودة::::Tous les documents requis pour les services de cette demande sont présents.::::Todos los documentos necesarios para los servicios de esta aplicación están presentes.::::::::Todos os documentos necessários para os serviços deste pedido estão presentes.::::::::申请中需要的所有文件都需要呈上。', NULL, 'Checks that all required documents for any of the services in an application are recorded. Null value is returned if there are no required documents');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-approve-cancel-old-titles', 'application-approve-cancel-old-titles', 'sql', 'An application including a new freehold service must also terminate the parent title(s) with a cancel title service.::::Identificati titoli esistenti. Prego terminare i titoli esistenti usando il servizio di Cancellazione Titolo::::الطلب الذي يحتوي على خدمة  تملك حر يجب ان يحتوي على خدمة اخرى تلغي جميع سندات الملكية السابقة::::Une demande incluant un nouveau service de propriété franche doit aussi résilier le(s) titre(s) parent(s) avec un service d''annulation.::::Una aplicación que incluye un nuevo servicio de dominio absoluto también debe terminar el título padre (s) con un servicio de cancelar título.::::::::Pedido, incluindo o serviço de nova propriedade livre deve também concluir o título(s) principal com um serviço de cancelar título.::::::::一项包括新的终身保有服务的申请也必须终止带有取消产权服务的源产权。', NULL, '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('current-rrr-for-variation-or-cancellation-check', 'current-rrr-for-variation-or-cancellation-check', 'sql', 'For cancellation or variation of rights (or restrictions), there must be existing rights or restriction (in addition to the primary (ownership) right)::::Для изменения или отмены права или ограничения, должно существовать право или ограничение (в дополнении к основному праву собственности).::::من اجل الغاء او تغيير الحقوق او القيود , يجب اولا وجود حقوق او قيود سابقة بالاضافة الى تعريف الحق الاساسي::::Pour l''annulation ou la variation de droits (ou restrictions), il doit y avoir des droits (ou restrictions) existants (en plus du droit principal (propriété)).::::Para la cancelación o modificación de los derechos (o restricciones), debe haber derechos o restricciones existentes (además del derecho primario (propiedad))::::::::Para o cancelamento ou alteração de direitos (ou restrições), devem haver direitos ou restrições (além do direito fundamental (posse))::::::::对于权力的取消或变更 (或限制)，必须存在权力或限制 (除基本（所有）权之外）。', NULL, '#{id}(application.service.id)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('public-display-check-baunit-has-co', 'public-display-check-baunit-has-co', 'sql', 'All property must have an associated cadastre object.::::Все объекты недвижимости должны иметь соответствующие кадастровые объекты.::::جميع الملكيات يجب ان ترتبط بكائن مساحي::::::::Toda propiedad debe tener un objeto catastral asociado.::::::::Toda propriedade deve ter um objeto de cadastro associado.::::::::所有的财产都必须有一个相关的地籍目标。', NULL, '#{lastPart}(name_lastpart) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('cancel-obscuration-request', 'cancel-obscuration-request', 'sql', 'cancel-obscuration-request::::...::::...::::...::::...::::...::::cancel-obscuration-request::::...::::...', NULL, '#{id}(service_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-cancel-obscuration-request', 'application-cancel-obscuration-request', 'sql', 'application-cancel-obscuration-request::::...::::...::::...::::...::::...::::application-cancel-obscuration-request::::...::::...', NULL, '#{id}(service_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-spatial-unit-not-transferred', 'application-spatial-unit-not-transferred', 'sql', 'An application must not use a parcel already transferred.::::::::لا يمكن للطلب استخدام قطعة تم نقلها سابقا::::::::Una aplicación no debe utilizar una parcela ya transferida.::::::::O pedido não deve usar uma parcela já transferida.::::::::一项申请不适用于已转让的宗地。', NULL, 'It checks if the application has no spatial_unit that is already targeted by an application that has the status  transferred.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('cancel-title-check-rrr-cancelled', 'cancel-title-check-rrr-cancelled', 'sql', 'All rights and restrictions on the title to be cancelled must be transfered or cancelled in this application.::::Все права и ограничения недвижимости, которая будет ликвидирована должны быть переданы или ликвидированы в этом же заявлении.::::جميع الحقوق او القيود على سند الملكية يجب نقلها او الغاؤها في هذا الطلب::::Tous les droits et restrictions sur le titre à annuler doivent être transférés ou annulés dans la demande.::::Todos los derechos y restricciones en el título para ser canceladas debe ser transferido o cancelado en esta aplicación.::::::::Todos os direitos e restrições sobre o título a ser cancelado devem ser transferidos ou cancelados neste pedido.::::::::所有需要被取消的有关产权的权利和限制在申请中都必须被转换或被取消。', NULL, '#{id}(application_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('service-check-no-previous-digital-title-service', 'service-check-no-previous-digital-title-service', 'sql', 'For the Convert Title service there must be no existing digital title record (including the recording of a primary (ownership) right) for the identified title::::Для услуги конвертации недвижимости не должно быть существующих записей этой недвижим.::::في خدمة تحويل الى سند  ملكية رقمي يجب ان لا يوجد  سجل رقمي للملكية بما فيه  تسجيل الحق الاساسي::::Pour le service de conversion de titre, il ne doit pas y avoir de titre numérique existant déjà enregistré (incluant l''enregistrement d''un droit principal (propriété) pour le titre identifié.::::Para el servicio Conversión de Título Convertir no debe haber ningún registro de título digital existente (incluyendo el registro de derechos primario (propiedad)) para el título identificado::::::::Para a Conversão do Título não deve haver nenhum registro de título digital (incluindo o registro de um direito fundamental (de posse)) para o título identificado::::::::对于转换产权服务，确定的产权不必具有现成数字产权记录(包括基本产权(所有) 权)记录。', NULL, '#{id}(application.service.id) is requested where service is for newDigitalTitle or newDigitalProperty');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('target-ba_unit-check-if-pending', 'target-ba_unit-check-if-pending', 'sql', 'Pending registration actions (from other applications) affecting the title to be cancelled should be cancelled::::Все незавершенные действия из других заявлений по регистрации прав с данной недвижимостью, которая будет ликвидирована должны быть отменены.::::حركات التسجيل المعلقة والتي تؤثر على سند الملكية من الطلبات الاخرى يجب الغاؤها::::Les actions d''enregistrement en attente (provenant d''autres demandes) affectant le titre à annuler doivent être annulées.::::Las acciones pendientes de registro (desde otras aplicaciones) que afecten el título a ser cancelados, se deben cancelar::::::::Ações pendentes de registro (a partir de outros pedidos) que afetam o título a ser cancelado, devem ser canceladas::::::::待定登记操作应该被取消，这些操作来自其他的申请，会影响要被取消的产权。', NULL, '#{id}(baunit_id) is requested. It checks if there is no pending transaction for target ba_unit (a ba_unit flagged for cancellation).
 It checks if the administrative.ba_unit_target table has a record of this ba_unit which is different
 from the transaction that has flagged the ba_unit for cancellation, that this transaction record is not yet approved,
 that this ba_unit has an associated rrr record which is pending and that there are no other applications with intended or pending changes to this ba_unit.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('applicant-name-to-owner-name-check', 'applicant-name-to-owner-name-check', 'sql', 'The applicants name should be the same as (one of) the current owner(s)::::Имя заявителя должно быть таким же как у одного из текущих владельцев.::::مقدم الطلب يجب ان يكون واحد من المالكين الحاليين::::Le nom d''au moins un des propriétaires actuels doivent apparaître parmis les demandeurs.::::El nombre de los solicitantes debe ser el mismo que (uno de) el actual propietario (s)::::::::O nome dos requerentes devem ser os mesmo que um (dos) dono(s) atual.::::::::申请人的名称和当前的所有者应该是一样的。', NULL, '#{id}(application.application.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('app-allowable-primary-right-for-new-title', 'app-allowable-primary-right-for-new-title', 'sql', 'An allowable primary right (ownership, apartment, State ownership, lease) must be identified for a new title::::Одно из допустимых прав собственности такое как - право собственности, право собственности на квартиру, государственное право собственности, аренда, должно быть зарегистрировано для нового объекта недвижимости.::::الحق الاساسي المسموح به  (المالك, الشقة, مالك العقار, الايجار ) يجب تحديده لسند ملكية جديد::::Tous les droits principaux autorisés (propriété, appartement, propriété de l''Etat, bail) doivent être identifiés pour le nouveau titre::::Un derecho primario permisible (propiedad, apartamento, propiedad del Estado, arrendamiento) debe ser identificado por un nuevo título::::::::O direito fundamental (posse, bem imóvel, propriedade do Estado, arrendamento) deve ser identificado por um novo título::::::::某项允许的基本权利(所有权、公寓、国有产权以及租赁等) 必须作为新的产权被确定。', NULL, '#{id}(application.application.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('baunit-has-multiple-mortgages', 'baunit-has-multiple-mortgages', 'sql', 'For the Register Mortgage service the identified title has no existing mortgages::::Для регистрации ипотеки указанная недвижимость не должна иметь существующих записей об ипотеки.::::في خدمة  تسجيل  رهن  السند المحدد لا يجب ان يكون عليه رهونات اخرى::::Pour le service d''enregistrement de l''hypothèque, le titre identifié n''a pas d''hypothèques existantes.::::Para el servicio de Registro de hipotecas el título identificado no tiene hipotecas existentes::::::::Para o serviço Cadastrar Hipoteca o título identificado não deve possui hipotecas::::::::对于抵押登记服务， 确定的产权没有现成的抵押。 ', NULL, '#{id}(administrative.ba_unit.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('document-supporting-rrr-is-current', 'document-supporting-rrr-is-current', 'sql', 'Documents supporting rights (or restrictions) must have current status::::Документы использующиеся для регистрации прав или ограничений должны иметь текущий (активный) статус.::::الوثائق التي تدعم الحقوق او القيود يجب ان يكون لها الحالة الحالية::::Les documents justificatifs de droits (ou restrictions) doivent avoir le statut courant.::::Los documentos justificativos de los derechos (o restricciones) deben tener estado actual::::::::Documentos que servem de suporte a direitos (ou restrições) devem ter o estado atual::::::::支持（或限制）权利的文件必须为目前状态。', NULL, '#{id}(application.service.id)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('service-title-terminated', 'service-title-terminated', 'sql', 'For the service ''req_type'' the title must be terminated (after all rights recorded on the title are transferred or cancelled).::::Для услуги ''req_type''  недвижимость должна быть ликвидирована (после того как все зарегистрированные права переданы или отменены).::::لخدمة من نوع     ''req_type'' , سند  الملكية يجب انهاؤه (بعد نقل الحقوق او الغاؤها (::::Pour le service ''req_type'', le titre doit être résilié (après que tous les droits enregistrés sur le titre soient transférés ou annulés).::::Para el servicio ''req_type'' el título debe estar terminado (después que todos los derechos inscritos en el título se transfieren o esten cancelados).::::::::Para o serviço ''req_type'' o título deve ser concluido (depois que todos os direitos registrados no título são transferidos ou cancelados)::::::::对于服务 “请求_类型”产权必须终止 (在所有关于产权的记录被转移或被取消之后）。', NULL, '#{id}(application.service.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('spatial-unit-group-not-overlap', 'spatial-unit-group-not-overlap', 'sql', 'Spatial unit groups of the same hierarchy must not overlap with each other. Tolerance of 0.5 m is applied.::::Пространственные группы одной и той же иерархии не должны пересекаться друг с другом. Погрешность не должна превышать 0.5 м::::مجموعة الوحدات المكانية من نفس البناء الهرمي يجب ان لا تتداخل مع بعضها. سيتم تطبيق سماحية لا تتعدى 0.5 متر::::::::Grupos unidad espacial de la misma jerarquía no deben solaparse entre sí. Se aplica la tolerancia de 0,5 m.::::::::Grupos de unidade espaciais com a mesma hierarquia, não devem ser sobrepor uns com os outros. Tolerância aplicada de 0.5 m.::::::::同一层次的空间单元组不能与其他的相交。适用限度是0.5米。', NULL, 'There is no parameter required.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-spatial-unit-group-name', 'generate-spatial-unit-group-name', 'sql', '', NULL, 'It accepts parameters: 
  #{geom_v} = The geometry of the new spatial unit group. It is in EWKB format.
  #{hierarchy_level_v} = The hierarchy level
  #{label_v} = The label
  ');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br3-check-properties-are-not-historic', 'application-br3-check-properties-are-not-historic', 'sql', 'All the titles identified for the application must be current.::::Все права собственности, относящиеся к заявлению должны иметь текущий (активный) статус.::::جميع سندات الملكية داخل الطلب يجب ان  تكون حالية::::Tous les titres identifiés pour la demande doivent être courants.::::Todos los títulos identificados para la aplicación deben estar al día.::::::::Todos os títulos identificados no pedido devem ser atuais.::::::::申请中说明的所有产权都必须是目前的。', NULL, 'Checks the title reference recorded at lodgement against titles in the database and if there is a ba_unit record it checks if it is current (PASS)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-on-approve-check-public-display', 'application-on-approve-check-public-display', 'sql', 'The publication period must be completed.::::Период публикации должен быть завершен.::::يجب استكمال فترة النشر::::La période de publication doit être exécutée.::::El período de publicación debe ser completado.::::::::O período de publicação deve ser concluído.::::::::出版日期必须完整。', NULL, 'Checks the completion of the public display period for all instances of systematic registration service related to the application');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('app-check-title-ref', 'app-check-title-ref', 'sql', 'Invalid identifier for title::::Неверный идентификатор права собственности::::معرف السند غير صحيح::::Identifiant invalide pour le titre::::Identificador no válido para el título::::::::Título com identificador inválido::::::::无效的产权标志', NULL, '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br7-check-sources-have-documents', 'application-br7-check-sources-have-documents', 'sql', 'Documents lodged with an application should have a scanned image file (or other source file) attached::::Документы присутствующие в заявлении должны иметь прикрепленную отсканированную копию.::::الوثائق المرتبطة بالطلب يجب ان يكون لها صور ممسوحة ومرفقة::::Documents lodged with an application should have a scanned image file (or other source file) attached::::Los Documentos presentados con la solicitud deben tener un archivo adjunto ya sea una imagen escaneado (o otro archivo de origen)::::::::Documentos apresentados com o pedido devem ter um arquivo de imagem digitalizada (ou outro tipo de arquivo) anexado::::::::和申请一道递交的文件应附加一个扫描图像文件（或其他来源的文件）', NULL, 'Checks that each document lodged with the application has a scanned image file (or other digital source file) stored in the SOLA database. To remedy the failure of the business rule add the scanned image to the document record through the Document Tab in the Application form or use the Document Toolbar item in the Main form.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-verifies-identification', 'application-verifies-identification', 'sql', 'Personal identification verification should be attached to the application.::::Персональный идентификационный документ должен быть прикреплен к заявлению.::::يجب ارفاق وثائق التعريف الشخصية مع الطلب::::La vérification de l''identité personnelle doit être attachée à la demande.::::Verificación de la identificación personal se debe adjuntar a la solicitud.::::::::Verificação de identificação pessoal deve ser anexada ao pedido.::::::::个人身份证明应附加到申请中。', NULL, '#{id}(application.application.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('app-current-caveat-and-no-remove-or-vary', 'app-current-caveat-and-no-remove-or-vary', 'sql', 'The identified property has a current or pending caveat registered on the title. The application must include a cancel or waiver/vary caveat service for registration to proceed.::::Выбранная недвижимость имеет арест. Заявление должно включать услугу снятия ареста для того чтобы продолжить регистрацию.::::الملكية المحددة عليها قيود . يجب الغاء القيود او التنازل عنها قبل امكانية الاستمرار::::Une caveat en cours ou en attente est enregistré sur le titre de la propriété identifiée. Il est nécessaire de procéder à un service d''annulation ou de renonciation/variation du caveat avant de procéder à l''enregistrement de la demande.::::La propiedad identificada tiene una advertencia actual o pendiente registrada en el título. La solicitud debe incluir una cancelación o servicio de renuncia/variación de la salvedad de registro para poder proceder.::::::::A propriedade identificada tem um embargo atual ou pendente registrado no título. O pedido deve incluir o cancelamento ou renúncia/modificação do embargo para que o registro possa ser continuado.::::::::明确的财产具有与所登记产权相关的当前或待定的附加权利。申请必须包括取消或豁免/变更附加说明以使登记继续。', NULL, '#{id}(application.application.id) is requested. It checks if there is a caveat (pending or current) registered
 on the title and if the application does not have any service of type remove or vary caveat');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('app-other-app-with-caveat', 'app-other-app-with-caveat', 'sql', 'The identified property is affected by another live application that includes a service to register a caveat. An application with a cancel or waiver/vary caveat service must be registered before this application can proceed.::::Выбранная недвижимость используется в другом заявлении, находящемся в обработке и включающее регистрацию ареста. Заявление с услугой отмены ареста должно быть зарегистрировано для того чтобы продолжить с текущим заявлением.::::هناك طلب أخر على الملكية المحددة والذي يحتوي  خدمة فيها قيود على نفس الملكية. يجب التنازل او الغاء القيود قبل امكانية الاستمرار::::La propriété identifiée est affectée par une autre demande en cours qui inclue un service d''enregistrement de caveat. Une demande de service d''annulation ou de variation/résiliation du caveat doit être enregistrée avant de pouvoir procéder à cette demande.::::La propiedad identificada es afectada por otra aplicación en vivo que incluye un servicio de registro de una advertencia. Una aplicación con una cancelación o renuncia / servicio de variación de advertencia, debe estar registrado antes de que esta solicitud puede proceder.::::::::A propriedade identificada é afetada por outro pedido que inclui um serviço de cadastro de embargo. Um pedido com o cancelamento ou desistência/modificação do embargo, deve ser registrado antes que este pedido possa ser continuado.::::::::确定的财产受另一项包括有附加说明登记的有效申请的影响。一项具有取消或豁免/变更附加说明的服务必须在这项申请继续之前被登记。 ', NULL, '#{id}(application.application.id) is requested.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-cancel-property-service-before-new-title', 'application-cancel-property-service-before-new-title', 'sql', 'New Freehold title service must come before Cancel Title service in the application.::::Услуга нового права собственности (свободное) должна быть перед услугой отмены права собственности.
system.br.application-approve-cancel-old-titles.feedback Заявление с услугой нового права собственности (свободное) должно также включать услугу ликвидации родительского права собственности.::::خدمة تسجيل ملكية حرة يجب ان تسبق خدمة الغاء ملكية في الطلب::::Un service de nouveau titre de propriété franche doit venir avant le service d''annulation du titre dans la demande.::::Nuevo servicio de propiedad absoluta debe venir antes de cancelar el servicio de titulo en la aplicación::::::::Um novo título de Propriedade Livre deve vir antes que o Cancelamento do Título no pedido.::::::::新的终身保有产权服务必须在申请中的产权服务取消之前进行。 ', NULL, '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('app-title-has-primary-right', 'app-title-has-primary-right', 'sql', 'A single primary right (such as ownership) must be identified whenever a new title record is created::::Единственное право собственности должно быть зарегистрировано для нового объекта недвижимости.::::يجب تحديد حق اساسي وحيد  عند انشاء سند ملكية جديد::::Un unique droit principal (tel que la propriété) doit être identifié lorsqu''un nouveau titre est créé.::::Un único derecho primario (como la propiedad) debe identificarse cada vez que se crea un nuevo registro de título::::::::O direito fundamental individual (como a posse) deve ser identificado sempre que um novo registro do título for criado.::::::::无论新的产权记录是在何时创建的，单一的基本权利(如所有权) 必须明确。', NULL, '#{id}(application.application.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-on-approve-check-services-without-transaction', 'application-on-approve-check-services-without-transaction', 'sql', 'Within an application,all services making changes to core records must be completed and have utilised an instance of transaction before application can be approved.::::Все услуги в заявлении, которые внесли изменения в основные данные, должны быть завершены перед тем как заявление может быть одобрено.::::تاكد من  ان جميع الخدمات التي تؤدي الى تغييرات على السجلات الاساسية  لها  حالة مكتملة::::Lors d''une demande, tous les services faisant des changements aux données clés doivent être exécutés et avoir utilisés une instance de transaction avant que la demande soit approuvée.::::Dentro de una aplicación, todos los servicios que hacen cambios en los registros centrales deben ser completados y han utilizado una instancia de la transacción antes de la aplicación puede ser aprobada.::::::::No pedido, todos os serviços que fazem alterações nos registros centrais devem ser concluidos e ter utilizado uma instância de transação antes do pedido ser aprovado.::::::::在申请被接受之前，申请中改变核心记录的所有服务必须完整并利用了交易实例。', NULL, 'Checks that all services have the status of completed and that there is a transaction record referring to each service record through the field from_service_id');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('spatial-unit-group-inside-other-spatial-unit-group', 'spatial-unit-group-inside-other-spatial-unit-group', 'sql', 'Spatial unit groups that are not of the top hierarchy must be spatially inside another spatial unit group with hierarchy which is a level up. Tolerance of 0.5 m is applied.::::Пространственные группы, которые не находятся на самой вершине иерархии, должны быть расположены внутри других пространственных групп с более высшим уровнем иерархии. Погрешность может составлять 0.5 м.::::مجموعة الوحدات المكانية والتي ليست جزءا من أعلى البناء الهرمي يجب ان تكون في داخل وحدات مكانية اعلى منها بالمستوى.  سيتم تطبيق سماحية لا تتعدى 0.5 متر::::::::Grupos de unidades espaciales que no son de la jerarquía superior deben estar espacialmente dentro de otro grupo de unidad espacial con la jerarquía que es un nivel hacia arriba. Se aplica la tolerancia de 0,5 m.::::::::Grupos de unidade espaciais que não estão no topo da hierarquia devem estar espacialmente dentro de outro grupo com hierarquia em um nível superior. Tolerância aplicada de 0.5 m.::::::::非顶层的空间单元组必须在空间上内置于另一个上层的空间单元。适用限度是0.5米。', NULL, 'There is no parameter required.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br5-check-there-are-front-desk-services', 'application-br5-check-there-are-front-desk-services', 'sql', 'There are services in this application that should  be dealt in the front office. These services are of type: serviceEnquiry, documentCopy, cadastrePrint, surveyPlanCopy, titleSearch.::::В заявлении имеются услуги, которые должны предоставляться в отделе приема документов. У ним относятся: serviceEnquiry, documentCopy, cadastrePrint, surveyPlanCopy, titleSearch.::::بعض الخدمات المطلوبة في الطلب يجب التعامل معها من المكتب الامامي . هذه الخدمات : الاستفسار , تصوير وثيقة , طباعة مساحة ,  خطة المساحة , البحث عن سند ملكية::::Certains services de cette demande doivent être traitées par la réception. Ces services de type: service enquête, copie de document, impression cadastre, copie de plan de levé, recherche de titre.::::Hay servicios en esta solicitud que debe ser tratado en la oficina principal. Estos servicios son de tipo: Consulta servicio, Copia de Documento, Impresión de Catastro, Copia de Plan Topográfico, Busqueda de Titulo.::::::::Existem serviços neste pedido que devem ser tratados no escritório. Estes serviços são do tipo: serviço Averiguar, Cópia do documento, Imprimir cadastro, Cópia do Plano Vistoriado, Localizar título.::::::::申请中有些服务应该由行政办公室来处理。这些服务分成几类：问讯服务、文件复印、地籍打印、调查方案复制以及产权调查等。', NULL, 'Checks the services in the applications to see if they are amongst services considered as front office services');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-for-new-title-has-cancel-property-service', 'application-for-new-title-has-cancel-property-service', 'sql', 'When a new title is created there must be a cancel title service in the application for the parent title.::::Когда создается новый объект недвижимости, должна присутствовать услуга ликвидации недвижимости в заявлении родительской недвижимости.::::عند خلق سند ملكية جديد يجب ان يحتوي الطلب على خدمة  الغاء سند الملكية الاب::::Quand un nouveau titre est créé, un service de demande d''annulation de titre pour la propriété parent doit apparaître dans la demande.::::Cuando se crea un nuevo título que debe haber un servicio de cancelar título en la aplicación para el título de los padres.::::::::Quando um novo título é criado deve haver um serviço no pedido para cancelar o título principal.::::::::创建一项新产权时，源产权申请中必须有一项取消的产权服务。', NULL, '');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('documents-present', 'documents-present', 'sql', 'Documents attached to the objects, created or modified through the service, must have a scanned image file (or other source file)::::Документы прикреплённые к объектам, созданные или измененные через услуги, должны иметь прикрепленную отсканированную копию.::::المستندات المرفقة للكائنات، التي تم إنشاؤها أو تعديلها من خلال هذه الخدمة، يجب أن يكون لديها ملف الصورة الممسوحة ضوئيا (أو ملف مصدر آخر::::Les documents attaché à des objets, créés ou modifiés à travers un service, doivent contenir un fichier d''image scannée (ou fichier d''une autre source).::::Documentos adjuntos a los objetos, creados o modificados a través del servicio, deben tener un archivo de imagen escaneada (u otro archivo de origen)::::::::Documentos anexados aos objetos, criados ou modificados pelo serviço, devem ter um arquivo de imagem digital (ou outro arquivo de origem)::::::::通过服务创建或修改、随标的附上的文件必须有扫描的图像文件(或其他来源的文件)。', NULL, '#{id}(service_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-baunit-check-area', 'application-baunit-check-area', 'sql', 'Title has the same area as the combined area of its associated parcels::::Недвижимость должна иметь такую же площадь как все ее земельные участки.::::المساحة المعرفة في سند الملكية تساوي مجموع مساحات القطع لهذه المنطقة::::Le titre a la même superficie que la superficie combinée des parcelles qui y sont associées.::::Título tiene la misma área que el área combinada de sus parcelas asociadas::::::::Título tem a mesma área que a área combinada das suas parcelas associadas::::::::财产应与相关地块的合并面积一致。', NULL, '#{id}(ba_unit_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('mortgage-value-check', 'mortgage-value-check', 'sql', 'For the Register Mortgage service, the new mortgage is for less than the reported value of property (at time application was received)::::Сумма зарегистрированной ипотеки, меньше чем заявленная стоимость недвижимости (во время подачи заявления).::::في خدمة تسجيل رهن قيمة الرهن يجب ان تكون اقل قيمة الملكية  وقت استلام الطلب::::Pour le service d''enregistrement d''un hypothèque, la nouvelle hypothèque est inférieure à la valeur déclarée de la propriété (au moment où la demande a été reçue).::::Para el servicio de Registro de Hipoteca, la nueva hipoteca es por menos del valor declarado de la propiedad (al momento que la solicitud fue recibida)::::::::Para o serviço Cadastrar Hipoteca, o valor da nova hipoteca deve ser menor que o valor da propriedade (no momento que o pedido foi recebido)::::::::对于抵押服务登记，新的抵押是针对小于报告值的财产 (在申请被受理时）而言的。', NULL, '#{id}(application.service.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('target-and-new-union-the-same', 'target-and-new-union-the-same', 'sql', 'The union of new parcel polygons is the same with the union of the target parcel polygons::::Объединение полигонов новых участков должно быть таким же как форма полигонов целевых участков.::::الاتحاد بين مضلعات القطعة الجديدة يساوي الاتحاد بين مضلعات القطعة المستهدفة::::L''union des polygones des nouvelles parcells est le même que l''union des polygones des parcelles cibles.::::La unión de los nuevos polígonos de parcela es la misma con la unión de los polígonos de parcela de destino::::::::A união de polígonos de novas parcelas é o mesmo que a união dos polígonos das parcelas alvo::::::::新地块多边形的联合与目标宗地多边形是相同的。', NULL, '#{id}(transaction_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('public-display-check-complete-status', 'public-display-check-complete-status', 'sql', 'At least 90% of the parcels must have an associated Systematic Application with complete status.::::По крайней мере 90% участков должны иметь соответствующие заявления на системную регистрацию с завершенным статусом.::::على الأقل 90% من القطع يجب ان يكون لها  ارتباط بالطلب المنتظم وبحالة مكتملة ::::::::Al menos el 90% de las parcelas debe disponer de una aplicación sistemática asociada con el estatus completo.::::::::Pelo menos 90% das parcelas devem ter um Pedido Regular associado com o estado concluído.::::::::至少90% 的地块必须有与完成情况相关的系统申请。', NULL, '#{lastPart}(name_lastpart) is requested');


ALTER TABLE br ENABLE TRIGGER ALL;

--
-- Data for Name: br_definition; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE br_definition DISABLE TRIGGER ALL;

INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-notation-reference-nr', '2014-02-20', 'infinity', 'SELECT coalesce(system.get_setting(''system-id''), '''') || to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''administrative.rrr_nr_seq''), ''0000'')) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-rrr-nr', '2014-02-20', 'infinity', 'SELECT coalesce(system.get_setting(''system-id''), '''') || to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''administrative.rrr_nr_seq''), ''0000'')) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-source-nr', '2014-02-20', 'infinity', 'SELECT coalesce(system.get_setting(''system-id''), '''') || to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''source.source_la_nr_seq''), ''000000000'')) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-baunit-nr', '2014-02-20', 'infinity', 'SELECT coalesce(system.get_setting(''system-id''), '''') || to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.ba_unit_first_name_part_seq''), ''0000''))
|| ''/'' || trim(to_char(nextval(''administrative.ba_unit_last_name_part_seq''), ''0000'')) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-cadastre-object-lastpart', '2014-02-20', 'infinity', 'SELECT cadastre.get_new_cadastre_object_identifier_last_part(#{geom}, #{cadastre_object_type}) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-cadastre-object-firstpart', '2014-02-20', 'infinity', 'SELECT cadastre.get_new_cadastre_object_identifier_first_part(#{last_part}, #{cadastre_object_type}) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-spatial-unit-group-name', '2014-02-20', 'infinity', 'SELECT cadastre.generate_spatial_unit_group_name(get_geometry_with_srid(#{geom_v}), #{hierarchy_level_v}, #{label_v}) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-application-nr', '2014-02-20', 'infinity', 'SELECT coalesce(system.get_setting(''system-id''), '''') || to_char(now(), ''yymm'') || trim(to_char(nextval(''application.application_nr_seq''), ''0000'')) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-on-approve-check-public-display', '2014-02-20', 'infinity', '  SELECT (COUNT(*) = 0)  AS vl
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, 
   application.application_property ap, application.application aa, application.service s, source.source ss
  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = ''officialArea''::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND ap.ba_unit_id::text = su.ba_unit_id::text AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text 
  AND s.request_type_code::text = ''systematicRegn''::text AND s.status_code::text = ''completed''::text
   AND COALESCE(co.land_use_code, ''residential''::character varying)::text = lu.code::text
  and ss.reference_nr = co.name_lastpart
  and ss.reference_nr = co.name_lastpart and ss.expiration_date >= now() 
  and s.application_id = #{id};');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('app-check-title-ref', '2014-02-20', 'infinity', 'WITH 	convertTitleApp	AS	(SELECT se.id FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newDigitalTitle''),
	titleRefChk	AS	(SELECT aprp.application_id FROM application.application_property aprp
				WHERE aprp.application_id= #{id} 
				AND SUBSTR(aprp.name_firstpart, 1) != ''N''
				AND NOT(aprp.name_lastpart ~ ''^[0-9]+$''))--isnumeric test
	
SELECT CASE 	WHEN (SELECT (COUNT(*) = 0) FROM convertTitleApp) THEN NULL
		WHEN (SELECT (COUNT(*) = 0) FROM titleRefChk) THEN TRUE
		ELSE FALSE
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br7-check-sources-have-documents', '2014-02-20', 'infinity', 'SELECT ext_archive_id IS NOT NULL AS vl
FROM source.source 
WHERE id IN (SELECT source_id FROM application.application_uses_source WHERE application_id= #{id})');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('app-allowable-primary-right-for-new-title', '2014-02-20', 'infinity', 'WITH 	newTitleApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code IN (''newFreehold'', ''newApartment'', ''newState'')),
	existTitleApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.application_property prp1
					INNER JOIN application.service sv ON (prp1.application_id = sv.application_id)
				WHERE prp1.application_id = #{id}
				AND sv.request_type_code = ''newDigitalTitle'')
				
 SELECT CASE WHEN (SELECT ((SELECT * FROM newTitleApp) OR (SELECT * FROM existTitleApp)) IS NULL) THEN NULL 
	WHEN ((SELECT COUNT(*) FROM existTitleApp) = 0) THEN	(SELECT (COUNT(*) = 0) FROM application.application_property prp2
									INNER JOIN administrative.rrr rr2 
										ON ((prp2.ba_unit_id = rr2.ba_unit_id) AND NOT(rr2.is_primary OR (rr2.type_code IN (''ownership'', ''apartment'', ''stateOwnership'', ''lease''))))
								 WHERE prp2.application_id = #{id} )
	ELSE	(SELECT (COUNT(*) = 0) FROM application.service sv2 
			 INNER JOIN transaction.transaction tn2 ON (sv2.id = tn2.from_service_id) 
			 INNER JOIN administrative.ba_unit ba2 ON (tn2.id = ba2.transaction_id) 
			 INNER JOIN administrative.rrr rr3 
				ON ((ba2.id = rr3.ba_unit_id) AND NOT(rr3.is_primary OR (rr3.type_code IN (''ownership'', ''apartment'', ''stateOwnership'', ''lease''))))
			 WHERE sv2.application_id = #{id} )
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('app-other-app-with-caveat', '2014-02-20', 'infinity', 'SELECT (SELECT COUNT(*) > 0 FROM application.service sv WHERE sv.application_id = ap.application_id AND sv.request_type_code IN (''varyCaveat'', ''removeCaveat'')) AS vl
FROM application.application_property ap
	INNER JOIN application.application_property ap2 ON (((ap.name_firstpart, ap.name_lastpart) = (ap2.name_firstpart, ap2.name_lastpart)) AND (ap.id != ap2.id))
	INNER JOIN application.application app2 ON (ap2.application_id = app2.id)
	INNER JOIN application.service sv2 ON ((app2.id = sv2.application_id) AND (sv2.request_type_code = ''caveat'') AND (sv2.status_code != ''cancelled'') AND (app2.status_code NOT IN (''completed'', ''annulled'')))
WHERE ap.application_id = #{id} 
ORDER BY 1
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-cancel-property-service-before-new-title', '2014-02-20', 'infinity', '
WITH 	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold''),
 	orderCancel	AS	(SELECT service_order + 1 AS cancelSequence FROM application.service sv 
				WHERE sv.application_id = #{id}
				AND sv.request_type_code = ''cancelProperty'' LIMIT 1),	
 	orderNew	AS	(SELECT service_order + 1 AS newSequence FROM application.service sv 
				WHERE sv.application_id = #{id}
				AND sv.request_type_code = ''newFreehold'' LIMIT 1)
				
SELECT CASE WHEN fhCheck IS TRUE THEN ((SELECT cancelSequence FROM orderCancel) - (SELECT newSequence FROM orderNew)) > 0
		ELSE NULL
	END AS vl FROM newFreeholdApp');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('app-title-has-primary-right', '2014-02-20', 'infinity', 'WITH 	newTitleApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code IN (''newFreehold'', ''newApartment'', ''newState'')),
	start_titles	AS	(SELECT DISTINCT ON (pt.from_ba_unit_id) pt.from_ba_unit_id, s.application_id FROM administrative.rrr rr 
				INNER JOIN administrative.required_relationship_baunit pt ON (rr.ba_unit_id = pt.to_ba_unit_id)
				INNER JOIN transaction.transaction tn ON (rr.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN application.application ap ON (s.application_id = ap.id)
				WHERE ap.id = #{id}),
	start_primary_rrr AS 	(SELECT DISTINCT ON(pp.nr) pp.nr FROM administrative.rrr pp 
				WHERE pp.status_code != ''cancelled''
				AND pp.is_primary
				AND pp.ba_unit_id IN (SELECT from_ba_unit_id  FROM start_titles))

SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT sum(1) FROM start_primary_rrr) = 1
		ELSE NULL
	END AS vl FROM newTitleApp');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br2-check-title-documents-not-old', '2014-02-20', 'infinity', 'SELECT s.recordation + 1 * interval ''1 week'' > NOW() AS vl
FROM application.application_uses_source a_s 
	INNER JOIN source.source s ON (a_s.source_id= s.id)
WHERE a_s.application_id = #{id}
AND s.type_code = ''title''');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('applicant-name-to-owner-name-check', '2014-02-20', 'infinity', 'WITH apStr AS (SELECT  COALESCE(name, '''') || '' '' || COALESCE(last_name, '''') AS searchStr FROM party.party pty
		INNER JOIN application.application ap ON (ap.contact_person_id = pty.id)
		WHERE ap.id = #{id}),
     apStr2 AS (SELECT  COALESCE(last_name, '''') AS searchStr FROM party.party pty
		INNER JOIN application.application ap ON (ap.contact_person_id = pty.id)
		WHERE ap.id = #{id}),
    poaQuery AS (SELECT pty.name AS firstName, pty.last_name AS lastName FROM application.application_property ap
			INNER JOIN administrative.ba_unit ba ON ((ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart))
			INNER JOIN administrative.rrr rr ON ((ba.id = rr.ba_unit_id) AND (rr.status_code = ''current'') AND rr.is_primary)
			INNER JOIN administrative.rrr_share rs ON (rr.id = rs.rrr_id)
			INNER JOIN administrative.party_for_rrr pr ON (rs.rrr_id = pr.rrr_id)
			INNER JOIN party.party pty ON (pr.party_id = pty.id)
		WHERE ap.application_id = #{id})

SELECT CASE WHEN (COUNT(*) > 0) THEN TRUE
		ELSE NULL
	END AS vl FROM poaQuery
WHERE (compare_strings((SELECT searchStr FROM apStr), COALESCE(firstName, '''') || '' '' || COALESCE(lastName, '''')) OR compare_strings((SELECT searchStr FROM apStr2), COALESCE(firstName, '''') || '' '' || COALESCE(lastName, '''')))
ORDER BY vl
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br3-check-properties-are-not-historic', '2014-02-20', 'infinity', 'WITH baUnitRecs AS	(SELECT ba.status_code AS status FROM application.application_property ap
				INNER JOIN administrative.ba_unit ba ON ((ap.name_lastpart = ba.name_lastpart) AND (ap.name_firstpart = ba.name_firstpart))
			WHERE application_id= #{id})

SELECT	CASE 	WHEN (SELECT (COUNT(*) = 0) FROM baUnitRecs) THEN NULL
		WHEN (COUNT(*) = 0) THEN TRUE
		ELSE  FALSE
	END AS vl FROM baUnitRecs
WHERE status = ''historic''
ORDER BY 1
LIMIT 1 ');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br4-check-sources-date-not-in-the-future', '2014-02-20', 'infinity', 'SELECT ss.recordation < NOW() as vl FROM application.application_uses_source a_s
	INNER JOIN source.source ss ON (a_s.source_id = ss.id)
	WHERE a_s.application_id = #{id}
ORDER BY 1
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br6-check-new-title-service-is-needed', '2014-02-20', 'infinity', 'SELECT	CASE	WHEN (name_firstpart, name_lastpart) NOT IN (SELECT name_firstpart, name_lastpart FROM administrative.ba_unit)
			THEN (SELECT (COUNT(*) > 0) FROM application.service WHERE request_type_code = ''newFreehold'')
		ELSE TRUE
	END AS vl
FROM application.application_property  
WHERE application_id=#{id}
ORDER BY 1
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-on-approve-check-services-status', '2014-02-20', 'infinity', 'SELECT (COUNT(*) = 0)  AS vl FROM application.service sv 
WHERE sv.application_id = #{id} 
AND sv.status_code NOT IN (''completed'', ''cancelled'')');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-on-approve-check-services-without-transaction', '2014-02-20', 'infinity', 'SELECT (COUNT(*) = 0) AS vl FROM application.service sv 
	INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
WHERE sv.application_id = #{id} 
AND sv.status_code NOT IN (''completed'', ''cancelled'')');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-on-approve-check-systematic-reg-no-objection', '2014-02-20', 'infinity', '  SELECT (COUNT(*) = 0)  AS vl
   FROM  application.application aa, 
   application.service s
  WHERE  s.application_id::text = aa.id::text 
  AND s.application_id::text in (select s.application_id 
                                 FROM application.service s
                                 where s.request_type_code::text = ''systematicRegn''::text
                                 and s.application_id = #{id}) 
  AND s.request_type_code::text = ''lodgeObjection''::text
  AND s.status_code::text != ''cancelled''::text
  and s.application_id = #{id};');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br8-check-has-services', '2014-02-20', 'infinity', 'SELECT (COUNT(*) > 0) AS vl
FROM application.service sv 
WHERE sv.application_id = #{id}
AND sv.status_code != ''cancelled''');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-verifies-identification', '2014-02-20', 'infinity', 'SELECT (CASE 	WHEN app.id is  NULL THEN NULL
		ELSE COUNT(1) > 0
	 END) as vl
FROM application.application app
  LEFT JOIN application.application_uses_source aus ON (aus.application_id = app.id)
  LEFT JOIN source.source sc ON ((sc.id = aus.source_id) AND (sc.type_code = ''idVerification''))
WHERE app.id= #{id}
GROUP BY app.id
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('newtitle-br24-check-rrr-accounted', '2014-02-20', 'infinity', '
WITH 	pending_property_rrr AS (SELECT DISTINCT ON(rp.nr) rp.nr FROM administrative.rrr rp 
				INNER JOIN transaction.transaction tn ON (rp.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN application.application ap ON (s.application_id = ap.id)
				WHERE ap.id = #{id}
				AND rp.status_code = ''pending''),
								
	parent_titles	AS	(SELECT DISTINCT ON (ba.id) ba.id AS liveTitle, from_ba_unit_id FROM administrative.ba_unit ba
				INNER JOIN transaction.transaction tn ON (ba.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN administrative.required_relationship_baunit pt ON (ba.id = pt.to_ba_unit_id)
				WHERE s.application_id = #{id}),
				
	new_titles	AS	(SELECT DISTINCT ON (rr.ba_unit_id) rr.ba_unit_id FROM administrative.rrr rr 
				INNER JOIN administrative.ba_unit nt ON (rr.ba_unit_id = nt.id)
				INNER JOIN transaction.transaction tn ON (rr.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN application.application ap ON (s.application_id = ap.id)
				WHERE ap.id = #{id}),
	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold''),
					
	prior_property_rrr AS 	(SELECT DISTINCT ON(pp.nr) pp.nr FROM administrative.rrr pp 
				WHERE pp.status_code = ''current''
				AND pp.ba_unit_id IN (SELECT from_ba_unit_id  FROM parent_titles)),

	rem_property_rrr AS	(SELECT nr FROM prior_property_rrr WHERE nr NOT IN (SELECT nr FROM pending_property_rrr))
				
SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT COUNT(nr) FROM rem_property_rrr) = 0
		ELSE NULL
	END AS vl FROM newFreeholdApp');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br1-check-required-sources-are-present', '2014-02-20', 'infinity', 'WITH reqForAp AS 	(SELECT DISTINCT ON(r_s.source_type_code) r_s.source_type_code AS typeCode
			FROM application.request_type_requires_source_type r_s 
				INNER JOIN application.service sv ON((r_s.request_type_code = sv.request_type_code) AND (sv.status_code != ''cancelled''))
			WHERE sv.application_id = #{id}),
     inclInAp AS	(SELECT DISTINCT ON (sc.id) sc.id FROM reqForAp req
				INNER JOIN source.source sc ON (req.typeCode = sc.type_code)
				INNER JOIN application.application_uses_source a_s ON ((sc.id = a_s.source_id) AND (a_s.application_id = #{id})))
SELECT 	CASE 	WHEN (SELECT (SUM(1) IS NULL) FROM reqForAp) THEN NULL
		WHEN ((SELECT COUNT(*) FROM inclInAp) - (SELECT COUNT(*) FROM reqForAp) >= 0) THEN TRUE
		ELSE FALSE
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-approve-cancel-old-titles', '2014-02-20', 'infinity', '
WITH 	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold''),
	parent_titles	AS	(SELECT DISTINCT ON (ba.id) ba.id AS liveTitle, ba.status_code FROM administrative.ba_unit ba
				INNER JOIN transaction.transaction tn ON (ba.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN administrative.required_relationship_baunit pt ON (ba.id = pt.to_ba_unit_id)
				WHERE s.application_id = #{id}
				AND ba.status_code = ''pending'')
				
SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT COUNT(liveTitle) FROM parent_titles) > 0
		ELSE NULL
	END AS vl FROM newFreeholdApp
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br5-check-there-are-front-desk-services', '2014-02-20', 'infinity', 'SELECT CASE WHEN (COUNT(*)= 0) THEN NULL
	ELSE FALSE 
	end AS vl
FROM application.service
WHERE application_id = #{id} 
AND action_code != ''cancel''
AND request_type_code IN (''serviceEnquiry'', ''documentCopy'', ''cadastrePrint'', ''surveyPlanCopy'', ''titleSearch'')');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-for-new-title-has-cancel-property-service', '2014-02-20', 'infinity', '
WITH 	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold'')
					
				
SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT COUNT(id) FROM application.service sv 
					WHERE sv.application_id = #{id}
					AND sv.request_type_code = ''cancelProperty'') > 0
		ELSE NULL
	END AS vl FROM newFreeholdApp');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('cancel-title-check-rrr-cancelled', '2014-02-20', 'infinity', 'WITH 	pending_property_rrr AS (SELECT DISTINCT ON(rr1.nr) rr1.nr FROM administrative.rrr rr1 
				INNER JOIN transaction.transaction tn ON (rr1.transaction_id = tn.id)
				INNER JOIN application.service sv1 ON (tn.from_service_id = sv1.id) 
				WHERE sv1.application_id = #{id}
				AND rr1.status_code = ''pending''),
								
	target_title	AS	(SELECT prp.ba_unit_id AS liveTitle FROM application.application_property prp
				WHERE prp.application_id = #{id}),
				
	cancelPropApp	AS	(SELECT sv3.id AS fhCheck, sv3.request_type_code FROM application.service sv3
				WHERE sv3.application_id = #{id}
				AND sv3.request_type_code = ''cancelProperty''),
					
	current_rrr AS 		(SELECT DISTINCT ON(rr2.nr) rr2.nr FROM administrative.rrr rr2 
				WHERE rr2.status_code = ''current''
				AND rr2.ba_unit_id IN (SELECT liveTitle FROM target_title)),

	rem_property_rrr AS	(SELECT nr FROM current_rrr WHERE nr NOT IN (SELECT nr FROM pending_property_rrr))
				
SELECT CASE 	WHEN (SELECT (COUNT(*) = 0) FROM cancelPropApp) THEN NULL
		WHEN (SELECT (COUNT(*) = 0) FROM pending_property_rrr) THEN FALSE
		WHEN (SELECT (COUNT(*) = 0) FROM rem_property_rrr) THEN TRUE
		ELSE FALSE
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('app-current-caveat-and-no-remove-or-vary', '2014-02-20', 'infinity', 'SELECT (SELECT (COUNT(*) > 0) FROM application.service sv 
  WHERE ((sv.application_id = ap.application_id) AND (sv.request_type_code IN (''varyCaveat'', ''removeCaveat'')))) AS vl
FROM application.application_property ap 
  INNER JOIN administrative.ba_unit ba ON ((ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart))
  LEFT JOIN administrative.rrr ON (rrr.ba_unit_id = ba.id)
WHERE ((ap.application_id = #{id}) AND (rrr.type_code = ''caveat'') AND (rrr.status_code IN (''pending'', ''current'')))
ORDER BY 1 desc
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('documents-present', '2014-02-20', 'infinity', 'WITH cadastreDocs AS 	(SELECT DISTINCT ON (id) ss.id, ext_archive_id FROM source.source ss
				INNER JOIN transaction.transaction_source ts ON (ss.id = ts.source_id)
				INNER JOIN transaction.transaction tn ON(ts.transaction_id = tn.id)
				WHERE tn.from_service_id = #{id}
				ORDER BY 1),
	rrrDocs AS	(SELECT DISTINCT ON (id) ss.id, ext_archive_id FROM source.source ss
				INNER JOIN administrative.source_describes_rrr sr ON (ss.id = sr.source_id)
				INNER JOIN administrative.rrr rr ON (sr.rrr_id = rr.id)
				INNER JOIN transaction.transaction tn ON(rr.transaction_id = tn.id)
				WHERE tn.from_service_id = #{id}
				ORDER BY 1),
     titleDocs AS	(SELECT DISTINCT ON (id) ss.id, ext_archive_id FROM source.source ss
				INNER JOIN administrative.source_describes_ba_unit su ON (ss.id = su.source_id)
				WHERE su.ba_unit_id IN (SELECT  ba_unit_id FROM rrrDocs)
				ORDER BY 1),
     regDocs AS		(SELECT DISTINCT ON (id) ss.id, ext_archive_id FROM source.source ss
				INNER JOIN transaction.transaction tn ON (ss.transaction_id = tn.id)
				INNER JOIN application.service sv ON (tn.from_service_id = sv.id)
				WHERE sv.id = #{id}
				AND sv.request_type_code IN (''regnPowerOfAttorney'', ''regnStandardDocument'', ''cnclPowerOfAttorney'', ''cnclStandardDocument'')
				ORDER BY 1),
     serviceDocs AS	((SELECT * FROM rrrDocs) UNION (SELECT * FROM cadastreDocs) UNION (SELECT * FROM titleDocs) UNION (SELECT * FROM regDocs))
     
     
 SELECT (((SELECT COUNT(*) FROM serviceDocs) - (SELECT COUNT(*) FROM serviceDocs WHERE ext_archive_id IS NOT NULL)) = 0) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-baunit-has-parcels', '2014-02-20', 'infinity', 'select (select count(*)>0 from administrative.ba_unit_contains_spatial_unit ba_su 
		inner join cadastre.cadastre_object co on ba_su.spatial_unit_id= co.id
	where co.status_code in (''current'') and co.geom_polygon is not null and ba_su.ba_unit_id= ba.id) as vl
from application.service s 
	inner join application.application_property ap on (s.application_id= ap.application_id)
	INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
where s.id = #{id}
order by 1
limit 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('current-rrr-for-variation-or-cancellation-check', '2014-02-20', 'infinity', 'SELECT (SUM(1) > 0) AS vl FROM application.service sv 
			INNER JOIN application.application_property ap ON (sv.application_id = ap.application_id )
			  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
			  INNER JOIN administrative.rrr rr ON rr.ba_unit_id = ba.id
			  WHERE sv.id = #{id}
			  AND sv.request_type_code IN (SELECT code FROM application.request_type WHERE ((status = ''c'') AND (type_action_code IN (''vary'', ''cancel''))))
			  AND NOT(rr.is_primary)
			  AND rr.status_code = ''current''
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('power-of-attorney-owner-check', '2014-02-20', 'infinity', 'WITH poaQuery AS (SELECT person_name, py.name AS firstName, py.last_name AS lastName FROM transaction.transaction tn
			INNER JOIN administrative.rrr rr ON (tn.id = rr.transaction_id) 
			INNER JOIN administrative.ba_unit ba ON (rr.ba_unit_id = ba.id)
			INNER JOIN administrative.rrr r2 ON ((ba.id = r2.ba_unit_id) AND (r2.status_code = ''current'') AND r2.is_primary)
			INNER JOIN administrative.rrr_share rs ON (r2.id = rs.rrr_id)
			INNER JOIN administrative.party_for_rrr pr ON (rs.rrr_id = pr.rrr_id)
			INNER JOIN party.party py ON (pr.party_id = py.id)
			INNER JOIN administrative.source_describes_rrr sr ON (rr.id = sr.rrr_id)
			INNER JOIN source.power_of_attorney pa ON (sr.source_id = pa.id)
		WHERE tn.from_service_id = #{id})
SELECT CASE WHEN (COUNT(*) > 0) THEN TRUE
		ELSE NULL
	END AS vl FROM poaQuery
WHERE compare_strings(person_name, COALESCE(firstName, '''') || '' '' || COALESCE(lastName, ''''))
ORDER BY vl
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('service-has-person-verification', '2014-02-20', 'infinity', 'SELECT (CASE 	WHEN sv.application_id is  NULL THEN NULL
		ELSE COUNT(1) > 0
	 END) as vl
FROM application.service sv
  LEFT JOIN application.application_uses_source aus ON (aus.application_id = sv.application_id)
  LEFT JOIN source.source sc ON ((sc.id = aus.source_id) AND (sc.type_code = ''idVerification''))
WHERE sv.id= #{id}
GROUP BY sv.application_id
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('rrr-has-pending', '2014-02-20', 'infinity', 'select count(*) = 0 as vl
from administrative.rrr rrr1 inner join administrative.rrr rrr2 on (rrr1.ba_unit_id, rrr1.nr) = (rrr2.ba_unit_id, rrr2.nr)
where rrr1.id = #{id} and rrr2.id!=rrr1.id and rrr2.status_code = ''pending''
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('ba_unit-has-a-valid-primary-right', '2014-02-20', 'infinity', 'SELECT (COUNT(*) = 1) AS vl FROM administrative.rrr rr1 
	 INNER JOIN administrative.ba_unit ba ON (rr1.ba_unit_id = ba.id)
	 INNER JOIN transaction.transaction tn ON (rr1.transaction_id = tn.id)
	 INNER JOIN application.service sv ON ((tn.from_service_id = sv.id) AND (sv.request_type_code != ''cancelProperty''))
 WHERE ba.id = #{id}
 AND rr1.status_code != ''cancelled''
 AND rr1.is_primary
 AND rr1.type_code IN (''ownership'', ''apartment'', ''stateOwnership'', ''lease'')');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-baunit-check-area', '2014-02-20', 'infinity', 'select
       ( 
         select coalesce(cast(sum(a.size)as float),0)
	 from administrative.ba_unit_area a
         inner join administrative.ba_unit ba
         on a.ba_unit_id = ba.id
         where ba.transaction_id = #{id}
         and a.type_code =  ''officialArea''
       ) 
   = 

       (
         select coalesce(cast(sum(a.size)as float),0)
	 from cadastre.spatial_value_area a
	 where  a.type_code = ''officialArea''
	 and a.spatial_unit_id in
           (  select b.spatial_unit_id
              from administrative.ba_unit_contains_spatial_unit b
              inner join administrative.ba_unit ba
	      on b.ba_unit_id = ba.id
	      where ba.transaction_id = #{id}
           )

        ) as vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('baunit-has-multiple-mortgages', '2014-02-20', 'infinity', 'SELECT	(SELECT (COUNT(*) = 0) FROM application.service sv2
		 INNER JOIN transaction.transaction tn ON (sv2.id = tn.from_service_id)
		 INNER JOIN administrative.rrr rr ON (tn.id = rr.transaction_id)
		 INNER JOIN administrative.rrr rr2 ON ((rr.ba_unit_id = rr2.ba_unit_id) AND (rr2.type_code = ''mortgage'') AND (rr2.status_code =''current'') ) 
	WHERE sv.id = #{id}) AS vl FROM application.service sv
WHERE sv.id = #{id}
AND sv.request_type_code = ''mortgage''
ORDER BY 1
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('document-supporting-rrr-is-current', '2014-02-20', 'infinity', 'WITH serviceDocs AS	(SELECT DISTINCT ON (sc.id) sv.id AS sv_id, sc.id AS sc_id, sc.status_code, sc.type_code FROM application.service sv
				INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
				INNER JOIN administrative.rrr rr ON (tn.id = rr.transaction_id)
				INNER JOIN administrative.source_describes_rrr sr ON (rr.id = sr.rrr_id)
				INNER JOIN source.source sc ON (sr.source_id = sc.id)
				WHERE sv.id = #{id}),
    nullDocs AS		(SELECT sc_id, type_code FROM serviceDocs WHERE status_code IS NULL),
    transDocs AS	(SELECT sc_id, type_code FROM serviceDocs WHERE status_code = ''current'' AND ((type_code = ''powerOfAttorney'') OR (type_code = ''standardDocument'')))
SELECT ((SELECT COUNT(*) FROM serviceDocs) - (SELECT COUNT(*) FROM nullDocs) - (SELECT COUNT(*) FROM transDocs) = 0) AS vl
ORDER BY 1
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('mortgage-value-check', '2014-02-20', 'infinity', 'SELECT (ap.total_value < rrr.amount) AS vl 
  from application.service s inner join application.application_property ap on s.application_id = ap.application_id 
 INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
 INNER JOIN administrative.rrr ON rrr.ba_unit_id = ba.id
WHERE s.id = #{id} and rrr.type_code= ''mortgage'' and rrr.status_code in (''pending'')
order by 1
limit 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('power-of-attorney-service-has-document', '2014-02-20', 'infinity', 'SELECT (SUM(1) = 1) AS vl, get_translation(rt.display_value, #{lng}) as req_type FROM application.service sv
	 INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
	 INNER JOIN source.source sc ON (tn.id = sc.transaction_id)
	 INNER JOIN application.request_type rt ON (sv.request_type_code = rt.code AND request_category_code = ''registrationServices'')
WHERE sv.id =#{id}
AND sc.type_code = ''powerOfAttorney''
GROUP BY rt.code
ORDER BY 1
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('required-sources-are-present', '2014-02-20', 'infinity', 'WITH reqForSv AS 	(SELECT r_s.source_type_code AS typeCode
			FROM application.request_type_requires_source_type r_s 
				INNER JOIN application.service sv ON((r_s.request_type_code = sv.request_type_code) AND (sv.status_code != ''cancelled''))
			WHERE sv.id = #{id}),
     inclInSv AS	(SELECT DISTINCT ON (sc.id) get_translation(rt.display_value, #{lng}) AS req_type FROM reqForSv req
				INNER JOIN source.source sc ON (req.typeCode = sc.type_code)
				INNER JOIN application.application_uses_source a_s ON (sc.id = a_s.source_id)
				INNER JOIN application.service sv ON ((a_s.application_id = sv.application_id) AND (sv.id = #{id}))
				INNER JOIN application.request_type rt ON (sv.request_type_code = rt.code))

SELECT 	CASE 	WHEN (SELECT (SUM(1) IS NULL) FROM reqForSv) THEN NULL
		WHEN ((SELECT COUNT(*) FROM inclInSv) - (SELECT COUNT(*) FROM reqForSv) >= 0) THEN TRUE
		ELSE FALSE
	END AS vl, req_type FROM inclInSv
ORDER BY vl
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('service-on-complete-without-transaction', '2014-02-20', 'infinity', 'select id in (select from_service_id from transaction.transaction where from_service_id is not null) as vl, 
  get_translation(r.display_value, #{lng}) as req_type
from application.service s inner join application.request_type r on s.request_type_code = r.code and request_category_code=''registrationServices''
and s.id= #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('service-title-terminated', '2014-02-20', 'infinity', 'WITH reqForSv AS 	(SELECT sv.id, get_translation(rt.display_value, #{lng}) AS req_type FROM application.service sv 
				INNER JOIN application.request_type rt ON (sv.request_type_code = rt.code)
			WHERE sv.id = #{id} 
			AND sv.request_type_code = ''cancelProperty''),
     checkTitle AS	(SELECT tg.ba_unit_id FROM application.service sv
				INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
				INNER JOIN administrative.ba_unit_target tg ON (tn.id = tg.transaction_id)
			WHERE sv.id = #{id})
SELECT 	CASE 	WHEN (SELECT (COUNT(*) = 0) FROM reqForSv) THEN NULL
		WHEN (SELECT (COUNT(*) > 0) FROM checkTitle) THEN TRUE
		ELSE FALSE
	END AS vl, req_type FROM reqForSv
ORDER BY vl
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('service-check-no-previous-digital-title-service', '2014-02-20', 'infinity', 'SELECT coalesce(not rrr.is_primary, true) as vl
FROM application.service s inner join application.application_property ap on s.application_id = ap.application_id
  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
  LEFT JOIN administrative.rrr ON rrr.ba_unit_id = ba.id
WHERE s.id = #{id} 
order by 1 desc
limit 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('target-ba_unit-check-if-pending', '2014-02-20', 'infinity', 'WITH	otherCancel AS	(SELECT (SELECT (COUNT(*) = 0)FROM administrative.ba_unit_target ba_t2 
				INNER JOIN transaction.transaction tn ON (ba_t2.transaction_id = tn.id)
				WHERE ba_t2.ba_unit_id = ba_t.ba_unit_id
				AND ba_t2.transaction_id != ba_t.transaction_id
				AND tn.status_code != ''approved'') AS chkOther
			FROM administrative.ba_unit_target ba_t
			WHERE ba_t.ba_unit_id = #{id}), 
	cancelAp AS	(SELECT ap.id FROM administrative.ba_unit_target ba_t 
			INNER JOIN application.application_property pr ON (ba_t.ba_unit_id = pr.ba_unit_id)
			INNER JOIN application.service sv ON (pr.application_id = sv.application_id)
			INNER JOIN application.application ap ON (pr.application_id = ap.id)
			WHERE ba_t.ba_unit_id = #{id}
			AND sv.request_type_code = ''cancelProperty''
			AND sv.status_code != ''cancelled''
			AND ap.status_code NOT IN (''annulled'', ''approved'')),
	otherAps AS	(SELECT (SELECT (count(*) = 0) FROM administrative.ba_unit ba
			INNER JOIN administrative.rrr rr ON (ba.id = rr.ba_unit_id)
			INNER JOIN transaction.transaction tn ON (rr.transaction_id = tn.id)
			INNER JOIN application.service sv ON (tn.from_service_id = sv.id)
			INNER JOIN application.application ap ON (sv.application_id = ap.id)
			WHERE ba.id = #{id} 
			AND ap.status_code = ''lodged''
			AND ap.id NOT IN (SELECT id FROM cancelAp)) AS chkNoOtherAps),

	pendingRRR AS	(SELECT (SELECT (count(*) = 0) FROM administrative.rrr rr
				INNER JOIN administrative.ba_unit_target ba_t2 ON (rr.ba_unit_id = ba_t2.ba_unit_id)
				INNER JOIN transaction.transaction t2 ON (ba_t2.transaction_id = t2.id)
				INNER JOIN application.service s2 ON (t2.from_service_id = s2.id) 
				WHERE ba_t2.ba_unit_id = ba_t.ba_unit_id
				AND s2.application_id != s1.application_id
				AND ba_t2.transaction_id != ba_t.transaction_id
				AND rr.status_code = ''pending'') AS chkPend 
			FROM administrative.ba_unit_target ba_t
			INNER JOIN transaction.transaction t1 ON (ba_t.transaction_id = t1.id)
			INNER JOIN application.service s1 ON (t1.from_service_id = s1.id) 
			WHERE ba_t.ba_unit_id = #{id})
SELECT ((SELECT chkPend  FROM pendingRRR) AND (SELECT chkOther FROM otherCancel)  AND (SELECT chkNoOtherAps FROM otherAps)) AS vl 
FROM administrative.ba_unit_target tg
WHERE tg.ba_unit_id  = #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('ba_unit-has-cadastre-object', '2014-02-20', 'infinity', 'SELECT count(*)>0 vl
from administrative.ba_unit_contains_spatial_unit ba_s 
WHERE ba_s.ba_unit_id = #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('ba_unit-has-compatible-cadastre-object', '2014-02-20', 'infinity', 'SELECT  co.type_code = ''parcel'' as vl
from administrative.ba_unit ba 
  inner join administrative.ba_unit_contains_spatial_unit ba_s on ba.id= ba_s.ba_unit_id
  inner join cadastre.cadastre_object co on ba_s.spatial_unit_id= co.id
WHERE ba.id = #{id} and ba.type_code= ''basicPropertyUnit''
order by case when co.type_code = ''parcel'' then 0 
		else 1 
	end
limit 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('ba_unit-spatial_unit-area-comparison', '2014-02-20', 'infinity', 'SELECT (abs(coalesce(ba_a.size,0.001) - 
 (select coalesce(sum(sv_a.size), 0.001) 
  from cadastre.spatial_value_area sv_a inner join administrative.ba_unit_contains_spatial_unit ba_s 
    on sv_a.spatial_unit_id= ba_s.spatial_unit_id
  where sv_a.type_code = ''officialArea'' and ba_s.ba_unit_id= ba.id))/coalesce(ba_a.size,0.001)) < 0.001 as vl
FROM administrative.ba_unit ba left join administrative.ba_unit_area ba_a 
  on ba.id= ba_a.ba_unit_id and ba_a.type_code = ''officialArea''
WHERE ba.id = #{id}
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('newtitle-br22-check-different-owners', '2014-02-20', 'infinity', 'WITH new_property_owner AS (
	SELECT  COALESCE(name, '''') || '' '' || COALESCE(last_name, '''') AS newOwnerStr FROM party.party po
		INNER JOIN administrative.party_for_rrr pfr1 ON (po.id = pfr1.party_id)
		INNER JOIN administrative.rrr rr1 ON (pfr1.rrr_id = rr1.id)
	WHERE rr1.ba_unit_id = #{id}),
	
  prior_property_owner AS (
	SELECT  COALESCE(name, '''') || '' '' || COALESCE(last_name, '''') AS priorOwnerStr FROM party.party pn
		INNER JOIN administrative.party_for_rrr pfr2 ON (pn.id = pfr2.party_id)
		INNER JOIN administrative.rrr rr2 ON (pfr2.rrr_id = rr2.id)
		INNER JOIN administrative.required_relationship_baunit rfb ON (rr2.ba_unit_id = rfb.from_ba_unit_id)
	WHERE	rfb.to_ba_unit_id = #{id}
	LIMIT 1	)

SELECT 	CASE 	WHEN (SELECT (COUNT(*) = 0) FROM prior_property_owner) THEN NULL
		WHEN (SELECT (COUNT(*) != 0) FROM new_property_owner npo WHERE compare_strings((SELECT priorOwnerStr FROM prior_property_owner), npo.newOwnerStr)) THEN TRUE
		ELSE FALSE
	END AS vl
ORDER BY vl
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('cadastre-redefinition-target-geometries-dont-overlap', '2014-02-20', 'infinity', 'select coalesce(st_area(st_union(co.geom_polygon)) = sum(st_area(co.geom_polygon)), true) as vl
from cadastre.cadastre_object_target co where transaction_id = #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('area-check-percentage-newareas-oldareas', '2014-02-20', 'infinity', 'select abs((select cast(sum(a.size)as float)
	from cadastre.spatial_value_area a
	where a.type_code = ''officialArea''
        and a.spatial_unit_id in (
	   select co_new.id
		from cadastre.cadastre_object co_new 
		where co_new.transaction_id = #{id}))
 -
   (select cast(sum(a.size)as float)
	from cadastre.spatial_value_area a
	where a.type_code = ''officialArea''
	and a.spatial_unit_id in ( 
	      select co_target.cadastre_object_id
		from cadastre.cadastre_object_target co_target
		    where co_target.transaction_id = #{id})) 
 ) /(select cast(sum(a.size)as float)
	from cadastre.spatial_value_area a
	where a.type_code = ''officialArea''
	and a.spatial_unit_id in ( 
	      select co_target.cadastre_object_id
		from cadastre.cadastre_object_target co_target
		    where co_target.transaction_id = #{id})) 
 < 0.001 as vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('area-check-percentage-newofficialarea-calculatednewarea', '2014-02-20', 'infinity', 'select count(*) = 0 as vl
from cadastre.cadastre_object co 
  left join cadastre.spatial_value_area sa_calc on (co.id= sa_calc.spatial_unit_id and sa_calc.type_code =''calculatedArea'')
  left join cadastre.spatial_value_area sa_official on (co.id= sa_official.spatial_unit_id and sa_official.type_code =''officialArea'')
where co.transaction_id = #{id} and
(abs(coalesce(sa_official.size, 0) - coalesce(sa_calc.size, 0)) 
/ 
(case when sa_official.size is null or sa_official.size = 0 then 1 else sa_official.size end)) > 0.01');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('cadastre-object-check-name', '2014-02-20', 'infinity', 'Select cadastre.cadastre_object_name_is_valid(name_firstpart, name_lastpart) as vl 
FROM cadastre.cadastre_object
WHERE transaction_id = #{id} and type_code = ''parcel''
order by 1
limit 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('cadastre-redefinition-union-old-new-the-same', '2014-02-20', 'infinity', 'select st_equals(geom_to_snap,target_geom) as vl from cadastre.snap_geometry_to_geometry((select st_union(co.geom_polygon) from cadastre.cadastre_object co 
 where id in (select cadastre_object_id from cadastre.cadastre_object_target co_t where transaction_id = #{id})), 
(select st_union(co_t.geom_polygon) from cadastre.cadastre_object_target co_t where transaction_id = #{id}), 
 system.get_setting(''map-tolerance'')::double precision, true)');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('new-cadastre-objects-do-not-overlap', '2014-02-20', 'infinity', 'WITH tolerance AS (SELECT CAST(ABS(LOG((CAST (vl AS NUMERIC)^2))) AS INT) AS area FROM system.setting where name = ''map-tolerance'' LIMIT 1)

SELECT COALESCE(ROUND(CAST (ST_AREA(ST_UNION(co.geom_polygon))AS NUMERIC), (SELECT area FROM tolerance)) = 
		ROUND(CAST(SUM(ST_AREA(co.geom_polygon))AS NUMERIC), (SELECT area FROM tolerance)), 
		TRUE) AS vl
FROM cadastre.cadastre_object co 
WHERE transaction_id = #{id} ');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('new-cadastre-objects-present', '2014-02-20', 'infinity', 'select count (*) > 0 as vl from cadastre.cadastre_object where transaction_id= #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('target-and-new-union-the-same', '2014-02-20', 'infinity', 'select st_equals(geom_to_snap,target_geom) as vl
from cadastre.snap_geometry_to_geometry(
(select st_union(co.geom_polygon) 
from cadastre.cadastre_object co where transaction_id = #{id})
, (select st_union(co.geom_polygon)
from cadastre.cadastre_object co 
where id in (select cadastre_object_id 
  from cadastre.cadastre_object_target  where transaction_id = #{id})), 
  system.get_setting(''map-tolerance'')::double precision, true)
 ');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('target-parcels-check-isapolygon', '2014-02-20', 'infinity', 'select St_GeometryType(ST_Union(co.geom_polygon)) = ''ST_Polygon'' as vl
 from cadastre.cadastre_object co 
  inner join cadastre.cadastre_object_target co_target
   on co.id = co_target.cadastre_object_id
    where co_target.transaction_id = #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('target-parcels-check-nopending', '2014-02-20', 'infinity', 'select (select count(*)=0 
  from cadastre.cadastre_object_target target_also inner join transaction.transaction t 
    on target_also.transaction_id = t.id and t.status_code not in (''approved'')
  where co_target.transaction_id != target_also.transaction_id
    and co_target.cadastre_object_id= target_also.cadastre_object_id) as vl
from cadastre.cadastre_object_target co_target
where co_target.transaction_id = #{id}
 ');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('target-parcels-present', '2014-02-20', 'infinity', 'select count (*) > 0 as vl from cadastre.cadastre_object_target where transaction_id= #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('survey-points-present', '2014-02-20', 'infinity', 'select count (*) > 2  as vl from cadastre.survey_point where transaction_id= #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('ba_unit-has-several-mortgages-with-same-rank', '2014-02-20', 'infinity', 'WITH	simple	AS	(SELECT rr1.id, rr1.nr FROM administrative.rrr rr1
				INNER JOIN administrative.ba_unit ba1 ON (rr1.ba_unit_id = ba1.id)
				INNER JOIN administrative.rrr rr2 ON ((ba1.id = rr2.ba_unit_id) AND (rr1.mortgage_ranking = rr2.mortgage_ranking))
			WHERE rr2.id = #{id}
			AND rr1.type_code = ''mortgage''
			AND rr1.status_code = ''current''
			AND (rr1.mortgage_ranking = rr2.mortgage_ranking)),
	complex	AS	(SELECT rr3.id, rr3.nr FROM administrative.rrr rr3
				INNER JOIN administrative.ba_unit ba2 ON (rr3.ba_unit_id = ba2.id)
				INNER JOIN administrative.rrr rr4 ON (ba2.id = rr4.ba_unit_id)
			WHERE rr4.id = #{id}
			AND rr3.type_code = ''mortgage''
			AND rr3.status_code != ''current''
			AND rr3.mortgage_ranking = rr4.mortgage_ranking
			AND rr3.nr IN (SELECT nr FROM simple))

SELECT CASE 	WHEN	((SELECT rr5.id FROM administrative.rrr rr5 WHERE rr5.id = #{id} AND rr5.type_code = ''mortgage'') IS NULL) THEN NULL
		WHEN 	(SELECT (COUNT(*) = 0) FROM simple) THEN TRUE
		WHEN 	(((SELECT COUNT(*) FROM simple) - (SELECT COUNT(*) FROM complex) = 0)) THEN TRUE
		ELSE	FALSE
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('rrr-must-have-parties', '2014-02-20', 'infinity', 'select count(*) = 0 as vl
from administrative.rrr r
where r.id= #{id} and type_code in (select code from administrative.rrr_type where party_required)
and (select count(*) from administrative.party_for_rrr where rrr_id= r.id) = 0');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('rrr-shares-total-check', '2014-02-20', 'infinity', 'SELECT (SUM(nominator::DECIMAL/denominator::DECIMAL)*10000)::INT = 10000  AS vl
FROM   administrative.rrr_share 
WHERE  rrr_id = #{id}
AND    denominator != 0');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('ba_unit-has-caveat', '2014-02-20', 'infinity', 'WITH caveatCheck AS	(SELECT COUNT(*) AS present FROM administrative.rrr rr2 
				 INNER JOIN administrative.ba_unit ba ON (rr2.ba_unit_id = ba.id)
				 INNER JOIN administrative.rrr rr1 ON ((ba.id = rr1.ba_unit_id) AND (rr1.type_code = ''caveat'') AND (rr1.status_code IN (''pending'', ''current'')))
			 WHERE rr2.id = #{id}
			 ORDER BY 1
			 LIMIT 1),
    changeCheck AS	(SELECT (COUNT(*) > 0) AS caveatChange FROM administrative.rrr rr2 
				 INNER JOIN administrative.ba_unit ba ON (rr2.ba_unit_id = ba.id)
				 INNER JOIN administrative.rrr rr3 ON ((ba.id = rr3.ba_unit_id) AND (rr3.type_code = ''caveat'') AND (rr3.status_code = ''current''))
				 INNER JOIN transaction.transaction tn ON (rr3.transaction_id = tn.id)
				 INNER JOIN application.service sv1 ON ((tn.from_service_id = sv1.id) AND sv1.request_type_code IN (''varyCaveat'', ''removeCaveat'') AND sv1.status_code IN (''lodged'', ''pending''))
			 WHERE rr2.id = #{id}),
	varyCheck AS 	(SELECT ((SELECT present FROM caveatCheck) - (SELECT SUM(1) FROM (SELECT DISTINCT ON (rr4.nr) rr4.nr FROM administrative.rrr rr2 
									 INNER JOIN administrative.ba_unit ba ON (rr2.ba_unit_id = ba.id) 
									 INNER JOIN administrative.rrr rr3 ON ((ba.id = rr3.ba_unit_id) AND (rr3.type_code = ''caveat'') AND (rr3.status_code = ''current''))
									 INNER JOIN transaction.transaction tn ON (rr3.transaction_id = tn.id) 
									 INNER JOIN application.service sv1 ON ((tn.from_service_id = sv1.id) AND (sv1.request_type_code = ''varyCaveat''))
									 INNER JOIN administrative.rrr rr4 ON ((ba.id = rr4.ba_unit_id) AND (rr3.nr = rr4.nr))
								WHERE rr2.id = #{id}) AS vary) = 0) AS withoutVary), 
     caveatRegn AS	(SELECT (COUNT(*) > 0) AS caveat FROM administrative.rrr rr4
				 INNER JOIN transaction.transaction tn ON ((rr4.transaction_id = tn.id)	AND (rr4.status_code IN (''pending'', ''current'')) AND (rr4.type_code = ''caveat''))
				 INNER JOIN application.service sv2 ON (tn.from_service_id = sv2.id)
			WHERE rr4.id = #{id}
			AND (SELECT (COUNT(*) = 0) FROM application.service sv3 WHERE ((sv3.application_id = sv2.application_id) AND (sv3.status_code != ''cancelled'') AND (sv3.request_type_code NOT IN (''caveat'', ''varyCaveat'', ''removeCaveat''))))
			ORDER BY 1
			LIMIT 1)
			
SELECT (SELECT	CASE 	WHEN (SELECT caveat FROM caveatRegn) THEN TRUE
			WHEN (SELECT caveatChange FROM changeCheck) THEN TRUE
			WHEN (SELECT withoutVary FROM varyCheck) THEN TRUE
			WHEN (SELECT (present = 0) FROM caveatCheck)THEN NULL
			WHEN (SELECT (present > 0) FROM caveatCheck) THEN FALSE
			ELSE TRUE
		END) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('source-attach-in-transaction-no-pendings', '2014-02-20', 'infinity', 'WITH checkServiceType	AS	(SELECT COUNT(*) AS cnt FROM application.service sv1
					INNER JOIN transaction.transaction tn ON (sv1.id = tn.from_service_id)
					INNER JOIN source.source sc1 ON (tn.id = sc1.transaction_id)
				 WHERE sc1.id = #{id}
				 AND sv1.request_type_code IN (''regnPowerOfAttorney'', ''regnStandardDocument'')),
	checkSource	AS	(SELECT COUNT(*) AS cnt FROM source.source sc2
				 WHERE sc2.id = #{id}
				 AND sc2.status_code = ''pending'')

SELECT	CASE 	WHEN (SELECT (cnt = 0) FROM checkServiceType) THEN NULL
		WHEN (SELECT (cnt = 0) FROM checkSource) THEN TRUE
		ELSE FALSE
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('source-attach-in-transaction-allowed-type', '2014-02-20', 'infinity', 'WITH checkServiceType	AS	(SELECT COUNT(*) AS cnt FROM application.service sv1
					INNER JOIN transaction.transaction tn ON (sv1.id = tn.from_service_id)
					INNER JOIN source.source sc1 ON (tn.id = sc1.transaction_id)
				 WHERE tn.id = #{id}
				 AND sv1.request_type_code IN (''regnPowerOfAttorney'', ''regnStandardDocument'')),
	allSource	AS	(SELECT sc2.id AS sid FROM source.source sc2
				 WHERE sc2.transaction_id = #{id}),
	checkSource	AS	(SELECT sid FROM allSource
				 WHERE sid IN (SELECT sc3.id FROM source.source sc3
							INNER JOIN source.administrative_source_type st ON (sc3.type_code = st.code)
						WHERE sc3.id = #{id}
						AND st.is_for_registration
						AND st.status = ''c''))

SELECT	CASE 	WHEN (SELECT (cnt = 0) FROM checkServiceType) THEN NULL
		WHEN (SELECT ((SELECT COUNT(*) FROM allSource) - (SELECT COUNT(*) FROM checkSource)) = 0) THEN TRUE
		ELSE FALSE
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('bulk-spatial-geom-overlaps-with-loading-geom', '2014-02-20', 'infinity', 'select (select count(1)=0
  from bulk_operation.spatial_unit_temporary tmp, bulk_operation.spatial_unit_temporary tmp2
  where tmp.transaction_id = tmp2.transaction_id and tmp.id != tmp2.id and tmp.geom && tmp2.geom 
    and st_intersects(tmp.geom, st_buffer(tmp2.geom, - system.get_setting(''map-tolerance'')::double precision))) as vl
from transaction.transaction t
where id = #{id}
  and id in (select transaction_id 
    from bulk_operation.spatial_unit_temporary 
    where type_code = ''cadastre_object'')
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('bulk-spatial-geom-overlaps-with-existing', '2014-02-20', 'infinity', 'select (select count(1)=0
  from bulk_operation.spatial_unit_temporary tmp, cadastre.cadastre_object co
  where tmp.transaction_id = t.id and tmp.geom && co.geom_polygon 
    and st_intersects(co.geom_polygon, st_buffer(tmp.geom, - system.get_setting(''map-tolerance'')::double precision))) as vl
from transaction.transaction t
where id = #{id}
  and id in (select transaction_id 
    from bulk_operation.spatial_unit_temporary 
    where type_code = ''cadastre_object'')
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('bulk-spatial-geom-not-valid', '2014-02-20', 'infinity', 'select (select count(1)=0
  from bulk_operation.spatial_unit_temporary tmp
  where tmp.transaction_id = t.id 
    and not (st_isvalid(tmp.geom) 
    and st_geometrytype(tmp.geom) = ''ST_Polygon'')) as vl
from transaction.transaction t
where id = #{id}
  and id in (select transaction_id 
    from bulk_operation.spatial_unit_temporary 
    where type_code = ''cadastre_object'')
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('bulk-spatial-name-unique', '2014-02-20', 'infinity', 'select (select count(1)=0
  from bulk_operation.spatial_unit_temporary 
  where transaction_id = t.id
   and (name_firstpart, name_lastpart) in (select name_firstpart, name_lastpart 
    from cadastre.cadastre_object)) as vl
from transaction.transaction t
where id = #{id}
  and id in (select transaction_id 
    from bulk_operation.spatial_unit_temporary 
    where type_code = ''cadastre_object'')
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('spatial-unit-group-not-overlap', '2014-02-20', 'infinity', 'select count(*) =0 as vl
from cadastre.spatial_unit_group sug1, cadastre.spatial_unit_group sug2
where sug1.hierarchy_level = sug2.hierarchy_level and sug1.id > sug2.id
  and st_intersects(sug1.geom, st_buffer(sug2.geom, -0.5))');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('spatial-unit-group-inside-other-spatial-unit-group', '2014-02-20', 'infinity', 'select count(*)= 0 as vl
from cadastre.spatial_unit_group 
where hierarchy_level !=0 and id not in (
  select sug1.id
  from cadastre.spatial_unit_group sug1, cadastre.spatial_unit_group sug2
  where sug1.hierarchy_level = sug2.hierarchy_level + 1
    and st_within(st_buffer(sug1.geom, -0.5), sug2.geom)
)');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('spatial-unit-group-name-unique', '2014-02-20', 'infinity', 'select count(*)=0 as vl
from (
select count(*)
from cadastre.spatial_unit_group
group by name
having count(*)>1) as tmp');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('public-display-check-baunit-has-co', '2014-02-20', 'infinity', 'SELECT count(bu.id) = 0 as vl
   FROM  application.application_property ap, 
   application.application aa, 
   application.service s,
   administrative.ba_unit bu
  WHERE 
   ap.ba_unit_id::text = bu.id::text 
   AND aa.id::text = ap.application_id::text 
   AND s.application_id::text = aa.id::text
   AND aa.id::text in (
   SELECT 
    aa.id id
   FROM 
   cadastre.cadastre_object co, cadastre.spatial_value_area sa, 
   administrative.ba_unit_contains_spatial_unit su, application.application_property ap, 
   application.application aa, application.service s
  WHERE sa.spatial_unit_id::text = co.id::text 
  AND sa.type_code::text = ''officialArea''::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND ap.ba_unit_id::text = su.ba_unit_id::text AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text
   AND s.request_type_code::text = ''systematicRegn''::text AND s.status_code::text = ''completed''::text 
   AND co.name_lastpart = #{lastPart}
    )
   AND s.request_type_code::text = ''systematicRegn''::text 
   AND s.status_code::text = ''completed''::text 
   AND  bu.id not in (
   select su.ba_unit_id
   from  
   administrative.ba_unit_contains_spatial_unit su
   )');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('public-display-check-complete-status', '2014-02-20', 'infinity', 'select
(select count(*)
from cadastre.cadastre_object co 
  INNER JOIN administrative.ba_unit_contains_spatial_unit ba_su on (co.id= ba_su.spatial_unit_id)
  INNER JOIN administrative.ba_unit bu on (bu.id= ba_su.ba_unit_id)
  INNER JOIN application.application_property ap on (bu.id= ap.ba_unit_id)
  INNER JOIN application.application a on (a.id= ap.application_id)
  INNER JOIN application.service s on (a.id= s.application_id and s.request_type_code=''systematicRegn'')
  where co.name_lastpart = #{lastPart})
/
(case when (select count(*)
from cadastre.cadastre_object co 
  INNER JOIN administrative.ba_unit_contains_spatial_unit ba_su on (co.id= ba_su.spatial_unit_id)
  INNER JOIN administrative.ba_unit bu on (bu.id= ba_su.ba_unit_id)
  INNER JOIN application.application_property ap on (bu.id= ap.ba_unit_id)
  INNER JOIN application.application a on (a.id= ap.application_id)
  INNER JOIN application.service s on (a.id= s.application_id and s.request_type_code=''systematicRegn'' and s.status_code=''completed'')
  where co.name_lastpart = #{lastPart}) = 0 then 1
  else  (select count(*)
from cadastre.cadastre_object co 
  INNER JOIN administrative.ba_unit_contains_spatial_unit ba_su on (co.id= ba_su.spatial_unit_id)
  INNER JOIN administrative.ba_unit bu on (bu.id= ba_su.ba_unit_id)
  INNER JOIN application.application_property ap on (bu.id= ap.ba_unit_id)
  INNER JOIN application.application a on (a.id= ap.application_id)
  INNER JOIN application.service s on (a.id= s.application_id and s.request_type_code=''systematicRegn'' and s.status_code=''completed'')
  where co.name_lastpart = #{lastPart})
 end 
  ) * 100
> 90 as vl
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-claim-nr', '2014-02-20', 'infinity', 'SELECT coalesce(system.get_setting(''system-id''), '''') || to_char(now(), ''yymm'') || trim(to_char(nextval(''opentenure.claim_nr_seq''), ''0000'')) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-not-transferred', '2014-09-12', 'infinity', 'select status_code != ''transferred'' as vl from application.application where id = #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-spatial-unit-not-transferred', '2014-09-12', 'infinity', 'select count(1) = 0 as vl
from application.application_spatial_unit  
where application_id = #{id} and spatial_unit_id in (select spatial_unit_id from application.application_spatial_unit where application_id in (select id from application.application where status_code=''transferred''))');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('consolidation-not-again', '2014-09-12', 'infinity', 'select not records_found as vl, result from system.get_already_consolidated_records() as vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-process-progress-consolidate-max', '2014-09-12', 'infinity', 'select 10 
  + 2 + (select count(*)*2 from system.consolidation_config) 
  + 1 + (select count(*)*2 from system.br_validation where target_code=''consolidate'')
  + 4 + (select count(*)*2 from system.consolidation_config) as vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-process-progress-extract-max', '2014-09-12', 'infinity', 'select 7 + (count(*)*(3+5)) + 2 + 10 as vl from system.consolidation_config');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('consolidation-extraction-file-name', '2014-09-12', 'infinity', 'select ''consolidation-'' || system.get_setting(''system-id'') || to_char(clock_timestamp(), ''-yyyy-MM-dd-HH24-MI'') as vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('consolidation-db-structure-the-same', '2014-02-20', 'infinity', 'with def_of_tables as (
  select source_table_name, target_table_name, 
    (select string_agg(col_definition, ''##'') from (select column_name || '' '' 
      || udt_name 
      || coalesce(''('' || character_maximum_length || '')'', '''') as col_definition
      from information_schema.columns cols
      where cols.table_schema || ''.'' || cols.table_name = config.source_table_name) as ttt) as source_def,
    (select string_agg(col_definition, ''##'') from (select column_name || '' '' 
      || udt_name 
      || coalesce(''('' || character_maximum_length || '')'', '''') as col_definition
      from information_schema.columns cols
      where cols.table_schema || ''.'' || cols.table_name = config.target_table_name) as ttt) as target_def      
from consolidation.config config)
select count(*)=0 as vl from def_of_tables where source_def != target_def');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('cancel-relation-notification', '2015-02-25', 'infinity', 'UPDATE administrative.notifiable_party_for_baunit 
 set status = ''x''
WHERE cancel_service_id in
(
SELECT        npbu.cancel_service_id
 FROM 
	      administrative.notifiable_party_for_baunit npbu,
	      application.application aa, 
	      application.service s,
	      party.group_party gp
WHERE 	      s.application_id::text = aa.id::text 
              and (npbu.party_id in (select pm.party_id from party.party_member pm where pm.group_id = gp.id))
              and (npbu.target_party_id in (select pm.party_id from party.party_member pm where pm.group_id = gp.id))
              and s.request_type_code::text = ''cancelRelationship''::text 
              and npbu.cancel_service_id = s.id
	      and aa.id = #{id})
;
select 0=0 as vl
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-cancel-obscuration-request', '2015-03-02', 'infinity', 'UPDATE party.party
 set classification_code = null,
     redact_code = null
WHERE obscure_service_id in
(
SELECT        s.id
 FROM 
	      application.application aa, 
	      application.service s
WHERE 	      s.application_id::text = aa.id::text 
              and s.request_type_code::text = ''obscurationRequest''::text 
              and aa.id = #{id})
;

select 0=0 as vl
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('cancel-obscuration-request', '2015-03-02', 'infinity', 'UPDATE party.party
 set classification_code = null,
     redact_code = null
WHERE obscure_service_id  = #{id}
;
select 0=0 as vl
');


ALTER TABLE br_definition ENABLE TRIGGER ALL;

--
-- Data for Name: br_validation; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE br_validation DISABLE TRIGGER ALL;

INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('beddb4ca-99dd-11e3-86d7-b7ad3c8d30f3', 'application-on-approve-check-public-display', 'application', 'approve', NULL, NULL, NULL, NULL, 'critical', 601);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bee57d18-99dd-11e3-a130-333174a347ed', 'app-check-title-ref', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 750);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bee66778-99dd-11e3-961a-834d8f1df017', 'application-br7-check-sources-have-documents', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 570);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bee86352-99dd-11e3-92f5-ff6ab473b1e3', 'app-other-app-with-caveat', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 590);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bee94db2-99dd-11e3-9503-5be69de99b6c', 'application-cancel-property-service-before-new-title', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 390);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('beea381c-99dd-11e3-9c1b-b34873923d3b', 'app-title-has-primary-right', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 100);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('beeafb6c-99dd-11e3-a08a-f77d218599a9', 'application-br2-check-title-documents-not-old', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 510);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('beec0cdc-99dd-11e3-9a1c-57d0a8457f7a', 'applicant-name-to-owner-name-check', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 410);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('beed1e56-99dd-11e3-b1d3-5b2bb3b66330', 'application-br3-check-properties-are-not-historic', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 180);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('beede1a6-99dd-11e3-b037-9b875b755c8b', 'application-br4-check-sources-date-not-in-the-future', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 710);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('beeecc06-99dd-11e3-8224-8f0f199b11e8', 'application-br6-check-new-title-service-is-needed', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 730);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('beefb670-99dd-11e3-80be-5f1f7d0be252', 'application-on-approve-check-services-status', 'application', 'approve', NULL, NULL, NULL, NULL, 'critical', 270);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef11600-99dd-11e3-b6f4-f7e5d1966496', 'application-on-approve-check-services-without-transaction', 'application', 'approve', NULL, NULL, NULL, NULL, 'critical', 330);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef2006a-99dd-11e3-b172-971b779500e0', 'application-on-approve-check-systematic-reg-no-objection', 'application', 'approve', NULL, NULL, NULL, NULL, 'critical', 600);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef2c3ba-99dd-11e3-8a92-9fe0710c1de1', 'application-br8-check-has-services', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 260);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef3ae1a-99dd-11e3-bf37-03b8fdd851ed', 'application-verifies-identification', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 530);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef47174-99dd-11e3-a840-57d6651e3211', 'newtitle-br24-check-rrr-accounted', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 160);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef534c4-99dd-11e3-9dad-2b73d16122d5', 'application-br1-check-required-sources-are-present', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 210);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef61f24-99dd-11e3-b5c3-3f18d066d216', 'application-approve-cancel-old-titles', 'application', 'approve', NULL, NULL, NULL, NULL, 'critical', 250);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef6e27e-99dd-11e3-b5b1-2fd1b09cc082', 'application-br5-check-there-are-front-desk-services', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 740);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef7ccde-99dd-11e3-bd39-d39c50f8cc80', 'application-for-new-title-has-cancel-property-service', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 1);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef8b73e-99dd-11e3-a4e4-cb550d80f143', 'cancel-title-check-rrr-cancelled', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 150);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef9537e-99dd-11e3-9ffd-b7715d85aeba', 'app-current-caveat-and-no-remove-or-vary', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 550);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef9efc8-99dd-11e3-964f-6b27f41ee3f8', 'application-not-transferred', 'application', 'assign', NULL, NULL, NULL, NULL, 'critical', 1);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('befa8c08-99dd-11e3-aee6-bf668a86c63d', 'application-spatial-unit-not-transferred', 'application', 'addSpatialUnit', NULL, NULL, NULL, NULL, 'critical', 300);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf1196d2-99dd-11e3-9ac5-83797407ab3d', 'documents-present', 'service', NULL, 'complete', NULL, NULL, NULL, 'critical', 200);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf136b92-99dd-11e3-89a5-7b26db224ca3', 'application-baunit-has-parcels', 'service', NULL, 'complete', NULL, 'cadastreChange', NULL, 'critical', 130);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf142ee2-99dd-11e3-9b31-c7a94fc0681f', 'application-baunit-has-parcels', 'service', NULL, 'complete', NULL, 'redefineCadastre', NULL, 'critical', 140);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf15405c-99dd-11e3-8196-2bd23db94507', 'current-rrr-for-variation-or-cancellation-check', 'service', NULL, 'complete', NULL, NULL, NULL, 'medium', 11);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf15b58c-99dd-11e3-a690-231e73911bf4', 'current-rrr-for-variation-or-cancellation-check', 'service', NULL, 'complete', NULL, NULL, NULL, 'medium', 650);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf16ee16-99dd-11e3-945b-dfc7d9fcc1b1', 'power-of-attorney-owner-check', 'service', NULL, 'complete', NULL, NULL, NULL, 'warning', 580);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf17ff86-99dd-11e3-9bb9-e34714282e41', 'service-has-person-verification', 'service', NULL, 'complete', NULL, NULL, NULL, 'critical', 350);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf195f16-99dd-11e3-bdce-c74f42f9154c', 'application-baunit-check-area', 'service', NULL, NULL, NULL, 'cadastreChange', NULL, 'warning', 520);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf1a7090-99dd-11e3-8c09-4b0bbde3417d', 'baunit-has-multiple-mortgages', 'service', NULL, 'complete', NULL, 'mortgage', NULL, 'warning', 670);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf1b8200-99dd-11e3-bb68-f74dd327ab4c', 'document-supporting-rrr-is-current', 'service', NULL, 'complete', NULL, NULL, NULL, 'critical', 240);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf1c6c6a-99dd-11e3-b6f6-4f95f8177fc0', 'mortgage-value-check', 'service', NULL, 'complete', NULL, 'mortgage', NULL, 'warning', 700);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf1ce19a-99dd-11e3-8009-abc8261667d8', 'mortgage-value-check', 'service', NULL, 'complete', NULL, 'varyMortgage', NULL, 'warning', 690);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf1dcbfa-99dd-11e3-b541-7b279723c27b', 'power-of-attorney-service-has-document', 'service', NULL, 'complete', NULL, 'regnPowerOfAttorney', NULL, 'critical', 340);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf1eb65a-99dd-11e3-a82a-63bcc9eb89eb', 'required-sources-are-present', 'service', NULL, 'complete', NULL, NULL, NULL, 'critical', 230);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf1fa0c4-99dd-11e3-80e7-6ba652a5d098', 'service-on-complete-without-transaction', 'service', NULL, 'complete', NULL, NULL, NULL, 'critical', 360);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf208b24-99dd-11e3-b094-4bfda581097c', 'service-title-terminated', 'service', NULL, 'complete', NULL, NULL, NULL, 'critical', 190);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf217584-99dd-11e3-971f-cb1338a539aa', 'service-check-no-previous-digital-title-service', 'service', NULL, 'complete', NULL, 'newDigitalTitle', NULL, 'warning', 720);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf2ee336-99dd-11e3-b589-9fa52f2707db', 'target-ba_unit-check-if-pending', 'ba_unit', NULL, NULL, 'current', NULL, NULL, 'critical', 280);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf312d30-99dd-11e3-9a36-2b027935a066', 'ba_unit-has-cadastre-object', 'ba_unit', NULL, NULL, 'current', NULL, NULL, 'medium', 500);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf32b3da-99dd-11e3-a86b-fb97c1bc1883', 'ba_unit-has-compatible-cadastre-object', 'ba_unit', NULL, NULL, 'current', NULL, NULL, 'medium', 540);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf3488a4-99dd-11e3-85e6-3f35aa386078', 'ba_unit-spatial_unit-area-comparison', 'ba_unit', NULL, NULL, 'current', NULL, NULL, 'medium', 490);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf37e40e-99dd-11e3-bf28-2f86e5fe7685', 'ba_unit-has-a-valid-primary-right', 'ba_unit', NULL, NULL, 'current', NULL, NULL, 'critical', 20);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf3a2e08-99dd-11e3-be9e-cfcb4db81fe7', 'newtitle-br22-check-different-owners', 'ba_unit', NULL, NULL, 'current', NULL, NULL, 'warning', 680);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf4ccbee-99dd-11e3-8765-b7ba0436cb1b', 'cadastre-redefinition-target-geometries-dont-overlap', 'cadastre_object', NULL, NULL, 'current', 'redefineCadastre', NULL, 'critical', 120);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf4e046e-99dd-11e3-ac01-67826511e731', 'cadastre-redefinition-target-geometries-dont-overlap', 'cadastre_object', NULL, NULL, 'pending', 'redefineCadastre', NULL, 'warning', 430);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf4fb228-99dd-11e3-8f06-ff089b1b7fe4', 'area-check-percentage-newareas-oldareas', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 640);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf502758-99dd-11e3-aa31-b3de9eb0f474', 'area-check-percentage-newareas-oldareas', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'warning', 630);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf5111b8-99dd-11e3-910a-073fdcc41e3f', 'area-check-percentage-newofficialarea-calculatednewarea', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'warning', 610);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf5186e8-99dd-11e3-87fe-7f5d1ec0ee3d', 'area-check-percentage-newofficialarea-calculatednewarea', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 620);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf529862-99dd-11e3-b8b9-7725d84e4c37', 'cadastre-object-check-name', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'medium', 600);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf530d92-99dd-11e3-8ac9-5fe3ebe62fec', 'cadastre-object-check-name', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'medium', 660);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf5ecd8a-99dd-11e3-897f-83b0d2f7ca79', 'cadastre-redefinition-union-old-new-the-same', 'cadastre_object', NULL, NULL, 'current', 'redefineCadastre', NULL, 'warning', 400);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf5f42c4-99dd-11e3-adf1-c35e9d107011', 'cadastre-redefinition-union-old-new-the-same', 'cadastre_object', NULL, NULL, 'pending', 'redefineCadastre', NULL, 'warning', 420);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf605434-99dd-11e3-94b0-db8d0a31a5eb', 'new-cadastre-objects-do-not-overlap', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 60);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf60f074-99dd-11e3-b103-3f68ada0b2ea', 'new-cadastre-objects-do-not-overlap', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'medium', 480);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf6228fe-99dd-11e3-8222-fb2038631753', 'new-cadastre-objects-present', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 370);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf629e2e-99dd-11e3-9f6d-1bce9d19f1b0', 'new-cadastre-objects-present', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'critical', 50);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf6424ce-99dd-11e3-871d-e34e420bd308', 'target-and-new-union-the-same', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 470);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf649a08-99dd-11e3-9400-bf6d3595104e', 'target-and-new-union-the-same', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'warning', 460);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf65ab78-99dd-11e3-8578-97b6e4e3f10c', 'target-parcels-check-isapolygon', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'critical', 90);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf6647b8-99dd-11e3-8e01-d33af44aed65', 'target-parcels-check-isapolygon', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'critical', 80);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf678042-99dd-11e3-91fc-23b055a0f1db', 'target-parcels-check-nopending', 'cadastre_object', NULL, NULL, 'pending', NULL, NULL, 'critical', 310);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf67f572-99dd-11e3-a9e8-6739cfc2b3de', 'target-parcels-check-nopending', 'cadastre_object', NULL, NULL, 'current', NULL, NULL, 'critical', 300);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf692df2-99dd-11e3-88af-bf24a927350a', 'target-parcels-present', 'cadastre_object', NULL, NULL, 'pending', NULL, NULL, 'warning', 450);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf6a3f6c-99dd-11e3-9a09-8f3026fcfa46', 'target-parcels-present', 'cadastre_object', NULL, NULL, 'current', NULL, NULL, 'warning', 440);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf6b50dc-99dd-11e3-8310-af68f5931839', 'survey-points-present', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 380);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf6bc60c-99dd-11e3-bc9d-574417653a44', 'survey-points-present', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'critical', 70);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf851ad0-99dd-11e3-a532-1b4026ab96d7', 'ba_unit-has-several-mortgages-with-same-rank', 'rrr', NULL, NULL, 'current', NULL, NULL, 'critical', 170);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf86a170-99dd-11e3-a2a8-bf0f7b339519', 'rrr-must-have-parties', 'rrr', NULL, NULL, 'current', NULL, NULL, 'critical', 110);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf8764ca-99dd-11e3-8284-736cc8ee135c', 'rrr-has-pending', 'rrr', NULL, NULL, 'current', NULL, NULL, 'critical', 290);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf88010a-99dd-11e3-acc8-9783e3e19a06', 'rrr-shares-total-check', 'rrr', NULL, NULL, 'current', NULL, NULL, 'critical', 40);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf88c45a-99dd-11e3-8051-13d27ae9940b', 'ba_unit-has-caveat', 'rrr', NULL, NULL, 'current', NULL, NULL, 'critical', 30);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf991846-99dd-11e3-b4fb-4b444862ac47', 'source-attach-in-transaction-no-pendings', 'source', NULL, NULL, 'pending', NULL, NULL, 'critical', 220);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bf9ac600-99dd-11e3-ae93-b3424d58aab7', 'source-attach-in-transaction-allowed-type', 'source', NULL, NULL, 'pending', NULL, NULL, 'critical', 560);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bfad3cd6-99dd-11e3-ad94-575ceec4b27e', 'bulk-spatial-geom-overlaps-with-loading-geom', 'bulkOperationSpatial', NULL, NULL, 'pending', NULL, NULL, 'warning', 440);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bfafade0-99dd-11e3-8c7f-9f27f35049a0', 'bulk-spatial-geom-overlaps-with-existing', 'bulkOperationSpatial', NULL, NULL, 'pending', NULL, NULL, 'warning', 440);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bfb09840-99dd-11e3-b41f-5b4e49782eaf', 'bulk-spatial-geom-not-valid', 'bulkOperationSpatial', NULL, NULL, 'pending', NULL, NULL, 'warning', 440);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bfb182a0-99dd-11e3-bffe-dfa75b679d35', 'bulk-spatial-name-unique', 'bulkOperationSpatial', NULL, NULL, 'pending', NULL, NULL, 'warning', 440);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bfbf658c-99dd-11e3-9ae3-0bfef3d70817', 'spatial-unit-group-not-overlap', 'spatial_unit_group', NULL, NULL, NULL, NULL, NULL, 'critical', 2);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bfc1d696-99dd-11e3-9f78-37e12aca6a61', 'spatial-unit-group-name-unique', 'spatial_unit_group', NULL, NULL, NULL, NULL, NULL, 'critical', 1);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bfcfe088-99dd-11e3-98dc-f329301d6629', 'public-display-check-baunit-has-co', 'public_display', NULL, NULL, NULL, NULL, NULL, 'warning', 2);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bfd11908-99dd-11e3-8302-931a1e68e8f6', 'public-display-check-complete-status', 'public_display', NULL, NULL, NULL, NULL, NULL, 'warning', 1);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bfeae2fc-99dd-11e3-98d3-47256ea2b59e', 'consolidation-db-structure-the-same', 'consolidation', NULL, NULL, NULL, NULL, NULL, 'critical', 570);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('consolidation-not-again', 'consolidation-not-again', 'consolidation', NULL, NULL, NULL, NULL, NULL, 'critical', 1);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bfc0ec2c-99dd-11e3-bc3f-13923fd8d236', 'spatial-unit-group-inside-other-spatial-unit-group', 'spatial_unit_group', NULL, NULL, NULL, NULL, NULL, 'medium', 2);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('cancel-relation-notification', 'cancel-relation-notification', 'application', 'approve', NULL, NULL, NULL, NULL, 'warning', 300);


ALTER TABLE br_validation ENABLE TRIGGER ALL;

--
-- PostgreSQL database dump complete
--

