Connection = Meteor.connection.constructor

originalSubscribe = Connection::subscribe
Connection::subscribe = (args...) ->
  handle = originalSubscribe.apply @, args

  handle.scopeQuery = ->
    query = {}
    query["_sub_#{handle.subscriptionId}"] =
      $exists: true
    query

  handle

# Recreate the convenience method.
Meteor.subscribe = _.bind Meteor.connection.subscribe, Meteor.connection

originalCompileProjection = LocalCollection._compileProjection
LocalCollection._compileProjection = (fields) ->
  fun = originalCompileProjection fields

  (obj) ->
    res = fun obj

    fields = Object.keys(res);

    for i in [0...fields.length]
      if fields[i].lastIndexOf('_sub_', 0) is 0
        delete res[fields[i]]

    res
