import 'package:hive_flutter/hive_flutter.dart';

abstract class HiveService {
  Future<void> init();
  Future<void> putData(String boxName, String key, dynamic value);
  dynamic getData(String boxName, String key);
  Future<void> deleteData(String boxName, String key);
  Future<void> clearBox(String boxName);
}

class HiveServiceImpl implements HiveService {
  static const String weatherBoxName = 'weather_cache_box';

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(weatherBoxName);
  }

  @override
  Future<void> putData(String boxName, String key, dynamic value) async {
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : await Hive.openBox(boxName);
    await box.put(key, value);
  }

  @override
  dynamic getData(String boxName, String key) {
    if (!Hive.isBoxOpen(boxName)) {
      return null;
    }
    final box = Hive.box(boxName);
    return box.get(key);
  }

  @override
  Future<void> deleteData(String boxName, String key) async {
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : await Hive.openBox(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clearBox(String boxName) async {
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : await Hive.openBox(boxName);
    await box.clear();
  }
}
