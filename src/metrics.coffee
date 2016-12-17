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

  put: (user_id, chart_id, metrics, callback) ->
    {timestamp, value} = metrics
    console.log "bonbon:"+ timestamp, value
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
    stream = db.createReadStream()
    stream.on 'data', (val) ->
      if val.key.substring(0, 9) == 'metric:' + user_id + ':'
        z = val.key.split ':'
        z = z[2]
        arr.push(z)
    stream.on 'close', ->
      max = Math.max.apply(Math, arr)
      console.log max
      callback null, max

  # Get metrics for specific chart
  readStream: (user_id,chart_id,callback) ->
    x = '['
    y =''
    stream = db.createReadStream()
    stream.on 'data', (val) ->
      console.log val.key
      if val.key.substring(0, 10) == 'metric:' + user_id + ':'+chart_id
        console.log val.value
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

  batch: (metrics, callback) ->
    db.batch metrics, (err) ->
      if err then callback err
      callback null, "batch done !"


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
