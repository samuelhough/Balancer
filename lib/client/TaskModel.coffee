BackboneModel = (require '../../node_modules/backbone').Model
Q = require '../../node_modules/Q'

module.exports = BackboneModel.extend(
    constructor: ->
      @deferred = Q.deferred()

    sync: ->

)
