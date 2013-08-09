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
    
    it 'Can receive messages from a server on the task port from the authorized source', ( done )->
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
      expect( client instanceof Backbone.Model ).to.equal true
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
        # storeTasks: ->
        #   super
        #   assert( @hasStoredTasks() is true, ' Should have stored tasks2 ')

        #   throw new Error('Stored tasks called')
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



    it 'Can be given a task to process and assign them to clients to complete on them connecting', (done)->
      # throw new Error('Test incomplete')
      class MyMaster extends ClientMaster
        onClientAdded: ->

          done()

      cm = new MyMaster( 
        port: 6000, 
        auth_port: 6001
        task_message_port: 6002
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
        port            : 4002
        secret_handshake: 'poop' 
        encryption_key  : 'hihi'
        server_address  : '0.0.0.0'
        auth_port       : 6001
        message_port    : 6002
      )
      
      taskMsg = JSON.stringify(
        tasks: [ v:1,v:2,v:3]
      )

      taskGiver.sendMessage( taskMsg, { port: 6002, address: '0.0.0.0' } )
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





