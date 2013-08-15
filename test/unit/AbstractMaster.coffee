__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect
assert = chai.assert

Master  = require '../../lib/server/AbstractMaster'
UDPServer = require '../../lib/UDP/UDPServer'
EncryptedUDPServer = require '../../lib/UDP/EncryptedUDP'
Backbone = require '../../node_modules/backbone'
ClientModel = require '../../lib/models/Client'

describe 'AbstractMaster  Test', ->
    it 'Should be there', (done) ->
      expect( typeof Master ).to.equal 'function'
      done()

    it 'Should be a constructor', (done) ->
      udp = new Master(
        secret_handshake: 'poop'
        encryption_key: 'poopy'
      )
      expect(udp instanceof Master).to.equal true
      udp.destroy()
      done()
    
    it 'If a server config is provided the servers will show up in the client list', ( done )->
      udp = new Master(
        secret_handshake: 'poop'
        encryption_key: 'poopy'
        server_config: 'test/unit/server-config.json'
      )
      assert( udp.clients.models.length is 3, 'Should have loaded 3 clients' )
      udp.serverLoader.addServer( {
        name: 'NewServer'
        host: '0.0.0.0'
        port: '1237'
      })
      assert( udp.clients.models.length is 4, 'Should have loaded the fourth client from the pubsubemitted clients' )
      done()


    it 'Can send a message and have it received between servers', ( done )->
      class child_server extends Master
        onMessageDecrypted: ( msg, info )->
          expect(String(msg)).to.equal 'hi'
          udp1.destroy()
          udp2.destroy()
          done()

      udp1 = new child_server( encryption_key: 'poopy', port: 3000, secret_handshake: 'poop' )
      udp2 = new Master( encryption_key: 'poopy', port: 8000, secret_handshake: 'poop' )
      udp2.sendMessage( 'hi', { 
        host: '0.0.0.0',
        port: '3000' 
      })

    it 'Can determine if a port and address is a current client', ( done )->
      udp2 = new Master( encryption_key: 'poopy', port: 8000, secret_handshake: 'poop' )
      assert(udp2.isAClient( '0.0.0.0', 3000 ) is false, 'Should not be a client yet')
      udp2.addClient( '0.0.0.0', 3000 )
      assert(udp2.isAClient( '0.0.0.0', 3000 ) is true, 'Should be a client now')
      udp2.destroy()
      done()

    it 'Will return a client object when added', ( done )->
      udp1 = new Master( encryption_key: 'poopy', port: 8000, secret_handshake: 'poop' )
      udp2 = new Master( encryption_key: 'poopy', port: 8000, secret_handshake: 'poop' )
      assert(udp2.isAClient( '0.0.0.0', 3000 ) is false, 'Should not not yet be a client');
      client = udp2.addClient( '0.0.0.0', 3000 )
      assert(  client instanceof ClientModel, 'Is a client model object')
      client2 = udp1.addClient( '0.0.0.0', 30000 )
      udp2.addClient( client2 )
      assert( udp2.clients.models.length is 2, 'Should be two clients' )
      client3 = udp2.addClient( new ClientModel({ address: 'sdfdsfds', port: 'sdfdsfsd' }) )
      assert( client3 instanceof ClientModel, 'Client inserted from a client model should return a client model' )
      udp2.destroy()
      udp1.destroy()
      done()

    it 'Will call onClientAdded when one is added', ( done )->
      class Mini extends Master
        onClientAdded: (client)->
          expect( client instanceof Backbone.Model ).to.equal true
          udp1.destroy()
          done()

      udp1 = new Mini( encryption_key: 'poopy', port: 8000, secret_handshake: 'poop' )
      expect(udp1.isAClient( '0.0.0.0', 3000 )).to.equal false
      udp1.addClient( '0.0.0.0', 3000 )

    it 'Can message a client using only the model', ( done )->
      udp1 = new Master( encryption_key: 'poopy', port: 8000, secret_handshake: 'poop' )
      udp2 = new UDPServer( encryption_key: 'poopy', port: 3000, secret_handshake: 'poop' )
      udp1.addClient( '0.0.0.0', 3000 )
      udp1.messageClient( 'hibob', udp1.clients.models[0] )
      udp2.on('message_received', ( msg )->
        udp1.destroy()
        udp2.destroy()
        done()
      )

