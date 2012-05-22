CREATE OR REPLACE FUNCTION func_r_s07_paging(parm_project_id integer, parm_ticket_id integer, parm_date_from date, parm_date_to date, parm_scale integer, parm_parent_id integer, parm_limmit integer)
  RETURNS SETOF record AS
$BODY$
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
							        		r_s07_w_mart.ticket_id,
							        		r_s07_w_mart.project_id,
							        		r_s07_w_mart.subject,
							        		r_s07_w_mart.planned_value,
							        		r_s07_w_mart.actual_cost,
							        		r_s07_w_mart.eac_continue,
							        		r_s07_w_mart.eac_special,
							        		r_s07_w_mart.thedate,
							        		r_s07_w_mart.parent_id,
							        		r_s07_w_mart.terminal_flg,
							        		w_mart.min_thedate
							    	    FROM    r_s07_w_mart
							    	        INNER JOIN
							    	            (SELECT project_id,
							    	                    ticket_id,
							    	                    MIN(thedate)    AS  min_thedate
							    	                FROM    r_s07_w_mart
							                        GROUP BY    project_id,
							                                    ticket_id
							    	            )   AS  w_mart
							    	        ON      r_s07_w_mart.project_id =   w_mart.project_id
							    	            AND r_s07_w_mart.ticket_id  =   w_mart.ticket_id
							    	UNION
							    	SELECT  1	AS scale,
							        		r_s07_m_mart.ticket_id,
							        		r_s07_m_mart.project_id,
							        		r_s07_m_mart.subject,
							        		r_s07_m_mart.planned_value,
							        		r_s07_m_mart.actual_cost,
							        		r_s07_m_mart.eac_continue,
							        		r_s07_m_mart.eac_special,
							        		r_s07_m_mart.thedate,
							        		r_s07_m_mart.parent_id,
							        		r_s07_m_mart.terminal_flg,
							        		m_mart.min_thedate
							    	    FROM    r_s07_m_mart
							    	        INNER JOIN
							    	            (SELECT project_id,
							    	                    ticket_id,
							    	                    MIN(thedate)    AS  min_thedate
							    	                FROM    r_s07_m_mart
							                        GROUP BY    project_id,
							                                    ticket_id
							    	            )   AS  m_mart
							    	        ON      r_s07_m_mart.project_id =   m_mart.project_id
							    	            AND r_s07_m_mart.ticket_id  =   m_mart.ticket_id
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
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION func_r_s07_paging(integer, integer, date, date, integer, integer, integer) OWNER TO ipf;
