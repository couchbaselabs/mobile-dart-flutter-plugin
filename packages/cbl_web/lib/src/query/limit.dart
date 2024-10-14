import 'expressions/expression.dart';
import 'ffi_query.dart';
import 'parameters.dart';
import 'proxy_query.dart';
import 'query.dart';
import 'query_change.dart';
import 'result_set.dart';

/// A query component representing the `LIMIT` clause of a [Query].
///
/// {@category Query Builder}
abstract class Limit implements Query {}

/// Version of [Limit] for building [SyncQuery]s.
///
/// {@category Query Builder}
abstract class SyncLimit implements Limit, SyncQuery {}

/// Version of [Limit] for building [AsyncQuery]s.
///
/// {@category Query Builder}
abstract class AsyncLimit implements Limit, AsyncQuery {}

// === Impl ====================================================================

class SyncLimitImpl implements SyncLimit {
  SyncLimitImpl({
    required Object query,
    required ExpressionInterface limit,
    offset,
  });

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

class AsyncLimitImpl extends AsyncBuilderQuery implements AsyncLimit {
  AsyncLimitImpl({
    required AsyncBuilderQuery super.query,
    required ExpressionInterface super.limit,
    super.offset,
  });
}
