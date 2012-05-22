-- PLPGSQL ON
CREATE LANGUAGE plpgsql;

-- CREATE SCHEMA
CREATE SCHEMA ipf;
ALTER SCHEMA ipf OWNER TO ipf;


--
-- Name: r_m02_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_m02_mart (
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    planned_cost double precision,
    actual_cost double precision,
    planned_test_count integer,
    actual_test_count integer,
    planned_bug_count integer,
    bug_count integer,
    open_bug_count integer,
    open_bug_number_of_days integer,
    planned_sloc integer,
    actual_sloc integer
);


ALTER TABLE ipf.r_m02_mart OWNER TO ipf;

--
-- Name: r_s01_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s01_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    thedate date NOT NULL,
    subject character varying(255) NOT NULL,
    actual_sloc integer NOT NULL,
    test_item_count integer NOT NULL,
    parent_id integer,
    index_ucl double precision,
    index_lcl double precision,
    terminal_flg character(1) NOT NULL
);


ALTER TABLE ipf.r_s01_mart OWNER TO ipf;

--
-- Name: r_s02_list_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s02_list_mart (
    ticket_id integer NOT NULL,
    wbs_no character varying(128),
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    planned_start_date date,
    planned_end_date date
);


ALTER TABLE ipf.r_s02_list_mart OWNER TO ipf;

--
-- Name: r_s02_m_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s02_m_mart (
    ticket_id integer NOT NULL,
    wbs_no character varying(128),
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    progress double precision,
    progress_diff double precision,
    thedate date NOT NULL,
    parent_id integer,
    terminal_flg character(1) NOT NULL
);


ALTER TABLE ipf.r_s02_m_mart OWNER TO ipf;

--
-- Name: r_s02_w_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s02_w_mart (
    ticket_id integer NOT NULL,
    wbs_no character varying(128),
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    progress double precision,
    progress_diff double precision,
    thedate date NOT NULL,
    parent_id integer,
    terminal_flg character(1) NOT NULL
);


ALTER TABLE ipf.r_s02_w_mart OWNER TO ipf;

--
-- Name: r_s04_m_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--


CREATE TABLE r_s04_m_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    planned_value double precision,
    actual_cost double precision,
    earned_value_wbs double precision,
    earned_value_sloc double precision,
    eac_wbs_continue double precision,
    eac_wbs_special double precision,
    eac_sloc_continue double precision,
    eac_sloc_special double precision,
    estimate_wbs_continue double precision,
    estimate_wbs_special double precision,
    estimate_sloc_continue double precision,
    estimate_sloc_special double precision,
    thedate date NOT NULL,
    parent_id integer,
    terminal_flg character(1) NOT NULL
);


ALTER TABLE ipf.r_s04_m_mart OWNER TO ipf;

--
-- Name: r_s04_w_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s04_w_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    planned_value double precision,
    actual_cost double precision,
    earned_value_wbs double precision,
    earned_value_sloc double precision,
    eac_wbs_continue double precision,
    eac_wbs_special double precision,
    eac_sloc_continue double precision,
    eac_sloc_special double precision,
    estimate_wbs_continue double precision,
    estimate_wbs_special double precision,
    estimate_sloc_continue double precision,
    estimate_sloc_special double precision,
    thedate date NOT NULL,
    parent_id integer,
    terminal_flg character(1) NOT NULL
);


ALTER TABLE ipf.r_s04_w_mart OWNER TO ipf;

--
-- Name: r_s05_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s05_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    planned_sloc integer,
    actual_sloc integer,
    variation integer,
    thedate date NOT NULL,
    parent_id integer,
    terminal_flg character(1) NOT NULL
);


ALTER TABLE ipf.r_s05_mart OWNER TO ipf;

--
-- Name: r_s06_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s06_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    test_percentage double precision,
    actual_test_count integer,
    planned_test_count integer,
    thedate date NOT NULL,
    parent_id integer,
    terminal_flg character(1) NOT NULL
);


ALTER TABLE ipf.r_s06_mart OWNER TO ipf;

--
-- Name: r_s07_m_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s07_m_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    planned_value double precision,
    actual_cost double precision,
    eac_continue double precision,
    eac_special double precision,
    thedate date NOT NULL,
    parent_id integer,
    terminal_flg character(1) NOT NULL
);


ALTER TABLE ipf.r_s07_m_mart OWNER TO ipf;

--
-- Name: r_s07_w_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s07_w_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    planned_value double precision,
    actual_cost double precision,
    eac_continue double precision,
    eac_special double precision,
    thedate date NOT NULL,
    parent_id integer,
    terminal_flg character(1) NOT NULL
);


ALTER TABLE ipf.r_s07_w_mart OWNER TO ipf;

--
-- Name: r_s08_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s08_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    thedate date NOT NULL,
    planned_bug_count double precision,
    bug_count integer,
    unsolved_bug_count integer,
    solved_bug_count integer,
    severity_id integer NOT NULL,
    severity_name character varying(60),
    parent_id integer,
    terminal_flg character(1) NOT NULL
);


ALTER TABLE ipf.r_s08_mart OWNER TO ipf;

--
-- Name: r_s09_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s09_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    wbs_no character varying(128),
    hierarchy integer NOT NULL,
    bug_cause integer NOT NULL,
    bug_cause_name character varying(255),
    closed_bug_count integer,
    open_bug_count integer,
    parent_id integer,
    terminal_flg character(1) NOT NULL
);


ALTER TABLE ipf.r_s09_mart OWNER TO ipf;

--
-- Name: r_s10_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s10_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    actual_sloc integer,
    test_item_count integer,
    actual_test_count integer,
    bug_density double precision,
    bug_count integer,
    parent_id integer,
    terminal_flg character(1) NOT NULL,
    closed_flg character(1)
);


ALTER TABLE ipf.r_s10_mart OWNER TO ipf;

--
-- Name: r_s11_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s11_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    hierarchy integer NOT NULL,
    period_zone integer NOT NULL,
    period_zone_name character varying(60) NOT NULL,
    unsolved_bug_count integer,
    severity_id integer NOT NULL,
    severity_name character varying(60)
);


ALTER TABLE ipf.r_s11_mart OWNER TO ipf;

--
-- Name: r_s12_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s12_mart (
    group_id integer NOT NULL,
    project_id integer NOT NULL,
    user_id character varying(10) NOT NULL,
    user_name character varying(60),
    working_hours double precision,
    thedate date NOT NULL,
    group_name character varying(255)
);


ALTER TABLE ipf.r_s12_mart OWNER TO ipf;

--
-- Name: r_s14_list_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s14_list_mart (
    project_id integer NOT NULL,
    severity_id integer NOT NULL,
    severity_name character varying(60),
    subject_count integer,
    unsolved_subject_count integer,
    late_start_count integer,
    late_end_count integer
);


ALTER TABLE ipf.r_s14_list_mart OWNER TO ipf;

--
-- Name: r_s14_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s14_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    subject character varying(255) NOT NULL,
    wbs_no character varying(60),
    period_zone integer NOT NULL,
    period_zone_name character varying(60),
    unsolved_subject_count integer,
    severity_id integer NOT NULL,
    severity_name character varying(60)
);


ALTER TABLE ipf.r_s14_mart OWNER TO ipf;

--
-- Name: r_s15_mart; Type: TABLE; Schema: ipf; Owner: ipf; Tablespace: 
--

CREATE TABLE r_s15_mart (
    ticket_id integer NOT NULL,
    project_id integer NOT NULL,
    wbs_no character varying(60),
    hierarchy integer NOT NULL,
    subject character varying(255) NOT NULL,
    days_later integer NOT NULL,
    priority_id integer,
    priority_name character varying(255),
    severity_id integer,
    severity_name character varying(255),
    planned_start_date date,
    planned_end_date date,
    start_date date,
    end_date date,
    parent_id integer,
    terminal_flg character(1) NOT NULL
);


ALTER TABLE ipf.r_s15_mart OWNER TO ipf;

--
-- Name: r_m02_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_m02_mart
    ADD CONSTRAINT r_m02_mart_pkey PRIMARY KEY (project_id);


--
-- Name: r_s01_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s01_mart
    ADD CONSTRAINT r_s01_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- Name: r_s02_list_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s02_list_mart
    ADD CONSTRAINT r_s02_list_mart_pkey PRIMARY KEY (ticket_id, project_id);


--
-- Name: r_s02_m_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s02_m_mart
    ADD CONSTRAINT r_s02_m_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- Name: r_s02_w_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s02_w_mart
    ADD CONSTRAINT r_s02_w_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- Name: r_s04_m_mart_test_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s04_m_mart
    ADD CONSTRAINT r_s04_m_mart_test_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- Name: r_s04_w_mart_test_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s04_w_mart
    ADD CONSTRAINT r_s04_w_mart_test_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- Name: r_s05_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s05_mart
    ADD CONSTRAINT r_s05_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- Name: r_s06_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s06_mart
    ADD CONSTRAINT r_s06_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- Name: r_s07_m_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s07_m_mart
    ADD CONSTRAINT r_s07_m_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- Name: r_s07_w_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s07_w_mart
    ADD CONSTRAINT r_s07_w_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- Name: r_s08_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s08_mart
    ADD CONSTRAINT r_s08_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate, severity_id);


--
-- Name: r_s09_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s09_mart
    ADD CONSTRAINT r_s09_mart_pkey PRIMARY KEY (ticket_id, project_id, bug_cause);


--
-- Name: r_s10_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s10_mart
    ADD CONSTRAINT r_s10_mart_pkey PRIMARY KEY (ticket_id, project_id);


--
-- Name: r_s11_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s11_mart
    ADD CONSTRAINT r_s11_mart_pkey PRIMARY KEY (ticket_id, project_id, period_zone, severity_id);


--
-- Name: r_s12_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s12_mart
    ADD CONSTRAINT r_s12_mart_pkey PRIMARY KEY (group_id, project_id, user_id, thedate);


--
-- Name: r_s14_list_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s14_list_mart
    ADD CONSTRAINT r_s14_list_mart_pkey PRIMARY KEY (project_id, severity_id);


--
-- Name: r_s14_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s14_mart
    ADD CONSTRAINT r_s14_mart_pkey PRIMARY KEY (ticket_id, project_id, period_zone, severity_id);


--
-- Name: r_s15_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s15_mart
    ADD CONSTRAINT r_s15_mart_pkey PRIMARY KEY (ticket_id, project_id);



--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--