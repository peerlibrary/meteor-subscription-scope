originalPublish = Meteor.publish
Meteor.publish = (name, publishFunction) ->
  originalPublish name, (args...) ->
    publish = @

    scopeFieldName = "_sub_#{publish._subscriptionId}"

    enabled = false

    publish.enableScope = ->
      enabled = true

    originalAdded = publish.added
    publish.added = (collectionName, id, fields) ->
      # Add our scoping field.
      if enabled
        fields = _.clone fields
        fields[scopeFieldName] = true

      originalAdded.call @, collectionName, id, fields

    originalChanged = publish.changed
    publish.changed = (collectionName, id, fields) ->
      # We do not allow changes to our scoping field.
      if enabled and scopeFieldName of fields
        fields = _.clone fields
        delete fields[scopeFieldName]

      originalChanged.call @, collectionName, id, fields

    publishFunction.apply publish, args
