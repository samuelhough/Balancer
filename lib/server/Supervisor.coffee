ServerWithAuth = require './ServerWithAuth'
ClientCollection = require '../collections/ClientCollection'
EncryptedUDP = require '../UDP/EncryptedUDP'
_ = require '../../node_modules/underscore'

module.exports = class Supervisor extends ServerWithAuth
    server_name: 'Supervisor'
    constructor: ( options )->
      super
      if !options.task_message_port
        throw new Error('Supervisor: options.task_message_port required for receiving messages')
      if !options.authorized_server
        throw new Error('Suervisor: options.authorized_server { port: number, host: "0.0.0.0" }  ')

      @task_server = new EncryptedUDP(
        encryption_key: @encryption_key
        port: options.task_message_port
        authorized: options.authorized_server
      )
      @task_server.on('msg_decrypted', _.bind( @taskMessageReceived, @ ) )

    taskMessageReceived: ( taskMsg )->

    destroy: ->
      super
      if @task_server
        @task_server.destroy()
      @task_server = null
