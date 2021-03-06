__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect
assert   = chai.assert
util = require 'util'
ClientMaster  = require '../../lib/server/ClientMaster'
Client = require '../../lib/Client'
UDPServer  = require '../../lib/UDP/EncryptedUDP'
Backbone = require '../../node_modules/backbone'
Task = require '../../lib/models/Task'
TaskCollection = require '../../lib/collections/TaskCollection'


describe 'ClientMaster Test', ->
    it 'Should be there', (done) ->
      expect( typeof ClientMaster ).to.equal 'function'
      done()

    it 'Should be a constructor', (done) ->
      udp = new ClientMaster(
        port: 8000, 
        auth_port: 8001
        task_message_port: 8002
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'hihi'
      )
      expect(udp instanceof ClientMaster).to.equal true
      udp.destroy()
      done()
    
    it 'findClientForTask returns a client object ', ( done )->
      cm = new ClientMaster( 
        port: 8000, 
        auth_port: 8001
        task_message_port: 8002
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'hihi'
      )

      cm.addClient( '0.0.0.0', 3000 )
      cm.addClient( '0.0.0.0', 3001 )
      cm.addClient( '0.0.0.0', 3002 )
      client = cm.findClientForTask()
      assert( !!client, 'Did not return a client object')
      assert( client instanceof Backbone.Model, 'Is an instance of BB model');
      cm.destroy()
      done()

    it 'Can pick the right client based on the number of tasks the clients each have', (done)->
      class CM2 extends ClientMaster
        parseTasks: ( taskMsg )->
          return [ new Task(v:1),new Task(v:2),new Task(v:3),new Task(v:4),new Task(v:5)]

      cm = new CM2( 
        port: 8000, 
        auth_port: 8001
        task_message_port: 8002
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'hihi'
      )
      models = cm.clients.models
      cm.addClient( '0.0.0.0', 3000 )
      cm.addClient( '0.0.0.0', 3001 )
      cm.addClient( '0.0.0.0', 3002 )

      expect(models[0].tasks.length).to.equal 0
      cm.taskMessageReceived( 'hihi' )
      
      count = 0
      for mod in models
        count += mod.tasks.length 
      assert( count is 5, 'Five tasks were given out'  )
      assert(models[0].tasks.length is 2, 'Model 1 Given two tasks' )
      assert(models[1].tasks.length is 2, 'Model 2 Given two tasks' )
      assert(models[2].tasks.length is 1, 'Given one task' )
      cm.destroy()
      done()

    it 'Stored tasks test', (done)->
      class Stored extends ClientMaster
        unableToParseTasks: ( msg )->
          assert( false, "Could not parse #{msg}" )

        taskMessageReceived: ( taskMsg )->
          super
          tasks = @parseTasks( taskMsg )
          assert( tasks and tasks.length > 0, 'Tasks should have been returned')

          assert( @hasClients()  is false, 'Should not have any clients')
          assert( @hasStoredTasks() is true, ' Should have stored tasks ')
          cm.destroy()
          taskGiver.destroy()
          done()

      cm = new Stored( 
        port: 5000, 
        auth_port: 5001
        task_message_port: 5002
        authorized_server: 
          host: '127.0.0.1'
          port: '5999'
        secret_handshake: 'poop' 
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )

      taskGiver = new UDPServer(
        port: '5999'
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )
      taskMsg = JSON.stringify(
        tasks: [ v:1,v:2,v:3]
      )
      assert( typeof cm.hasStoredTasks is 'function', 'should have a hasStoredTasks method')
      assert( cm.hasStoredTasks() is false, ' Should not yet have stored tasks ')
      taskGiver.sendMessage( taskMsg, { port: 5002, address: '0.0.0.0' } )

    it 'Emits an event when tasks are stored', (done)->
      cm = new ClientMaster( 
        port: 5000, 
        auth_port: 5001
        task_message_port: 5003
        authorized_server: 
          host: '127.0.0.1'
          port: '5999'
        secret_handshake: 'poop' 
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )


      taskGiver = new UDPServer(
        port: '5999'
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )
      taskMsg = JSON.stringify(
        tasks: [ v:1,v:2,v:3]
      )
      cm.on('tasks_stored', ( tasks )->
        assert( cm.stored_tasks instanceof TaskCollection, 'Should be a task collection')
        assert( TaskCollection, 'Should be a task collection constructor')
        assert( tasks instanceof TaskCollection, 'Gives the task collection instance not a: '+ tasks )
        cm.destroy()
        taskGiver.destroy()
        done()
      )
      taskGiver.sendMessage( taskMsg, { port: 5003, address: '0.0.0.0' } )



    it 'Can be given a task to process and assign them to clients to complete on them connecting', (done)->
      class TaskReceiver extends Client
      cm = new ClientMaster( 
        port: 6010, 
        auth_port: 6011
        task_message_port: 6012
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )

      taskGiver = new UDPServer(
        port: '6999'
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )

      client = new TaskReceiver(
        port            : 4012
        secret_handshake: 'poop' 
        encryption_key  : 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
        master:
          respond_port    : 6020
          server_address  : '0.0.0.0'
          auth_port       : 6011
          message_port    : 6012
      )
      
      taskMsg = JSON.stringify(
        tasks: [ v:1,v:2,v:3]
      )

      taskGiver.sendMessage( taskMsg, { port: 6012, address: '0.0.0.0' } )
      assert( !cm.hasPendingTasks(), 'Should not have any pending tasks' )
      client.on 'task:received', ( task )->
        if cm.hasStoredTasks()
          throw new Error('Stored tasks should be handed out')
        assert( cm.hasPendingTasks(), 'Should have a pending task' )
        taskGiver.destroy()
        client.destroy()
        cm.destroy()
        done()

      client.authorize()

    it 'Can avoid flushing tasks if given the parameter autoFlushTasks as false', (done)->
      class TaskReceiver extends Client
      class NoFlush extends ClientMaster
        onClientAdded: ->
          super
          if !@hasStoredTasks()
            throw new Error('Should have stored tasks')
          cm.destroy()
          taskGiver.destroy()
          client.destroy()
          done()

      cm = new NoFlush( 
        port: 6010, 
        auth_port: 6011
        task_message_port: 6012
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
        autoFlushTasks: false
      )

      taskGiver = new UDPServer(
        port: '6999'
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )

      client = new TaskReceiver(
        port            : 4012
        secret_handshake: 'poop' 
        encryption_key  : 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
        master:
          respond_port    : 6020
          server_address  : '0.0.0.0'
          auth_port       : 6011
          message_port    : 6012
      )
      
      taskMsg = JSON.stringify(
        tasks: [ v:1,v:2,v:3]
      )

      taskGiver.sendMessage( taskMsg, { port: 6012, address: '0.0.0.0' } )
      client.on 'task:received', ( task )->
        throw new Error('Should not flush a task')

      client.authorize()

    it 'Will fire an event when all tasks are completed in a set of tasks', (done)->
      cm = new ClientMaster( 
        port: 6040, 
        auth_port: 6041
        task_message_port: 6042
        authorized_server: 
          host: '127.0.0.1'
          port: '5999'
        secret_handshake: 'poop' 
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )
      taskGiver = new UDPServer(
        port: '5999'
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )
      
      taskMsg = JSON.stringify(
        tasks: [ v:1 ]
      )

      taskGiver.sendMessage( taskMsg, { port: 6042, address: '0.0.0.0' } )

      cm.on('tasks_stored', ->
        assert(cm.task_sets.models.length, 'Should have task sets')
        assert( cm.task_sets.models[0].get('status'), 'Status should be pending' )
        assert( cm.task_sets.models[0].get('count'), 'Count should be 1' )
        cm.task_sets.models[0].complete()
      )
      cm.on('taskset:completed', ( taskSet ) ->
        cm.destroy()
        taskGiver.destroy()
        done()
      )

    it 'A master will update the task when it receives new info about the task', (done)->
      cm = new ClientMaster( 
        port: 6020, 
        auth_port: 6021
        task_message_port: 6022
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )

      taskGiver = new UDPServer(
        port: '6999'
        encryption_key: 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
      )

      client = new Client(
        port            : 4022
        secret_handshake: 'poop' 
        encryption_key  : 'o5S1kcZp32jWlAdI41sggnpz9vr4fHSA'
        master:
          respond_port    : 6020
          server_address  : '0.0.0.0'
          auth_port       : 6021
          message_port    : 6020
      )
      
      taskMsg = JSON.stringify(
        tasks: [ v:1 ]
      )

      taskGiver.sendMessage( taskMsg, { port: 6022, address: '0.0.0.0' } )

      
      client.on 'task:received', ( task )->
        task.complete()

      cm.on 'change:task_status', ( task) ->
        status = task.get('status')
        assert( status is 'complete', "Status shouldbe complete not #{status}")
        client.destroy()
        taskGiver.destroy()
        cm.destroy()
        done()

      client.authorize()

    it 'Destroy', (done)->
      udp1 = new ClientMaster( 
        port: 8000, 
        auth_port: 8001
        task_message_port: 8002
        authorized_server: 
          host: '127.0.0.1'
          port: '6999'
        secret_handshake: 'poop' 
        encryption_key: 'hihi'
      )
      udp1.destroy()
      expect( udp1.task_server).to.equal null
      done()
