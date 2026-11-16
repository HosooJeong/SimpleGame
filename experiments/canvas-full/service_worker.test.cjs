const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const handlers = {};
let requests;
let networkOptions;
const scope = "https://example.test/SimpleGame/";
const context = {
  self: {
    registration: {scope},
    addEventListener(type, handler) { handlers[type] = handler; },
  },
  caches: {
    async open() {
      return {async addAll(items) { requests = items; }};
    },
  },
  location: {origin: "https://example.test"},
  fetch(request, options) {
    networkOptions = options;
    return Promise.resolve("network");
  },
  Request,
  URL,
};
vm.runInNewContext(fs.readFileSync(path.join(__dirname, "sw.js"), "utf8"), context);
let install;
handlers.install({waitUntil(promise) { install = promise; }});
install.then(() => {
  assert.ok(requests.length > 0);
  assert.ok(requests.every(request => request.cache === "reload"));
  assert.ok(requests.some(request => request.url === scope + "app.js"));
  assert.ok(requests.some(request => request.url === scope + "assets/fonts/Jua-Regular.ttf"));
  let response;
  handlers.fetch({
    request: new Request(scope + "version.json?check=123"),
    respondWith(promise) { response = promise; },
  });
  assert.equal(networkOptions.cache, "no-store");
  return response;
}).then(value => {
  assert.equal(value, "network");
  console.log("Service worker update checks passed");
}).catch(error => {
  console.error(error);
  process.exitCode = 1;
});
