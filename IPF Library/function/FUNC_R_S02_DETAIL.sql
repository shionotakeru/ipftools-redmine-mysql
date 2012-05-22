-- Function: func_r_s02_detail(text, integer, integer, integer)

-- DROP FUNCTION func_r_s02_detail(text, integer, integer, integer);

CREATE OR REPLACE FUNCTION func_r_s02_detail(param_ticket_id text, param_proj_id integer, param_productivity integer, param_scale integer)
  RETURNS SETOF record AS
$BODY$
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
						 	R_S02_LIST_MART L 
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION func_r_s02_detail(text, integer, integer, integer) OWNER TO ipf;
