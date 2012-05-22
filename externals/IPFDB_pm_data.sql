--
-- PostgreSQL database dump
--

-- Started on 2011-12-09 14:55:41

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 21 (class 2615 OID 24576)
-- Name: pm_data; Type: SCHEMA; Schema: -; Owner: ipf
--

CREATE SCHEMA pm_data;


ALTER SCHEMA pm_data OWNER TO ipf;

SET search_path = pm_data, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 2107 (class 1259 OID 24605)
-- Dependencies: 21
-- Name: category_mst; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE category_mst (
    category_id integer NOT NULL,
    project_id integer NOT NULL,
    subject text
);


ALTER TABLE pm_data.category_mst OWNER TO ipf;

--
-- TOC entry 2108 (class 1259 OID 24613)
-- Dependencies: 21
-- Name: cause_mst; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE cause_mst (
    cause_id integer NOT NULL,
    item_no character varying(10),
    subject character varying(255),
    project_id integer NOT NULL
);


ALTER TABLE pm_data.cause_mst OWNER TO ipf;

--
-- TOC entry 2109 (class 1259 OID 24618)
-- Dependencies: 21
-- Name: group_info; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE group_info (
    group_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255)
);


ALTER TABLE pm_data.group_info OWNER TO ipf;

--
-- TOC entry 2110 (class 1259 OID 24623)
-- Dependencies: 21
-- Name: period_mst; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE period_mst (
    project_id integer NOT NULL,
    type character(1) NOT NULL,
    period_zone integer NOT NULL,
    subject character varying(255),
    period_l integer,
    period_u integer
);


ALTER TABLE pm_data.period_mst OWNER TO ipf;

--
-- TOC entry 2111 (class 1259 OID 24628)
-- Dependencies: 21
-- Name: priority_mst; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE priority_mst (
    priority_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255),
    "position" integer
);


ALTER TABLE pm_data.priority_mst OWNER TO ipf;

--
-- TOC entry 2112 (class 1259 OID 24633)
-- Dependencies: 21
-- Name: problem_ticket; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE problem_ticket (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    description character varying(255),
    category_id integer NOT NULL,
    status_id integer NOT NULL,
    priority_id integer NOT NULL,
    user_id integer,
    planned_start_date date,
    planned_end_date date,
    planned_cost double precision,
    parent_id integer,
    change_date date,
    change_user_id integer,
    severity_id integer,
    progress double precision,
    start_date date,
    completed_date date,
    relation_id character varying(255),
    preliminary_t_1 text,
    preliminary_i_1 integer,
    preliminary_d_1 date,
    preliminary_t_2 text,
    preliminary_i_2 integer,
    preliminary_d_2 date,
    preliminary_t_3 text,
    preliminary_i_3 integer,
    preliminary_d_3 date,
    preliminary_t_4 text,
    preliminary_i_4 integer,
    preliminary_d_4 date,
    preliminary_t_5 text,
    preliminary_i_5 integer,
    preliminary_d_5 date,
    preliminary_t_6 text,
    preliminary_i_6 integer,
    preliminary_d_6 date,
    preliminary_t_7 text,
    preliminary_i_7 integer,
    preliminary_d_7 date,
    preliminary_t_8 text,
    preliminary_i_8 integer,
    preliminary_d_8 date,
    preliminary_t_9 text,
    preliminary_i_9 integer,
    preliminary_d_9 date,
    preliminary_t_10 text,
    preliminary_i_10 integer,
    preliminary_d_10 date
);


ALTER TABLE pm_data.problem_ticket OWNER TO ipf;

--
-- TOC entry 2113 (class 1259 OID 24641)
-- Dependencies: 21
-- Name: progress_info; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE progress_info (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    thedate date NOT NULL,
    progress double precision,
    actual_test_count integer,
    parent_id integer
);


ALTER TABLE pm_data.progress_info OWNER TO ipf;

--
-- TOC entry 2106 (class 1259 OID 24577)
-- Dependencies: 21
-- Name: project_info; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE project_info (
    project_id integer NOT NULL,
    project_name character varying(255) NOT NULL,
    outline character varying(255) NOT NULL,
    parent_id integer,
    start_date date,
    end_date date,
    pg_start_date date,
    pg_end_date date,
    trouble_initial_date integer,
    problem_initial_date integer,
    project_path character varying(255)
);


ALTER TABLE pm_data.project_info OWNER TO ipf;

--
-- TOC entry 2114 (class 1259 OID 24646)
-- Dependencies: 21
-- Name: severity_mst; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE severity_mst (
    severity_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255),
    "position" integer
);


ALTER TABLE pm_data.severity_mst OWNER TO ipf;

--
-- TOC entry 2115 (class 1259 OID 24651)
-- Dependencies: 21
-- Name: source_scale; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE source_scale (
    project_id character varying(255) NOT NULL,
    revision character varying(255) NOT NULL,
    ticket_id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    file_type character varying(255),
    file_path text NOT NULL,
    change_user_id integer,
    change_date timestamp without time zone,
    file_size integer,
    source_lines integer,
    source_lines2 integer,
    increase_source_lines integer,
    increase_source_lines2 integer,
    change_source_lines integer,
    change_source_lines2 integer,
    change_user character varying(255)
);


ALTER TABLE pm_data.source_scale OWNER TO ipf;

--
-- TOC entry 2116 (class 1259 OID 24659)
-- Dependencies: 21
-- Name: status_mst; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE status_mst (
    status_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255)
);


ALTER TABLE pm_data.status_mst OWNER TO ipf;

--
-- TOC entry 2121 (class 1259 OID 24705)
-- Dependencies: 21
-- Name: trouble_ticket; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE trouble_ticket (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    description character varying(255),
    category_id integer NOT NULL,
    status_id integer NOT NULL,
    priority_id integer NOT NULL,
    user_id integer,
    planned_start_date date,
    planned_end_date date,
    planned_cost double precision,
    parent_id integer,
    change_date date,
    change_user_id integer,
    severity_id integer,
    progress double precision,
    cause_id integer,
    start_date date,
    completed_date date,
    relation_id character varying(255),
    preliminary_t_1 text,
    preliminary_i_1 integer,
    preliminary_d_1 date,
    preliminary_t_2 text,
    preliminary_i_2 integer,
    preliminary_d_2 date,
    preliminary_t_3 text,
    preliminary_i_3 integer,
    preliminary_d_3 date,
    preliminary_t_4 text,
    preliminary_i_4 integer,
    preliminary_d_4 date,
    preliminary_t_5 text,
    preliminary_i_5 integer,
    preliminary_d_5 date,
    preliminary_t_6 text,
    preliminary_i_6 integer,
    preliminary_d_6 date,
    preliminary_t_7 text,
    preliminary_i_7 integer,
    preliminary_d_7 date,
    preliminary_t_8 text,
    preliminary_i_8 integer,
    preliminary_d_8 date,
    preliminary_t_9 text,
    preliminary_i_9 integer,
    preliminary_d_9 date,
    preliminary_t_10 text,
    preliminary_i_10 integer,
    preliminary_d_10 date
);


ALTER TABLE pm_data.trouble_ticket OWNER TO ipf;

--
-- TOC entry 2117 (class 1259 OID 24664)
-- Dependencies: 21
-- Name: user_info; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE user_info (
    user_id integer NOT NULL,
    user_name character varying(255) NOT NULL,
    name character varying(30) NOT NULL,
    value text
);


ALTER TABLE pm_data.user_info OWNER TO ipf;

--
-- TOC entry 2119 (class 1259 OID 24684)
-- Dependencies: 21
-- Name: user_permission; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE user_permission (
    user_id integer NOT NULL,
    project_id integer NOT NULL,
    action character varying(255) NOT NULL
);


ALTER TABLE pm_data.user_permission OWNER TO ipf;

--
-- TOC entry 2120 (class 1259 OID 24693)
-- Dependencies: 21
-- Name: wbs_ticket; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE wbs_ticket (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    description character varying(255),
    category_id integer NOT NULL,
    status_id integer NOT NULL,
    priority_id integer NOT NULL,
    user_id integer NOT NULL,
    planned_start_date date,
    planned_end_date date,
    planned_cost double precision,
    parent_id integer,
    change_date date,
    change_user_id integer,
    severity_id integer,
    progress double precision,
    planned_test_count integer,
    actual_test_count integer,
    planned_sloc integer,
    bug_density double precision,
    start_date date,
    completed_date date,
    index_ucl double precision,
    index_lcl double precision,
    component text,
    reporter text,
    cc text,
    version text,
    milestone text,
    resolution text,
    keywords text,
    wbs_no character varying(128),
    relation_id character varying(255),
    group_id integer,
    preliminary_t_1 text,
    preliminary_i_1 integer,
    preliminary_d_1 date,
    preliminary_t_2 text,
    preliminary_i_2 integer,
    preliminary_d_2 date,
    preliminary_t_3 text,
    preliminary_i_3 integer,
    preliminary_d_3 date,
    preliminary_t_4 text,
    preliminary_i_4 integer,
    preliminary_d_4 date,
    preliminary_t_5 text,
    preliminary_i_5 integer,
    preliminary_d_5 date,
    preliminary_t_6 text,
    preliminary_i_6 integer,
    preliminary_d_6 date,
    preliminary_t_7 text,
    preliminary_i_7 integer,
    preliminary_d_7 date,
    preliminary_t_8 text,
    preliminary_i_8 integer,
    preliminary_d_8 date,
    preliminary_t_9 text,
    preliminary_i_9 integer,
    preliminary_d_9 date,
    preliminary_t_10 text,
    preliminary_i_10 integer,
    preliminary_d_10 date
);


ALTER TABLE pm_data.wbs_ticket OWNER TO ipf;

--
-- TOC entry 2118 (class 1259 OID 24672)
-- Dependencies: 21
-- Name: work_record; Type: TABLE; Schema: pm_data; Owner: ipf; Tablespace: 
--

CREATE TABLE work_record (
    work_record_id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    ticket_id integer NOT NULL,
    work_date date NOT NULL,
    work_time numeric,
    work_content character varying(255)
);


ALTER TABLE pm_data.work_record OWNER TO ipf;

--
-- TOC entry 2430 (class 2606 OID 24612)
-- Dependencies: 2107 2107 2107
-- Name: category_mst_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY category_mst
    ADD CONSTRAINT category_mst_pkey PRIMARY KEY (category_id, project_id);


--
-- TOC entry 2432 (class 2606 OID 24617)
-- Dependencies: 2108 2108 2108
-- Name: cause_mst_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY cause_mst
    ADD CONSTRAINT cause_mst_pkey PRIMARY KEY (cause_id, project_id);


--
-- TOC entry 2434 (class 2606 OID 24622)
-- Dependencies: 2109 2109 2109
-- Name: group_info_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY group_info
    ADD CONSTRAINT group_info_pkey PRIMARY KEY (group_id, project_id);


--
-- TOC entry 2436 (class 2606 OID 24627)
-- Dependencies: 2110 2110 2110 2110
-- Name: period_mst_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY period_mst
    ADD CONSTRAINT period_mst_pkey PRIMARY KEY (project_id, type, period_zone);


--
-- TOC entry 2438 (class 2606 OID 24632)
-- Dependencies: 2111 2111 2111
-- Name: priority_mst_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY priority_mst
    ADD CONSTRAINT priority_mst_pkey PRIMARY KEY (priority_id, project_id);


--
-- TOC entry 2440 (class 2606 OID 24640)
-- Dependencies: 2112 2112 2112
-- Name: problem_ticket_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY problem_ticket
    ADD CONSTRAINT problem_ticket_pkey PRIMARY KEY (ticket_id, project_id);


--
-- TOC entry 2442 (class 2606 OID 24645)
-- Dependencies: 2113 2113 2113 2113
-- Name: progress_info_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY progress_info
    ADD CONSTRAINT progress_info_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- TOC entry 2428 (class 2606 OID 24584)
-- Dependencies: 2106 2106
-- Name: project_info_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY project_info
    ADD CONSTRAINT project_info_pkey PRIMARY KEY (project_id);


--
-- TOC entry 2444 (class 2606 OID 24650)
-- Dependencies: 2114 2114 2114
-- Name: severity_mst_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY severity_mst
    ADD CONSTRAINT severity_mst_pkey PRIMARY KEY (severity_id, project_id);


--
-- TOC entry 2446 (class 2606 OID 24658)
-- Dependencies: 2115 2115 2115 2115 2115 2115
-- Name: source_scale_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY source_scale
    ADD CONSTRAINT source_scale_pkey PRIMARY KEY (project_id, revision, ticket_id, file_name, file_path);


--
-- TOC entry 2448 (class 2606 OID 24663)
-- Dependencies: 2116 2116 2116
-- Name: status_mst_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY status_mst
    ADD CONSTRAINT status_mst_pkey PRIMARY KEY (status_id, project_id);


--
-- TOC entry 2458 (class 2606 OID 24712)
-- Dependencies: 2121 2121 2121
-- Name: trouble_ticket_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY trouble_ticket
    ADD CONSTRAINT trouble_ticket_pkey PRIMARY KEY (ticket_id, project_id);


--
-- TOC entry 2450 (class 2606 OID 24671)
-- Dependencies: 2117 2117 2117
-- Name: user_info_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY user_info
    ADD CONSTRAINT user_info_pkey PRIMARY KEY (user_id, name);


--
-- TOC entry 2454 (class 2606 OID 24688)
-- Dependencies: 2119 2119 2119 2119
-- Name: user_permission_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY user_permission
    ADD CONSTRAINT user_permission_pkey PRIMARY KEY (user_id, project_id, action);


--
-- TOC entry 2456 (class 2606 OID 24700)
-- Dependencies: 2120 2120 2120
-- Name: wbs_ticket_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY wbs_ticket
    ADD CONSTRAINT wbs_ticket_pkey PRIMARY KEY (ticket_id, project_id);


--
-- TOC entry 2452 (class 2606 OID 24679)
-- Dependencies: 2118 2118 2118
-- Name: work_record_pkey; Type: CONSTRAINT; Schema: pm_data; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY work_record
    ADD CONSTRAINT work_record_pkey PRIMARY KEY (work_record_id, project_id);


-- Completed on 2011-12-09 14:55:44

--
-- PostgreSQL database dump complete
--

