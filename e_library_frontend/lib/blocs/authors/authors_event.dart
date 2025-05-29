abstract class AuthorsEvent {}

class LoadAuthorsEvent extends AuthorsEvent {}

class SearchAuthorsEvent extends AuthorsEvent {
  final String query;

  SearchAuthorsEvent({required this.query});
}

class AddAuthorEvent extends AuthorsEvent {
  final String token;
  final String fullName;
  final String country;
  final String city;

  AddAuthorEvent({
    required this.token,
    required this.fullName,
    required this.country,
    required this.city,
  });
}