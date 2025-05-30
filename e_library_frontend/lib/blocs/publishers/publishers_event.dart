abstract class PublishersEvent {}

class LoadPublishersEvent extends PublishersEvent {}

class SearchPublishersEvent extends PublishersEvent {
  final String query;

  SearchPublishersEvent({required this.query});
}

class AddPublisherEvent extends PublishersEvent {
  final String token;
  final String name;
  final String city;

  AddPublisherEvent({
    required this.token,
    required this.name,
    required this.city,
  });
}

class DeletePublisherEvent extends PublishersEvent {
  final String token;
  final int publisherId;

  DeletePublisherEvent({required this.token, required this.publisherId});
}

class UpdatePublisherEvent extends PublishersEvent {
  final String token;
  final int publisherId;
  final String name;
  final String city;

  UpdatePublisherEvent({
    required this.token,
    required this.publisherId,
    required this.name,
    required this.city,
  });
}
