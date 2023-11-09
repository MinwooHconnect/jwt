import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_test_api_1106/dio/auth_repository.dart';
import 'package:dio_test_api_1106/dio/dio_client.dart';
import 'package:dio_test_api_1106/hive_manager.dart';
import 'package:logger/logger.dart';

class CustomInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    printRequest(options);
    // 로그인 요청의 경우 토큰을 헤더에 추가하지 않음
    if (!options.path.contains("/login")) {
      String? accessToken = await HiveTokenManager().getAccessToken();
      if (accessToken != null) {
        options.headers["Authorization"] = "Bearer $accessToken";
      }
    }
    return super.onRequest(options, handler);
  }

  void printRequest(RequestOptions options) {
    String prettyJson =
        const JsonEncoder.withIndent('  ').convert(options.data);
    Logger().d("Request data: $prettyJson");
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    printResponse(response);
    final retCd = response.data['retCd'];
    if (retCd == "2") {
      _handleTokenExpiration(response.requestOptions, handler);
    } else {
      return handler.next(response); // 다른 retCd에 대한 처리
    }
  }

  void printResponse(Response<dynamic> response) {
    String prettyJson =
        const JsonEncoder.withIndent('  ').convert(response.data);
    Logger().d("Response data: $prettyJson");
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 에러 발생 시 로직
    print('Error: ${err.response?.statusCode}');
    Logger().e(err.response?.data);
    return handler.next(err); // 에러를 계속 전파합니다.
  }

  void _handleTokenExpiration(
      RequestOptions requestOptions, ResponseInterceptorHandler handler) async {
    try {
      // refreshToken을 사용하여 토큰 갱신 요청
      var newAccessToken = await AuthRepository().refreshToken();

      // 새로운 엑세스 토큰으로 요청 헤더 업데이트
      requestOptions.headers["Authorization"] = "Bearer $newAccessToken";

      // 원래 요청 재전송
      var response = await DioClient().fetch(requestOptions);
      return handler.resolve(response);
    } catch (e) {
      // 토큰 갱신 실패 처리
      return handler
          .reject(DioException(requestOptions: requestOptions, error: e));
    }
  }
}

class CustomLogInterceptor extends LogInterceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }
}

//
// case 0:
// // 성공 처리
// break;
// case 1:
// // 처리되지 않은 인가 처리
// break;
// case 2:
// // 엑세스토큰 만료 처리
// break;
// case 3:
// // 엑세스토큰이 유효하지 않음 처리
// break;
// default:
// // 기타 경우 처리
