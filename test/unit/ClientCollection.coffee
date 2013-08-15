__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect
assert   = chai.assert

Backbone = require '../../node_modules/backbone'
ClientCollection  = require '../../lib/server/ClientCollection'
ClientModel  = require '../../lib/models/Client'

describe 'ClientCollection', ->
    it 'Should be a constructor', (done) ->
      col = new ClientCollection()
      expect(col instanceof ClientCollection).to.equal true
      done()

    it 'Should have a collection for the number of clients', (done) ->
      col = new ClientCollection()
      expect(col instanceof Backbone.Collection).to.equal true
      done()

    it 'Adding a json object client should create a ClientModel', (done) ->
      col = new ClientCollection()
      col.add( [ 
          {
            address: '0.0.0.0'
            port: '1234'
          }
      ])
      model = col.models[0]
      expect( model instanceof ClientModel ).to.equal true
      expect( typeof model.getTasks ).to.equal 'function'
      done()

    it 'Can get models without tasks', (done) ->
      col = new ClientCollection()
      col.add( [ 
          {
            address: '0.0.0.0'
            port: '1234'
          }
          {
            address: '0.0.0.0'
            port: '1232'
          }
          {
            address: '0.0.0.0'
            port: '1233'
          }
      ])
      ntask = col.findClientsWithoutTask()
      expect(ntask.length).to.equal 3
      col.models[0].addTask( 'd' )
      ntask = col.findClientsWithoutTask()
      expect(ntask.length).to.equal 2
      done()

    it 'Can get models by number of tasks', (done) ->
      col = new ClientCollection()
      col.add( [ 
          {
            pos: 1
            address: '0.0.0.0'
            port: '1234'
          }
          {
            pos: 2
            address: '0.0.0.0'
            port: '1232'
          }
          {
            pos: 3
            address: '0.0.0.0'
            port: '1233'
          }
      ])
      models = col.clientsByTasks()
      assert(models.length is 3, 'There should be three models')
      col.models[0].addTask( 'a' )

      assert(col.models[0].tasks.length is 1, 'There should be one task added')
      assert(col.models[0].get('pos') is 1, 'The first model should be at position 0')
      
      models = col.clientsByTasks()
      assert( models.length is 3, 'There should be three models' )
      assert( models[0].tasks.length is 0, 'The first model should not have any tasks' )
      assert( models[1].tasks.length is 0, 'The second model should not have any tasks' )
      assert( models[2].tasks.length is 1, 'The third model should have one' )


      col.models[1].addTask( 'b' )
      col.models[2].addTask( 'c' )

      models = col.clientsByTasks()
      assert(col.models[0].get('pos') is 1, 'The first model is still at position 0 in the collectoin')
      assert( models.length is 3 , 'There should be three models')

      assert( models[0].tasks.length is 1, 'There should only be one task'  )
      assert( models[1].tasks.length is 1 , 'There should only be one task'  )
      assert( models[2].tasks.length is 1 , 'There should only be one task'  )

      col.models[2].addTask( 'c' )
      models = col.clientsByTasks()
      assert( models[0].tasks.length is 1, 'There should only be one task'  )
      assert( models[1].tasks.length is 1 , 'There should only be one task'  )
      assert( models[2].tasks.length is 2 , 'There should be two task'  )

      done()
###

manager = new Server(
  port: 8000
  ttl: 5000
)
manager.getClientById( id )
manager.removeClientById( id )
manager.removeClient( client )

manager.on 'client:connect', ( client, data )->

manager.on 'client:validated', ( client )->

manager.on 'client:disconnect', ( client )->

manager.on 'client:removed', ( client )->


client = new Client(
  host: 'server.test.com'
  port: 8000
)
connection = client.connect()
connection.promise.then()
client.disconnect()


client.onTask 'process_video', ( task, details )->
  task.fail( 'arguments' )
  task.complete()
  task.id


client.getTaskById( id )

client.hasTasks()

client.getTasks()

client.createTask()

client.removeTask()

client.die()

client.
###
