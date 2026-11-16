"""Serve only this prototype and the required existing assets."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

site = Path(__file__).resolve().parent
repo = site.parents[1]
subset = repo / "build/web/assets/assets/fonts"
fonts = subset if subset.is_dir() else repo / "assets/fonts"
assets = {"/assets/fonts/" + n: fonts / n for n in (
    "Jua-Regular.ttf", "BlackHanSans-Regular.ttf",
    "Pretendard-Regular.otf", "Pretendard-Bold.otf")}
assets.update({"/assets/sfx/" + n + ".wav": repo / "assets/sfx" / (n + ".wav")
               for n in ("tap", "success", "fail", "tick", "go")})
assets.update({"/web/icons/" + n: repo / "web/icons" / n
               for n in ("Icon-192.png", "Icon-512.png")})

class Handler(SimpleHTTPRequestHandler):
    def translate_path(self, path):
        resource = urlsplit(path).path
        if resource in assets:
            return str(assets[resource])
        return super().translate_path(path)
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", 8768), partial(Handler, directory=str(site))).serve_forever()
