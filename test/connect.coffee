_g = require './common'
{expect} = require 'chai'

_dbs = [ 'mysql', 'mongodb', 'sqlite3', 'sqlite3_memory', 'postgresql', 'redis' ]

_dbs.forEach (db) ->
  return if not _g.db_configs[db]
  describe 'connect-' + db, ->
    before (done) ->
      _g.connection = new _g.Connection db, _g.db_configs[db]
      User = _g.connection.model 'User',
        name: String
        age: Number
      User.drop (error) ->
        done null

    it 'can process without waiting connected and schemas applied', (done) ->
      _g.connection = new _g.Connection db, _g.db_configs[db]
      User = _g.connection.model 'User',
        name: String
        age: Number

      User.create { name: 'John Doe', age: 27 }, (error, user) ->
        return done error if error
        User.find user.id, (error, record) ->
          return done error if error
          expect(record).to.exist
          expect(record).to.be.an.instanceof User
          expect(record).to.have.property 'id', user.id
          expect(record).to.have.property 'name', user.name
          expect(record).to.have.property 'age', user.age
          done null

    after (done) ->
      _g.dropModels [_g.connection.User], ->
        _g.connection.close()
        _g.connection = null
        done null
