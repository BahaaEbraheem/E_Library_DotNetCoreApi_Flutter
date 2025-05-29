class Book {
  final int id;
  final String title;
  final String type;
  final double price;
  final int publisherId;
  final int authorId;
  final String? authorName;
  final String? publisherName;

  Book({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.publisherId,
    required this.authorId,
    this.authorName,
    this.publisherName,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      price: json['price'].toDouble(),
      publisherId: json['publisherId'],
      authorId: json['authorId'],
      authorName: json['author']?['fName'] != null && json['author']?['lName'] != null
          ? "${json['author']['fName']} ${json['author']['lName']}"
          : null,
      publisherName: json['publisher']?['pName'],
    );
  }
}