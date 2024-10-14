import 'expressions/expression.dart';
import 'ffi_query.dart';
import 'having.dart';
import 'limit.dart';
import 'order_by.dart';
import 'ordering.dart';
import 'parameters.dart';
import 'proxy_query.dart';
import 'query.dart';
import 'query_change.dart';
import 'result_set.dart';
import 'router/having_router.dart';
import 'router/limit_router.dart';
import 'router/order_by_router.dart';

/// A query component representing the `GROUP BY` clause of a [Query].
///
/// {@category Query Builder}
abstract class GroupBy
    implements Query, HavingRouter, OrderByRouter, LimitRouter {}

/// Version of [GroupBy] for building [SyncQuery]s.
///
/// {@category Query Builder}
abstract class SyncGroupBy
    implements
        GroupBy,
        SyncQuery,
        SyncHavingRouter,
        SyncOrderByRouter,
        SyncLimitRouter {}

/// Version of [GroupBy] for building [AsyncQuery]s.
///
/// {@category Query Builder}
abstract class AsyncGroupBy
    implements
        GroupBy,
        AsyncQuery,
        AsyncHavingRouter,
        AsyncOrderByRouter,
        AsyncLimitRouter {}

// === Impl ====================================================================

class SyncGroupByImpl implements SyncGroupBy {
  SyncGroupByImpl({
    required Object query,
    required Iterable<ExpressionInterface> expressions,
  });

  @override
  SyncHaving having(ExpressionInterface expression) =>
      SyncHavingImpl(query: this, expression: expression);

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

class AsyncGroupByImpl extends AsyncBuilderQuery implements AsyncGroupBy {
  AsyncGroupByImpl({
    required AsyncBuilderQuery query,
    required Iterable<ExpressionInterface> expressions,
  }) : super(query: query, groupBys: expressions);

  @override
  AsyncHaving having(ExpressionInterface expression) =>
      AsyncHavingImpl(query: this, expression: expression);

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
