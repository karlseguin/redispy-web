express = require('express')
Socket = require('./lib/redispysocket')

app = module.exports = express.createServer()
app.use require('connect-assets')()
app.configure ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)

app.get '/', (req, res) ->
  res.render('home', {layout: false})

port = 4000
app.listen(port)
socket = new Socket()
socket.start(app)
console.log('running on http://localhost:%d',port)