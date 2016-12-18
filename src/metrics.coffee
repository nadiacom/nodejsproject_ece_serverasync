levelup = require 'levelup'
levelws = require 'level-ws'
db = levelws levelup "#{__dirname}/../db/metrics"
d3 = require 'd3'

util = require 'util'

module.exports = 

  put: (user_id, chart_id, metrics, callback) ->
    {timestamp, value} = metrics
    db.put "metric:#{user_id}:#{chart_id}:#{timestamp}", value, (err) ->
      if err then callback err
      # some kind of I/O error
      # 3) fetch by key
      db.get "metric:#{user_id}:#{chart_id}:#{timestamp}", (err, val) ->
        if err then callback err
        # likely the key was not found
        # ta da!
        callback null, val

  get: (user_id, chart_id, timestamp, callback) ->
    db.get "metric:#{user_id}:#{chart_id}:#{timestamp}", (err, val) ->
      if err then callback err
      # likely the key was not found
      callback null, val

  # Get the number of charts for specific user
  getNbChart: (user_id, callback) ->
    arr = []
    max = 0
    stream = db.createReadStream()
    stream.on 'data', (val) ->
      username = val.key.split(":")[1]
      if username == user_id
        z = val.key.split ':'
        z = z[2]
        arr.push(z)
    stream.on 'close', ->
      if arr.length != 0
        max = Math.max.apply(Math, arr)
      callback null, max

  # Get metrics for specific chart
  readStream: (user_id,chart_id,callback) ->
    x = '['
    y =''
    stream = db.createReadStream()
    stream.on 'data', (val) ->
      username = val.key.split(":")[1]
      chart = val.key.split(":")[2]
      console.log val
      if username == user_id && chart == chart_id
        z = val.key.split ':'
        z = z[3]
        y = val.value
        x += JSON.stringify({ timestamp: z, value: y })+','
    stream.on 'close', ->
      x = x.slice(0, -1) + ']'
      x= JSON.stringify(x)
      callback null, x

  remove: (user_id,chart_id, timestamp, callback) ->
    db.del "metric:#{user_id}:#{chart_id}:#{timestamp}", (err) ->
      if err then callback err
      callback null, "success"

  batch: (metrics, callback) ->
    db.batch metrics, (err) ->
      if err then callback err
      callback null, "batch done !"
