abstract class BooksEvent {}

class LoadBooksEvent extends BooksEvent {}

class SearchBooksEvent extends BooksEvent {
  final String query;

  SearchBooksEvent({required this.query});
}

class AddBookEvent extends BooksEvent {
  final String token;
  final String title;
  final String type;
  final double price;
  final int publisherId;
  final int authorId;

  AddBookEvent({
    required this.token,
    required this.title,
    required this.type,
    required this.price,
    required this.publisherId,
    required this.authorId,
  });
}