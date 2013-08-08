__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect
util = require 'util'
ServerWithAuth  = require '../../lib/server/ServerWithAuth'
EncryptedUDP = require '../../lib/UDP/EncryptedUDP'
Client = require '../../lib/Client'

describe 'ServerWithAuth Test', ->
    it 'Should be there', (done) ->
      expect( typeof ServerWithAuth ).to.equal 'function'
      done()

    it 'Should be a constructor', (done) ->
      udp = new ServerWithAuth(
        secret_handshake: 'poop'
        auth_port: 3005
        port: 3004
        encryption_key: 'hihi'
      )
      expect(udp instanceof ServerWithAuth).to.equal true
      udp.destroy()
      done()
    
    it 'Has a communication server and auth server', ( done )->
      udp1 = new ServerWithAuth( 
        port: 3000, 
        secret_handshake: 'poop' 
        auth_port: 3001
        encryption_key: 'hihi'
      )
      expect( udp1.server ).to.be.ok
      expect( udp1.auth_server.server ).to.be.ok
      udp1.destroy()
      expect( udp1.auth_server.server ).to.equal null
      expect( udp1.server ).to.equal null
      done()

    it 'A client can authorize with a server', ( done )->
      console.log 'hi'
      udp1 = new ServerWithAuth( 
        port: 8000, 
        secret_handshake: 'poop' 
        auth_port: 8001
        encryption_key: 'hihi'
      )
      client = new Client(
        port            : 3002
        secret_handshake: 'poop' 
        encryption_key  : 'hihi'
        server_address  : '0.0.0.0'
        auth_port       : 8001
        message_port    : 8000
      )
      count = 0
      udp1.on('client_authorized', ->
        count++
      )
      client.on('authorized', ->
        count++
        expect( count ).to.equal 2
        done()
      )
      client.authorize()



