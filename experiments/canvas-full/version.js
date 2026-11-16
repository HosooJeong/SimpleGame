"use strict";

const CURRENT_VERSION = "__BUILD_VERSION__";

async function checkReleaseVersion(current, fetchVersion, onNewVersion) {
  try {
    const version = await fetchVersion();
    if (typeof version !== "string" || !/^[a-zA-Z0-9_-]{1,80}$/.test(version)) {
      return "unavailable";
    }
    if (version === current) return "current";
    onNewVersion();
    return "outdated";
  } catch (_) {
    // Offline, unreachable, or invalid responses never block the game.
    return "unavailable";
  }
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = {checkReleaseVersion};
}

if (typeof window !== "undefined") {
  document.addEventListener("DOMContentLoaded", () => {
    const fetchVersion = async () => {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), 3500);
      try {
        const url = new URL("version.json", document.baseURI);
        url.searchParams.set("check", Date.now() + "-" + Math.random().toString(36).slice(2));
        const response = await fetch(url, {cache:"no-store", signal:controller.signal});
        if (!response.ok) throw new Error("Version unavailable");
        return (await response.json()).version;
      } finally {
        clearTimeout(timer);
      }
    };
    const onNewVersion = () => {
      if (document.getElementById("update-notice")) return;
      const notice = document.createElement("aside");
      notice.id = "update-notice";
      notice.className = "update-notice";
      notice.setAttribute("role", "status");
      const message = document.createElement("span");
      const ko = document.documentElement.lang === "ko";
      message.textContent = ko
        ? "새 버전이 있어. 잠시 후 이 사이트의 모든 탭을 닫고 다시 열면 적용돼."
        : "A new version is available. Close all tabs for this site and reopen it shortly to update.";
      const close = document.createElement("button");
      close.type = "button";
      close.textContent = ko ? "닫기" : "Dismiss";
      const app = document.getElementById("app");
      const syncVisibility = () => {
        notice.hidden = Boolean(app?.querySelector(".play"));
      };
      const observer = new MutationObserver(syncVisibility);
      if (app) observer.observe(app, {childList:true});
      close.addEventListener("click", () => {
        observer.disconnect();
        notice.remove();
      });
      notice.append(message, close);
      document.body.append(notice);
      syncVisibility();
      if ("serviceWorker" in navigator) {
        navigator.serviceWorker.getRegistration()
          .then(registration => registration?.update())
          .catch(() => {});
      }
    };
    checkReleaseVersion(CURRENT_VERSION, fetchVersion, onNewVersion);
  });
}
