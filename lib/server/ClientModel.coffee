Backbone = require '../../node_modules/backbone'
Q = require '../../node_modules/Q'

module.exports = Backbone.Model.extend(
    authenticated: false
    isAuthenticating: false
    initialize: ()->
      @tasks = []

    addTask: ( task )->
      @tasks.push( task )

    numTasks: ->
      @tasks.length 

    hasTask: ->
      return !!@tasks.length

    getTasks: ->
      return @tasks

    authenticate: ->
      @isAuthenticating = true
      return Q.deferred()

    sync: ->
)
