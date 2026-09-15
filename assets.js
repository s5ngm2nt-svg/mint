/* 송민트 · 테마 이미지 로더
   admin에서 URL을 넣으면 그 이미지로, 비우면 기본 파일로.
   (사과 · 반쪽사과 · 보라하트 · 민트하트 · D-day 사과노트)
   */
(function () {
  var ROOT = (window.ASSET_ROOT !== undefined) ? window.ASSET_ROOT : '../';

  /* 기본값 (레포에 동봉된 파일) */
  var DEFAULTS = {
    apple:     ROOT + 'apple.png',
    appleHalf: ROOT + 'apple-half.png',
    heartP:    ROOT + 'heart-purple.png',
    heartM:    ROOT + 'heart-mint.png',
    appleNote: ROOT + 'apple-note.png'
  };

  /* DB 키 ↔ 내부 이름 */
  var KEYMAP = {
    'img-apple':      'apple',
    'img-apple-half': 'appleHalf',
    'img-heart-p':    'heartP',
    'img-heart-m':    'heartM',
    'img-apple-note': 'appleNote'
  };

  var CACHE_KEY = 'mint_imgs';

  /* 즉시 사용 가능한 값 (캐시 → 기본값) */
  window.MINT_IMG = {};
  for (var k in DEFAULTS) window.MINT_IMG[k] = DEFAULTS[k];
  try {
    var cached = JSON.parse(localStorage.getItem(CACHE_KEY) || '{}');
    for (var c in cached) if (cached[c]) window.MINT_IMG[c] = cached[c];
  } catch (e) {}

  /* CSS 변수로도 노출 (D-day 사과노트 등 CSS에서 씀) */
  function applyVars() {
    var r = document.documentElement.style;
    r.setProperty('--img-apple',      "url('" + window.MINT_IMG.apple + "')");
    r.setProperty('--img-apple-half', "url('" + window.MINT_IMG.appleHalf + "')");
    r.setProperty('--img-heart-p',    "url('" + window.MINT_IMG.heartP + "')");
    r.setProperty('--img-heart-m',    "url('" + window.MINT_IMG.heartM + "')");
    r.setProperty('--img-apple-note', "url('" + window.MINT_IMG.appleNote + "')");
  }
  applyVars();

  /* 이미지가 바뀌면 다시 그려야 하는 것들이 등록 */
  var listeners = (window.__mintPending || []).slice();
  window.__mintPending = null;
  window.onMintImages = function (fn) { listeners.push(fn); fn(); };
  listeners.forEach(function (fn) { try { fn(); } catch (e) {} });

  function refresh() {
    applyVars();
    listeners.forEach(function (fn) { try { fn(); } catch (e) {} });
  }

  /* DB에서 실제 값 가져오기 */
  (async function () {
    if (typeof fetchAll !== 'function') return;
    try {
      var rows = await fetchAll('profile');
      var d = (rows && rows[0] && rows[0].data) ? rows[0].data : null;
      if (!d) return;
      var changed = false, store = {};
      for (var key in KEYMAP) {
        var name = KEYMAP[key];
        var url = (d[key] || '').trim();
        var val = url || DEFAULTS[name];
        store[name] = url || '';
        if (window.MINT_IMG[name] !== val) { window.MINT_IMG[name] = val; changed = true; }
      }
      try { localStorage.setItem(CACHE_KEY, JSON.stringify(store)); } catch (e) {}
      if (changed) refresh();
    } catch (e) {}
  })();
})();
