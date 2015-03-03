_g = require '../common'
{expect} = require 'chai'

module.exports = () ->
  it 'unique', (done) ->
    _g.connection.Version.create major: 1, minor: 1, (error, version) ->
      return done error if error
      _g.connection.Version.create major: 1, minor: 1, (error, version) ->
        # 'duplicated email' or 'duplicated'
        expect(error.message).to.match /^duplicated( major_minor)?$/
        expect(error).to.exist
        done null

  it 'each can duplicate', (done) ->
    _g.connection.Version.create major: 1, minor: 1, (error, version) ->
      return done error if error
      _g.connection.Version.create major: 1, minor: 2, (error, version) ->
        return done error if error
        done null

  it 'can have two null records', (done) ->
    _g.connection.Version.create {}, (error, version) ->
      return done error if error
      _g.connection.Version.create {}, (error, version) ->
        return done error if error
        done null
