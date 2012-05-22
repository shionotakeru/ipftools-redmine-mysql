-- Function: func_r_s13(integer, integer, date, date)

-- DROP FUNCTION func_r_s13(integer, integer, date, date);

CREATE OR REPLACE FUNCTION func_r_s13(param_project_id integer, param_ticket_id integer, param_date_from date, param_date_to date)
  RETURNS SETOF record AS
$BODY$
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

		-- 生産性が0の場合は予測分を追加しない
		CONTINUE WHEN CALC_PRODUCTIVITY = 0;

		-- 最終実績の進捗率が既に100%の場合は予測分を追加しない
		CONTINUE WHEN CALC_PROGRESS >= 100;
		
		CNT := 1;
		EXIT_FLG := FALSE;
        
		LOOP
            -- 進捗率計算
            CALC_PROGRESS := ((CALC_SOLVED_BUG_COUNT_ACCUM + (CALC_PRODUCTIVITY * CNT)) / CALC_BUG_COUNT) *100;
            
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
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION func_r_s13(integer, integer, date, date) OWNER TO ipf;
