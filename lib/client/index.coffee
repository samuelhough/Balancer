TaskCollection = require '../Collections/TaskCollection'
EncryptedUDP = require '../UDP/EncryptedUDP'
Handshake = require '../controller/handshake'
TaskModel = require '../models/Task'
_ = require '../../node_modules/underscore'

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

    if !options.master or !(typeof options.master is 'object')
      throw 'Client: master object required'

    if !options.master.auth_port
      throw 'Client: Options.auth_port required'

    if !options.master.message_port
      throw 'Client: Options.message_port required'

    if !options.master.server_address
      throw 'Client: Options.server_address required'

    if !options.master.respond_port
      throw 'Client: options.respond_port required (the port to report all task messages back to)'
    
    @master = options.master
    @server_address = options.master.server_address
    @respond_port   = options.master.respond_port
    @message_port   = options.master.message_port
    @auth_port      = options.master.auth_port

  isAuthorized: ->
    @authorized

  _authorize: ->
    @_authorized = true
    @emit('authorized', @)

  getMasterDetails: ->
    return {
      respond_port: @respond_port
      message_port: @message_port
      auth_port: @auth_port
      server_address: @server_address
    }

  authorize: ( msg )->
    @sendMessage( @handshaker.getHandshake(),  { host: @server_address, port: @auth_port } )

  messageMaster: ( msg ) ->
    @sendMessage( msg,  { host: @server_address, port: @respond_port } )

  onTaskReceived: ( taskJSON )->
    task = @createTaskModel( taskJSON )
    task.on('change:status', @sendTaskData, @)
    @emit( 'task:received', task )
    task
    
  sendTaskData: ( task )->
    @messageMaster( 'task:'+JSON.stringify(task.toJSON()) )

  createTaskModel: ( taskJSON )->
    taskModel = JSON.parse( taskJSON )
    return new TaskModel( taskModel )

  onMessageDecrypted: ( message, rinfo )->
    if !(typeof message is 'string')
      throw new Error('decrypted message must be a string')
    if message is 'authorized'
      @_authorize()
    if /task:/.test( message )
      [ prefix, task ] = message.split('task:')
      @onTaskReceived( task )
