class AuthResponse {
  final String token;
  final String? message;

  AuthResponse({
    required this.token,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() => 'AuthResponse(token: $token, message: $message)';
}
