BackboneModel = (require '../../node_modules/backbone').Model
Q = require '../../node_modules/Q'

module.exports = BackboneModel.extend(
    authenticated: false
    isAuthenticating: false
    constructor: ( address, port )->
      @tasks = []

    hasTask: ->
      return !!@tasks.length

    getTasks: ->
      return @tasks

    authenticate: ->
      @isAuthenticating = true
      return Q.deferred()

    sync: ->
)
