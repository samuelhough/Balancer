Backbone = require '../../node_modules/backbone'
Q = require '../../node_modules/Q'

module.exports = Backbone.Model.extend(
    isComplete: false
    completeTask: ()->
      @trigger('completed', @)
    sync: ->
)
