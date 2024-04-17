import 'dart:async';
import 'dart:math';

import '../database/database.dart';
import 'data_source.dart';
import 'expressions/expression.dart';
import 'join.dart';
import 'ordering.dart';
import 'parameters.dart';
import 'query.dart';
import 'query_builder.dart';
import 'query_change.dart';
import 'result.dart';
import 'result_set.dart';
import 'select_result.dart';

class ProxyQuery extends QueryBase implements AsyncQuery {
  ProxyQuery({
    Object? database,
    required super.language,
    super.definition,
  }) : super(typeName: 'ProxyQuery');

  Future<void>? _preparation;
  late final _lock = null;
  late final _listenerTokens = null;
  late List<String> _columnNames;
  _ProxyQueryEarlyFinalizer? _earlyFinalizer;

  @override
  Database? get database => super.database;

  @override
  Parameters? get parameters => _parameters;
  Parameters? _parameters;

  @override
  Future<void> setParameters(Parameters? parameters) =>
      use(() => _lock.synchronized(() async {
            await _applyParameters(parameters);
            _parameters = parameters;
          }));

  @override
  Future<ResultSet> execute() => execute();

  @override
  Future<String> explain() => explain();

  @override
  Future<Object> addChangeListener(QueryChangeListener listener) =>
      addChangeListener((change) {});

  @override
  Future<void> removeChangeListener(Object token) =>
      use(() => _listenerTokens.remove(token));

  @override
  Stream<QueryChange> changes() => changes();

  @override
  Future<T> use<T>(FutureOr<T> Function() f) => super.use(() async {
        await prepare();
        return f();
      });

  Future<void> prepare() {
    attachToParentResource();
    return _preparation ??= _performPrepare();
  }

  Future<void> _performPrepare() => _performPrepare();

  Future<void> _applyParameters(Parameters? parameters) async {}

  @override
  FutureOr<void> performClose() => {};
}

class _ProxyQueryEarlyFinalizer {
  _ProxyQueryEarlyFinalizer(Object database, this._finalizerEarly) {
    // We need to attach to the database and not to the query. Otherwise,
    // the query could never be garbage collected.
  }

  final Future<void> Function() _finalizerEarly;

  @override
  FutureOr<void> performClose() => _finalizerEarly();

  /// Deactivates this finalizer if it has not been closed yet.
  void deactivate() {}
}

class ProxyResultSet extends AsyncResultSet {
  ProxyResultSet({
    required ProxyQuery query,
    required Stream<Object> results,
  })  : _query = query,
        _results = results;

  final ProxyQuery _query;
  final Stream<Object> _results;

  @override
  Stream<Result> asStream() => asStream();

  @override
  Stream<D> asTypedStream<D extends Object>() => asTypedStream();

  @override
  Future<List<Result>> allResults() => asStream().toList();

  @override
  Future<List<D>> allTypedResults<D extends Object>() =>
      asTypedStream<D>().toList();
}

class AsyncBuilderQuery extends ProxyQuery with BuilderQueryMixin {
  AsyncBuilderQuery({
    BuilderQueryMixin? query,
    Iterable<SelectResultInterface>? selects,
    bool? distinct,
    DataSourceInterface? from,
    Iterable<JoinInterface>? joins,
    ExpressionInterface? where,
    Iterable<ExpressionInterface>? groupBys,
    ExpressionInterface? having,
    Iterable<OrderingInterface>? orderings,
    ExpressionInterface? limit,
    ExpressionInterface? offset,
  }) : super(language: '') {
    initBuilderQuery(
      query: query,
      selects: selects,
      distinct: distinct,
      from: from,
      joins: joins,
      where: where,
      groupBys: groupBys,
      having: having,
      orderings: orderings,
      limit: limit,
      offset: offset,
    );
  }
}
