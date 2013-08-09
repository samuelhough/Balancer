__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect
assert   = chai.assert
util = require 'util'
Supervisor  = require '../../lib/server/Supervisor'
Client = require '../../lib/Client'
UDPServer  = require '../../lib/UDP/EncryptedUDP'

describe 'Supervisor Test', ->
    it 'Should be there', (done) ->
      expect( typeof Supervisor ).to.equal 'function'
      done()

    it 'Should be a constructor', (done) ->
      udp = new Supervisor(
        port: 8000, 
        auth_port: 8001
        task_message_port: 8002
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'hihi'
      )
      expect(udp instanceof Supervisor).to.equal true
      udp.destroy()
      done()
    
    it 'Can receive messages from a server on the task port from the authorized source', ( done )->
      class Superman extends Supervisor 
        taskMessageReceived: ( msg )->
          expect( msg ).to.equal 'hi'
          done()

      superman = new Superman( 
        port: 8000, 
        auth_port: 8001
        task_message_port: 8002
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'hihi'
      )

      taskgiver = new UDPServer( port: 6999, encryption_key: 'hihi')
      taskgiver.sendMessage( 'hi', { 
        host: '0.0.0.0',
        port: '8002' 
      })


    it 'Destroy', (done)->
      udp1 = new Supervisor( 
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





