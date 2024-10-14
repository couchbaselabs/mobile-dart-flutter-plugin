import 'expressions/expression.dart';
import 'ffi_query.dart';
import 'limit.dart';
import 'ordering.dart';
import 'parameters.dart';
import 'proxy_query.dart';
import 'query.dart';
import 'query_change.dart';
import 'result_set.dart';
import 'router/limit_router.dart';

/// A query component representing the `ORDER BY` clause of a [Query].
///
/// {@category Query Builder}
abstract class OrderBy implements Query, LimitRouter {}

/// Version of [OrderBy] for building [SyncQuery]s.
///
/// {@category Query Builder}
abstract class SyncOrderBy implements OrderBy, SyncQuery, SyncLimitRouter {}

/// Version of [OrderBy] for building [AsyncQuery]s.
///
/// {@category Query Builder}
abstract class AsyncOrderBy implements OrderBy, AsyncQuery, AsyncLimitRouter {}

// === Impl ====================================================================

class SyncOrderByImpl implements SyncOrderBy {
  SyncOrderByImpl({
    required Object query,
    required Iterable<OrderingInterface> orderings,
  });

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

class AsyncOrderByImpl extends AsyncBuilderQuery implements AsyncOrderBy {
  AsyncOrderByImpl({
    required AsyncBuilderQuery query,
    required Iterable<OrderingInterface> orderings,
  });

  @override
  AsyncLimit limit(ExpressionInterface limit, {ExpressionInterface? offset}) =>
      AsyncLimitImpl(query: this, limit: limit, offset: offset);
}
