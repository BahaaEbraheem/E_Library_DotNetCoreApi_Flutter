import 'package:flutter/material.dart';

class Publisher {
  final int id;
  final String name;
  final String city;

  Publisher({required this.id, required this.name, required this.city});

  factory Publisher.fromJson(Map<String, dynamic> json) {
    // أضف هذا السطر للتأكد من طباعة البيانات المستلمة
    debugPrint(
      'بيانات الناشر من JSON: ${json['id']}, ${json['pName']}, ${json['city']}',
    );

    return Publisher(
      id: json['id'],
      name: json['pName'] ?? '',
      city: json['city'] ?? '',
    );
  }
}
