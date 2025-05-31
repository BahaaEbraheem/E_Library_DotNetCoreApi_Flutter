import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library/blocs/books/books_event.dart';
import 'package:e_library/blocs/books/books_state.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/models/book.dart';

class BooksBloc extends Bloc<BooksEvent, BooksState> {
  final ApiService _apiService;

  BooksBloc(this._apiService) : super(BooksInitial()) {
    on<LoadBooksEvent>(_onLoadBooks);
    on<SearchBooksEvent>(_onSearchBooks);
    on<AddBookEvent>(_onAddBook);
    on<DeleteBookEvent>(_onDeleteBook);
    on<UpdateBookEvent>(_onUpdateBook);
  }
  Future<void> _onUpdateBook(
    UpdateBookEvent event,
    Emitter<BooksState> emit,
  ) async {
    emit(BooksLoading());
    try {
      // Add debug logs
      debugPrint('Attempting to update book ID: ${event.bookId}');
      debugPrint('Title: ${event.title}');
      debugPrint('Type: ${event.type}');
      debugPrint('Price: ${event.price}');
      debugPrint('Publisher ID: ${event.publisherId}');
      debugPrint('Author ID: ${event.authorId}');

      await _apiService.updateBook(
        {'token': event.token},
        event.bookId,
        {
          'title': event.title,
          'type': event.type,
          'price': event.price,
          'publisherId': event.publisherId,
          'authorId': event.authorId,
        },
      );

      // After successful update, reload books
      add(LoadBooksEvent());
    } catch (e) {
      debugPrint('Error in _onUpdateBook: $e');
      emit(BooksError(message: e.toString()));
    }
  }

  Future<void> _onLoadBooks(
    LoadBooksEvent event,
    Emitter<BooksState> emit,
  ) async {
    emit(BooksLoading());
    try {
      final booksData = await _apiService.getAllBooks();

      // إضافة سجل للتشخيص
      debugPrint('تم استلام ${booksData.length} كتاب من API');
      debugPrint(
        'عينة من البيانات: ${booksData.isNotEmpty ? booksData[0] : "لا توجد بيانات"}',
      );

      final books = booksData.map((book) => Book.fromJson(book)).toList();
      emit(BooksLoaded(books: books));
    } catch (e) {
      debugPrint('خطأ في تحميل الكتب: $e');
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
      // طباعة بيانات الكتاب للتشخيص
      debugPrint('محاولة إضافة كتاب جديد:');
      debugPrint('العنوان: ${event.title}');
      debugPrint('النوع: ${event.type}');
      debugPrint('السعر: ${event.price}');
      debugPrint('معرف الناشر: ${event.publisherId}');
      debugPrint('معرف المؤلف: ${event.authorId}');

      await _apiService.addBook(
        {'token': event.token},
        {
          'title': event.title,
          'type': event.type,
          'price': event.price,
          'publisherId': event.publisherId,
          'authorId': event.authorId,
        },
      );

      // بعد الإضافة، قم بتحميل الكتب مرة أخرى
      add(LoadBooksEvent());
    } catch (e) {
      debugPrint('خطأ في إضافة الكتاب: $e');
      emit(BooksError(message: e.toString()));
    }
  }

  Future<void> _onDeleteBook(
    DeleteBookEvent event,
    Emitter<BooksState> emit,
  ) async {
    emit(BooksLoading());
    try {
      await _apiService.deleteBook({'token': event.token}, event.bookId);

      // بعد الحذف، قم بتحميل الكتب مرة أخرى
      add(LoadBooksEvent());
    } catch (e) {
      emit(BooksError(message: e.toString()));
    }
  }
}
