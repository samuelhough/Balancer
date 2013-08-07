# __base   = process.cwd()
# chai     = require 'chai'
# expect   = chai.expect

# Backbone = require '../../node_modules/backbone'
# Server  = require '../../lib/Server'
# Client  = require '../../lib/Client'

# describe 'Server Test', ->
#     it 'Should be a constructor', (done) ->
#       monger = new Server()
#       expect(monger instanceof Server).to.equal true
#       done()

#     it 'Should have a collection for the number of clients', (done) ->
#       monger = new Server()
#       expect(monger.getClients() instanceof Backbone.Collection).to.equal true
#       done()


# ###

# manager = new Server(
#   port: 8000
#   ttl: 5000
# )
# manager.getClientById( id )
# manager.removeClientById( id )
# manager.removeClient( client )

# manager.on 'client:connect', ( client, data )->

# manager.on 'client:validated', ( client )->

# manager.on 'client:disconnect', ( client )->

# manager.on 'client:removed', ( client )->


# client = new Client(
#   host: 'server.test.com'
#   port: 8000
# )
# connection = client.connect()
# connection.promise.then()
# client.disconnect()


# client.onTask 'process_video', ( task, details )->
#   task.fail( 'arguments' )
#   task.complete()
#   task.id


# client.getTaskById( id )

# client.hasTasks()

# client.getTasks()

# client.createTask()

# client.removeTask()

# client.die()

# client.
# ###
