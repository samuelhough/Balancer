Supervisor = require './Supervisor'
ClientCollection = require './ClientCollection'
TaskCollection = require '../Collections/TaskCollection'
EncryptedUDP = require '../UDP/EncryptedUDP'
_ = require '../../node_modules/underscore'
Task = require '../models/Task'

module.exports = class ClientMaster extends Supervisor
    server_name: 'ClientMaster'

    constructor: ->
      super
      @pending_tasks = new TaskCollection()

    # The point at which a message is received from another server giving orders
    taskMessageReceived: ( taskMsg )->
      tasks = @parseTasks( taskMsg )

      if tasks and tasks.length
        if @hasClients()
          @handOutTasks( tasks )
        else 
          @storeTasks( tasks )
      else
        @unableToParseTasks( taskMsg )

    storeTasks: ( tasks )->
      if !@task_queue
        @task_queue = []
      @task_queue = @task_queue.concat( tasks )

    hasStoredTasks: ->
      return !!(@task_queue and @task_queue.length > 0)

    handOutTasks: ( tasks )->
      _.each( tasks, ( task )=>
        if !(task instanceof Task)
          throw new Error(@server_name +": cannot send out something that is not a task")
        client = @findClientForTask()
        client.addTask( task )
        @addToPendingTasks( task )
        @messageClient( 'task:'+task.toJSON(), client )
      )

    addToPendingTasks: ( task )->  
      @pending_tasks.add(task)
      return task

    hasPendingTasks: ->
      !!@pending_tasks.models.length

    parseTasks: ( taskMsg )->
      taskObj = @createTaskObject( taskMsg )
      if !taskObj
        return null
      
      subdividedTasks = @subdivideTasks( taskObj.tasks )
      totalTasks = []
      for oneTask in subdividedTasks
        thisTask = @createTask( oneTask )
        thisTask.on('completed', @onTaskComplete, @)
        totalTasks.push( thisTask )
      return totalTasks

    onClientAdded: ( client )->
      super
      if @hasStoredTasks()
        @handOutTasks( @task_queue )
        @task_queue = []

    onTaskComplete: ( task )->

    createTask: ( taskMsg )->
      new Task( task: taskMsg )

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
      
    findClientForTask: ->
      noTasks = @clients.findClientsWithoutTask()
      if noTasks.length
        return noTasks.shift()
      return @clients.clientsByTasks().shift()

    unableToParseTasks: ( taskMsg, reason )->

