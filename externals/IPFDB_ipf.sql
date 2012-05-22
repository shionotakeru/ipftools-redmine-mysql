-- PLPGSQL ON
CREATE LANGUAGE plpgsql;

--
-- PostgreSQL database dump
--

-- Started on 2011-12-09 17:01:51

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 8 (class 2615 OID 30171)
-- Name: ipf; Type: SCHEMA; Schema: -; Owner: ipf
--

CREATE SCHEMA ipf;


ALTER SCHEMA ipf OWNER TO ipf;

SET search_path = ipf, pg_catalog;

--
-- TOC entry 40 (class 1255 OID 30281)
-- Dependencies: 8 398
-- Name: func_r_m02_paging(character varying, integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION FUNC_R_M02_PAGING(condition VARCHAR, threshold INTEGER, inLimmit INTEGER, user_id INTEGER) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
    
    -- 閾値
    THRE INTEGER := threshold;
    -- 制限値
    LIM INTEGER := inLimmit;
    -- 表示種別（0 : 進捗遅れ, 1 : 工数超過）
    COND VARCHAR := condition;
    -- ユーザID
    USER_ID INTEGER := user_id;
    
    -- カウント数
    COU_VAL RECORD;
    -- 一時テーブル
    TMP_VAL RECORD;
    -- 該当件数
    RECODE_COUNT INTEGER := 0;
    -- ループ回数
    LOOP_COUNT INTEGER := 0;
    -- リミット件数
    TMP_LIMMIT INTEGER := 0;
    
BEGIN
    -- 一時テーブル
    CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER) WITHOUT OIDS;
    FOR COU_VAL IN 
    -- 該当レコード件数を取得
        WITH TMP AS (
            SELECT
                MART.PROJECT_ID AS PROJECT_ID,
                MART.SUBJECT AS PROJECT_NAME,
                CAST(MART.ACTUAL_SLOC AS FLOAT8) / CAST(CASE WHEN MART.PLANNED_SLOC = 0 THEN 1 ELSE MART.PLANNED_SLOC END AS FLOAT8) AS PROGRESS,
                CAST(MART.ACTUAL_COST AS FLOAT8) / CAST(CASE WHEN MART.PLANNED_COST = 0 THEN 1 ELSE MART.PLANNED_COST END AS FLOAT8) AS COST
            FROM
                R_M02_MART AS MART
            WHERE
                MART.PROJECT_ID IN
                (
                SELECT DISTINCT
                    PROJECT_ID
                FROM
                    PM_DATA.USER_PERMISSION
                WHERE
                    USER_ID = USER_ID
                )
        )
        SELECT
            SUM(UNION_TMP.COU) AS COU
        FROM
            (
            SELECT
                COUNT(PROJECT_ID) AS COU
            FROM 
                TMP
            WHERE
                '0' = COND
            AND
                (PROGRESS <= 1 - CAST(THRE AS FLOAT8) / 100 OR PROGRESS >= 1 + CAST(THRE AS FLOAT8) / 100)
            UNION ALL
            SELECT
                COUNT(PROJECT_ID) AS COU
            FROM 
                TMP
            WHERE
                '1' = COND
            AND
                (COST >= 1 + CAST(THRE AS FLOAT8) / 100 OR COST <= 1 - CAST(THRE AS FLOAT8) / 100)
            ) AS UNION_TMP
    LOOP
        RECODE_COUNT := COU_VAL.COU;
    END LOOP;
    
    -- 無限ループ対応
    IF LIM = 0 THEN
        LIM := 10;
    END IF;
    
    -- 該当件数なし時
    IF RECODE_COUNT = 0 THEN
        EXECUTE 'INSERT INTO TMP_TABLE VALUES ('
        || CAST(0 AS INTEGER)
        || ')';
    END IF;
    
    WHILE (RECODE_COUNT - LIM) > 0 LOOP
        LOOP_COUNT := LOOP_COUNT + 1;
        TMP_LIMMIT := LIM * LOOP_COUNT; 
        EXECUTE 'INSERT INTO TMP_TABLE VALUES ('
            || CAST((TMP_LIMMIT - LIM) AS INTEGER)
            || ')';
        RECODE_COUNT := RECODE_COUNT - LIM;
    END LOOP;
    
    -- 最終ページの表示判断をする
    IF RECODE_COUNT > 0 THEN
        LOOP_COUNT := LOOP_COUNT + 1;
        TMP_LIMMIT := LIM * LOOP_COUNT; 
        EXECUTE 'INSERT INTO TMP_TABLE VALUES ('
            || CAST((TMP_LIMMIT - LIM) AS INTEGER)
            || ')';
        RECODE_COUNT := RECODE_COUNT - LIM;
    END IF; 
    --　ループ処理 
    FOR TMP_VAL IN EXECUTE 'SELECT * FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'                
    LOOP
        RETURN NEXT TMP_VAL;
    END LOOP;
    
    -- 一時テーブル削除
    DROP TABLE TMP_TABLE CASCADE;
    RETURN;

END;

$$;


ALTER FUNCTION ipf.func_r_m02_paging(condition character varying, threshold integer, inlimmit integer, user_id integer) OWNER TO ipf;

--
-- TOC entry 21 (class 1255 OID 30259)
-- Dependencies: 398 8
-- Name: func_r_s01_paging(integer, integer, date, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s01_paging(project_id integer, ticket_id integer, date_to date, parent_id integer, inlimmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	PARENT			INTEGER := PARENT_ID;
	LIM				INTEGER := inLimmit;
    PROJ_ID			INTEGER := PROJECT_ID;
    T_ID			INTEGER := TICKET_ID;
    D_TO			DATE	:= DATE_TO;
      
	-- カウント数
	COU_VAL 		RECORD;
	-- 一時テーブル
	TMP_VAL 		RECORD;
	-- 該当件数
	RECODE_COUNT	INTEGER := 0;
    -- ループ回数
    LOOP_COUNT		INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT		INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(TBL.TICKET_ID) as cou
                    FROM 
                        (
                            SELECT
                                MART.TICKET_ID
                            FROM
                                R_S01_MART MART
                            WHERE
                                MART.PROJECT_ID = PROJ_ID
                                AND MART.THEDATE <= D_TO
                                AND CASE WHEN PARENT = 0
                            	       THEN MART.TICKET_ID = T_ID
                            	       ELSE MART.PARENT_ID = PARENT
                            	  END
                            GROUP BY MART.TICKET_ID
                        ) TBL
	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

    IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
    END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s01_paging(project_id integer, ticket_id integer, date_to date, parent_id integer, inlimmit integer) OWNER TO ipf;

--
-- TOC entry 36 (class 1255 OID 30274)
-- Dependencies: 398 8
-- Name: func_r_s02(date, date, text, integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s02(param_from_date date, param_to_date date, param_ticket_id text, param_proj_id integer, param_productivity integer, param_scale integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
    REC             RECORD;
    RET_REC         RECORD;
    
    TBL_NM          TEXT;
    DATE_QUERY      TEXT;
    MOD_PROG        DOUBLE PRECISION;  
    EXIT_FLG        BOOLEAN    DEFAULT FALSE;

    FROM_DATE       DATE;
    TARGET_DATE     DATE;
    DIFF            DOUBLE PRECISION;
    CNT             INT;

BEGIN

    -- 一時テーブル作成
    CREATE TEMPORARY TABLE TEMP_TBL (
        T_ID            INTEGER NOT NULL,
        SUB             CHARACTER VARYING(255) NOT NULL,
        PROG            DOUBLE PRECISION,
        PROG_DIFF       DOUBLE PRECISION,
        EST_PROG        DOUBLE PRECISION,
        EST_PROG_DIFF   DOUBLE PRECISION,        
        T_DATE          DATE NOT NULL,
        P_ID            INTEGER NOT NULL,
        T_FLG           CHARACTER(1) NOT NULL,
        EST_FLG         CHARACTER(1) NOT NULL,
        PRIMARY KEY (T_ID, T_DATE, EST_FLG)
    );

    
    -- 月別 OR 週別判定
    IF PARAM_SCALE = 0  
        THEN TBL_NM         := 'R_S02_W_MART';
             DATE_QUERY     := 'MAX(T_DATE)'; 
        ELSE TBL_NM         := 'R_S02_M_MART';
             DATE_QUERY     := 'CAST(TO_CHAR(MAX(T_DATE) + INTERVAL''-1 MONTHS'',''yyyy-MM-dd'') AS DATE)';
    END IF;

    -- 実績分を一時テーブルに投入
    FOR REC IN EXECUTE 'SELECT * FROM ' || TBL_NM || ' WHERE '
                                        || 'PROJECT_ID = ' || PARAM_PROJ_ID
                                        || ' AND TICKET_ID IN ('  || PARAM_TICKET_ID
                                        || ')'
    LOOP

            EXECUTE 'INSERT INTO TEMP_TBL VALUES('
			|| CAST(REC.TICKET_ID AS INT)
			|| ',' 
			|| CAST('''' || REC.SUBJECT || '''' AS TEXT)
			|| ',' 
			|| CAST(REC.PROGRESS AS DOUBLE PRECISION)
                  || ',' 
			|| CAST(REC.PROGRESS_DIFF AS DOUBLE PRECISION)
			|| ',' 
			|| CAST(999 AS DOUBLE PRECISION)
                  || ',' 
			|| CAST(999 AS DOUBLE PRECISION)
            || ',' 
			|| '''' || REC.THEDATE || ''''
            || ',' 
			|| CAST(REC.PARENT_ID AS INT)
			|| ',' 
			|| CAST('''' || REC.TERMINAL_FLG || '''' AS TEXT)
            || ',' 
			|| CAST('''' || 0 || '''' AS TEXT)
			|| ')';

    END LOOP;


    -- 予測分を一時テーブルに投入
    FOR REC IN EXECUTE '
                        SELECT
                            *
                        FROM
                            (
                            SELECT 
                                * 
                            FROM TEMP_TBL INNER JOIN (
                                                SELECT
                                                    T_ID AS INNER_ID,
                                                    MAX(T_DATE) AS MAX_DATE
                                                FROM
                                                    TEMP_TBL
                                                GROUP BY
                                                    T_ID
                                                ) MAX_TBL ON (TEMP_TBL.T_ID = MAX_TBL.INNER_ID AND TEMP_TBL.T_DATE = MAX_TBL.MAX_DATE)
                            ) PARENT_TBL
                        INNER JOIN 
                        (

                           SELECT
                                MAX_TBL.T_ID AS __T_ID,
                                MAX_TBL.T_DATE AS T_DATE,
                                TEMP_TBL.PROG_DIFF AS DIFF_VALUE
                            FROM
                                TEMP_TBL INNER JOIN (SELECT
                                                        T_ID,
                                                         '
                                                        || DATE_QUERY || 
                                                        'AS T_DATE
                                                    FROM
                                                        TEMP_TBL
                                                    GROUP BY
                                                        T_ID
                                                    ) MAX_TBL ON (TEMP_TBL.T_ID = MAX_TBL.T_ID AND TEMP_TBL.T_DATE = MAX_TBL.T_DATE)
                        
                        ) CHILD_TBL
                            ON (PARENT_TBL.T_ID = CHILD_TBL.__T_ID)
                        ORDER BY
                            PARENT_TBL.T_ID,
                            PARENT_TBL.T_DATE
                        '

    LOOP

        CNT := 0;
        EXIT_FLG := FALSE;

        -- 生産性が0以下の場合は予測分を追加しない
		CONTINUE WHEN REC.DIFF_VALUE <= 0;
        
        -- 最終実績の進捗率が既に1(100%)の場合は予測分を追加しない
        CONTINUE WHEN REC.PROG >= 1;        

        -- 生産変化分取得
        IF PARAM_PRODUCTIVITY > 0
        THEN DIFF := CAST(PARAM_PRODUCTIVITY AS DOUBLE PRECISION) / 100;
        ELSE DIFF := REC.DIFF_VALUE;
        END IF;
        

        LOOP
            --日付調整
            IF CNT = 0
            THEN 
                 MOD_PROG       := REC.PROG;
                 TARGET_DATE    := REC.MAX_DATE;
            ELSE 
                 MOD_PROG       := MOD_PROG + DIFF;
                 -- 加算週 OR 加算月
                 IF PARAM_SCALE = 0
                 THEN   TARGET_DATE     := TARGET_DATE + 7;
                 ELSE   TARGET_DATE     := TARGET_DATE + INTERVAL '+1 MONTH';
                 END IF;
            END IF;

            --表示用
            IF MOD_PROG >= 1
            THEN 
                 MOD_PROG := 1;
                 EXIT_FLG := TRUE;
            END IF;

            IF TARGET_DATE > param_to_date
            THEN 
                 EXIT_FLG := TRUE;
            END IF;
            
            --予測値投入
            EXECUTE 'INSERT INTO TEMP_TBL VALUES('
			|| CAST(REC.T_ID AS INT)
			|| ',' 
			|| CAST('''' || REC.SUB || '''' AS TEXT)
			|| ',' 
			|| CAST(999 AS DOUBLE PRECISION)
            || ',' 
			|| CAST(999 AS DOUBLE PRECISION)
			|| ',' 
			|| CAST(MOD_PROG AS DOUBLE PRECISION)
            || ',' 
			|| CAST(REC.PROG_DIFF AS DOUBLE PRECISION)
            || ',' 
			|| '''' || TARGET_DATE || ''''
            || ',' 
			|| CAST(REC.P_ID AS INT)
			|| ',' 
			|| CAST('''' || REC.T_FLG || '''' AS TEXT)
            || ',' 
			|| CAST('''' || 1 || '''' AS TEXT)
			|| ')';
            
            -- 進捗率が100を超えたらループ終了
            IF EXIT_FLG
            THEN EXIT;
            END IF;
    
            CNT := CNT + 1;
        END LOOP;
    END LOOP;

    -- 仮に入力したデータをNULLにUPDATE
    EXECUTE 'UPDATE TEMP_TBL SET PROG           =   NULL WHERE PROG             = 999';
    EXECUTE 'UPDATE TEMP_TBL SET PROG_DIFF      =   NULL WHERE PROG_DIFF        = 999';
    EXECUTE 'UPDATE TEMP_TBL SET EST_PROG       =   NULL WHERE EST_PROG         = 999';
    EXECUTE 'UPDATE TEMP_TBL SET EST_PROG_DIFF  =   NULL WHERE EST_PROG_DIFF    = 999';

  IF PARAM_SCALE = 0
  THEN FROM_DATE   :=  PARAM_FROM_DATE;
  ELSE FROM_DATE   :=  DATE_TRUNC('MONTH', PARAM_FROM_DATE);
  END IF;

  -- 一時テーブルからSELECTした結果をループ→RECORD型変数に代入
  FOR RET_REC IN EXECUTE 'SELECT * FROM TEMP_TBL WHERE T_DATE BETWEEN ''' || FROM_DATE ||''' AND ''' || PARAM_TO_DATE ||''' ORDER BY T_DATE DESC' 
  LOOP
    RETURN NEXT RET_REC;
  END LOOP;

  -- 明示的にDROP
  DROP TABLE TEMP_TBL;

  RETURN;
END;
$$;


ALTER FUNCTION ipf.func_r_s02(param_from_date date, param_to_date date, param_ticket_id text, param_proj_id integer, param_productivity integer, param_scale integer) OWNER TO ipf;

--
-- TOC entry 37 (class 1255 OID 30276)
-- Dependencies: 8 398
-- Name: func_r_s02_detail(text, integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s02_detail(param_ticket_id text, param_proj_id integer, param_productivity integer, param_scale integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
    REC             RECORD;
    RET_REC         RECORD;

    TBL_NM          TEXT;
    DATE_QUERY      TEXT;
    MOD_PROG        DOUBLE PRECISION;  
    EXIT_FLG        BOOLEAN	DEFAULT FALSE;

    TARGET_DATE     DATE;
    DIFF            DOUBLE PRECISION;
    CNT             INT;
BEGIN

    -- 一時テーブル作成
    CREATE TEMPORARY TABLE TEMP_TBL (
        T_ID            INTEGER NOT NULL,
        SUB             CHARACTER VARYING(255) NOT NULL,
        PROG            DOUBLE PRECISION,
        PROG_DIFF       DOUBLE PRECISION,
        EST_PROG        DOUBLE PRECISION,
        EST_PROG_DIFF   DOUBLE PRECISION,        
        T_DATE          DATE NOT NULL,
        P_ID            INTEGER NOT NULL,
        T_FLG           CHARACTER(1) NOT NULL,
        EST_FLG         CHARACTER(1) NOT NULL,
        PRIMARY KEY (T_ID, T_DATE, EST_FLG)
    );

    
    -- 月別 or 週別判定
    IF PARAM_SCALE = 0  
        THEN TBL_NM         := 'R_S02_W_MART';
             DATE_QUERY     := 'MAX(T_DATE)'; 
        ELSE TBL_NM         := 'R_S02_M_MART';
             DATE_QUERY     := 'CAST(TO_CHAR(MAX(T_DATE) + INTERVAL''-1 MONTHS'',''yyyy-MM-dd'') AS DATE)';
    END IF;



    -- 実績分を一時テーブルに投入
    FOR REC IN EXECUTE 'SELECT * FROM ' || TBL_NM || ' WHERE '
                                        || 'project_id = ' || PARAM_PROJ_ID
                                        || ' and ticket_id IN ('  || PARAM_TICKET_ID
                                        || ')'
    LOOP

            EXECUTE 'INSERT INTO TEMP_TBL VALUES('
			|| CAST(REC.TICKET_ID AS INT)
			|| ',' 
			|| CAST('''' || REC.SUBJECT || '''' AS TEXT)
			|| ',' 
			|| CAST(REC.PROGRESS AS DOUBLE PRECISION)
            || ',' 
			|| CAST(REC.PROGRESS_DIFF AS DOUBLE PRECISION)
			|| ',' 
			|| CAST(999 AS DOUBLE PRECISION)
            || ',' 
			|| CAST(999 AS DOUBLE PRECISION)
            || ',' 
			|| '''' || REC.THEDATE || ''''
            || ',' 
			|| CAST(REC.PARENT_ID AS INT)
			|| ',' 
			|| CAST('''' || REC.TERMINAL_FLG || '''' AS TEXT)
            || ',' 
			|| CAST('''' || 0 || '''' AS TEXT)
			|| ')';

    END LOOP;

    -- 予測分を一時テーブルに投入
    FOR REC IN EXECUTE '
                        SELECT
                            *
                        FROM
                            (
                            SELECT 
                                * 
                            FROM TEMP_TBL INNER JOIN (
                                                SELECT
                                                    T_ID AS INNER_ID,
                                                    MAX(T_DATE) AS MAX_DATE
                                                FROM
                                                    TEMP_TBL
                                                GROUP BY
                                                    T_ID
                                                ) MAX_TBL ON (TEMP_TBL.T_ID = MAX_TBL.INNER_ID AND TEMP_TBL.T_DATE = MAX_TBL.MAX_DATE)
                            ) PARENT_TBL
                        INNER JOIN 
                        (

                           SELECT
                                MAX_TBL.T_ID AS __T_ID,
                                MAX_TBL.T_DATE AS T_DATE,
                                TEMP_TBL.PROG_DIFF AS DIFF_VALUE
                            FROM
                                TEMP_TBL INNER JOIN (SELECT
                                                        T_ID,
                                                         '
                                                        || DATE_QUERY || 
                                                        'AS T_DATE
                                                    FROM
                                                        TEMP_TBL
                                                    GROUP BY
                                                        T_ID
                                                    ) MAX_TBL ON (TEMP_TBL.T_ID = MAX_TBL.T_ID AND TEMP_TBL.T_DATE = MAX_TBL.T_DATE)
                        
                        ) CHILD_TBL
                            ON (PARENT_TBL.T_ID = CHILD_TBL.__T_ID)
                        ORDER BY
                            PARENT_TBL.T_ID,
                            PARENT_TBL.T_DATE
                        '

    LOOP

        CNT := 0;
        EXIT_FLG := FALSE;

        -- 生産性が0の場合は予測分を追加しない
		CONTINUE WHEN REC.DIFF_VALUE = 0;
        
        -- 最終実績の進捗率が既に1(100%)の場合は予測分を追加しない
        CONTINUE WHEN REC.PROG >= 1;

        -- 生産変化分取得
        IF PARAM_PRODUCTIVITY > 0
        THEN DIFF := CAST(PARAM_PRODUCTIVITY AS DOUBLE PRECISION) / 100;
        ELSE DIFF := REC.DIFF_VALUE;
        END IF;
        
        LOOP

            --日付調整
            IF CNT = 0
            THEN 
                 MOD_PROG       := REC.PROG;
                 TARGET_DATE    := REC.MAX_DATE;
            ELSE 
                 MOD_PROG             := MOD_PROG + DIFF;

                 -- 加算週 or 加算月
                 IF PARAM_SCALE = 0
                 THEN TARGET_DATE     := TARGET_DATE + 7;
                 ELSE TARGET_DATE     := TARGET_DATE + interval '+1 month';
                 END IF;
            END IF;

            --表示用
            IF MOD_PROG >= 1
            THEN 
                 MOD_PROG := 1;
                 EXIT_FLG := TRUE;
            END IF;

            --予測値投入
            EXECUTE 'INSERT INTO TEMP_TBL VALUES('
			|| CAST(REC.T_ID AS INT)
			|| ',' 
			|| CAST('''' || REC.SUB || '''' AS TEXT)
			|| ',' 
			|| CAST(999 AS DOUBLE PRECISION)
            || ',' 
			|| CAST(999 AS DOUBLE PRECISION)
			|| ',' 
			|| CAST(MOD_PROG AS DOUBLE PRECISION)
            || ',' 
			|| CAST(REC.PROG_DIFF AS DOUBLE PRECISION)
            || ',' 
			|| '''' || TARGET_DATE || ''''
            || ',' 
			|| CAST(REC.P_ID AS INT)
			|| ',' 
			|| CAST('''' || REC.T_FLG || '''' AS TEXT)
            || ',' 
			|| CAST('''' || 1 || '''' AS TEXT)
			|| ')';
            
            -- 進捗率が1(100%)を超えたらループ終了
            IF EXIT_FLG
            THEN EXIT;
            END IF;
    
            CNT := CNT + 1;
        END LOOP;
    END LOOP;


  -- 一時テーブルからSELECTした結果をループ→RECORD型変数に代入
  FOR RET_REC IN EXECUTE '
                         SELECT 
							  L.TICKET_ID
							, L.SUBJECT
							, L.PLANNED_START_DATE
							, L.PLANNED_END_DATE
							, M.T_DATE
							, TMP.EST_FLG
						 FROM 
						 	R_S15_MART L 
						 INNER JOIN (
						 		SELECT 
						 			  T_ID
                                    , MAX(T_DATE) AS T_DATE 
						 		FROM 
						 			TEMP_TBL 
						 		GROUP BY 
						 			T_ID
						 			) M 
						 ON (L.TICKET_ID = M.T_ID) 
                         INNER JOIN 
                            TEMP_TBL TMP
                         ON (TMP.T_ID = L.TICKET_ID AND TMP.T_DATE = M.T_DATE)
                         WHERE L.PROJECT_ID = ' 
                            || PARAM_PROJ_ID ||
						 ' ORDER BY L.TICKET_ID'
  LOOP    
    RETURN NEXT RET_REC;
  END LOOP;

  -- 明示的にDROP
  DROP TABLE TEMP_TBL;

  RETURN;
END;
$$;


ALTER FUNCTION ipf.func_r_s02_detail(param_ticket_id text, param_proj_id integer, param_productivity integer, param_scale integer) OWNER TO ipf;

--
-- TOC entry 22 (class 1255 OID 30260)
-- Dependencies: 8 398
-- Name: func_r_s02_paging(date, date, text, integer, integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s02_paging(param_from_date date, param_to_date date, param_ticket_id text, param_proj_id integer, param_productivity integer, param_scale integer, in_limmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
    -- 表示最大数 
	LIM          INTEGER := IN_LIMMIT;
      
	-- カウント数
	COU_VAL        RECORD;

	-- 一時テーブル
	TMP_VAL        RECORD;

	-- 該当件数
	RECODE_COUNT   INTEGER  := 0;

    -- ループ回数
    LOOP_COUNT     INTEGER  := 0;

	-- リミット件数
	TMP_LIMMIT     INTEGER  := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(TBL.THEDATE) as cou
                    FROM 
                        (
                            SELECT
                                THEDATE
                            FROM
                                FUNC_R_S02(PARAM_FROM_DATE
                                            , PARAM_TO_DATE
                                            , PARAM_TICKET_ID
                                            , PARAM_PROJ_ID
                                            , PARAM_PRODUCTIVITY
                                            , PARAM_SCALE
                                            )
                                        AS(
                                            TICKET_ID       INT
                                            ,SUBJECT        VARCHAR
                                            ,PROG           DOUBLE PRECISION
                                            ,PROG_DIFF      DOUBLE PRECISION
                                            ,EST_PROG       DOUBLE PRECISION
                                            ,EST_PROG_DIFF  DOUBLE PRECISION
                                            ,THEDATE        DATE
                                            ,PARENT_ID      INT
                                            ,TERMINL_FLG    CHAR
                                            ,EST_FLG        CHAR
                                        )

                            GROUP BY
                                THEDATE
                        ) TBL
	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

    IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
    END IF;


	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s02_paging(param_from_date date, param_to_date date, param_ticket_id text, param_proj_id integer, param_productivity integer, param_scale integer, in_limmit integer) OWNER TO ipf;

--
-- TOC entry 23 (class 1255 OID 30261)
-- Dependencies: 8 398
-- Name: func_r_s03_paging(date, date, text, integer, integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s03_paging(param_from_date date, param_to_date date, param_ticket_id text, param_proj_id integer, param_productivity integer, param_scale integer, in_limmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
    -- 表示最大数 
	LIM          INTEGER := IN_LIMMIT;
      
	-- カウント数
	COU_VAL        RECORD;

	-- 一時テーブル
	TMP_VAL        RECORD;

	-- 該当件数
	RECODE_COUNT   INTEGER  := 0;

    -- ループ回数
    LOOP_COUNT     INTEGER  := 0;

	-- リミット件数
	TMP_LIMMIT     INTEGER  := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(TBL.THEDATE) as cou
                    FROM 
                        (
                            SELECT
                                INN.THEDATE
                            FROM
                                (
                                    SELECT
                                        *
                                    FROM
                                        FUNC_R_S02(PARAM_FROM_DATE
                                                    , PARAM_TO_DATE
                                                    , PARAM_TICKET_ID
                                                    , PARAM_PROJ_ID
                                                    , PARAM_PRODUCTIVITY
                                                    , PARAM_SCALE
                                                    )
                                                AS(
                                                      TICKET_ID       INT
                                                    , SUBJECT        VARCHAR
                                                    , PROG           DOUBLE PRECISION
                                                    , PROG_DIFF      DOUBLE PRECISION
                                                    , EST_PROG       DOUBLE PRECISION
                                                    , EST_PROG_DIFF  DOUBLE PRECISION
                                                    , THEDATE        DATE
                                                    , PARENT_ID      INT
                                                    , TERMINL_FLG    CHAR
                                                    , EST_FLG        CHAR
                                                )
                                    WHERE EST_FLG = '0'
                                ) INN
                            GROUP BY
                                INN.THEDATE
                        ) TBL
	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

    IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
    END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s03_paging(param_from_date date, param_to_date date, param_ticket_id text, param_proj_id integer, param_productivity integer, param_scale integer, in_limmit integer) OWNER TO ipf;

--
-- TOC entry 24 (class 1255 OID 30262)
-- Dependencies: 8 398
-- Name: func_r_s04_paging(integer, integer, date, date, integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s04_paging(parm_project_id integer, parm_ticket_id integer, parm_date_from date, parm_date_to date, parm_scale integer, parm_parent_id integer, parm_limmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	PARENT INTEGER		:= PARM_PARENT_ID;
	LIM INTEGER			:= PARM_Limmit;
    PROJ_ID INTEGER		:= PARM_PROJECT_ID;
    T_ID INTEGER		:= PARM_TICKET_ID;
    D_FR DATE			:= PARM_DATE_FROM;
    D_TO DATE			:= PARM_DATE_TO;
	P_SCALE	INTEGER		:= PARM_SCALE;

	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
      LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(MART_COU.TICKET_ID) as cou
                    FROM
                    	(
							SELECT	ticket_id									AS ticket_id,
									project_id									AS project_id,
									subject										AS subject,
									thedate										AS thedate,
									parent_id									AS parent_id,
									terminal_flg								AS terminal_flg
								FROM
									(SELECT 0	AS	scale,
											ticket_id,
											project_id,
											subject,
											planned_value,
											actual_cost,
											earned_value_wbs,
											earned_value_sloc,
											eac_wbs_continue,
											eac_wbs_special,
											eac_sloc_continue,
											eac_sloc_special,
											estimate_wbs_continue,
											estimate_wbs_special,
											estimate_sloc_continue,
											estimate_sloc_special,
											thedate,
											parent_id,
											terminal_flg
										FROM	r_s04_w_mart
										UNION
									SELECT	1	AS	scale,
											ticket_id,
											project_id,
											subject,
											planned_value,
											actual_cost,
											earned_value_wbs,
											earned_value_sloc,
											eac_wbs_continue,
											eac_wbs_special,
											eac_sloc_continue,
											eac_sloc_special,
											estimate_wbs_continue,
											estimate_wbs_special,
											estimate_sloc_continue,
											estimate_sloc_special,
											thedate,
											parent_id,
											terminal_flg
										FROM	r_s04_m_mart
									)	r_s04_mart
								WHERE	project_id	=	PROJ_ID
							        AND ticket_id   =   T_ID
									AND	CASE WHEN PARENT	=	0
											 THEN TICKET_ID		=	T_ID
											 ELSE PARENT_ID		=	PARENT
										END
									AND thedate between D_FR	AND D_TO
									AND scale		=	P_SCALE
						) MART_COU
 	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

      IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
      END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s04_paging(parm_project_id integer, parm_ticket_id integer, parm_date_from date, parm_date_to date, parm_scale integer, parm_parent_id integer, parm_limmit integer) OWNER TO ipf;

--
-- TOC entry 25 (class 1255 OID 30263)
-- Dependencies: 8 398
-- Name: func_r_s05_paging(integer, integer, date, date, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s05_paging(parm_project_id integer, parm_ticket_id integer, parm_date_from date, parm_date_to date, parm_parent_id integer, parm_limmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	PARENT INTEGER		:= PARM_PARENT_ID;
	LIM INTEGER			:= PARM_Limmit;
    PROJ_ID INTEGER		:= PARM_PROJECT_ID;
    T_ID INTEGER		:= PARM_TICKET_ID;
    D_FR DATE			:= PARM_DATE_FROM;
    D_TO DATE			:= PARM_DATE_TO;

	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
      LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(MART_COU.TICKET_ID) as cou
                    FROM
                    	(
							SELECT  ticket_id                   ticket_id,
							        project_id                  project_id,
							        subject                     subject,
							        thedate                     thedate,
							        parent_id                   parent_id,
							        terminal_flg                terminal_flg
							    FROM    r_s05_mart
							    WHERE   project_id  =   PROJ_ID
							        AND ticket_id   =   T_ID
							        AND thedate BETWEEN D_FR   AND D_TO
							    	AND	parent_id = PARENT
								GROUP BY	ticket_id,
							        		project_id,
							        		subject,
							        		thedate,
							        		parent_id,
							        		terminal_flg
						) MART_COU
 	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

      IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
      END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s05_paging(parm_project_id integer, parm_ticket_id integer, parm_date_from date, parm_date_to date, parm_parent_id integer, parm_limmit integer) OWNER TO ipf;

--
-- TOC entry 26 (class 1255 OID 30264)
-- Dependencies: 398 8
-- Name: func_r_s06_paging(integer, integer, date, date, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s06_paging(parm_project_id integer, parm_ticket_id integer, parm_date_from date, parm_date_to date, parm_parent_id integer, parm_limmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	PARENT INTEGER		:= PARM_PARENT_ID;
	LIM INTEGER			:= PARM_Limmit;
    PROJ_ID INTEGER		:= PARM_PROJECT_ID;
    T_ID INTEGER		:= PARM_TICKET_ID;
    D_FR DATE			:= PARM_DATE_FROM;
    D_TO DATE			:= PARM_DATE_TO;

	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
      LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(MART_COU.TICKET_ID) as cou
                    FROM
                    	(
							SELECT ticket_id
								FROM	r_s06_mart
								WHERE	CASE WHEN	PARENT	=	0
											THEN	ticket_id	=	T_ID
											ELSE	parent_id	=	PARENT
										END
									AND	project_id	=	PROJ_ID
									AND	thedate	BETWEEN	D_FR	AND	D_TO
									AND	parent_id	=	PARENT
								GROUP BY ticket_id

						) MART_COU
 	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

      IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
      END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s06_paging(parm_project_id integer, parm_ticket_id integer, parm_date_from date, parm_date_to date, parm_parent_id integer, parm_limmit integer) OWNER TO ipf;

--
-- TOC entry 27 (class 1255 OID 30265)
-- Dependencies: 398 8
-- Name: func_r_s07_paging(integer, integer, date, date, integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s07_paging(parm_project_id integer, parm_ticket_id integer, parm_date_from date, parm_date_to date, parm_scale integer, parm_parent_id integer, parm_limmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	PARENT INTEGER		:= PARM_PARENT_ID;
	LIM INTEGER			:= PARM_Limmit;
    PROJ_ID INTEGER		:= PARM_PROJECT_ID;
    T_ID INTEGER		:= PARM_TICKET_ID;
    D_FR DATE			:= PARM_DATE_FROM;
    D_TO DATE			:= PARM_DATE_TO;
	P_SCALE	INTEGER		:= PARM_SCALE;

	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
      LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(MART_COU.TICKET_ID) as cou
                    FROM
                    	(
							SELECT	ticket_id,
							        project_id,
							        subject,
									thedate,
							        parent_id,
							        terminal_flg
							    FROM
							    	(SELECT 0	as scale,
							        		r_s04_w_mart.ticket_id,
							        		r_s04_w_mart.project_id,
							        		r_s04_w_mart.subject,
							        		r_s04_w_mart.planned_value,
							        		r_s04_w_mart.actual_cost,
							        		r_s04_w_mart.estimate_wbs_continue,
							        		r_s04_w_mart.estimate_wbs_special,
							        		r_s04_w_mart.thedate,
							        		r_s04_w_mart.parent_id,
							        		r_s04_w_mart.terminal_flg,
							        		w_mart.min_thedate
							    	    FROM    r_s04_w_mart
							    	        INNER JOIN
							    	            (SELECT project_id,
							    	                    ticket_id,
							    	                    MIN(thedate)    AS  min_thedate
							    	                FROM    r_s04_w_mart
							                        GROUP BY    project_id,
							                                    ticket_id
							    	            )   AS  w_mart
							    	        ON      r_s04_w_mart.project_id =   w_mart.project_id
							    	            AND r_s04_w_mart.ticket_id  =   w_mart.ticket_id
							    	UNION
							    	SELECT  1	AS scale,
							        		r_s04_m_mart.ticket_id,
							        		r_s04_m_mart.project_id,
							        		r_s04_m_mart.subject,
							        		r_s04_m_mart.planned_value,
							        		r_s04_m_mart.actual_cost,
							        		r_s04_m_mart.estimate_wbs_continue,
							        		r_s04_m_mart.estimate_wbs_special,
							        		r_s04_m_mart.thedate,
							        		r_s04_m_mart.parent_id,
							        		r_s04_m_mart.terminal_flg,
							        		m_mart.min_thedate
							    	    FROM    r_s04_m_mart
							    	        INNER JOIN
							    	            (SELECT project_id,
							    	                    ticket_id,
							    	                    MIN(thedate)    AS  min_thedate
							    	                FROM    r_s04_m_mart
							                        GROUP BY    project_id,
							                                    ticket_id
							    	            )   AS  m_mart
							    	        ON      r_s04_m_mart.project_id =   m_mart.project_id
							    	            AND r_s04_m_mart.ticket_id  =   m_mart.ticket_id
							    	) as r_s07_mart
							    WHERE   project_id  =   PROJ_ID
							    	AND	CASE WHEN PARENT    	=   0
							    			 THEN TICKET_ID     =   T_ID
							    			 ELSE PARENT_ID     =   PARENT
							    		END
							    	AND thedate between D_FR   AND D_TO
							    	AND scale       =   P_SCALE
						) MART_COU
 	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

      IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
      END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s07_paging(parm_project_id integer, parm_ticket_id integer, parm_date_from date, parm_date_to date, parm_scale integer, parm_parent_id integer, parm_limmit integer) OWNER TO ipf;

--
-- TOC entry 28 (class 1255 OID 30266)
-- Dependencies: 8 398
-- Name: func_r_s08_paging(integer, integer, date, date, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s08_paging(project_id integer, ticket_id integer, date_from date, date_to date, parent_id integer, inlimmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	PARENT INTEGER := PARENT_ID;
	LIM INTEGER := inLimmit;
      PROJ_ID INTEGER := PROJECT_ID;
      T_ID INTEGER :=  TICKET_ID;
      D_FR DATE := DATE_FROM;
      D_TO DATE := DATE_TO;
      
	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
      LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(MART_COU.TICKET_ID) as cou
                    FROM
                    	(
							SELECT
								MART.TICKET_ID
								,MART.PROJECT_ID
								,MART.SUBJECT
								,MART.THEDATE
								,MART.PARENT_ID
								,MART.TERMINAL_FLG
							FROM
								R_S08_MART MART
							WHERE
								MART.PROJECT_ID		=	PROJ_ID
								AND	MART.TICKET_ID	=	T_ID
								AND	MART.THEDATE	BETWEEN D_FR AND D_TO
								AND	MART.PARENT_ID	=	PARENT
							GROUP BY
								MART.TICKET_ID
								,MART.PROJECT_ID
								,MART.SUBJECT
								,MART.THEDATE
								,MART.PARENT_ID
								,MART.TERMINAL_FLG
						) MART_COU
 	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

      IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
      END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s08_paging(project_id integer, ticket_id integer, date_from date, date_to date, parent_id integer, inlimmit integer) OWNER TO ipf;

--
-- TOC entry 29 (class 1255 OID 30267)
-- Dependencies: 8 398
-- Name: func_r_s09_paging(integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s09_paging(project_id integer, ticket_id integer, inlimmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	LIM INTEGER := inLimmit;
      PROJ_ID INTEGER := PROJECT_ID;
      T_ID INTEGER :=  TICKET_ID;
      
	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
      LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(MART.TICKET_ID) as cou
                    FROM
                    	R_S09_MART MART
					WHERE
						MART.TICKET_ID		=	T_ID
						AND MART.PROJECT_ID		=	PROJ_ID
LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

      IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
      END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s09_paging(project_id integer, ticket_id integer, inlimmit integer) OWNER TO ipf;

--
-- TOC entry 30 (class 1255 OID 30268)
-- Dependencies: 8 398
-- Name: func_r_s10_paging(integer, integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s10_paging(project_id integer, ticket_id integer, parent_id integer, inlimmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	PARENT INTEGER := PARENT_ID;
	LIM INTEGER := inLimmit;
    PROJ_ID INTEGER := PROJECT_ID;
    T_ID INTEGER :=  TICKET_ID;
      
	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
    LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
				SELECT
					COUNT(MART.TICKET_ID) AS cou
				FROM
					R_S10_MART MART
				WHERE
					MART.PROJECT_ID	= PROJ_ID
					AND CASE WHEN PARENT = 0
							THEN 
								MART.TICKET_ID =  T_ID
							ELSE
								MART.PARENT_ID	= PARENT
							END
 	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

      IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
      END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s10_paging(project_id integer, ticket_id integer, parent_id integer, inlimmit integer) OWNER TO ipf;

--
-- TOC entry 31 (class 1255 OID 30269)
-- Dependencies: 398 8
-- Name: func_r_s11_paging(integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s11_paging(param_project_id integer, param_ticket_id integer, param_inlimmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	LIM INTEGER := PARAM_INLIMMIT;
    PROJ_ID INTEGER := PARAM_PROJECT_ID;
    T_ID INTEGER :=  PARAM_TICKET_ID;
      
	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
      LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(MART_COU.TICKET_ID) as cou
                    FROM
                    	(
							SELECT
								MART.TICKET_ID AS TICKET_ID
								,MART.PERIOD_ZONE AS PERIOD_ZONE
							FROM
								R_S11_MART MART
							WHERE
								MART.TICKET_ID	= T_ID
								AND MART.PROJECT_ID		=	PROJ_ID
							GROUP BY
								MART.TICKET_ID
								,MART.PERIOD_ZONE
						) MART_COU
 	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

      IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
      END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s11_paging(param_project_id integer, param_ticket_id integer, param_inlimmit integer) OWNER TO ipf;

--
-- TOC entry 32 (class 1255 OID 30270)
-- Dependencies: 398 8
-- Name: func_r_s12_paging(integer, character varying, character varying, integer, character varying, date, date, double precision, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s12_paging(param_project_id integer, param_select_output character varying, param_hidden_tarminal_flag character varying, param_group_id integer, param_worker_id character varying, param_date_from date, param_date_to date, param_border_time double precision, param_inlimmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
    PROJ_ID INTEGER	:= PARAM_PROJECT_ID;
	S_OUT VARCHAR	:= PARAM_SELECT_OUTPUT;
	H_T_FLG VARCHAR	:= PARAM_HIDDEN_TARMINAL_FLAG;
	G_ID INTEGER	:= PARAM_GROUP_ID;
	W_ID VARCHAR	:= PARAM_WORKER_ID;
	D_FR DATE		:= PARAM_DATE_FROM;
	D_TO DATE		:= PARAM_DATE_TO;
	B_TIME FLOAT	:= PARAM_BORDER_TIME;
	LIM INTEGER		:= PARAM_INLIMMIT;

	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
    LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT 
						CASE WHEN S_OUT = '0' AND H_T_FLG = '0'
								THEN
									(
										SELECT COUNT(GROUP_GROUP.GROUP_ID)
										FROM
										(
											SELECT
												MART.GROUP_ID AS GROUP_ID
												,MART.GROUP_NAME AS GROUP_NAME
											FROM
												R_S12_MART MART
											WHERE
												MART.PROJECT_ID = PROJ_ID	
												AND MART.THEDATE BETWEEN D_FR AND D_TO
											GROUP BY
												MART.GROUP_ID
												,MART.GROUP_NAME
										) GROUP_GROUP
									)
							 WHEN S_OUT = '0' AND H_T_FLG = '1'
								THEN
									(
										SELECT COUNT(GROUP_USER.USER_ID)
										FROM
										(
											SELECT
												MART.USER_ID AS USER_ID
												,MART.USER_NAME AS USER_NAME
											FROM 
												R_S12_MART MART
											WHERE
												MART.PROJECT_ID = PROJ_ID
												AND MART.THEDATE BETWEEN D_FR AND D_TO
												AND MART.GROUP_ID = G_ID 
											GROUP BY
												MART.USER_ID
												,MART.USER_NAME
										) GROUP_USER
									)
							 WHEN S_OUT = '1' AND H_T_FLG = '0'
								THEN
									(
										SELECT COUNT(USER_USER.USER_ID)
										FROM
										(
											SELECT
												USER_TABLE.USER_ID AS USER_ID
												,USER_TABLE.USER_NAME AS USER_NAME
												,USER_TABLE.TOTAL_WORK_TIME AS TOTAL_WORK_TIME
											FROM
											(
												SELECT
													MART.USER_ID AS USER_ID
													,MART.USER_NAME AS USER_NAME
													,SUM(MART.WORKING_HOURS) AS TOTAL_WORK_TIME
												FROM R_S12_MART MART
												WHERE
													MART.PROJECT_ID = PROJ_ID
													AND MART.THEDATE BETWEEN D_FR AND D_TO
													AND CASE WHEN W_ID <> '@@@@@@@@@@@@@@@'
															THEN MART.USER_ID = W_ID 
															ELSE 0 = 0 
														END
												GROUP BY
													MART.USER_ID
													,MART.USER_NAME
											) USER_TABLE
											WHERE
												CASE WHEN W_ID <> '@@@@@@@@@@@@@@@'
													THEN 0 = 0
													ELSE USER_TABLE.TOTAL_WORK_TIME > B_TIME
												END											
										) USER_USER
									)
							 WHEN S_OUT = '1' AND H_T_FLG = '1'
								THEN
									(
										SELECT COUNT(USER_GROUP.GROUP_ID)
										FROM
										(
											SELECT
												MART.GROUP_ID AS GROUP_ID
												,MART.GROUP_NAME AS GROUP_NAME
											FROM R_S12_MART MART
											WHERE
												MART.PROJECT_ID = PROJ_ID
												AND MART.THEDATE BETWEEN D_FR AND D_TO
												AND MART.USER_ID = W_ID
											GROUP BY
												MART.GROUP_ID
												,MART.GROUP_NAME
										) USER_GROUP
									)
							END AS cou
 	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

    IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
    END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s12_paging(param_project_id integer, param_select_output character varying, param_hidden_tarminal_flag character varying, param_group_id integer, param_worker_id character varying, param_date_from date, param_date_to date, param_border_time double precision, param_inlimmit integer) OWNER TO ipf;

--
-- TOC entry 39 (class 1255 OID 30279)
-- Dependencies: 8 398
-- Name: func_r_s13(integer, integer, date, date); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s13(param_project_id integer, param_ticket_id integer, param_date_from date, param_date_to date) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- パラメータ
    PRM_P_ID INTEGER     :=     PARAM_PROJECT_ID;
    PRM_T_ID INTEGER     :=     PARAM_TICKET_ID;
    PRM_D_FR DATE        :=     PARAM_DATE_FROM;
    PRM_D_TO DATE        :=     PARAM_DATE_TO;

    -- レコード
    REC                       RECORD;
	RET_REC        			  RECORD;

    -- 計算用項目
    CALC_BUG_COUNT                    DOUBLE PRECISION;        --障害件数
    CALC_SOLVED_BUG_COUNT_ACCUM       DOUBLE PRECISION;        --解決済障害件数
    CALC_PROGRESS                     DOUBLE PRECISION;        --進捗率
    CALC_PRODUCTIVITY                 DOUBLE PRECISION;        --生産性
    
    -- ループ制御用項目
    CNT                       INT;
    EXIT_FLG                  BOOLEAN	DEFAULT FALSE;
    
    -- 最終実績日付
    TARGET_DATE               DATE;    

    -- カーソル 最終実績保持用
    LAST_REC_CURS CURSOR FOR
						SELECT 
							LAST.PROJECT_ID AS PROJECT_ID
							,LAST.TICKET_ID AS TICKET_ID
							,LAST.SUBJECT AS SUBJECT
							,LAST.THEDATE AS THEDATE
							,LAST.SEVERITY_ID AS SEVERITY_ID
							,LAST.BUG_COUNT AS BUG_COUNT
							,LAST.UNSOLVED_BUG_COUNT AS UNSOLVED_BUG_COUNT
							,LAST.SOLVED_BUG_COUNT_TODAY AS SOLVED_BUG_COUNT_TODAY
							,LAST.SOLVED_BUG_COUNT_ACCUM AS SOLVED_BUG_COUNT_ACCUM
							,LAST.PROGRESS AS PROGRESS
							,LAST.SEVERITY_NAME AS SEVERITY_NAME
							,LAST.PARENT_ID AS PARENT_ID
							,LAST.TERMINAL_FLG AS TERMINAL_FLG
							,PROD.PRODUCTIVITY AS PRODUCTIVITY
						FROM
						(
							SELECT
								MART.PROJECT_ID AS PROJECT_ID
								,MART.TICKET_ID AS TICKET_ID
								,MART.SUBJECT AS SUBJECT
								,MART.THEDATE AS THEDATE
								,MART.SEVERITY_ID AS SEVERITY_ID
								,MART.BUG_COUNT AS BUG_COUNT
								,MART.UNSOLVED_BUG_COUNT AS UNSOLVED_BUG_COUNT
								,MART.SOLVED_BUG_COUNT AS SOLVED_BUG_COUNT_TODAY
								,(MART.BUG_COUNT - MART.UNSOLVED_BUG_COUNT) AS SOLVED_BUG_COUNT_ACCUM
								,CASE WHEN MART.BUG_COUNT = 0
									THEN 100
									ELSE
										(CAST((MART.BUG_COUNT - MART.UNSOLVED_BUG_COUNT) AS DOUBLE PRECISION) / CAST(MART.BUG_COUNT AS DOUBLE PRECISION)) * 100
									END AS PROGRESS
								,MART.SEVERITY_NAME AS SEVERITY_NAME
								,MART.PARENT_ID AS PARENT_ID
								,MART.TERMINAL_FLG AS TERMINAL_FLG
							
							FROM
								R_S08_MART MART
							INNER JOIN
								(
									SELECT
										MAX_DATE.PROJECT_ID AS PROJECT_ID
										,MAX_DATE.TICKET_ID AS TICKET_ID
										,MAX(MAX_DATE.THEDATE) AS THEDATE
									FROM
										R_S08_MART MAX_DATE
									WHERE
										MAX_DATE.PROJECT_ID		=	PRM_P_ID
										AND	MAX_DATE.TICKET_ID	=	PRM_T_ID
									GROUP BY
										MAX_DATE.PROJECT_ID
										,MAX_DATE.TICKET_ID
								) LAST_DATE
							ON
								MART.THEDATE = LAST_DATE.THEDATE
							WHERE
								MART.PROJECT_ID		=	PRM_P_ID
								AND	MART.TICKET_ID	=	PRM_T_ID
						) LAST
						INNER JOIN
							(
								SELECT
									MART.PROJECT_ID AS PROJECT_ID
									,MART.TICKET_ID AS TICKET_ID
									,MART.SEVERITY_ID AS SEVERITY_ID
									,CAST(SUM(MART.SOLVED_BUG_COUNT) AS DOUBLE PRECISION) / CAST(COUNT(MART.THEDATE) AS DOUBLE PRECISION) AS PRODUCTIVITY
								FROM
									R_S08_MART MART
								WHERE
									MART.PROJECT_ID		=	PRM_P_ID
									AND	MART.TICKET_ID	=	PRM_T_ID
									AND	MART.THEDATE	BETWEEN PRM_D_FR AND PRM_D_TO
								GROUP BY
									MART.PROJECT_ID
									,MART.TICKET_ID
									,MART.SEVERITY_ID
							) PROD
						ON
						LAST.PROJECT_ID = PROD.PROJECT_ID 
						AND LAST.TICKET_ID = PROD.TICKET_ID
						AND LAST.SEVERITY_ID = PROD.SEVERITY_ID
						ORDER BY
							LAST.PROJECT_ID
							,LAST.TICKET_ID
							,LAST.THEDATE
							,LAST.SEVERITY_ID;

BEGIN

    -- 一時テーブル作成
    CREATE TEMPORARY TABLE TEMP_TABLE
    (
        PROJECT_ID					INTEGER NOT NULL,
        TICKET_ID                   INTEGER NOT NULL,
        SUBJECT                     CHARACTER VARYING(255),
        THEDATE                     DATE NOT NULL,
        SEVERITY_ID                 INTEGER NOT NULL,
        SEVERITY_NAME               CHARACTER VARYING(60),
        BUG_COUNT                   INTEGER,
        SOLVED_BUG_COUNT_ACCUM      INTEGER,
        PROGRESS                    DOUBLE PRECISION,
        PRODUCTIVITY                DOUBLE PRECISION,
        PARENT_ID                   INTEGER,
        TERMINAL_FLG                CHARACTER(1),
        PRIMARY KEY(PROJECT_ID, TICKET_ID, THEDATE, SEVERITY_ID)
    );


	-- 実績分を一時テーブルに投入
    OPEN LAST_REC_CURS;
    LOOP
        FETCH LAST_REC_CURS INTO REC;

        IF NOT FOUND 
        THEN EXIT;
        END IF;

        -- 最終実績投入
        EXECUTE 'INSERT INTO TEMP_TABLE VALUES ('
                              || CAST(REC.PROJECT_ID                    AS INTEGER)
                   || ','     || CAST(REC.TICKET_ID                     AS INTEGER)
                   || ','     || CAST('''' || REC.SUBJECT || ''''       AS TEXT)
                   || ','     || '''' || REC.THEDATE || ''''
                   || ','     || CAST(REC.SEVERITY_ID                   AS INTEGER)
                   || ','     || CAST('''' || REC.SEVERITY_NAME || '''' AS TEXT)
                   || ','     || CAST(REC.BUG_COUNT                     AS INTEGER)
                   || ','     || CAST(REC.SOLVED_BUG_COUNT_ACCUM        AS INTEGER)
                   || ','     || CAST(REC.PROGRESS                      AS DOUBLE PRECISION)
                   || ','     || CAST(REC.PRODUCTIVITY                  AS DOUBLE PRECISION)
                   || ','     || CAST(REC.PARENT_ID                     AS INTEGER)
                   || ','     || CAST('''' || REC.TERMINAL_FLG || ''''  AS TEXT)
                   || ')';

    END LOOP;
    CLOSE LAST_REC_CURS;

    -- 予測分を一時テーブルに投入
    FOR REC IN EXECUTE 'SELECT TMP.PROJECT_ID, TMP.TICKET_ID, TMP.SUBJECT, TMP.THEDATE, TMP.SEVERITY_ID, TMP.SEVERITY_NAME, TMP.BUG_COUNT, TMP.SOLVED_BUG_COUNT_ACCUM, TMP.PROGRESS, TMP.PRODUCTIVITY, TMP.PARENT_ID, TMP.TERMINAL_FLG FROM TEMP_TABLE TMP ORDER BY TMP.PROJECT_ID, TMP.TICKET_ID, TMP.THEDATE, TMP.SEVERITY_ID'
    LOOP
        
        -- 最終実績より項目取得
--		TARGET_DATE						:= CAST(REC.THEDATE AS DATE);					-- 日付
		CALC_BUG_COUNT					:= CAST(REC.BUG_COUNT AS DOUBLE PRECISION);				-- 障害件数
        CALC_SOLVED_BUG_COUNT_ACCUM		:= CAST(REC.SOLVED_BUG_COUNT_ACCUM AS DOUBLE PRECISION);	-- 解決済障害件数
		CALC_PROGRESS					:= CAST(REC.PROGRESS AS DOUBLE PRECISION);					-- 進捗率
		CALC_PRODUCTIVITY				:= CAST(REC.PRODUCTIVITY AS DOUBLE PRECISION); 			-- 生産性

		-- 予測分の日付は当日スタートとなるように日付を調整
		TARGET_DATE := CURRENT_DATE;

		-- 最終実績の進捗率が既に100%の場合は予測分を追加しない
		CONTINUE WHEN CALC_PROGRESS >= 100;
		
		CNT := 1;
		EXIT_FLG := FALSE;
        
		LOOP
            -- 進捗率計算
            CALC_PROGRESS := ((CALC_SOLVED_BUG_COUNT_ACCUM + (CALC_PRODUCTIVITY * CNT)) / CALC_BUG_COUNT) *100;

			--生産性が0の場合は、1回でやめる 2011/12/28
			IF CALC_PRODUCTIVITY = 0
			THEN EXIT_FLG := TRUE;
			END IF;

            -- 進捗率が100%以上の場合は100%とする
            IF CALC_PROGRESS >= 100
            THEN CALC_PROGRESS := 100;
                 EXIT_FLG := TRUE;
            END IF;

            --予測値投入
            EXECUTE 'INSERT INTO TEMP_TABLE VALUES('
                              || CAST(REC.PROJECT_ID                    AS INTEGER)
                   || ','     || CAST(REC.TICKET_ID                     AS INTEGER)
                   || ','     || CAST('''' || REC.SUBJECT || ''''       AS TEXT)
                   || ','     || '''' || TARGET_DATE || ''''
                   || ','     || CAST(REC.SEVERITY_ID                   AS INTEGER)
                   || ','     || CAST('''' || REC.SEVERITY_NAME || '''' AS TEXT)
                   || ','     || CAST(REC.BUG_COUNT                     AS INTEGER)
                   || ','     || CAST((CALC_SOLVED_BUG_COUNT_ACCUM + (CALC_PRODUCTIVITY * CNT))         AS INTEGER)
                   || ','     || CAST(CALC_PROGRESS                     AS DOUBLE PRECISION)
                   || ','     || CAST(REC.PRODUCTIVITY                  AS DOUBLE PRECISION)
                   || ','     || CAST(REC.PARENT_ID                     AS INTEGER)
                   || ','     || CAST('''' || REC.TERMINAL_FLG || ''''  AS TEXT)
                   || ')';
            
            -- 進捗率が100を超えたらループ終了
            IF EXIT_FLG
            THEN EXIT;
            END IF;

            -- 日付調整
            TARGET_DATE := TARGET_DATE + 7;
    
            CNT := CNT + 1;
        END LOOP;
    END LOOP;


	-- 一時テーブルからSELECTした結果をループ→RECORD型変数に代入　（最終実績は不要。当日以降データのみ返却）
	FOR RET_REC IN EXECUTE 'SELECT * FROM TEMP_TABLE WHERE THEDATE >= CURRENT_DATE ORDER BY THEDATE' LOOP
	  RETURN NEXT RET_REC;
	END LOOP;

	-- 明示的にDROP
	DROP TABLE TEMP_TABLE;

  RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s13(param_project_id integer, param_ticket_id integer, param_date_from date, param_date_to date) OWNER TO ipf;

--
-- TOC entry 33 (class 1255 OID 30271)
-- Dependencies: 398 8
-- Name: func_r_s13_paging(integer, integer, date, date, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s13_paging(param_project_id integer, param_ticket_id integer, param_date_from date, param_date_to date, param_inlimmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	LIM INTEGER := PARAM_INLIMMIT;
    PROJ_ID INTEGER := PARAM_PROJECT_ID;
    T_ID INTEGER :=  PARAM_TICKET_ID;
    D_FR DATE := PARAM_DATE_FROM;
    D_TO DATE := PARAM_DATE_TO;
      
	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
      LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(MART_COU.TICKET_ID) as cou
                    FROM
                    	(
							SELECT
								PROJECT_ID
								,TICKET_ID
								,THEDATE
							FROM
								FUNC_R_S13(PROJ_ID,T_ID,D_FR,D_TO)
							AS
								( 
									PROJECT_ID			    INTEGER,
									TICKET_ID       		INTEGER,
                                    SUBJECT                 CHARACTER VARYING(255),
									THEDATE                 DATE,
									SEVERITY_ID             INTEGER,
									SEVERITY_NAME           CHARACTER VARYING(60),
									BUG_COUNT               INTEGER,
									SOLVED_BUG_COUNT_ACCUM  INTEGER,
									PROGRESS                DOUBLE PRECISION,
									PRODUCTIVITY            DOUBLE PRECISION,
									PARENT_ID               INTEGER,
									TERMINAL_FLG            CHARACTER(1)
								)
							GROUP BY
								PROJECT_ID
								,TICKET_ID
								,THEDATE
						) MART_COU
 	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

      IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
      END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s13_paging(param_project_id integer, param_ticket_id integer, param_date_from date, param_date_to date, param_inlimmit integer) OWNER TO ipf;

--
-- TOC entry 34 (class 1255 OID 30272)
-- Dependencies: 398 8
-- Name: func_r_s14_paging(integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s14_paging(param_project_id integer, param_period_zone integer, param_inlimmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	LIM INTEGER := PARAM_INLIMMIT;
    PROJ_ID INTEGER := PARAM_PROJECT_ID;
    P_ZONE INTEGER :=  PARAM_PERIOD_ZONE;
      
	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
      LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(MART_COU.PERIOD_ZONE) as cou
                    FROM
                    	(
							SELECT
								MART.PERIOD_ZONE AS PERIOD_ZONE
							FROM
								R_S14_MART MART
							WHERE
								MART.PROJECT_ID = PROJ_ID
								AND MART.PERIOD_ZONE >= P_ZONE
							GROUP BY
								MART.PERIOD_ZONE
						) MART_COU
 	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

      IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
      END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s14_paging(param_project_id integer, param_period_zone integer, param_inlimmit integer) OWNER TO ipf;

--
-- TOC entry 38 (class 1255 OID 30278)
-- Dependencies: 398 8
-- Name: func_r_s14_paging_dtl(integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s14_paging_dtl(param_project_id integer, param_period_zone integer, param_inlimmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	LIM INTEGER := PARAM_INLIMMIT;
    PROJ_ID INTEGER := PARAM_PROJECT_ID;
    P_ZONE INTEGER :=  PARAM_PERIOD_ZONE;
      
	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
      LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
                    SELECT
                        COUNT(MART_COU.TICKET_ID) as cou
                    FROM
                    	(
							SELECT 
								MART.TICKET_ID AS TICKET_ID
							FROM
								R_S14_MART MART
							WHERE
								MART.PROJECT_ID = PROJ_ID
								AND MART.PERIOD_ZONE = P_ZONE
							GROUP BY
								MART.TICKET_ID
						) MART_COU
 	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

      IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
      END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s14_paging_dtl(param_project_id integer, param_period_zone integer, param_inlimmit integer) OWNER TO ipf;

--
-- TOC entry 35 (class 1255 OID 30273)
-- Dependencies: 8 398
-- Name: func_r_s15_paging(integer, integer, integer); Type: FUNCTION; Schema: ipf; Owner: ipf
--

CREATE FUNCTION func_r_s15_paging(param_project_id integer, param_severity_id integer, param_inlimmit integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	
	LIM INTEGER := PARAM_INLIMMIT;
    PROJ_ID INTEGER := PARAM_PROJECT_ID;
    S_ID INTEGER :=  PARAM_SEVERITY_ID;
      
	-- カウント数
	COU_VAL RECORD;
	-- 一時テーブル
	TMP_VAL RECORD;
	-- 該当件数
	RECODE_COUNT INTEGER := 0;
      -- ループ回数
      LOOP_COUNT INTEGER := 0;
	-- リミット件数
	TMP_LIMMIT INTEGER := 0;
BEGIN
  
	-- 一時テーブル
	CREATE TEMP TABLE TMP_TABLE(OUT_OFFSET INTEGER, OUT_LIMMIT INTEGER) WITHOUT OIDS;

	-- 該当レコード件数を取得
	FOR COU_VAL IN 
					SELECT
						COUNT(MART.TICKET_ID) AS cou
					FROM
						R_S15_MART MART
					WHERE
						MART.SEVERITY_ID = S_ID
						AND MART.PROJECT_ID = PROJ_ID
						AND MART.DAYS_LATER > 0
 	LOOP
		RECODE_COUNT := COU_VAL.COU;
	END LOOP;	

      IF LIM = 0 THEN
	    LIM := 10;
	END IF;

	IF RECODE_COUNT = 0 THEN
              EXECUTE 'INSERT INTO TMP_TABLE VALUES('
        			|| CAST(0 AS INTEGER)
        			|| ')';
      END IF;

	WHILE (RECODE_COUNT - LIM) > 0 LOOP
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END LOOP;
	
	-- 最終ページの表示判断をする
	IF RECODE_COUNT > 0 THEN
		LOOP_COUNT := LOOP_COUNT + 1;
		TMP_LIMMIT := LIM * LOOP_COUNT; 
            EXECUTE 'INSERT INTO TMP_TABLE VALUES('
			|| CAST((TMP_LIMMIT - LIM) AS INTEGER)
			|| ',' 
			|| CAST((TMP_LIMMIT) AS INTEGER)
			|| ')';
		RECODE_COUNT := RECODE_COUNT - LIM;
	END IF; 

	--　ループ処理 
	FOR TMP_VAL IN EXECUTE 'SELECT OUT_OFFSET FROM TMP_TABLE ORDER BY OUT_OFFSET ASC'				
	LOOP
		RETURN NEXT TMP_VAL;
	END LOOP;
	-- 一時テーブル削除

	DROP TABLE TMP_TABLE CASCADE;
	RETURN;

END;
$$;


ALTER FUNCTION ipf.func_r_s15_paging(param_project_id integer, param_severity_id integer, param_inlimmit integer) OWNER TO ipf;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1601 (class 1259 OID 30172)
-- Dependencies: 8
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
-- TOC entry 1602 (class 1259 OID 30175)
-- Dependencies: 8
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
-- TOC entry 1603 (class 1259 OID 30178)
-- Dependencies: 8
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
-- TOC entry 1604 (class 1259 OID 30181)
-- Dependencies: 8
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
-- TOC entry 1605 (class 1259 OID 30184)
-- Dependencies: 8
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
-- TOC entry 1606 (class 1259 OID 30187)
-- Dependencies: 8
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
-- TOC entry 1607 (class 1259 OID 30190)
-- Dependencies: 8
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
-- TOC entry 1608 (class 1259 OID 30193)
-- Dependencies: 8
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
-- TOC entry 1609 (class 1259 OID 30196)
-- Dependencies: 8
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
-- TOC entry 1610 (class 1259 OID 30199)
-- Dependencies: 8
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
-- TOC entry 1611 (class 1259 OID 30205)
-- Dependencies: 8
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
-- TOC entry 1612 (class 1259 OID 30208)
-- Dependencies: 8
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
-- TOC entry 1613 (class 1259 OID 30211)
-- Dependencies: 8
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
-- TOC entry 1614 (class 1259 OID 30214)
-- Dependencies: 8
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
-- TOC entry 1615 (class 1259 OID 30217)
-- Dependencies: 8
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
-- TOC entry 1616 (class 1259 OID 30220)
-- Dependencies: 8
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
-- TOC entry 1895 (class 2606 OID 30227)
-- Dependencies: 1601 1601
-- Name: r_m02_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_m02_mart
    ADD CONSTRAINT r_m02_mart_pkey PRIMARY KEY (project_id);


--
-- TOC entry 1897 (class 2606 OID 30229)
-- Dependencies: 1602 1602 1602 1602
-- Name: r_s01_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s01_mart
    ADD CONSTRAINT r_s01_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- TOC entry 1899 (class 2606 OID 30231)
-- Dependencies: 1603 1603 1603 1603
-- Name: r_s02_m_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s02_m_mart
    ADD CONSTRAINT r_s02_m_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- TOC entry 1901 (class 2606 OID 30233)
-- Dependencies: 1604 1604 1604 1604
-- Name: r_s02_w_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s02_w_mart
    ADD CONSTRAINT r_s02_w_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- TOC entry 1903 (class 2606 OID 30235)
-- Dependencies: 1605 1605 1605 1605
-- Name: r_s04_m_mart_test_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s04_m_mart
    ADD CONSTRAINT r_s04_m_mart_test_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- TOC entry 1905 (class 2606 OID 30237)
-- Dependencies: 1606 1606 1606 1606
-- Name: r_s04_w_mart_test_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s04_w_mart
    ADD CONSTRAINT r_s04_w_mart_test_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- TOC entry 1907 (class 2606 OID 30239)
-- Dependencies: 1607 1607 1607 1607
-- Name: r_s05_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s05_mart
    ADD CONSTRAINT r_s05_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- TOC entry 1909 (class 2606 OID 30241)
-- Dependencies: 1608 1608 1608 1608
-- Name: r_s06_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s06_mart
    ADD CONSTRAINT r_s06_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate);


--
-- TOC entry 1911 (class 2606 OID 30243)
-- Dependencies: 1609 1609 1609 1609 1609
-- Name: r_s08_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s08_mart
    ADD CONSTRAINT r_s08_mart_pkey PRIMARY KEY (ticket_id, project_id, thedate, severity_id);


--
-- TOC entry 1913 (class 2606 OID 30245)
-- Dependencies: 1610 1610 1610 1610
-- Name: r_s09_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s09_mart
    ADD CONSTRAINT r_s09_mart_pkey PRIMARY KEY (ticket_id, project_id, bug_cause);


--
-- TOC entry 1915 (class 2606 OID 30247)
-- Dependencies: 1611 1611 1611
-- Name: r_s10_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s10_mart
    ADD CONSTRAINT r_s10_mart_pkey PRIMARY KEY (ticket_id, project_id);


--
-- TOC entry 1917 (class 2606 OID 30249)
-- Dependencies: 1612 1612 1612 1612 1612
-- Name: r_s11_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s11_mart
    ADD CONSTRAINT r_s11_mart_pkey PRIMARY KEY (ticket_id, project_id, period_zone, severity_id);


--
-- TOC entry 1919 (class 2606 OID 30251)
-- Dependencies: 1613 1613 1613 1613 1613
-- Name: r_s12_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s12_mart
    ADD CONSTRAINT r_s12_mart_pkey PRIMARY KEY (group_id, project_id, user_id, thedate);


--
-- TOC entry 1921 (class 2606 OID 30253)
-- Dependencies: 1614 1614 1614
-- Name: r_s14_list_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s14_list_mart
    ADD CONSTRAINT r_s14_list_mart_pkey PRIMARY KEY (project_id, severity_id);


--
-- TOC entry 1923 (class 2606 OID 30255)
-- Dependencies: 1615 1615 1615 1615 1615
-- Name: r_s14_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s14_mart
    ADD CONSTRAINT r_s14_mart_pkey PRIMARY KEY (ticket_id, project_id, period_zone, severity_id);


--
-- TOC entry 1925 (class 2606 OID 30257)
-- Dependencies: 1616 1616 1616
-- Name: r_s15_mart_pkey; Type: CONSTRAINT; Schema: ipf; Owner: ipf; Tablespace: 
--

ALTER TABLE ONLY r_s15_mart
    ADD CONSTRAINT r_s15_mart_pkey PRIMARY KEY (ticket_id, project_id);


-- Completed on 2011-12-09 17:01:52

--
-- PostgreSQL database dump complete
--

