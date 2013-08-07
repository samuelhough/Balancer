dgram = require 'dgram'
_ = require '../../node_modules/underscore'

module.exports = class UDPServer
  udp_type: 'udp4'
  my_port: 8000
  my_host: '0.0.0.0'
  constructor: ( options )->
    if options 
      if options.port
        @my_port = options.port
      if options.host
        @my_host = options.host

    @connections = []
    @connections_by_id = {}
    @createServer()
    if options
      if options.connectTo
        @connect( options.connectTo.host, options.connectTo.port ) 

  createServer: ->
    @server = dgram.createSocket(@udp_type)
    @server.on("message",   _.bind(  @onMessageReceived, @ ) )
    @server.on("listening",  _.bind(  @onServerListening, @ ) )
    @server.bind( @my_port, @my_host )

  saveAddress: ( host, port )->
    if !host or !port
      throw "Host and port must be specified"
    id = "id_"+(Math.random() * 10000000)
    connection = 
      id  : id
      host: host
      port: port
    @connections.push connection
    @connections_by_id[id] = connection

  getAddress: ->
    @server.address()

  onMessageReceived: (msg, rinfo) ->
    console.log( String("Server received: " + msg + " from " + String(rinfo.address).red + ":" + String(rinfo.port).green).yellow );

  onServerListening: ->
    address = @getAddress();
    console.log ' '
    console.log( String("UDP Server listening on " + String(address.address + ":" + String(address.port).red).cyan ).green );

  sendMessage: ( msg, host )->
    message = new Buffer( msg );
    port = host.port
    address = host.host
    @server.send(message, 0, message.length, port, address, (err, bytes) =>
      if err
        @onErrorSendingMessage( msg, err, bytes )
      else
        @onSuccessSendingMessage( msg, bytes )
      
    )

  onErrorSendingMessage: ( msg, err, bytes )->
    console.log 'Error sending message'
    console.log arguments

  onSuccessSendingMessage: ( msg, bytes )->
    console.log ' '
    console.log '"'+String(msg).green+'" sent successfully'

  destroy: ->
    @server.close()
    @server = null
    @connections_by_id = null
    @connections = null

