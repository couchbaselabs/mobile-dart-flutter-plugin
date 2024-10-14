import 'expressions/expression.dart';
import 'ffi_query.dart';
import 'group_by.dart';
import 'limit.dart';
import 'order_by.dart';
import 'ordering.dart';
import 'parameters.dart';
import 'proxy_query.dart';
import 'query.dart';
import 'query_change.dart';
import 'result_set.dart';
import 'router/group_by_router.dart';
import 'router/limit_router.dart';
import 'router/order_by_router.dart';

/// A query component representing the `WHERE` clause of a [Query].
///
/// {@category Query Builder}
abstract class Where
    implements Query, GroupByRouter, OrderByRouter, LimitRouter {}

/// Version of [Where] for building [SyncQuery]s.
///
/// {@category Query Builder}
abstract class SyncWhere
    implements
        Where,
        SyncQuery,
        SyncGroupByRouter,
        SyncOrderByRouter,
        SyncLimitRouter {}

/// Version of [Where] for building [AsyncQuery]s.
///
/// {@category Query Builder}
abstract class AsyncWhere
    implements
        Where,
        AsyncQuery,
        AsyncGroupByRouter,
        AsyncOrderByRouter,
        AsyncLimitRouter {}

// === Impl ====================================================================

class SyncWhereImpl implements SyncWhere {
  SyncWhereImpl({
    required Object query,
    required ExpressionInterface expression,
  });

  @override
  SyncGroupBy groupBy(
    ExpressionInterface expression0, [
    ExpressionInterface? expression1,
    ExpressionInterface? expression2,
    ExpressionInterface? expression3,
    ExpressionInterface? expression4,
    ExpressionInterface? expression5,
    ExpressionInterface? expression6,
    ExpressionInterface? expression7,
    ExpressionInterface? expression8,
    ExpressionInterface? expression9,
  ]) =>
      groupByAll([
        expression0,
        expression1,
        expression2,
        expression3,
        expression4,
        expression5,
        expression6,
        expression7,
        expression8,
        expression9,
      ].whereType());

  @override
  SyncGroupBy groupByAll(Iterable<ExpressionInterface> expressions) =>
      SyncGroupByImpl(query: this, expressions: expressions);

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

class AsyncWhereImpl extends AsyncBuilderQuery implements AsyncWhere {
  AsyncWhereImpl({
    required AsyncBuilderQuery query,
    required ExpressionInterface expression,
  }) : super(query: query, where: expression);

  @override
  AsyncGroupBy groupBy(
    ExpressionInterface expression0, [
    ExpressionInterface? expression1,
    ExpressionInterface? expression2,
    ExpressionInterface? expression3,
    ExpressionInterface? expression4,
    ExpressionInterface? expression5,
    ExpressionInterface? expression6,
    ExpressionInterface? expression7,
    ExpressionInterface? expression8,
    ExpressionInterface? expression9,
  ]) =>
      groupByAll([
        expression0,
        expression1,
        expression2,
        expression3,
        expression4,
        expression5,
        expression6,
        expression7,
        expression8,
        expression9,
      ].whereType());

  @override
  AsyncGroupBy groupByAll(Iterable<ExpressionInterface> expressions) =>
      AsyncGroupByImpl(query: this, expressions: expressions);

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
