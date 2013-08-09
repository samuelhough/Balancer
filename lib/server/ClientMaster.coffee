Supervisor = require './Supervisor'
ClientCollection = require './ClientCollection'
EncryptedUDP = require '../UDP/EncryptedUDP'
_ = require '../../node_modules/underscore'
Task = require '../models/Task'

module.exports = class ClientMaster extends Supervisor
    server_name: 'ClientMaster'

    # The point at which a message is received from another server giving orders
    taskMessageReceived: ( taskMsg )->
      taskObject = @parseTasks( taskMsg )

      if tasks
        _.each( tasks, ( task )=>
          client = @findClientForTask()
          client.addTask( task )
          @messageClient( 'task:'+task, client )
        )

    parseTasks: ( taskMsg )->
      taskObj = @createTaskObject( taskMsg )
      if !taskObj
        return null
      
      subdividedTasks = @subdivideTasks( taskObj.tasks )
      totalTasks = []
      for oneTask in subdividedTasks
        totalTasks.push( @createTask( oneTask ) )
      return totalTasks

    createTask: ( taskMsg )->
      new Task( oneTask )

    subdivideTasks: ( singleTask )->
      singleTask

    # Determine how to return array of task objects here
    createTaskObject: ( taskMsg )->
      try
        taskObj = JSON.parse( taskMsg )
        if !taskObj.tasks or !Array.isArray( taskObj.tasks )
          @unableToParseTasks( taskMsg, 'taskobj.tasks is not an array' )
        if taskObj.tasks.length is 0
          @unableToParseTasks( taskMsg, 'taskobj.tasks is empty' )
      catch e
        @unableToParseTasks( taskMsg, e )
        return null
      
      return taskObj
      
    unableToParseTasks: ( taskMsg, reason )->

    findClientForTask: ->
      noTasks = @clients.findClientsWithoutTask()
      if noTasks.length
        return noTasks.shift()
      return @clients.clientsByTasks().shift()





