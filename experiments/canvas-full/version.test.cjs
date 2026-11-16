const assert = require("node:assert/strict");
const {checkReleaseVersion} = require("./version.js");

(async () => {
  let notices = 0;
  let requestedVersion;
  const notify = version => { notices++; requestedVersion = version; };
  assert.equal(await checkReleaseVersion("a1", async () => "a1", notify), "current");
  assert.equal(notices, 0);
  assert.equal(await checkReleaseVersion("a1", async () => "b2", notify), "outdated");
  assert.equal(notices, 1);
  assert.equal(requestedVersion, "b2");
  assert.equal(await checkReleaseVersion("a1", async () => { throw new Error("offline"); }, notify), "unavailable");
  assert.equal(await checkReleaseVersion("a1", async () => "../invalid", notify), "unavailable");
  assert.equal(notices, 1);
  console.log("Version check tests passed");
})().catch(error => { console.error(error); process.exitCode = 1; });
