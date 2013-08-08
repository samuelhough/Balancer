ClientCollection = require './ClientCollection'
UDPServer = require '../UDP/UDPServer'
BackboneModel = (require '../../node_modules/backbone').Model
module.exports = class Server extends UDPServer
    constructor: ( options )->
      if !options
        throw 'Server/Index : options hash required'

      if !options.secret_handshake
        throw 'Server/Index : options.secret_handshake required'

      @clients = new ClientCollection()
      super

    onMessageReceived: ( msg, rinfo )->
      if !@isAClient( rinfo.address, rinfo.port ) 
        if @checkHandshake( msg )
          @addClient( rinfo.address, rinfo.port )
        else
          @onHandshakeFail( rinfo )
          return null
      else
        @processMessage( msg, @getClientFromHeader( rinfo ) )
    
    onHandshakeFail: ( rinfo ) ->

    processMessage: ( msg, rinfo )->

    checkHandshake: ( msg )->
      canBeAClient = false
      try
        handshake = @decryptMessage( msg )
        if handshake is @secret_handshake
          canBeAClient = true
      catch e
        canBeAClient = false
      
      return canBeAClient
      
    getClientFromHeader: ( rinfo ) ->
      return @clients.getClient( rinfo.address, rinfo.port )

    addClient: ( address, port, client )->
      if address instanceof BackboneModel
        @clients.add address
        client = address
      else
        @clients.add( [ 
          {
            address: address
            port: port
          }
        ])
        client = @clients.getClient( address, port )

      @onClientAdded( client )
      client

    messageClient: ( message, client )->
      @sendMessage( message, { host: client.get('address'), port: client.get('port') } )

    onClientAdded: ( client )->

    isAClient: ( address, port )->
      return !!@clients.getClient( address, port )

    destroy: ->
      super
      @clients = null