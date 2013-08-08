UDPServer = require './UDPServer'
crypto = require 'crypto'

module.exports = class EncryptedUDP extends UDPServer
  encryption_key: null
  cipher: 'aes-128-cbc'
  constructor: ( options )->
    if !options
      throw 'Options hash required for instantiation'

    if !options.encryption_key
      throw 'opts.encryption_key required'+ options.encryption_key


    if options.cipher
        @cipher = options.cipher

    @encryption_key = options.encryption_key
    sendMessage = @sendMessage
    @sendMessage = @encryptMessage
    @__sendMessage = sendMessage
    super

  encryptMessage: ( msg, host ) ->
    encryptMessage = msg
    if @encryption_key
      cypher = crypto.createCipher( @cipher, @encryption_key )
      cypher.update( msg, 'utf8', 'base64' )
      encryptMessage = cypher.final( 'base64' )

    @__sendMessage( encryptMessage, host )

  onMessageReceived: ( msg, host )->
    decrypted = @decryptMessage( msg )
    @onMessageDecrypted( decrypted, host )


  decryptMessage: ( msg )->
    decipher = crypto.createDecipher( @cipher, @encryption_key )
    decipher.update( String(msg), 'base64', 'utf8' )
    decryptedMessage = decipher.final( 'utf8' )

 
  onMessageDecrypted: ( msg, host )->
