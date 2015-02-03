# ReActive Record

ReActive Record is an ActiveRecord like ORM.

Features include:

* Reflects on database columns to generate accessors for the data models.

* Queries return relation objects that facilitate the lazy loading of results - minimizing actual calls to the database.

* Implements model associations including: has_many, belongs_to, and has_one_through.

* Implements Relation#include by storing the results of a query in a closure, and using send and define_method to build a method on the original model that accesses the closure.
