fs = require 'fs'
ServerModel = require '../models/Server'
ServerCollection = require '../collections/ServerCollection'

module.exports = class ServerLoader
  constructor: ->
    @servers = new ServerCollection()

  loadConfig: ( fileName )-> 
    file = String( fs.readFileSync( fileName ) )
    @parseServerConfig( file )

  parseServerConfig: ( ServerConfig )->
    # throw ServerConfig
    ServerConfig = JSON.parse( ServerConfig )
    for server of ServerConfig.servers
      @addServer( ServerConfig.servers[server] )

  addServer: ( obj )->
    @servers.add( new ServerModel(obj) )

  getServer: ( name )->
    @servers.findWhere( { name: name })

  getServers: ->
    @servers.models

  hasAServer: ->
    !!@servers.models.length

  hasServer: ( name )->
    !!@servers.findWhere( { name: name })

  removeServer: ( name )->
    server = @servers.findWhere( { name: name })
    @servers.remove( server )  