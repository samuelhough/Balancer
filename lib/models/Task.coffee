Backbone = require '../../node_modules/backbone'
Q = require '../../node_modules/Q'

module.exports = Backbone.Model.extend(
    completed: false
    completeTask: ()->
      @completed = true
      @trigger('completed', @)
      
    isComplete: ->
      @completed

    sync: ->
)
