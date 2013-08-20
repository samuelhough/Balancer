__base   = process.cwd()
chai     = require 'chai'
expect   = chai.assert

Backbone = require '../../node_modules/backbone'
TaskSetModel  = require '../../lib/models/TaskSet'
TaskSetCollection = require '../../lib/collections/TaskSetCollection'
TaskModel = require '../../lib/models/Task'

describe 'TaskSet Model', ->
    it 'Should be a constructor', (done) ->
      model = new TaskSetModel()
      assert(model instanceof TaskSetModel, 'should be a constructor')
      done()

    it 'Should be an instance of Backbone model', (done) ->
      model = new TaskSetModel()
      assert(model instanceof Backbone.Model, 'Should be a backbone model')
      done()

    it 'Has an id', (done) ->
      model = new TaskSetModel()
      assert( !!model.getId() )
      done()

    it 'The count should be incremented as models are added', (done)->
      model = new TaskSetModel()
      t1 = new TaskModel()
      t2 = new TaskModel()
      model.add( [t1, t2] )
      assert(model.get('count') is 2, 'Should be two models')
      assert( model.get('status') is 'pending', 'Status should be pending')
      model.add( new TaskModel() )
      assert( model.get('count') is 3, 'Should be another model for the count' )
      done()

    it 'Giving a TaskSetModel an array of tasks will emit an event when they are all complete', (done)->
      model = new TaskSetModel()
      t1 = new TaskModel()
      t2 = new TaskModel()
      model.add( [t1, t2] )
      assert(model.get('count') is 2, 'Should be two tasks')
      assert(model.get('status') is 'pending', "Set should be pending")
      model.on('completed', ->
        assert(model.get('status') is 'complete', 'Set should be complete')
        done()
      )
      t2.complete()
      t1.complete()
      assert( model.get('count') is 0, 'Count should now be 0')
      assert( t2.get('status') is 'complete', 'Status should be complete' )


