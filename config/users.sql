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

INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('ManageSettings', 'super-group-id');
INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('ManageSecurity', 'super-group-id');
INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('ChangePassword', 'super-group-id');
INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('ManageRefdata', 'super-group-id');
INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('ModerateClaim', 'super-group-id');
INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('RecordClaim', 'super-group-id');
INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('ReviewClaim', 'super-group-id');
INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('ViewReports', 'super-group-id');

INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('AccessCS', 'CommunityRecorders');
INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('RecordClaim', 'CommunityRecorders');

INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('ModerateClaim', 'claim-moderators');
INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('AccessCS', 'claim-moderators');

INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('ReviewClaim', 'claim-reviewers');
INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('AccessCS', 'claim-reviewers');

INSERT INTO approle_appgroup (approle_code, appgroup_id) VALUES ('AccessCS', 'CommunityMembers');



ALTER TABLE approle_appgroup ENABLE TRIGGER ALL;

--
-- Data for Name: appuser; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE appuser DISABLE TRIGGER ALL;

INSERT INTO appuser (id, username, first_name, last_name, email, mobile_number, activation_code, passwd, active, description, rowidentifier, rowversion, change_action, change_user, change_time, activation_expiration) VALUES ('test-id', 'test', 'Test', 'Test User', 'test@simple.com', NULL, NULL, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', true, NULL, 'be17a2c6-99dd-11e3-ba2b-af4cac70daca', 1, 'i', 'test', '2014-02-20 16:19:00.722', NULL);
INSERT INTO appuser (id, username, first_name, last_name, email, mobile_number, activation_code, passwd, active, description, rowidentifier, rowversion, change_action, change_user, change_time, activation_expiration) VALUES ('e21f7c3d-bb02-4a15-94f3-d076861bf343', 'demo', 'demo', 'demo', 'demo@demo.com', '2222222', '12345', '2a97516c354b68848cdbd8f54a226a0a55b21ed138e207ad6c5cbb9c00aa5aea', true, '', '07cbee47-f0ae-46f1-bb72-199abfbf41b3', 15, 'u', 'ANONYMOUS', '2014-09-21 17:36:36.559', NULL);
INSERT INTO appuser (id, username, first_name, last_name, email, mobile_number, activation_code, passwd, active, description, rowidentifier, rowversion, change_action, change_user, change_time, activation_expiration) VALUES ('claim-recorder', 'ClaimRecorder', 'Claim', 'Recorder', 'claim.recorder@mail.com', '111-222', NULL, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', true, 'Demo user for claim recorder role', '4661fa74-1ba1-11e4-ae33-57068db554f3', 13, 'u', 'db:postgres', '2014-09-21 17:36:36.559', NULL);
INSERT INTO appuser (id, username, first_name, last_name, email, mobile_number, activation_code, passwd, active, description, rowidentifier, rowversion, change_action, change_user, change_time, activation_expiration) VALUES ('claim-reviewer', 'ClaimReviewer', 'Claim', 'Reviewer', 'claim.reviewer@mail.com', '111-333', NULL, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', true, 'Demo user for claim reviwer role', '466c0cbc-1ba1-11e4-b1a2-877bd2f873c2', 13, 'u', 'db:postgres', '2014-09-21 17:36:36.559', NULL);
INSERT INTO appuser (id, username, first_name, last_name, email, mobile_number, activation_code, passwd, active, description, rowidentifier, rowversion, change_action, change_user, change_time, activation_expiration) VALUES ('claim-moderator', 'ClaimModerator', 'Claim', 'Moderator', 'claim.moderator@mail.com', '111-444', NULL, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', true, 'Demo user for claim moderator role', '466c33cc-1ba1-11e4-af2b-6f314bab285f', 13, 'u', 'db:postgres', '2014-09-21 17:36:36.559', NULL);

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

