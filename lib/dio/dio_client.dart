import 'package:dio/dio.dart';
import 'package:dio_test_api_1106/dio/interceptor.dart';
import 'package:dio_test_api_1106/hive_manager.dart';

class DioClient {
  final Dio _dio;
  final String token =
      "dKpI6DSWSLyVFx8UE6QDRQ:APA91bETqIZq1qz3Y5-gHsDHx3kL1VHU2rY0FRrW13NtP5yOzaMo9S9yiF_TYTVSEMmF54F3DxavJRimMVDXoLQYUSzMgTUl6H2CEWeASg4VJjjs0bXLvDRiHilsSOYsaqs73-dFU0we";

  static final DioClient _instance = DioClient._internal();

  DioClient._internal() : _dio = Dio() {
    _dio.interceptors.add(LogInterceptor());
    _dio.interceptors.add(CustomInterceptor());
  }

  factory DioClient() {
    return _instance;
  }

  static void initialize({
    required String baseUrl,
    HiveTokenManager? tokenManager,
  }) {
    _instance._dio.options = BaseOptions(baseUrl: baseUrl);
    if (tokenManager != null) {
      _instance._dio.interceptors
          .removeWhere((interceptor) => interceptor is CustomInterceptor);
      _instance._dio.interceptors.add(CustomInterceptor());
    }
  }

  // post 메소드 추가
  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? headers}) async {
    return _dio.post(path, data: data, options: Options(headers: headers));
  }

  // fetch 메소드 추가
  Future<Response> fetch(RequestOptions requestOptions) {
    return _dio.fetch(requestOptions);
  }
}
