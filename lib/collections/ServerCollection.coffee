BackboneCollection = (require '../../node_modules/backbone').Collection
ServerModel = require '../models/Server'

module.exports = BackboneCollection.extend(
  model: ServerModel
)
