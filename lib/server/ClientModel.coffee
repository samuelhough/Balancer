Backbone = require '../../node_modules/backbone'
Q = require '../../node_modules/Q'

module.exports = Backbone.Model.extend(
    authenticated: false
    isAuthenticating: false
    constructor: ( address, port )->
      @tasks = []
      Backbone.Model.apply( @, arguments )

    addTask: ( task )->
      @tasks.push( task )

    hasTask: ->
      return !!@tasks.length

    getTasks: ->
      return @tasks

    authenticate: ->
      @isAuthenticating = true
      return Q.deferred()

    sync: ->
)
