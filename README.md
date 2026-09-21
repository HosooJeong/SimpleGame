# 스낵게임 · SimpleGame

잠깐의 빈 시간에 반응속도, 기억력, 감각을 시험하는 **14가지 미니게임 모음**. Flutter로 만들었고, 개인 최고기록에 계속 도전할 수 있어.

**[🎮 GitHub Pages에서 바로 플레이](https://hosoojeong.github.io/SimpleGame/)**

설치 없이 브라우저에서 실행할 수 있어. 모바일에서는 세로 화면으로 즐기는 걸 추천해.

## 미니게임

| 게임 | 플레이 방법 |
| --- | --- |
| 반응속도 | 초록 화면으로 바뀌면 터치! 5회 평균 반응 시간을 측정해. |
| 숫자 순서 | 흩어진 숫자 1부터 25까지 순서대로 빠르게 눌러. |
| 탭 스피드 | 첫 터치부터 10초 동안 최대한 많이 탭해. |
| 타이밍 스톱 | 움직이는 원을 정중앙에 멈춰. 총 5라운드야. |
| 순서 기억 | 반짝이는 방향을 기억하고 같은 순서로 눌러. |
| 정확한 10초 | 타이머가 가려진 뒤 감각만으로 10초를 맞혀. |
| 다른 색 찾기 | 30초 동안 색이 다른 타일을 찾아. 오답은 2초 감소! |
| 색깔 함정 | 단어의 뜻과 글자 색이 같은지 30초 동안 판단해. |
| 순간 기억 | 숫자의 위치를 외우고, 가려진 숫자를 순서대로 눌러. |
| 반반 자르기 | 절단선을 드래그해서 도형의 넓이를 반으로 나눠. |
| 완벽한 원 | 한 획으로 원을 그려서 원형도 점수를 확인해. |
| 셔플 추적 | 섞이는 타일 중 별이 들어 있는 타일을 끝까지 추적해. |
| 순간 셈 | 잠깐 나타난 점이 몇 개였는지 맞혀. |
| 가짜 신호 | 초록 신호에는 터치하고, 빨간 신호는 참아. |

## 주요 기능

- 게임별 최고기록, 누적 플레이 횟수, 최근 50회 기록과 추이 그래프
- 결과 공유와 해당 게임으로 바로 연결되는 링크
- 한국어·영어 지원과 앱 내 언어 선택
- 효과음·진동 개별 설정
- 로컬 기록 저장: 별도 계정이나 서버 없이 사용
- 웹 앱 매니페스트와 서비스워커를 통한 PWA 지원

기록은 현재 기기 또는 브라우저에 저장돼. 다른 기기와 동기화되지 않으며, 앱 데이터나 브라우저 사이트 데이터를 삭제하면 사라질 수 있어. 웹에서 오프라인으로 다시 열려면 해당 페이지와 필요한 리소스가 먼저 캐시되어 있어야 해.

## 로컬 실행

Flutter SDK와 실행할 플랫폼의 개발 환경이 필요해. 현재 배포 워크플로는 **Flutter 3.41.4**, 프로젝트의 Dart SDK 조건은 **`^3.11.1`**이야.

```sh
git clone https://github.com/HosooJeong/SimpleGame.git
cd SimpleGame
flutter pub get
flutter gen-l10n
flutter run
```

브라우저에서 실행하려면:

```sh
flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080
```

같은 네트워크의 다른 기기에서는 개발 PC의 IP와 포트 `8080`으로 접속할 수 있어. 방화벽에서 해당 포트 접근이 허용되어 있어야 해.

## 코드 구조

```text
lib/
├── app/          # 테마, 공통 UI, 서비스 주입
├── core/         # 기록 저장, 설정, 효과음·진동, 공유
├── games/        # 14개 게임과 공통 진행 셸
├── l10n/         # 한국어·영어 번역
├── models/       # 게임 기록 모델
├── screens/      # 홈, 통계, 설정 화면
└── main.dart     # 앱 초기화
test/            # 단위·위젯 테스트
assets/          # 폰트, 효과음, 아이콘
web/             # 웹 진입점, PWA 설정, 서비스워커
tool/            # 배포용 폰트 서브셋 도구
```

각 게임은 `GameDefinition`과 플레이 위젯으로 구성돼. 공통 `GameShellScreen`이 **설명 → 카운트다운 → 플레이 → 결과** 흐름을 관리하고, 플레이 위젯은 `GameSession`으로 결과를 전달해. 게임 등록 목록은 [`lib/games/game_registry.dart`](lib/games/game_registry.dart)에 있어.

## 검증

```sh
flutter analyze
flutter test
```

테스트는 기록 저장, 게임 진행 흐름, 공유 링크, 언어 전환 등을 검증해.

## 웹 배포

`main` 브랜치에 푸시하면 [GitHub Actions](https://github.com/HosooJeong/SimpleGame/actions/workflows/deploy-pages.yml)가 웹 빌드, 폰트 서브셋 처리, 서비스워커 버전 설정을 거쳐 GitHub Pages에 배포해. 워크플로를 수동으로 실행할 수도 있어.

배포에 사용하는 웹 빌드 명령:

```sh
flutter build web --release --wasm --base-href /SimpleGame/
```

배포 주소: **[hosoojeong.github.io/SimpleGame](https://hosoojeong.github.io/SimpleGame/)**

자세한 자동화 설정은 [배포 워크플로](.github/workflows/deploy-pages.yml)에서 확인할 수 있어.
