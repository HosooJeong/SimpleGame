const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const handlers = {};
let requests;
let networkOptions;
let windows = [];
let activations = 0;
const deletedCaches = [];
const scope = "https://example.test/SimpleGame/";
const context = {
  self: {
    registration: {scope},
    addEventListener(type, handler) { handlers[type] = handler; },
    clients: {async matchAll() { return windows; }},
    async skipWaiting() { activations++; },
  },
  caches: {
    async open() {
      return {async addAll(items) { requests = items; }};
    },
    async keys() {
      return ["snack-canvas-full-old", "snack-canvas-full-__BUILD_VERSION__", "another-app-cache"];
    },
    async delete(key) { deletedCaches.push(key); },
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
}).then(async value => {
  assert.equal(value, "network");
  let answer;
  const port = {postMessage(value) { answer = value; }};
  handlers.message({data:{type:"GET_VERSION"}, ports:[port]});
  assert.equal(answer.version, "__BUILD_VERSION__");
  async function requestActivation() {
    let done;
    handlers.message({
      data:{type:"ACTIVATE_IF_SOLE_CLIENT"},
      ports:[port],
      source:{id:"caller"},
      waitUntil(promise) { done = promise; },
    });
    await done;
    return answer.accepted;
  }
  windows = [{id:"caller",url:scope}, {id:"other",url:scope + "?game=memory"}];
  assert.equal(await requestActivation(), false);
  assert.equal(activations, 0);
  windows = [{id:"caller",url:scope}, {id:"unrelated",url:"https://example.test/other/"}];
  assert.equal(await requestActivation(), true);
  assert.equal(activations, 1);
  let activation;
  handlers.activate({waitUntil(promise) { activation = promise; }});
  await activation;
  assert.deepEqual(deletedCaches, ["snack-canvas-full-old"]);
  console.log("Service worker update checks passed");
}).catch(error => {
  console.error(error);
  process.exitCode = 1;
});
