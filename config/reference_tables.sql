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

SET search_path = administrative, pg_catalog;

--
-- Data for Name: ba_unit_rel_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE ba_unit_rel_type DISABLE TRIGGER ALL;

INSERT INTO ba_unit_rel_type (code, display_value, description, status) VALUES ('priorTitle', 'Prior Title::::Предыдущая недвижимость::::سند الملكية السابق::::Titre précédent::::Título Previo::::::::Título Anterior::::::::之前的权利', 'Prior Title::::Предыдущая недвижимость::::...::::Titre précédent::::Título Previo::::::::Título Anterior::::::::之前的权利', 'c');
INSERT INTO ba_unit_rel_type (code, display_value, description, status) VALUES ('rootTitle', 'Root of Title::::Корневая недвижимость::::أصل  سند الملكية::::Racine du Titre::::Raíz del título::::::::Origem do Título::::::::业权根源', 'Root of Title::::Корневая недвижимость::::...::::Racine du Titre::::Raíz del título::::::::Origem do Título::::::::业权根源', 'c');


ALTER TABLE ba_unit_rel_type ENABLE TRIGGER ALL;

--
-- Data for Name: ba_unit_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

ALTER TABLE ba_unit_type DISABLE TRIGGER ALL;

INSERT INTO ba_unit_type (code, display_value, description, status) VALUES ('administrativeUnit', 'Administrative Unit::::Административная единица::::وحدة ادارية::::Unité Administrative::::Unidad Administrativa::::::::Unidade Administrativa::::::::管理单元', '...::::::::...::::...::::...::::::::...::::::::...', 'x');
INSERT INTO ba_unit_type (code, display_value, description, status) VALUES ('basicPropertyUnit', 'Basic Property Unit::::Базовая единица недвижимости::::وحدة ملكية اساسة::::Unité de Base Propriété::::Propiedad Unidad Básica::::::::Unidade de Propriedade Básica::::::::基本财产单元', 'This is the basic property unit that is used by default::::Это базовая единица недвижимости используемая по умолчанию::::...::::Ceci est l''unité de base de propriété utilisée par défaut::::Esta es la unidad de propiedad básica que se utiliza por defecto::::::::Esta é a unidade de propriedade básica que é usado por padrão::::::::这是默认使用的基本产权单元。', 'c');
INSERT INTO ba_unit_type (code, display_value, description, status) VALUES ('leasedUnit', 'Leased Unit::::Единица для Аренды::::وحدة  مؤجرة::::Unité de Bail::::Unidad arrendadas::::::::Unidade Arrendada::::::::租赁单元', '...::::::::...::::...::::...::::::::...::::::::...', 'x');
INSERT INTO ba_unit_type (code, display_value, description, status) VALUES ('propertyRightUnit', 'Property Right Unit::::Единица права недвижимости::::وحدة حقوق الملكية::::Unité de Droit de Propriété::::Propiedad Unidad Básica::::::::Unidade de Direito de Propriedade::::::::产权单元', '...::::::::...::::...::::...::::::::...::::::::...', 'x');


ALTER TABLE ba_unit_type ENABLE TRIGGER ALL;

--
-- Data for Name: condition_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

ALTER TABLE condition_type DISABLE TRIGGER ALL;

INSERT INTO condition_type (code, display_value, description, status) VALUES ('c6', 'Condition 6::::Условие 6::::الشرط السادس::::Condition 6::::Condicion 6::::::::Condição 6::::::::条件6', 'The interior and exterior of any building erected on the land and all building additions thereto and all other buildings at any time erected or standing on the land and walls, drains and other appurtenances, shall be kept by the Lessee in good repair and tenantable condition to the satisfaction of the planning authority.::::The interior and exterior of any building erected on the land and all building additions thereto and all other buildings at any time erected or standing on the land and walls, drains and other appurtenances, shall be kept by the Lessee in good repair and tenantable condition to the satisfaction of the planning authority.::::جميع مداخل ومخارج البنايات المرفوعة على الارض وجميع البنايات المرفوعة على الارض في أي وقت والجدران والمصارف والتوابع , يجب الحفاظ عليها بصورة جيدة وتصليحها بما يحقق متطلبات سلطة التخطيط::::Les intérieurs et extérieurs des bâtiments érigés sur le terrain and tous les ajouts et autres bâtiments érigés à n''importe quel moment ou en cours de réalisation, ainsi que les murs, drains ou autres équipements, doivent être entretenus par le teneur de bail en bon état de location à la satisfaction des autorités d''urbanisme.::::El interior y el exterior de cualquier edificio construido en la tierra y todos los anexos de construcción de éste y todos los otros edificios en cualquier momento erigido o de pie sobre la tierra y las paredes, los desagües y otros accesorios, deberán ser conservados por el arrendatario en buen estado de habitabilidad a la satisfacción de la autoridad de planificación.::::::::O interior e exterior de qualquer edifício construído sobre a terra e todos os acréscimos de construção dos mesmos e de outras construções, a qualquer momento erguidas sobre a terra, assim como paredes, ralos e outros acessórios, devem ser conservados pelo Locatário em bom estado de conservação, conforme determinação da autoridade de planejamento.::::::::任何建造在土地上的建筑的内部和外部，以及所有建筑的附加部分，此外还有所有其他任何建造在地上的建筑、墙、排水和其他附着物，都将由租户保留良好的维修和居住条件以到达规划当局满意的效果。', 'c');
INSERT INTO condition_type (code, display_value, description, status) VALUES ('c5', 'Condition 5::::Условие 5::::الشرط الخامس::::Condition 5::::Condicion 5::::::::Condição 5::::::::条件5', 'Save with the written authority of the planning authority, no electrical power or telephone pole or line or water, drainage or sewer pipe being upon or passing through, over or under the land and no replacement thereof, shall be moved or in any way be interfered with and reasonable access thereto shall be preserved to allow for inspection, maintenance, repair, renewal and replacement.::::Save with the written authority of the planning authority, no electrical power or telephone pole or line or water, drainage or sewer pipe being upon or passing through, over or under the land and no replacement thereof, shall be moved or in any way be interfered with and reasonable access thereto shall be preserved to allow for inspection, maintenance, repair, renewal and replacement.::::محفوظة بشكل خطي عند سلطة التخطيط , جميع خطوط الطاقة الكهربائية أو قطب الهاتف أو خط المياه والصرف الصحي أو أنابيب المجاري التي تجري على الارض او و تمر، فوق أو تحت الأرض لا يجب استبدال أي منها، او نقلها في أي حال من الأحوال ويجب الحفاظ عليها وضمان صول معقول للسماح للتفتيش والصيانة والإصلاح والتجديد والاستبدال::::Sauvegarder en écrit de la part des autorités de l''urbanisme, pas de courant électrique ou de poteau de téléphone ou d''évacuation d''égout passant au-dessus ou à travers, au-dessus ou en-dessous du terrain et pas de remplacement, ne doit pas être déplacé ou interférer avec l''accès, doit être préservé pour rendre possible l''inspection, l''entretien, la réparation, le renouvellement ou le déplacement.::::Salvar con la autorización escrita de la autoridad de planificación, no hay alimentación o el teléfono poste eléctrico o la línea o el agua, drenaje o alcantarilla estar sobre o de paso, sobre o debajo de la tierra y no la sustitución del mismo, será movido o de ninguna manera ser interferido con la misma y de acceso razonables serán conservados para permitir la inspección, mantenimiento, reparación, renovación y sustitución.::::::::Salvo com a autorização por escrito da autoridade de planejamento, nenhuma rede de energia elétrica ou poste de telefone ou linha de água, drenagem ou tubulação de esgoto passando, sobre ou sob a terra, deve ser substituída ou movida, ou de alguma forma interferir em um acesso razoavelmente preservado, permitindo a inspeção, manutenção, reparação, renovação e substituição.::::::::与规划当局的书面授权一同保存，不允许电力、电话线、进水和排水管道打地上或地下通过，不能取消或以任何形式进行干扰，要保留合理通行以允许检查、维护、修理和替换。', 'c');
INSERT INTO condition_type (code, display_value, description, status) VALUES ('c4', 'Condtion 4::::Условие 4::::الشرط الرابع::::Condition 4::::Condicion 4::::::::Condição 4::::::::条件4', 'The Lessee shall use the land comprised in the lease only for the purpose specified in the lease or in any variation made to the original lease.::::The Lessee shall use the land comprised in the lease only for the purpose specified in the lease or in any variation made to the original lease.::::على المستاجر استخدام الارض فقط للاغراض المنصوص عليها في عقد الايجار او أي تغييرات مرفقة مع عقد الايجار::::Le preneur de bail doit utiliser le terrain compris dans le bail seulement pour l''objet spécifié dans bail ou dans une variation effectuée au bail d''origine.::::El arrendatario deberá utilizar el terreno comprendido en el contrato de arrendamiento sólo para los fines especificados en el contrato de arrendamiento o de cualquier variación hecha al arrendamiento original.::::::::O Locatário deve usar a terra compreendida na locação apenas para os fins previstos no contrato de arrendamento ou de qualquer variação feita ao contrato original.::::::::考虑到明确在租赁中或出现在原始租赁中的任何变动，租户将使用包含在租赁之中的土地。', 'c');
INSERT INTO condition_type (code, display_value, description, status) VALUES ('c1', 'Condition 1::::Условие 1::::الشرط الاول::::Condition 1::::Condicion 1::::::::Condição 1::::::::条件1', 'Unless the Minister directs otherwise the Lessee shall fence the boundaries of the land within 6 (six) months of the date of the grant and the Lessee shall maintain the fence to the satisfaction of the Commissioner.::::Unless the Minister directs otherwise the Lessee shall fence the boundaries of the land within 6 (six) months of the date of the grant and the Lessee shall maintain the fence to the satisfaction of the Commissioner.::::ما لم يقرر الوزير غير ذلك  على المستأجر تسييج حدود الارض بمدة لا تزيد عن 6 شهورمن تاريخ السماح ويجب على المستاجر المحافظة على سلامة السياج لصالح المفوض::::A moins que le Ministre n''ordonne d''autres directives, le preneur de bail doit clôturer les limites du terrain dans les 6 (six) mois suivant la date d''obtention du bail et le preneur de bail doit entretenir la clôture selon la satisfaction du Commissaire.::::A menos que la autoridad de otra orden, el Arrendatario debe colocar una valla alrededor de los límites de la tierra dentro de los 6 (seis) meses de la fecha de concesión y el arrendatario deberá mantener la valla a satisfacción del Comisionado.::::::::A menos que o Ministro diga o contrário, o Locatário deve cercar os limites da terra dentro de 6 (seis) meses a contar da data da sua concessão, o Locatário deverá fazer a manutenção da cerca, conforme determinação do Comissário.::::::::除非有部里的指导，否则租户需要在获准租赁的6个月内围封住土地，且需将围封保持住以让负责人满意。', 'c');
INSERT INTO condition_type (code, display_value, description, status) VALUES ('c3', 'Condition 3::::Условие 3::::الشرط الثالث::::Condition 3::::Condicion 3::::::::Condição 3::::::::条件3', 'Within a period of the time to be fixed by the planning authority, the Lessee shall provide at his own expense main drainage or main sewerage connections from the building erected on the land as the planning authority may require.::::Within a period of the time to be fixed by the planning authority, the Lessee shall provide at his own expense main drainage or main sewerage connections from the building erected on the land as the planning authority may require.::::ضمن المدة المحددة من سلطة التخطيط, على المستأجر التمديد على حسابه وصلات الصرف الصحي وصرف المياه من البناية المرفوعة على الارض بما يتوافق مع متطلبات سلطة التخطيط::::Pendant la période de temps fixée par les autorités en charge de l''urbanisme, le preneur de bail doit fournir à ses propres frais une évacuation des eaux usées ou un raccordement au réseau d''évacuation des beaux usées depuis le bâtiment érigé sur le terrain selon les conditions des autorités en charge de l''urbanisme.::::Dentro de un período del tiempo que fije la autoridad de planificación, el arrendatario deberá proveer a sus propias expensas drenaje principal o principales conexiones de alcantarillado del edificio erigido en la tierra como la autoridad de planificación pueda requerir.::::::::No período de tempo a ser fixado pela autoridade de planejamento, o Locatário deve se responsabilizar pela despesa com a drenagem principal ou principais ligações de esgoto da construção no terreno, conforme, determinação da autoridade de planejamento.::::::::在一个由规划当局规定的时期内，租户将根据规划当局的要求自行支付其建筑的主要排水或下水管道连接费用。', 'c');
INSERT INTO condition_type (code, display_value, description, status) VALUES ('c2', 'Condition 2::::Условие 2::::الشرط الثاني::::Condition 2::::Condicion 2::::::::Condição 2::::::::条件2', 'Unless special written authority is given by the Commissioner, the Lessee shall commence development of the land within 5 years of the date of the granting of a lease. This shall also apply to further development of the land held under a lease during the term of the lease.::::Unless special written authority is given by the Commissioner, the Lessee shall commence development of the land within 5 years of the date of the granting of a lease. This shall also apply to further development of the land held under a lease during the term of the lease.::::ما لم يصدر مرسوم رسمي عن المفوض , على المستأجر البدء يتطوير الارض خلال 5 سنوات من تاريخ  الاستئجار. كما ينطبق ذلك على التطوير الاضافي للارض الواقعة ضمن بنود الاستئجار::::A moins que le Commissaire de donne des pouvoirs spéciaux par écrit, le preneur de bail doit commencer le développement du terrain dans les 5 ans suivant la date d''obtention du bail. Ceci doit aussi s''appliquer à d''autres développement du terrain tenu à bail pendant la durée du bail.::::A menos que la autoridad de otra orden, el Arrendatario debe colocar una valla alrededor de los límites de la tierra dentro de los 6 (seis) meses de la fecha de concesión y el arrendatario deberá mantener la valla a satisfacción de las autoridades.::::::::A menos que uma autorização especial enviado por escrito pelo Comissário, o Locatário deve começar o desenvolvimento da terra dentro de 5 anos a contar da data da concessão do contrato de arrendamento. O mesmo se aplica a um maior desenvolvimento da terra sob um contrato de arrendamento durante o período do arrendado.::::::::除非负责人给出了特殊的书面授权，否则租户将在获准租赁的5年内开始开发土地。这一做法也适用于尚在承租中的土地的进一步开发。', 'c');


ALTER TABLE condition_type ENABLE TRIGGER ALL;

--
-- Data for Name: mortgage_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

ALTER TABLE mortgage_type DISABLE TRIGGER ALL;

INSERT INTO mortgage_type (code, display_value, description, status) VALUES ('levelPayment', 'Level Payment::::Многоуровневый платеж::::دفعات متدرجة::::Niveau de Paiement::::Nivel de Pago::::::::Nível de Pagamento::::::::平均支付', '...::::::::...::::...::::...::::::::...::::::::...', 'c');
INSERT INTO mortgage_type (code, display_value, description, status) VALUES ('linear', 'Linear::::Линейный::::خطي::::Linéaire::::Lineal::::::::Linear::::::::线性的', '...::::::::...::::...::::...::::::::...::::::::...', 'c');
INSERT INTO mortgage_type (code, display_value, description, status) VALUES ('microCredit', 'Micro Credit::::Микро кредит::::القروض الصغيرة::::Micro Crédit::::Micro Credito::::::::Microcrédito::::::::小额信贷', '...::::::::...::::...::::...::::::::...::::::::...', 'c');


ALTER TABLE mortgage_type ENABLE TRIGGER ALL;

--
-- Data for Name: rrr_group_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

ALTER TABLE rrr_group_type DISABLE TRIGGER ALL;

INSERT INTO rrr_group_type (code, display_value, description, status) VALUES ('responsibilities', 'Responsibilities::::Ответственность::::المسؤوليات::::Responsabilités::::Responsabilidades::::Përgjegjësitë::::Responsabilidades::::ការទទួលខុសត្រូវ::::多种责任', '...::::::::::::...::::...::::...::::...::::...::::...', 'x');
INSERT INTO rrr_group_type (code, display_value, description, status) VALUES ('restrictions', 'Restrictions::::Ограничения::::القيود::::Restrictions::::Restricciones::::Kufizimet::::Restrições::::ការរឹបណ្តឹង::::多项限制', '...::::::::::::...::::...::::...::::...::::...::::...', 'c');
INSERT INTO rrr_group_type (code, display_value, description, status) VALUES ('rights', 'Rights::::Права::::الحقوق::::Droits::::Derechos::::Të drejtat::::Direitos::::សិទ្ធិ::::权利', '...::::::::::::...::::...::::...::::...::::...::::...', 'c');


ALTER TABLE rrr_group_type ENABLE TRIGGER ALL;

--
-- Data for Name: rrr_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

ALTER TABLE rrr_type DISABLE TRIGGER ALL;

INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('ownershipAssumed', 'rights', 'Ownership Assumed::::Принятое право собственности::::ملكية مفترضة::::Propriété supposée::::Propiedad Asumido::::Pronësi e Supozuar::::Dono Presumido::::បានសន្មត់ថាជាម្ចាស់កម្មសិទ្ធិ::::取得的所有权::::ပိုင်ဆိုင်မှု ရပိုင်ခွင့်', true, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('waterrights', 'rights', 'Water Right::::Право на водные ресурсы::::حق المياه::::Droit d''Eau::::Derechos de Agua::::E Drejta e Ujit::::Direito a água::::សិទ្ធិប្រើប្រាស់ទឹក::::水权::::တပ်မတော်ပိုင်/ Military', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'c', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('commonOwnership', 'rights', 'Common Ownership::::Общая собственность::::الملكية المشتركة::::Propriété Commune::::Propiedad Común::::Bashkëpronësi::::Propriedade Comum::::កម្មសិទ្ធិរួម::::共有产权制度::::စုပေါင်းပိုင်ဆိုင်မှု ', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('superficies', 'rights', 'Superficies::::Superficies::::الأسطح::::Superficies::::Superficies::::Sipërfaqe::::Superfícies::::ស្ទាក់ស្ទើ ឬសើៗ::::地上权::::မြေပေါ် ငှားရမ်းတည်ဆောက်မှု', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('agriActivity', 'rights', 'Agriculture Activity::::Сельскохозяйственная деятельность::::نشاط زراعي::::Activité Agricole::::Actividad Agricultura::::Aktivitet Bujqësor::::Atividade Agrária::::សកម្មភាពកសិកម្ម::::农业活动::::စိုက်ပျိုးရေးလုပ်ငန်း', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('informalOccupation', 'rights', 'Informal Occupation::::Неформальная оккупация::::أحتلال غير رسمي::::Occupation informelle::::Ocupación Informal::::Pushtim Informal::::Ocupação Informal::::មុខរបបមិនផ្លូវការ::::非正式占有::::ပုံစံမမှန်သော ဝင်ရောက်အသုံးပြုသူ', false, false, false, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'simpleRight');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('waterwayMaintenance', 'responsibilities', 'Waterway Maintenance::::Обслуживания каналов ирригации::::صيانة مجرى مياه::::Entretien Voie Navigable::::Mantenimiento Hidrovía::::Mirëmbajtje e Vijës së Ujit::::Manutenção do canal::::ថែរក្សាផ្លូវទឹក::::航道维护::::ရေစီးရေလာ ထိန်းသိမ်းခြင်း', false, false, false, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'simpleRight');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('caveat', 'restrictions', 'Caveat::::Арест::::مذكرة قانونية::::Caveat::::Salvedad::::Kufizim::::Embargo::::ព្រមាន កើនរំលឹកជាមុន::::附加说明::::ကြိုတင်အသိပေးခြင်း', false, true, true, 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension du LADM::::Extension a LADM::::Extension to LADM::::Extensão para LADM::::​ ពង្រីកទៅដល់  LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', 'x', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('customaryType', 'rights', 'Customary Right::::Традиционное право::::الحق العرفي::::Droit Coutumier::::Derecho Consuetudinario::::E Drejta Zakonore::::Direito Consuetudinário::::សិទ្ធិជាលក្ខណៈប្រពៃណី::::习惯产权::::ဓလေ့ထုံးတမ်းအရ မြေယာလုပ်ပိုင်ခွင့်', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'c', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('grazing', 'rights', 'Grazing Right::::Право выпаса::::حق الرعي::::Droit de Pacage::::Derechos de Pasto::::E Drejta e Kullotës::::Direito de Pasto::::សិទ្ធិក្នុងការច្រូតស្មៅ ឫសម្រាប់សត្វពាហនៈស៊ី::::放牧权::::ဌာနေပြည်သူ့စစ်/ BGF', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'c', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('mortgage', 'restrictions', 'Mortgage::::Ипотека::::الرهن::::Hypothèque::::Hipoteca::::Hipotekë::::Hipoteca::::របស់បញ្ជាំ::::抵押::::အပေါင်စာချုပ်ဖြင့် ပိုင်ဆိုင်ခြင်း', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'mortgage');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('usufruct', 'rights', 'Right to Extract::::Право использования для сбора урожая::::حق الانتفاع::::Usufruit::::Usufructo::::Uzufrukt::::Usufruto::::សិទ្ធិអាស្រ័យផល::::用益物权::::ထုတ်ယူသုံးစွဲပိုင်ခွင့်', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'c', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('ownership', 'rights', 'Ownership::::Право собственности::::ملكية::::Propriété::::Propietario::::Pronësi::::Proprietário::::ម្ចាស់កម្មសិទ្ធិ::::所有权::::ပိုင်ဆိုင်မှု', true, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'ownership');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('occupation', 'rights', 'Occupancy::::Оккупация::::إشغال::::Occupation::::Ocupación::::Pushtim::::Ocupação::::ការកាន់កាប់::::占有::::ဝင်ရောက်အသုံးပြုမှု', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'c', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('lease', 'rights', 'Lease::::Аренда::::الأيجار::::Bail::::Arrendamiento::::Qira::::Arrendamento::::ជួលរបស់របប::::租赁::::ငှားရမ်းမှု', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'lease');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('lifeEstate', 'rights', 'Life Estate::::Пожизненное право собственности::::حياة العقار::::Donation au dernier vivant::::Propiedades de Vida::::Renta Jetësore::::Estado de Vida::::អាយុរបស់សំណង់ដីធ្លី::::终身产业::::Life Estate', true, true, true, 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::Extension to LADM::::Extensão para LADM::::ពង្រីកទៅដល់  LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', 'x', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('monumentMaintenance', 'responsibilities', 'Monument Maintenance::::Обслуживание памятника::::صيانة نصب تذكاري::::Entretien Monument::::Mantenimiento Monumento::::Mirëmbajtje Monumenti::::Manutenção do Monumento::::ការថែរក្សាស្នាដែទុកអោយអ្នកជំនាន់ក្រោយ::::纪念物维护::::အထိမ်းအမှတ်နေရာ ထိန်းသိမ်းခြင်း', false, false, false, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'simpleRight');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('servitude', 'restrictions', 'Right of Way::::Сервитут::::حق الارتفاق::::Servitude::::Servidumbre::::Servitute::::Servidão::::ការដាក់គំនាប::::地役权::::တိုင်းရင်းသား လက်နက်ကိုင်/ Arms group', false, false, false, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'c', 'simpleRight');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('noBuilding', 'restrictions', 'Building Restriction::::Ограничение на здание::::قيد بناء::::Restriction Bâtiment::::Restricciones de Construcción::::Kufizim Ndërtimi::::Restrição de Construção::::ការហាមប្រាមការសាងសង់នានា::::建筑限制::::ငှားရမ်းမှု အနေအထား', false, false, false, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'simpleRight');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('adminPublicServitude', 'restrictions', 'Administrative Public Servitude::::Административный публичный сервитут::::الأدارة العامة لحق الارتفاق::::Servitude Publique Administrative::::Servidumbre Pública Administrativa::::Servitute publike::::Servidão Administrativa Pública::::ការដាក់គំនាបពីរដ្ឋបាលសាធារណៈ::::公共地役权管理::::လူထုပိုင်ဆိုင်မှုအား စီမံခန့်ခွဲခြင်း', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('apartment', 'rights', 'Apartment Ownership::::Право собственности на квартиру::::مالك الشقة::::Propriété d''Appartement::::Propiedad de Apartamento::::Pronësi Apartamenti::::Posse do Bem Imóvel::::ម្ចាស់កម្មសិទ្ធិសំណង់::::公寓的所有权::::တိုက်ခန်းပိုင်ဆိုင်မှု', true, true, true, 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::...::::Extension a LADM::::Extension to LADM::::Extensão para LADM::::ពង្រីកទៅដល់  LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', 'x', 'ownership');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('historicPreservation', 'restrictions', 'Historic Preservation::::Историческая резервация::::حفظ المواقع التاريحية::::Préservation Historique::::Preservación histórica::::Monument Historik::::Preservação Histórica::::ការថែរក្សាដែលជាប្រវត្តិសាស្រ្ត::::史迹保存::::သမိုင်းအမွေအနှစ် ထိန်းသိမ်းစောင့်ရှောက်ခြင်း', false, false, false, 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::...::::Extension a LADM::::Extension to LADM::::Extensão para LADM::::ពង្រីកទៅដល់  LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', 'x', 'simpleRight');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('fishing', 'rights', 'Fishing Right::::Рыболовное право::::حقوق الصيد::::Droit de pêche::::Derechos de Pesca::::E Drejtë Peshkimi::::Direito a Pesca::::សិទ្ធិក្នុងការនេសាទ::::渔业权::::ငါးဖမ်းခွင့်', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'c', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('limitedAccess', 'restrictions', 'Limited Access (to Road)::::Ограниченный доступ к дороге::::حق وصول محدود (على الطريق)::::Accès Limité (à la Route)::::Acceso limitado (a la vía)::::Hyrje e kufizuar (në rrugë)::::Acesso Restrito (à Estrada)::::មិនអាចចូលទៅដល់(ទៅកាន់ផ្លូវ)::::（道路）的受限权::::လမ်းအသုံးပြုမှု ကန့်သတ်ခြင်း ', false, false, false, 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::Extension to LADM::::Extensão para LADM::::ពង្រីកទៅដល់  LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', 'x', 'simpleRight');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('stateOwnership', 'rights', 'Gazetted Reserves::::Государственное право собственности::::صاحب الحالة::::Propriété de l''Etat::::Propiedad del Estado::::Pronësi Shtetërore::::Propriedade do Estado::::រដ្ឋជាម្ចាស់កម្មសិទ្ធិ::::国有产权::::တရားဝင် သတ်မှတ် အရံမြေ', true, false, false, 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::Extension to LADM::::Extensão para LADM::::ពង្រីកទៅដល់  LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', 'c', 'ownership');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('firewood', 'rights', 'Firewood Collection::::Сбор древисины::::جمع الحطب::::Collecte Bois à brûler::::Recolección de Leña::::Mbledhje Dru Zjarri::::Coleta de Lenha::::ការប្រមូលឈើថាមពល ឬអុស::::薪柴收集::::ကုမ္ပဏီပိုင်/ Company', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('monument', 'restrictions', 'Monument::::Памятник::::نصب تذكاري::::Monument::::Monumento::::Monument::::Monumento::::ស្នាដែទុកអោយអ្នកជំនាន់ក្រោយ::::永久纪念物::::အထိမ်းအမှတ်နေရာ', false, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'simpleRightholder');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status, rrr_panel_code) VALUES ('tenancy', 'rights', 'Tenancy::::Арендаторство::::الأيجار::::Tenure::::Tenencia::::Qiramarrje::::Posse::::ការជួល::::租佃::::သီးစားခ', true, true, true, '...::::::::...::::...::::...::::...::::...::::...::::...::::...', 'x', 'simpleRightholder');


ALTER TABLE rrr_type ENABLE TRIGGER ALL;

SET search_path = application, pg_catalog;

--
-- Data for Name: application_status_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE application_status_type DISABLE TRIGGER ALL;

INSERT INTO application_status_type (code, display_value, status, description) VALUES ('lodged', 'Lodged::::Подано::::مودع::::Déposée::::Alojado::::::::Apresentado::::::::已提交', 'c', 'Application has been lodged and officially received by land office::::Заявление подано и официально принято регистрационным офисом::::تم ايداع الطلب واستلامه رسميا من قبل دائرة الأراضي::::La demande a été déposée et officiellement reçue par l''Officier d''Etat::::La aplicación ha sido presentada y recibida oficialmente por la oficina de tierras::::::::Pedido foi apresentado e oficialmente recebido pelo escritório de terra::::::::申请已被提交并被土地管理局正式受理');
INSERT INTO application_status_type (code, display_value, status, description) VALUES ('approved', 'Approved::::Одобрено::::موافق عليه::::Approuvée::::Aprobado::::::::Aprovado::::::::已批准', 'c', '');
INSERT INTO application_status_type (code, display_value, status, description) VALUES ('annulled', 'Annulled::::Аннулировано::::ملغى::::Annulée::::Anulado::::::::Anulado::::::::被取消的', 'c', '');
INSERT INTO application_status_type (code, display_value, status, description) VALUES ('completed', 'Completed::::Завершено::::مكتمل::::Exécutée::::Completado::::::::Concluído::::::::已完成', 'c', '');
INSERT INTO application_status_type (code, display_value, status, description) VALUES ('requisitioned', 'Requisitioned::::Запрошена доп. информация::::يحتاج بيانات::::Réquisitionnée::::Requisado::::::::Requisitado::::::::正式要求', 'c', '');
INSERT INTO application_status_type (code, display_value, status, description) VALUES ('to-be-transferred', 'To be transferred::::::::ليتم تحويلها::::::::Para ser transferido::::::::Para ser transferido::::::::待转换', 'c', 'Application is marked for transfer.::::::::تم تعليم الطلب للنقل::::::::La aplicación esta marcada para ser transferida::::::::Perdido marcado para transferência.::::::::申请已被标记，用于转换');
INSERT INTO application_status_type (code, display_value, status, description) VALUES ('transferred', 'Transferred::::::::محول::::::::Transferido::::::::Transferido::::::::已转换', 'c', 'Application is transferred.::::::::تم نقل الطلب::::::::La aplicación fue transferida::::::::Pedido transferido.::::::::申请被转移');


ALTER TABLE application_status_type ENABLE TRIGGER ALL;

--
-- Data for Name: application_action_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE application_action_type DISABLE TRIGGER ALL;

INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('validateFailed', 'Quality Check Fails::::Проверка качества вернула ошибки::::فشلت عملية التحقق::::Le Contrôle Qualité a échoué::::Falla Control de Calidad::::::::Falha na Verificação da Qualidade::::::::质量检查失败', NULL, 'c', 'Quality check fails (automatically logged when a critical business rule failure occurs)::::Ошибки при проверки качества будут автоматически записаны в лог системы::::فحص الجودة فشل (تسجل تلقائيا عندما يحدث خطأ حرج في قاعدة أعمال )::::Le Contrôle Qualité a échoué (automatiquement déposé  quand un échec de règle métier critique se produit)::::Falla de Control de calidad (Se registra automáticamente cuando se produce un fallo crítico de reglas de negocio)::::::::Falha na Verificação da Qualidade (automaticamente registrada quando ocorre uma falha crítica na regra de negócio)::::::::质量检查失败(当出现关键商业规则失灵时要手动登录)');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('approve', 'Approve::::Одобрено::::الموافقة::::Approver::::Aprobado::::::::Aprovar::::::::批准', 'approved', 'c', 'Application is approved (automatically logged when application is approved successively)::::Заявление одобрено::::تمت الموافقة على الطلب (تم تسجيل الحركة تلقائيا عندما تمت الموافقة على التوالي)::::La demande est approuvée (automatiquement déposé  quand la demande est approuvée avec succès)::::Se aprobó la Solicitud (conectado automáticamente cuando la aplicación está aprobado sucesivamente)::::::::Pedido aprovado (automaticamente registrado quando pedido é aprovado, sucessivamente)::::::::申请被批准 (当申请被先后批准时，自动登录）');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('cancel', 'Cancel application::::Отменено::::الغاء طلب::::Annuler Demande::::Cancelar aplicación::::::::Cancelar pedido::::::::取消申请', 'annulled', 'c', 'Application cancelled by Land Office (action is automatically logged when application is cancelled)::::Отмена исполнения заявления::::تم الغاء الطلب من دائرة الأراضي (الحركة اوتوماتيكية وتم تسجيلها عند الغاء الطلب) ::::La demande est annulée par l''Officier d''Etat (l''action est automatiquement déposée quand la demande est annulée)::::Aplicación cancelado por la Oficina de Tierras (acción se registra automáticamente cuando se cancela la solicitud)::::::::Pedido cancelado pelo Escritório de Terra (a ação é automaticamente registrada quando um pedido é cancelado)::::::::申请被土地办取消(当申请被取消时，操作会自动登录）');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('archive', 'Archive::::Помещено в архив::::ارشفة::::Archiver::::Archivar::::::::Arquivar::::::::存档', 'completed', 'c', 'Paper application records are archived (action is manually logged)::::Отправление в архив бумажной копии заявления::::تم أرشفة سجلات الطلب الورقية ( الحركة تسجل يدويا)::::Les papiers de demande  sont archivés (l''action est manuellement déposée)::::Expedientes de solicitud en papel se archivan (acción se registra manualmente)::::::::Registros do pedido em papel são arquivados (a ação é registrada manualmente)::::::::文本申请记录存档（操作需手动登录）');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('assign', 'Assign::::Назначено::::تعيين::::Assigner::::Asignar::::::::Atribuir::::::::指定', NULL, 'c', '');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('requisition', 'Requisition:::Ulteriori Informazioni domandate dal richiedente::::Запрошена доп. информацию::::الأستفسار::: معلومات إضافية مطلوبة ::::Réquisition::::Requisicion:::Más información pedir al solicitante::::::::Requisitar ::: Mais informações solicitar ao requerente::::::::征用:::Ulteriori Informazioni domandate dal richiedente', 'requisitioned', 'c', 'Further information requested from applicant (action is manually logged)::::Дальнейшая информация запрошена у заявителя::::هنا ك حاجة الى المزيد من المعلومات من مقدم الطلب (تم تسجيل الحركة يدويا)::::Plus d''informations requises de la part du demandeur (l''action est automatiquement déposée)::::Información solicitada a solicitante (la acción se registra manualmente)::::::::Mais informações solicitar ao requerente (a ação é registrada manualmente)::::::::申请人要求的更多信息(操作需手动登录)');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('unAssign', 'Unassign::::Освобождено::::الغاء تعيين::::Retirer::::Sin Asignar::::::::Cancelar Atribuição::::::::未指定', NULL, 'c', '');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('lapse', 'Lapse::::Помечено как устарешее::::مضى عليه زمن::::Erreur::::Lapso::::::::Expirar::::::::失效', 'annulled', 'c', '');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('withdraw', 'Withdraw application::::Забрано::::اسحب الطلب::::Retirer Demande::::Retirar Aplicación::::::::Retirar pedido::::::::撤销申请', 'annulled', 'c', 'Application withdrawn by Applicant (action is manually logged)::::Заявление было забрано заявителем::::تم سحب الطلب من قبل مقدمه (تم تسجيل الحركة يدويا)::::Demande retirée par le demandeur (l''action est automatiquement déposée)::::Solicitud retirada por el solicitante (la acción se registra manualmente)::::::::Pedido retirado pelo Requerente (a ação é registrada manualmente)::::::::申请人撤销申请 (操作需要手动登录)');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('resubmit', 'Resubmit::::Подано заново::::اعادة تقديم::::Resoumettre::::Vuelva a enviar::::::::Reenviar::::::::重新提交', 'lodged', 'c', '');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('addSpatialUnit', 'Add spatial unit::::Add spatial unit::::إضافة وحدة مكانية::::Add spatial unit::::Agregar unidad espacial::::::::Adicionar unidade espacial::::::::添加空间单元', NULL, 'c', '');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('transfer', 'Transfer::::::::التحويل::::::::Transferencia::::::::Transferir::::::::转换', 'to-be-transferred', 'c', 'Marks the application for transfer::::::::وضع اشارة على الطلب للنقل::::::::Marca la solicitud de transferencia::::::::Marca o pedido para transferência::::::::在该申请上做记号用于转让');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('addDocument', 'Add document::::Добавлен документ::::اضافة وثيقة::::Ajouter Document::::Agregar documento::::::::Adicionar documento::::::::添加文件', NULL, 'c', 'Scanned Documents linked to Application (action is automatically logged when a new document is saved)::::Добавление документа к заявлению::::الوثائق الممسوحة ضوئيا والمرتبطة بالطلب (حركة تسجل تلقائيا عند نخزين وثيقة جديدة)::::Les documents scannés sont liés à la demande (l''action est automatiquement déposée quand un nouveau document est sauvegardé)::::Documentos escaneados vinculados a aplicaciones (acción se registra automáticamente cuando se guarda un documento nuevo)::::::::Documentos digitalizados anexados ao pedido (a ação é automaticamente registrada quando um novo documento é salvo)::::::::扫描与申请相关联的文件（新文件被保存后操作会自动登录）');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('dispatch', 'Dispatch::::Отослано::::توزيع::::Envoyer::::despacho::::::::Enviar::::::::发送', NULL, 'c', 'Application documents and new land office products are sent or collected by applicant (action is manually logged)::::Документы заявления отсылаются заявителю или он забирает их сам::::وثائق الطلب ومنتجات دائرة الأراضي الجديدة تم ارسالها وجمعها من قبل مقدم الطلب (الحركة تم تسجيلها يدويا)::::Les documents de demande et les produits du nouveau bureau du foncier sont envoyés à ou collecté par le demandeur (l''action est manuellement déposée)::::Los documentos de solicitud y los nuevos productos de oficina de tierras son enviados o recogidos por el solicitante (la acción se registra manualmente)::::::::Documentos do pedido e novos produtos do escritório de terra são enviadas ou coletados pelo requerente (a ação é registrada manualmente)::::::::申请文件和土地办的新资料由申请人发送或收集(操作需手动登录)');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('validate', 'Validate::::Проверено::::التحقق من صحة البيانات::::Valider::::Validar::::::::Validar::::::::确认', NULL, 'c', 'The action validate does not leave a mark, because validateFailed and validateSucceded will be used instead when the validate is completed.::::The action validate does not leave a mark, because validateFailed and validateSucceded will be used instead when the validate is completed.::::حركة التحقق من الصحة لا تترك أية علامة وذلك لاستخدام فشل-التحقق او نجح-التحقق عند أنتهاء عملية التحقق::::L''action valider ne laisse pas de trace car Erreur de Validation (validateFailed) et Succès de Validation (validateSucceded) seront utilisés quand la validation est exécutée.::::La validación acción no deja una marca, porque validateFailed y validateSucceded lugar se utilizará cuando se complete la validación.::::::::A ação Validar não está marcada, porque a validação da falha ou do sucesso será usada quando a validação for concluida.::::::::操作确认没有留下记号，因为当确认完成时，会显示“确认失败”和“确认成功”。');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('lodge', 'Lodgement Notice Prepared::::Подготовлено уведомление об оплате::::تم تحضير ملاحظة الايداع::::Notice de dépôt préparée::::Aviso presentación Preparado::::::::Aviso de Apresentação Preparado::::::::提交通知书已准备好', 'lodged', 'c', 'Lodgement notice is prepared (action is automatically logged when application details are saved for the first time::::Подготовлено уведомление об оплате::::تم تجهيز إشعار أيداع (يتم تسجيل هذه الحركة تلقائيا عند تخزين تفاصيل الطلب لاول مرة)::::La notice de dépôt set préparée (l''action est automatiquement déposée quand les détails de la demande sont sauvegardé pour la première fois)::::Se prepara aviso presentación (acción se registra automáticamente cuando se guardan detalles de la aplicación por primera vez::::::::Aviso de apresentação preparado (a ação é automaticamente registrada quando os dados do pedido são salvos pela primeira vez)::::::::提交通知已准备好 (当申请详情被首次保存时操作会自动登录）');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('validatePassed', 'Quality Check Passes::::Успешная проверка качества::::عملية التحقق تمت بنجاح::::Le Contrôle Qualité a réussi::::Aprueba Control de Calidad::::::::Verificação da Qualidade de Passes::::::::质量检查通过', NULL, 'c', 'Quality check passes (automatically logged when business rules are run without any critical failures)::::Успешная проверка качества::::فحص الجودة نجح (تسجل تلقائيا عندما لا يحدث أي خطأ حرج لأي قاعدة أعمال)::::Le Contrôle Qualité a réussi (automatiquement déposé  quand des règles métier sont passées sans erreur critique)::::Pases de verificación de la calidad (registran automáticamente cuando las reglas de negocio se ejecutan sin ningún tipo de fallos críticos)::::::::Verificação da Qualidade de Passes (automaticamente registrada quando as regras de negócio são executados sem quaisquer falhas críticas)::::::::质量检查通过 (当商业规则运行良好，没有出现任何失灵时，自动登录)');


ALTER TABLE application_action_type ENABLE TRIGGER ALL;

--
-- Data for Name: request_category_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE request_category_type DISABLE TRIGGER ALL;

INSERT INTO request_category_type (code, display_value, description, status) VALUES ('informationServices', 'Information Services::::Информационные услуги::::خدمات معلوماتية::::Services Information::::Servicios de Información::::::::Serviços de Informação::::::::信息服务', '...::::...::::خدمات معلوماتية::::...::::...::::::::...::::::::...', 'c');
INSERT INTO request_category_type (code, display_value, description, status) VALUES ('registrationServices', 'Registration Services::::Регистрационные услуги::::خدمات تسجيل::::Services Enregistrement::::Servicios de Registro::::::::Serviços de Registro::::::::登记服务', '...::::...::::خدمات تسجيل::::...::::...::::::::...::::::::...', 'c');


ALTER TABLE request_category_type ENABLE TRIGGER ALL;

--
-- Data for Name: type_action; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE type_action DISABLE TRIGGER ALL;

INSERT INTO type_action (code, display_value, description, status) VALUES ('new', 'New::::Новый::::جديد::::Nouveau::::Nuevo::::::::Novo::::::::新的', '...::::...::::...::::...::::...::::::::...::::::::...', 'c');
INSERT INTO type_action (code, display_value, description, status) VALUES ('cancel', 'Cancel::::Отмена::::الغاء::::Annuler::::Cancelar::::::::Cancelar::::::::取消', '...::::...::::...::::...::::...::::::::...::::::::...', 'c');
INSERT INTO type_action (code, display_value, description, status) VALUES ('vary', 'Vary::::Изменить::::تعديل::::Varier::::Variar::::::::Modificar::::::::变动', '...::::...::::...::::...::::...::::::::...::::::::...', 'c');


ALTER TABLE type_action ENABLE TRIGGER ALL;

--
-- Data for Name: request_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE request_type DISABLE TRIGGER ALL;

INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('surveyPlanCopy', 'informationServices', 'Survey Plan Copy::::Копия кадастрового плана::::نسخة خطة مساحة::::Copie Plan de Levé::::Copia del Plan de Levantamiento Topográfico::::::::Vistoria da Cópia do Plano::::::::调查计划复印件', '...::::...::::...::::...::::...::::::::...::::::::...', 'x', 1, 1.00, 0.00, 0.00, 0, NULL, NULL, NULL, 'Survey::::::::المسح::::::::Topografía::::::::Survey::::::::调查', 'documentSearch');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('documentCopy', 'informationServices', 'Document Copy::::Копия документа::::نسخ وثيقة::::Copie Document::::Copiar Documento::::::::Copiar Documento::::::::文件复印', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 1, 0.50, 0.00, 0.00, 0, NULL, NULL, NULL, 'Documents::::::::الوثائق::::::::Documentos::::::::Documents::::::::文件', 'documentSearch');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('cadastrePrint', 'informationServices', 'Cadastre Print::::Печать кадастровых данных::::اطبع المساحة::::Imprimer Cadastre::::Imprimir Catastro::::::::Cadastrar Impressão::::::::地籍打印', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 1, 0.50, 0.00, 0.00, 0, NULL, NULL, NULL, 'Supporting::::::::دعم::::::::Apoyando::::::::Supporting::::::::支持', 'map');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('serviceEnquiry', 'informationServices', 'Service Enquiry::::Запрос информации о заявлении::::طلب معلومات::::Service Enquête::::Servicio Civico::::::::Consultar Serviço::::::::服务查询', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 1, 0.00, 0.00, 0.00, 0, NULL, NULL, NULL, 'Supporting::::::::دعم::::::::Apoyando::::::::Supporting::::::::支持', 'applicationSearch');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('redefineCadastre', 'registrationServices', 'Redefine Cadastre::::Изменение кадастрового объекта::::إعادة تعريف المساحة::::Redéfinir Cadastre::::Redefinir Catastro::::::::Redefinir Cadastro::::::::重新定义地籍', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 30, 25.00, 0.10, 0.00, 1, NULL, NULL, NULL, 'Survey::::::::المسح::::::::Topografía::::::::Survey::::::::调查', 'cadastreTransMap');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('mapExistingParcel', 'registrationServices', 'Map Existing Parcel::::::::الخارطة- القطع الموجودة ::::::::Mapa de Parcela Existente::::::::Mapear Parcela Existente::::::::勘察现有宗地', '', 'x', 30, 0.00, 0.00, 0.00, 0, 'Allows to make changes to the cadastre', NULL, NULL, 'Systematic Registration::::::::التسجيل المنتظم::::::::Registro Sistemático::::::::Systematic Registration::::::::系统登记', 'cadastreTransMap');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('newState', 'registrationServices', 'New State Title::::Новое право собственности (государственное)::::سند ملكية عقار جديد::::Nouveau Titre d''Etat::::Nuevo estado del título::::::::Novo Título do Estado::::::::新的国有产权', '...::::...::::...::::...::::...::::::::...::::::::...', 'x', 5, 0.00, 0.00, 0.00, 1, 'State Estate', NULL, NULL, 'General Registration::::::::التسجيل العام::::::::Registros Generales::::::::General Registration::::::::普通登记', 'newProperty');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('newFreehold', 'registrationServices', 'New Freehold Title::::Новое право собственности (свободное)::::سند ملكية جديد::::Nouveau Titre Propriété::::Nuevo título de propiedad absoluta::::::::Novo Título de Propriedade Livre::::::::新的终身保有产权', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Fee Simple Estate', NULL, NULL, 'General Registration::::::::التسجيل العام::::::::Registros Generales::::::::General Registration::::::::普通登记', 'newProperty');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('newApartment', 'registrationServices', 'New Apartment Title::::Новое право на квартиру::::سند ملكية . لشقة جديدة::::Titre Nouvel Appartement::::Nuevo Título de Apartamento::::::::Novo Título de Bem Imóvel::::::::新公寓产权', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.02, 1, 'Apartment Estate', 'apartment', 'new', 'General Registration::::::::التسجيل العام::::::::Registros Generales::::::::General Registration::::::::普通登记', 'newProperty');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('recordTransfer', 'informationServices', 'Record transfer::::Record transfer in russian::::نقل السجل::::Record transfer in french::::Traslado de Expediente::::::::Registrar transferência::::::::记录转换', '...::::...::::...::::...::::...::::::::...::::::::...', 'x', 1, 0.00, 0.00, 0.00, 0, NULL, NULL, NULL, 'Ownership::::::::ملكية::::::::Propiedad::::::::Ownership::::::::所有权', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('varyCaveat', 'registrationServices', 'Vary caveat::::Изменить арест::::تعديل القيد::::Varier Caveat::::Variación de Salvedad::::::::Modificar Embargo::::::::更改附加说明', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, '<Caveat> <reference>', 'caveat', 'vary', 'Caveat::::::::مذكرة قانونية::::::::Salvedad::::::::Caveat::::::::附加说明', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('varyMortgage', 'registrationServices', 'Vary Mortgage::::Изменить ипотеку::::تعديل الرهن.::::Varier Hypothèque::::Variacion Hipoteca::::::::Modificar Hipoteca::::::::变更抵押', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 1, 5.00, 0.00, 0.00, 1, 'Change on the mortgage', 'mortgage', 'vary', 'Mortgage::::::::رهن::::::::Hipoteca::::::::Mortgage::::::::抵押', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('noteOccupation', 'registrationServices', 'Occupation Noted::::Уведомление о самозахвате::::ملاحظة استخدام::::Mention Occupation::::Ocupación Conocido::::::::Nota de Ocupação::::::::记录的（房屋、土地）使用方式', '...::::...::::...::::...::::...::::::::...::::::::...', 'x', 5, 5.00, 0.00, 0.01, 1, 'Occupation by <name> recorded', NULL, NULL, 'Ownership::::::::ملكية::::::::Propietario::::::::Ownership::::::::所有权', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('registerLease', 'registrationServices', 'Register Lease::::Регистрация права пользования::::تسجيل ايجار::::Enregistrer Bail::::Registro Arrendamiento::::::::Cadastrar Arrendamento::::::::登记租赁', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.01, 1, 'Lease of nn years to <name>', 'lease', 'new', 'Lease::::::::إيجار::::::::Arrendamiento::::::::Lease::::::::租赁', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('historicOrder', 'registrationServices', 'Register Historic Preservation Order::::Регистрация недвижимости исторического назначения::::تسجيل امر حفظ تاريخي::::Enregistrer Ordonnance de Préservation Historique::::Registrar Orden de Preservación Histórica::::::::Cadastrar Ordem de Preservação Histórica::::::::登记史迹保存命令', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Historic Preservation Order', 'noBuilding', 'new', 'Other Registration::::::::تسجيل آخر::::::::Otro registro::::::::Other Registration::::::::其他登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('obscurationRequest', 'registrationServices', 'Privacy Request::::::::طلب حجب معلومات::::::::::::::::Privacy Request::::::::', '', 'c', 30, 0.00, 0.00, 0.00, 0, NULL, NULL, NULL, 'Gender Safeguards::::::::تسجيل آخر::::::::::::::::Gender Safeguards::::::::', 'partySearch');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('recordRelationship', 'registrationServices', 'Record Person Relationship::::::::تسجيل العلاقة::::::::::::::::Cadastrar Relacionamento da Pessoal::::::::记录个人关系', '', 'c', 30, 0.00, 0.00, 0.00, 0, NULL, NULL, NULL, 'Gender Safeguards::::::::تسجيل آخر::::::::::::::::Other Registration::::::::其他登记', 'recordRelationship');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('regnPowerOfAttorney', 'registrationServices', 'Registration of Power of Attorney::::Регистрация доверенности::::تسجيل وكالة::::Enregistrement de la Procuration::::Registro de Poder Legal::::::::Cadastrar Procuração::::::::委托书登记', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 3, 5.00, 0.00, 0.00, 0, NULL, NULL, NULL, 'Documents::::::::الوثائق::::::::Documentos::::::::Documents::::::::文件', 'documentTrans');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('titleSearch', 'informationServices', 'Title Search::::Поиск недвижимости::::البحث عن سند ملكية.::::Recherche Titre::::Busqueda de Títulos::::::::Localizar Título::::::::产权调查', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 1, 5.00, 0.00, 0.00, 1, NULL, NULL, NULL, 'Supporting::::::::دعم::::::::Apoyando::::::::Supporting::::::::支持', 'propertySearch');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('lodgeObjection', 'registrationServices', 'Lodge Objection::::Заявление оспаривания права::::اعتراض::::Objection Dépôt::::Objección de Alojamiento::::::::Apresentar Objeção::::::::提出异议', '...::::...::::...::::...::::...::::::::...::::::::...', 'x', 90, 5.00, 0.00, 0.00, 1, NULL, NULL, NULL, 'Systematic Registration::::::::التسجيل المنتظم::::::::Registro Sistemático::::::::Systematic Registration::::::::系统登记', 'newProperty');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('removeCaveat', 'registrationServices', 'Remove Caveat::::Снять ограничение::::...::::Supprimer Caveat::::Remover Salvedad::::::::Retirar Embargo::::::::删除附加说明', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Caveat <reference> removed', 'caveat', 'cancel', 'Caveat::::::::مذكرة قانونية::::::::Salvedad::::::::Caveat::::::::附加说明', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('newDigitalTitle', 'registrationServices', 'Convert to Digital Title::::Новое право собственности (конвертация)::::تحويل الى سند ملكية الكتروني::::Convertir en Titre Numérique::::Convertir a Título Digital::::::::Converter para Título Digital::::::::转换为数字化的产权', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 0.00, 0.00, 0.00, 1, 'Title converted to digital format', NULL, NULL, 'General Registration::::::::التسجيل العام::::::::Registros Generales::::::::General Registration::::::::普通登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('regnDeeds', 'registrationServices', 'Deed Registration::::Регистрация сделки::::تسجيل حركة::::Enregistrement Acte::::Registro de Título de Propiedad::::::::Escritura do Registro::::::::契据登记', '...::::...::::...::::...::::...::::::::...::::::::...', 'x', 3, 1.00, 0.00, 0.00, 0, NULL, NULL, NULL, 'General Registration::::::::التسجيل العام::::::::Registros Generales::::::::General Registration::::::::普通登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('mortgage', 'registrationServices', 'Register Mortgage::::Регистрация ипотеки::::تسجيل رهن::::Enregistrer Hypothèque::::Registro Arrendamiento::::::::Cadastrar Hipoteca::::::::登记抵押', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Mortgage to <lender>', 'mortgage', 'new', 'Mortgage::::::::رهن::::::::Arrendamiento::::::::Mortgage::::::::抵押', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('servitude', 'registrationServices', 'Register Servitude::::Регистрация сервитута::::حق استخدام الطريق::::Enregistrer Servitude::::Registro de Servidumbre::::::::Cadastrar Servidão::::::::登记地役权', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Servitude over <parcel1> in favour of <parcel2>', 'servitude', 'new', 'Other Registration::::::::تسجيل آخر::::::::Otro registro::::::::Other Registration::::::::其他登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('limitedRoadAccess', 'registrationServices', 'Register Limited Road Access::::Регистрация ограниченного доступа к дороги::::تسجيل  دخول طريق محدودة::::Enregistrer Route Accès Limité::::Registrar Acceso Limitado a carretera::::::::Cadastrar Estrada com Acesso Restrito::::::::登记受限的道路通行权', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Limited Road Access', 'limitedAccess', NULL, 'Other Registration::::::::تسجيل آخر::::::::Otro registro::::::::Other Registration::::::::其他登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('lifeEstate', 'registrationServices', 'Establish Life Estate::::Регистрация пожизненного права пользования::::انشاء تمليك عقار مدى الحياة.::::Constitution Donation au dernier vivant / Viager::::Establecer Bienes Raices de por vida::::::::Estabelecer Propriedade da Vida::::::::建立终身不动产', '...::::...::::...::::...::::...::::::::...::::::::...', 'x', 5, 5.00, 0.00, 0.02, 1, 'Life Estate for <name1> with Remainder Estate in <name2, name3>', 'lifeEstate', 'new', 'Other Registration::::::::تسجيل آخر::::::::Otro registro::::::::Other Registration::::::::其他登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('usufruct', 'registrationServices', 'Register Usufruct::::Регистрация права пользования ресурсами::::حق الانتفاع::::Enregistrer Usufruit::::Registrar Usufructo::::::::Cadastrar Usufruto::::::::登记使用权', '...::::...::::...::::...::::...::::::::...::::::::...', 'x', 5, 5.00, 0.00, 0.00, 1, '<usufruct> right granted to <name>', 'usufruct', 'new', 'Other Registration::::::::تسجيل آخر::::::::Otro registro::::::::Other Registration::::::::其他登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('removeRight', 'registrationServices', 'Remove Right (General)::::Прекратить право::::الغاء حق (عام)::::Supprimer Droit (Général)::::Remover Derechos (General)::::::::Retirar Direito (Geral)::::::::取消权利 (概况)', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, '<right> <reference> cancelled', NULL, 'cancel', 'General Registration::::::::التسجيل العام::::::::Registros Generales::::::::General Registration::::::::普通登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('varyLease', 'registrationServices', 'Vary Lease::::Изменить право пользования::::تعديل الايجار::::Varier Bail::::Variación Arrendamiento::::::::Modificar Arrendamento::::::::变更租赁', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Variation of Lease <reference>', 'lease', 'vary', 'Lease::::::::إيجار::::::::Lease::::::::Lease::::::::租赁', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('cancelRelationship', 'registrationServices', 'Cancel Person Relationship::::::::الغاء صلة الشخص ::::::::::::::::Cancelar Relacinamento da Pessoa::::::::取消个人关系', '', 'c', 30, 0.00, 0.00, 0.00, 0, NULL, NULL, NULL, 'Gender Safeguards::::::::تسجيل آخر::::::::::::::::Other Registration::::::::其他登记', 'cancelRelationship');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('cadastreExport', 'informationServices', 'Cadastre Export::::Экспорт кадастра еще текст::::تصدير المساحة::::Exporter Cadastre::::Exportanción de Catastro::::::::Exportar Cadastro::::::::地籍输出', '...::::::::...::::...::::...::::::::...::::::::...', 'x', 1, 0.00, 0.10, 0.00, 0, NULL, NULL, NULL, 'Supporting::::::::دعم::::::::Soporte::::::::Supporting::::::::支持', NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('cadastreBulk', 'informationServices', 'Cadastre Bulk Export::::Массовая загрузка кадастровых данных::::تصدير  رزمة مساحة::::Export Cadastre Groupé::::Exportanción de Catastro en Masa::::::::Exportar Cadastro em Massa::::::::地籍批量输出', '...::::...::::...::::...::::...::::::::...::::::::...', 'x', 5, 5.00, 0.10, 0.00, 0, NULL, NULL, NULL, 'Supporting::::::::دعم::::::::Soporte::::::::Supporting::::::::支持', NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('regnStandardDocument', 'registrationServices', 'Registration of Standard Document::::Регистрация типового документа::::تسجيل وثيقة مرجعية::::Enregistrement du Document Standard::::Registro del Documento Estándar::::::::Cadastrar Documento Padrão::::::::标准文件登记', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 3, 5.00, 0.00, 0.00, 0, NULL, NULL, NULL, 'Documents::::::::الوثائق::::::::Documentos::::::::Documents::::::::文件', 'documentTrans');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('cnclStandardDocument', 'registrationServices', 'Withdraw Standard Document::::Удалить типовой документ::::سحب الوثيقة المرجعية::::Retirer Document Standard::::Retirar Documento Estándar::::::::Retirar Documento Padrão::::::::撤销标准文件', 'To withdraw from use any standard document (such as standard mortgage or standard lease)::::...::::...::::...::::Para prohibir el uso de cualquier documento estándar (como hipoteca estándar o arrendamiento estándar)::::::::Para retirar do uso qualquer documento padrão (como hipoteca padrão ou arrendamento padrão)::::::::撤销使用任何标准文件 (比如标准抵押或标准租赁)', 'c', 1, 5.00, 0.00, 0.00, 0, NULL, NULL, NULL, 'Documents::::::::الوثائق::::::::Documentos::::::::Documents::::::::文件', 'documentTrans');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('cnclPowerOfAttorney', 'registrationServices', 'Cancel Power of Attorney::::Нотариальная доверенность::::الغاء التوكيل::::Annuller Procuration::::Cancelar Poder Legal::::::::Cancelar Procuração::::::::取消委托书', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 1, 5.00, 0.00, 0.00, 0, NULL, NULL, 'cancel', 'Documents::::::::الوثائق::::::::Documentos::::::::Documents::::::::文件', 'documentTrans');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('cadastreChange', 'registrationServices', 'Change to Cadastre::::Изменение кадастра::::تغيير المساحة::::Modification du Cadastre::::Cambio de Catastro::::::::Modificar Cadastro::::::::变更为地籍', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 30, 25.00, 0.10, 0.00, 1, NULL, NULL, NULL, 'Survey::::::::المسح::::::::Topografía::::::::Survey::::::::调查', 'cadastreTransMap');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('varyRight', 'registrationServices', 'Vary Right (General)::::Изменить право (общее)::::تعديل حق (عام)::::Varier Droit (Général)::::Variación de Derechos (General)::::::::Modificar Direitos (Geral)::::::::变更权利 (概况)', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Variation of <right> <reference>', NULL, 'vary', 'General Registration::::::::التسجيل العام::::::::Registros Generales::::::::General Registration::::::::普通登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('caveat', 'registrationServices', 'Register Caveat::::Регистрация ареста::::تسجيل  قيد::::Enregistrer Caveat::::Registrar Salvedad::::::::Cadastrar Embargo::::::::记录附加说明', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 50.00, 0.00, 0.00, 1, 'Caveat in the name of <name>', 'caveat', 'new', 'Caveat::::::::مذكرة قانونية::::::::Salvedad::::::::Caveat::::::::附加说明', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('newOwnership', 'registrationServices', 'Change of Ownership::::Смена владельца::::تغيير الملكية::::Changement de propriétaire::::Cambio de Propietario::::::::Mudança de Proprietário::::::::所有权变更', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.02, 1, 'Transfer to <name>', 'ownership', 'vary', 'Ownership::::::::ملكية::::::::Propietario::::::::Ownership::::::::所有权', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('waterRights', 'registrationServices', 'Register Water Rights::::Регистрация права пользования водными ресурсами::::تسجيل حق الانتفاع (مياه).::::Enregistrer Droits d''Eau::::Registrar Derechos del Agua::::::::Cadastrar Direitos a Água::::::::登记水权', '...::::...::::...::::...::::...::::::::...::::::::...', 'x', 5, 5.00, 0.01, 0.00, 1, 'Water Rights granted to <name>', 'waterrights', 'new', 'Other Registration::::::::تسجيل آخر::::::::Otro registro::::::::Other Registration::::::::其他登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('buildingRestriction', 'registrationServices', 'Register Building Restriction::::Регистрация ограничения на строение::::تسجيل قيود بناية::::Enregistrer Restriction de Bâtiment::::Registrar Restricciones de Construcción::::::::Cadastrar Restrição de Construção::::::::登记建筑限制', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Building Restriction', 'noBuilding', 'new', 'Other Registration::::::::تسجيل آخر::::::::Otro registro::::::::Other Registration::::::::其他登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('removeRestriction', 'registrationServices', 'Remove Restriction (General)::::Снять ограничение::::ازالة قيد::::Supprimer Restriction (Général)::::Remover Restriccion (General)::::::::Retirar Restrição (Geral)::::::::取消限制 (概况)', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, '<restriction> <reference> cancelled', NULL, 'cancel', 'General Registration::::::::التسجيل العام::::::::Registros Generales::::::::General Registration::::::::普通登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('newDigitalProperty', 'registrationServices', 'New Digital Property::::Регистрация существующего права собственности::::أنشاء سند الكتروني جديد::::Nouvelle Propriété Numérique::::Nueva Propiedad Digital::::::::Nova Propriedade Digital::::::::新的数字财产', '...::::...::::...::::...::::...::::::::...::::::::...', 'x', 5, 0.00, 0.00, 0.00, 1, NULL, NULL, NULL, 'General Registration::::::::التسجيل العام::::::::Registros Generales::::::::General Registration::::::::普通登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('systematicRegn', 'registrationServices', 'Systematic Registration Claim::::Запрос на системную регистрацию::::المطالبة بتسجيل منتظم::::Déclaration Enregistrement Systèmatique::::Reclamo registro sistemático::::::::Reinvidicar Registro Regular::::::::系统登记申明', '...::::...::::...::::...::::...::::::::...::::::::...', 'x', 90, 50.00, 0.00, 0.00, 0, 'Title issued at completion of systematic registration', 'ownership', 'new', 'Systematic Registration::::::::التسجيل المنتظم::::::::Registro Sistemático::::::::Systematic Registration::::::::系统登记', 'newProperty');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('regnOnTitle', 'registrationServices', 'Registration on Title::::Регистрация права собственности::::التسجيل على سند ملكية::::Enregistrement du Titre::::Registro de Título::::::::Registrar no Título::::::::产权登记', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.01, 1, NULL, NULL, NULL, 'General Registration::::::::التسجيل العام::::::::Registros Generales::::::::General Registration::::::::普通登记', 'property');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code, display_group_name, service_panel_code) VALUES ('cancelProperty', 'registrationServices', 'Cancel title::::Прекращение права собственности::::الغاء سند ملكية::::Annuler Titre::::Cancelar Título::::::::Cancelar Título::::::::取消产权', '...::::...::::...::::...::::...::::::::...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, '', NULL, 'cancel', 'General Registration::::::::التسجيل العام::::::::Registros Generales::::::::General Registration::::::::普通登记', 'property');


ALTER TABLE request_type ENABLE TRIGGER ALL;

--
-- Data for Name: service_status_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE service_status_type DISABLE TRIGGER ALL;

INSERT INTO service_status_type (code, display_value, status, description) VALUES ('cancelled', 'Cancelled::::Отменен::::ملغاة::::Annulé::::Cancelado::::::::Cancelado::::::::被取消', 'c', '...::::...::::...::::...::::...::::::::...::::::::...');
INSERT INTO service_status_type (code, display_value, status, description) VALUES ('pending', 'Pending::::На исполнении::::قيد الانتظار::::En attente::::Pendiente::::::::Pendente::::::::待定', 'c', '...::::...::::...::::::::...::::::::...::::::::...');
INSERT INTO service_status_type (code, display_value, status, description) VALUES ('completed', 'Completed::::Завершен::::مكتملة.::::Exécuté::::Completado::::::::Concluído::::::::已完成', 'c', '...::::...::::...::::...::::...::::::::...::::::::...');
INSERT INTO service_status_type (code, display_value, status, description) VALUES ('lodged', 'Lodged::::Зарегистрирован::::مودعة::::Enregistré::::Alojado::::::::Apresentado::::::::已提交', 'c', 'Application for a service has been lodged and officially received by land office::::Заявление было подано и зарегистрировано в регистрационном офисе::::...::::Demande de service a été déposée et officiellement reçue par l''Officier d''Etat::::La solicitud de servicio ha sido oficialmente recibido por la oficina de tierras::::::::Pedido de serviço foi apresentado e oficialmente recebido pelo escritório de terra::::::::服务申请已经提出，并被土地管理局正式受理');


ALTER TABLE service_status_type ENABLE TRIGGER ALL;

--
-- Data for Name: service_action_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE service_action_type DISABLE TRIGGER ALL;

INSERT INTO service_action_type (code, display_value, status_to_set, status, description) VALUES ('lodge', 'Lodge::::Подать заявление::::ايداع::::Déposer::::Alojado::::::::Apresentar::::::::提出', 'lodged', 'c', 'Application for service(s) is officially received by land office (action is automatically logged when application is saved for the first time)::::Заявление принято официально регистрационным офисом (событие будет автоматически записано в журнал событий)::::.استلام الطلب رسميا من قبل دائرة الاراضي  حيث يتم حفظه بحالة مودع::::Demande de service(s) officiellement reçue par l''Officier d''Etat (action déposée automatiquement quand la demande est sauvegardée pour la première fois)::::La solicitud de servicio(s) fue recibida oficialmente por la oficina de tierras (la acción se registra automáticamente cuando la aplicación se guarda por primera vez)::::::::Pedido de serviço(s) foi apresentado e oficialmente recebido pelo escritório de terra (a ação é automaticamente registrada quando o pedido é salvo pela primeira vez)::::::::申请服务由土地办正式受理（当申请被首次保存时操作会自动登录）');
INSERT INTO service_action_type (code, display_value, status_to_set, status, description) VALUES ('revert', 'Revert::::Вернуть на доработку::::تراجع::::Retourner::::Revertir::::::::Reverter::::::::恢复', 'pending', 'c', 'The status of the service has been reverted to pending from being completed (action is automatically logged when a service is reverted back for further work)::::Статус услуги изменен к "исполняется" (событие будет автоматически записано в журнал событий)::::يتم تغيير حالة الخدمة الى  قيد الانتظار عندما تحتاج الخدمة الى مزيد من المعلومات او العمل::::Le statut du service a été retourné du statut "complet" au statut "en attente" (action déposée automatiquement quand un service est retourné pour plus de travail)::::El estado del servicio se ha devuelto a la espera de ser completado (acción se registra automáticamente cuando un servicio se devolvió de nuevo para seguir trabajando)::::::::O estado do serviço foi revertido para pendente de ser concluído (a ação é automaticamente registrada quando um serviço é revertido para trabalhos futuros)::::::::该服务状态已经从已完成回复到待定状态（当某项服务需恢复下一步工作时，操作会自动登录）。');
INSERT INTO service_action_type (code, display_value, status_to_set, status, description) VALUES ('cancel', 'Cancel::::Отмена::::الغاء::::Annuler::::Cancelar::::::::Cancelar::::::::取消', 'cancelled', 'c', 'Service is cancelled by Land Office (action is automatically logged when a service is cancelled)::::Отмена услуги регистрационным офисом (отмена будет автоматически зафиксирована в журнале событий)::::تم الغاء الخدمة من قبل دائرة الاراضي . الخدمات الملغاة يتم تسجيلها تلقائيا من قبل النظام::::Service annulé par l''Officier d''Etat (action déposée automatiquement quand un service est annulé)::::Servicio es cancelado por la Oficina de Tierras (acción se registra automáticamente cuando se cancela un servicio)::::::::Serviço cancelado pelo Escritório de Terra (a ação é automaticamente registrada quando um serviço é cancelado)::::::::服务被土地管理部门取消了（当某项服务被取消时，操作会自动登录）');
INSERT INTO service_action_type (code, display_value, status_to_set, status, description) VALUES ('start', 'Start::::Запустить::::ابدأ::::Commencer::::Inicio::::::::Iniciar::::::::开始', 'pending', 'c', 'Provisional RRR Changes Made to Database as a result of application (action is automatically logged when a change is made to a rrr object)::::Определенные изменения должны быть сделаны, относящиеся к услуги (событие будет автоматически записано в журнал событий)::::يتم تسجيل الحالة عندما يحدث تغيير على الكائن::::Changement des RRR provisionnels réalisé dans la base de données suite au résultat de la demande (action déposée automatiquement quand un changement est fait sur un objet RRR)::::Cambios a los RRR Provisionales realizadas a la base de datos como resultado de la aplicación (acción se registra automáticamente cuando se realiza un cambio en un objeto rrr)::::::::Alterações Provisórias DRR Feitos à Base de Dados como resultado do pedido (a ação é automaticamente registrada quando é feita uma alteração para um objeto drr)::::::::作为申请结果而对数据库作出的临时RRR改变（当对rrr目标作出某些变化时操作会自动登录）。');
INSERT INTO service_action_type (code, display_value, status_to_set, status, description) VALUES ('complete', 'Complete::::Завершить::::انهاء::::...::::Completo::::::::Concluir::::::::完成', 'completed', 'c', 'Application is ready for approval (action is automatically logged when service is marked as complete::::Заявление готово к одобрению (событие будет автоматически записано в журнал событий)::::الطلب جاهز للموافقة عندما تتغير حالة الخدمة الى مكتملة::::Demande prête pour approbation (action déposée automatiquement quand le service est marqué comme complet)::::Aplicación está lista para su aprobación (la acción se registra automáticamente cuando el servicio se marca como completa)::::::::Pedido pronto para aprovação (a ação é automaticamente registrada quando o serviço é marcado como concluído)::::::::申请已准备妥当（当服务显示完成时，操作会自动登录）');


ALTER TABLE service_action_type ENABLE TRIGGER ALL;

SET search_path = cadastre, pg_catalog;

--
-- Data for Name: area_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE area_type DISABLE TRIGGER ALL;

INSERT INTO area_type (code, display_value, description, status) VALUES ('calculatedArea', 'Calculated Area::::Вычисленная Площадь::::المساحة المحسوبة::::Superficie Calculée::::Area Calculada::::::::Área Calculada::::::::已计算面积', '', 'c');
INSERT INTO area_type (code, display_value, description, status) VALUES ('nonOfficialArea', 'Non-official Area::::Неофициальная Площадь::::مساحة غير رسمية::::Superficie Non-officielle::::Area NO oficial::::::::Área Não Oficial::::::::非正式面积', '', 'c');
INSERT INTO area_type (code, display_value, description, status) VALUES ('officialArea', 'Official Area::::Официальная Площадь::::المساحة الرسمية::::Superficie Officielle::::Area Oficial::::::::Área Oficial::::::::登记面积', '', 'c');
INSERT INTO area_type (code, display_value, description, status) VALUES ('surveyedArea', 'Surveyed Area::::Площадь по Съемке::::المساحة الممسوحة::::Superficie Levée::::Area Topografiada::::::::Área Vistoriada::::::::已调查面积', '', 'c');


ALTER TABLE area_type ENABLE TRIGGER ALL;

--
-- Data for Name: building_unit_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE building_unit_type DISABLE TRIGGER ALL;

INSERT INTO building_unit_type (code, display_value, description, status) VALUES ('individual', 'Individual::::Индивидуальное::::فردي::::Individuel::::Individual::::::::Individual::::::::个人', '', 'c');
INSERT INTO building_unit_type (code, display_value, description, status) VALUES ('shared', 'Shared::::Общая::::مشتركة::::Partagé::::Compartido::::::::Compartilhado::::::::共享', '', 'c');


ALTER TABLE building_unit_type ENABLE TRIGGER ALL;

--
-- Data for Name: cadastre_object_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE cadastre_object_type DISABLE TRIGGER ALL;

INSERT INTO cadastre_object_type (code, display_value, description, status, in_topology) VALUES ('parcel', 'Parcel::::Участок::::قطعة::::Parcelle::::Parcela::::::::Parcela::::::::宗地', '', 'c', true);
INSERT INTO cadastre_object_type (code, display_value, description, status, in_topology) VALUES ('buildingUnit', 'Building Unit::::Единица Здания::::وحدة بناية::::Bâtiment::::Unidad de Construcción::::::::Unidade de Construção::::::::建筑单元', '', 'c', false);
INSERT INTO cadastre_object_type (code, display_value, description, status, in_topology) VALUES ('utilityNetwork', 'Utility Network::::Инфраструктурная Сеть::::شبكة خدمات::::Réseaux de services publics::::Red de Servicio Público::::::::Rede de Utilidade::::::::实用网络', '', 'c', false);


ALTER TABLE cadastre_object_type ENABLE TRIGGER ALL;

--
-- Data for Name: dimension_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE dimension_type DISABLE TRIGGER ALL;

INSERT INTO dimension_type (code, display_value, description, status) VALUES ('0D', '0D::::0D::::0D::::0D::::0D::::::::0D::::::::0维', '', 'c');
INSERT INTO dimension_type (code, display_value, description, status) VALUES ('1D', '1D::::1D::::1D::::1D::::1D::::::::1D::::::::1维', '', 'c');
INSERT INTO dimension_type (code, display_value, description, status) VALUES ('2D', '2D::::2D::::2D::::2D::::2D::::::::2D::::::::2维', '', 'c');
INSERT INTO dimension_type (code, display_value, description, status) VALUES ('3D', '3D::::3D::::3D::::3D::::3D::::::::3D::::::::3维', '', 'c');
INSERT INTO dimension_type (code, display_value, description, status) VALUES ('liminal', 'Liminal::::Liminal::::حدي::::Liminal::::Liminal::::::::Liminar::::::::阈限', '', 'x');


ALTER TABLE dimension_type ENABLE TRIGGER ALL;

--
-- Data for Name: hierarchy_level; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE hierarchy_level DISABLE TRIGGER ALL;

INSERT INTO hierarchy_level (code, display_value, description, status) VALUES ('0', 'Hierarchy 0::::Hierarchy 0::::تسلسل هرمي 0::::Hiérarchie 0::::Jerarquia 0::::::::Hierarquia 0::::::::第零层', '', 'c');
INSERT INTO hierarchy_level (code, display_value, description, status) VALUES ('1', 'Hierarchy 1::::Hierarchy 1::::تسلسل هرمي 1::::Hiérarchie 1::::Jerarquia 1::::::::Hierarquia 1::::::::第一层', '', 'c');
INSERT INTO hierarchy_level (code, display_value, description, status) VALUES ('2', 'Hierarchy 2::::Hierarchy 2::::تسلسل هرمي 2::::Hiérarchie 2::::Jerarquia 2::::::::Hierarquia 2::::::::第二层', '', 'c');
INSERT INTO hierarchy_level (code, display_value, description, status) VALUES ('3', 'Hierarchy 3::::Hierarchy 3::::تسلسل هرمي 3::::Hiérarchie 3::::Jerarquia 3::::::::Hierarquia 3::::::::第三层', '', 'c');
INSERT INTO hierarchy_level (code, display_value, description, status) VALUES ('4', 'Hierarchy 4::::Hierarchy 4::::تسلسل هرمي 4::::Hiérarchie 4::::Jerarquia 4::::::::Hierarquia 4::::::::第四层', '', 'c');


ALTER TABLE hierarchy_level ENABLE TRIGGER ALL;

--
-- Data for Name: land_use_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE land_use_type DISABLE TRIGGER ALL;

INSERT INTO land_use_type (code, display_value, description, status) VALUES ('commercial', 'Commercial::::Коммерческая::::تجاري::::Commercial::::Comercial::::Tregtare::::Comercial::::តំបន់ពាណិជ្ជកម្ម::::商业的::::စီးပွားရေး', '', 'c');
INSERT INTO land_use_type (code, display_value, description, status) VALUES ('residential', 'Residential::::Жилая::::سكني::::Résidentiel::::Residencial::::Banimi::::Residencial::::តំបន់លំនៅដ្ឋាន::::居住::::လူနေရပ်ကွက်', '', 'c');
INSERT INTO land_use_type (code, display_value, description, status) VALUES ('industrial', 'Industrial::::Производственная::::صناعي::::Industriel::::Industrial::::Industriale::::Industrial::::តំបន់ឧស្សាហ៍កម្ម::::工业的::::စက်မှုလုပ်ငန်း', '', 'c');
INSERT INTO land_use_type (code, display_value, description, status) VALUES ('agricultural', 'Agricultural::::Сельскохозяйственная::::زراعي::::Agricole::::Agricultura::::Bujqësore::::Agrícola::::តំបន់កសិកម្ម::::农业的::::စိုက်ပျိုးရေး', '', 'c');
INSERT INTO land_use_type (code, display_value, description, status) VALUES ('forestry', 'Forestry::::::::::::::::::::::::::::::::::::သစ်တောစိုက်ခင်း', '', 'c');


ALTER TABLE land_use_type ENABLE TRIGGER ALL;

--
-- Data for Name: level_content_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE level_content_type DISABLE TRIGGER ALL;

INSERT INTO level_content_type (code, display_value, description, status) VALUES ('building', 'Building::::Здание::::بناية::::Bâtiment::::Construcción::::::::Construção::::::::建筑', '', 'x');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('customary', 'Customary::::Традиционный::::عرفي::::Coutumier::::Habitual::::::::Consuetudinário::::::::习惯法', '', 'x');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('informal', 'Informal::::Неформальный::::غير رسمي::::Informel::::Informal::::::::Informal::::::::非正式', '', 'x');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('mixed', 'Mixed::::Смешанный::::مختلط::::Mixte::::Mixto::::::::Misto::::::::混合的', '', 'x');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('network', 'Network::::Сеть::::شبكة::::Réseau::::Red ::::::::Rede::::::::网络', '', 'x');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('primaryRight', 'Primary Right::::Первичное право::::حق اساسي::::Droit Principal::::Derechos Primarios::::::::Direito Fundamental::::::::基本权利', '', 'c');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('responsibility', 'Responsibility::::Ответственность::::المسؤوليات::::Responsibilité::::Responsabilidad ::::::::Responsabilidade::::::::责任', '', 'x');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('restriction', 'Restriction::::Ограничение::::القيود::::Restriction::::Restricción::::::::Restrição::::::::限制', '', 'c');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('geographicLocator', 'Geographic Locators::::Географические Точки::::تحديد المواقع الجغرافية::::Repères Géographiques::::Localizadores Geográficos::::::::Localizadores Geográficos::::::::地理定位', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::::::扩展为 LADM', 'c');


ALTER TABLE level_content_type ENABLE TRIGGER ALL;

--
-- Data for Name: register_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE register_type DISABLE TRIGGER ALL;

INSERT INTO register_type (code, display_value, description, status) VALUES ('all', 'All::::Все::::الجميع::::Tout::::Todos::::::::Todo::::::::所有', '', 'c');
INSERT INTO register_type (code, display_value, description, status) VALUES ('forest', 'Forest::::Лес::::الغابات::::Forêt::::Forestal::::::::Floresta::::::::森林', '', 'c');
INSERT INTO register_type (code, display_value, description, status) VALUES ('mining', 'Mining::::Добыча::::التعدين::::Mine::::Minería::::::::Mineração::::::::采矿', '', 'c');
INSERT INTO register_type (code, display_value, description, status) VALUES ('publicSpace', 'Public Space::::Общественная территория::::اماكن عامة::::Espace Publique::::Espacio Público::::::::Espaço Público::::::::公共空间', '', 'c');
INSERT INTO register_type (code, display_value, description, status) VALUES ('rural', 'Rural::::Сельский::::ريفي::::Rural::::Rural::::::::Rural::::::::农村', '', 'c');
INSERT INTO register_type (code, display_value, description, status) VALUES ('urban', 'Urban::::Городской::::حضري::::Urbain::::Urbano::::::::Urbano::::::::城市', '', 'c');


ALTER TABLE register_type ENABLE TRIGGER ALL;

--
-- Data for Name: structure_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE structure_type DISABLE TRIGGER ALL;

INSERT INTO structure_type (code, display_value, description, status) VALUES ('point', 'Point::::Точка::::نقطة::::Point::::Punto::::::::Ponto::::::::点', '', 'c');
INSERT INTO structure_type (code, display_value, description, status) VALUES ('polygon', 'Polygon::::Полигон::::مضلع::::Polygone::::Poligono::::::::Polígono::::::::多边形', '', 'c');
INSERT INTO structure_type (code, display_value, description, status) VALUES ('sketch', 'Sketch::::Схема::::رسم تخطيطي::::Croquis::::Bosquejo::::::::Esboço::::::::草图', '', 'c');
INSERT INTO structure_type (code, display_value, description, status) VALUES ('text', 'Text::::Текс::::نص::::Texte::::Texto::::::::Texto::::::::文本', '', 'c');
INSERT INTO structure_type (code, display_value, description, status) VALUES ('topological', 'Topological::::Топологический::::طبوغرافي::::Topologique::::Topologica::::::::Topológica::::::::地志学的', '', 'c');
INSERT INTO structure_type (code, display_value, description, status) VALUES ('unStructuredLine', 'UnstructuredLine::::Неструктурированная линия::::خط غير منتظم::::Ligne::::lineal no estructurada::::::::Linha não estruturada::::::::自由线', '', 'c');


ALTER TABLE structure_type ENABLE TRIGGER ALL;

--
-- Data for Name: surface_relation_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE surface_relation_type DISABLE TRIGGER ALL;

INSERT INTO surface_relation_type (code, display_value, description, status) VALUES ('above', 'Above::::Над::::فوق::::Au-dessus::::Arriba::::::::Acima::::::::以上', '', 'x');
INSERT INTO surface_relation_type (code, display_value, description, status) VALUES ('below', 'Below::::Под::::أسفل::::En-dessous::::Abajo::::::::Abaixo::::::::以下', '', 'x');
INSERT INTO surface_relation_type (code, display_value, description, status) VALUES ('mixed', 'Mixed::::Смешанный::::مختلط::::Mixte::::Mixto::::::::Misto::::::::混合的', '', 'x');
INSERT INTO surface_relation_type (code, display_value, description, status) VALUES ('onSurface', 'On Surface::::На Поверхности::::فوق السطح::::En Surface::::En la superficie::::::::Na Superfície::::::::表面上', '', 'c');


ALTER TABLE surface_relation_type ENABLE TRIGGER ALL;

--
-- Data for Name: utility_network_status_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE utility_network_status_type DISABLE TRIGGER ALL;

INSERT INTO utility_network_status_type (code, display_value, description, status) VALUES ('inUse', 'In Use::::Используется::::قيد الاستخدام::::Utilisé::::En Uso::::::::Em Uso::::::::在使用中', '', 'c');
INSERT INTO utility_network_status_type (code, display_value, description, status) VALUES ('outOfUse', 'Out of Use::::Не используется::::خارج الخدمة::::Hors d''usage::::Fuera de uso::::::::Fora de Uso::::::::不在用', '', 'c');
INSERT INTO utility_network_status_type (code, display_value, description, status) VALUES ('planned', 'Planned::::Запланировано::::مخطط::::Planifié::::Planificado::::::::Planejado::::::::被规划', '', 'c');


ALTER TABLE utility_network_status_type ENABLE TRIGGER ALL;

--
-- Data for Name: utility_network_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE utility_network_type DISABLE TRIGGER ALL;

INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('chemical', 'Chemicals::::Химическая::::مواد كيماوية::::Produits chimiques::::Quimico::::::::Materiais químicos::::::::化学品', '', 'c');
INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('electricity', 'Electricity::::Электричество::::كهرباء::::Electricité::::Electricidad::::::::Eletricidade::::::::电', '', 'c');
INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('gas', 'Gas::::Газ::::غاز::::Gaz::::Gas::::::::Gás::::::::气', '', 'c');
INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('heating', 'Heating::::Отопление::::حرارة::::Chauffage::::Calor::::::::Aquecedor::::::::取暖', '', 'c');
INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('oil', 'Oil::::Нефть::::بترول::::Pétrol::::Combustible::::::::Óleo::::::::油', '', 'c');
INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('telecommunication', 'Telecommunication::::Телекоммуникации::::اتصالات::::Télécommunication::::Telecomunicaciones::::::::Telecomunicação::::::::通信', '', 'c');
INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('water', 'Water::::Вода::::ماء::::Eau::::Agua::::::::Água::::::::水', '', 'c');


ALTER TABLE utility_network_type ENABLE TRIGGER ALL;

SET search_path = opentenure, pg_catalog;

--
-- Data for Name: administrative_boundary_status; Type: TABLE DATA; Schema: opentenure; Owner: postgres
--

ALTER TABLE administrative_boundary_status DISABLE TRIGGER ALL;

INSERT INTO administrative_boundary_status (code, display_value, status, description) VALUES ('approved', 'Approved', 'c', 'Approved');
INSERT INTO administrative_boundary_status (code, display_value, status, description) VALUES ('pending', 'Pending', 'c', 'Pending');


ALTER TABLE administrative_boundary_status ENABLE TRIGGER ALL;

--
-- Data for Name: administrative_boundary_type; Type: TABLE DATA; Schema: opentenure; Owner: postgres
--

ALTER TABLE administrative_boundary_type DISABLE TRIGGER ALL;

INSERT INTO administrative_boundary_type (code, display_value, status, level, description) VALUES ('district', 'District', 'c', 1, 'District');
INSERT INTO administrative_boundary_type (code, display_value, status, level, description) VALUES ('village', 'Village::::::::::::::::::::::::::::::::::::', 'c', 2, 'Village::::::::::::::::::::::::::::::::::::');


ALTER TABLE administrative_boundary_type ENABLE TRIGGER ALL;

--
-- Data for Name: claim_status; Type: TABLE DATA; Schema: opentenure; Owner: postgres
--

ALTER TABLE claim_status DISABLE TRIGGER ALL;

INSERT INTO claim_status (code, display_value, status, description) VALUES ('withdrawn', 'Withdrawn::::::::سحبت::::Renoncé::::Retirado::::I tërhequr::::Retirado::::ដកចេញ::::撤回::::ရုပ်သိမ်းခြင်း', 'c', 'Status for withdrawn claims::::::::حالة الادعاءات التي تم سحبها::::Statut pour les déclarations renoncées::::Estado de alegaciones retiradas::::Statusi për pretendimet e tërhequra::::Estado dos requerimentos retirados::::ស្ថានភាពសម្រាប់ការចកចេញនៃបណ្តឹងទាមទា::::撤回请求状态::::ရုပ်သိမ်းထားခြင်း အခြေအနေရှိသည့် အဆိုပြုမှုများ');
INSERT INTO claim_status (code, display_value, status, description) VALUES ('rejected', 'Rejected::::::::رفضت::::Rejetée::::Rechazado::::I refuzuar::::Excluido::::បានច្រានចោល::::被拒绝::::ပယ်ချခြင်း', 'c', 'Status for rejected claims::::::::حالة الادعاءات المرفوضة::::Statut pour les déclarations rejetées::::Estatus de las peticiones rechazadas::::Statusi për pretendimet e refuzuara::::Estado dos requerimentos excluidos::::ស្ថានភាពសម្រាប់ការច្រានចោលបណ្តឹងទាមទា::::拒绝请求状态::::ပယ်ချထားသော အခြေအနေရှိသည့် အဆိုပြုမှုများ');
INSERT INTO claim_status (code, display_value, status, description) VALUES ('created', 'Created::::::::أنشئت::::Créée::::Creado::::I krijuar::::Criado::::បានបង្កើតហើយ::::已创建::::စတင်ပြုလုပ်ခြင်း', 'i', 'Statut pour les déclarations créées::::::::حالة الادعاءات التي تم انشاؤها::::::::Estado de las declaraciones creadas::::Statusi për pretendimet e krijuara::::Estado dos requerimentos criados::::Statut pour les déclarations créées::::Statut pour les déclarations créées::::စတင်ပြုလုပ်သည့် အခြေအနေရှိ အဆိုပြုမှုများ');
INSERT INTO claim_status (code, display_value, status, description) VALUES ('moderated', 'Moderated::::::::عدلت::::Modéré::::Moderado::::I moderuar::::Moderado::::មធ្យម::::已调整::::ညှိနှိုင်းပြင်ဆင်ထားခြင်း', 'i', 'Statut pour les déclarations modérées::::::::حالة الأدعاءات التي تم تعديلها::::::::Estado de las declaraciones moderadas::::Statusi për pretendimet e moderuara::::Estado dos requerimentos moderados::::Statut pour les déclarations modérées::::Statut pour les déclarations modérées::::ညှိနှိုင်းပြင်ဆင်သော အခြေအနေရှိသည့် အဆိုပြုမှုများ');
INSERT INTO claim_status (code, display_value, status, description) VALUES ('reviewed', 'Reviewed::::::::روجعت::::Revue::::Revisado::::I rishikuar::::Revisado::::បានត្រួតពិនិត្យឡើងវិញ::::已审查::::ပြန်လည်သုံးသပ်ခြင်း', 'c', 'Status for reviewed claims::::::::حالة الادعاءات التي تم مراجعتها::::Statut pour les déclarations revues::::Estatus de reclamaciones revisadas::::Statusi për pretendimet e rishikuara::::Estado dos requerimentos revisados::::ស្ថានភាពសម្រាប់ការត្រួតពិនិត្យឡើងវិញនៃបណ្តឹងទាមទា::::复查请求状态::::အဆိုပြုမှုကို ပြန်လည်သုံးသပ်ခြင်း အဆင့်');
INSERT INTO claim_status (code, display_value, status, description) VALUES ('unmoderated', 'Un-moderated::::::::لم تعدل::::Non modéré::::No moderado::::I pa moderuar::::Não moderado::::មិនទំហំមធ្យម::::未调整::::ညှိနှိုင်းပြင်ဆင်မှု မလုပ်ရသေးခြင်း', 'i', 'Statut pour les déclarations non modérées::::::::حالة الأدعاءات التي لم يتم تعديلها::::::::Estado de las declaraciones no moderados::::Statusi për pretendimet e pa moderuara::::Estado dos requerimentos não moderados::::Statut pour les déclarations non modérées::::Statut pour les déclarations non modérées::::ညှိနှိုင်းပြင်ဆင်မှု မလုပ်ရသေးသည့် အဆိုပြုမှုများ');
INSERT INTO claim_status (code, display_value, status, description) VALUES ('issued', 'Issued', 'c', 'Final status for the claim, indicating it is issued to the owner');
INSERT INTO claim_status (code, display_value, status, description) VALUES ('historic', 'Historic', 'c', 'Historic status, indicating that parcel was split or merged.');


ALTER TABLE claim_status ENABLE TRIGGER ALL;

--
-- Data for Name: field_constraint_type; Type: TABLE DATA; Schema: opentenure; Owner: postgres
--

ALTER TABLE field_constraint_type DISABLE TRIGGER ALL;

INSERT INTO field_constraint_type (code, display_value, status, description) VALUES ('OPTION', 'OPTION::::::::خيار::::OPTION::::OPCION::::OPTION::::OPÇÃO::::ជម្រើស::::选择::::OPTION', 'c', 'OPTION::::::::خيار::::::::OPCION::::Mundësi::::OPÇÃO::::ជម្រើស​::::选择::::OPTION');
INSERT INTO field_constraint_type (code, display_value, status, description) VALUES ('DATETIME', 'DATETIME::::::::تاريخ_وقت::::DATE ET HEURE::::FECHAHORA::::DATAORA::::DATA E HORA::::ពេលវេលាការបរិច្ឆេទ::::日期与时间::::DATETIME', 'c', 'DATE ET HEURE::::::::التاريخ والوقت::::::::FECHAHORA::::DATA dhe ORA::::DATA E HORA::::ពេលវេលាការបរិច្ឆេទ::::日期与时间::::DATE ET HEURE');
INSERT INTO field_constraint_type (code, display_value, status, description) VALUES ('INTEGER', 'INTEGER::::::::رقم_صحيح::::ENTIER::::ENTERO::::INTEGER::::INTEIRO::::លេខគត::::整数::::INTEGER', 'c', 'ENTIER::::::::رقم صحيح::::::::ENTERO::::Numër i plotë::::INTEIRO::::ទាំងស្រុង::::全部::::ENTIER');
INSERT INTO field_constraint_type (code, display_value, status, description) VALUES ('NOT_NULL', 'NOT_NULL::::::::غير_فارغ::::NON NUL::::NO NULO::::NOT_NULL::::NÃO_NULO::::NOT_NULL::::不能为空::::NOT_NULL', 'c', 'NON NUL::::::::حقل غير فارغ::::::::NO NULO::::Jo bosh::::NÃO NULO::::NON NUL::::非空::::NON NUL');
INSERT INTO field_constraint_type (code, display_value, status, description) VALUES ('INTEGER_RANGE', 'INTEGER_RANGE::::::::مدى_الرقم_الصحيح::::PLAGE ENTIER::::RANGO ENTERO::::INTEGER_RANGE::::ALCANCE_INTEIRO::::លេខគត_រាយពី::::整数 区间::::INTEGER_RANGE', 'c', 'PLAGE ENTIER::::::::مدى الرقم الصحيح::::::::RANGO ENTERO::::Varg i plotë::::ALCANCE INTEIRO::::តំបន់ទាំងមូល::::谱斑块::::PLAGE ENTIER');
INSERT INTO field_constraint_type (code, display_value, status, description) VALUES ('DOUBLE_RANGE', 'DOUBLE_RANGE::::::::مدى_العدد_العشري::::PLAGE DOUBLE::::DOBLE RANGO::::DOUBLE_RANGE::::ALCANCE_DUPLO::::ទ្វេរដង_រាយពី::::双_量程::::DOUBLE_RANGE', 'c', 'PLAGE DOUBLE::::::::مدى العدد العشري::::::::DOBLE RANGO::::Varg i dyfishtë::::ALCANCE DUPLO::::ទ្វេរដងទេ្វរដង::::双谱斑::::PLAGE DOUBLE');
INSERT INTO field_constraint_type (code, display_value, status, description) VALUES ('REGEXP', 'REGEXP::::::::تعبير_مركب::::REGEXP::::REGEXP::::REGEXP::::REGEXP::::REGEXP::::正则表达式::::REGEXP', 'c', 'REGEXP::::::::تعبير مركب::::::::REGEXP::::REGEXP::::REGEXP::::REGEXP::::正则表达式::::REGEXP');
INSERT INTO field_constraint_type (code, display_value, status, description) VALUES ('LENGTH', 'LENGTH::::::::طول::::LONGUEUR::::LONGITUD::::LENGTH::::COMPRIMENTO::::រយះពេល::::长度::::LENGTH', 'c', 'LONGUEUR::::::::طول الحقل::::::::LONGITUD::::Gjatësi::::COMPRIMENTO::::LONGUEUR::::乏味的部分::::LONGUEUR');


ALTER TABLE field_constraint_type ENABLE TRIGGER ALL;

--
-- Data for Name: field_type; Type: TABLE DATA; Schema: opentenure; Owner: postgres
--

ALTER TABLE field_type DISABLE TRIGGER ALL;

INSERT INTO field_type (code, display_value, status, description) VALUES ('BOOL', 'BOOL::::::::منطقي::::BOOL::::BOOL::::BOOL::::BOOL::::BOOL::::布尔数据类型::::BOOL', 'c', 'BOOL::::::::منطقي::::::::BOOL::::True/False::::BOOL::::BOOL::::布尔数据类型::::BOOL');
INSERT INTO field_type (code, display_value, status, description) VALUES ('TEXT', 'TEXT::::::::نص::::TEXTE::::TEXTO::::TEXT::::TEXTO::::អត្ដបទ::::文本::::TEXT', 'c', 'TEXTE::::::::نص::::::::TEXTO::::Tekst::::TEXTO::::អត្ដបទ::::文件::::TEXTE');
INSERT INTO field_type (code, display_value, status, description) VALUES ('INTEGER', 'INTEGER::::::::رقم صحيح::::ENTIER::::ENTERO::::INTEGER::::INTEIRO::::លេខគត::::整数::::INTEGER', 'c', 'ENTIER::::::::رقم صحيح::::::::ENTERO::::Numër i plotë::::INTEIRO::::ទាំងមូល::::全部::::ENTIER');
INSERT INTO field_type (code, display_value, status, description) VALUES ('DECIMAL', 'DECIMAL::::::::رقم عشري::::DECIMAL::::DECIMAL::::DECIMAL::::DECIMAL::::លេខទសភាគ::::十进位制::::DECIMAL', 'c', 'DECIMAL::::::::رقم عشري::::::::DECIMAL::::Numër dhjetor::::DECIMAL::::លេខទសភាគ::::十进位制::::DECIMAL');
INSERT INTO field_type (code, display_value, status, description) VALUES ('DATE', 'DATE::::::::التاريخ::::DATE::::FECHA::::DATE::::DATA::::កាលបរិច្ឆេទ::::日期::::DATE', 'c', 'DATE::::::::التاريخ::::::::FECHA::::DATA::::DATA::::កាលបរិច្ឆេទ::::日期::::DATE');


ALTER TABLE field_type ENABLE TRIGGER ALL;

--
-- Data for Name: field_value_type; Type: TABLE DATA; Schema: opentenure; Owner: postgres
--

ALTER TABLE field_value_type DISABLE TRIGGER ALL;

INSERT INTO field_value_type (code, display_value, status, description) VALUES ('TEXT', 'TEXT::::::::نص::::TEXTE::::TEXTO::::TEXT::::TEXTO::::អត្ដបទ::::文本::::TEXT', 'c', 'TEXTE::::::::نص::::::::TEXTO::::Tekst::::TEXTO::::អត្ដបទ::::文件::::TEXTE');
INSERT INTO field_value_type (code, display_value, status, description) VALUES ('NUMBER', 'NUMBER::::::::عدد::::NUMERO::::NUMERO::::NUMBER::::NÚMERO::::លេខ::::数字::::NUMBER', 'c', 'NUMERO::::::::عدد::::::::NUMERO::::Numër::::NÚMERO::::លេខ::::头号::::NUMERO');
INSERT INTO field_value_type (code, display_value, status, description) VALUES ('BOOL', 'BOOL::::::::منطقي::::BOOL::::BOOL::::BOOL::::BOOL::::BOOL::::布尔数据类型::::BOOL', 'c', 'BOOL::::::::منطقي::::::::BOOL::::True/False::::BOOL::::BOOL::::布尔数据类型::::BOOL');


ALTER TABLE field_value_type ENABLE TRIGGER ALL;

--
-- Data for Name: rejection_reason; Type: TABLE DATA; Schema: opentenure; Owner: postgres
--

ALTER TABLE rejection_reason DISABLE TRIGGER ALL;

INSERT INTO rejection_reason (code, display_value, status, description) VALUES ('inconclusiveEvidence', 'Documentary evidence provided is insufficient to substantiate the claim to the tenure rights::::::::::::::::::::::::::::::::::::မြေယာရပိုင်ခွင့် အဆိုပြုမှုကို အခိုင်အမာ အထောက်အပံ့ ပေးနိုင်သော စာရွက်စာတမ်း အထောက်အထား အလုံအလောက် မပြနိုင်ခြင်း', 'c', 'Inconclusive evidence::::::::::::::::::::::::::::::::::::မပြည့်စုံသော သက်သေအထောက်အထားများ');
INSERT INTO rejection_reason (code, display_value, status, description) VALUES ('others', 'Other reasons::::::::::::::::::::::::::::::::::::အခြား အကြောင်းပြချက်များ', 'c', 'Other reasons::::::::::::::::::::::::::::::::::::အခြား အကြောင်းပြချက်များ');
INSERT INTO rejection_reason (code, display_value, status, description) VALUES ('validityOfEvidence', 'There are significant doubts concerning the validity of the documentary evidence provided in support of the claim to tenure rights::::::::::::::::::::::::::::::::::::မြေယာအဆိုပြုမှုကို အထောက်အပံ့ပြုသော အထောက်အထားများ၏ ခိုင်မာမှုနှင့် စပ်လျဉ်း၍ သံသယဖြစ်ဖွယ် အချက်များ အများအပြား ပါဝင်နေသည်။', 'c', 'Invalid evidence::::::::::::::::::::::::::::::::::::ခိုင်လုံမှုမရှိသော သက်သေအထောက်အထား ');
INSERT INTO rejection_reason (code, display_value, status, description) VALUES ('alternativeProcess', 'An alternative process must be completed before the claim to these tenure rights can be considered::::::::::::::::::::::::::::::::::::လုပ်ပိုင်ခွင့် အခွင့်အရေးများ အဆိုပြုမှု အပေါ် မစဉ်းစားခင် သမားရိုးကျ မဟုတ်သော ဖြစ်စဉ်တစ်ခု ရှိခဲ့သလား', 'c', 'Alternative process::::::::::::::::::::::::::::::::::::သမားရိုးကျ မဟုတ်သော ဖြစ်စဉ်များ ');
INSERT INTO rejection_reason (code, display_value, status, description) VALUES ('boundaryUnclear', 'The definition of the boundaries (of the claimed tenure rights) is missing from the claim, unclear, incorrectly defined or subject to an unresolved boundary dispute::::::::::::::::::::::::::::::::::::မြေအဆိုပြုမှုတွင် (မြေယာပိုင်ဆိုင်ခွင့် အရ) နယ်နမိတ် သတ်မှတ်သည့် အချက်အလက်များ မပြည့်စုံခြင်း၊ မှန်ကန်ရှင်းလင်းမှု မရှိခြင်း၊ ဖြေရှင်းရ ခက်သော နယ်နမိတ် အငြင်းပွားမှုမျိုး ရှိနေခြင်း။', 'c', 'Boundary unclear::::::::::::::::::::::::::::::::::::နယ်နမိတ် မရှင်းလင်းခြင်း');
INSERT INTO rejection_reason (code, display_value, status, description) VALUES ('missingEvidence', 'Documentary evidence in support of the claimed tenure rights is missing::::::::::::::::::::::::::::::::::::မြေယာရပိုင်ခွင့် အဆိုပြုမှုကို အထောက်အပံ့ ပေးနိုင်သော စာရွက်စာတမ်း အထောက်အထားများ မပြည့်စုံခြင်း', 'c', 'Missing evidence::::::::::::::::::::::::::::::::::::သက်သေအထောက်အထား မပြည့်စုံခြင်း');


ALTER TABLE rejection_reason ENABLE TRIGGER ALL;

SET search_path = party, pg_catalog;

--
-- Data for Name: communication_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

ALTER TABLE communication_type DISABLE TRIGGER ALL;

INSERT INTO communication_type (code, display_value, status, description) VALUES ('courier', 'Courier::::Курьер::::ساعي بريد::::Coursier::::Mensajero::::::::Transportadora::::::::快件', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO communication_type (code, display_value, status, description) VALUES ('fax', 'Fax::::Факс::::فاكس::::Fax::::Fax::::::::Fax::::::::传真', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO communication_type (code, display_value, status, description) VALUES ('phone', 'Phone::::Телефон::::تلفون::::Téléphone::::Teléfono::::::::Telefone::::::::电话', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO communication_type (code, display_value, status, description) VALUES ('post', 'Post::::Почта::::بريد::::Poste::::Correos::::::::Correio::::::::邮寄', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO communication_type (code, display_value, status, description) VALUES ('eMail', 'e-Mail::::Эл. почта::::بريد الكتروني::::Courriel::::Correo Electrónico::::::::E-mail::::::::电子邮件', 'c', '...::::::::...::::...::::...::::::::...::::::::...');


ALTER TABLE communication_type ENABLE TRIGGER ALL;

--
-- Data for Name: gender_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

ALTER TABLE gender_type DISABLE TRIGGER ALL;

INSERT INTO gender_type (code, display_value, status, description) VALUES ('female', 'Female::::Женский::::أنثى::::Femme::::Femenino::::Femër::::Feminino::::ភេទស្រី::::女性::::ကျား', 'c', '...::::::::...::::...::::...::::...::::...::::...::::...::::...');
INSERT INTO gender_type (code, display_value, status, description) VALUES ('male', 'Male::::Мужской::::ذكر::::Homme::::Masculino::::Mashkull::::Masculino::::ភេទប្រុស::::男性::::မ', 'c', '...::::::::...::::...::::...::::...::::...::::...::::...::::...');
INSERT INTO gender_type (code, display_value, status, description) VALUES ('na', 'Not applicable::::::::غير متاح::::::::No es aplicable::::I pa aplikueshëm::::Não aplicável::::មិនអាចប្រើបាន::::不适用::::မဖြေလိုပါ ', 'x', '...::::::::::::::::::::::::...::::::::...::::...');


ALTER TABLE gender_type ENABLE TRIGGER ALL;

--
-- Data for Name: group_party_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

ALTER TABLE group_party_type DISABLE TRIGGER ALL;

INSERT INTO group_party_type (code, display_value, status, description) VALUES ('tribe', 'Tribe::::Племя::::القبيلة::::Tribu::::Tribu::::::::Tribo::::::::种族', 'x', '');
INSERT INTO group_party_type (code, display_value, status, description) VALUES ('association', 'Association::::Ассоциация::::رابطة::::Association::::Asociación::::::::Associação::::::::协会', 'c', '');
INSERT INTO group_party_type (code, display_value, status, description) VALUES ('family', 'Family::::Семья::::العائلة::::Famille::::Familia::::::::Família::::::::家庭', 'c', '');
INSERT INTO group_party_type (code, display_value, status, description) VALUES ('baunitGroup', 'Basic Administrative Unit Group::::Базовая Административная Группа Единиц::::مجموعة الوحدات الادارية الاساسية::::Groupe d''Unité Administrative de Base::::Grupo de Unidades Administrativas Básicas::::::::Grupo de Unidade Administrativa Básica::::::::基本管理单元组', 'x', '');


ALTER TABLE group_party_type ENABLE TRIGGER ALL;

--
-- Data for Name: id_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

ALTER TABLE id_type DISABLE TRIGGER ALL;

INSERT INTO id_type (code, display_value, status, description) VALUES ('otherPassport', 'Other Passport::::Другой паспорт::::جواز سفر آخر::::Autre passeport::::Otro Pasaporte::::Pasaportë Tjetër::::Outro Passaporte::::លិខិតឆ្លងដែនផ្សេងទៀត::::其他护照::::အခြား နိုင်ငံကူးလက်မှတ် အမှတ်', 'c', 'A passport issued by another country::::Паспорт выданный другой страной::::جواز سفر صادر من بلد آخر::::Un passeport délivré par un autre pays::::Un pasaporte expedido por otro país::::Pasaportë e lëshuar nga një vend tjetër::::Passaporte emitido por outro país::::លិខិតឆ្លងដែនចេញដោយប្រទេសផ្សេងទៀត::::他国签发的护照::::အခြား နိုင်ငံကူးလက်မှတ် ထုတ်ပေးသည့်နိုင်ငံ');
INSERT INTO id_type (code, display_value, status, description) VALUES ('nationalID', 'National ID::::Внутренний ID::::بطاقة التعريف::::Carte Nationale d''Identité::::ID nacional::::ID Kombëtare::::Carteira de Identidade::::អត្តសញ្ជាណសញ្ជាតិ::::国民身份::::အမျိုးသားမှတ်ပုံတင်', 'c', 'The main person ID that exists in the country::::Внутренняя ID карта гражданина внутри страны::::رقم البطاقة الشخصية::::Le document principal d''identité existant dans le pays::::La Identificación principal de la persona que exista en el país::::ID unike e personit brenda vendit::::Principal identificação pessoal que existe no país::::អត្តសញ្ជាណមនុស្សសំខាន់ដែលមាននៅក្នុងប្រទេស::::本国主要人员的身份::::နိုင်ငံတွင်းရှိ အဓိကပုဂ္ဂိုလ်၏ မှတ်ပုံတင်အမှတ်');
INSERT INTO id_type (code, display_value, status, description) VALUES ('nationalPassport', 'National Passport::::Паспорт::::جواز السفر الوطني::::Passeport National::::Pasaporte Nacional::::Pasaporta Kombëtare::::Passaporte Nacional::::លេខលិខិតឆ្លងដែនជាតិ::::国民护照::::နိုင်ငံကူးလက်မှတ် အမှတ်', 'c', 'A passport issued by the country::::Паспорт, выданный в стране::::جواز السفر الصادر من بلد المواطن::::Un passeport délivré par le pays::::Un pasaporte expedido por el país::::Pasaportë e lëshuar nga Autoriteti Kombëtar::::Passaporte emitido pelo país::::លិខិតឆ្លងដែនចេញដោយប្រទេស::::本国签发的护照::::နိုင်ငံကူးလက်မှတ် ထုတ်ပေးသည့်နိုင်ငံ');


ALTER TABLE id_type ENABLE TRIGGER ALL;

--
-- Data for Name: party_role_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

ALTER TABLE party_role_type DISABLE TRIGGER ALL;

INSERT INTO party_role_type (code, display_value, status, description) VALUES ('partner', 'Partner::::::::الشريك::::::::::::::::Parceiro::::::::合作伙伴', 'c', '');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('inheritor', 'Inheritor::::::::الوريث::::::::::::::::Herdeiro::::::::继承人', 'c', '');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('spouse', 'Spouse::::::::الزوج::::::::::::::::Conjugê::::::::配偶', 'c', '');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('notifiablePerson', 'Notifiable Person::::::::الشخص الذي تم إشعاره::::::::::::::::Pessoa de Notificação Obrigatória::::::::申报人', 'c', '');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('bank', 'Bank::::Банк::::البنك::::Banque::::Banco::::::::Banco::::::::银行', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('transferor', 'Transferor (from)::::Цедент::::منقول منه::::Cédant (de)::::Cedente (de)::::::::Cedente (de)::::::::转让人', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::::::扩展为 LADM');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('citizen', 'Citizen::::Гражданин::::المواطن::::Citoyen::::Ciudadano::::::::Cidadão::::::::居民', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('writer', 'Writer::::Оформитель документов::::كاتب::::Auteur::::Escritor::::::::Escritor::::::::作家', 'x', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('conveyor', 'Conveyor::::Перевозчик::::الموصل::::Convoyeur::::Transportador::::::::Transportador::::::::传送带', 'x', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('employee', 'Employee::::Служащий::::الموظف::::Employé::::Empleado::::::::Empregado::::::::雇员', 'x', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('farmer', 'Farmer::::Фермер::::مزارع::::Agriculteur::::Agricultor::::::::Agricultor::::::::农民', 'x', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('landOfficer', 'Land Officer::::Землеустроитель::::موظف دائرة الاراضي::::Officier d''Etat / du Cadastre::::Oficial de Tierras::::::::Escritório de Terra::::::::土地官员', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::::::扩展为 LADM');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('certifiedSurveyor', 'Licenced Surveyor::::Лицензированный Геодезист::::مساح مرخص::::Géomètre Expert / Arpenteur licencié::::Topografo Autorizado::::::::Agrimensor Licenciado::::::::具有资质的测量员', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('lodgingAgent', 'Lodging Agent::::Агент по подачи заявлений::::وكيل تسجيل::::Agent des Dépôts::::Agente de Alojamiento::::::::Agente de Apresentação::::::::房产中介', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::::::扩展为 LADM');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('moneyProvider', 'Money Provider::::Заемщик денег::::ممول::::Fournisseur d''Argent::::Proveedor de Dinero::::::::Financiador::::::::资金提供者', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('notary', 'Notary::::Нотариус::::كاتب عدل::::Notaire::::Notario::::::::Notário::::::::公证人', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('powerOfAttorney', 'Power of Attorney::::Адвокат (поверенный)::::وكيل::::Procuration::::Poder Legal::::::::Procuração::::::::委托书', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::::::扩展为 LADM');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('stateAdministrator', 'Registrar / Approving Surveyor::::Регистратор / Утверждающий Геодезист::::مساح معتمد::::Officier d''Etat / Géomètre Approbateur::::Registrar / Aprobación del Topografo::::::::Registrar / Aprovando Agrimensor::::::::登记员 / 资质调查员', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('surveyor', 'Surveyor::::Геодезист::::مساح::::Géomètre::::Topógrafo::::::::Agrimensor::::::::调查人员', 'x', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('transferee', 'Transferee (to)::::Получатель::::منقول له::::Cessionnaire (à)::::Cesionario (a)::::::::Cessionário (para)::::::::…受让人', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::::::扩展为 LADM');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('applicant', 'Applicant::::Заявитель::::مقدم الطلب::::Demandeur::::Solicitante::::::::Requerente::::::::申请人', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::::::扩展为 LADM');


ALTER TABLE party_role_type ENABLE TRIGGER ALL;

--
-- Data for Name: party_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

ALTER TABLE party_type DISABLE TRIGGER ALL;

INSERT INTO party_type (code, display_value, status, description) VALUES ('baunit', 'Basic Administrative Unit::::Базовая Административная Единица::::الطابو::::Unité Administrative de Base::::Unidad Administrativa Básica::::::::Unidade Administrativa Básica::::::::基本管理单元', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_type (code, display_value, status, description) VALUES ('group', 'Group::::Группа::::مجموعة::::Groupe::::Grupo::::::::Grupo::::::::组', 't', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_type (code, display_value, status, description) VALUES ('naturalPerson', 'Natural Person::::Физическое лицо::::شخص طبيعي::::Personne Physique::::Persona Natural::::::::Pessoa Física::::::::自然人', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO party_type (code, display_value, status, description) VALUES ('nonNaturalPerson', 'Non-natural Person::::Организация::::شخص اعتباري::::Personne Non Physique::::Persona No Natural::::::::Pessoa Jurídica::::::::非自然人', 'c', '...::::::::...::::...::::...::::::::...::::::::...');


ALTER TABLE party_type ENABLE TRIGGER ALL;

SET search_path = source, pg_catalog;

--
-- Data for Name: administrative_source_type; Type: TABLE DATA; Schema: source; Owner: postgres
--

ALTER TABLE administrative_source_type DISABLE TRIGGER ALL;

INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('deed', 'Deed::::Сделка::::صك::::Acte::::Titulo de Propiedad::::::::Escritura::::ឯកសារ::::契约::::အိမ်ခြံမြေ ပိုင်ဆိုင်မှုစာရွက်စာတမ်း ', 'c', '...::::::::...::::...::::...::::::::...::::...::::...::::...', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('pdf', 'Pdf Scanned Document::::Отсканированный Документ PDF::::وثيقة ممسوحة بصيغة (pdf)::::Document Scanné en PDF::::Documento Escaneado en formato PDF::::::::Documento Pdf Digitalizado::::ឯកសារស្កែន Pdf::::Pdf 扫描文件::::Scan ဖတ် သိမ်းထားသော PDF ဖိုင်', 'x', '...::::::::...::::...::::...::::::::...::::...::::...::::...', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('powerOfAttorney', 'Power of Attorney::::Доверенность::::وكالة::::Procuration::::Poder Legal::::::::Procuração::::អំណាចរបស់មេធាវី::::委托书::::ရှေ့ နေကိုယ်စားလှယ် လွှဲစာ', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', true);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('courtOrder', 'Court Order::::Судебное Решение::::أمر محكمة::::Décision de Justice::::Orden judicial::::::::Ordem Judicial::::ដីការតុលសាការ::::法院的决议::::တရားရုံး အမိန့်စာ', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('will', 'Will::::Завещание::::وصية::::Testament::::Testamento::::::::Vontade::::នឹង::::遗赠::::သေတမ်းစာ', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('tiff', 'Tiff Scanned Document::::Отсканированный Документ TIFF::::وثيقة ممسوحة بصيغة (tiff)::::Document Scanné en TIFF::::Documento Escaneado en formato TIF::::::::Documento Tiff Digitalizado::::ឯកសារស្កែនTiff::::Tiff 扫描文件::::Scan ဖတ် သိမ်းထားသော Tiff ဖိုင်', 'x', '...::::::::...::::...::::...::::::::...::::...::::...::::...', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('taxPayment', 'Tax payment::::::::دفع الضريبة::::::::Pago de Impuestos::::::::Pagamento de imposto::::ការបង់ពន្ធ::::完税::::အခွန်ပေးချေမှု', 'c', 'Tax payment::::::::دفع الضريبة::::::::Pago de Impuestos::::::::Pagamento de imposto::::ការបង់ពន្ធ::::完税::::အခွန်ပေးချေမှု', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('proclamation', 'Gazette Notice::::Прокламация::::إعلان::::Proclamation::::Proclamacion::::::::Anúncio::::សេចក្តីប្រកាស::::公告::::တရားဝင် အကြောင်းကြားစာ', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM​::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('relationshipTitle', 'Vital Record::::::::شهادة حيوية::::::::::::::::Registro Vital::::::::重要证书::::မရှိမဖြစ်လိုအပ်သည့် အထောက်အထား မှတ်တမ်း', 'x', '', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('standardDocument', 'Standard Document::::Стандартный Документ::::وثيقة معيارية::::Document Standard::::Documento Estandard ::::::::Documento Padrão::::ឯកសារគោល::::标准文件::::သတ်မှတ် စာရွက်စာတမ်း', 'x', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', true);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('title', 'Certificate of Occupancy::::Право Собственности::::سند ملكية::::Titre::::Titulo::::::::Título::::ចំណងជើង::::产权::::ဝင်ရောက်နေထိုင်ခွင့် လက်မှတ်', 'c', '...::::::::...::::...::::...::::::::...::::...::::...::::...', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('personPhoto', 'Person photo::::::::::::::::::::::::Fotografia pessoal::::::::::::လူပုဂ္ဂိုလ် ဓါတ်ပုံ ', 'c', 'Photo of the person::::::::::::::::::::::::Fotografia da pessoa::::::::::::လူပုဂ္ဂိုလ် ဓါတ်ပုံ', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('lease', 'Lease::::Договор Аренды::::إيجار::::Bail::::Arrendamiento::::::::Arrendamento::::ជួល::::租赁::::အိမ်၊ ခြံမြေ ငှားရမ်းခြင်း', 'c', '...::::::::...::::...::::...::::::::...::::...::::...::::...', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('cadastralSurvey', 'Cadastral Survey::::Кадастровая Съемка::::المسح العقاري::::Relevé Cadastral::::Topografía Catastral::::::::Vistoria do Cadastro::::សិក្សាស្រាជ្រាវលើដីធ្លី::::地籍调查::::မြေတိုင်းအချက်အလက် စစ်တမ်း', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('objection', 'Objection  document::::Документ Обжалования::::وثيقة إعتراض::::Document d''Objection::::Documento Objetado::::::::Documento de objeção::::ការច្រានចោលនូវឯកសារ::::目标文件::::ကန့်ကွက်လွှာများ', 'x', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('restrictionOrder', 'Suppression Order::::::::أمر قيد::::::::::::::::Ordem de Supressão::::::::::::Suppression Order', 'x', '', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('contractForSale', 'Contract for Sale::::Договор о Продаже::::عقد البيع::::Contrat de Vente::::Contrato de Venta::::::::Contrato de Venda::::កិច្ចព្រមព្រៀងសម្រាប់លក់::::售卖合同::::အရောင်းအဝယ်စာချုပ် ', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('agriLease', 'Agricultural Lease::::Сельскохозяйственная Аренда::::تأجير زراعي::::Bail Agricole::::Arrendamiento Agrícola::::::::Arrendamento Agrícola::::ជួលដីកសិកម្ម::::农业租赁::::စိုက်ပျိုးရေးလုပ်ငန်း အတွက် ငှားရမ်းလုပ်ကိုင်ခြင်း', 'x', '...::::::::...::::...::::...::::::::...::::...::::...::::...', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('utilityBill', 'Utility bill::::::::فاتورة إستخدام::::::::Factura de Servicios Públicos::::::::Taxa de infraestrutura::::វិក័យបត្រទឹកភ្លើង::::物业账单::::ရေ၊ မီး၊ အခွန်အခ ပေးဆောင်သည့် ဖြတ်ပိုင်း', 'x', 'Utility bill::::::::فاتورة إشتراك::::::::Factura de Servicios Públicos::::::::Taxa de infraestrutura::::វិក័យបត្រទឹកភ្លើង​::::物业账单::::ရေ၊ မီး၊ အခွန်အခ ပေးဆောင်သည့် ဖြတ်ပိုင်း', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('agriConsent', 'Agricultural Consent::::Сельскохозяйственное Разрешение::::إتفاق زراعي::::Consentement Agricole::::Consentimiento Agrícola::::::::Permissão Agrícola::::កិច្ចយល់ព្រមផ្នែកកសិកម្ម::::农业准许::::စိုက်ပျိုးရေးဆိုင်ရာ သဘောတူညီချက်', 'x', '...::::::::...::::...::::...::::::::...::::...::::...::::...', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('agreement', 'Agreement::::Соглашение::::إتفاقية::::Accord::::Acuerdo::::::::Acordo::::កិច្ចព្រមព្រៀង​::::协议书::::သဘောတူညီချက်', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('agriNotaryStatement', 'Agricultural Notary Statement::::Нотариальное Сельскохозяйственное Заявление::::بيان زراعي من كاتب العدل::::Déclaration Agricole Notariée::::Declaración Notario Agrícola::::::::Declaração de Notário Agrícola::::សេចក្តីថ្លែងការរបស់មេធាវីសាធារណៈស្តីពីកសិកម្ម::::农业公正申明::::စိုက်ပျိုးရေးလုပ်ငန်း အချက်အလက် မှန်ကန်ကြောင်း ထောက်ခံချက်', 'x', '...::::::::...::::...::::...::::::::...::::...::::...::::...', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('cadastralMap', 'Layout Map::::Кадастровая Карта::::خارطة المسح العقاري::::Plan Cadastral::::Mapa Catastral::::::::Mapa Cadastral::::ផែនទីដីធ្លីដីធ្លី::::地籍图::::မြေပုံတွင် ပုံစံချခြင်း', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('caveat', 'Caveat::::Протест::::تحذير::::Caveat::::Advertencia::::::::Embargo::::ការប្រមាន::::附加说明::::ကြိုတင်အသိပေးခြင်း', 'x', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('waiver', 'Waiver::::::::التنازل عن مذكرة قانونية أو أي مطلب آخر::::::::Renuncia a la Advertencia u otro requisito::::::::Renúncio do Embargo ou outra exigência::::::::对附加条件和其他要求的豁免::::စွန့်လွှတ်ကြောင်း တရားဝင်စာ', 'x', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('consentLetter', 'Letter of Consent::::::::::::::::::::::::::::::::::::သဘောတူညီမှုစာ', 'c', '', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('mortgage', 'Mortgage::::Ипотека::::رهن::::Hypothèque::::Hipoteca::::::::Hipoteca::::កាតបញ្ជាំរបស់របប::::抵押::::အပေါင်စာချုပ်', 'c', '...::::::::...::::...::::...::::::::...::::...::::...::::...', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('propertyPhoto', 'Property Photo::::::::::::::::::::::::::::::::::::ပိုင်ဆိုင်မှု အထောက်အထား ဓာတ်ပုံ', 'c', '', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('mortgageRelease', 'Release of Mortgage::::::::::::::::::::::::::::::::::::အပေါင်စာချုပ်အား ရုပ်သိမ်းခြင်း ', 'c', '', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('releasePowerOfAttorn', 'Release of Power of Attorney::::::::::::::::::::::::::::::::::::ရှေ့နေ ကိုယ်စားလှယ်လွှဲစာ ရုပ်သိမ်းခြင်း', 'c', '', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('other', 'Other::::::::::::::::::::::::Outro::::::::::::အခြား', 'c', 'Document that does not fit one of the other named categories.::::::::::::::::::::::::Document that does not fit one of the other named categories.::::::::::::သတ်မှတ် အမျိုးအစားတွင် မပါဝင်သော အထောက်အထား စာရွက်စာတမ်း', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('idVerification', 'Proof of Identity::::::::نموذج تعريف ويتضمن البطاقة الشخصية::::::::Forma de Identificación incluyendo ID Personal::::::::Formulário de Identificação incluindo Identificação Pessoal::::::::包含个人身份证明的表格::::သက်သေခံအချက်အလက် မှန်ကန်ကြောင်းပြနိုင်မှု ', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('surveyDataFile', 'Survey Data File::::::::::::::::::::::::Survey Data File::::::::::::အချက်အလက် စစ်တမ်း ကောက်ခံသည့် ဖိုင်', 'c', 'A CSV data file containing survey coordinate points that can be imported when processing the Change to Cadastre Service.::::::::::::::::::::::::A CSV data file containing survey coordinate points that can be imported when processing the Change to Cadastre Service.::::::::::::မြေတိုင်းဝန်ဆောင်မှု ပြောင်းလဲမှု ပြုလုပ်နေစဉ် CSV ဖိုင်ပါ ထိစပ်အမှတ် coordinate points အချက်အလက်များကိုပါ ထုတ်ယူနိုင်ပါသည်။', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('requisition', 'Requisition Notice::::::::::::::::::::::::Aviso de Requisição::::::::::::ဆင့်ခေါ်စာ', 'c', 'Notice sent by the land registation agency to inform the agent of items that must be addressed with their application before the application can be processed and approved.::::::::::::::::::::::::Notice sent by the land registation agency to inform the agent of items that must be addressed with their application before the application can be processed and approved.::::::::::::လျှောက်လွှာ တခုကို စိစစ် အတည်ပြုခြင်း မပြုလုပ်မီ၊ တင်ပြရန် လိုအပ်သော အချက်များပါသည့် မြေယာမှတ်ပုံတင်ဌာနမှ ပေးပို့သော အကြောင်းကြားစာ ', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('publicNotification', 'Public Notification for Systematic Registration::::Публичное Уведомление о Системной Регистрации::::إعلان عام للتسجيل المنتظم::::Notification Publique pour Enregistrement Systématique::::Notificación Pública de Registro Sistemático::::::::Notificação Pública do Registro Regular::::ការកត់សម្គាល់សាធារណៈសម្រាប់ប្រព័ន្ធចុះបញ្ជី::::系统登记公示::::စနစ်တကျ မှတ်ပုံတင်နိုင်ရန် အများပြည်သူအား အသိပေးခြင်း', 'x', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('officeNote', 'Office Note::::::::::::::::::::::::Nota Oficial::::::::::::ရုံးမှတ်ချက်', 'c', 'Document created by a staff member to note information or points of interest related to a given application::::::::::::::::::::::::Document created by a staff member to note information or points of interest related to a given application::::::::::::ထုတ်ပေးထားသော စာရွက်စာတမ်းနှင့် ပတ်သက်ပြီး ထုတ်ပေးသူမှ မှတ်ချက်ပြု ရေးသားထားချက်၊ အရေးပါသည့် မှတ်ချက် စသည့် အထောက်အထား အချက်အလက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('systematicRegn', 'Systematic Registration Application::::Заявление на Системную Регистрацию::::طلب تسجيل منتظم::::Demande Enregistrement Systématique::::Solicitud de Inscripción Sistemática::::::::Pedido de Registro Regular::::កម្មវិធីចុះបញ្ជីជាប្រព័ន្ធ::::系统登记申请::::စနစ်တကျ မှတ်ပုံတင် လျှောက်လွှာ', 'x', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::ពង្រីកទៅដល់ LADM::::扩展为 LADM::::LADM စံသတ်မှတ်ချက်', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('signed_cert', 'Signed certificate', 'c', '', false);


ALTER TABLE administrative_source_type ENABLE TRIGGER ALL;

--
-- Data for Name: availability_status_type; Type: TABLE DATA; Schema: source; Owner: postgres
--

ALTER TABLE availability_status_type DISABLE TRIGGER ALL;

INSERT INTO availability_status_type (code, display_value, status, description) VALUES ('archiveConverted', 'Converted::::Сконвертированный::::محولة::::Converti::::Convertido::::::::Convertido::::::::转换的', 'c', '');
INSERT INTO availability_status_type (code, display_value, status, description) VALUES ('archiveDestroyed', 'Destroyed::::Уничтоженный::::متلفة::::Détruit::::Destruido::::::::Destruído::::::::已遭破坏', 'x', '');
INSERT INTO availability_status_type (code, display_value, status, description) VALUES ('incomplete', 'Incomplete::::Незаконченный::::غير مكتملة::::Incomplet::::Incompleto::::::::Incompleto::::::::不完善', 'c', '');
INSERT INTO availability_status_type (code, display_value, status, description) VALUES ('archiveUnknown', 'Unknown::::Неизвестный::::غير معروفة::::Inconnu::::Desconocido::::::::Desconhecido::::::::未知', 'c', '');
INSERT INTO availability_status_type (code, display_value, status, description) VALUES ('available', 'Available::::Доступный::::متوفرة::::Disponible::::Available::::::::Disponível::::::::可用', 'c', 'Extension to LADM::::Extension to LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::::::扩展为 LADM');


ALTER TABLE availability_status_type ENABLE TRIGGER ALL;

--
-- Data for Name: presentation_form_type; Type: TABLE DATA; Schema: source; Owner: postgres
--

ALTER TABLE presentation_form_type DISABLE TRIGGER ALL;

INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('modelDigital', 'Digital Model::::Цифровая Модель::::نموذج رقمي::::Modèle Numérique::::Modelo Digital::::::::Modelo Digital::::::::数字模型', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('modelHarcopy', 'Hardcopy Model::::Бумажная Модель::::نموذج ورقي::::Modèle Papier::::Modelo en Papel::::::::Modelo Impresso::::::::硬拷贝模式', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('profileDigital', 'Digital Profile::::Цифровое Дело::::ملف شخصي رقمي::::Profil Numérique::::Perfil Digital::::::::Perfil Digital::::::::数字档案', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('documentDigital', 'Digital Document::::Цифровой Документ::::وثيقة رقمية::::Document Numérique::::Documento Digital::::::::Documento Digital::::::::数字文件', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('profileHardcopy', 'Hardcopy Profile::::Бумажное Дело::::ملف شخصي ورقي::::Profil Papier::::Perfil en Papel::::::::Perfil Impresso::::::::硬拷贝档案', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('documentHardcopy', 'Hardcopy Document::::Бумажный Документ::::وثيقة ورقية::::Document Papier::::Documento en Papel::::::::Documento Impresso::::::::硬拷贝文件', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('imageDigital', 'Digital Image::::Цифровое Изображение::::صورة رقمية::::Image Numérique::::Imagen Digital::::::::Imagem Digital::::::::数字图像', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('tableDigital', 'Digital Table::::Цифровая Таблица::::جدول رقمي::::Table Numérique::::Tabla Digital::::::::Tabela Digital::::::::数字表', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('imageHardcopy', 'Hardcopy Image::::Бумажное Изображение::::صورة ورقية::::Image Papier::::Image en Papel::::::::Imagem Impressa::::::::硬拷贝图像', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('mapDigital', 'Digital Map::::Цифровая Карты::::خارطة رقمية::::Plan Numérique::::Mapa Digital::::::::Mapa Digital::::::::数字地图', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('tableHardcopy', 'Hardcopy Table::::Бумажная Таблица::::جدول ورقي::::Table Papier::::Tabla en Papel::::::::Tabela Impressa::::::::硬拷贝表', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('mapHardcopy', 'Hardcopy Map::::Бумажная Карта::::خارطة ورقية::::Plan Papier::::Mapa en Papel::::::::Mapa Impresso::::::::硬拷贝地图', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('videoDigital', 'Digital Video::::Цифровое Видео::::شريط فيديو رقمي::::Vidéo Numérique::::Video Digital::::::::Vídeo Digital::::::::数字录像', 'c', '');
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('videoHardcopy', 'Hardcopy Video::::Видео на носителе::::شريط فيديو::::Vidéo Analogue::::Video en Físico::::::::Vídeo Impresso::::::::硬拷贝录像', 'c', '');


ALTER TABLE presentation_form_type ENABLE TRIGGER ALL;

--
-- Data for Name: spatial_source_type; Type: TABLE DATA; Schema: source; Owner: postgres
--

ALTER TABLE spatial_source_type DISABLE TRIGGER ALL;

INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('cadastralSurvey', 'Cadastral Survey::::Кадастровая Съемка::::المسح العقاري::::Levé Cadastral::::Topografía Catastral::::::::Vistoria do Cadastro::::::::地籍调查', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::::::扩展为 LADM');
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('surveyData', 'Survey Data (Coordinates)::::Данные Съемки (Координаты)::::احداثيات بيانات المسح::::Données de Levé (Coordonnées)::::Datos Topográficos (Coordinadas)::::::::Vistoria de Dados (Coordenadas)::::::::调查数据 (协调)', 'c', 'Extension to LADM::::Расширение LADM::::ميزة إضافية للنظام::::Extension au LADM::::Extension a LADM::::::::Extensão para LADM::::::::扩展为 LADM');
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('fieldSketch', 'Field Sketch::::Полевая Схема::::رسم الحقل::::Croquis de terrain::::Croquis::::::::Esboço do Campo::::::::作业草图', 'c', '');
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('gnssSurvey', 'GNSS (GPS) Survey::::Съемка GNSS (GPS)::::مسح جي بي اس::::Levé GNSS (GPS)::::Topografía GNSS (GPS)::::::::Levantamento GNSS (GPS)::::::::卫星导航 (GPS) 调查', 'c', '');
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('orthoPhoto', 'Orthophoto::::Аэрофотография::::الصور الجوية المعدلة::::Orthophoto::::Ortofoto::::::::Fotografia aérea::::::::正射影像', 'c', '');
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('relativeMeasurement', 'Relative Measurements::::Относительные Измерения::::القياسات المرتبطة::::Mesures Relatives::::Mediciones Relativas::::::::Medidas Relativas::::::::相对测量', 'c', '');
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('topoMap', 'Topographical Map::::Топологическая Карта::::خارطة طبوغرافية::::Plan Topographique::::Mapa Topográfico::::::::Mapa Topográfico::::::::地貌图', 'c', '');
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('video', 'Video::::Видео::::شريط فيديو::::Vidéo::::Video::::::::Vídeo::::::::录像', 'c', '');


ALTER TABLE spatial_source_type ENABLE TRIGGER ALL;

SET search_path = system, pg_catalog;

--
-- Data for Name: approle; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE approle DISABLE TRIGGER ALL;

INSERT INTO approle (code, display_value, status, description) VALUES ('01SEC_Unrestricted', 'Security - Unrestricted::::::::السرية - غير مقيد::::::::::::::::Segurança - Irrestrito::::::::安全 - 不受限制::::လုံခြုံရေး − ကန့်သတ်မှု မလုပ်ထား', 'c', 'Grants user clearance to view and/or access all unrestricted records.::::::::امنح المستخدم تصريحا بالوصول ومشاهدة جميع السجلات المقيدة::::::::::::::::Grants user clearance to view and/or access all unrestricted records.::::::::授权用户查看和/或获取所有非限制性记录。::::ကန့်သတ်မှု မလုပ်ထားသော မှတ်တမ်း အမျိုးအစားများအား ကြည့်ခွင့်နှင့် အသုံးပြုခွင့်ကို ယခု အသုံးပြုသူအား ခွင့်ပြုသည်။');
INSERT INTO approle (code, display_value, status, description) VALUES ('03SEC_Confidential', 'Security - Confidential::::::::السرية - خصوصي::::::::::::::::Segurança - Confidencial::::::::安全 - 机密::::လုံခြုံရေး − လျှို့ဝှက်', 'c', 'Grants user clearance to view and/or access all unrestricted, restricted and confidential records.::::::::امنح المستخدم تصريحا بالوصول ومشاهدة جميع السجلات الغير مقيدة , المقيدة والخصوصية::::::::::::::::Grants user clearance to view and/or access all unrestricted, restricted and confidential records.::::::::授权用户查看和/或获取所有非限制性的、限制性的和保密的记录。::::ကန့်သတ်ထားသော၊ ကန့်သတ် မထားသော၊ လျှို့ဝှက်ထားသော မှတ်တမ်းများအား ကြည့်ခွင့်နှင့် အသုံးပြုခွင့်ကို ယခု အသုံးပြုသူအား ခွင့်ပြုသည်။');
INSERT INTO approle (code, display_value, status, description) VALUES ('05SEC_TopSecret', 'Security - Top Secret::::::::السرية - سرية عالية::::::::::::::::Segurança - Extremamente Secreto::::::::安全 - 绝密::::လုံခြုံရေး − အထူးလျှို့ဝှက်', 'c', 'Grants user clearance to view and/or access all records.::::::::امنح المستخدم تصريحا بالوصول ومشاهدة جميع السجلات::::::::::::::::Grants user clearance to view and/or access all records.::::::::授权用户查看和/或获取所有记录。::::မှတ်တမ်း အမျိုးအစားအားလုံးကို ကြည့်ခွင့်နှင့် အသုံးပြုခွင့်ကို ယခု အသုံးပြုသူအား ခွင့်ပြုသည်။');
INSERT INTO approle (code, display_value, status, description) VALUES ('ViewReports', 'View Community Server reports::::::::::::::::::::::::::::::::::::ရပ်ရွာဆာဗာမှ အစီရင်ခံစာများကို ကြည့်ရန်', 'c', 'View Community Server reports::::::::::::::::::::::::::::::::::::ရပ်ရွာဆာဗာမှ အစီရင်ခံစာများကို ကြည့်ရန်');
INSERT INTO approle (code, display_value, status, description) VALUES ('RecordClaim', 'Record claim::::::::تسجيل الأدعاء::::::::Reclamo de registro::::::::Cadastrar requerimento::::::::记录申明::::အဆိုပြုမှတ်တမ်း ', 'c', 'Community recorder role::::::::دور مسجل مجتمع::::::::Posición del registrador comunitario::::::::Função do usuário registrado da Comunidade::::::::社区记录员角色::::မြေပြင်အချက်အလက် ကောက်ယူသူ၏ အခန်းကဏ္ဍ');
INSERT INTO approle (code, display_value, status, description) VALUES ('ReviewClaim', 'Review claim::::::::مراجعة الأدعاء::::::::Reclamo de la opinión::::::::Revisar Requerimento::::::::审查声明::::အဆိုပြုမှု ပြန်စမ်းစစ်ခြင်း', 'c', 'Review claim role::::::::مراجعة دور الأدعاء::::::::Posición del reclamo de la opinión::::::::Revisar a função do requerimento::::::::审查声明角色::::အဆိုပြုမှု ပြန်စမ်းစစ်ခြင်း အခန်းကဏ္ဍ');
INSERT INTO approle (code, display_value, status, description) VALUES ('ChangePassword', 'Admin - Change Password::::Admin - Change Password::::ادارة-تغيير كلمة المرور::::Admin - Changer le Mot de Passe::::Admin - Cambiar contraseña::::::::Admin - Alterar a Senha::::::::管理 - 改变密码::::စီမံ − စကားဝှက်ပြောင်းခြင်း', 'c', 'Allows a user to change their password and edit thier user name. This role should be included in every security group. ::::Allows a user to change their password and edit thier user name. This role should be included in every security group.::::يسمح للمستخدم بتغيير كلمة المرور او تعديل اسم المستخدم. يجب ان يعطى هذا الدور لكل مجموعات أمن المعلومات::::Permet à l''utilisateur de changer son mot de passe et d''éditer son nom d''utilisateur. Ce rôle doit être inclus dans tous les groupes de sécurité.::::Permite a un usuario cambiar su contraseña y editar el nombre de usuario. Este papel debe ser incluido en cada grupo de seguridad.::::::::Permite ao usuário alterar sua senha e editar o nome do seu usuário. Esta função deve ser incluída em todos os grupos de segurança.::::::::允许用户改变密码和修改用户名。这种角色应包含在每一个安全组内。::::အသုံးပြုသူအနေဖြင့် မိမိ၏ အဖွဲ့ဝင်အမည်၊ စကားဝှက်များကို ပြင်ဆင်ခွင့် ပေးထားသည်။ လုံခြုံရေး သတ်မှတ်အဆင့်တိုင်း၌ ပြုလုပ်ခွင့်ပါဝင်သည်။');
INSERT INTO approle (code, display_value, status, description) VALUES ('02SEC_Restricted', 'Security - Restricted::::::::السرية - محدود::::::::::::::::Segurança - Restrito::::::::安全 - 保密::::လုံခြုံရေး − ကန့်သတ်', 'c', 'Grants user clearance to view and/or access all unrestricted and restricted records.::::::::امنح المستخدم تصريحا بالوصول ومشاهدة السجلات المقيدة والغير مقيدة::::::::::::::::Grants user clearance to view and/or access all unrestricted and restricted records.::::::::授权用户查看和/或获取所有非限制和限制性记录。::::ကန့်သတ်၊ ကန့်သတ်မထားသော မှတ်တမ်း အမျိုးအစားအားလုံးကို ကြည့်ခွင့်နှင့် အသုံးပြုခွင့်ကို ယခု အသုံးပြုသူအား ခွင့်ပြုသည်။');
INSERT INTO approle (code, display_value, status, description) VALUES ('AccessCS', 'Access Community Server::::::::الوصول الى خادم المجتمع::::::::Servidor de Acceso Comunitario::::::::Acesso ao Servidor da Comunidade::::::::访问社区服务器::::ရပ်ရွာအဝန်းအဝိုင်း ဆာဗာကို အသုံးပြုခြင်း', 'c', 'Allows to access Community Server as Community recorder user::::::::يسمح بالوصول الى خادم المجتمع كمسجل للمجتمع::::::::Permite acceder al servidor comunitario como usuario registrador comunitario::::::::Permite acessar ao Servidor da Comunidade como usuário registrado na mesma::::::::允许作为社区记录人员访问社区服务器::::မြေပြင်အချက်အလက် ကောက်ယူသူ ဖြစ်သည့် အတွက် ရပ်ရွာအဝန်းအဝိုင်း ဆာဗာအား အသုံးပြုခွင့်ပေးသည်');
INSERT INTO approle (code, display_value, status, description) VALUES ('04SEC_Secret', 'Security - Secret::::::::السرية - سري ::::::::::::::::Segurança - Secreto::::::::安全 - 秘密::::လုံခြုံရေး − လျှို.ဝှက်', 'c', 'Grants user clearance to view and/or access all unrestricted, restricted, confidential and secret records.::::::::امنح المستخدم تصريحا بالوصول ومشاهدة جميع السجلات الغير مقيدة , المقيدة والخصوصية والسرية::::::::::::::::Grants user clearance to view and/or access all unrestricted, restricted, confidential and secret records.::::::::授权用户查看和/或获取所有非限制性的、限制性的、机密的和秘密的记录。::::ကန့်သတ်ထားသော၊ ကန့်သတ် မထားသော၊ လျှို့ဝှက်၊ အထူးလျှို့ဝှက် ထားသော မှတ်တမ်းများအား ကြည့်ခွင့်နှင့် အသုံးပြုခွင့်ကို ယခု အသုံးပြုသူအား ခွင့်ပြုသည်။');
INSERT INTO approle (code, display_value, status, description) VALUES ('ChangeSecClass', 'Security - Change Security Classification::::::::السرية - تغيير تصنيف السرية::::::::::::::::Segurança - Mudança da Classificação da Segurança::::::::安全 - 改变安全分类::::လုံခြုံရေး − လုံခြုံရေးဆိုင်ရာ အမျိုးအစားများ သတ်မှတ်ခြင်း', 'c', 'Allows the user to set or change the security classification for a record.::::::::يسمح للمستخدم  بتعيين  او تغيير تصنيف سرية السجل ::::::::::::::::Allows the user to set or change the security classification for a record.::::::::允许用户设置或改变某个记录的安全分类。::::အသုံးပြုသူ အနေဖြင့် မိမိထည့်သွင်း လိုက်သော မှတ်တမ်း တခု၏ လုံခြုံရေး အဆင့် သတ်မှတ်ခြင်း၊ ပြောင်းလဲခြင်းကို ခွင့်ပြုသည်');
INSERT INTO approle (code, display_value, status, description) VALUES ('ManageSecurity', 'Admin - Users and Security::::Admin - Users and Security::::ادارة-المستخدمين وسرية النظام::::Admin - Utilisateurs et Sécurité::::Admin - Usuarios y Seguridad::::::::Admin - Usuários e Segurança::::::::管理 - 用户及安全性::::စီမံ − အသုံးပြုသူ အဖွဲ့ဝင်နှင့် လုံခြုံရေး', 'c', 'Allows system administrators to manage (edit and save) users, groups and roles. Users with this role will be able to login to the SOLA Admin application. ::::Allows system administrators to manage (edit and save) users, groups and roles. Users with this role will be able to login to the SOLA Admin application.::::يسمح لمدراء النظام بادارة (تعديل وحفظ)  المستخدمين, المجموعات والأدوار. المستخدمين الذين لهم هذه الصلاحية يستطيعون تسجيل الدخول لنظام أدارة سولا::::Permet à l''administrateur système de gérer (éditer et sauvegarder) les utilisateurs, groupes et rôles. Les utilisateurs avec ce rôle peuvent se connecter à l''application SOLA Admin.::::Permite a los administradores de sistemas gestionar (editar y guardar) usuarios, grupos y roles. Los usuarios con este rol podrán acceder a la aplicación SOLA Admin.::::::::Permite que os administradores do sistema possam gerenciar (editar e salvar) usuários, grupos e funções. Usuários com essa função poderão acessar o aplicativo de Administração do SOLA.::::::::允许程序管理员管理 (编辑和保存) 用户、小组和角色。具有这种角色的用户可以登录 SOLA 管理申请。::::စနစ်စီမံခန့်ခွဲသူများအား အသုံးပြုသူ အဖွဲ့ဝင်များ၊ အစုအဖွဲ့များ၊ အဖွဲ့ဝင် အခန်းကဏ္ဍများနှင့် ပတ်သက်ပြီး (ပြင်ဆင်ခြင်း နှင့် သိမ်းဆည်းခြင်း) များ ပြုလုပ်နိုင်ရန် ခွင့်ပြုသည်။ ဤအခန်းကဏ္ဍဖြင့် အသုံးပြုသူများသည် SOLA Admin Application စနစ် အတွင်း ဝင်ရောက်ခွင့်ရှိသည်။');
INSERT INTO approle (code, display_value, status, description) VALUES ('10SEC_SuppressOrd', 'Security - Suppression Order::::::::السرية - أمر كتمان::::::::::::::::Segurança - Ordem de Supressão::::::::安全 - 禁止令::::လုံခြုံရေး − Suppression Order', 'c', 'Grants user clearance to view and/or access all records marked with the Supression Order security classification.::::::::امنح المستخدم تصريحا بالمشاهدة والوصول الى السجلات المعلمة بالأوامر الممنوعة من تصنيفات الأمن والسرية::::::::::::::::Grants user clearance to view and/or access all records marked with the Supression Order security classification.::::::::授权用户查看和/或获取所有标注有禁止令安全分类的记录。::::Suppression Order အမျိုးအစား မှတ်တမ်းများအား ကြည့်ခွင့်နှင့် အသုံးပြုခွင့်ကို ယခု အသုံးပြုသူအား ခွင့်ပြုသည်။');
INSERT INTO approle (code, display_value, status, description) VALUES ('ModerateClaim', 'Moderate claim::::::::تسوية الأدعاء ::::::::Reclamación moderada::::::::Questionamento Moderado::::::::修改声明::::ညှိနှိုင်းပြင်ဆင်ထားသည့် အဆိုပြုမှု', 'c', 'Allows to moderate claims submitted by other community recorders.::::::::يسمح  بتسوية الأدعاءات التي تم ارسالها من مسجلين آخرين ::::::::Permite moderar las reclamaciones presentadas por otras registradores comunitarios.::::::::Permite moderar questionamentos apresentados por outros usuários registrados na Comunidade.::::::::允许修改其他社区记录人员提交的声明。::::အခြား မြေပြင်အချက်အလက် ကောက်ယူသူများ ထည့်သွင်းထားသော အချက်များကို ပြုပြင်ခွင့် ပြုသည်');
INSERT INTO approle (code, display_value, status, description) VALUES ('ManageSettings', 'Admin - System Settings::::Admin - System Settings::::ادارة-اعدادات النظام::::Admin - Paramètres Système::::Admin - Ajustes del sistema ::::::::Admin - Configurações do Sistema::::::::管理 - 系统设置::::စီမံ − စနစ်အပြင်အဆင်', 'c', 'Allows system administrators to manage (edit and save) system setting details. Users with this role will be able to login to the SOLA Admin application. ::::Allows system administrators to manage (edit and save) system setting details. Users with this role will be able to login to the SOLA Admin application.::::يسمح لمدراء النظام بادارة (تعديل وحفظ)  تفاصيل البيانات المرجعية.   المستخدمين الذين لهم هذه الصلاحية يستطيعون تسجيل الدخول لنظام أدارة سولا::::Permet à l''administrateur système de gérer (éditer et sauvegarder) les détails des paramètres du système. Les utilisateurs avec ce rôle peuvent se connecter à l''application SOLA Admin.::::Permite a los administradores de sistemas gestionar (editar y guardar) detalles de configuración del sistema. Los usuarios con este rol podrán acceder a la aplicación SOLA Admin.::::::::Permite que os administradores do sistema possam gerenciar (editar e salvar) dados de configuração do sistema. Usuários com essa função poderão acessar o aplicativo de Administração do SOLA.::::::::允许程序管理员管理（编辑和存储）系统设置细节。具有这种功能的用户可以登录SOLA管理申请。 ::::စနစ်စီမံခန့်ခွဲသူများအား အသေးစိတ် စနစ်ပြင်ဆင်ခြင်း (ပြင်ဆင်ခြင်း နှင့် သိမ်းဆည်းခြင်း) များအား စီမံဆောင်ရွက်ခွင့် ပြုလုပ်နိုင်ရန် ခွင့်ပြုသည်။ ဤအခန်းကဏ္ဍဖြင့် အသုံးပြုသူများသည် SOLA Admin Application စနစ် အတွင်း ဝင်ရောက်ခွင့်ရှိသည်။');
INSERT INTO approle (code, display_value, status, description) VALUES ('ManageRefdata', 'Admin - Reference Data::::Admin - Reference Data::::ادارة- البيانات المرجعية::::Admin - Données de Référence::::Admin - Datos de referencia::::::::Admin - Dados de Referência::::::::管理 - 参考数据::::စီမံ − ကိုးကားအချက်အလက်', 'c', 'Allows system administrators to manage (edit and save) reference data details.  Users with this role will be able to login to the SOLA Admin application. ::::Allows system administrators to manage (edit and save) reference data details.  Users with this role will be able to login to the SOLA Admin application.::::يسمح لمدراء النظام بادارة (تعديل وحفظ) قواعد الأعمال::::Permet à l''administrateur système de gérer (éditer et sauvegarder) les détails des données de référence. Les utilisateurs avec ce rôle peuvent se connecter à l''application SOLA Admin.::::Permite a los administradores de sistemas gestionar (editar y guardar) detalles de los datos de referencia. Los usuarios con este rol podrán acceder a la aplicación SOLA Admin.::::::::Permite que os administradores do sistema possam gerenciar (editar e salvar) os dados de referência. Usuários com essa função poderão acessar o aplicativo de Administração do SOLA.::::::::允许系统管理员管理（编辑和保存）参考数据详情。具有这种角色的用户可以登录SOLA 管理申请。 ::::စနစ်စီမံခန့်ခွဲသူများအား ကိုးကားအချက်အလက်များအား (ပြင်ဆင်ခြင်းနှင့် သိမ်းဆည်းခြင်း) တို့ကို စီမံဆောင်ရွက်နိုင်ရန် ခွင့်ပြုသည်။ ဤအခန်းကဏ္ဍဖြင့် အသုံးပြုသူများသည် SOLA Admin Application စနစ် အတွင်း ဝင်ရောက်ခွင့်ရှိသည်။');


ALTER TABLE approle ENABLE TRIGGER ALL;

--
-- Data for Name: br_severity_type; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE br_severity_type DISABLE TRIGGER ALL;

INSERT INTO br_severity_type (code, display_value, status, description) VALUES ('critical', 'Critical::::Критичное::::حرج::::Critique::::Critico::::::::Crítico::::::::关键的', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO br_severity_type (code, display_value, status, description) VALUES ('medium', 'Medium::::Среднее::::متوسط::::Moyen::::Medio::::::::Médio::::::::中等的', 'c', '...::::::::...::::...::::...::::::::...::::::::...');
INSERT INTO br_severity_type (code, display_value, status, description) VALUES ('warning', 'Warning::::Предупреждение::::تحذير::::Alerte::::Advertencia::::::::Aviso::::::::预告', 'c', '...::::::::...::::...::::...::::::::...::::::::...');


ALTER TABLE br_severity_type ENABLE TRIGGER ALL;

--
-- Data for Name: br_technical_type; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE br_technical_type DISABLE TRIGGER ALL;

INSERT INTO br_technical_type (code, display_value, status, description) VALUES ('drools', 'Drools::::Drools::::Drools::::Drools::::Drools::::::::Drools::::::::Drools系统', 'c', 'The rule definition is based on Drools engine.::::The rule definition is based on Drools engine.::::...::::La définition de la règle est basée sur le moteur Drools.::::La definición de las reglas esta basado en el motor Drools.::::::::A definição de regra é baseada no motor Drools.::::::::该规则的定义基于Drools引擎。');
INSERT INTO br_technical_type (code, display_value, status, description) VALUES ('sql', 'SQL::::SQL::::SQL::::SQL::::SQL::::::::SQL::::::::结构化查询语言', 'c', 'The rule definition is based in sql and it is executed by the database engine.::::The rule definition is based in sql and it is executed by the database engine.::::...::::La définition de la règle est basée en SQL et est exécutée par le moteur de la base de donnée.::::La definición de la regla esta basado en SQL y se ejecuta en el motor de la base de datos.::::::::A definição da regra é baseada em sql e é executado pelo mecanismo de banco de dados.::::::::该规则的定义基于结构化查询语言并由数据库引擎执行。');


ALTER TABLE br_technical_type ENABLE TRIGGER ALL;

--
-- Data for Name: br_validation_target_type; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE br_validation_target_type DISABLE TRIGGER ALL;

INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('ba_unit', 'Administrative Unit::::Единица Недвижимости::::وحدة ادارية::::Unité Administrative::::Unidad Administrativa::::::::Unidade Administrativa::::::::管理单元', 'c', 'The target of the validation is the ba_unit. It accepts one parameter {id} which is the ba_unit id.::::Объектом проверки является единица недвижимости. Имеется один входной параметр - {id} который является id недвижимости.::::...::::La cible de la validation est la ba_unit, l''unité adminstrative de base. Elle accepte un paramètre {id} qui est le numéro d''identification de l''unité administrative ba_unit id.::::El objetivo de la validación es la ba_unit. Se acepta un parámetro {id} que es el id ba_unit.::::::::O objetivo da validação é a ba_und. Ele aceita um parâmetro {id} que é a identificação ba_und.::::::::验证目标为 ba_unit. 它接受ba_unit id为参数 {id} 。');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('source', 'Source::::Документ::::المصدر::::Source::::Fuente::::::::Origem::::::::来源', 'c', 'The target of the validation is the source. It accepts one parameter {id} which is the source id.::::Объектом проверки является документ. Имеется один входной параметр - {id} который является id документа.::::...::::La cible de la validation est la source. Elle accepte un paramètre {id} qui est le numéro d''identification de la source.::::El objetivo de la validación es la fuente. Se acepta un parámetro {id} que es la identificación de la fuente.::::::::O objetivo da validação é a origem. Ele aceita um parâmetro {id} que é a identificação da origem.::::::::验证目标在于来源。它接受来源id为参数 {id} 。');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('application', 'Application::::Заявление::::الطلب::::Demande::::Aplicación::::::::Pedido::::::::申请', 'c', 'The target of the validation is the application. It accepts one parameter {id} which is the application id.::::Объектом проверки является заявление. Имеется один входной параметр - {id} который является id заявления.::::...::::LA cible de la validation est la demande. Elle accepte un paramètre {id} qui est le numéro d''identification de la demande.::::El objetivo de la validación es la aplicación. Se acepta un parámetro {id} que es el ID de aplicación.::::::::O objetivo da validação é o pedido. Ele aceita um parâmetro {id} que é a identificação do pedido.::::::::验证目标在于申请。它接受申请id为参数 {id} 。');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('public_display', 'Public display::::Публичный показ::::أظهار عام::::Affichage Public::::Exhibición pública::::::::Exibição pública::::::::公示', 'c', 'The target of the validation is the set of cadastre objects/ba units that belong to a certain last part. It accepts one parameter {lastPart} which is the last part.::::Объектом проверки является комбинация кадастрового объекта и ед. недвижимости содержащих одинакокую последнюю часть идентификационного кода. Имеется один входной параметр - {lastPart} который является последней частью идентификационного кода.::::...::::La cible de la validation est le lot d''objets cadastre / d''unités administratives qui appartiennent à une certaine dernière partie. Elle accepte un paramètre {lastpart} qui est la dernière partie.::::El objetivo de la validación es el conjunto de objetos catastrales / unidades ba que pertenecen a un determinado última parte. Se acepta un parámetro {lastPart} que es la última parte.::::::::O objetivo da validação é o conjunto de unidades de objetos/ba do cadastro que pertencem com certeza a última parte. Ele aceita um parâmetro {lastPart} que é a última parte.::::::::验证目标为一组地籍对象/属于某一部分的ba units 。它接受这一部分为参数 {lastPart}。');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('rrr', 'Right or Restriction::::Право или Ограничение::::حق أو قيد::::Droit ou Restriction::::Derecho o Restricción::::::::Direito ou Restrição::::::::权利或限制', 'c', 'The target of the validation is the rrr. It accepts one parameter {id} which is the rrr id. ::::Объектом проверки является право. Имеется один входной параметр - {id} который является id права.::::...::::La cible de la validation est le RRR. Elle accepte un paramètre {id} qui est le numéro d''identification du RRR.::::El objetivo de la validación es la RRR. Se acepta un parámetro {id} que es la identificación del RRR.::::::::O objetivo da validação é o drr. Ele aceita um parâmetro {id} que é a identificação do drr.::::::::验证目标为权利限制与责任。它接受权利限制与责任 id为参数 {id} 。');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('spatial_unit_group', 'Spatial unit group::::Пространственная группа::::مجموعة الوحدات المكانية::::Groupe d''Unité Spatiale::::Grupo de unidad espacial.::::::::Grupo de unidade espacial::::::::空间单元组', 'c', 'The target of the validation are the spatial unit groups::::Объектом проверки является пространственные группы::::...::::La cible de la validation sont les groupes d''unité spatiale::::El objetivo de la validación son los grupos de unidades espaciales::::::::O objetivo da validação são os grupos de unidades espaciais::::::::验证目标为空间单元组。');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('consolidation', 'Consolidation::::Consolidation::::الدمج::::Consolidation::::Consolidación::::::::Consolidação::::::::合并', 'c', 'The target of the validation are the records to be consolidated::::The target of the validation are the records to be consolidated::::...::::The target of the validation are the records to be consolidated::::El objetivo de la validación son los registros que se consolidan::::::::O objetivo da validação são os registros a serem consolidados::::::::验证目标为需要合并的记录。');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('bulkOperationSpatial', 'BUlk operation::::Массовая Операция::::رزمة عمليات::::Opération en masse::::Operación Masiva::::::::Operação em massa::::::::批量操作', 'c', 'The target of the validation is the transaction related with the bulk operations.::::Объектом проверки является транзакция, отосящаяся к массовым операциям.::::...::::La cible de la validation est la transaction liée à l''opération en masse.::::El objetivo de la validación es la transacción relacionada con las operaciones masivas.::::::::O objetivo da validação é a operação relacionada com as operações em massa.::::::::验证目标为与批量操作有关的交易。');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('service', 'Service::::Услуга::::خدمة::::Service::::Servicio::::::::Serviço::::::::服务', 'c', 'The target of the validation is the service. It accepts one parameter {id} which is the service id.::::Объектом проверки является услуга. Имеется один входной параметр - {id} который является id услуги.::::...::::La cible de la validation est le service. Elle accepte un paramètre {id} qui est le numéro d''identification du service.::::El objetivo de la validación es el servicio. Se acepta un parámetro {id}, que es el identificador de servicio.::::::::O objetivo da validação é o serviço. Ele aceita um parâmetro {id} que é a identificação de serviço.::::::::验证目标在于服务。它接受服务id为参数 {id} 。');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('cadastre_object', 'Cadastre Object::::Кадастровый Объект::::كائن مساحة::::Objet Cadastre::::Objeto Catastral::::::::Objeto de Cadastro::::::::地籍对象', 'c', 'The target of the validation is the transaction related with the cadastre change. It accepts one parameter {id} which is the transaction id.::::Объектом проверки является кадастровый объект. Имеется один входной параметр - {id} который является id транзакции.::::هدف التحقق من صحة الحركة فحص التغيير على الكائن الممسوح::::La cible de la validation est la transaction liée à la modification du cadastre. Elle accepte un paramètre {id} qui est le numéro d''identification de la transaction.::::El objetivo de la validación es la transacción relacionada con el cambio de catastro. Se acepta un parámetro {id} que es la identificación de la transacción.::::::::O objetivo da validação é a operação relacionada com a mudança de cadastro. Ele aceita um parâmetro {id} que é a identificação da transação.::::::::验证目标为与地籍变更相关的交易。它接受交易id为参数 {id} 。');


ALTER TABLE br_validation_target_type ENABLE TRIGGER ALL;

--
-- Data for Name: language; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE language DISABLE TRIGGER ALL;

INSERT INTO language (code, display_value, active, is_default, item_order, ltr) VALUES ('zh-CN', '中国', true, false, 9, true);
INSERT INTO language (code, display_value, active, is_default, item_order, ltr) VALUES ('en-US', 'English', true, true, 1, true);
INSERT INTO language (code, display_value, active, is_default, item_order, ltr) VALUES ('es-ES', 'Español', true, false, 5, true);
INSERT INTO language (code, display_value, active, is_default, item_order, ltr) VALUES ('fr-FR', 'Français', true, false, 4, true);
INSERT INTO language (code, display_value, active, is_default, item_order, ltr) VALUES ('pt-BR', 'Português', true, false, 7, true);
INSERT INTO language (code, display_value, active, is_default, item_order, ltr) VALUES ('ru-RU', 'Русский', true, false, 2, true);
INSERT INTO language (code, display_value, active, is_default, item_order, ltr) VALUES ('ar-JO', 'عربي', true, false, 3, false);
INSERT INTO language (code, display_value, active, is_default, item_order, ltr) VALUES ('km-KH', 'ខ្មែរ', false, false, 8, true);
INSERT INTO language (code, display_value, active, is_default, item_order, ltr) VALUES ('sq-AL', 'Shqip', false, false, 6, true);
INSERT INTO language (code, display_value, active, is_default, item_order, ltr) VALUES ('my-MM', 'မြန်မာ', true, false, 10, true);


ALTER TABLE language ENABLE TRIGGER ALL;

SET search_path = transaction, pg_catalog;

--
-- Data for Name: reg_status_type; Type: TABLE DATA; Schema: transaction; Owner: postgres
--

ALTER TABLE reg_status_type DISABLE TRIGGER ALL;

INSERT INTO reg_status_type (code, display_value, description, status) VALUES ('historic', 'Historic::::История::::تاريخي::::Historique::::Historico::::::::Histórico::::::::历史的', '...::::::::...::::...::::...::::::::...::::::::...', 'c');
INSERT INTO reg_status_type (code, display_value, description, status) VALUES ('pending', 'Pending::::На исполнении::::قيد الانتظار::::En attente::::Pendiente::::::::Pendente::::::::待定', '...::::::::...::::...::::...::::::::...::::::::...', 'c');
INSERT INTO reg_status_type (code, display_value, description, status) VALUES ('previous', 'Previous::::Предыдущий::::السابق::::Précédent::::Previo::::::::Anterior::::::::先前的', '...::::::::...::::...::::...::::::::...::::::::...', 'c');
INSERT INTO reg_status_type (code, display_value, description, status) VALUES ('current', 'Current::::Текущий::::الحالي::::Courant::::Actual::::::::Atual::::::::目前的', '...::::::::...::::...::::...::::::::...::::::::...', 'c');


ALTER TABLE reg_status_type ENABLE TRIGGER ALL;

--
-- Data for Name: transaction_status_type; Type: TABLE DATA; Schema: transaction; Owner: postgres
--

ALTER TABLE transaction_status_type DISABLE TRIGGER ALL;

INSERT INTO transaction_status_type (code, display_value, description, status) VALUES ('approved', 'Approved::::Одобрено::::موافق عليه::::Approuvé::::Aprobado::::::::Aprovado::::::::已批准', '', 'c');
INSERT INTO transaction_status_type (code, display_value, description, status) VALUES ('cancelled', 'Cancelled::::Отменено::::ملغى::::Annulé::::Cancelado::::::::Cancelado::::::::被取消', '', 'c');
INSERT INTO transaction_status_type (code, display_value, description, status) VALUES ('pending', 'Pending::::Незавершено::::معلق::::En attente::::Pendiente::::::::Pendente::::::::待定', '', 'c');
INSERT INTO transaction_status_type (code, display_value, description, status) VALUES ('completed', 'Completed::::Завершено::::مكتمل::::Exécuté::::Completado::::::::Concluído::::::::已完成', '', 'c');


ALTER TABLE transaction_status_type ENABLE TRIGGER ALL;

--
-- PostgreSQL database dump complete
--

