import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import './secure_storage.dart';

class DioClient {
  static Dio? _instance;
  static Dio get instance {
    _instance ??= _createDio();  // Singleton pattern
    return _instance!;
  }
 
  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));
 
    // Interceptor 1: Logging
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        debugPrint('[REQUEST] ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[RESPONSE] ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) async {
        debugPrint('====================');
        debugPrint('ERROR TYPE: ${error.type}');
        debugPrint('ERROR MSG : ${error.message}');
        debugPrint('STATUS    : ${error.response?.statusCode}');
        debugPrint('DATA      : ${error.response?.data}');
        debugPrint('URL       : ${error.requestOptions.uri}');
        debugPrint('====================');

        if (error.response?.statusCode == 401) {
          await SecureStorageService.clearAll();
        }

        handler.next(error);
      },
    ));
 
    // Interceptor 2: Auto-inject Bearer Token
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageService.getToken();

        debugPrint('TOKEN: $token');
        debugPrint('URL  : ${options.uri}');

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },
    ));
 
    return dio;
  }
}
