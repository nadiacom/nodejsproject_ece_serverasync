var should, user;

should = require('should');

user = require('../lib/user.js');


//user.js
describe('get a user from leveldb', function() {
  user.save("username_test","password_test",function(err, data) {
    return "test";
  });
  return it('should get a user w/ right parameters', function(done) {
    return user.get("username_test", function(err, data) {
      data.username.should.equal("username_test");
      return done();
    });
  });
});

describe('save one user on leveldb', function() {
  user.save("username_test2","password_test",function(err, data) {
    return "test";
  });
  return it('should get a user w/ right parameters', function(done) {
    return user.get("username_test2", function(err, data) {
      data.username.should.equal("username_test2");
      data.password.should.equal("password_test");
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
