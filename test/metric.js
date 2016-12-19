var should, metric;

should = require('should');

metric = require('../lib/metrics.js');

//metrics.js
describe('put a metric on leveldb', function() {
  json1 = { "timestamp": "2016-01-09", "value": "10"};
  return it('should get a user w/ right parameters', function(done) {
    return metric.put("test","9",json1, function(err, data) {
        data.should.equal("10");
      return done();
    });
  });
});

describe('get metric from leveldb', function() {
  return it('should get a user w/ right parameters', function(done) {
    return metric.get("test","9","2016-01-09", function(err, data) {
      data.should.equal("10");
      return done();
    });
  });
});
describe('delete one metric on leveldb', function() {
  metric.remove("test","9","2016-01-09",function(err, data) {
    return "test";
  });
  return it('should get a user w/ right parameters', function(done) {
    return metric.get("test","9","2016-01-09", function(err, data) {
      should.not.exist(err);
      should.exist(data);
      return done();
    });
  });
});
