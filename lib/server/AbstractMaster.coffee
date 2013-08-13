ClientCollection = require './ClientCollection'
EncryptedUDPServer = require '../UDP/EncryptedUDP'
ClientModel = require './ClientModel'

module.exports = class AbstractMaster extends EncryptedUDPServer
    server_name: 'AbstractMaster'
    constructor: ( options )->
      if !options
        throw 'AbstractMaster: options hash required'

      if !options.secret_handshake
        throw 'AbstractMaster: options.secret_handshake required'

      @secret_handshake = options.secret_handshake
      @clients = new ClientCollection()
      super
      
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

    generateGuid: ->
      "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace /[xy]/g, (c) ->
        r = Math.random() * 16 | 0
        v = (if c is "x" then r else (r & 0x3 | 0x8))
        v.toString 16

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


