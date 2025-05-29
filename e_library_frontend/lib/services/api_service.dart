import 'dart:io';
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  late String baseUrl;
  List<String>? _possibleIps;

  ApiService() {
    if (Platform.isAndroid) {
      // تعيين عنوان URL الأساسي مبدئ<|im_start|> إلى العنوان الذي نجح
      baseUrl = 'http://192.168.42.10:5298/api';

      // تخزين قائمة العناوين البديلة
      _possibleIps = [
        '192.168.42.10', // وضع العنوان الناجح أولاً
        '10.2.0.2',
        '192.168.43.230',
        '192.168.43.1',
        '192.168.42.129',
        '10.0.2.2',
      ];
    } else if (Platform.isIOS) {
      baseUrl = 'http://192.168.42.10:5298/api';
    } else {
      baseUrl = 'http://localhost:5298/api';
    }

    // إعدادات Dio
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.sendTimeout = const Duration(seconds: 15);

    // إضافة interceptor للتصحيح - تعطيل في الإنتاج
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          // تقليل حجم السجلات
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    // تعطيل التحقق من شهادة SSL
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    debugPrint('تم تهيئة ApiService مع عنوان: $baseUrl');
  }

  // Authentication methods
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {'username': username, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
        );
      } else if (e.type == DioExceptionType.badCertificate) {
        throw Exception(
          'مشكلة في شهادة الأمان. يرجى التحقق من إعدادات الاتصال.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'خطأ في الاتصال. تأكد من تشغيل الخادم ومن اتصالك بالإنترنت. تحقق من عنوان IP وإعدادات الشبكة.',
        );
      }
      debugPrint('خطأ في تسجيل الدخول: $e');
      throw Exception('فشل تسجيل الدخول: ${e.toString()}');
    } catch (e) {
      debugPrint('خطأ في تسجيل الدخول: $e');
      throw Exception('فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/register',
        data: {
          'username': username,
          'password': password,
          'fName': firstName,
          'lName': lastName,
          'isAdmin': false,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('Register error: $e');
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  // Books
  Future<List<dynamic>> getAllBooks() async {
    try {
      final response = await _dio.get('$baseUrl/books');
      return response.data;
    } catch (e) {
      debugPrint('Get all books error: $e');
      throw Exception('Failed to load books: ${e.toString()}');
    }
  }

  Future<List<dynamic>> searchBooks(String query) async {
    try {
      final response = await _dio.get(
        '$baseUrl/books/search',
        queryParameters: {'title': query},
      );
      return response.data;
    } catch (e) {
      debugPrint('Search books error: $e');
      throw Exception('Failed to search books: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> addBook(
    Map<String, dynamic> bookData,
    Map<String, Object> map,
  ) async {
    try {
      final response = await _dio.post('$baseUrl/books', data: bookData);
      return response.data;
    } catch (e) {
      debugPrint('Add book error: $e');
      throw Exception('Failed to add book: ${e.toString()}');
    }
  }

  // Books by ID
  Future<Map<String, dynamic>> getBookById(int bookId) async {
    try {
      final response = await _dio.get('$baseUrl/books/$bookId');
      return response.data;
    } catch (e) {
      debugPrint('Get book by ID error: $e');
      throw Exception('Failed to load book details: ${e.toString()}');
    }
  }

  // Books by Author ID
  Future<List<dynamic>> getBooksByAuthorId(int authorId) async {
    try {
      final response = await _dio.get('$baseUrl/books/author/$authorId');
      return response.data;
    } catch (e) {
      debugPrint('Get books by author ID error: $e');
      throw Exception('Failed to load author books: ${e.toString()}');
    }
  }

  // Books by Publisher ID
  Future<List<dynamic>> getBooksByPublisherId(int publisherId) async {
    try {
      final response = await _dio.get('$baseUrl/books/publisher/$publisherId');
      return response.data;
    } catch (e) {
      debugPrint('Get books by publisher ID error: $e');
      throw Exception('Failed to load publisher books: ${e.toString()}');
    }
  }

  // Authors
  Future<List<dynamic>> getAllAuthors() async {
    try {
      final response = await _dio.get('$baseUrl/authors');
      return response.data;
    } catch (e) {
      debugPrint('Get all authors error: $e');
      throw Exception('Failed to load authors: ${e.toString()}');
    }
  }

  Future<List<dynamic>> searchAuthors(String query) async {
    try {
      final response = await _dio.get(
        '$baseUrl/authors/search',
        queryParameters: {'name': query},
      );
      return response.data;
    } catch (e) {
      debugPrint('Search authors error: $e');
      throw Exception('Failed to search authors: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> addAuthor(
    Map<String, dynamic> authorData,
    Map<String, String> map,
  ) async {
    try {
      final response = await _dio.post('$baseUrl/authors', data: authorData);
      return response.data;
    } catch (e) {
      debugPrint('Add author error: $e');
      throw Exception('Failed to add author: ${e.toString()}');
    }
  }

  // Author by ID
  Future<Map<String, dynamic>> getAuthorById(int authorId) async {
    try {
      final response = await _dio.get('$baseUrl/authors/$authorId');
      return response.data;
    } catch (e) {
      debugPrint('Get author by ID error: $e');
      throw Exception('Failed to load author details: ${e.toString()}');
    }
  }

  // Publishers
  Future<List<dynamic>> getAllPublishers() async {
    try {
      final response = await _dio.get('$baseUrl/publishers');
      return response.data;
    } catch (e) {
      debugPrint('Get all publishers error: $e');
      throw Exception('Failed to load publishers: ${e.toString()}');
    }
  }

  Future<List<dynamic>> searchPublishers(String query) async {
    try {
      final response = await _dio.get(
        '$baseUrl/publishers/search',
        queryParameters: {'name': query},
      );
      return response.data;
    } catch (e) {
      debugPrint('Search publishers error: $e');
      throw Exception('Failed to search publishers: ${e.toString()}');
    }
  }

  // Add Publisher
  Future<void> addPublisher(
    Map<String, dynamic> tokenMap,
    Map<String, dynamic> publisherData,
  ) async {
    try {
      final String token = tokenMap['token'];

      // تأكد من إعداد رؤوس التفويض بشكل صحيح
      final options = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // طباعة البيانات المرسلة للتشخيص
      debugPrint('إرسال طلب إلى $baseUrl/publishers');
      debugPrint('الرؤوس: ${options.headers}');
      debugPrint('البيانات: $publisherData');

      // التأكد من أن أسماء الحقول تتطابق مع الباك إند
      final Map<String, dynamic> formattedData = {
        'pName': publisherData['pName'],
        'city': publisherData['city'],
      };

      // إرسال الطلب
      final response = await _dio.post(
        '$baseUrl/publishers',
        data: formattedData,
        options: options,
      );

      debugPrint('تمت إضافة الناشر بنجاح');
    } catch (e) {
      debugPrint('خطأ في إضافة الناشر: $e');
      if (e is DioException) {
        debugPrint('رمز الحالة: ${e.response?.statusCode}');
        debugPrint('بيانات الاستجابة: ${e.response?.data}');
      }
      throw Exception('فشل إضافة الناشر: ${e.toString()}');
    }
  }

  // Publisher by ID
  Future<Map<String, dynamic>> getPublisherById(int publisherId) async {
    try {
      final response = await _dio.get('$baseUrl/publishers/$publisherId');
      return response.data;
    } catch (e) {
      debugPrint('Get publisher by ID error: $e');
      throw Exception('Failed to load publisher details: ${e.toString()}');
    }
  }

  // التحقق من الاتصال بالخادم
  Future<bool> isServerReachable() async {
    if (Platform.isAndroid && _possibleIps != null) {
      for (String ip in _possibleIps!) {
        if (ip.isEmpty) continue;

        String testUrl = 'http://$ip:5298/api/ping';
        debugPrint('جاري تجربة الاتصال على: $testUrl');

        try {
          final response = await _dio.get(
            testUrl,
            options: Options(
              receiveTimeout: const Duration(seconds: 3),
              sendTimeout: const Duration(seconds: 3),
            ),
          );

          if (response.statusCode == 200) {
            debugPrint('نجح الاتصال على: $testUrl');

            // إذا نجح الاتصال، قم بتحديث عنوان URL الأساسي
            baseUrl = 'http://$ip:5298/api';
            return true;
          }
        } catch (e) {
          // تقليل حجم السجلات
          debugPrint('فشل الاتصال على $ip');
        }
      }

      debugPrint('فشلت جميع محاولات الاتصال');
      return false;
    } else {
      try {
        final response = await _dio.get(
          '$baseUrl/ping',
          options: Options(
            receiveTimeout: const Duration(seconds: 5),
            sendTimeout: const Duration(seconds: 5),
          ),
        );

        return response.statusCode == 200;
      } catch (e) {
        debugPrint('خطأ في الاتصال بالخادم');
        return false;
      }
    }
  }
}
