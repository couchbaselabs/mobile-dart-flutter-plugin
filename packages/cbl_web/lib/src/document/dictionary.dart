abstract class DictionaryInterface {
  int get length;

  T? value<T extends Object>(String key);

  Map<String, Object?> toPlainMap();
}

abstract class Dictionary implements DictionaryInterface, Iterable<String> {
  /// Returns this dictionary's data as JSON.
  String toJson();
}
