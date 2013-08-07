TaskCollection = require './TaskCollection'
module.exports = class Client
  constructor: ->
    @tasks = new TaskCollection()