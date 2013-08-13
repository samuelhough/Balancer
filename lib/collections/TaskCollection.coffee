BackboneCollection = (require '../../node_modules/backbone').Collection

module.exports = BackboneCollection.extend(
  idAttribute: 'task_id'

)
