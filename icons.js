/* 🍏 💚 💜 이모지 → 이미지 아이콘 치환 (DB엔 이모지 그대로) */
(function(){
  function MAPNOW(){
    var I = window.MINT_IMG || {};
    var ROOT = (window.ICON_ROOT !== undefined) ? window.ICON_ROOT : '../';
    return {
      '\uD83C\uDF4F': I.apple  || ROOT+'apple.png',
      '\uD83D\uDC9A': I.heartM || ROOT+'heart-mint.png',
      '\uD83D\uDC9C': I.heartP || ROOT+'heart-purple.png'
    };
  }
  var SKIP = { SCRIPT:1, STYLE:1, INPUT:1, TEXTAREA:1, CANVAS:1 };

  function iconize(root){
    if(!root) return;
    var MAP = MAPNOW();
    var walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
      acceptNode: function(n){
        if(!n.nodeValue) return NodeFilter.FILTER_REJECT;
        var p = n.parentNode;
        if(!p || SKIP[p.nodeName]) return NodeFilter.FILTER_REJECT;
        if(p.classList && p.classList.contains('e-ico')) return NodeFilter.FILTER_REJECT;
        return /\uD83C\uDF4F|\uD83D\uDC9A|\uD83D\uDC9C/.test(n.nodeValue)
          ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_REJECT;
      }
    });
    var nodes=[], n;
    while((n = walker.nextNode())) nodes.push(n);
    nodes.forEach(function(node){
      var txt=node.nodeValue, frag=document.createDocumentFragment(), last=0, m;
      var re=/\uD83C\uDF4F|\uD83D\uDC9A|\uD83D\uDC9C/g;
      while((m=re.exec(txt))){
        if(m.index>last) frag.appendChild(document.createTextNode(txt.slice(last,m.index)));
        var i=document.createElement('span');
        i.className='e-ico';
        i.setAttribute('data-emo', m[0]);
        i.style.backgroundImage="url('"+MAP[m[0]]+"')";
        i.setAttribute('aria-hidden','true');
        frag.appendChild(i);
        last=m.index+m[0].length;
      }
      if(last<txt.length) frag.appendChild(document.createTextNode(txt.slice(last)));
      node.parentNode.replaceChild(frag,node);
    });
  }
  function refreshIcons(){
    var MAP = MAPNOW();
    var order = ['\uD83C\uDF4F','\uD83D\uDC9A','\uD83D\uDC9C'];
    document.querySelectorAll('.e-ico[data-emo]').forEach(function(el){
      var u = MAP[el.getAttribute('data-emo')];
      if(u) el.style.backgroundImage = "url('"+u+"')";
    });
  }
  if(window.onMintImages) window.onMintImages(refreshIcons);
  else (window.__mintPending = window.__mintPending || []).push(refreshIcons);
  window.iconizeEmoji = iconize;
  function run(){ iconize(document.body); }
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', run); else run();
  /* DB 렌더 후에도 반영 */
  var mo = new MutationObserver(function(muts){
    var hit=false;
    muts.forEach(function(m){ if(m.addedNodes && m.addedNodes.length) hit=true; });
    if(hit){ mo.disconnect(); iconize(document.body); mo.observe(document.body,{childList:true,subtree:true}); }
  });
  if(document.body) mo.observe(document.body,{childList:true,subtree:true});
})();
