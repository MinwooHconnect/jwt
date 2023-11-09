// auth_repository.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_test_api_1106/dio/dio_client.dart';
import 'package:dio_test_api_1106/hive_manager.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();

  AuthRepository._internal();

  factory AuthRepository() {
    return _instance;
  }

  Future<void> login({
    required String userMobileNo,
    required String userPwd,
  }) async {
    try {
      await loginStep1(userMobileNo, userPwd);
      await loginStep2();
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  Future<void> loginStep1(String userMobileNo, String userPwd) async {
    final response = await DioClient().post('/IF-HLO-CHMC-0300', data: {
      'userCountryNo': '82',
      'userMobileNo': userMobileNo,
      'userPwd': userPwd,
      'osType': Platform.isAndroid ? '90103200' : '90103100',
      'registrationId': 'deviceToken',
      'languageCode': '10801300',
      'appVersion': '1.2.7',
      'reqDate': "20231108171931",
    });

    if (response.statusCode == 200) {
      final responseData = response.data;
      final tokensData = responseData['data'];
      await HiveTokenManager().saveTokens(
        tokensData['accessToken'],
        tokensData['refreshToken'],
      );
      await HiveTokenManager().saveAuthAndSno(
        authId: tokensData['authId'],
        authKey: tokensData['authKey'],
        //authKey: tokensData['userSno'],
      );
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  Future<void> loginStep2() async {
    final response = await DioClient().post('/IF-HLO-CHMC-0500', data: {
      'authKey': await HiveTokenManager().getAuthKey(),
      'pageNum': 0,
      'reqDate': "20231108171931",
    });

    if (response.statusCode == 200) {
      final responseData = response.data;
      final tokensData = responseData['data'];
      await HiveTokenManager().saveAuthAndSno(
        userSno: tokensData['userSno'],
      );
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  Future<String> refreshToken() async {
    try {
      final refreshToken = await HiveTokenManager().getRefreshToken();
      final authId = await HiveTokenManager().getAuthId();
      final userSno = await HiveTokenManager().getUserSno();

      if (refreshToken == null || authId == null) {
        throw Exception('No refreshToken or authId available');
      }

      final response = await DioClient().post(
        '/api/auth/access-token',
        data: {
          'authId': authId,
          'refreshToken': refreshToken,
          'userSno': userSno,
        },
        headers: {}, // 헤더를 비운다.
      );

      if (response.statusCode == 200 && response.data['retCd'] == '0') {
        final tokensData = response.data['data'];
        await HiveTokenManager().saveTokens(
          tokensData['accessToken'],
          tokensData['refreshToken'],
        );
        return tokensData['accessToken'];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      print('Refresh Token Error: $e');
      rethrow;
    }
  }
}
