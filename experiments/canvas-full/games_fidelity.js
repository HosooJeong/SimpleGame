"use strict";
// The original green signal includes a continuously shrinking white ring.
GAMES.fake_signal=({root,finish,s,t,fx,h})=>{
 let phase="gap",fake=false,streak=0,greenRun=0,timer,started=0,duration=0,reason="",failedInGap=false;
 const title=h("div",{class:"display"}),hint=h("p",{class:"hint"}),center=h("div",{class:"play-center"}),button=h("div",{style:{width:"170px",height:"170px",borderRadius:"50%",border:"3px solid #b2986e66",position:"relative"}}),ring=h("canvas",{style:{width:"170px",height:"170px",position:"absolute",top:"0",left:"0"}});
 center.append(button);root.append(title,hint,center);const ratio=window.devicePixelRatio||1;ring.width=170*ratio;ring.height=170*ratio;const ctx=ring.getContext("2d");ctx.scale(ratio,ratio);
 function update(){title.textContent=t("countItems",{count:streak});hint.textContent=phase==="dead"?reason:phase==="gap"?t("fakeSignalWait"):fake?t("fakeSignalHold"):t("fakeSignalTap");button.style.background=phase==="gap"||failedInGap?"transparent":fake?"#ff4b4b":"#58cc02";button.style.border=phase==="gap"||failedInGap?"3px solid #b2986e66":"0";button.replaceChildren();if(phase==="signal"&&!fake)button.append(ring);if(phase==="dead")button.append(h("div",{style:{position:"absolute",inset:"0",display:"grid",placeItems:"center",fontSize:"72px",color:failedInGap?"#ff4b4b":"white"},text:"×"}));}
 function schedule(){phase="gap";update();timer=s.later(signal,350+rnd(400));}
 function signal(){fake=greenRun>=3||Math.random()<.35;phase="signal";duration=Math.max(400,Math.round(850-65*Math.sqrt(2*streak)));started=performance.now();update();if(!fake)s.frame(paint);timer=s.later(()=>{if(fake){greenRun=0;fx("tick");pass();}else fail(t("fakeSignalMissed"));},fake?Math.max(400,duration-100):duration);}
 function paint(now){if(phase!=="signal"||fake)return;const left=Math.max(0,1-(now-started)/duration);ctx.clearRect(0,0,170,170);ctx.beginPath();ctx.arc(85,85,74,-Math.PI/2,-Math.PI/2+2*Math.PI*left);ctx.strokeStyle="#ffffffe6";ctx.lineWidth=7;ctx.lineCap="round";ctx.stroke();s.frame(paint);}
 function pass(){clearTimeout(timer);streak++;if(streak>=200){finish(200);return;}schedule();}
 function fail(why){if(phase==="dead")return;clearTimeout(timer);failedInGap=phase==="gap";phase="dead";reason=why;fx("fail");update();s.later(()=>finish(streak),1400);}
 center.addEventListener("pointerdown",()=>{if(phase==="gap")fail(t("fakeSignalTooSoon"));else if(phase==="signal"){if(fake)fail(t("fakeSignalBaited"));else{fx("light");greenRun++;pass();}}});schedule();
};
