__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect
assert   = chai.assert
util = require 'util'
ClientMaster  = require '../../lib/server/ClientMaster'
Client = require '../../lib/Client'
UDPServer  = require '../../lib/UDP/EncryptedUDP'
Backbone = require '../../node_modules/backbone'
Task = require '../../lib/models/Task'

describe 'Client Test', ->
    it 'Should be there', (done) ->
      expect( typeof Client ).to.equal 'function'
      done()

    it 'Should be a constructor', (done) ->
      udp = new Client(
        port            : 4012
        secret_handshake: 'poop' 
        encryption_key  : 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
        master:
          server_address  : '0.0.0.0'
          auth_port       : 6011
          message_port    : 6012
          respond_port    : 6020
      )
      expect( udp instanceof Client ).to.equal true
      udp.destroy()
      done()
    
    it 'Can get master details', (done)->
      client = new Client(
        port            : 4022
        secret_handshake: 'poop' 
        encryption_key  : 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
        master: 
          server_address  : '0.0.0.0'
          auth_port       : 6021
          message_port    : 6022
          respond_port    : 6023
      )
      master = client.getMasterDetails()
      assert( typeof master is 'object', 'Returns an object' )
      assert( master.respond_port is 6023, 'Returns the correct response port' )
      assert( master.auth_port is 6021, 'Returns the correct auth port ' + master.auth_port )
      assert( master.message_port is 6022, 'Returns the correct auth port' )
      assert( master.server_address is '0.0.0.0', 'Returns the correct address')
      client.destroy()
      done()

    it 'Can message the master server through messageMaster', ( done )->
      class MasterSendMessage extends ClientMaster
        onMessageDecrypted: ( msg )->
          if !@countmsg
            @countmsg = 0
          @countmsg++
          if @countmsg is 2
            cm.destroy()
            client.destroy()
            done()

      cm = new MasterSendMessage( 
        port: 6020, 
        auth_port: 6021
        task_message_port: 6022
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )

      client = new Client(
        port            : 4022
        secret_handshake: 'poop' 
        encryption_key  : 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
        master:
          server_address  : '0.0.0.0'
          auth_port       : 6021
          message_port    : 6022
          respond_port    : 6020
      )
      client.sendMessage( 'hi', { port: 6020, address: '0.0.0.0' })
      client.messageMaster( 'hi2' )

    it 'A client will emit a task when received', (done)->
      cm = new ClientMaster( 
        port: 6020, 
        auth_port: 6021
        task_message_port: 6022
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )

      taskGiver = new UDPServer(
        port: '6999'
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )

      client = new Client(
        port            : 4022
        secret_handshake: 'poop' 
        encryption_key  : 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
        master:
          server_address  : '0.0.0.0'
          auth_port       : 6021
          message_port    : 6022
          respond_port    : 6020
      )
      
      taskMsg = JSON.stringify(
        tasks: [ v:1 ]
      )

      taskGiver.sendMessage( taskMsg, { port: 6022, address: '0.0.0.0' } )
      
      client.on 'task:received', ( task )->
        assert( task instanceof Task, 'Should be a task model')
        assert( task.isComplete() is false, 'The task should not yet be complete' )
        assert( !!task.get('task_id'), 'The task should have a task id' )
        assert( task.get('status') is 'pending', 'The task should have a pending status' )
        cm.destroy()
        client.destroy()
        taskGiver.destroy()
        done()

      client.authorize()

    it 'When a task is completed it will attempt to tell the master server about it', (done)->
      class MessageMaster extends Client
        sendMessage: ( msg )->
          client.destroy()
          done()

      client = new MessageMaster(
        port            : 4022
        secret_handshake: 'poop' 
        encryption_key  : 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
        master:
          server_address  : '0.0.0.0'
          auth_port       : 6021
          message_port    : 6022
          respond_port    : 6023
      )
      task = new Task( v:1 )

      client.on 'task:received', ( task )->
        task.complete()
        assert(task.get('status') is 'complete', 'Task should be marked as complete')    

      aTask = client.onTaskReceived( JSON.stringify(task.toJSON()) )
      assert( aTask instanceof Task, 'Should return the task model' )
