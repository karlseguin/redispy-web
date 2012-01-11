$ ->
  class Socket
    connect: =>
      @socket = io.connect('http://localhost')
      @socket.emit 'connect', {host: $('#host').val(), port: $('#port').val(), db: $('#db').val()}
      @socket.on 'data', monitor.data
      @connected = true
      $('#submit').val('stop')
      @hitsInterval = setInterval(monitor.updateHits, 3000)
    
    disconnect: =>
      clearInterval(@hitsInterval) if @hitsInterval?
      @socket.removeListener 'data', monitor.data
      @connected = false
      $('#submit').val('monitor')
  
  class Monitor
    constructor: (@mbody, @topCommands, @topKeys) ->
      @commandHits = {}
      @keyHits = {}
      
    clear: =>
      @mbody.empty()
      @topCommands.empty()
      @topKeys.empty()
      @commandHits = {}
      @keyHits = {}

    data: (data) =>
      this.addRow(data)
      @commandHits[data.command] = 0 unless @commandHits[data.command]?
      @commandHits[data.command] += 1
      for key in data.keys
        @keyHits[key] = 0 unless @keyHits[key]?
        @keyHits[key] += 1
      
    addRow: (data) =>
      $row =  $('<div>')
      $('<div>').addClass('time').text(new Date(data.date).toLocaleTimeString()).appendTo($row)
      $('<div>').addClass('command').text(data.command).appendTo($row)
      $('<div>').addClass('key').text(data.keys.join(', ')).appendTo($row)
      $('<div>').addClass('arguments').text(data.arguments.join(', ')).appendTo($row)
      @mbody.prepend($row)
      @mbody.children(':gt(500)').remove()
         
    updateHits: =>
      this.displayTop(@topCommands, @commandHits)
      this.displayTop(@topKeys, @keyHits)
      
    displayTop: ($container, hits) =>
      $container.empty()
      sorted = Monitor.sort(hits).slice(0, 5)
      for v in sorted
        $item = $('<div>').addClass('hit')
        $('<div>').addClass('count').text(hits[v]).appendTo($item)
        $('<div>').addClass('item').text(v).appendTo($item)
        $container.append($item)
      
    @sort: (hits) ->
      sorted = []
      for o of hits
        sorted.push(o)
      sorted.sort (a,b) -> hits[b] - hits[a]
      
  monitor = new Monitor($('#mbody'), $('#topCommands > div'), $('#topKeys > div'))
  socket = new Socket()
  $('#toggle').on 'submit', ->
    if socket.connected then socket.disconnect() else socket.connect()
    false
    
  $('#mclear').on 'click', => monitor.clear()