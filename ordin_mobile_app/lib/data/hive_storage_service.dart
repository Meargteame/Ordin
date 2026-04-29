import 'package:hive_flutter/hive_flutter.dart';
import 'storage_service.dart';

class HiveStorageService implements StorageService {
  static const String _boxName = 'ordin_box';
  Box? _box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _box?.put(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _box?.get(key);
  }

  @override
  Future<void> saveList(String key, List<String> values) async {
    await _box?.put(key, values);
  }

  @override
  Future<List<String>> getList(String key) async {
    final result = _box?.get(key);
    if (result == null) return [];
    return List<String>.from(result);
  }

  @override
  Future<void> delete(String key) async {
    await _box?.delete(key);
  }
}
