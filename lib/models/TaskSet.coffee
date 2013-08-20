Backbone = require '../../node_modules/backbone'
TaskCollection = require '../collections/TaskCollection'
util = require '../util/index'

module.exports = Backbone.Model.extend(
    initialize: ->
      @tasks = new TaskCollection()
      @set( 'task_set_id', util.generateGuid() )
      @set( 'status', 'pending' )
      @set( 'count', 0 )
      @set( 'success', true )
      @tasks.on( 'add', @onTaskAdded, @ ) 
      @on( 'change:count' , @onCountChange, @)

    add: ( task )->
      @tasks.add( task )

    getId: ->
      @get('task_set_id')

    onTaskAdded: ( task )->
      @set('count', ( @get('count') + 1 ) )
      task.set( 'task_set_id', @get('task_set_id') )
      task.on( 'change:status', @onTaskStatusChange, @ )

    onTaskStatusChange: ( task, status )->
      status = task.get('status')

      if status is 'complete'
        @set( 'count', ( @get('count') - 1) )
      else 
        @set( 'success', false )

    onCountChange: ->
      if @get('count') is 0
        @complete()
      
    complete: ()->
      @tasks = null
      @set('status', 'complete')
      @trigger('completed', @)

    getId: ->
      @get('task_set_id')

    isComplete: ->
      return this.get('status') is 'complete'
    
    sync: ->
)
