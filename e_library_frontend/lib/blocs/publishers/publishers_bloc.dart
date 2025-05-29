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
}
