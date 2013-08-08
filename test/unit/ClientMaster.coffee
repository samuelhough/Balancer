__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect
util = require 'util'
ClientMaster  = require '../../lib/server/ClientMaster'
Client = require '../../lib/Client'
UDPServer  = require '../../lib/UDP/EncryptedUDP'
Backbone = require '../../node_modules/backbone'

describe 'ClientMaster Test', ->
    it 'Should be there', (done) ->
      expect( typeof ClientMaster ).to.equal 'function'
      done()

    it 'Should be a constructor', (done) ->
      udp = new ClientMaster(
        port: 8000, 
        auth_port: 8001
        task_message_port: 8002
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'hihi'
      )
      expect(udp instanceof ClientMaster).to.equal true
      udp.destroy()
      done()
    
    it 'Can receive messages from a server on the task port from the authorized source', ( done )->
      cm = new ClientMaster( 
        port: 8000, 
        auth_port: 8001
        task_message_port: 8002
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'hihi'
      )

      cm.addClient( '0.0.0.0', 3000 )
      cm.addClient( '0.0.0.0', 3001 )
      cm.addClient( '0.0.0.0', 3002 )
      client = cm.findClientForTask()
      expect( client instanceof Backbone.Model ).to.equal true
      cm.destroy()
      done()

    it 'Destroy', (done)->
      udp1 = new ClientMaster( 
        port: 8000, 
        auth_port: 8001
        task_message_port: 8002
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'hihi'
      )
      udp1.destroy()
      expect( udp1.task_server).to.equal null
      done()





