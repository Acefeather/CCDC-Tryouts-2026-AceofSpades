
function storageKey(page, id){ return `ccdc:${page}:${id}`; }

function currentStatus(task){
  if(task.classList.contains("done")) return "done";
  if(task.classList.contains("almost")) return "almost";
  if(task.classList.contains("return")) return "return";
  return "";
}

function setStatus(task, status){
  task.classList.remove("done","almost","return");
  if(status) task.classList.add(status);
  localStorage.setItem(storageKey(document.body.dataset.page, task.dataset.id), status || "");
  updateProgress();
}

function toggleStatus(task, status){
  setStatus(task, currentStatus(task) === status ? "" : status);
}

function updateProgress(){
  const tasks=[...document.querySelectorAll(".task")];
  const done=tasks.filter(t=>t.classList.contains("done")).length;
  const almost=tasks.filter(t=>t.classList.contains("almost")).length;
  const ret=tasks.filter(t=>t.classList.contains("return")).length;
  const total=tasks.length;
  const pct=total?Math.round((done/total)*100):0;
  const bar=document.querySelector(".progress > div");
  const label=document.querySelector(".progress-label");
  if(bar) bar.style.width=pct+"%";
  if(label) label.textContent=`${done}/${total} done • ${almost} almost done • ${ret} return to complete`;
}

document.addEventListener("DOMContentLoaded",()=>{
  document.querySelectorAll(".task").forEach(task=>{
    const saved=localStorage.getItem(storageKey(document.body.dataset.page, task.dataset.id));
    if(saved) task.classList.add(saved);

    task.querySelector(".done-btn").onclick=()=>toggleStatus(task,"done");
    task.querySelector(".almost-btn").onclick=()=>toggleStatus(task,"almost");
    task.querySelector(".return-btn").onclick=()=>toggleStatus(task,"return");
  });

  const reset=document.querySelector("#reset");
  if(reset) reset.onclick=()=>{
    if(confirm("Reset all task statuses on this page?")){
      document.querySelectorAll(".task").forEach(task=>setStatus(task,""));
    }
  };
  updateProgress();
});
