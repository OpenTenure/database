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
-- Data for Name: appgroup; Type: TABLE DATA; Schema: system; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE appgroup DISABLE TRIGGER ALL;

INSERT INTO appgroup (id, name, description) VALUES ('super-group-id', 'Super group', 'This is a group of users that has right in anything. It is used in developement. In production must be removed.');
INSERT INTO appgroup (id, name, description) VALUES ('CommunityRecorders', 'Community recorders', 'Community recorders users, who can submit claims');
INSERT INTO appgroup (id, name, description) VALUES ('claim-moderators', 'Claim moderators', 'Group for users who can moderate claims, submitted by community recorders');
INSERT INTO appgroup (id, name, description) VALUES ('claim-reviewers', 'Claim reviewers', 'Claim reviewers');
INSERT INTO appgroup (id, name, description) VALUES ('CommunityMembers', 'Community members', 'Community memebers, who can view claims');
INSERT INTO appgroup (id, name, description) VALUES ('ff94bfad-7079-41ea-bf4b-6962e36cad1f', 'Test Classifications', NULL);


ALTER TABLE appgroup ENABLE TRIGGER ALL;

--
-- Data for Name: approle_appgroup; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE approle_appgroup DISABLE TRIGGER ALL;

INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ManageSettings', 'super-group-id', 'be3fc4cc-99dd-11e3-86a1-27716dc68756', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ManageSecurity', 'super-group-id', 'be3febdc-99dd-11e3-8812-fb80415cc5a5', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ChangePassword', 'super-group-id', 'be419996-99dd-11e3-8b35-77b8c207d13b', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ManageRefdata', 'super-group-id', 'be419996-99dd-11e3-8513-a728bd470770', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('AccessCS', 'CommunityRecorders', 'ea10c034-b845-11e3-b045-db6f34a547f8', 1, 'i', 'db:postgres', '2014-03-31 02:00:16.97');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('AccessCS', 'super-group-id', '65dfc8ea-cc69-11e3-999c-53ccd0502f3a', 1, 'i', 'db:postgres', '2014-04-25 17:04:40.353');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ModerateClaim', 'claim-moderators', '0c36e100-eb60-11e3-9533-178ebeef4b74', 1, 'i', 'db:postgres', '2014-06-04 02:45:50.554');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('AccessCS', 'claim-moderators', '0c45d552-eb60-11e3-809a-d76734fbffdd', 1, 'i', 'db:postgres', '2014-06-04 02:45:50.554');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('RecordClaim', 'CommunityRecorders', '4670a0b0-1ba1-11e4-9bde-73a6b8c95aee', 1, 'i', 'db:postgres', '2014-08-04 12:33:40.723');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('RecordClaim', 'super-group-id', '467338ca-1ba1-11e4-841c-bba6c14ffbb3', 1, 'i', 'db:postgres', '2014-08-04 12:33:40.723');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ReviewClaim', 'super-group-id', '467386ea-1ba1-11e4-bde7-0b769093a89f', 1, 'i', 'db:postgres', '2014-08-04 12:33:40.723');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ReviewClaim', 'claim-reviewers', '4673adfa-1ba1-11e4-bc93-17aba8d6daed', 1, 'i', 'db:postgres', '2014-08-04 12:33:40.723');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('AccessCS', 'claim-reviewers', '4673d50a-1ba1-11e4-a1f9-ef941a7b9d3f', 1, 'i', 'db:postgres', '2014-08-04 12:33:40.723');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('AccessCS', 'CommunityMembers', 'ac3503a8-bb9e-11e4-b25d-777354e14c1e', 1, 'i', 'db:postgres', '2015-02-24 02:58:09.586');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ChangeSecClass', 'super-group-id', 'c1421db4-be21-11e4-a9d3-1f0c398dde0f', 1, 'i', 'db:postgres', '2015-02-27 14:41:31.339');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('01SEC_Unrestricted', 'super-group-id', 'c14970d2-be21-11e4-ac7a-abbb20e52dce', 1, 'i', 'db:postgres', '2015-02-27 14:41:31.339');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('02SEC_Restricted', 'super-group-id', 'c14997e2-be21-11e4-9603-6f1b52b1eff8', 1, 'i', 'db:postgres', '2015-02-27 14:41:31.339');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('03SEC_Confidential', 'super-group-id', 'c149bef2-be21-11e4-8aef-7b03b0b3eec4', 1, 'i', 'db:postgres', '2015-02-27 14:41:31.339');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('04SEC_Secret', 'super-group-id', 'c149e602-be21-11e4-b8f0-b7c5ea351184', 1, 'i', 'db:postgres', '2015-02-27 14:41:31.339');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('05SEC_TopSecret', 'super-group-id', 'c149e602-be21-11e4-a2df-ab6b1ddc6997', 1, 'i', 'db:postgres', '2015-02-27 14:41:31.339');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('10SEC_SuppressOrd', 'super-group-id', 'c14a0d12-be21-11e4-9235-d751064ef956', 1, 'i', 'db:postgres', '2015-02-27 14:41:31.339');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('AccessCS', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', '95f8f6b3-d4f2-45c4-9888-88d0b62bca19', 1, 'i', 'test', '2015-02-27 15:31:06.736');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ChangePassword', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', '94575082-ec4d-4d5f-8472-8bfc3d424d41', 1, 'i', 'test', '2015-02-27 15:31:06.736');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ManageRefdata', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', '07e9f98a-8354-4fd5-ac67-f74908852e2d', 1, 'i', 'test', '2015-02-27 15:31:06.736');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ManageSettings', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', '8250f0be-5b53-415c-a99d-396c41956e59', 1, 'i', 'test', '2015-02-27 15:31:06.736');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ManageSecurity', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', '3eb8dd0d-a751-4054-9a63-f3e48cf2a29d', 1, 'i', 'test', '2015-02-27 15:31:06.736');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ModerateClaim', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', 'b715f0d0-ec4d-4d24-a296-3f4fe68b7a87', 1, 'i', 'test', '2015-02-27 15:31:06.736');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('RecordClaim', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', '722feb45-3b55-4c78-bc3a-f9640448d827', 1, 'i', 'test', '2015-02-27 15:31:06.736');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ReviewClaim', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', 'cf00122b-38a9-4681-ab2b-1492cd47e653', 1, 'i', 'test', '2015-02-27 15:31:06.736');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ChangeSecClass', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', '387c38eb-7ff7-49f6-98f7-126b3b0d32ee', 1, 'i', 'test', '2015-02-27 15:31:06.736');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('01SEC_Unrestricted', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', 'a91afd78-3921-4993-a256-f7b2482c081b', 1, 'i', 'test', '2015-02-27 15:31:06.736');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('02SEC_Restricted', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', '1bfe00f6-6b0e-42d2-9c12-a779593a8f24', 1, 'i', 'test', '2015-02-27 15:31:06.736');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ViewReports', 'super-group-id', '2c4da65a-43f6-11e5-9c67-9f326dbd1cf8', 1, 'i', 'db:postgres', '2015-08-16 15:07:08.677');


ALTER TABLE approle_appgroup ENABLE TRIGGER ALL;

--
-- Data for Name: appuser; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE appuser DISABLE TRIGGER ALL;

INSERT INTO appuser (id, username, first_name, last_name, email, mobile_number, activation_code, passwd, active, description, rowidentifier, rowversion, change_action, change_user, change_time, activation_expiration) VALUES ('test-id', 'test', 'Test', 'The BOSS', 'test@simple.com', NULL, NULL, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', true, NULL, 'be17a2c6-99dd-11e3-ba2b-af4cac70daca', 1, 'i', 'test', '2014-02-20 16:19:00.722', NULL);
INSERT INTO appuser (id, username, first_name, last_name, email, mobile_number, activation_code, passwd, active, description, rowidentifier, rowversion, change_action, change_user, change_time, activation_expiration) VALUES ('e21f7c3d-bb02-4a15-94f3-d076861bf343', 'demo', 'demo', 'demo', 'demo@demo.com', '2222222', '12345', '2a97516c354b68848cdbd8f54a226a0a55b21ed138e207ad6c5cbb9c00aa5aea', true, '', '07cbee47-f0ae-46f1-bb72-199abfbf41b3', 15, 'u', 'ANONYMOUS', '2014-09-21 17:36:36.559', NULL);
INSERT INTO appuser (id, username, first_name, last_name, email, mobile_number, activation_code, passwd, active, description, rowidentifier, rowversion, change_action, change_user, change_time, activation_expiration) VALUES ('claim-recorder', 'ClaimRecorder', 'Claim', 'Recorder', 'claim.recorder@mail.com', '111-222', NULL, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', true, 'Demo user for claim recorder role', '4661fa74-1ba1-11e4-ae33-57068db554f3', 13, 'u', 'db:postgres', '2014-09-21 17:36:36.559', NULL);
INSERT INTO appuser (id, username, first_name, last_name, email, mobile_number, activation_code, passwd, active, description, rowidentifier, rowversion, change_action, change_user, change_time, activation_expiration) VALUES ('claim-reviewer', 'ClaimReviewer', 'Claim', 'Reviewer', 'claim.reviewer@mail.com', '111-333', NULL, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', true, 'Demo user for claim reviwer role', '466c0cbc-1ba1-11e4-b1a2-877bd2f873c2', 13, 'u', 'db:postgres', '2014-09-21 17:36:36.559', NULL);
INSERT INTO appuser (id, username, first_name, last_name, email, mobile_number, activation_code, passwd, active, description, rowidentifier, rowversion, change_action, change_user, change_time, activation_expiration) VALUES ('claim-moderator', 'ClaimModerator', 'Claim', 'Moderator', 'claim.moderator@mail.com', '111-444', NULL, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', true, 'Demo user for claim moderator role', '466c33cc-1ba1-11e4-af2b-6f314bab285f', 13, 'u', 'db:postgres', '2014-09-21 17:36:36.559', NULL);
INSERT INTO appuser (id, username, first_name, last_name, email, mobile_number, activation_code, passwd, active, description, rowidentifier, rowversion, change_action, change_user, change_time, activation_expiration) VALUES ('6843b8e6-0738-4a89-a0cc-fa03d385184e', 'user', 'User', 'Test', 'test@sola22.org', '32423423', NULL, '1b4f0e9851971998e732078544c96b36c3d01cedf7caa332359d6f1d83567014', false, NULL, '6f8c6293-fe64-4387-9f12-17ad7e41ef78', 6, 'u', 'test', '2015-02-27 16:26:51.642', NULL);
INSERT INTO appuser (id, username, first_name, last_name, email, mobile_number, activation_code, passwd, active, description, rowidentifier, rowversion, change_action, change_user, change_time, activation_expiration) VALUES ('020bf9c9-2fd9-4014-aa65-09463b3c9e56', 'user2', 'User2', 'Test2', 'test2@user2.org', '434-5453', NULL, '6025d18fe48abd45168528f18a82e265dd98d421a7084aa09f61b341703901a3', true, NULL, 'ec40c46b-f89a-46cf-91cd-8d177cdac74f', 4, 'u', 'test', '2015-02-27 16:27:14.329', NULL);


ALTER TABLE appuser ENABLE TRIGGER ALL;

--
-- Data for Name: appuser_appgroup; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE appuser_appgroup DISABLE TRIGGER ALL;

INSERT INTO appuser_appgroup (appuser_id, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('test-id', 'super-group-id', 'be56cf8c-99dd-11e3-ac27-0343410f6672', 1, 'i', 'db:postgres', '2014-02-20 16:19:01.139');
INSERT INTO appuser_appgroup (appuser_id, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('e21f7c3d-bb02-4a15-94f3-d076861bf343', 'CommunityRecorders', 'bae0f1f3-cfbe-4135-aa25-5059fbdd9edf', 1, 'i', 'ANONYMOUS', '2014-04-25 18:34:02.579');
INSERT INTO appuser_appgroup (appuser_id, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('test-id', 'claim-moderators', 'cd1007b8-eb5f-11e3-8c6d-afdc9e2ad33d', 1, 'i', 'db:postgres', '2014-06-04 02:44:04.493');
INSERT INTO appuser_appgroup (appuser_id, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('test-id', 'claim-reviewers', '466e0896-1ba1-11e4-9c89-ff1ae04cc155', 1, 'i', 'db:postgres', '2014-08-04 12:33:40.723');
INSERT INTO appuser_appgroup (appuser_id, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('claim-recorder', 'CommunityRecorders', '466f8f36-1ba1-11e4-9f4e-13649f8ebcde', 1, 'i', 'db:postgres', '2014-08-04 12:33:40.723');
INSERT INTO appuser_appgroup (appuser_id, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('test-id', 'CommunityRecorders', '466fdd56-1ba1-11e4-b8f6-e7421ee931e9', 1, 'i', 'db:postgres', '2014-08-04 12:33:40.723');
INSERT INTO appuser_appgroup (appuser_id, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('claim-reviewer', 'claim-reviewers', '46700466-1ba1-11e4-811d-bb4889ee1d9a', 1, 'i', 'db:postgres', '2014-08-04 12:33:40.723');
INSERT INTO appuser_appgroup (appuser_id, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('claim-moderator', 'claim-moderators', '46705290-1ba1-11e4-9cdc-d78e1a6af69e', 1, 'i', 'db:postgres', '2014-08-04 12:33:40.723');
INSERT INTO appuser_appgroup (appuser_id, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('6843b8e6-0738-4a89-a0cc-fa03d385184e', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', 'eda84249-a431-4a47-9807-a74b8ec30df7', 1, 'i', 'test', '2015-02-27 15:33:00.741');
INSERT INTO appuser_appgroup (appuser_id, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('020bf9c9-2fd9-4014-aa65-09463b3c9e56', 'ff94bfad-7079-41ea-bf4b-6962e36cad1f', '4b756401-3ccb-48e8-9993-633a9dcb6073', 1, 'i', 'test', '2015-02-27 16:27:02.988');
INSERT INTO appuser_appgroup (appuser_id, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('test-id', 'CommunityMembers', 'bf6cd289-18fe-45f1-93ac-da251a864bee', 1, 'i', 'test', '2015-05-26 12:02:40.793');


ALTER TABLE appuser_appgroup ENABLE TRIGGER ALL;

--
-- Data for Name: appuser_setting; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE appuser_setting DISABLE TRIGGER ALL;



ALTER TABLE appuser_setting ENABLE TRIGGER ALL;

--
-- PostgreSQL database dump complete
--

