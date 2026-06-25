import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

class JwtInterceptor extends Interceptor {
  final SecureStorageService _storageService;

  JwtInterceptor(this._storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storageService.getToken();
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If the error is 401 Unauthorized, we could potentially handle token refresh here
    // or log the user out.
    if (err.response?.statusCode == 401) {
      // Handle unauthorized (e.g. clear token, redirect to login)
      _storageService.deleteToken();
    }
    super.onError(err, handler);
  }
}
