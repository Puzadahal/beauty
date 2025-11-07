import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class LocalStorageKeys {
  static const String user = 'auth_user';
}

class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  Future<void> saveUser(UserModel user) async {
    final encoded = jsonEncode(user.toJson());
    await _prefs.setString(LocalStorageKeys.user, encoded);
  }

  UserModel? getUser() {
    final encoded = _prefs.getString(LocalStorageKeys.user);
    if (encoded == null) return null;
    try {
      final Map<String, dynamic> data =
          jsonDecode(encoded) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUser() => _prefs.remove(LocalStorageKeys.user);
}
