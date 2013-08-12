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
        server_address  : '0.0.0.0'
        auth_port       : 6011
        message_port    : 6012
      )
      expect( udp instanceof Client ).to.equal true
      udp.destroy()
      done()
    

    it 'Can be given a task to process and assign them to clients to complete on them connecting', (done)->
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
        server_address  : '0.0.0.0'
        auth_port       : 6021
        message_port    : 6022
      )
      
      taskMsg = JSON.stringify(
        tasks: [ v:1 ]
      )

      taskGiver.sendMessage( taskMsg, { port: 6022, address: '0.0.0.0' } )
      
      client.on 'task:received', ( task )->
        assert( task instanceof Task, 'Should be a task model')
        done()

      client.authorize()
     
