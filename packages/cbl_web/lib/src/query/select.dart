import 'dart:async';
import 'data_source.dart';
import 'ffi_query.dart';
import 'from.dart';
import 'parameters.dart';
import 'proxy_query.dart';
import 'query.dart';
import 'query_builder.dart';
import 'query_change.dart';
import 'result_set.dart';
import 'router/from_router.dart';
import 'select_result.dart';

/// A query component representing the `SELECT` clause of a [Query].
///
/// {@category Query Builder}
abstract class Select implements Query, FromRouter {}

/// Version of [Select] for building [SyncQuery]s.
///
/// {@category Query Builder}
abstract class SyncSelect implements Select, SyncQuery, SyncFromRouter {}

/// Version of [Select] for building [AsyncQuery]s.
///
/// {@category Query Builder}
abstract class AsyncSelect implements Select, AsyncQuery, AsyncFromRouter {}

// === Impl ====================================================================

class SelectImpl extends QueryBase with BuilderQueryMixin implements Select {
  SelectImpl(
    Iterable<SelectResultInterface> select, {
    required bool distinct,
  }) : super(
          typeName: 'SelectImpl',
          language: '',
        ) {
    initBuilderQuery(
      selects: select,
      distinct: distinct,
    );
  }

  @override
  From from(DataSourceInterface dataSource) => from(dataSource);

  // All these methods will never execute their body because the `useSync`
  // method from `BuilderQueryMixin` throws because the query has not FROM
  // clause. They just have to be implemented to satisfy the interface.

  // coverage:ignore-start

  @override
  Parameters? get parameters => useSync(() => throw UnimplementedError());

  @override
  FutureOr<void> setParameters(Parameters? value) =>
      useSync(() => throw UnimplementedError());

  @override
  FutureOr<ResultSet> execute() => useSync(() => throw UnimplementedError());

  @override
  FutureOr<String> explain() => useSync(() => throw UnimplementedError());

  @override
  FutureOr<Object> addChangeListener(QueryChangeListener listener) =>
      useSync(() => throw UnimplementedError());

  @override
  FutureOr<void> removeChangeListener(Object token) =>
      useSync(() => throw UnimplementedError());

  @override
  Stream<QueryChange> changes() => useSync(() => throw UnimplementedError());

  // coverage:ignore-end
}

class SyncSelectImpl implements SyncSelect {
  SyncSelectImpl(
    Iterable<SelectResultInterface> select, {
    required bool distinct,
  });

  @override
  SyncFrom from(DataSourceInterface dataSource) {
    return SyncFromImpl(query: this, from: dataSource);
  }

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

class AsyncSelectImpl extends AsyncBuilderQuery implements AsyncSelect {
  AsyncSelectImpl(
    Iterable<SelectResultInterface> select, {
    required bool distinct,
  }) : super(selects: select, distinct: distinct);

  @override
  AsyncFrom from(DataSourceInterface dataSource) {
    return AsyncFromImpl(query: this, from: dataSource);
  }
}

void _assertDataSourceType<T, E>(
  DataSourceInterface dataSource,
  String expectedStyle,
  String actualStyle,
) {
  final source = (dataSource as DataSourceImpl).source;
  if (source is! T && source is! E) {
    throw ArgumentError(
      '${expectedStyle}QueryBuilder must be used with an '
      '${expectedStyle}Database or ${expectedStyle}Collection. To build a '
      'query for a ${actualStyle}Database or ${actualStyle}Collection '
      'use ${actualStyle}QueryBuilder.',
    );
  }
}
