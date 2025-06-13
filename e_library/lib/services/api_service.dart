import 'dart:convert';
import 'dart:io';
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final Dio _dio = Dio();
  late String baseUrl;
  List<String>? _possibleIps;

  ApiService() {
    if (Platform.isAndroid) {
<<<<<<< HEAD
      // تخزين قائمة العناوين البديلة
      _possibleIps = [
        '10.0.2.2', // عنوان خاص بمحاكي الأندرويد (يشير إلى localhost على الكمبيوتر المضيف)
        '192.168.42.10',
        '10.2.0.2',
        '192.168.43.230',
        '192.168.43.1',
        '192.168.42.129',
      ];

      // تعيين عنوان URL الأساسي مبدئ<|im_start|> إلى عنوان المحاكي
      baseUrl = 'http://10.0.2.2:5298/api';
    } else if (Platform.isIOS) {
      baseUrl = 'http://localhost:5298/api'; // للمحاكي iOS استخدم localhost
    } else {
      baseUrl = 'http://localhost:5298/api';
=======
      baseUrl = 'http://elibrary2025.somee.com/api';
>>>>>>> d569d34 (commit)
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
    Map<String, dynamic> tokenMap,
    Map<String, dynamic> bookData,
  ) async {
    try {
      final String token = tokenMap['token'];

      // Make sure token is properly formatted
      final options = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Format data to match backend expectations
      final Map<String, dynamic> formattedData = {
        'Title': bookData['title'],
        'Type': bookData['type'],
        'Price': bookData['price'],
        'PublisherId': bookData['publisherId'],
        'AuthorId': bookData['authorId'],
      };
      debugPrint('Sending formatted data: $formattedData');
      // Send request
      final response = await _dio.post(
        '$baseUrl/books',
        data: formattedData,
        options: options,
      );

      return response.data;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        debugPrint('Authorization error: 403 Forbidden');
        throw Exception('Access denied. Please check your permissions.');
      }
      // Other error handling...
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

  Future<dynamic> addAuthor(
    Map<String, dynamic> headers,
    Map<String, dynamic> authorData,
  ) async {
    try {
      // طباعة الهيدرز والبيانات للتشخيص
      debugPrint('إضافة مؤلف - الهيدرز: $headers');
      debugPrint('إضافة مؤلف - البيانات: $authorData');

      // تأكد من إرسال التوكن في الهيدر بالشكل الصحيح
      final Map<String, dynamic> requestHeaders = {};

      if (headers.containsKey('Authorization')) {
        requestHeaders['Authorization'] = headers['Authorization'];
      }

      debugPrint('الهيدرز النهائية: $requestHeaders');
      debugPrint('authorData:  $authorData');
      debugPrint('baseUrl : $baseUrl');

      final response = await _dio.post(
        '$baseUrl/authors', // استخدام baseUrl بدلاً من _baseUrl
        data: authorData,
        options: Options(headers: requestHeaders),
      );

      debugPrint(
        'استجابة إضافة المؤلف: ${response.statusCode} - ${response.data}',
      );
      return response.data;
    } catch (e) {
      debugPrint('خطأ Dio: ${e.runtimeType}');
      if (e is DioException) {
        debugPrint('رسالة الخطأ: ${e.message}');
        debugPrint('استجابة الخطأ:');
        debugPrint('كود الاستجابة: ${e.response?.statusCode}');
        debugPrint('بيانات الاستجابة: ${e.response?.data}');
      }
      throw Exception('فشل إضافة المؤلف: $e');
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
      await _dio.post(
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

  // التحقق من الاتصال بالخادم مع محاولات متعددة
  Future<bool> isServerReachable() async {
    // التحقق أولاً مما إذا كان التطبيق يعمل على محاكي
    if (await _isEmulator()) {
<<<<<<< HEAD
      baseUrl = 'http://10.0.2.2:5298/api';
=======
      baseUrl = 'http://elibrary2025.somee.com/api';
>>>>>>> d569d34 (commit)
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
        debugPrint('فشل الاتصال بالخادم على عنوان المحاكي');
        return false;
      }
    }

    // إذا لم يكن محاكي، استمر بالطريقة العادية
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

  Future<void> deleteAuthor(Map<String, dynamic> token, int authorId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/authors/$authorId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token['token']}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('فشل حذف المؤلف: ${response.body}');
    }
  }

  Future<void> deletePublisher(
    Map<String, dynamic> token,
    int publisherId,
  ) async {
    try {
      final String tokenStr = token['token'];

      // تأكد من إعداد رؤوس التفويض بشكل صحيح
      final options = Options(
        headers: {
          'Authorization': 'Bearer $tokenStr',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
        'محاولة حذف الناشر باستخدام: $baseUrl/publishers/$publisherId',
      );

      // استخدام Dio بدلاً من http
      await _dio.delete('$baseUrl/publishers/$publisherId', options: options);

      debugPrint('تم حذف الناشر بنجاح');
    } catch (e) {
      debugPrint('خطأ في حذف الناشر: $e');
      if (e is DioException) {
        debugPrint('رمز الحالة: ${e.response?.statusCode}');
        debugPrint('بيانات الاستجابة: ${e.response?.data}');
      }
      throw Exception('فشل حذف الناشر: ${e.toString()}');
    }
  }

  Future<void> deleteBook(Map<String, dynamic> token, int bookId) async {
    try {
      final String tokenStr = token['token'];

      // تأكد من إعداد رؤوس التفويض بشكل صحيح
      final options = Options(
        headers: {
          'Authorization': 'Bearer $tokenStr',
          'Content-Type': 'application/json',
        },
      );

      // إرسال الطلب
      await _dio.delete('$baseUrl/books/$bookId', options: options);

      debugPrint('تم حذف الكتاب بنجاح');
    } catch (e) {
      debugPrint('خطأ في حذف الكتاب: $e');
      if (e is DioException) {
        debugPrint('رمز الحالة: ${e.response?.statusCode}');
        debugPrint('بيانات الاستجابة: ${e.response?.data}');
      }
      throw Exception('فشل حذف الكتاب: ${e.toString()}');
    }
  }

  Future<void> updateBook(
    Map<String, dynamic> token,
    int bookId,
    Map<String, dynamic> bookData,
  ) async {
    try {
      // Fix the URL path - remove the duplicate 'api'
      final url = Uri.parse('$baseUrl/books/$bookId');

      // Format data to match backend expectations
      final Map<String, dynamic> formattedData = {
        'title': bookData['title'],
        'type': bookData['type'],
        'price': bookData['price'],
        'publisherId': bookData['publisherId'],
        'authorId': bookData['authorId'],
      };

      debugPrint('Updating book ID: $bookId');
      debugPrint('Update data: $formattedData');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
        body: jsonEncode(formattedData),
      );

      if (response.statusCode != 200) {
        debugPrint('Update failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('فشل تحديث الكتاب: ${response.body}');
      }

      debugPrint('Book updated successfully');
    } catch (e) {
      debugPrint('Error updating book: $e');
      throw Exception('فشل تحديث الكتاب: $e');
    }
  }

  Future<void> updateAuthor(
    Map<String, dynamic> tokenMap,
    int authorId,
    Map<String, dynamic> authorData,
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

      // تحويل البيانات لتتطابق مع ما يتوقعه الخادم
      final Map<String, dynamic> formattedData = {};

      // تقسيم الاسم الكامل إلى اسم أول واسم أخير
      final nameParts = authorData['fullName']?.split(' ') ?? [];
      formattedData['fName'] = nameParts.isNotEmpty ? nameParts.first : '';
      formattedData['lName'] =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      formattedData['country'] = authorData['country'] ?? '';
      formattedData['city'] = authorData['city'] ?? '';

      // طباعة البيانات المرسلة للتشخيص
      debugPrint('إرسال طلب تحديث إلى $baseUrl/authors/$authorId');
      debugPrint('الرؤوس: ${options.headers}');
      debugPrint('البيانات: $formattedData');

      // إرسال الطلب
      await _dio.put(
        '$baseUrl/authors/$authorId',
        data: formattedData,
        options: options,
      );
    } catch (e) {
      debugPrint('Update author error: $e');
      throw Exception('Failed to update author: ${e.toString()}');
    }
  }

  Future<void> updatePublisher(
    Map<String, dynamic> token,
    int publisherId,
    Map<String, dynamic> publisherData,
  ) async {
    try {
      final String tokenStr = token['token'];
      debugPrint('التوكن المستخدم: $tokenStr');

      // تجربة طريقة مختلفة للتحديث
      // 1. أولاً، دعنا نحاول الحصول على الناشر الحالي للتأكد من أن الاتصال يعمل
      final currentPublisher = await getPublisherById(publisherId);
      debugPrint(
        'تم الحصول على الناشر الحالي: ${currentPublisher['pName']}, ${currentPublisher['city']}',
      );

      // 2. إعداد البيانات بشكل مختلف - إضافة معرف الناشر في البيانات
      final Map<String, dynamic> completeData = {
        'id': publisherId,
        'pName': publisherData['pName'],
        'city': publisherData['city'],
        // إضافة حقل books فارغ لتجنب أي مشاكل
        'books': null,
      };

      // 3. استخدام طريقة مختلفة للإرسال
      final url = Uri.parse('$baseUrl/publishers/$publisherId');
      final jsonBody = jsonEncode(completeData);

      debugPrint('إرسال طلب تحديث إلى $url');
      debugPrint('البيانات الكاملة: $jsonBody');

      // تجربة طريقة مختلفة لإرسال الهيدرز
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenStr',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );

      debugPrint('استجابة HTTP: ${response.statusCode}');
      debugPrint('محتوى الاستجابة: ${response.body}');

      if (response.statusCode != 200) {
        // تجربة طريقة أخرى - استخدام PATCH بدلاً من PUT
        final patchResponse = await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $tokenStr',
            'Accept': 'application/json',
          },
          body: jsonBody,
        );

        debugPrint('استجابة PATCH: ${patchResponse.statusCode}');
        debugPrint('محتوى استجابة PATCH: ${patchResponse.body}');

        if (patchResponse.statusCode != 200) {
          throw Exception(
            'فشل تحديث الناشر: ${response.statusCode} - ${response.body}',
          );
        }
      }

      debugPrint('تم تحديث الناشر بنجاح');
    } catch (e) {
      debugPrint('خطأ في تحديث الناشر: $e');
      throw Exception('فشل تحديث الناشر: ${e.toString()}');
    }
  }

  // التحقق مما إذا كان التطبيق يعمل على محاكي
  Future<bool> _isEmulator() async {
    if (Platform.isAndroid) {
      try {
        // محاولة الاتصال بعنوان المحاكي الافتراضي
        final response = await _dio.get(
<<<<<<< HEAD
          'http://10.0.2.2:5298/api/ping',
=======
          'http://elibrary2025.somee.com/api/ping',
>>>>>>> d569d34 (commit)
          options: Options(
            receiveTimeout: const Duration(seconds: 3),
            sendTimeout: const Duration(seconds: 3),
          ),
        );

        if (response.statusCode == 200) {
          debugPrint('تم اكتشاف أن التطبيق يعمل على محاكي');
          return true;
        }
      } catch (e) {
        // تجاهل الخطأ
      }
    }
    return false;
  }
}
