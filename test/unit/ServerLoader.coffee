__base   = process.cwd()
chai     = require 'chai'
assert   = chai.assert
util = require 'util'
ServerLoader = require '../../lib/controller/ServerLoader'
Backbone = require '../../node_modules/backbone'

describe 'ServerLoader Test', ->
    it 'Should be a constructor', (done) ->
      serverLoader = new ServerLoader()
      assert( serverLoader instanceof ServerLoader )
      done()
    it 'Can load a file', ( done )->
      serverLoader = new ServerLoader()
      serverLoader.loadConfig( './test/unit/server-config.json' )
      assert(serverLoader.hasAServer() is true, 'Should have loaded a server')
      done()

     it 'Can get the servers model list', ( done )->
      serverLoader = new ServerLoader()
      serverLoader.loadConfig( './test/unit/server-config.json' )
      assert(serverLoader.getServers().length is 3, 'Shoudl have three servers')
      done()

    it 'Can get a server model by name', ( done )->
      serverLoader = new ServerLoader()
      serverLoader.loadConfig( './test/unit/server-config.json' )
      model = serverLoader.getServer('Server1')
      assert( model instanceof Backbone.Model, 'Should be a backbone model')
      assert( !!model, 'Shoudl return a model')
      done()

    it 'Can tell if a server is there', ( done )->
      serverLoader = new ServerLoader()
      serverLoader.loadConfig( './test/unit/server-config.json' )
      model = serverLoader.hasServer('Server4')
      assert( !model, 'Should not be there')
      model = serverLoader.hasServer('Server3')
      assert( !!model, 'Should be there')
      done()

    it 'Can get the correct properties for a model', ( done )->
      serverLoader = new ServerLoader()
      serverLoader.loadConfig( './test/unit/server-config.json' )
      model = serverLoader.getServer('Server1')
      assert( model.get('name') is 'Server1', 'Should be correctly named')
      assert( model.get('host') is '0.0.0.1', 'Should have correct host '+ model.get('host'))
      assert( model.get('port') is '1234', 'Should have correct port '+ model.get('port'))
      done()

    it 'Can remove a server by name or object', (done)->
      serverLoader = new ServerLoader()
      serverLoader.loadConfig( './test/unit/server-config.json' )

      assert( serverLoader.getServers().length is 3, 'Should be three servers')
      serverLoader.removeServer( 'Server1' )
      assert( serverLoader.getServers().length is 2, 'Should be one less server')

      serverLoader.removeServer( serverLoader.getServer('Server2') )
      assert( serverLoader.getServers().length is 1, 'Should be only one server')
      done()
      