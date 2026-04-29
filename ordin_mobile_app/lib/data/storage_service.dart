abstract class StorageService {
  Future<void> init();
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveList(String key, List<String> values);
  Future<List<String>> getList(String key);
  Future<void> delete(String key);
}
