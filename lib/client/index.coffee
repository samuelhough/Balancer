TaskCollection = require './TaskCollection'
EncryptedUDP = require '../UDP/EncryptedUDP'
Handshake = require '../controller/handshake'
module.exports = class Client extends EncryptedUDP
  authorized: false
  constructor: ( options )->
    super
    @validateOptions( options )
    @tasks = new TaskCollection()
    @handshaker = new Handshake( secret_handshake: options.secret_handshake )

  validateOptions: ( options )->
    if !options
      throw 'Client: Options required'

    if !options.auth_port
      throw 'Client: Options.auth_port required'

    if !options.message_port
      throw 'Client: Options.message_port required'

    if !options.server_address
      throw 'Client: Options.server_address required'
    
    @server_address = options.server_address
    @message_port   = options.message_port
    @auth_port      = options.auth_port

  isAuthorized: ->
    @authorized

  _authorize: ->
    @_authorized = true
    @emit('authorized', @)

  authorize: ->
    return @sendMessage( @handshaker.getHandshake(),  { host: @server_address, port: @auth_port } )

  onTaskReceived: ( task )->
    @emit( 'task:received', task )

  onMessageDecrypted: ( message, rinfo )->
    if !(typeof message is 'string')
      throw new Error('decrypted message must be a string')
    if message is 'authorized'
      @_authorize()
    if /task:/.test( message )
      [ prefix, task ] = message.split('task:')
      @onTaskReceived( message )
