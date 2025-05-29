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
