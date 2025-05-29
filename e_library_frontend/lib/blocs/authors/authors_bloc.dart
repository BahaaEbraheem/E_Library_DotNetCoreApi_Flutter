import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library_frontend/blocs/authors/authors_event.dart';
import 'package:e_library_frontend/blocs/authors/authors_state.dart';
import 'package:e_library_frontend/services/api_service.dart';
import 'package:e_library_frontend/models/author.dart';

class AuthorsBloc extends Bloc<AuthorsEvent, AuthorsState> {
  final ApiService _apiService;

  AuthorsBloc(this._apiService) : super(AuthorsInitial()) {
    on<LoadAuthorsEvent>(_onLoadAuthors);
    on<SearchAuthorsEvent>(_onSearchAuthors);
    on<AddAuthorEvent>(_onAddAuthor);
  }

  Future<void> _onLoadAuthors(
    LoadAuthorsEvent event,
    Emitter<AuthorsState> emit,
  ) async {
    emit(AuthorsLoading());
    try {
      final authorsData = await _apiService.getAllAuthors();
      final authors = authorsData.map((author) => Author.fromJson(author)).toList();
      emit(AuthorsLoaded(authors: authors));
    } catch (e) {
      emit(AuthorsError(message: e.toString()));
    }
  }

  Future<void> _onSearchAuthors(
    SearchAuthorsEvent event,
    Emitter<AuthorsState> emit,
  ) async {
    emit(AuthorsLoading());
    try {
      final authorsData = await _apiService.searchAuthors(event.query);
      final authors = authorsData.map((author) => Author.fromJson(author)).toList();
      emit(AuthorsLoaded(authors: authors));
    } catch (e) {
      emit(AuthorsError(message: e.toString()));
    }
  }

  Future<void> _onAddAuthor(
    AddAuthorEvent event,
    Emitter<AuthorsState> emit,
  ) async {
    emit(AuthorsLoading());
    try {
      await _apiService.addAuthor(event.token as Map<String, dynamic>, {
        'fullName': event.fullName,
        'country': event.country,
        'city': event.city,
      });

      // بعد الإضافة، قم بتحميل المؤلفين مرة أخرى
      add(LoadAuthorsEvent());
    } catch (e) {
      emit(AuthorsError(message: e.toString()));
    }
  }
}