import 'package:flutter/material.dart';

class Author {
  final int id;
  final String fullName;
  final String country;
  final String city;
  final String? address;

  Author({
    required this.id,
    required this.fullName,
    required this.country,
    required this.city,
    this.address,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    // طباعة البيانات المستلمة للتشخيص
    debugPrint('بيانات المؤلف من JSON: ${json.toString()}');

    // تجميع الاسم الكامل من fName و lName
    final firstName = json['fName'] ?? '';
    final lastName = json['lName'] ?? '';
    final fullName = '$firstName $lastName'.trim();

    return Author(
      id: json['id'],
      fullName: fullName,
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    // تقسيم الاسم الكامل إلى اسم أول واسم أخير
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return {
      'id': id,
      'fName': firstName,
      'lName': lastName,
      'country': country,
      'city': city,
      'address': address,
    };
  }
}
