import '../../../data/models/user_model.dart';

class AuthPayloadModel {
  AuthPayloadModel({required this.token, required this.user});

  final String token;
  final UserModel user;

  factory AuthPayloadModel.fromJson(Map<String, dynamic> json) {
    return AuthPayloadModel(
      token: json['token'] as String? ?? '',
      user: UserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }
}
