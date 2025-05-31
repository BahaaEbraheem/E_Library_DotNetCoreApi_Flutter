import 'package:flutter/material.dart';
import 'package:e_library/models/book.dart';
import 'package:e_library/services/api_service.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Book? _book;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استخراج معرف الكتاب من الوسائط
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bookId = args?['bookId'] as int?;

    if (bookId != null) {
      _loadBookDetails(bookId);
    } else {
      setState(() {
        _error = 'لم يتم تحديد الكتاب';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBookDetails(int bookId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookData = await _apiService.getBookById(bookId);
      setState(() {
        _book = Book.fromJson(bookData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الكتاب'), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('خطأ: $_error'))
              : _book == null
              ? const Center(child: Text('لا توجد بيانات للكتاب'))
              : _buildBookDetails(),
    );
  }

  Widget _buildBookDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // إضافة سجل للتشخيص
          Text(
            'بيانات الكتاب الكاملة: ${_book?.toJson()}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            _book?.title ?? 'عنوان غير معروف',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('النوع:', _book!.type),
          _buildInfoRow('السعر:', '${_book!.price} \$'),
          _buildInfoRow('المؤلف:', _book!.authorName ?? 'غير معروف'),
          _buildInfoRow('الناشر:', _book!.publisherName ?? 'غير معروف'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/author-details',
                arguments: {'authorId': _book!.authorId},
              );
            },
            child: const Text('عرض تفاصيل المؤلف'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/publisher-details',
                arguments: {'publisherId': _book!.publisherId},
              );
            },
            child: const Text('عرض تفاصيل الناشر'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
