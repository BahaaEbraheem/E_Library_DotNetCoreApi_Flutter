import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library/blocs/authors/authors_event.dart';
import 'package:e_library/blocs/authors/authors_state.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/models/author.dart';

class AuthorsBloc extends Bloc<AuthorsEvent, AuthorsState> {
  final ApiService _apiService;

  AuthorsBloc(this._apiService) : super(AuthorsInitial()) {
    on<LoadAuthorsEvent>(_onLoadAuthors);
    on<SearchAuthorsEvent>(_onSearchAuthors);
    on<AddAuthorEvent>(_onAddAuthor);
    on<DeleteAuthorEvent>(_onDeleteAuthor);
    on<UpdateAuthorEvent>(_onUpdateAuthor);
  }

  Future<void> _onLoadAuthors(
    LoadAuthorsEvent event,
    Emitter<AuthorsState> emit,
  ) async {
    emit(AuthorsLoading());
    try {
      final authorsData = await _apiService.getAllAuthors();
      final authors =
          authorsData.map((author) => Author.fromJson(author)).toList();
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
      final authors =
          authorsData.map((author) => Author.fromJson(author)).toList();
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
      // تقسيم الاسم الكامل إلى اسم أول واسم أخير
      List<String> nameParts = event.fullName.trim().split(' ');
      String firstName = nameParts.isNotEmpty ? nameParts.first : '';
      String lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // طباعة بيانات المؤلف للتشخيص
      debugPrint('محاولة إضافة مؤلف:');
      debugPrint('الاسم الكامل: ${event.fullName}');
      debugPrint('الاسم الأول: $firstName');
      debugPrint('الاسم الأخير: $lastName');
      debugPrint('البلد: ${event.country}');
      debugPrint('المدينة: ${event.city}');

      // إعداد بيانات المؤلف بالشكل الصحيح
      final authorData = {
        'fName': firstName,
        'lName': lastName,
        'country': event.country,
        'city': event.city,
        'address': event.address,
      };

      // طباعة التوكن للتشخيص (جزء منه فقط للأمان)
      debugPrint(
        'التوكن المستخدم: ${event.token.substring(0, min(20, event.token.length))}...',
      );

      // إعداد هيدر التوكن
      final Map<String, dynamic> headers = {
        'Authorization': 'Bearer ${event.token}',
      };

      // استدعاء خدمة API
      final result = await _apiService.addAuthor(headers, authorData);

      // طباعة نتيجة الاستدعاء
      debugPrint('نتيجة إضافة المؤلف: $result');

      // تحديث قائمة المؤلفين
      final authors = await _apiService.getAllAuthors();
      emit(
        AuthorsLoaded(
          authors: authors.map((data) => Author.fromJson(data)).toList(),
        ),
      );
    } catch (e) {
      debugPrint('خطأ في إضافة المؤلف: $e');
      emit(AuthorsError(message: e.toString()));
    }
  }

  Future<void> _onDeleteAuthor(
    DeleteAuthorEvent event,
    Emitter<AuthorsState> emit,
  ) async {
    emit(AuthorsLoading());
    try {
      await _apiService.deleteAuthor({'token': event.token}, event.authorId);

      // بعد الحذف، قم بتحميل المؤلفين مرة أخرى
      add(LoadAuthorsEvent());
    } catch (e) {
      emit(AuthorsError(message: e.toString()));
    }
  }

  Future<void> _onUpdateAuthor(
    UpdateAuthorEvent event,
    Emitter<AuthorsState> emit,
  ) async {
    emit(AuthorsLoading());
    try {
      await _apiService.updateAuthor(
        {'token': event.token},
        event.authorId,
        {
          'fullName': event.fullName,
          'country': event.country,
          'city': event.city,
        },
      );

      // بعد التحديث، قم بتحميل المؤلفين مرة أخرى
      add(LoadAuthorsEvent());
    } catch (e) {
      emit(AuthorsError(message: e.toString()));
    }
  }
}
