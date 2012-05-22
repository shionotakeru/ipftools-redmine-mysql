-- Function: func_r_s12_paging(integer, character varying, character varying, integer, character varying, date, date, double precision, integer)

-- DROP FUNCTION func_r_s12_paging(integer, character varying, character varying, integer, character varying, date, date, double precision, integer);

CREATE OR REPLACE FUNCTION func_r_s12_paging(param_project_id integer, param_select_output character varying, param_hidden_tarminal_flag character varying, param_group_id integer, param_worker_id character varying, param_date_from date, param_date_to date, param_border_time double precision, param_inlimmit integer)
  RETURNS SETOF record AS
$BODY$
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
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION func_r_s12_paging(integer, character varying, character varying, integer, character varying, date, date, double precision, integer) OWNER TO ipf;
