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
  final String address; // إضافة حقل العنوان

  AddAuthorEvent({
    required this.token,
    required this.fullName,
    required this.country,
    required this.city,
    this.address = '', // قيمة افتراضية فارغة
  });
}

class DeleteAuthorEvent extends AuthorsEvent {
  final String token;
  final int authorId;

  DeleteAuthorEvent({required this.token, required this.authorId});
}

class UpdateAuthorEvent extends AuthorsEvent {
  final String token;
  final int authorId;
  final String fullName;
  final String country;
  final String city;

  UpdateAuthorEvent({
    required this.token,
    required this.authorId,
    required this.fullName,
    required this.country,
    required this.city,
  });
}
