spy = require('redispy')
socketio = require('socket.io')

class RedispySocket
  constructor: ->
    @spy = null
    
  start: (app) =>
    io = socketio.listen(app)
    io.set('log level', 1);
    io.sockets.on 'connection', (socket) =>
      @socket = socket
      socket.on 'connect', this.connect
      socket.on 'disconect', this.stop
       
  connect: (config) =>
    this.stop  =>
      @spy = new spy(config.host, config.port, config.db)
      @spy.on 'data', (data) => @socket.emit('data', data);
      @spy.start()
      
  stop: (cb) =>
    if @spy?
      @spy.stop(cb) 
    else if cb?
      cb()
    
module.exports = RedispySocket