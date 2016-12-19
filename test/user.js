var should, user;

should = require('should');

user = require('../lib/user.js');
metrics = require('../lib/metrics.js');

//user.js
describe('get user from leveldb', function() {
  return it('should get a user w/ right parameters', function(done) {
    return user.get("nadia", function(err, data) {
      data.username.should.equal("nadia");
      return done();
    });
  });
});

describe('save one user on leveldb', function() {
  user.save("username_test2","passwor_test",function(err, data) {
    return "test";
  });
  return it('should get a user w/ right parameters', function(done) {
    return user.get("username_test2", function(err, data) {
      data.username.should.equal("username_test2");
      data.password.should.equal("passwor_test");
      return done();
    });
  });
});

describe('delete one user on leveldb', function() {
  user.remove("usernametest2",function(err, data) {
    return "test";
  });
  return it('should get a user w/ right parameters', function(done) {
    return user.get("usernametest2", function(err, data) {
      should.not.exist(err);
      should.exist(data);
      return done();
    });
  });
});

//metrics.js
describe('put metric on leveldb', function() {
  json1 = { "timestamp": "2016-01-09", "value": "10"};
  return it('should get a user w/ right parameters', function(done) {
    return metrics.put("nadia","1",json1, function(err, data) {
        data.should.equal("10");
      return done();
    });
  });
});

describe('get metric from leveldb', function() {
  return it('should get a user w/ right parameters', function(done) {
    return metrics.get("nadia","1","2016-01-09", function(err, data) {
        data.should.equal("10");
      return done();
    });
  });
});
describe('delete one metric on leveldb', function() {
  metrics.remove("nadia","1","2016-01-09",function(err, data) {
    return "test";
  });
  return it('should get a user w/ right parameters', function(done) {
    return metrics.get("nadia","1","2016-01-09", function(err, data) {
      should.not.exist(err);
      should.exist(data);
      return done();
    });
  });
});
