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
