# 스낵게임 · SimpleGame

반응속도와 기억력을 시험하는 미니게임 모음이야. [GitHub Pages에서 바로 플레이](https://hosoojeong.github.io/SimpleGame/)할 수 있어.

현재 홈과 기록 화면에는 **반응속도, 숫자 순서, 순서 기억, 정확한 10초, 순간 기억** 다섯 게임을 표시해. 나머지 게임의 코드는 삭제하지 않고 숨겨뒀어. 기존에 공유한 개별 게임 링크도 계속 열 수 있어.

웹 화면은 브라우저 기본 스크롤, HTML/CSS와 Canvas 2D로 만들어져 있어. 기존 Flutter 소스와 테스트는 저장소에 유지돼.

## 기록과 설정

기록은 기기별 브라우저 저장소에 저장되며 다른 기기로 동기화되지 않아. 기존 Flutter 웹과 같은 출처에서 이식판을 처음 열면 기존 기록과 설정을 별도 키로 복사하고, Flutter 원본 기록은 그대로 보존해. 다른 출처의 기록은 브라우저 보안 정책 때문에 자동으로 읽을 수 없어.

설정의 기록 초기화는 현재 표시된 다섯 게임에만 적용돼. 숨긴 게임의 기록은 유지돼. 효과음, 진동과 공유는 기기와 브라우저의 지원 여부에 따라 달라질 수 있어.

## 로컬 실행

```sh
python experiments/canvas-full/serve.py
```

브라우저에서 `http://localhost:8768/`을 열어. 같은 네트워크의 다른 기기에서는 개발 PC 주소와 포트 8768로 접속할 수 있어.

```sh
node experiments/canvas-full/scoring.test.cjs
python -m pip install fonttools==4.58.5
python experiments/canvas-full/build.py --output ./canvas-site --version local
```

빌드 출력 디렉터리는 비어 있어야 해. 웹 오프라인 기능은 HTTPS 또는 localhost에서만 동작해.

## 배포

`main`에 푸시하면 GitHub Actions가 점수 테스트, 폰트 서브셋 및 웹 산출물 생성을 수행한 뒤 GitHub Pages에 배포해. 상세 설정은 [배포 워크플로](.github/workflows/deploy-pages.yml)를 참고해.
