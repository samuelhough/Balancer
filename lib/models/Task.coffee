Backbone = require '../../node_modules/backbone'

module.exports = Backbone.Model.extend(
    complete: ()->
      @set('status', 'complete')
      @trigger('completed', @)

    isComplete: ->
      return this.get('status') is 'complete'
    sync: ->
)
