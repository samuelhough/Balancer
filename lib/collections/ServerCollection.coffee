BackboneCollection = (require '../../node_modules/backbone').Collection
ServerModel = require '../models/Client'

module.exports = BackboneCollection.extend(
  model: ServerModel
)
