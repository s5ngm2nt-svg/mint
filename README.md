# MINT OFFICIAL

송민트 팬사이트. 정적 사이트(HTML/CSS/JS) + Supabase + Cloudflare Pages.

## 폴더

```
index.html  style.css  supabase.js  fx.js  assets.js  icons.js
admin/      관리자
overlay/    OBS "지금 트는 노래"
profile/ notice/ schedule/ work/ diary/ song/ dress/ game/
*.sql       Supabase 셋업 / 이관 / 패치
```

## 배포 순서

1. **Supabase → Authentication → Users → Add user**
   관리자 이메일·비밀번호 생성. **Auto Confirm User 켜기.**
2. **Supabase → SQL Editor**
   - 신규 프로젝트: `supabase_all.sql` → `2_data_migrate.sql`
   - 운영 중인 프로젝트: `3_security_patch.sql` 만 Run
3. `supabase.js` 상단 두 줄(프로젝트 URL · anon 키) 확인
4. GitHub 에 폴더 구조 그대로 push → Cloudflare Pages 자동 배포
5. 새로고침은 `Ctrl+Shift+R`

**순서 주의** — 계정을 만들기 전에 SQL 을 먼저 Run 하면
쓰기 권한이 `authenticated` 로 잠겨 본인도 관리자에서 저장할 수 없다.

## 관리자 로그인

- 코드에 비밀번호를 넣지 않는다. 로그인은 Supabase Auth (`signInWithPassword`).
- 계정 추가·비밀번호 변경·삭제는 전부 Supabase → Authentication → Users.
- 세션은 Supabase 가 보관하므로 새로고침해도 유지된다. 우측 상단 로그아웃 버튼.

## 접근 권한 (RLS)

| 동작 | 누가 |
|---|---|
| 읽기 | 누구나 |
| 등록·수정·삭제 | 로그인한 관리자만 |
| `comments` · `inquiries` 등록 | 누구나 |
| `inquiries` 열람 | 관리자만 |

## 업보 페이지

- 업보 0개인 시청자는 기본으로 숨겨진다.
  전부 보이려면 관리자 → 업보 탭 → "업보 페이지 설정" → 전부 보이기.
- 업보 메모는 `upbo_counts.memo` 컬럼이 있어야 저장된다 (`3_security_patch.sql`).

## SOOP 게시글 삽입

```html
<iframe height="2400" scrolling="no" src="배포주소" style="width:100%;border:0;display:block;"></iframe>
```
