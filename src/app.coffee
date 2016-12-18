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
morgan = require('morgan')
session = require 'express-session'
LevelStore = require('level-session-store')(session)

# set port
app.set 'port', 1337  

# set views
app.set 'views', "#{__dirname}/../views" 
app.set 'view engine', 'jade'

# Make it sexy ! bootstrap css & jquery js links
# Get /public/..
app.use '/public', express.static "#{__dirname}/../public"
# Get /public/..
app.use '/public/css', express.static "#{__dirname}/../public/css"

# Get /styles/..
app.use '/styles', express.static "#{__dirname}/../styles"
# Get node_modules/...
app.use '/node_modules', express.static "#{__dirname}/../node_modules"
# Get views/ ...
app.use '/views', express.static "#{__dirname}/../views"

#Posting metrics :  body-parser to parse the request’s body
app.use bodyParser.json()
app.use bodyParser.urlencoded()

# Use morgan middleware
app.use morgan 'dev'

# Use express session
app.use session
  secret: 'MyAppSecret'
  store: new LevelStore 'db/sessions'
  resave: true
  saveUninitialized: true

app.listen app.get('port'), () ->
  console.log "server listening on #{app.get 'port'}"

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
  metrics.get 'nadia','nadia','2016-01-09', (err, data) ->
    throw next err if err
    res.status(200).json data

# Get readStream from db
app.get '/my_many_metrics/:chart_id', (req, res) ->
  chart_id = req.params.chart_id.toString()
  console.log "hey"+ chart_id
  metrics.readStream 'nadia',chart_id, (err, data) ->
    throw next err if err
    console.log 'test final: '+data+' '
    res.status(200).json data

# Get readStream from db
app.get '/nb_charts.json', (req, res) ->
  metrics.getNbChart 'nadia', (err, data) ->
    throw next err if err
    console.log 'test : '+data+' '
    res.status(200).json data

# Check if user is already connected (session)
authCheck = (req, res, next) ->
  unless req.session.loggedIn == true
    res.redirect '/login'
  else
    next()

# HOME PAGE
app.get '/', authCheck, (req, res) -> 
  # Get number of charts
  metrics.getNbChart 'nadia', (err, data) ->
    throw next err if err
    console.log 'test : '+data+' '
    # Set app.locals function, which acts as an object you can store values or functions in, and then makes them available to views
    req.app.locals.username = req.session.username
    res.render 'index', {pageData: { new_chart:''+(data+1)*1}}

app.post '/', (req, res) -> 
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

app.get '/login', (req, res) ->
  res.render 'login'

app.post '/login', (req, res) ->
  user.get req.body.username, (err, data) ->
    console.log  data
    return next err if err
    unless data.password == req.body.password
      res.redirect '/login'
    else
      req.session.loggedIn = true
      req.session.username = data.username
      res.redirect '/'

app.get '/logout', (req, res) ->
  delete req.session.loggedIn
  delete req.session.username
  res.redirect '/login'

app.get '/signup', (req, res) ->
  res.render 'signup'

app.post '/signup', (req, res) ->
  console.log req.body.username+req.body.password
  # Save new user on leveldb
  user.save req.body.username,req.body.password, (err, value) -> 
    throw err  if err
    # Open session
    req.session.loggedIn = true
    req.session.username = req.body.username
    res.redirect '/'
