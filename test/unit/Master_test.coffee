__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect

Master  = require '../../lib/Master'
Backbone = require '../../node_modules/backbone'

describe 'Master Server Test', ->
    it 'Should be there', (done) ->
      expect( typeof Master ).to.equal 'function'
      done()

    it 'Should be a constructor', (done) ->
      udp = new Master(
        secret_handshake: 'poop'
      )
      expect(udp instanceof Master).to.equal true
      udp.destroy()
      done()
    
    it 'Can send a message and have it received between servers', ( done )->
      class child_server extends Master
        onMessageReceived: ( msg, info )->
          expect(String(msg)).to.equal 'hi'
          udp1.destroy()
          udp2.destroy()
          done()

      udp1 = new child_server( port: 3000, secret_handshake: 'poop' )
      udp2 = new Master( port: 8000, secret_handshake: 'poop' )
      udp2.sendMessage( 'hi', { 
        host: '0.0.0.0',
        port: '3000' 
      })

    it 'Can determine if a port and address is a current client', ( done )->
      udp2 = new Master( port: 8000, secret_handshake: 'poop' )
      expect(udp2.isAClient( '0.0.0.0', 3000 )).to.equal false
      udp2.addClient( '0.0.0.0', 3000 )
      expect(udp2.isAClient( '0.0.0.0', 3000 )).to.equal true
      udp2.destroy()
      done()

    it 'Can determine if a port and address is a current client', ( done )->
      udp2 = new Master( port: 8000, secret_handshake: 'poop' )
      expect(udp2.isAClient( '0.0.0.0', 3000 )).to.equal false
      udp2.addClient( '0.0.0.0', 3000 )
      expect(udp2.isAClient( '0.0.0.0', 3000 )).to.equal true
      udp2.destroy()
      done()

    it 'Will return a client object when added', ( done )->
      udp1 = new Master( port: 8000, secret_handshake: 'poop' )
      udp2 = new Master( port: 8000, secret_handshake: 'poop' )
      expect(udp2.isAClient( '0.0.0.0', 3000 )).to.equal false
      client = udp2.addClient( '0.0.0.0', 3000 )
      expect( typeof client ).to.equal 'object'
      client2 = udp1.addClient( '0.0.0.0', 30000 )
      udp2.addClient( client2 )
      expect( udp2.clients.models.length ).to.equal 2
      udp2.destroy()
      udp1.destroy()
      done()

    it 'Will call onClientAdded when one is added', ( done )->
      class Mini extends Master
        onClientAdded: (client)->
          expect( client instanceof Backbone.Model ).to.equal true
          udp1.destroy()
          done()

      udp1 = new Mini( port: 8000, secret_handshake: 'poop' )
      expect(udp1.isAClient( '0.0.0.0', 3000 )).to.equal false
      udp1.addClient( '0.0.0.0', 3000 )
