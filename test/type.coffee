DBConnection = require('../index').DBConnection

_dbs =
  mysql:
    database: 'test'
  mongodb:
    database: 'test'

Object.keys(_dbs).forEach (db) ->
  describe 'type-' + db, ->
    connection = undefined
    connect = (callback) ->
      connection = new DBConnection db, _dbs[db]
      if connection.connected
        callback()
      else
        connection.once 'connected', callback
        connection.once 'error', (error) ->
          callback error

    models = {}

    before (done) ->
      connect (error) ->
        return done error if error

        Type = models.Type = connection.model 'Type',
          number: Number

        Type.drop (error) ->
          return done error if error
          connection.applySchemas (error) ->
            return done error if error
            done null

    beforeEach (done) ->
      models.Type.deleteAll (error) ->
        return done error if error
        done null

    after (done) ->
      models.Type.drop done

    require('./cases/type')(models)