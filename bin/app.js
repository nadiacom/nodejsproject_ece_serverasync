var fs, http, url, user;

http = require('http');

user = require('./user.coffee');

url = require('url');

fs = require('fs');

http.createServer(function(req, res) {
  var path;
  path = url.parse(req.url).pathname;
  return user.get("cesar", function(id) {
    res.writeHead(200, {
      'Content-Type': 'text/plain'
    });
    return res.end("hello " + id);
  });
}).listen(1337, '127.0.0.1', function() {
  return console.log("running on 127.0.0.1:1337");
});
