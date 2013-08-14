##TaskBalancer -
  Balance tasks between multiple clients over encrypted UDP

  PRE - ALPHA

## Status
Completely broken and in progress at the moment


## Documentation

UDP Server Messaging (Without encryption)
--------------------
  # From the server sending the message
  UDPServer  = require 'lib/UDP/UDPServer'
  UDPServer1 = new UDPServer( port: 3000 )
  deferred = UDPServer1.sendMessage( 'hi', { 
    host: '0.0.0.0',
    port: '8000' 
  })
  deferred.promise.then( (msg)->
    UDPServer1.destroy()
    UDPServer1.destroy()
    done()
  )

  # Receive the message
  UDPServer  = require 'lib/UDP/UDPServer'
  UDPServer2 = new UDPServer( port: 8000 )
  UDPServer2.on( 'message_received', ( message, senderInfo)=>
    console.log( "I received '#{message}' from #{senderInfo.address}:#{senderInfo.port}")
    @sendMessage( 'Hey I got your message UDPServer1', senderInfo )
  )


## Examples
_(Coming soon)_

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History
_(Nothing yet)_

## License
Copyright (c) 2013 SamuelHough  
Licensed under the MIT license.
