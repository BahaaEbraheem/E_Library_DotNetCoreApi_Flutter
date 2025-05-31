import 'package:e_library/models/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  final User user;
  final bool isAdmin;

  AuthAuthenticated({
    required this.token,
    required this.user,
    required this.isAdmin,
  });
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}
