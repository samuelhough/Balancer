ClientCollection = require './ClientCollection'
EncryptedUDPServer = require '../UDP/EncryptedUDP'

module.exports = class AbstractMaster extends EncryptedUDPServer
    server_name: 'AbstractMaster'
    constructor: ( options )->
      if !options
        throw 'options hash required'

      if !options.secret_handshake
        throw 'options.secret_handshake required'

      @secret_handshake = options.secret_handshake
      @clients = new ClientCollection()
      super
      
    getClientFromHeader: ( rinfo ) ->
      return @clients.getClient( rinfo.address, rinfo.port )

    addClient: ( address, port )->
      @clients.add( [ 
        {
          address: address
          port: port
        }
      ])
      @onClientAdded( @clients.getClient( address, port ) )

    onClientAdded: ( client )->

    isAClient: ( address, port )->
      return !!@clients.getClient( address, port )