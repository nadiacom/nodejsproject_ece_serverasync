# Import a module
http = require 'http'
user = require './user.coffee'
metrics = require './metrics.coffee'
url = require 'url'
fs = require 'fs'
express = require 'express'
bodyParser = require 'body-parser'
app = express()  
d3 = require 'd3'
path = require('path')


# set port
app.set 'port', 1337  

# set views
app.set 'views', "#{__dirname}/../views" 
app.set 'view engine', 'jade'

# Make it sexy ! bootstrap css & jquery js links
# Get /public/..
app.use '/public', express.static "#{__dirname}/../public"
# Get /styles/..
app.use '/styles', express.static "#{__dirname}/../styles"
# Get node_modules/...
app.use '/node_modules', express.static "#{__dirname}/../node_modules"
app.use '/views', express.static "#{__dirname}/../views"

#Posting metrics :  body-parser to parse the request’s body
app.use bodyParser.json()
app.use bodyParser.urlencoded()

app.listen app.get('port'), () ->
  console.log "server listening on #{app.get 'port'}"

#HOME PAGE
app.get '/', (req, res) -> 
  #res.end('Hello World\n');
  res.render 'index', {}

# Adding parameters in the routes
app.get '/hello/:name', (req, res) -> 
  res.send "Hello #{req.params.name}"

# Expose the metrics on the back-end
app.get '/metrics.json', (req, res) ->
  metrics.get_test (err, data) ->
    throw next err if err
    res.status(200).json data

# Get metrics from db
app.get '/my_metrics.json', (req, res) ->
  metrics.get '1','1','2016-01-09', (err, data) ->
    throw next err if err
    res.status(200).json data

# Get readStream from db
app.get '/my_many_metrics/:chart_id', (req, res) ->
  chart_id = req.params.chart_id.toString()
  console.log "hey"+ chart_id
  metrics.readStream '1',chart_id, (err, data) ->
    throw next err if err
    console.log 'test final: '+data+' '
    res.status(200).json data

# Get readStream from db
app.get '/nb_charts.json', (req, res) ->
  metrics.getNbChart '1', (err, data) ->
    throw next err if err
    console.log 'test : '+data+' '
    res.status(200).json data

#METRICS PAGE
app.get '/metrics', (req, res) -> 
  # Get number of charts
  metrics.getNbChart '1', (err, data) ->
    throw next err if err
    console.log 'test : '+data+' '
    res.render 'metrics', {pageData: { new_chart:''+(data+1)*1}}

app.post '/metrics', (req, res) -> 
  console.log req.body
  metrics.batch req.body, (err, value) ->
    throw err if err
    res.json value

#HOME PAGE
app.get '/edit/:chart_id', (req, res) -> 
  chart_id = req.params.chart_id
  res.render 'edit', {pageData: {chart_id : ''+chart_id}}

app.post '/edit/:chart_id', (req, res) ->
  chart_id = req.params.chart_id
  console.log req.body
  metrics.put 1,chart_id, req.body, (err, value) -> 
    throw err  if err
    res.json value


app.put '/', (req, res) -> 
  # PUT

app.delete '/:chart_id/:timestamp', (req, res) -> 
  # DELETE
  chart_id = req.params.chart_id
  timestamp = req.params.timestamp
  metrics.remove 1,chart_id,timestamp, req.body, (err) -> 
    throw err  if err
