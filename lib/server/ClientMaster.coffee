Supervisor = require './Supervisor'
ClientCollection = require './ClientCollection'
EncryptedUDP = require '../UDP/EncryptedUDP'
_ = require '../../node_modules/underscore'

module.exports = class ClientMaster extends Supervisor
    server_name: 'ClientMaster'

    taskMessageReceived: ( taskMsg )->
      tasks = @parseTasks( taskMsg )

      _.each( tasks, ( task )=>
        client = @findClientForTask()
        client.addTask( task )
        @messageClient( 'task:'+task, client )
      )

    parseTasks: ( taskMsg )->
      throw new Error( "parseTasks must be overwritten in subclass.  Expected to return array of tasks")

    findClientForTask: ->
      noTasks = @clients.findClientsWithoutTask()
      if noTasks.length
        return noTasks.pop()
      return @clients.clientsByTasks().pop() or null



