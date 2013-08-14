__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect

Events = require('events').EventEmitter
UDPServer  = require '../../lib/UDP/UDPServer'



describe 'UDP Test', ->
    it 'Should be a constructor', (done) ->
      udp = new UDPServer()
      expect(udp instanceof UDPServer).to.equal true
      udp.destroy()
      done()
    it 'Is an instance of EventEmitter', ( done )->
      udp = new UDPServer()
      expect( udp instanceof Events ).to.equal true
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

    it 'Calling send message returns a deferred that resolves when passing', ( done )->
      udp1 = new UDPServer( port: 3000 )
      udp2 = new UDPServer( port: 8000 )
      def = udp2.sendMessage( 'hi', { 
        host: '0.0.0.0',
        port: '3000' 
      })
      def.promise.then( (msg)->
          udp1.destroy()
          udp2.destroy()
          done()
      )


    it 'Check that the test code in the readme works', ( done )->
        # From the server sending the message
        UDPServer1 = new UDPServer( port: 3016 )
        deferred = UDPServer1.sendMessage( 'hi', { 
          host: '0.0.0.0',
          port: '8015' 
        })
        UDPServer1.on('message_received', ( message, senderInfo )->
          assert( message is 'Hey I got your message UDPServer1', 'Should have received a message' )
          done()
        )

        # Receive the message
        UDPServer2 = new UDPServer( port: 8015 )
        UDPServer2.on( 'message_received', ( message, senderInfo) ->
          console.log( "I received '#{message}' from #{senderInfo.address}:#{senderInfo.port}")
          shouldBeMsg = 'hi'
          assert( typeof message is 'string', 'Type should be string  and not an object: '+ typeof message )
          assert( message is "hi", "Should be the same message received - '#{message}' != '#{shouldBeMsg}' #{message.length}")
          @sendMessage( 'Hey I got your message UDPServer1', senderInfo )
          assert( @ is UDPServer2, 'Scope without args should be the UDPServer firing the callback')
        )