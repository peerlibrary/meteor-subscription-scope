subscription scope
==================

This Meteor smart package allows scoping of queries on collections only to documents
published by a subscription.

Adding this package to your [Meteor](http://www.meteor.com/) application extends
subscription's handle with `scopeQuery` and publish endpoint function's `this` is
extended with `this.enableScope()`.

Both client and server side.

Installation
------------

```
meteor add peerlibrary:subscription-scope
```

API
---

The subscription handle returned from [`Meteor.subscribe`](http://docs.meteor.com/#/full/meteor_subscribe)
contain a new method:

* `scopeQuery()` – returns a query which limits collection's documents only to this subscription

Limiting is only done on documents, not on fields. If multiple publish endpoints publish different fields
and you subscribe to them, all combined fields will still be available in all queries on the client side.

Inside the [publish endpoint](http://docs.meteor.com/#/full/meteor_publish) function `this` is
extended with:

* `enableScope()` – when enabled, for subscriptions to this publish endpoint, clients can use `scopeQuery()`
  to limit queries only to the subscription

Example
-------

If on the server side you have such publish endpoint (using
[MongoDB full-text search](https://docs.mongodb.org/v2.6/reference/operator/query/text/)):

```javascript
Meteor.publish('search-documents', function (search) {
  this.enableScope();

  var query = {$text: {$search: search}};
  query['score_' + this._subscriptionId] = {$meta: 'textScore'};

  return MyCollection.find(query);
});
```

Then you can on the client side subscribe to it and query only the documents returned from it:

```javascript
var subscription = Meteor.subscribe('search-documents', 'foobar');

var sort = {}
sort['score_' + subscription.subscriptionId] = -1;

// Returns documents found on the server, sorted by the full-text score.
MyCollection.find(subscription.scopeQuery(), {sort: sort}).fetch();

// Returns count of documents found on the server authored by the current user.
MyCollection.find({$and: [subscription.scopeQuery(), {author: Meteor.userId()}]}).count();
```

Related projects
----------------

* [find-from-publication](https://github.com/versolearning/find-from-publication) – uses an
  extra collection which means that there are some syncing issues between collections and
  much more data is send to the client for every document; in short, it is much more complicated
  solution to the simple but powerful approach used by this package
