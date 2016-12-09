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
  metrics.get (err, data) ->
    throw next err if err
    res.status(200).json data
    console.log "got param :"

#METRICS PAGE
app.get '/metrics', (req, res) -> 
  res.render 'metrics', {}

app.post '/metrics', (req, res) -> 
  console.log req.body
  metrics.batch req.body, (err, value) ->
    throw err if err
    res.json value

app.put '/', (req, res) -> 
  # PUT

app.delete '/', (req, res) -> 
  # DELETE



# Without Express : OLD
# Declare an http server
# http.createServer (req, res) ->

#  path = url.parse(req.url).pathname

#  user.get "cesar", (id) ->
    # Write a response header
#    res.writeHead 200,
#      'Content-Type': 'text/plain'

    # Write a response content
    #res.end('Hello World\n');`
#    res.end "hello #{id}" # "hello" + id

# Start the server
# .listen 1337, '127.0.0.1', () ->
#  console.log "running on 127.0.0.1:1337"
