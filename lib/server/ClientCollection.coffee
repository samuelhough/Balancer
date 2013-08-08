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
    return _.find( @models, ( model )->
        return model.hasTask()
    ) or []

  clientsByTasks: ->
    return _.sortBy(@models, ( model1, model2 ) ->
      return model1.getTasks().length > model2.getTasks().length
    )
)
