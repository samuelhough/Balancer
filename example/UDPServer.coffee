# From the server sending the message
UDPServer  = require '../lib/UDP/UDPServer'
UDPServer1 = new UDPServer( port: 3000 )
UDPServer1.sendMessage( 'hi', { 
  host: '0.0.0.0',
  port: '8000' 
})


# Receive the message
UDPServer2 = new UDPServer( port: 8000 )
UDPServer2.on( 'message_received', ( message, senderInfo)->
  console.log( "I received '#{message}' from #{senderInfo.address}:#{senderInfo.port}")
  @sendMessage( 'Hey I got your message UDPServer1', senderInfo )
)


UDPServer1.on('message_received', ->
  console.log( 'Example finished - destroying servers'.red)
  UDPServer1.destroy()
  UDPServer2.destroy()
  UDPServer2 = null
  UDPServer1 = null
)