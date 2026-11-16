"use strict";
function makePreview(g){
 const ratio=window.devicePixelRatio||1,outer=h("span",{class:"tile-preview"}),c=h("canvas",{width:String(Math.round(110*ratio)),height:String(Math.round(70*ratio)),style:{width:"110px",height:"70px",touchAction:"auto"}}),x=c.getContext("2d");outer.append(c);x.scale(ratio,ratio);
 const rect=(a,b,w,hh,r,fill)=>{x.fillStyle=fill;x.beginPath();x.roundRect(a,b,w,hh,r);x.fill();},circle=(a,b,r,fill)=>{x.fillStyle=fill;x.beginPath();x.arc(a,b,r,0,2*Math.PI);x.fill();},text=(v,a,b,size=12,color="white",family="Jua")=>{x.fillStyle=color;x.font=size+"px "+family;x.textAlign="center";x.textBaseline="middle";x.fillText(v,a,b);},strokeCircle=(a,b,r,color,width=3)=>{x.beginPath();x.arc(a,b,r,0,2*Math.PI);x.strokeStyle=color;x.lineWidth=width;x.stroke();};
 function paint(){x.clearRect(0,0,110,70);switch(g.id){
 case "reaction":rect(6,18,34,34,10,"#ffffff59");text("➜",55,35,20);rect(70,18,34,34,10,"white");rect(72,20,30,30,8,"#58cc02");circle(87,35,5,"white");break;
 case "number_grid":case "odd_tile":for(let i=0;i<9;i++){let a=24+(i%3)*22,b=4+Math.floor(i/3)*22;rect(a,b,19,19,5,g.id==="number_grid"?(i<3?"white":"#ffffff59"):(i===5?"#ffffff73":"#fffffff2"));if(g.id==="number_grid"&&i<3)text(String(i+1),a+9.5,b+10,11,g.color,"Pretendard");}break;
 case "tap_speed":strokeCircle(55,35,28,"#ffffff66",2.5);strokeCircle(55,35,19,"#ffffffb3",2.5);circle(55,35,9,"white");break;
 case "timing_bar":rect(0,31.5,110,7,4,"#ffffff59");rect(53,23,4,24,2,"white");circle(80,35,7.5,"white");break;
 case "memory":rect(46,6,18,18,5,"white");rect(26,26,18,18,5,"#ffffff59");rect(66,26,18,18,5,"#ffffff59");rect(46,46,18,18,5,"#ffffff59");break;
 case "timer_ten":text("◉̸",30,35,22);text("?.??",72,35,26,"white","BlackHan");break;
 case "stroop":rect(27,8,56,26,9,"white");text(t("colorRed"),55,21,17,"#1cb0f6");circle(40,53,11,"#ffffff66");circle(70,53,11,"#ffffff66");text("O",40,53,12);text("X",70,53,12);break;
 case "chimp":for(let i=0;i<6;i++){let a=21+(i%3)*24,b=14+Math.floor(i/3)*24;rect(a,b,20,20,5,i===0?"white":i===1||i===4?"#ffffff40":"#ffffff8c");if(i===0)text("1",a+10,b+10,12,g.color,"Pretendard");}break;
 case "half_cut":x.beginPath();x.moveTo(13,59);[.45,.7,.55,.85,.6,.75,.4,.65,.5].forEach((v,i)=>x.lineTo(13+i*10.5,59-48*v));x.lineTo(97,59);x.closePath();x.fillStyle="#ffffff80";x.fill();x.save();x.clip();x.fillStyle="white";x.fillRect(13,0,42,70);x.restore();rect(53.5,11,3,48,1.5,"white");break;
 case "circle_draw":x.beginPath();for(let i=0;i<=40;i++){const a=-Math.PI/2+.35+(2*Math.PI-.7)*i/40,r=24.36*(1+.07*Math.sin(a*3+1)),px=55+Math.cos(a)*r,py=35+Math.sin(a)*r;i?x.lineTo(px,py):x.moveTo(px,py);}x.strokeStyle="white";x.lineWidth=3.5;x.lineCap="round";x.stroke();circle(48,10,4,"white");break;
 case "shuffle_track":for(let i=0;i<3;i++)rect(13+i*30,15,24,24,7,i===1?"white":"#ffffff59");text("★",55,27,16,g.color);text("↔",55,51,20);break;
 case "flash_count":[[24,12],[48,6],[70,16],[32,34],[56,30]].forEach(p=>circle(p[0],p[1],5.5,"white"));text("?",80,52,24,"white","BlackHan");break;
 case "fake_signal":circle(35,35,15,"white");circle(35,35,13,"#58cc02");circle(75,35,15,"white");circle(75,35,13,"#ff4b4b");text("×",75,35,23);break;
 }}paint();if(document.fonts)document.fonts.ready.then(()=>{if(c.isConnected)paint();});return outer;
}
