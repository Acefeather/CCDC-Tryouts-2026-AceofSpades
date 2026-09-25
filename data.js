
function key(name){ return `ccdc:data:${name}`; }
function load(name){ try{return JSON.parse(localStorage.getItem(key(name))||"[]")}catch(e){return []} }
function save(name,data){ localStorage.setItem(key(name),JSON.stringify(data)); }
function esc(s){return String(s??"").replace(/[&<>"']/g,m=>({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#039;"}[m]));}
