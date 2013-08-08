AbstractMaster = require './AbstractMaster'
AuthServer = require './AuthServer'

module.exports = class ServerWithAuth extends AbstractMaster
    server_name: 'ServerWithAuth'
    constructor: ( options )->
      super
      if !options
        throw 'options required'
      if !options.auth_port
        throw "options.auth_port required" 
      @auth_port = options.auth_port   
      @createAuthServer()

    createAuthServer: ->
      @auth_server = new AuthServer(
        secret_handshake: @secret_handshake
        port: @auth_port
        encryption_key: @encryption_key
      )
      @auth_server.on( 'client_authorized', ( rinfo ) =>
        @emit 'client_authorized', rinfo
      )

    onMessageReceived: ( msg, rinfo )->
      if @isAuthorized( rinfo.address, rinfo.port ) 
        @processMessage( msg, @getClientFromHeader( rinfo ) )  

    isAuthorized: ( address, port )->
      return !!@auth_server.isAClient( address, port )


    destroy: ->
      super
      @auth_server.destroy()