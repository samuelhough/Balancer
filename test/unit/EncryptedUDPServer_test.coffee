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

    it 'Fires teh message decrypted event when a message is decrypted', ( done )->
      udp1 = new UDPServer( port: 3007, encryption_key: 'hihi' )
      udp2 = new UDPServer( port: 8000, encryption_key: 'hihi' )
      udp2.sendMessage( 'hi', { 
        host: '0.0.0.0',
        port: '3007' 
      })
      udp1.on 'msg_decrypted', ( msg )->
        expect( msg ).to.equal 'hi'
        udp1.destroy()
        udp2.destroy()
        done()


    it 'Will call unauthorizedMsg when the host and port do not align', ( done )->
      class child_server extends UDPServer
        unauthorizedMsg: ( msg, info )->
          udp1.destroy()
          udp2.destroy()
          done()
        decryptMessage: ->
          ## DECRYPT MESAGE SHOULD NOT BE CALLED
          expect( null ).to.equal true

      udp1 = new child_server( 
        authorized: { host: '0.0.0.0', port: '99999' }
        port: 3002, 
        encryption_key: 'hihi' 
      )
      udp2 = new UDPServer( 
        port: 8000, 
        encryption_key: 'hihi' 
      )

      udp2.sendMessage( 'hi', { 
        host: '0.0.0.0',
        port: '3002' 
      })

    it 'Will decrypt messages from authorized ports and not from unauthorized', ( done )->
      class child_server extends UDPServer
        unauthorizedMsg: (msg, host)->
          expect(host.port.toString()).to.equal '1111'
        onMessageDecrypted: ( msg, host )->
          expect(host.port.toString()).to.equal '2009'
          master.destroy()
          udp2.destroy()
          udp3.destroy()
          done()

      master = new child_server( 
        authorized: { host: '127.0.0.1', port: '2009' }
        port: 3002, 
        encryption_key: 'hihi' 
      )

      udp2 = new UDPServer( 
        port: 1111, 
        encryption_key: 'hihi' 
      )
      udp3 = new UDPServer( 
        port: 2009, 
        encryption_key: 'hihi' 
      )

      udp2.sendMessage( 'hi', { 
        host: '0.0.0.0',
        port: '3002' 
      })
      udp3.sendMessage( 'hi', { 
        host: '0.0.0.0',
        port: '3002' 
      })