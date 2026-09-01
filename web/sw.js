// 커스텀 서비스워커.
// Flutter가 기본 서비스워커를 폐기해(현재는 자기 자신을 해제하는 스텁만 생성) 직접 넣는다.
// __BUILD_VERSION__ 은 배포 시 커밋 해시로 치환된다 — 캐시 무효화 기준.

const VERSION = '__BUILD_VERSION__';
const CACHE = `snackgame-${VERSION}`;

// skipWaiting/clients.claim 은 일부러 쓰지 않는다. 열려 있는 탭이 이전 워커와 이전
// 캐시를 그대로 유지해야 한 페이지 안에서 서로 다른 빌드의 파일이 섞이지 않는다.
// 새 배포는 탭을 모두 닫은 뒤 다음 방문에 적용된다.
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(
      keys.filter((key) => key !== CACHE).map((key) => caches.delete(key)),
    );
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
  const cache = await caches.open(CACHE);
  const cached = await cache.match(request);
  if (cached) return cached;

  const response = await fetch(request);
  store(cache, request, response);
  return response;
}

// 문서 요청: 새 배포를 우선 반영하되, 오프라인이면 캐시로 폴백한다.
async function networkFirst(request) {
  const cache = await caches.open(CACHE);
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
