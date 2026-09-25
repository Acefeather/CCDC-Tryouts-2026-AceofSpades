
function copyText(id, btn){
  const text=document.getElementById(id).innerText;
  navigator.clipboard.writeText(text).then(()=>{
    const old=btn.innerText; btn.innerText="Copied";
    setTimeout(()=>btn.innerText=old,1000);
  });
}
