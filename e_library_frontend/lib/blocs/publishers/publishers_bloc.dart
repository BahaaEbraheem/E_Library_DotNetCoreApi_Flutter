import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library_frontend/blocs/publishers/publishers_event.dart';
import 'package:e_library_frontend/blocs/publishers/publishers_state.dart';
import 'package:e_library_frontend/services/api_service.dart';
import 'package:e_library_frontend/models/publisher.dart';

class PublishersBloc extends Bloc<PublishersEvent, PublishersState> {
  final ApiService _apiService;

  PublishersBloc(this._apiService) : super(PublishersInitial()) {
    on<LoadPublishersEvent>(_onLoadPublishers);
    on<SearchPublishersEvent>(_onSearchPublishers);
    on<AddPublisherEvent>(_onAddPublisher);
    on<DeletePublisherEvent>(_onDeletePublisher);
    on<UpdatePublisherEvent>(_onUpdatePublisher);
  }

  Future<void> _onLoadPublishers(
    LoadPublishersEvent event,
    Emitter<PublishersState> emit,
  ) async {
    emit(PublishersLoading());
    try {
      final publishersData = await _apiService.getAllPublishers();
      final publishers =
          publishersData
              .map((publisher) => Publisher.fromJson(publisher))
              .toList();
      emit(PublishersLoaded(publishers: publishers));
    } catch (e) {
      emit(PublishersError(message: e.toString()));
    }
  }

  Future<void> _onSearchPublishers(
    SearchPublishersEvent event,
    Emitter<PublishersState> emit,
  ) async {
    emit(PublishersLoading());
    try {
      final publishersData = await _apiService.searchPublishers(event.query);
      final publishers =
          publishersData
              .map((publisher) => Publisher.fromJson(publisher))
              .toList();
      emit(PublishersLoaded(publishers: publishers));
    } catch (e) {
      emit(PublishersError(message: e.toString()));
    }
  }

  Future<void> _onAddPublisher(
    AddPublisherEvent event,
    Emitter<PublishersState> emit,
  ) async {
    emit(PublishersLoading());
    try {
      debugPrint('Adding publisher: ${event.name}, ${event.city}');
      debugPrint('Token: ${event.token}');

      // تمرير التوكن بشكل صحيح
      await _apiService.addPublisher(
        {'token': event.token},
        {'pName': event.name, 'city': event.city},
      );

      debugPrint('Publisher added successfully');

      // بعد الإضافة، قم بتحميل الناشرين مرة أخرى
      add(LoadPublishersEvent());
    } catch (e) {
      debugPrint('Error adding publisher: ${e.toString()}');
      emit(PublishersError(message: e.toString()));
    }
  }

  Future<void> _onDeletePublisher(
    DeletePublisherEvent event,
    Emitter<PublishersState> emit,
  ) async {
    emit(PublishersLoading());
    try {
      await _apiService.deletePublisher({
        'token': event.token,
      }, event.publisherId);

      // بعد الحذف، قم بتحميل الناشرين مرة أخرى
      add(LoadPublishersEvent());
    } catch (e) {
      debugPrint('Error deleting publisher: ${e.toString()}');
      emit(PublishersError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePublisher(
    UpdatePublisherEvent event,
    Emitter<PublishersState> emit,
  ) async {
    emit(PublishersLoading());
    try {
      // طباعة بيانات التحديث للتشخيص
      debugPrint(
        'تحديث الناشر: ID=${event.publisherId}, الاسم=${event.name}, المدينة=${event.city}',
      );
      debugPrint('التوكن: ${event.token}');

      // تأكد من أن التوكن ليس فارغًا
      if (event.token.isEmpty) {
        throw Exception('التوكن فارغ أو غير صالح');
      }

      // تمرير التوكن بشكل صحيح
      await _apiService.updatePublisher(
        {'token': event.token},
        event.publisherId,
        {'pName': event.name, 'city': event.city},
      );

      // بعد التحديث، قم بتحميل الناشرين مرة أخرى
      add(LoadPublishersEvent());
    } catch (e) {
      debugPrint('خطأ في تحديث الناشر: ${e.toString()}');
      emit(PublishersError(message: e.toString()));
    }
  }
}
