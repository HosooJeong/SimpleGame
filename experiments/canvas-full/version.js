"use strict";

const CURRENT_VERSION = "__BUILD_VERSION__";

async function checkReleaseVersion(current, fetchVersion, onNewVersion) {
  try {
    const version = await fetchVersion();
    if (typeof version !== "string" || !/^[a-zA-Z0-9_-]{1,80}$/.test(version)) {
      return "unavailable";
    }
    if (version === current) return "current";
    await onNewVersion(version);
    return "outdated";
  } catch (_) {
    // Network failures and offline use never prevent the game from starting.
    return "unavailable";
  }
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = {checkReleaseVersion};
}

if (typeof window !== "undefined") {
  const startedAt = performance.now();
  let interacted = false;
  for (const event of ["pointerdown", "keydown", "wheel", "touchstart"]) {
    document.addEventListener(event, () => { interacted = true; },
      {capture:true, passive:true, once:true});
  }
  const canApply = () => !interacted &&
    document.visibilityState === "visible" &&
    !document.querySelector(".play") &&
    performance.now() - startedAt < 8000;

  function askWorker(worker, type) {
    return new Promise(resolve => {
      const channel = new MessageChannel();
      const timer = setTimeout(() => { channel.port1.close(); resolve(null); }, 1000);
      channel.port1.onmessage = event => {
        clearTimeout(timer);
        channel.port1.close();
        resolve(event.data);
      };
      try {
        worker.postMessage({type}, [channel.port2]);
      } catch (_) {
        clearTimeout(timer);
        channel.port1.close();
        resolve(null);
      }
    });
  }

  async function applyWhenSafe(version) {
    if (!("serviceWorker" in navigator)) return;
    const registration = await navigator.serviceWorker.getRegistration();
    if (!registration || !navigator.serviceWorker.controller) return;
    try { await registration.update(); } catch (_) { return; }
    // Keep the current page responsive while the browser prepares the update.
    const end = performance.now() + 5000;
    while (!registration.waiting && canApply() && performance.now() < end) {
      await new Promise(resolve => setTimeout(resolve, 100));
    }
    const worker = registration.waiting;
    if (!worker || !canApply()) return;
    const answer = await askWorker(worker, "GET_VERSION");
    if (answer?.version !== version || !canApply()) return;
    const guard = "snack.auto-update." + version;
    try { if (sessionStorage.getItem(guard)) return; } catch (_) {}
    const changed = () => {
      navigator.serviceWorker.removeEventListener("controllerchange", changed);
      if (!canApply()) return;
      try { sessionStorage.setItem(guard, "1"); } catch (_) {}
      window.location.reload();
    };
    navigator.serviceWorker.addEventListener("controllerchange", changed);
    const result = await askWorker(worker, "ACTIVATE_IF_SOLE_CLIENT");
    if (!result?.accepted) {
      navigator.serviceWorker.removeEventListener("controllerchange", changed);
    }
  }

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
    checkReleaseVersion(CURRENT_VERSION, fetchVersion, applyWhenSafe);
  });
}
