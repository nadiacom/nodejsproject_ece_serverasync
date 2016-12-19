levelup = require 'levelup'
levelws = require 'level-ws'
db = levelws levelup './db/users'

module.exports =
  get: (username, callback) ->
    user = {}
    rs = db.createReadStream
      gte: "user:#{username}"
    rs.on 'data', (data) ->
      user.username = username
      user.password = data.value
    rs.on 'error', callback
    rs.on 'close', ->
      callback null, user

  save: (username, password, callback) ->
    console.log username
    db.put "user:#{username}", password, (err) ->
      if err then callback err
      # some kind of I/O error
      # 3) fetch by key
      db.get "user:#{username}", (err, val) ->
        if err then callback err
        # likely the key was not found
        # ta da!
        callback null, val

  remove: (username, callback) ->
    db.del "user:#{username}", (err) ->
      if err then callback err
      callback null, "success"

  # We won't do update
