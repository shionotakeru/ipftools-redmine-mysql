-- Function: func_r_s14_paging(integer, integer, integer)

-- DROP FUNCTION func_r_s14_paging(integer, integer, integer);

CREATE OR REPLACE FUNCTION func_r_s14_paging(param_project_id integer, param_period_zone integer, param_inlimmit integer)
  RETURNS SETOF record AS
$BODY$
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
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION func_r_s14_paging(integer, integer, integer) OWNER TO ipf;
