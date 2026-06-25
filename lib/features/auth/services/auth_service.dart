import '../models/user_model.dart';
import '../../../core/network/dio_client.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/Auth/login',
        data: {'email': email, 'password': password},
      );
      
      // Assuming response.data contains { "token": "...", "email": "..." }
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
