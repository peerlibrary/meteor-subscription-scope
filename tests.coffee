if Meteor.isServer
  TestDataCollection = new Mongo.Collection null

  Meteor.methods
    insertTest: (obj) ->
      TestDataCollection.insert obj

    updateTest: (selector, query) ->
      TestDataCollection.update selector, query

    removeTest: (selector) ->
      TestDataCollection.remove selector

  Meteor.publish 'testDataPublish', (divisor, remainder) ->
    @enableScope()

    TestDataCollection.find({i: $mod: [divisor, remainder]}).observeChanges
      added: (id, fields) =>
        @added 'testDataCollection', id, fields
      changed: (id, fields) =>
        @changed 'testDataCollection', id, fields
      removed: (id) =>
        @removed 'testDataCollection', id

    @ready()

else
  TestDataCollection = new Mongo.Collection 'testDataCollection'

class BasicTestCase extends ClassyTestCase
  @testName: 'subscription-data - basic'

  setUpServer: ->
    TestDataCollection.remove {}

  testClientBasic: [
    ->
      @subscription1 = @assertSubscribeSuccessful 'testDataPublish', 2, 0, @expect()
      @subscription2 = @assertSubscribeSuccessful 'testDataPublish', 2, 1, @expect()
      @subscription3 = @assertSubscribeSuccessful 'testDataPublish', 6, 0, @expect()
      @subscription4 = @assertSubscribeSuccessful 'testDataPublish', 3, 0, @expect()
  ,
    ->
      @assertEqual TestDataCollection.find({}, {fields: {_id: 0}, sort: {i: 1}}).fetch(), []
      @assertEqual TestDataCollection.find(@subscription1.scopeQuery(), {fields: {_id: 0}, sort: {i: 1}}).fetch(), []
      @assertEqual TestDataCollection.find(@subscription2.scopeQuery(), {fields: {_id: 0}, sort: {i: 1}}).fetch(), []
      @assertEqual TestDataCollection.find(@subscription3.scopeQuery(), {fields: {_id: 0}, sort: {i: 1}}).fetch(), []
      @assertEqual TestDataCollection.find(@subscription4.scopeQuery(), {fields: {_id: 0}, sort: {i: 1}}).fetch(), []

      @documents = []

      for i in [0...10]
        doc = {i: i}
        @documents.push doc
        Meteor.call 'insertTest', doc, @expect (error, documentId) =>
          @assertFalse error, error
          @assertTrue documentId

      @documents = _.sortBy @documents, 'i'
  ,
    ->
      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 100 # ms
  ,
    ->
      @assertEqual TestDataCollection.find({}, {fields: {_id: 0}, sort: {i: 1}}).fetch(), @documents
      @assertEqual TestDataCollection.find(@subscription1.scopeQuery(), {fields: {_id: 0}, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 2 is 0
      @assertEqual TestDataCollection.find(@subscription2.scopeQuery(), {fields: {_id: 0}, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 2 is 1
      @assertEqual TestDataCollection.find(@subscription3.scopeQuery(), {fields: {_id: 0}, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 6 is 0
      @assertEqual TestDataCollection.find(@subscription4.scopeQuery(), {fields: {_id: 0}, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 3 is 0

      for i in [0...10]
        doc = {i: i}
        @documents.push doc
        Meteor.call 'insertTest', doc, @expect (error, documentId) =>
          @assertFalse error, error
          @assertTrue documentId

      @documents = _.sortBy @documents, 'i'
  ,
    ->
      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 100 # ms
  ,
    ->
      @assertEqual TestDataCollection.find({}, {fields: {_id: 0}, sort: {i: 1}}).fetch(), @documents
      @assertEqual TestDataCollection.find(@subscription1.scopeQuery(), {fields: {_id: 0}, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 2 is 0
      @assertEqual TestDataCollection.find(@subscription2.scopeQuery(), {fields: {_id: 0}, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 2 is 1
      @assertEqual TestDataCollection.find(@subscription3.scopeQuery(), {fields: {_id: 0}, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 6 is 0
      @assertEqual TestDataCollection.find(@subscription4.scopeQuery(), {fields: {_id: 0}, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 3 is 0

      @subscription2.stop()

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 100 # ms
  ,
    ->
      fields = {_id: 0, i: 1}
      fields["_sub_#{@subscription1.subscriptionId}"] = 1
      fields["_sub_#{@subscription2.subscriptionId}"] = 1
      fields["_sub_#{@subscription3.subscriptionId}"] = 1
      fields["_sub_#{@subscription4.subscriptionId}"] = 1

      @assertEqual TestDataCollection.find({}, {fields: fields, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 2 is 0 or i % 6 is 0 or i % 3 is 0
      @assertEqual TestDataCollection.find(@subscription1.scopeQuery(), {fields: fields, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 2 is 0
      @assertEqual TestDataCollection.find(@subscription2.scopeQuery(), {fields: fields, sort: {i: 1}}).fetch(), []
      @assertEqual TestDataCollection.find(@subscription3.scopeQuery(), {fields: fields, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 6 is 0
      @assertEqual TestDataCollection.find(@subscription4.scopeQuery(), {fields: fields, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 3 is 0

      @subscription3.stop()

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 100 # ms
  ,
    ->
      @assertEqual TestDataCollection.find({}, {fields: {_id: 0, i: 1}, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 2 is 0 or i % 3 is 0
      @assertEqual TestDataCollection.find(@subscription1.scopeQuery(), {fields: {_id: 0, i: 1}, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 2 is 0
      @assertEqual TestDataCollection.find(@subscription2.scopeQuery(), {fields: {_id: 0, i: 1}, sort: {i: 1}}).fetch(), []
      @assertEqual TestDataCollection.find(@subscription3.scopeQuery(), {fields: {_id: 0, i: 1}, sort: {i: 1}}).fetch(), []
      @assertEqual TestDataCollection.find(@subscription4.scopeQuery(), {fields: {_id: 0, i: 1}, sort: {i: 1}}).fetch(), _.filter @documents, ({i}) -> i % 3 is 0
  ]

ClassyTestCase.addTest new BasicTestCase()
