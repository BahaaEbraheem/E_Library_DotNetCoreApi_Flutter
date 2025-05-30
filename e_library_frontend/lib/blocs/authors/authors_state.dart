import 'package:e_library_frontend/models/author.dart';

abstract class AuthorsState {}

class AuthorsInitial extends AuthorsState {}

class AuthorsLoading extends AuthorsState {}

class AuthorsLoaded extends AuthorsState {
  final List<Author> authors;

  AuthorsLoaded({required this.authors});
}

class AuthorsError extends AuthorsState {
  final String message;

  AuthorsError({required this.message});
}
