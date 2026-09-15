-- 업보 기록 정리.
-- 3_security_patch.sql 을 먼저 Run 한 뒤 이 파일을 Run 한다.
-- 여러 번 실행해도 안전.
--
-- 왜 필요한가:
--   옛 관리자는 업보를 저장할 때 타입 65개를 count=0 까지 전부 기록했다.
--   시청자 한 명당 65행이 쌓여 표가 수천 행이 되었고, 한 번의 조회는 1000행까지만
--   돌려주므로 나중에 저장한 행이 화면에 아예 안 읽혔다("저장은 되는데 0으로 보임").
--   실제 값이 0 인 행은 의미가 없으므로 지운다.

BEGIN;

-- 정리 전 상태
SELECT COUNT(*) AS 정리전_전체행,
       COUNT(*) FILTER (WHERE count > 0) AS 실제기록,
       COUNT(*) FILTER (WHERE count = 0) AS 빈행
FROM upbo_counts;

DELETE FROM upbo_counts
 WHERE count = 0
   AND (memo IS NULL OR btrim(memo) = '');

CREATE INDEX IF NOT EXISTS idx_upbo_counts_viewer ON upbo_counts(viewer_id);

COMMIT;


-- 정리 후 상태 (1000 미만이면 정상)
SELECT COUNT(*) AS 정리후_전체행,
       COALESCE(SUM(count), 0) AS 업보총합,
       COUNT(DISTINCT viewer_id) AS 업보있는시청자
FROM upbo_counts;
