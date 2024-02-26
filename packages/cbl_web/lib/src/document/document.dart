import '../../cbl_web.dart';

abstract class Document implements DictionaryInterface, Iterable<String> {
  String get id;
}

class MutableDocument implements DictionaryInterface {
  MutableDocument([this.map]);

  Map<String, dynamic>? map;

  @override
  // TODO: implement length
  int get length => 1;

  @override
  T? value<T extends Object>(String key) {
    return null;
  }

  @override
  Map<String, Object?> toPlainMap() {
    return this.map ?? {};
  }
}
