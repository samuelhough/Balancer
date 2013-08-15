fs = require 'fs'
ClientModel = require '../models/Client'
ServerCollection = require '../collections/ServerCollection'
EventEmitter = require('events').EventEmitter

module.exports = class ServerLoader extends EventEmitter
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
    server = new ClientModel(obj)  
    @servers.add( server )
    @emit( 'server_added', server )

  getServer: ( name )->
    @servers.findWhere( { name: name })

  getServers: ->
    @servers.models

  hasAServer: ->
    !!@servers.models.length

  hasServer: ( name )->
    !!@servers.findWhere( { name: name })

  removeServer: ( name )->
    if typeof name is 'string'
      server = @servers.findWhere( { name: name })
    else
      server = name

    @servers.remove( server )  