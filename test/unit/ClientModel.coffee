__base   = process.cwd()
chai     = require 'chai'
expect   = chai.expect

Backbone = require '../../node_modules/backbone'
ClientModel  = require '../../lib/server/ClientModel'

describe 'ClientModel', ->
    it 'Should be a constructor', (done) ->
      model = new ClientModel()
      expect(model instanceof ClientModel).to.equal true
      done()

    it 'Should be an instance of Backbone model', (done) ->
      model = new ClientModel()
      expect(model instanceof Backbone.Model).to.equal true
      done()

    it 'Can get tasks from a model', (done) ->
      model = new ClientModel()
      expect(model.getTasks().length).to.equal 0
      done()

    it 'Can add tasks to a model', (done) ->
      model = new ClientModel()
      model.addTask( 'hi' )
      expect(model.getTasks().length).to.equal 1
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
