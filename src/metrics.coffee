levelup = require 'levelup'
levelws = require 'level-ws'
db = levelws levelup "db"
d3 = require 'd3'

util = require 'util'

module.exports = 
  ###
    `get(callback)` 
    ——————— 
    returns some hard-coded metrics 

    `callback`: callback function
  ###



  get_test: (callback) -> 
    callback null, [
      timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:12 
    ,
        timestamp:(new Date '2013-11-04 14:30 UTC').getTime(), value:15 
    ]

  put: (id, metrics, callback) ->
    for metric in metrics 
      {timestamp, value} = metric
      console.log timestamp, value
      db.put "metric:#{id}:#{timestamp}", value, (err) ->
        if err then callback err
        # some kind of I/O error
        # 3) fetch by key
        db.get "metric:#{id}:#{timestamp}", (err, val) ->
          if err then callback err
          # likely the key was not found
          # ta da!
          callback null, val

  get: (user_id, chart_id, timestamp, callback) ->
    db.get "metric:#{user_id}:#{chart_id}:#{timestamp}", (err, val) ->
      if err then callback err
      # likely the key was not found
      callback null, val

  readStream: (user_id,chart_id,callback) ->
    x = '['
    y =''
    stream = db.createReadStream
      start: 'metric:1:1:2013-01-09'
      end: 'metric:1:1:2013-01-11'
    stream.on 'data', (val) ->
      console.log val.value
      z = val.key.split ':'
      z = z[3]
      y = val.value
      x += JSON.stringify({ timestamp: z, value: y })+','
    stream.on 'close', ->
      x = x.slice(0, -1) + ']'
      x= JSON.stringify(x)
      callback null, x

  remove: (id, timestamp, callback) ->
    db.del "metric:#{id}:#{timestamp}", (err) ->
      if err then callback err

  batch: (metrics, callback) ->
    db.batch metrics, (err) ->
      if err then callback err
    db.get "metric:1:2013-01-09", (err, val) ->
      if err then callback err
      # likely the key was not found
      callback null, val


  save: (id, metrics, callback) -> 
    console.log "heyy"
    console.log metrics.length
    console.log util.inspect(metrics, false, null)
    #ws = db.createWriteStream() 
    #ws.on 'error', callback 
    #ws.on 'close', callback 
    for metric in metrics 
      console.log "heyy"


      #{timestamp, value} = metric
      #ws.write key: "metric:#{id}:#{timestamp}", value: value 
    #ws.end()
