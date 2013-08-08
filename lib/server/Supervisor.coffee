ServerWithAuth = require './ServerWithAuth'
ClientCollection = require './ClientCollection'
EncryptedUDP = require '../UDP/EncryptedUDP'
_ = require '../../node_modules/underscore'

module.exports = class Supervisor extends ServerWithAuth
    server_name: 'Supervisor'
    constructor: ( options )->
      super
      if !options.task_message_port
        throw new Error('Supervisor: options.task_message_port required for receiving messages')

      @task_server = new EncryptedUDP(
        encryption_key: @encryption_key
        port: options.task_message_port
      )
      @task_server.on('msg_decrypted', _.bind( @parseMessage, @ ) )

    parseMessage: ( task )->




    destroy: ->
      super
      @task_server.destroy()
      @task_server = null
