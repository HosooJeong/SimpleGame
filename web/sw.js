// 커스텀 서비스워커.
// Flutter가 기본 서비스워커를 폐기해(현재는 자기 자신을 해제하는 스텁만 생성) 직접 넣는다.
// __BUILD_VERSION__ 은 배포 시 커밋 해시로 치환된다 — 캐시 무효화 기준.

const VERSION = '__BUILD_VERSION__';
const CACHE = `snackgame-${VERSION}`;

self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(
      keys.filter((key) => key !== CACHE).map((key) => caches.delete(key)),
    );
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  if (new URL(request.url).origin !== self.location.origin) return;

  event.respondWith(
    request.mode === 'navigate' ? networkFirst(request) : cacheFirst(request),
  );
});

// 정적 자산(canvaskit·폰트·main.dart.js·효과음): 캐시에 있으면 네트워크를 타지 않는다.
async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) return cached;

  const response = await fetch(request);
  store(request, response);
  return response;
}

// 문서 요청: 새 배포를 우선 반영하되, 오프라인이면 캐시로 폴백한다.
async function networkFirst(request) {
  try {
    const response = await fetch(request);
    store(request, response);
    return response;
  } catch (error) {
    const cached = await caches.match(request);
    if (cached) return cached;
    throw error;
  }
}

function store(request, response) {
  if (response.status !== 200) return;
  const copy = response.clone();
  caches.open(CACHE)
    .then((cache) => cache.put(request, copy))
    .catch(() => {});
}
