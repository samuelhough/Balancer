__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect

Master  = require '../../lib/Master'

describe 'Master Server Test', ->
    it 'Should be there', (done) ->
      expect( typeof Master ).to.equal 'function'
      done()

    it 'Should be a constructor', (done) ->
      udp = new Master()
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

      udp1 = new child_server( port: 3000 )
      udp2 = new Master( port: 8000 )
      udp2.sendMessage( 'hi', { 
        host: '0.0.0.0',
        port: '3000' 
      })

    it 'Can determine if a port and address is a current client', ( done )->
      udp2 = new Master( port: 8000 )
      expect(udp2.isAClient( '0.0.0.0', 3000 )).to.equal false
      udp2.addClient( '0.0.0.0', 3000 )
      expect(udp2.isAClient( '0.0.0.0', 3000 )).to.equal true
      udp2.destroy()
      done()