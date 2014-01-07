var buster = require('buster');
var assert = require('buster').assert;
var refute = require('buster').refute;

buster.testCase("Any Tests", {
    "a test": function () {
      assert.equals("1", "1");
      refute.equals("1", "2");
    }
});

