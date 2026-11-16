const assert=require("node:assert/strict");
require("./scoring.js");
assert.equal(SCORE.timing(0),0);assert.equal(SCORE.timing(.5),100);assert.equal(SCORE.timing(1),0);assert.equal(SCORE.timing(.25),25);
const rectangle=[1,1,1],p=SCORE.prefix(rectangle);assert.equal(SCORE.halfRatio(rectangle,p,0),0);assert.equal(SCORE.halfRatio(rectangle,p,.5),.5);assert.equal(SCORE.halfRatio(rectangle,p,1),1);assert.equal(SCORE.halfScore(.5),100);
const triangle=[0,1],tp=SCORE.prefix(triangle);assert.equal(SCORE.halfRatio(triangle,tp,.5),.25);assert.equal(SCORE.halfScore(.25),25);
assert.equal(SCORE.circleScore([100,100,100,100],100),100);
console.log("Scoring checks passed");
