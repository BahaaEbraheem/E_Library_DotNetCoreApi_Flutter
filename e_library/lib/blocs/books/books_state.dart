import 'package:e_library/models/book.dart';

abstract class BooksState {}

class BooksInitial extends BooksState {}

class BooksLoading extends BooksState {}

class BooksLoaded extends BooksState {
  final List<Book> books;

  BooksLoaded({required this.books});
}

class BooksError extends BooksState {
  final String message;

  BooksError({required this.message});
}
