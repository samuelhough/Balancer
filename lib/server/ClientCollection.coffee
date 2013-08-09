BackboneCollection = (require '../../node_modules/backbone').Collection
_ = require '../../node_modules/underscore'
ClientModel = require './ClientModel'

module.exports = BackboneCollection.extend(
  model: ClientModel
  getClient: ( address, port )->
    return _.find( @models, ( model ) ->
      return model.get('port') is port and model.get('address') is address
    ) 

  findClientsWithoutTask: ( )->
    return _.filter( @models, ( model )->
        return !model.hasTask()
    )

  clientsByTasks: ->
    arr = []
    for i in @models
      arr.push i

    return _.sortBy(arr, (  model1 ) ->
      return model1.numTasks() 
    )
)
