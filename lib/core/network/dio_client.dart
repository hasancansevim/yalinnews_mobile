import 'package:dio/dio.dart';
import 'jwt_interceptor.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  late final Dio dio;

  DioClient(SecureStorageService storageService) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://yalinnews.onrender.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add JWT Interceptor
    dio.interceptors.add(JwtInterceptor(storageService));
    
    // Add logging interceptor for debugging in dev mode (Disabled to prevent terminal spam)
  }
}
