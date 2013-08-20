ClientCollection = require '../collections/ClientCollection'
EncryptedUDPServer = require '../UDP/EncryptedUDP'
ClientModel = require '../models/Client'
_ = require '../../node_modules/underscore'

module.exports = class AbstractMaster extends EncryptedUDPServer
    server_name: 'AbstractMaster'
    constructor: ( options )->
      super
      if !options
        throw 'AbstractMaster: options hash required'

      if !options.secret_handshake
        throw 'AbstractMaster: options.secret_handshake required'

      @secret_handshake = options.secret_handshake
      @clients = new ClientCollection()

      preloadedServers = @serverLoader.getServers()
      @serverLoader.on('server_added', _.bind( @addClient, @ ) )
      if preloadedServers.length
        _.each( preloadedServers, ( client )=>
          @addClient( client )
        )
      
      
    getClientFromHeader: ( rinfo ) ->
      return @clients.getClient( rinfo.address, rinfo.port )

    addClient: ( address, port, client )->
      if (typeof address is 'string' or !address)
        if !address or !port
          throw new Error( "addClient: missing address:#{address} port:#{port}")
        client = new ClientModel(
          {
              address: address
              port: port
          }
        )  
      else
        client = address
      @clients.add( client )
      @onClientAdded( client )
      return client

    hasClients: ->
      return !!@clients.models.length

    onClientAdded: ( client )->

    isAClient: ( address, port )->
      return !!@clients.getClient( address, port )

    messageClient: ( message, client )->
      address = client.get('address');
      port = client.get('port');
      if !address or !port
        throw new Error("Client missing port #{port} or address #{address}")
      @sendMessage( message, { address: address, port: port } )


