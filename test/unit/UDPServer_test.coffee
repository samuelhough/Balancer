__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect

UDPServer  = require '../../lib/UDP/UDPServer'

describe 'UDP Test', ->
    it 'Should be a constructor', (done) ->
      udp = new UDPServer()
      expect(udp instanceof UDPServer).to.equal true
      udp.destroy()
      done()
    
    it 'Can send a message and have it received between servers', ( done )->
      class child_server extends UDPServer
        onMessageReceived: ( msg, info )->
          expect(String(msg)).to.equal 'hi'
          udp1.destroy()
          udp2.destroy()
          done()

      udp1 = new child_server( port: 3000 )
      udp2 = new UDPServer( port: 8000 )
      udp2.sendMessage( 'hi', { 
        host: '0.0.0.0',
        port: '3000' 
      })
