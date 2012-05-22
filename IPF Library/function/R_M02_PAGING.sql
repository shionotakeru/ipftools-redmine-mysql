-- DROP FUNCTION FUNC_R_M02_PAGING(condition VARCHAR, threshold INTEGER, inLimmit INTEGER);

CREATE FUNCTION FUNC_R_M02_PAGING(condition VARCHAR, threshold INTEGER, inLimmit INTEGER)
    RETURNS SETOF RECORD AS $$
DECLARE
    
    -- 閾値
    THRE INTEGER := threshold;
    -- 制限値
    LIM INTEGER := inLimmit;
    -- 表示種別（0 : 進捗遅れ, 1 : 工数超過）
    COND VARCHAR := condition;
    
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

$$ LANGUAGE 'PLPGSQL';

-- SELECT * FROM FUNC_R_M02_PAGING('0', 10, 5) AS (OUT_OFFSET INTEGER);