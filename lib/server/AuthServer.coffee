ClientCollection = require './ClientCollection'
AbstractMaster = require './AbstractMaster'
Handshake = require '../controller/handshake'
module.exports = class AuthServer extends AbstractMaster
    server_name: 'AuthServer'
    constructor: (options)->
      super
      @handshaker = new Handshake( secret_handshake: @secret_handshake )

    onMessageReceived: ( msg, rinfo )->
      if !@isAClient( rinfo.address, rinfo.port ) 
        if @checkHandshake( msg )
          client = @addClient( rinfo.address, rinfo.port )
          @sendMessage( 'authorized', rinfo )
          @emit('client_authorized', rinfo, client )
        else
          @onHandshakeFail( rinfo )
          return null
      else
        @processMessage( msg, @getClientFromHeader( rinfo ) )

    checkHandshake: ( msg )->
      canBeAClient = false
      try
        handshake = @decryptMessage( msg )
        if @handshaker.isValid( handshake )
          canBeAClient = true
      catch e
        canBeAClient = false
        console.log e
        console.log 'Error decrypting message'
      
      return canBeAClient

    onHandshakeFail: ( rinfo ) ->

    processMessage: ( msg, rinfo )->