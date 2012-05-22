-- Function: func_r_s08_paging(integer, integer, date, date, integer, integer)

-- DROP FUNCTION func_r_s08_paging(integer, integer, date, date, integer, integer);

CREATE OR REPLACE FUNCTION func_r_s08_paging(project_id integer, ticket_id integer, date_from date, date_to date, parent_id integer, inlimmit integer)
  RETURNS SETOF record AS
$BODY$
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
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION func_r_s08_paging(integer, integer, date, date, integer, integer) OWNER TO ipf;
