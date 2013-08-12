dgram = require 'dgram'
_ = require '../../node_modules/underscore'
EventEmitter = require('events').EventEmitter
Q = require '../../node_modules/Q'

module.exports = class UDPServer extends EventEmitter
  udp_type: 'udp4'
  my_port: 8000
  my_host: '0.0.0.0'
  server_name: 'UDP_Server'
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
      throw "UDPServer: Host and port must be specified"
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
    @emit( 'message_received', msg, rinfo )

  onServerListening: ->
    address = @getAddress();
    console.log ' '
    console.log( String(@server_name + " Server listening on " + String(address.address + ":" + String(address.port).red).cyan ).green );

  sendMessage: ( msg, host )->
    deferred = Q.defer()
    message = new Buffer( msg );
    port = host.port
    address = host.host or host.address
    if !host
      throw new Error("sendMessage: Host object required to send message")
    if !port or !address 
      throw new Error("sendMessage: Port and address required via obj.host /obj.address and obj.port - host.address = #{host.address}, host.port = #{host.port}")

    # try
    @server.send(message, 0, message.length, port, address, (err, bytes) =>
      if err
        deferred.reject( err )
        @onErrorSendingMessage( msg, err, bytes )
      else
        deferred.resolve()
        @onSuccessSendingMessage( msg, bytes )
      
    )
    # catch e 
    #   console.log 'Error sending message'
     # deferred.reject( e )
      
    return deferred

  onErrorSendingMessage: ( msg, err, bytes )->
    console.log 'Error sending message'
    console.log arguments

  onSuccessSendingMessage: ( msg, bytes )->
    console.log ' '
    console.log '"'+String(msg).green+'" sent successfully'

  destroy: ->
    if @server
      @server.close()
    @server = null
    @connections_by_id = null
    @connections = null

