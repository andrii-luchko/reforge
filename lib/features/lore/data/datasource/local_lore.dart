import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:reforge/features/lore/data/models/plates_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalLoreDataSource {
  Future<List<PlatesModel>> getPlates();
  Future<void> storePlates(List<PlatesModel> models);
}

@Injectable(as: LocalLoreDataSource)
class LocalLoreDataSourceImpl implements LocalLoreDataSource {
  LocalLoreDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'lore_plates';

  @override
  Future<List<PlatesModel>> getPlates() async {
    final jsonString = _prefs.getString(_key);

    if (jsonString == null) return [];

    try {
      final jsonList = json.decode(jsonString) as List<dynamic>;

      return jsonList.map((e) => PlatesModel.fromJson(e as Map<String, dynamic>)).toList();

      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> storePlates(List<PlatesModel> models) async {
    final jsonString = json.encode(
      models.map((m) => m.toJson()).toList(),
    );
    await _prefs.setString(_key, jsonString);
  }
}
