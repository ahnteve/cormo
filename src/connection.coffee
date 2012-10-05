EventEmitter = require('events').EventEmitter
DBModel = require './model'

###
# Normalizes a schema
# (field: String -> field: {type: String})
###
_normalizeSchema = (schema) ->
  for field, property of schema
    if typeof property is 'function'
      schema[field] = type: property
  return

###
# Manages connection to a database
###
class DBConnection extends EventEmitter
  ###
  # Creates a connection
  # @param {String} adapater_name
  # @param {Object} settings
  # @see MySQLAdapter.createAdapter
  # @see MongoDBAdapter.createAdapter
  ###
  constructor: (adapter_name, settings) ->
    @connected = false
    @models = {}

    createAdapter = require __dirname + '/adapters/' + adapter_name
    createAdapter @, settings, (error, adapter) =>
      if error
        @emit 'error', error
        return
      @_adapter = adapter
      @connected = true
      @emit 'connected'

  ###
  # Creates a Model class
  # @param {String} name
  # @param {Object} schema
  # @return {Class}
  ###
  model: (name, schema) ->
    _normalizeSchema schema

    class NewModel extends DBModel
    Object.defineProperty NewModel, '_connection', value: @
    Object.defineProperty NewModel, '_name', value: name
    Object.defineProperty NewModel, '_schema', value: schema
    Object.defineProperty NewModel, '_associations', value: {}

    @models[name] = NewModel
    return NewModel

  _waitingForConnection: (object, method, args) ->
    return false if @connected
    @once 'connected', ->
      method.apply object, args
    return true

  ###
  # Applies schemas
  # @param {Function} callback
  # @param {Error} callback.error
  ###
  applySchemas: (callback) ->
    return if @_waitingForConnection @, @applySchemas, arguments

    if @_adapter.applySchemas?
      @_adapter.applySchemas callback
    else
      callback null

module.exports = DBConnection
