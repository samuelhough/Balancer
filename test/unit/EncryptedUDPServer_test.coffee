__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect

UDPServer  = require '../../lib/UDP/EncryptedUDP'

describe 'Encrypted UDP Test', ->
    it 'Should be a constructor', (done) ->
      udp = new UDPServer(
        encryption_key: 'hihi'
      )
      expect(udp instanceof UDPServer).to.equal true
      udp.destroy()
      done()

    it 'Can send a message and have it received between servers and it be encrypted', ( done )->
      class child_server extends UDPServer
        onMessageReceived: ( msg, info )->
          expect(String(msg)).to.equal '/f6gP8mLGCJBTnY9vP9ybA=='
          udp1.destroy()
          udp2.destroy()
          done()

      udp1 = new child_server( port: 3001, encryption_key: 'hihi' )
      udp2 = new UDPServer( port: 8000, encryption_key: 'hihi' )
      udp2.sendMessage( 'hi', { 
        host: '0.0.0.0',
        port: '3001' 
      })

    it 'Can decrypt the message sent between servers', ( done )->
      class child_server extends UDPServer
        onMessageDecrypted: ( msg, info )->
          expect(String(msg)).to.equal 'hi'
          udp1.destroy()
          udp2.destroy()
          done()

      udp1 = new child_server( port: 3002, encryption_key: 'hihi' )
      udp2 = new UDPServer( port: 8000, encryption_key: 'hihi' )
      udp2.sendMessage( 'hi', { 
        host: '0.0.0.0',
        port: '3002' 
      })
