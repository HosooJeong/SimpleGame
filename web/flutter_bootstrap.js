{{flutter_js}}
{{flutter_build_config}}

// serviceWorkerSettings 를 넘기지 않아 Flutter 기본(정리용) 서비스워커 등록을 막는다.
// 캐싱은 index.html 이 등록하는 sw.js 가 담당한다.
_flutter.loader.load();
