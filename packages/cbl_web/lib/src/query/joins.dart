import 'expressions/expression.dart';
import 'ffi_query.dart';
import 'join.dart';
import 'limit.dart';
import 'order_by.dart';
import 'ordering.dart';
import 'parameters.dart';
import 'proxy_query.dart';
import 'query.dart';
import 'query_change.dart';
import 'result_set.dart';
import 'router/limit_router.dart';
import 'router/order_by_router.dart';
import 'router/where_router.dart';
import 'where.dart';

/// A query component representing the `JOIN` clauses of a [Query].
///
/// {@category Query Builder}
abstract class Joins
    implements Query, WhereRouter, OrderByRouter, LimitRouter {}

/// Version of [Joins] for building [SyncQuery]s.
///
/// {@category Query Builder}
abstract class SyncJoins
    implements
        Joins,
        SyncQuery,
        SyncWhereRouter,
        SyncOrderByRouter,
        SyncLimitRouter {}

/// Version of [Joins] for building [AsyncQuery]s.
///
/// {@category Query Builder}
abstract class AsyncJoins
    implements
        Joins,
        AsyncQuery,
        AsyncWhereRouter,
        AsyncOrderByRouter,
        AsyncLimitRouter {}

// === Impl ====================================================================

class SyncJoinsImpl implements SyncJoins {
  SyncJoinsImpl({
    required Object query,
    required Iterable<JoinInterface> joins,
  });

  @override
  SyncWhere where(ExpressionInterface expression) =>
      SyncWhereImpl(query: this, expression: expression);

  @override
  SyncOrderBy orderBy(
    OrderingInterface ordering0, [
    OrderingInterface? ordering1,
    OrderingInterface? ordering2,
    OrderingInterface? ordering3,
    OrderingInterface? ordering4,
    OrderingInterface? ordering5,
    OrderingInterface? ordering6,
    OrderingInterface? ordering7,
    OrderingInterface? ordering8,
    OrderingInterface? ordering9,
  ]) =>
      orderByAll([
        ordering0,
        ordering1,
        ordering2,
        ordering3,
        ordering4,
        ordering5,
        ordering6,
        ordering7,
        ordering8,
        ordering9,
      ].whereType());

  @override
  SyncOrderBy orderByAll(Iterable<OrderingInterface> orderings) =>
      SyncOrderByImpl(query: this, orderings: orderings);

  @override
  SyncLimit limit(ExpressionInterface limit, {ExpressionInterface? offset}) =>
      SyncLimitImpl(query: this, limit: limit, offset: offset);

  @override
  addChangeListener(QueryChangeListener<SyncResultSet> listener) {
    // TODO: implement addChangeListener
    throw UnimplementedError();
  }

  @override
  Stream<QueryChange<SyncResultSet>> changes() {
    // TODO: implement changes
    throw UnimplementedError();
  }

  @override
  SyncResultSet execute() {
    // TODO: implement execute
    throw UnimplementedError();
  }

  @override
  String explain() {
    // TODO: implement explain
    throw UnimplementedError();
  }

  @override
  // TODO: implement jsonRepresentation
  String? get jsonRepresentation => throw UnimplementedError();

  @override
  // TODO: implement n1ql
  String? get n1ql => throw UnimplementedError();

  @override
  // TODO: implement parameters
  Parameters? get parameters => throw UnimplementedError();

  @override
  void removeChangeListener(token) {
    // TODO: implement removeChangeListener
  }

  @override
  void setParameters(Parameters? value) {
    // TODO: implement setParameters
  }
}

class AsyncJoinsImpl extends AsyncBuilderQuery implements AsyncJoins {
  AsyncJoinsImpl({
    required AsyncBuilderQuery query,
    required Iterable<JoinInterface> joins,
  }) : super(query: query, joins: joins);

  @override
  AsyncWhere where(ExpressionInterface expression) =>
      AsyncWhereImpl(query: this, expression: expression);

  @override
  AsyncOrderBy orderBy(
    OrderingInterface ordering0, [
    OrderingInterface? ordering1,
    OrderingInterface? ordering2,
    OrderingInterface? ordering3,
    OrderingInterface? ordering4,
    OrderingInterface? ordering5,
    OrderingInterface? ordering6,
    OrderingInterface? ordering7,
    OrderingInterface? ordering8,
    OrderingInterface? ordering9,
  ]) =>
      orderByAll([
        ordering0,
        ordering1,
        ordering2,
        ordering3,
        ordering4,
        ordering5,
        ordering6,
        ordering7,
        ordering8,
        ordering9,
      ].whereType());

  @override
  AsyncOrderBy orderByAll(Iterable<OrderingInterface> orderings) =>
      AsyncOrderByImpl(query: this, orderings: orderings);

  @override
  AsyncLimit limit(ExpressionInterface limit, {ExpressionInterface? offset}) =>
      AsyncLimitImpl(query: this, limit: limit, offset: offset);
}
