__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect
util = require 'util'
Supervisor  = require '../../lib/server/Supervisor'
Client = require '../../lib/Client'

describe 'Supervisor Test', ->
    it 'Should be there', (done) ->
      expect( typeof Supervisor ).to.equal 'function'
      done()

    it 'Should be a constructor', (done) ->
      udp = new Supervisor(
        secret_handshake: 'poop'
        auth_port: 3005
        port: 3004
        task_message_port: 3006
        encryption_key: 'hihi'
      )
      expect(udp instanceof Supervisor).to.equal true
      udp.destroy()
      done()
    
    it 'A client can authorize with a server', ( done )->
      console.log 'hi'
      udp1 = new Supervisor( 
        port: 8000, 
        secret_handshake: 'poop' 
        auth_port: 8001
        task_message_port    : 8002
        encryption_key: 'hihi'
      )
      expect(typeof udp1.task_server).to.equal 'object'
      udp1.destroy()
      done()

    it 'Destroy', (done)->
      udp1 = new Supervisor( 
        port: 8000, 
        secret_handshake: 'poop' 
        auth_port: 8001
        task_message_port    : 8002
        encryption_key: 'hihi'
      )
      udp1.destroy()
      expect( udp1.task_server).to.equal null
      done()





