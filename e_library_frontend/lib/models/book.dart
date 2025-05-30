import 'package:flutter/material.dart';

class Book {
  final int id;
  final String title;
  final String type;
  final double price;
  final int? authorId;
  final int? publisherId;
  final String? authorName;
  final String? publisherName;

  Book({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    this.authorId,
    this.publisherId,
    this.authorName,
    this.publisherName,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // إضافة سجل للتشخيص
    debugPrint('استلام بيانات الكتاب من API: $json');

    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      authorId: json['authorId'],
      publisherId: json['publisherId'],
      authorName: json['authorName'],
      publisherName: json['publisherName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'price': price,
      'authorId': authorId,
      'publisherId': publisherId,
      'authorName': authorName,
      'publisherName': publisherName,
    };
  }
}
