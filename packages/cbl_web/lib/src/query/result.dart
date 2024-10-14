// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'dart:collection';
import 'dart:convert';

import '../document/array.dart';
import '../document/dictionary.dart';
import 'result_set.dart';

/// A single row in a [ResultSet].
///
/// The name of a column is determined by the first applicable rule of the
/// following rules:
///
/// 1. The alias name of an aliased column.
/// 2. The last component of a property expression. Functions for example, are
///    **not** property expressions.
/// 3. A generated key of the format `$1`, `$2`, `$3`, ... The number after `$`
///    corresponds to the position of the column among the rest of the unnamed
///    columns and starts at `1`.
///
/// {@category Query}
abstract class Result implements Iterable<String>, DictionaryInterface {
  /// The number of column in this result.
  @override
  int get length;

  /// The names of the columns in this result.
  @override
  List<String> get keys;

  /// Returns the column at the given [nameOrIndex].
  ///
  /// Returns `null` if the column is `null`.
  ///
  /// Throws a [RangeError] if [nameOrIndex] is ouf of range.
  T? value<T extends Object>(Object nameOrIndex);

  /// Returns the column at the given [nameOrIndex] as a [String].
  ///
  /// {@template cbl.Result.typedNullableGetter}
  /// Returns `null` if the value is not a of the expected typ or it is `null`.
  ///
  /// Throws a [RangeError] if the [nameOrIndex] is ouf of range.
  /// {@endtemplate}
  String? string(Object nameOrIndex);

  /// Returns the column at the given [nameOrIndex] as an integer number.
  ///
  /// {@template cbl.Result.typedDefaultedGetter}
  /// Returns a default value (integer: `0`, double: `0.0`, boolean: `false`) if
  /// the column is not of the expected type or is `null`.
  ///
  /// Throws a [RangeError] if the [nameOrIndex] is ouf of range.
  /// {@endtemplate}
  int integer(Object nameOrIndex);

  /// Returns the column at the given [nameOrIndex] as an floating point number.
  ///
  /// {@macro cbl.Result.typedDefaultedGetter}
  double float(Object nameOrIndex);

  /// Returns the column at the given [nameOrIndex] as a [num].
  ///
  /// {@macro cbl.Result.typedNullableGetter}
  num? number(Object nameOrIndex);

  /// Returns the column at the given [nameOrIndex] as a [bool].
  ///
  /// {@macro cbl.Result.typedDefaultedGetter}
  bool boolean(Object nameOrIndex);

  /// Returns the column at the given [nameOrIndex] as a [DateTime].
  ///
  /// {@macro cbl.Result.typedNullableGetter}
  DateTime? date(Object nameOrIndex);

  /// Returns the column at the given [nameOrIndex] as a [Blob].
  ///
  /// {@macro cbl.Result.typedNullableGetter}
  Object? blob(Object nameOrIndex);

  /// Returns the column at the given [nameOrIndex] as an [Array].
  ///
  /// {@macro cbl.Result.typedNullableGetter}
  Array? array(Object nameOrIndex);

  /// Returns the column at the given [nameOrIndex] as a [Dictionary].
  ///
  /// {@macro cbl.Result.typedNullableGetter}
  Dictionary? dictionary(Object nameOrIndex);

  /// Returns whether a column with the given [nameOrIndex] exists in this
  /// result.
  @override
  bool contains(Object? nameOrIndex);

  /// Returns a [Fragment] for the column at the given [nameOrIndex].
  Object operator [](Object nameOrIndex);

  /// Returns a JSON string which contains a dictionary of the named columns of
  /// this result.
  String toJson();
}

class ResultImpl with IterableMixin<String> implements Result {
  factory ResultImpl.fromTransferableValue(
    Object value, {
    required Object context,
    required List<String> columnNames,
  }) {
    return ResultImpl.fromValuesArray(
      [],
      context: context,
      columnNames: columnNames,
    );
  }

  /// Creates a result from an array of the column values, encoded in a chunk of
  /// Fleece [data].
  ///
  /// The [context] must not be shared with other [Result]s.
  ResultImpl.fromValuesData(
    Object data, {
    required Object context,
    required List<String> columnNames,
  })  : _context = context,
        _columnNames = columnNames,
        columnValuesArray = null,
        columnValuesData = data;

  /// Creates a result from a fleece [array] fo the column values.
  ///
  /// The [context] can be shared with other [Result]s, if it is guaranteed that
  /// all results are from the same chunk of encoded Fleece data.
  ResultImpl.fromValuesArray(
    Object array, {
    required Object context,
    required List<String> columnNames,
  })  : _context = context,
        _columnNames = columnNames,
        columnValuesArray = array,
        columnValuesData = null;

  final Object _context;
  final List<String> _columnNames;
  final Object? columnValuesData;
  final Object? columnValuesArray;

  late final Object _array = [];
  late final Object _dictionary = {};

  Object get asDictionary => _dictionary;

  @override
  Iterator<String> get iterator => _columnNames.iterator;

  @override
  List<String> get keys => _columnNames;

  @override
  T? value<T extends Object>(Object nameOrIndex) {
    _checkNameOrIndex(nameOrIndex);
  }

  @override
  String? string(Object nameOrIndex) {
    _checkNameOrIndex(nameOrIndex);
  }

  @override
  int integer(Object nameOrIndex) {
    _checkNameOrIndex(nameOrIndex);
    return 0;
  }

  @override
  double float(Object nameOrIndex) {
    _checkNameOrIndex(nameOrIndex);
    return 0;
  }

  @override
  num? number(Object nameOrIndex) {
    _checkNameOrIndex(nameOrIndex);
    return 0;
  }

  @override
  bool boolean(Object nameOrIndex) {
    _checkNameOrIndex(nameOrIndex);
    return false;
  }

  @override
  DateTime? date(Object nameOrIndex) {
    _checkNameOrIndex(nameOrIndex);
    return null;
  }

  @override
  Object? blob(Object nameOrIndex) {
    _checkNameOrIndex(nameOrIndex);
  }

  @override
  Array? array(Object nameOrIndex) {
    _checkNameOrIndex(nameOrIndex);
    return null;
  }

  @override
  Dictionary? dictionary(Object nameOrIndex) {
    _checkNameOrIndex(nameOrIndex);
    return null;
  }

  @override
  // ignore: avoid_renaming_method_parameters
  bool contains(Object? nameOrIndex) {
    _checkNameOrIndex(nameOrIndex);
    if (nameOrIndex is int) {
      return nameOrIndex >= 0 && nameOrIndex < _columnNames.length;
    }
    return _columnNames.contains(nameOrIndex);
  }

  @override
  Object operator [](Object nameOrIndex) {
    _checkNameOrIndex(nameOrIndex);
    return [];
  }

  @override
  List<Object?> toPlainList() => [];

  @override
  Map<String, Object?> toPlainMap() => {};

  @override
  String toJson() => '';

  Object? encodeColumnValues(Object format) {}

  void _checkNameOrIndex(Object? nameOrIndex) {
    if (!(nameOrIndex is int || nameOrIndex is String)) {
      throw ArgumentError.value(
        nameOrIndex,
        'nameOrIndex',
        'must be a String or int',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultImpl &&
          runtimeType == other.runtimeType &&
          _dictionary == other._dictionary;

  @override
  int get hashCode => _dictionary.hashCode;

  @override
  String toString() => '';
}
