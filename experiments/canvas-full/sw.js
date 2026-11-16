"use strict";
const CACHE="snack-canvas-full-__BUILD_VERSION__";
const files=["./","./index.html","./style.css","./i18n.js","./scoring.js","./app.js","./version.js","./previews.js","./games_basic.js","./games_memory.js","./games_draw.js","./games_more.js","./games_fidelity.js","./manifest.json","assets/fonts/Jua-Regular.ttf","assets/fonts/BlackHanSans-Regular.ttf","assets/fonts/Pretendard-Regular.otf","assets/fonts/Pretendard-Bold.otf",...["tap","success","fail","tick","go"].map(x=>"assets/sfx/"+x+".wav"),"web/icons/Icon-192.png","web/icons/Icon-512.png"];
self.addEventListener("install", event => {
  event.waitUntil(caches.open(CACHE).then(cache => {
    const requests = files.map(path =>
      new Request(new URL(path, self.registration.scope), {cache:"reload"}));
    return cache.addAll(requests);
  }));
});
self.addEventListener("activate",event=>event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k.startsWith("snack-canvas-full-")&&k!==CACHE).map(k=>caches.delete(k))))));
self.addEventListener("fetch",event=>{if(event.request.method!=="GET"||new URL(event.request.url).origin!==location.origin)return;if(new URL(event.request.url).pathname===new URL("version.json",self.registration.scope).pathname){event.respondWith(fetch(event.request,{cache:"no-store"}));return;}event.respondWith((async()=>{const cache=await caches.open(CACHE);const key=event.request.mode==="navigate"?new URL("./",self.registration.scope).href:event.request;return await cache.match(key)||fetch(event.request);})());});
