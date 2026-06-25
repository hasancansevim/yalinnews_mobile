import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider((ref) => SecureStorageService(const FlutterSecureStorage()));

final dioClientProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage);
});

final authServiceProvider = Provider((ref) {
  final client = ref.watch(dioClientProvider);
  return AuthService(client);
});

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final storageService = ref.watch(secureStorageProvider);
    final token = await storageService.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.watch(authServiceProvider);
      final storageService = ref.watch(secureStorageProvider);
      
      final user = await authService.login(email, password);
      await storageService.saveToken(user.token);
      state = const AsyncValue.data(true);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    final storageService = ref.watch(secureStorageProvider);
    await storageService.deleteToken();
    state = const AsyncValue.data(false);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});
