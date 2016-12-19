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

# URL UTILS
# Get readStream from db
app.get '/my_many_metrics/:user_id/:chart_id', (req, res) ->
  chart_id = req.params.chart_id.toString()
  user_id = req.params.user_id.toString()
  metrics.readStream user_id,chart_id, (err, data) ->
    throw next err if err
    console.log data
    res.status(200).json data

# Get readStream from db
app.get '/nb_charts/:user_id', (req, res) ->
  user_id = req.params.user_id.toString()
  metrics.getNbChart user_id, (err, data) ->
    throw next err if err
    res.status(200).json data

# Check if user is already connected (session)
authCheck = (req, res, next) ->
  unless req.session.loggedIn == true
    res.redirect '/login'
  else
    next()

# HOME PAGE
# Render views
app.get '/', authCheck, (req, res) -> 
  # Get number of charts
  metrics.getNbChart req.session.username, (err, data) ->
    throw next err if err
    res.render 'index', {pageData: { new_chart:''+(data+1)*1}}

# Handling delete request
app.delete '/:user_id/:chart_id/:timestamp', (req, res) -> 
  # DELETE
  user_id = req.params.user_id
  chart_id = req.params.chart_id
  timestamp = req.params.timestamp
  metrics.remove user_id,chart_id,timestamp, req.body, (err) -> 
    throw err  if err

# EDIT CHART PAGE
# Render view
app.get '/edit/:chart_id', (req, res) -> 
  chart_id = req.params.chart_id
  res.render 'edit', {pageData: {chart_id : ''+chart_id}}

# Handling post requests : adding, removing metrics
app.post '/edit/:chart_id', (req, res) ->
  user_id = req.session.username
  chart_id = req.params.chart_id
  metrics.put user_id,chart_id, req.body, (err, value) -> 
    throw err  if err
    res.json value

# LOGIN PAGE
# Render view
app.get '/login', (req, res) ->
  res.render 'login'

# Handling post request : authentification
app.post '/login', (req, res) ->
  user.get req.body.username, (err, data) ->
    console.log  data
    return next err if err
    unless data.password == req.body.password
      res.redirect '/login'
    else
      req.session.loggedIn = true
      req.session.username = data.username
      # Set app.locals function, which acts as an object you can store values or functions in, and then makes them available to views
      req.app.locals.username = req.session.username
      res.redirect '/'

# LOGOUT
app.get '/logout', (req, res) ->
  delete req.session.loggedIn
  delete req.session.username
  res.redirect '/login'

# SIGNUP PAGE
# Render view
app.get '/signup', (req, res) ->
  res.render 'signup'

# Handling post request : subscription
app.post '/signup', (req, res) ->
  console.log req.body.username+req.body.password
  # Save new user on leveldb
  user.save req.body.username,req.body.password, (err, value) -> 
    throw err  if err
    # Open session
    req.session.loggedIn = true
    req.session.username = req.body.username
    # Set app.locals function, which acts as an object you can store values or functions in, and then makes them available to views
    req.app.locals.username = req.session.username
    # Redirect to batch metrics submission
    res.redirect '/signup/batch'

app.get '/signup/batch', (req, res) ->
  res.render 'batch'

# Handling post request : put many metrics (batch) on subscription
app.post '/signup/batch', (req, res) -> 
  console.log req.body.data
  metrics.batch req.body.data, (err, value) ->
    throw err if err
    # Redirect to dashboard
    res.redirect '/'
