###
Seperating this out in case the handshake needs to have complicated logic around it and shared between client and server
###


module.exports = class Handshake
  constructor: (options)->
    if !options or !options.secret_handshake
      throw "options.secret_handshake required"

    @secret_handshake = options.secret_handshake

  getHandshake: ->
    @secret_handshake

  isValid: ( handshake )->
    if handshake and handshake is @secret_handshake
      return true
    return false
