-- Function: func_r_s03_paging(date, date, text, integer, integer, integer, integer)

-- DROP FUNCTION func_r_s03_paging(date, date, text, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION func_r_s03_paging(param_from_date date, param_to_date date, param_ticket_id text, param_proj_id integer, param_productivity integer, param_scale integer, in_limmit integer)
  RETURNS SETOF record AS
$BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION func_r_s03_paging(date, date, text, integer, integer, integer, integer) OWNER TO ipf;
