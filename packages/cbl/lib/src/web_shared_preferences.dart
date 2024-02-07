import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SharedPrefsService {
  Future<bool> clear(String key);

  Future<bool> clearAll();

  Future<T?> getValue<T>(String key);

  Future<bool> setValue(String key, Object value);
}

class SharedPrefsServiceImpl implements SharedPrefsService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.reload();

    return _prefs!;
  }

  SharedPrefsServiceImpl();

  @override
  Future<bool> clear(String key) async {
    assert(key == null || key == '', 'Key cannot be null or empty');

    return (await prefs).remove(key);
  }

  @override
  Future<bool> clearAll() async => (await prefs).clear();

  @override
  Future<T?> getValue<T>(String key) async {
    assert(key == null || key == '', 'Key cannot be null or empty');

    final value = (await prefs).get(key);

    return value as T?;
  }

  @override
  Future<bool> setValue(String key, Object value) async {
    assert(key == null || key == '', 'Key cannot be null or empty');

    if (value is String) {
      return (await prefs).setString(key, value);
    } else if (value is int) {
      return (await prefs).setInt(key, value);
    } else if (value is double) {
      return (await prefs).setDouble(key, value);
    } else if (value is bool) {
      return (await prefs).setBool(key, value);
    } else {
      return (await prefs).setString(key, value.toString());
    }
  }
}
