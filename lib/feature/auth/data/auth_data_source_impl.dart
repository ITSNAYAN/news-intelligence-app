import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_api_app/feature/auth/data/auth_data_model.dart';
import 'package:news_api_app/feature/auth/data/auth_data_source.dart';

class AuthDataSourceImpl implements AuthDataSource {
  AuthDataSourceImpl(this._box);

  // Box is opened once in main.dart and injected here.
  final Box<String> _box;
  static const _userKey = 'current_user';

  @override
  Future<void> saveUser(AuthDataModel user) =>
         _box.put(_userKey, jsonEncode(user.toJson()));

  @override
  AuthDataModel? getUserData() {
      final raw = _box.get(_userKey);
    if (raw == null) return null;
      return AuthDataModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> clearUser() => _box.delete(_userKey);
}