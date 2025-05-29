import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library_frontend/blocs/books/books_event.dart';
import 'package:e_library_frontend/blocs/books/books_state.dart';
import 'package:e_library_frontend/services/api_service.dart';
import 'package:e_library_frontend/models/book.dart';

class BooksBloc extends Bloc<BooksEvent, BooksState> {
  final ApiService _apiService;

  BooksBloc(this._apiService) : super(BooksInitial()) {
    on<LoadBooksEvent>(_onLoadBooks);
    on<SearchBooksEvent>(_onSearchBooks);
    on<AddBookEvent>(_onAddBook);
  }

  Future<void> _onLoadBooks(
    LoadBooksEvent event,
    Emitter<BooksState> emit,
  ) async {
    emit(BooksLoading());
    try {
      final booksData = await _apiService.getAllBooks();
      final books = booksData.map((book) => Book.fromJson(book)).toList();
      emit(BooksLoaded(books: books));
    } catch (e) {
      emit(BooksError(message: e.toString()));
    }
  }

  Future<void> _onSearchBooks(
    SearchBooksEvent event,
    Emitter<BooksState> emit,
  ) async {
    emit(BooksLoading());
    try {
      final booksData = await _apiService.searchBooks(event.query);
      final books = booksData.map((book) => Book.fromJson(book)).toList();
      emit(BooksLoaded(books: books));
    } catch (e) {
      emit(BooksError(message: e.toString()));
    }
  }

  Future<void> _onAddBook(AddBookEvent event, Emitter<BooksState> emit) async {
    emit(BooksLoading());
    try {
      await _apiService.addBook(event.token as Map<String, dynamic>, {
        'title': event.title,
        'type': event.type,
        'price': event.price,
        'publisherId': event.publisherId,
        'authorId': event.authorId,
      });

      // بعد الإضافة، قم بتحميل الكتب مرة أخرى
      add(LoadBooksEvent());
    } catch (e) {
      emit(BooksError(message: e.toString()));
    }
  }
}
