ClientCollection = require './ClientCollection'
UDPServer = require '../UDP/UDPServer'
module.exports = class Server extends UDPServer
    constructor: ->
      @clients = new ClientCollection()
      super

    authenticateClient: ( client )->
      deferred = client.authenticate()
      deferred.promise.then(
        ( args, details )->
          @insertClient( client )
        ( err )->
          console.log 'Client not valid'
          console.log err
      )
      deferred

    onMessageReceived: ( msg, rinfo )->
     # if !@isAClient( rinfo.address, rinfo.port ) and String( msg ) is @handshake_key



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