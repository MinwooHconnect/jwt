import 'package:hive_flutter/hive_flutter.dart';

class HiveTokenManager {
  static const String _authBox = 'authBox';
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _authId = 'authId';
  static const String _authKey = 'authKey';
  static const String _userSno = 'userSno';

  static final HiveTokenManager _instance = HiveTokenManager._internal();
  static bool _initialized = false;

  factory HiveTokenManager() {
    return _instance;
  }

  HiveTokenManager._internal() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (!_initialized) {
      await Hive.initFlutter();
      _initialized = true;
    }
  }

  Future<Box<dynamic>> _openBox() async {
    return await Hive.openBox(_authBox);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final box = await _openBox();
    await box.put(_accessTokenKey, accessToken);
    await box.put(_refreshTokenKey, refreshToken);
  }

  Future<void> saveAuthAndSno(
      {String? authId, String, authKey, String? userSno}) async {
    final box = await _openBox();
    if (authId != null) await box.put(_authId, authId);
    if (authKey != null) await box.put(_authKey, authKey);
    if (userSno != null) await box.put(_userSno, userSno);
  }

  Future<String?> getAccessToken() async {
    final box = await _openBox();
    return box.get(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final box = await _openBox();
    return box.get(_refreshTokenKey);
  }

  Future<String?> getAuthId() async {
    final box = await _openBox();
    return box.get(_authId);
  }

  Future<String?> getAuthKey() async {
    final box = await _openBox();
    return box.get(_authKey);
  }

  Future<String?> getUserSno() async {
    final box = await _openBox();
    return box.get(_userSno);
  }
}
