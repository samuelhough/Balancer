UDPServer = require './UDPServer'
crypto = require 'crypto'
_ = require '../../node_modules/underscore'


module.exports = class EncryptedUDP extends UDPServer
  encryption_key: null
  cipher: 'aes-128-cbc'
  constructor: ( options )->
    if !options
      throw 'EncryptedUDP: Options hash required for instantiation'

    if !options.encryption_key
      throw 'EncryptedUDP: opts.encryption_key required'+ options.encryption_key

    if options.authorized
      @authorized_only = true
      @authorized = [].concat options.authorized

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
      cypher.setAutoPadding(true);
      encryptMessage = cypher.update( msg, 'utf8', 'hex' ) + cypher.final( 'hex' )

    @__sendMessage( encryptMessage, host )

  onMessageReceived: ( msg, host )->
    if @authorized_only
      if(!_.filter( @authorized, ( auth )->
          return auth.host is String(host.address) and String(auth.port) is String(host.port)
      ).length)
        @unauthorizedMsg( msg, host )
        return

    decrypted = @decryptMessage( msg )
    @onMessageDecrypted( decrypted, host )

  unauthorizedMsg: ( msg, host )->

  decryptMessage: ( encryptedMsg )->
    decipher = crypto.createDecipher( @cipher, @encryption_key )
    decipher.setAutoPadding(true);
    decryptedMessage = decipher.update(String(encryptedMsg), 'hex', 'utf8') + decipher.final('utf8');
 
  onMessageDecrypted: ( msg, host )->
    @emit( 'msg_decrypted', msg, host )
