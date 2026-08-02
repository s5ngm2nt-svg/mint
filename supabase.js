/* Replace the two lines below when moving to a new Supabase project. */

const SUPABASE_URL  = 'https://jkhwspwflodlttezhqbx.supabase.co';
const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpraHdzcHdmbG9kbHR0ZXpocWJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQwMzg0MDAsImV4cCI6MjA5OTYxNDQwMH0.RFz-P_MTHYJk-9Kf4r-daHDt5pc40MN7JlrP8fInS_Q';

const { createClient } = supabase;
const db = createClient(SUPABASE_URL, SUPABASE_ANON);

/* fetchAll('schedule', { order:'date', asc:true }) */
async function fetchAll(table, options = {}) {
  let query = db.from(table).select('*');
  if (options.order)  query = query.order(options.order, { ascending: options.asc ?? false });
  if (options.limit)  query = query.limit(options.limit);
  if (options.filter) query = query.eq(options.filter.col, options.filter.val);
  const { data, error } = await query;
  if (error) { console.error(`fetchAll(${table})`, error); return []; }
  return data;
}

/* Returns false on failure; the raw error is kept in window.lastDbError. */
async function insertRow(table, row) {
  const { error } = await db.from(table).insert(row);
  window.lastDbError = error || null;
  if (error) { console.error(`insertRow(${table})`, error); return false; }
  return true;
}

async function deleteRow(table, id) {
  const { error } = await db.from(table).delete().eq('id', id);
  window.lastDbError = error || null;
  if (error) { console.error(`deleteRow(${table})`, error); return false; }
  return true;
}

async function updateRow(table, id, updates) {
  const { error } = await db.from(table).update(updates).eq('id', id);
  window.lastDbError = error || null;
  if (error) { console.error(`updateRow(${table})`, error); return false; }
  return true;
}

/* GIF is returned untouched; compressing it would freeze the animation. */
async function compressImage(file, maxW = 1200, quality = 0.8) {
  if (file.type === 'image/gif') return file;
  try {
    const img = await new Promise((res, rej) => {
      const i = new Image();
      i.onload = () => res(i);
      i.onerror = rej;
      i.src = URL.createObjectURL(file);
    });
    const scale = Math.min(1, maxW / img.width);
    const w = Math.round(img.width * scale);
    const h = Math.round(img.height * scale);
    const canvas = document.createElement('canvas');
    canvas.width = w; canvas.height = h;
    canvas.getContext('2d').drawImage(img, 0, 0, w, h);
    URL.revokeObjectURL(img.src);
    const blob = await new Promise(res => canvas.toBlob(res, 'image/jpeg', quality));
    return blob || file;
  } catch (e) {
    console.error('compressImage', e);
    return file;
  }
}

async function uploadImage(file, folder = 'uploads') {
  try {
    const blob = await compressImage(file);
    const rand = Math.random().toString(36).slice(2, 8);
    const path = `${folder}/${Date.now()}_${rand}.jpg`;
    const { error } = await db.storage.from('images').upload(path, blob, {
      upsert: true, contentType: 'image/jpeg'
    });
    if (error) { console.error('uploadImage', error); return null; }
    const { data } = db.storage.from('images').getPublicUrl(path);
    return data?.publicUrl || null;
  } catch (e) {
    console.error('uploadImage', e);
    return null;
  }
}

function showToast(msg, duration = 2500) {
  let t = document.getElementById('toast');
  if (!t) {
    t = document.createElement('div');
    t.id = 'toast'; t.className = 'toast';
    document.body.appendChild(t);
  }
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), duration);
}

function initIframeResize() {
  const send = () =>
    window.parent.postMessage({ type: 'resize', height: document.body.scrollHeight }, '*');
  send();
  new ResizeObserver(send).observe(document.body);
}

/* Alias: category pages call enableIframeAutoHeight(). */
function enableIframeAutoHeight() { initIframeResize(); }
