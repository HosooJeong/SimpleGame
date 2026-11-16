"use strict";
const games=[
  ["반응속도","#ff4b4b","● ➜ ●"],["숫자 순서","#1cb0f6","▦"],["탭 스피드","#ffc800","◎"],["타이밍 스톱","#a560e8","──●──"],
  ["순서 기억","#58cc02","✚"],["정확한 10초","#ff9600","?.??"],["다른 색 찾기","#f65ca8","▦"],["색깔 함정","#6979f8","O ×"],
  ["순간 기억","#00c2b2","▦"],["반반 자르기","#a6c700","◧"],["완벽한 원","#00b7e4","◯"],["셔플 추적","#d34fd4","★"],
  ["순간 셈","#00c46a","•••"],["가짜 신호","#ff6b3b","●"]
];
const byId=id=>document.getElementById(id), screens=["home","intro","countdown","play","result"];
const canvas=byId("game-canvas"),ctx=canvas.getContext("2d");
let phase="home",round=1,total=0,position=0,roundStart=0,animation=0,timers=[],roundPoints=null,best=null;
try{const v=localStorage.getItem("canvas-timing-best");best=v===null?null:Number(v);}catch(_){}
function blend(hex,amount){let n=parseInt(hex.slice(1),16),r=n>>16,g=n>>8&255,b=n&255;const f=v=>Math.round(v+(amount>0?255-v:v)*amount);return `rgb(${f(r)} ${f(g)} ${f(b)})`;}
function buildHome(){
  const grid=byId("grid");grid.replaceChildren();
  games.forEach(([name,color,icon],i)=>{const button=document.createElement("button");button.className="tile";button.disabled=i!==3;
    button.style.setProperty("--color",color);button.style.setProperty("--top",blend(color,.12));button.style.setProperty("--bottom",blend(color,-.12));button.style.setProperty("--shadow",color+"59");
    const preview=document.createElement("span");preview.className="preview";preview.textContent=icon;
    const title=document.createElement("span");title.className="title";title.textContent=name;
    const badge=document.createElement("span");badge.className="badge";badge.textContent=i===3&&best!==null?`최고 ${best}점`:"NEW";
    button.append(preview,title,badge);if(i===3)button.addEventListener("click",openIntro);grid.append(button);
  });
}
function later(fn,ms){timers.push(setTimeout(fn,ms));}
function cancelWork(){cancelAnimationFrame(animation);timers.forEach(clearTimeout);timers=[];}
function show(next){cancelWork();phase=next;screens.forEach(id=>byId(id).hidden=id!==next);window.scrollTo(0,0);}
function openHome(){show("home");buildHome();}
function openIntro(){show("intro");byId("intro-best").textContent=best===null?"아직 아무도 도전하지 않았다":`최고 ${best}점`;}
function start(){round=1;total=0;show("countdown");const el=byId("count-value");el.textContent="3";later(()=>el.textContent="2",800);later(()=>el.textContent="1",1600);later(()=>el.textContent="시작!",2400);later(startRound,2850);}
function sizeCanvas(){const rect=canvas.getBoundingClientRect(),dpr=window.devicePixelRatio||1;const w=Math.round(rect.width*dpr),h=Math.round(rect.height*dpr);if(canvas.width!==w||canvas.height!==h){canvas.width=w;canvas.height=h;}ctx.setTransform(dpr,0,0,dpr,0,0);return {width:rect.width,height:rect.height};}
function draw(value){const {width:w,height:h}=sizeCanvas();ctx.clearRect(0,0,w,h);ctx.lineCap="round";ctx.lineWidth=10;ctx.strokeStyle="#fff";ctx.beginPath();ctx.moveTo(5,h/2);ctx.lineTo(w-5,h/2);ctx.stroke();ctx.lineWidth=4;ctx.strokeStyle="#58cc02";ctx.beginPath();ctx.moveTo(w/2,h/2-20);ctx.lineTo(w/2,h/2+20);ctx.stroke();ctx.fillStyle="#a560e8";ctx.beginPath();ctx.arc(14+value*(w-28),h/2,14,0,Math.PI*2);ctx.fill();}
function tick(now){if(phase!=="play"||roundPoints!==null)return;const duration=Math.round(1100*Math.pow(.85,round-1));const t=((now-roundStart)/duration)%2;position=t<=1?t:2-t;draw(position);animation=requestAnimationFrame(tick);}
function startRound(){show("play");roundPoints=null;position=0;byId("round-label").textContent=`라운드 ${round} / 5  ·  ${total}점`;const message=byId("game-message");message.className="";message.textContent="정중앙에서 터치!";draw(0);roundStart=performance.now();animation=requestAnimationFrame(tick);}
function stopRound(){if(phase!=="play"||roundPoints!==null)return;cancelAnimationFrame(animation);const distance=Math.min(1,Math.abs(position-.5)*2);roundPoints=Math.round((1-distance)*(1-distance)*100);total+=roundPoints;const message=byId("game-message");message.className="points";message.textContent=`${roundPoints}점!`;later(()=>{if(round===5){finish();return;}round++;startRound();},900);}
function finish(){show("result");const isBest=best===null||total>best;if(isBest){best=total;try{localStorage.setItem("canvas-timing-best",String(best));}catch(_){}}byId("score").textContent=`${total}점`;byId("best").textContent=isBest?"★ 신기록!":`최고 ${best}점`;}
document.querySelectorAll(".back").forEach(button=>button.addEventListener("click",()=>phase==="play"?openIntro():openHome()));
byId("start").addEventListener("click",start);byId("retry").addEventListener("click",start);byId("home-button").addEventListener("click",openHome);
byId("tap-area").addEventListener("pointerdown",stopRound);window.addEventListener("resize",()=>{if(phase==="play")draw(position);});
buildHome();
