import 'package:e_library_frontend/models/publisher.dart';

abstract class PublishersState {}

class PublishersInitial extends PublishersState {}

class PublishersLoading extends PublishersState {}

class PublishersLoaded extends PublishersState {
  final List<Publisher> publishers;

  PublishersLoaded({required this.publishers});
}

class PublishersError extends PublishersState {
  final String message;

  PublishersError({required this.message});
}