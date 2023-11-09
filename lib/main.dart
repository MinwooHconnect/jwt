import 'package:dio_test_api_1106/dio/auth_repository.dart';
import 'package:dio_test_api_1106/dio/dio_client.dart';
import 'package:dio_test_api_1106/hive_manager.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DioClient.initialize(
      baseUrl: 'https://mapi-stg.health-on.co.kr',
      tokenManager: HiveTokenManager());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                child: Text('로그인'),
                onPressed: _handleLogin, // 버튼 클릭시 fetchApi 호출
              ),
              OutlinedButton(
                child: Text('리프레시토큰'),
                onPressed: _refreshToken, // 버튼 클릭시 fetchApi 호출
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    try {
      await AuthRepository()
          .login(userMobileNo: '01000000000', userPwd: '116622');
      // 로그인 성공 처리
      print('Login successful');
    } catch (e) {
      // 로그인 실패 처리
      print('Login failed: $e');
    }
  }

  void _refreshToken() async {
    try {
      print('현재토큰: ${await HiveTokenManager().getAccessToken()}');
      print('현재토큰: ${await HiveTokenManager().getRefreshToken()}');
      await AuthRepository().refreshToken();
      print('이후토큰: ${await HiveTokenManager().getAccessToken()}');
      print('이후토큰: ${await HiveTokenManager().getRefreshToken()}');
      // 로그인 성공 처리
      print('refresh successful');
    } catch (e) {
      // 로그인 실패 처리
      print('refresh failed: $e');
    }
  }
}
