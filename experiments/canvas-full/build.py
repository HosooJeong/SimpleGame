"""Build a self-contained GitHub Pages artifact without changing source assets."""
import argparse
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

site = Path(__file__).resolve().parent
repo = site.parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--output", required=True, type=Path)
parser.add_argument("--version", required=True)
args = parser.parse_args()
if not re.fullmatch(r"[a-zA-Z0-9_-]+", args.version):
    raise SystemExit("Invalid build version")
output = args.output.resolve()
if output.exists() and any(output.iterdir()):
    raise SystemExit("Output must be a new or empty directory")
output.mkdir(parents=True, exist_ok=True)
site_files = ("index.html", "style.css", "i18n.js", "scoring.js", "app.js",
              "previews.js", "games_basic.js", "games_memory.js", "games_draw.js",
              "games_more.js", "games_fidelity.js", "manifest.json")
for name in site_files:
    shutil.copy2(site / name, output / name)
worker = (site / "sw.js").read_text(encoding="utf-8")
if worker.count("__BUILD_VERSION__") != 1:
    raise SystemExit("Expected exactly one service-worker version placeholder")
(output / "sw.js").write_text(worker.replace("__BUILD_VERSION__", args.version),
                             encoding="utf-8", newline="\n")
with tempfile.TemporaryDirectory(prefix="snack-fonts-", dir=output.parent) as temp:
    work = Path(temp)
    fonts = work / "assets/assets/fonts"
    fonts.mkdir(parents=True)
    names = ("Jua-Regular.ttf", "BlackHanSans-Regular.ttf",
             "Pretendard-Regular.otf", "Pretendard-Bold.otf")
    for name in names:
        shutil.copy2(repo / "assets/fonts" / name, fonts / name)
    subprocess.run([sys.executable, str(repo / "tool/subset_fonts.py"), str(work)], check=True)
    target = output / "assets/fonts"
    target.mkdir(parents=True)
    for name in names:
        shutil.copy2(fonts / name, target / name)
for source, destination, names in (
    (repo / "assets/sfx", output / "assets/sfx", ("tap.wav", "success.wav", "fail.wav", "tick.wav", "go.wav")),
    (repo / "web/icons", output / "web/icons", ("Icon-192.png", "Icon-512.png")),
):
    destination.mkdir(parents=True)
    for name in names:
        shutil.copy2(source / name, destination / name)
print(f"Built Canvas Pages artifact at {output}")
