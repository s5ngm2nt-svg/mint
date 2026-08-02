-- 이미 운영 중인 프로젝트(jkhwspwflodlttezhqbx)에 그대로 Run 하는 패치.
-- 여러 번 실행해도 안전.
--
-- 실행 순서 주의:
--   1) Authentication > Users > Add user 로 관리자 계정 생성 (Auto Confirm User 켜기)
--   2) 그 다음 이 파일 Run
--   반대로 하면 본인도 관리자에서 저장할 수 없다.

BEGIN;

-- ── 1) 업보 메모 컬럼 (관리자 업보 부여가 memo 를 저장한다) ──
ALTER TABLE upbo_counts ADD COLUMN IF NOT EXISTS memo TEXT;


-- ── 2) 접근 권한 재설정 ──
-- 읽기: 누구나 / 등록·수정·삭제: 로그인한 관리자만
-- 예외: comments·inquiries 는 누구나 등록, inquiries 열람은 관리자만

DO $$
DECLARE
  t   TEXT;
  pol RECORD;
  tables TEXT[] := ARRAY[
    'profile','notice','diary','comments','schedule','songs','original_songs',
    'dress_items','viewers','upbo_types','upbo_counts','inquiries','overlay_state'
  ];
BEGIN
  FOREACH t IN ARRAY tables LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    FOR pol IN SELECT policyname FROM pg_policies WHERE schemaname='public' AND tablename=t LOOP
      EXECUTE format('DROP POLICY %I ON public.%I', pol.policyname, t);
    END LOOP;

    IF t = 'inquiries' THEN
      EXECUTE format('CREATE POLICY "%s_read" ON public.%I FOR SELECT TO authenticated USING (true)', t, t);
    ELSE
      EXECUTE format('CREATE POLICY "%s_read" ON public.%I FOR SELECT USING (true)', t, t);
    END IF;

    IF t IN ('comments','inquiries') THEN
      EXECUTE format('CREATE POLICY "%s_insert" ON public.%I FOR INSERT TO anon, authenticated WITH CHECK (true)', t, t);
    ELSE
      EXECUTE format('CREATE POLICY "%s_insert" ON public.%I FOR INSERT TO authenticated WITH CHECK (true)', t, t);
    END IF;

    EXECUTE format('CREATE POLICY "%s_update" ON public.%I FOR UPDATE TO authenticated USING (true) WITH CHECK (true)', t, t);
    EXECUTE format('CREATE POLICY "%s_delete" ON public.%I FOR DELETE TO authenticated USING (true)', t, t);
  END LOOP;
END $$;

COMMIT;


-- ── 확인용 (선택) ──
-- SELECT tablename, policyname, cmd, roles FROM pg_policies
--  WHERE schemaname='public' ORDER BY tablename, cmd;
--
-- SELECT COUNT(*) AS 시청자 FROM viewers;
-- SELECT COUNT(*) AS 업보기록, COALESCE(SUM(count),0) AS 총합 FROM upbo_counts;
