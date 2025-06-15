abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  LoginEvent({required this.username, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final bool isAdmin;

  RegisterEvent({
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.isAdmin,
  });
}

class LogoutEvent extends AuthEvent {}
