import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/user_model.dart';
import '../models/auth_payload_model.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required SecureStorageService storageService,
  }) : _apiClient = apiClient,
       _storageService = storageService;

  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  Future<AuthPayloadModel> login({
    required String email,
    required String password,
  }) async {
    final Response<dynamic> response = await _apiClient.post(
      '/auth/login',
      data: <String, dynamic>{'email': email, 'password': password},
    );

    final ApiResponse<AuthPayloadModel> payload =
        ApiResponse<AuthPayloadModel>.fromJson(
          response.data as Map<String, dynamic>? ?? <String, dynamic>{},
          (dynamic raw) => AuthPayloadModel.fromJson(
            raw as Map<String, dynamic>? ?? <String, dynamic>{},
          ),
        );

    if (!payload.success) {
      throw Exception(payload.message);
    }

    await _storageService.saveToken(payload.data.token);
    return payload.data;
  }

  Future<UserModel> me() async {
    final Response<dynamic> response = await _apiClient.get('/auth/me');
    final ApiResponse<UserModel> payload = ApiResponse<UserModel>.fromJson(
      response.data as Map<String, dynamic>? ?? <String, dynamic>{},
      (dynamic raw) => UserModel.fromJson(
        raw as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );

    if (!payload.success) {
      throw Exception(payload.message);
    }

    return payload.data;
  }

  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
    await _storageService.clearToken();
  }

  Future<String?> getStoredToken() {
    return _storageService.getToken();
  }

  Future<void> clearStoredToken() {
    return _storageService.clearToken();
  }
}
