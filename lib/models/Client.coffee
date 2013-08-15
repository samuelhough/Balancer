Backbone = require '../../node_modules/backbone'
Q = require '../../node_modules/Q'
TaskCollection = require '../collections/TaskCollection'

module.exports = Backbone.Model.extend(
    authenticated: false
    isAuthenticating: false
    initialize: ()->
      @tasks = new TaskCollection()
      if !@get('name')
        @set( 'name', @createName() )

    createName: ->
      "Client_"+@get('host')+':'+@get('port')

    addTask: ( task )->
      @tasks.add( task )

    numTasks: ->
      @tasks.models.length 

    hasTask: ->
      return !!@tasks.models.length

    getTasks: ->
      return @tasks.models

    authenticate: ->
      @isAuthenticating = true
      return Q.deferred()

    sync: ->
)
