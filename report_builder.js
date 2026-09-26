
function el(id){ return document.getElementById(id); }
function safe(v){ return (v || "").trim(); }
function textOrBlank(v){ return safe(v) || " "; }
function escapeHTML(s){ return String(s || "").replace(/[&<>"']/g,m=>({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#039;"}[m])); }
function nl(s){ return escapeHTML(s).replace(/\n/g,"<br>"); }

function addScreenshotRow(){
  const wrap=document.createElement("div");
  wrap.className="shot-row";
  wrap.innerHTML=`
    <div class="grid">
      <div class="field"><label>Screenshot</label><input type="file" accept="image/*" class="shot-file"></div>
      <div class="field"><label>Caption</label><input type="text" class="shot-caption" placeholder="Describe what this screenshot shows"></div>
    </div>
    <img class="shot-preview" style="display:none">
    <button type="button" class="btn danger remove-shot">Remove screenshot</button>`;
  el("screenshots").appendChild(wrap);

  const fileInput=wrap.querySelector(".shot-file");
  const preview=wrap.querySelector(".shot-preview");
  fileInput.addEventListener("change",()=>{
    const file=fileInput.files&&fileInput.files[0];
    if(!file) return;
    const reader=new FileReader();
    reader.onload=e=>{
      wrap.dataset.image=e.target.result;
      preview.src=e.target.result;
      preview.style.display="block";
      buildPreview();
    };
    reader.readAsDataURL(file);
  });
  wrap.querySelector(".shot-caption").addEventListener("input",buildPreview);
  wrap.querySelector(".remove-shot").onclick=()=>{wrap.remove();buildPreview();};
}
function getScreenshots(){
  return [...document.querySelectorAll(".shot-row")].map(r=>({
    image:r.dataset.image||"",
    caption:r.querySelector(".shot-caption").value||""
  })).filter(x=>x.image);
}
function screenshotHTML(){
  return getScreenshots().map((s,i)=>`
    <div class="figure">
      <img src="${s.image}" alt="Evidence ${i+1}">
      <div class="caption">Figure ${i+1}: ${escapeHTML(s.caption)}</div>
    </div>`).join("");
}
function printPDF(){ buildPreview(); setTimeout(()=>window.print(),100); }
function wireInputs(){ document.querySelectorAll("input:not([type=file]),textarea,select").forEach(x=>x.addEventListener("input",buildPreview)); }
function clearForm(){
  if(!confirm("Clear all fields and screenshots?")) return;
  document.querySelectorAll("input:not([type=file]),textarea").forEach(x=>x.value="");
  document.querySelectorAll("select").forEach(x=>x.selectedIndex=0);
  el("screenshots").innerHTML="";
  if(typeof resetRequirements==="function") resetRequirements();
  addScreenshotRow();
  buildPreview();
}
