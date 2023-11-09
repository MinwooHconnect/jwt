// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dio = Dio();

  test(
    'api test',
    () async {
      configure(dio);
      await sendData(dio);
    },
  );
}

void configure(Dio dio) {
  // Set default configs
  dio.options.baseUrl = 'https://mapi.health-on.co.kr/';
  dio.options.connectTimeout = Duration(seconds: 5);
  dio.options.receiveTimeout = Duration(seconds: 3);
}

Future<void> sendData(Dio dio) async {
  final formData = {
    'osType': '90103200',
    'languageCode': '10801100',
    'reqDate': '20231106182028'
  };
  final response = await dio.post('/IF-HLO-CHMC-0001', data: formData);
  print(response);
}
