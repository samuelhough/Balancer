__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect

Backbone = require '../../node_modules/backbone'
ClientCollection  = require '../../lib/server/ClientCollection'
ClientModel  = require '../../lib/server/ClientModel'

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
