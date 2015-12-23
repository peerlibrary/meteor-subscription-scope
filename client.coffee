Connection = Meteor.connection.constructor

originalSubscribe = Connection::subscribe
Connection::subscribe = (args...) ->
  handle = originalSubscribe.apply @, args

  handle.scopeQuery = ->
    query = {}
    query["_sub_#{handle.subscriptionId}"] = 1
    query

  handle

# Recreate the convenience method.
Meteor.subscribe = _.bind Meteor.connection.subscribe, Meteor.connection
