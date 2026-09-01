"""빌드 산출물의 폰트를 실제로 쓰는 글자만 남기고 줄인다.

첫 로딩 용량을 줄이는 게 목적. 원본 폰트(assets/fonts/)는 그대로 두고
build/web 안의 복사본만 깎으므로, 소스의 문구를 바꾸면 다음 빌드에서
자동으로 반영된다 — 서브셋이 소스와 어긋나 글자가 □로 깨질 일이 없다.

포함하는 글자는 lib/**.dart 에 등장하는 모든 문자 + ASCII + 흔한 기호뿐이다.
한글 완성형 2,350자를 여유분으로 넣어보면 폰트가 0.69MB 대신 3.39MB가 된다.
Jua·BlackHanSans 가 이미 서브셋 폰트(글리프 약 2,500개)라 여유분이 사실상
원본 크기를 그대로 붙잡기 때문이다.

**따라서 화면에 나오는 글자는 반드시 lib/ 안의 Dart 소스에 있어야 한다.**
에셋 파일이나 서버에서 받아온 한글을 그리면 □ 로 깨진다. 소스에 있는 글자가
빠졌는지는 아래 verify 가 빌드 시점에 잡아준다.

사용: python tool/subset_fonts.py <build/web 경로>
"""

import pathlib
import sys

from fontTools import subset
from fontTools.ttLib import TTFont

# 한국어 본문에서 흔히 쓰는 기호 — 소스에 없더라도 미리 넣어둔다.
# 기호 몇 개는 용량에 거의 영향이 없고, 원본에 없는 글리프는 그냥 무시된다.
EXTRA_SYMBOLS = '·–—…‘’“”×÷℃％「」『』〈〉《》•→←↑↓'


def chars_in_sources(repo_root):
    """lib 아래 Dart 소스와 번역 파일(.arb)에 등장하는 모든 문자.

    문자열 리터럴만 골라내지 않고 파일 전체를 훑는다. 식별자·키워드는 어차피
    ASCII라 결과에 영향이 없고, 파싱 실수로 문구를 빠뜨릴 위험이 사라진다.

    .arb 도 함께 읽는 이유: UI 문구의 원본은 lib/l10n/app_*.arb 이고, 거기서
    생성되는 Dart 파일은 커밋하지 않는다. .dart 만 훑으면 코드 생성 전에는
    번역문이 통째로 빠져 글자가 □ 로 깨진다.
    """
    chars = set()
    lib = repo_root / 'lib'
    for pattern in ('*.dart', '*.arb'):
        for path in sorted(lib.rglob(pattern)):
            chars |= set(path.read_text(encoding='utf-8'))
    return {ch for ch in chars if ch.isprintable() and not ch.isspace()}


def freeze_timestamps(font):
    """head 테이블의 수정 시각을 고정한다.

    fontTools 는 저장할 때 현재 시각을 적기 때문에, 같은 입력으로 서브셋해도
    결과 바이트가 매번 달라진다. 서비스워커의 자산 캐시 키를 산출물 해시로
    잡고 있어서 그대로 두면 배포마다 캐시가 무효화돼 분리한 의미가 없어진다.

    필드를 지우는 것만으로는 부족하다. recalcTimestamp 가 켜져 있으면 compile
    시점에 현재 시각으로 다시 덮어쓴다.
    """
    font.recalcTimestamp = False
    if 'head' in font:
        font['head'].created = 0
        font['head'].modified = 0


def coverage(path):
    font = TTFont(path)
    covered = set()
    for table in font['cmap'].tables:
        covered |= {chr(code) for code in table.cmap}
    font.close()
    return covered


def main():
    if len(sys.argv) != 2:
        raise SystemExit('사용: python tool/subset_fonts.py <build/web 경로>')

    web_dir = pathlib.Path(sys.argv[1]).resolve()
    repo_root = pathlib.Path(__file__).resolve().parent.parent
    font_dir = web_dir / 'assets' / 'assets' / 'fonts'

    if not font_dir.is_dir():
        raise SystemExit(f'폰트 디렉터리를 찾을 수 없음: {font_dir}')

    used = chars_in_sources(repo_root)
    keep = used | {chr(code) for code in range(0x21, 0x7F)} | set(EXTRA_SYMBOLS)
    print(f'소스 사용 문자 {len(used):,}자, 유지 대상 {len(keep):,}자')

    fonts = sorted(
        p for p in font_dir.iterdir() if p.suffix.lower() in ('.otf', '.ttf')
    )
    if not fonts:
        raise SystemExit(f'서브셋할 폰트가 없음: {font_dir}')

    text = ''.join(sorted(keep))
    total_before = total_after = 0

    for path in fonts:
        before = path.stat().st_size
        original = coverage(path)

        font = TTFont(path)
        options = subset.Options()
        options.layout_features = ['*']
        options.name_IDs = ['*']
        options.notdef_outline = True
        subsetter = subset.Subsetter(options=options)
        subsetter.populate(text=text)
        subsetter.subset(font)
        freeze_timestamps(font)
        font.save(path)
        font.close()

        # 원본에 있었는데 서브셋에서 사라진 글자가 있으면 화면에 □로 나온다.
        # 원본이 애초에 갖고 있지 않던 글자는 서브셋 탓이 아니므로 제외한다.
        lost = (used & original) - coverage(path)
        if lost:
            raise SystemExit(
                f'{path.name}: 소스에 쓰이는 글자 {len(lost)}자가 사라졌다 — '
                f'{"".join(sorted(lost))[:40]}'
            )

        after = path.stat().st_size
        total_before += before
        total_after += after
        print(
            f'  {path.name:32} {before / 1024:8.0f} KB -> {after / 1024:7.0f} KB'
            f'  ({after / before * 100:4.1f}%)'
        )

    print(
        f'합계 {total_before / 1024 / 1024:.2f} MB -> '
        f'{total_after / 1024 / 1024:.2f} MB '
        f'({total_after / total_before * 100:.1f}%)'
    )
    print('검증 통과: 소스에 쓰이는 글자가 모두 남아있다')


if __name__ == '__main__':
    main()
