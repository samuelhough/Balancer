##TaskBalancer -
  Balance tasks between multiple clients over encrypted UDP

## Status
Completely broken and in progress at the moment


## Documentation

UDP Server Messaging (Without encryption)
--------------------
    #Sending the message
    UDPServer  = require '../lib/UDP/UDPServer'
    UDPServer1 = new UDPServer( port: 3000 )
    UDPServer1.sendMessage( 'hi', { 
      host: '0.0.0.0',
      port: '8000' 
    })
    UDPServer1.sendJSON(
      { 
        msg: hi 
      }, 
      { 
        host: '0.0.0.0',
        port: '8000' 
      }

    )


    # Receive the message
    UDPServer2 = new UDPServer( port: 8000 )
    UDPServer2.on( 'message_received', ( message, senderInfo)->
      console.log( "I received '#{message}' from #{senderInfo.address}:#{senderInfo.port}")
      @sendMessage( 'Hey I got your message UDPServer1', senderInfo )
    )

    #Destroying the servers
    UDPServer1.on('message_received', ->
      console.log( 'Example finished - destroying servers'.red)
      UDPServer1.destroy()
      UDPServer2.destroy()
      UDPServer2 = null
      UDPServer1 = null


## Examples
_(Coming soon)_

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History
_(Nothing yet)_

## License
Copyright (c) 2013 SamuelHough  
Licensed under the MIT license.
