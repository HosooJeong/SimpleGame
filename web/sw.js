// 커스텀 서비스워커.
// Flutter가 기본 서비스워커를 폐기해(현재는 자기 자신을 해제하는 스텁만 생성) 직접 넣는다.
// 아래 두 값은 배포 시 치환된다(워크플로의 Stamp service worker versions 단계).

// 앱 코드(index.html·flutter_bootstrap.js·main.dart.js) — 커밋마다 바뀐다.
const APP_VERSION = '__BUILD_VERSION__';
// canvaskit·폰트·효과음 — 내용이 실제로 바뀔 때만 값이 바뀐다.
// 앱 코드와 캐시를 나눠, 코드만 고친 배포에서 canvaskit(2.8MB)을 다시 받지 않게 한다.
const ASSET_VERSION = '__ASSET_VERSION__';

const APP_CACHE = `snackgame-app-${APP_VERSION}`;
const ASSET_CACHE = `snackgame-assets-${ASSET_VERSION}`;
const CURRENT = [APP_CACHE, ASSET_CACHE];

// skipWaiting/clients.claim 은 일부러 쓰지 않는다. 열려 있는 탭이 이전 워커와 이전
// 캐시를 그대로 유지해야 한 페이지 안에서 서로 다른 빌드의 파일이 섞이지 않는다.
// 새 배포는 탭을 모두 닫은 뒤 다음 방문에 적용된다.
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(
      keys.filter((key) => !CURRENT.includes(key)).map((key) => caches.delete(key)),
    );
  })());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  event.respondWith(
    request.mode === 'navigate'
        ? networkFirst(request, APP_CACHE)
        : cacheFirst(request, cacheNameFor(url)),
  );
});

// canvaskit·에셋은 배포 간에 살아남는 캐시로, 나머지는 커밋 단위 캐시로 보낸다.
function cacheNameFor(url) {
  const path = url.pathname;
  return path.includes('/canvaskit/') || path.includes('/assets/')
      ? ASSET_CACHE
      : APP_CACHE;
}

// 정적 자산: 캐시에 있으면 네트워크를 타지 않는다.
async function cacheFirst(request, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);
  if (cached) return cached;

  const response = await fetch(request);
  store(cache, request, response);
  return response;
}

// 문서 요청: 새 배포를 우선 반영하되, 오프라인이면 캐시로 폴백한다.
async function networkFirst(request, cacheName) {
  const cache = await caches.open(cacheName);
  try {
    const response = await fetch(request);
    store(cache, request, response);
    return response;
  } catch (error) {
    const cached = await cache.match(request);
    if (cached) return cached;
    throw error;
  }
}

// caches.match() 는 이전 버전 캐시까지 뒤지므로 쓰지 않는다 — 빌드가 섞인다.
function store(cache, request, response) {
  if (response.status !== 200) return;
  cache.put(request, response.clone()).catch(() => {});
}
