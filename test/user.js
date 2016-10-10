var should, user;

should = require('should');

user = require('../src/user.coffee');

describe('my first test list', function() {
  return it('should get a user w/ right parameters', function(done) {
    return user.get("marie", function(res) {
      res.should.equal("marie");
      return done();
    });
  });
});
