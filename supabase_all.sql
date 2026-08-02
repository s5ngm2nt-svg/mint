-- =============================================================
-- 버추얼 팬페이지 템플릿 — Supabase 전체 셋업 SQL (한 번에 붙여넣기용)
-- 사용법: Supabase → SQL Editor → 아래 전체 복붙 → Run.
-- 여러 번 다시 실행해도 안전 (CREATE ... IF NOT EXISTS / DROP POLICY IF EXISTS).
-- 권한: 읽기는 누구나 / 등록·수정·삭제는 로그인한 관리자만(RLS).
-- 예외: comments·inquiries 는 누구나 등록 가능, inquiries 열람은 관리자만.
-- 실행 순서: Authentication > Users 에서 관리자 계정을 먼저 만든 뒤 이 SQL 을 Run.
-- 안 쓰는 카테고리가 있어도 표는 그냥 둬도 무방(빈 표는 아무 영향 없음).
-- 이미지는 "링크" 방식이라 Storage(버킷) 없이도 동작합니다.
-- =============================================================


-- ── 프로필 (메인: id=1 한 칸에 JSON 저장) ──
CREATE TABLE IF NOT EXISTS profile (
  id         BIGINT PRIMARY KEY,
  data       JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE profile ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "profile_all" ON public.profile;
DROP POLICY IF EXISTS "profile_read" ON public.profile;
DROP POLICY IF EXISTS "profile_insert" ON public.profile;
DROP POLICY IF EXISTS "profile_update" ON public.profile;
DROP POLICY IF EXISTS "profile_delete" ON public.profile;
CREATE POLICY "profile_read"   ON public.profile FOR SELECT USING (true);
CREATE POLICY "profile_insert" ON public.profile FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "profile_update" ON public.profile FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "profile_delete" ON public.profile FOR DELETE TO authenticated USING (true);


-- ── 공지 ──
CREATE TABLE IF NOT EXISTS notice (
  id         BIGSERIAL PRIMARY KEY,
  title      TEXT NOT NULL,
  content    TEXT,
  pinned     BOOLEAN DEFAULT FALSE,
  image_url  TEXT,
  images     JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE notice ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE notice ADD COLUMN IF NOT EXISTS images JSONB DEFAULT '[]'::jsonb;
ALTER TABLE notice ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "notice_all" ON public.notice;
DROP POLICY IF EXISTS "notice_read" ON public.notice;
DROP POLICY IF EXISTS "notice_insert" ON public.notice;
DROP POLICY IF EXISTS "notice_update" ON public.notice;
DROP POLICY IF EXISTS "notice_delete" ON public.notice;
CREATE POLICY "notice_read"   ON public.notice FOR SELECT USING (true);
CREATE POLICY "notice_insert" ON public.notice FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "notice_update" ON public.notice FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "notice_delete" ON public.notice FOR DELETE TO authenticated USING (true);


-- ── 일기 ──
CREATE TABLE IF NOT EXISTS diary (
  id         BIGSERIAL PRIMARY KEY,
  title      TEXT NOT NULL,
  content    TEXT,
  mood       TEXT,
  diary_date DATE,
  image_url  TEXT,
  images     JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE diary ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE diary ADD COLUMN IF NOT EXISTS images JSONB DEFAULT '[]'::jsonb;
ALTER TABLE diary ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "diary_all" ON public.diary;
DROP POLICY IF EXISTS "diary_read" ON public.diary;
DROP POLICY IF EXISTS "diary_insert" ON public.diary;
DROP POLICY IF EXISTS "diary_update" ON public.diary;
DROP POLICY IF EXISTS "diary_delete" ON public.diary;
CREATE POLICY "diary_read"   ON public.diary FOR SELECT USING (true);
CREATE POLICY "diary_insert" ON public.diary FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "diary_update" ON public.diary FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "diary_delete" ON public.diary FOR DELETE TO authenticated USING (true);


-- ── 일기 댓글 (일기 페이지에서 사용) ──
CREATE TABLE IF NOT EXISTS comments (
  id         BIGSERIAL PRIMARY KEY,
  diary_id   BIGINT NOT NULL,
  nickname   TEXT,
  message    TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "comments_all" ON public.comments;
DROP POLICY IF EXISTS "comments_read" ON public.comments;
DROP POLICY IF EXISTS "comments_insert" ON public.comments;
DROP POLICY IF EXISTS "comments_update" ON public.comments;
DROP POLICY IF EXISTS "comments_delete" ON public.comments;
CREATE POLICY "comments_read"   ON public.comments FOR SELECT USING (true);
CREATE POLICY "comments_insert" ON public.comments FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "comments_update" ON public.comments FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "comments_delete" ON public.comments FOR DELETE TO authenticated USING (true);


-- ── 일정 (달력) — 색/하이라이트/2부/설명 포함 ──
CREATE TABLE IF NOT EXISTS schedule (
  id          BIGSERIAL PRIMARY KEY,
  title       TEXT NOT NULL,
  date        DATE NOT NULL,
  time        TEXT,
  type        TEXT DEFAULT '일반',          -- 일반 / 특별 / 콜라보 / 휴방
  note        TEXT,
  color       TEXT DEFAULT 'green',
  highlight   BOOLEAN DEFAULT FALSE,
  time2       TEXT,
  title2      TEXT,
  type2       TEXT,
  description TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE schedule ADD COLUMN IF NOT EXISTS color       TEXT DEFAULT 'green';
ALTER TABLE schedule ADD COLUMN IF NOT EXISTS highlight   BOOLEAN DEFAULT FALSE;
ALTER TABLE schedule ADD COLUMN IF NOT EXISTS time2       TEXT;
ALTER TABLE schedule ADD COLUMN IF NOT EXISTS title2      TEXT;
ALTER TABLE schedule ADD COLUMN IF NOT EXISTS type2       TEXT;
ALTER TABLE schedule ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE schedule ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "schedule_all" ON public.schedule;
DROP POLICY IF EXISTS "schedule_read" ON public.schedule;
DROP POLICY IF EXISTS "schedule_insert" ON public.schedule;
DROP POLICY IF EXISTS "schedule_update" ON public.schedule;
DROP POLICY IF EXISTS "schedule_delete" ON public.schedule;
CREATE POLICY "schedule_read"   ON public.schedule FOR SELECT USING (true);
CREATE POLICY "schedule_insert" ON public.schedule FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "schedule_update" ON public.schedule FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "schedule_delete" ON public.schedule FOR DELETE TO authenticated USING (true);


-- ── 노래책: 커버곡 ──
CREATE TABLE IF NOT EXISTS songs (
  id         BIGSERIAL PRIMARY KEY,
  title      TEXT NOT NULL,
  artist     TEXT,
  genre      TEXT DEFAULT '기타',
  difficulty INT  DEFAULT 3,
  memo       TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE songs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "songs_all" ON public.songs;
DROP POLICY IF EXISTS "songs_read" ON public.songs;
DROP POLICY IF EXISTS "songs_insert" ON public.songs;
DROP POLICY IF EXISTS "songs_update" ON public.songs;
DROP POLICY IF EXISTS "songs_delete" ON public.songs;
CREATE POLICY "songs_read"   ON public.songs FOR SELECT USING (true);
CREATE POLICY "songs_insert" ON public.songs FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "songs_update" ON public.songs FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "songs_delete" ON public.songs FOR DELETE TO authenticated USING (true);


-- ── 노래책: 오리지널 곡 (SOOP VOD) ──
CREATE TABLE IF NOT EXISTS original_songs (
  id         BIGSERIAL PRIMARY KEY,
  title      TEXT NOT NULL,
  vod_id     TEXT,
  thumbnail  TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE original_songs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "original_songs_all" ON public.original_songs;
DROP POLICY IF EXISTS "original_songs_read" ON public.original_songs;
DROP POLICY IF EXISTS "original_songs_insert" ON public.original_songs;
DROP POLICY IF EXISTS "original_songs_update" ON public.original_songs;
DROP POLICY IF EXISTS "original_songs_delete" ON public.original_songs;
CREATE POLICY "original_songs_read"   ON public.original_songs FOR SELECT USING (true);
CREATE POLICY "original_songs_insert" ON public.original_songs FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "original_songs_update" ON public.original_songs FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "original_songs_delete" ON public.original_songs FOR DELETE TO authenticated USING (true);


-- ── 옷장 (헤어 / 렌즈 / 의상) — 이미지는 image_url(링크) ──
CREATE TABLE IF NOT EXISTS public.dress_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category    TEXT NOT NULL DEFAULT 'hair',   -- hair / lens / outfit
  name        TEXT NOT NULL,
  description TEXT DEFAULT '',
  image_key   TEXT DEFAULT '',                -- (안 씀) R2용 키
  image_url   TEXT DEFAULT '',                -- 이미지 링크(붙여넣은 주소)
  badges      JSONB DEFAULT '[]',             -- 예: [{"label":"NEW"}]
  is_event    BOOLEAN DEFAULT FALSE,
  glow_color  TEXT DEFAULT '',
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_dress_items_category ON public.dress_items(category);
ALTER TABLE public.dress_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "dress_all" ON public.dress_items;
DROP POLICY IF EXISTS "dress_items_read" ON public.dress_items;
DROP POLICY IF EXISTS "dress_items_insert" ON public.dress_items;
DROP POLICY IF EXISTS "dress_items_update" ON public.dress_items;
DROP POLICY IF EXISTS "dress_items_delete" ON public.dress_items;
CREATE POLICY "dress_items_read"   ON public.dress_items FOR SELECT USING (true);
CREATE POLICY "dress_items_insert" ON public.dress_items FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "dress_items_update" ON public.dress_items FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "dress_items_delete" ON public.dress_items FOR DELETE TO authenticated USING (true);


-- ── 업보: 시청자 ──
CREATE TABLE IF NOT EXISTS viewers (
  id         BIGSERIAL PRIMARY KEY,
  nickname   TEXT NOT NULL,
  soop_id    TEXT,
  memo       TEXT,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE viewers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "viewers_all" ON public.viewers;
DROP POLICY IF EXISTS "viewers_read" ON public.viewers;
DROP POLICY IF EXISTS "viewers_insert" ON public.viewers;
DROP POLICY IF EXISTS "viewers_update" ON public.viewers;
DROP POLICY IF EXISTS "viewers_delete" ON public.viewers;
CREATE POLICY "viewers_read"   ON public.viewers FOR SELECT USING (true);
CREATE POLICY "viewers_insert" ON public.viewers FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "viewers_update" ON public.viewers FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "viewers_delete" ON public.viewers FOR DELETE TO authenticated USING (true);


-- ── 업보: 타입(종류) ──
CREATE TABLE IF NOT EXISTS upbo_types (
  id         BIGSERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  category   TEXT DEFAULT '일반',            -- 일반 / 이벤트
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE upbo_types ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "upbo_types_all" ON public.upbo_types;
DROP POLICY IF EXISTS "upbo_types_read" ON public.upbo_types;
DROP POLICY IF EXISTS "upbo_types_insert" ON public.upbo_types;
DROP POLICY IF EXISTS "upbo_types_update" ON public.upbo_types;
DROP POLICY IF EXISTS "upbo_types_delete" ON public.upbo_types;
CREATE POLICY "upbo_types_read"   ON public.upbo_types FOR SELECT USING (true);
CREATE POLICY "upbo_types_insert" ON public.upbo_types FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "upbo_types_update" ON public.upbo_types FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "upbo_types_delete" ON public.upbo_types FOR DELETE TO authenticated USING (true);


-- ── 업보: 카운트 (시청자 × 타입 = 횟수) ──
CREATE TABLE IF NOT EXISTS upbo_counts (
  id         BIGSERIAL PRIMARY KEY,
  viewer_id  BIGINT NOT NULL,
  type_id    BIGINT NOT NULL,
  count      INT DEFAULT 0,
  memo       TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (viewer_id, type_id)
);
ALTER TABLE upbo_counts ADD COLUMN IF NOT EXISTS memo TEXT;
ALTER TABLE upbo_counts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "upbo_counts_all" ON public.upbo_counts;
DROP POLICY IF EXISTS "upbo_counts_read" ON public.upbo_counts;
DROP POLICY IF EXISTS "upbo_counts_insert" ON public.upbo_counts;
DROP POLICY IF EXISTS "upbo_counts_update" ON public.upbo_counts;
DROP POLICY IF EXISTS "upbo_counts_delete" ON public.upbo_counts;
CREATE POLICY "upbo_counts_read"   ON public.upbo_counts FOR SELECT USING (true);
CREATE POLICY "upbo_counts_insert" ON public.upbo_counts FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "upbo_counts_update" ON public.upbo_counts FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "upbo_counts_delete" ON public.upbo_counts FOR DELETE TO authenticated USING (true);


-- ── 문의함 ──
CREATE TABLE IF NOT EXISTS inquiries (
  id         BIGSERIAL PRIMARY KEY,
  nickname   TEXT,
  message    TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE inquiries ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "inquiries_all" ON public.inquiries;
DROP POLICY IF EXISTS "inquiries_read" ON public.inquiries;
DROP POLICY IF EXISTS "inquiries_insert" ON public.inquiries;
DROP POLICY IF EXISTS "inquiries_update" ON public.inquiries;
DROP POLICY IF EXISTS "inquiries_delete" ON public.inquiries;
CREATE POLICY "inquiries_read"   ON public.inquiries FOR SELECT TO authenticated USING (true);
CREATE POLICY "inquiries_insert" ON public.inquiries FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "inquiries_update" ON public.inquiries FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "inquiries_delete" ON public.inquiries FOR DELETE TO authenticated USING (true);


-- ── (옷장 OBS 오버레이 쓸 때만) "지금 트는 노래" 상태 1행 ──
CREATE TABLE IF NOT EXISTS public.overlay_state (
  id          INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  song_title  TEXT DEFAULT '',
  song_artist TEXT DEFAULT '',
  is_visible  BOOLEAN DEFAULT FALSE,          -- ⚠️ OBS에 보이려면 true
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
INSERT INTO public.overlay_state (id) VALUES (1) ON CONFLICT (id) DO NOTHING;
ALTER TABLE public.overlay_state ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "overlay_all" ON public.overlay_state;
DROP POLICY IF EXISTS "overlay_state_read" ON public.overlay_state;
DROP POLICY IF EXISTS "overlay_state_insert" ON public.overlay_state;
DROP POLICY IF EXISTS "overlay_state_update" ON public.overlay_state;
DROP POLICY IF EXISTS "overlay_state_delete" ON public.overlay_state;
CREATE POLICY "overlay_state_read"   ON public.overlay_state FOR SELECT USING (true);
CREATE POLICY "overlay_state_insert" ON public.overlay_state FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "overlay_state_update" ON public.overlay_state FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "overlay_state_delete" ON public.overlay_state FOR DELETE TO authenticated USING (true);


-- ── 프로필 기본 행(id=1) 보장 ──
-- ⚠️ 한 Supabase 프로젝트는 "한 사람"에게만 쓰세요.
--    이미 다른 사람 데이터가 들어있는 프로젝트를 재사용하면, 아래 INSERT는
--    DO NOTHING 때문에 옛 데이터를 덮어쓰지 않습니다(= 프사·이름이 옛 사람으로 보임).
--    새 사람으로 갈아끼울 땐, 아래 줄의 맨 앞 '--' 를 지워서 한 번 실행하면 프로필이 비워집니다.
-- DELETE FROM profile WHERE id = 1;
INSERT INTO profile (id, data) VALUES (1, '{"avatar": "", "soop-id": "ad8hv5jk7d6", "head-sub": "안녕! 목소리 1티어 송민트야 💚\n오늘도 민트빛 하루 되세요 ⊹₊⟡", "quote": "· \"야르하게 부탁드립니다 💚\"", "msg": "· 인디 · 포크 감성으로 조곤조곤 불러요 🎵", "info-name": "송민트", "info-mbti": "E쁨", "info-fandom": "애플", "info-debut": "2026.01.03", "info-birth": "6.26", "main-art": "", "main-story": "\"목소리 1티어\"\n개인 소속 · 여 · 버추얼 스트리머 | 팬 애칭 애플 🍏", "like1": "너 💚", "like2": "인디 · 포크", "like3": "아이유 · 볼빨간사춘기", "like4": "풋사과 🍏", "dislike1": "밤티", "dislike2": "팝송 (영어 못함 이슈)", "dislike3": "많음…", "tmi-food": "사과 🍏", "tmi-song": "아이유 · 볼빨간사춘기", "tmi-book": "인디 · 포크", "days": "0,1,3,4,5,6", "diary-sub": "송민트의 방송 일기에요", "link-soop": "https://www.sooplive.com/station/ad8hv5jk7d6", "link-cafe": "https://cafe.naver.com/applemintfarm", "link-fancim": "https://fancim.me/mypage/myfancim.aspx", "profile-art": "", "img-apple": "", "img-apple-half": "", "img-heart-p": "", "img-heart-m": "", "img-apple-note": "", "upbo-hide-zero": "on"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- 끝! 이미지는 전부 "링크" 방식이라 Storage 설정이 필요 없습니다.
