import 'query.dart';

/// A [Query] data source.
///
/// {@category Query Builder}
abstract class DataSourceInterface {}

/// A [Query] data source, with the ability to assign it an alias.
///
/// {@category Query Builder}
abstract class DataSourceAs extends DataSourceInterface {
  /// Specifies an [alias] for this data source.
  DataSourceInterface as(String alias);
}

/// Factory for creating data sources.
///
/// {@category Query Builder}
class DataSource {
  DataSource._();

  /// Creates a data source from a [Database].
  @Deprecated('Use DataSource.collection(database.defaultCollection) instead.')
  static DataSourceAs database(Object database) =>
      DataSourceAsImpl(source: database);

  /// Creates a data source from a [Collection].
  static DataSourceAs collection(Object collection) =>
      DataSourceAsImpl(source: collection);
}

// === Impl ====================================================================

class DataSourceImpl implements DataSourceInterface {
  DataSourceImpl({required this.source, this.alias});

  final Object source;
  final String? alias;

  Object get database => {};

  Map<String, Object?> toJson() => {};
}

class DataSourceAsImpl extends DataSourceImpl implements DataSourceAs {
  DataSourceAsImpl({required super.source, super.alias});

  @override
  DataSourceInterface as(String alias) =>
      DataSourceImpl(source: source, alias: alias);
}
