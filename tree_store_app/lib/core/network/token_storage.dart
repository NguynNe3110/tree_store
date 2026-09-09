import 'package:hive_flutter/hive_flutter.dart';

class TokenStorage {
  static const _boxName = 'auth_box';
  static const _accessKey = 'accessToken';
  static const _refreshKey = 'refreshToken';

  Future<Box> _openBox() => Hive.openBox(_boxName);

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final box = await _openBox();
    await box.put(_accessKey, accessToken);
    await box.put(_refreshKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    final box = await _openBox();
    return box.get(_accessKey) as String?;
  }

  Future<String?> getRefreshToken() async {
    final box = await _openBox();
    return box.get(_refreshKey) as String?;
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.deleteAll([_accessKey, _refreshKey]);
  }
}