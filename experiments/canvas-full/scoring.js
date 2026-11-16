"use strict";
globalThis.SCORE={
 timing(position){const distance=Math.min(1,Math.max(0,Math.abs(position-.5)*2));return Math.round((1-distance)*(1-distance)*100);},
 prefix(heights){const p=[0];for(let i=1;i<heights.length;i++)p[i]=p[i-1]+(heights[i-1]+heights[i])/2;return p;},
 halfRatio(heights,prefix,cut){const last=heights.length-1,pos=Math.max(0,Math.min(1,cut))*last,i=Math.min(last-1,Math.floor(pos)),f=pos-i,height=heights[i]+(heights[i+1]-heights[i])*f;return (prefix[i]+f*(heights[i]+height)/2)/prefix[last];},
 halfScore(ratio){return Math.round(Math.pow(Math.max(0,Math.min(1,1-Math.abs(ratio-.5)/.5)),2)*100);},
 circleScore(distances,mean){const cv=Math.sqrt(distances.reduce((a,v)=>a+(v-mean)**2,0)/distances.length)/mean;return Math.round(Math.max(0,Math.min(100,100*(1-cv*3)))*10)/10;}
};
