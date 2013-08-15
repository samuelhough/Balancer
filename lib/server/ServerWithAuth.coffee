AbstractMaster = require './AbstractMaster'
AuthServer = require './AuthServer'
Backbone = require '../../node_modules/backbone'
module.exports = class ServerWithAuth extends AbstractMaster
    server_name: 'ServerWithAuth'
    constructor: ( options )->
      super
      if !options
        throw 'ServerWithAuth: options required'
      if !options.auth_port
        throw "ServerWithAuth: options.auth_port required" 
      @auth_port = options.auth_port   
      @createAuthServer()

    createAuthServer: ->
      @auth_server = new AuthServer(
        secret_handshake: @secret_handshake
        port: @auth_port
        encryption_key: @encryption_key
      )
      @auth_server.on( 'client_authorized', ( rinfo, client ) =>
        if ( !client instanceof Backbone.Model )
          throw 'Not a bb model is not a client'
        @addClient( client )
        @emit 'client_authorized', rinfo
      ) 

    isAuthorized: ( address, port )->
      return !!@isAClient( address, port )

    destroy: ->
      super
      if @auth_server
        @auth_server.destroy()
      @auth_server = null