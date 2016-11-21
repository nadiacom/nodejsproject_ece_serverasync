# Import a module
http = require 'http'
user = require './user.coffee'
url = require 'url'
fs = require 'fs'
express = require 'express'
app = express()  

# set port
app.set 'port', 1337  

# set views
app.set 'views', "#{__dirname}/../views" 
app.set 'view engine', 'jade'

# Make it sexy ! bootstrap css & jquery js links
# Get /public/..
app.use '/public', express.static "#{__dirname}/../public"

app.listen app.get('port'), () ->
  console.log "server listening on #{app.get 'port'}"

app.get '/', (req, res) -> 
  #res.end('Hello World\n');
  res.render 'index', {}

# Adding parameters in the routes
app.get '/hello/:name', (req, res) -> 
  res.send "Hello #{req.params.name}"

app.post '/', (req, res) -> 
  # POST  

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
