Supervisor = require './Supervisor'
ClientCollection = require './ClientCollection'
TaskCollection = require '../collections/TaskCollection'
EncryptedUDP = require '../UDP/EncryptedUDP'
_ = require '../../node_modules/underscore'
Task = require '../models/Task'

module.exports = class ClientMaster extends Supervisor
    server_name: 'ClientMaster'
    autoFlushTasks: true # Set to false if you want tasks to only be flushed by you
    constructor: (options)->
      super
      if typeof options.autoFlushTasks != 'undefined'
        @autoFlushTasks = options.autoFlushTasks

      @pending_tasks = new TaskCollection()
      @stored_tasks  = new TaskCollection()

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
      taskQueue = [].concat tasks
      @stored_tasks.add( taskQueue )
      if @hasStoredTasks()
        @emit('tasks_stored', @stored_tasks )

    hasStoredTasks: ->
      return !!( @stored_tasks.models.length > 0 )

    handOutTasks: ( tasks )->
      _.each( tasks, ( task )=>
        if !(task instanceof Task)
          throw new Error(@server_name +": cannot send out something that is not a task")
        client = @findClientForTask()
        client.addTask( task )
        @addToPendingTasks( task )
        @messageClient( 'task:'+JSON.stringify(task.toJSON()), client )
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
        thisTask.on('change:status', @onTaskStatusChange, @)
        totalTasks.push( thisTask )
      return totalTasks

    flushStoredTasks: ->
      tasksToHandOut = @stored_tasks.models
      @stored_tasks = new TaskCollection()
      @handOutTasks( tasksToHandOut )

    onClientAdded: ( client )->
      super
      if @hasStoredTasks() and @autoFlushTasks
        @flushStoredTasks()


    onTaskStatusChange: ( task )->
      @emit( 'change:task_status', task )

    createTask: ( task_details )->
      new Task( status: 'pending', task_details: task_details, task_id: "tid_"+@generateGuid() )

    subdivideTasks: ( singleTask )->
      singleTask

    onMessageDecrypted: ( msg, rhost )->
      super
      if /task:/.test( msg )
        @updateTask( msg.split('task:')[1] )
        
    updateTask: ( taskJSON )->
      task = JSON.parse( taskJSON )
      model = @pending_tasks.findWhere( { task_id: task.task_id } )
      for key of task
        model.set( key, task[key] )


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

