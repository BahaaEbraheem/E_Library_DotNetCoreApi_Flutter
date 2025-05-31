import 'package:flutter/material.dart';
import 'package:e_library/models/publisher.dart';
import 'package:e_library/models/book.dart';
import 'package:e_library/services/api_service.dart';

class PublisherDetailsScreen extends StatefulWidget {
  const PublisherDetailsScreen({super.key});

  @override
  State<PublisherDetailsScreen> createState() => _PublisherDetailsScreenState();
}

class _PublisherDetailsScreenState extends State<PublisherDetailsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Publisher? _publisher;
  List<Book> _books = [];
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استخراج معرف الناشر من الوسائط
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final publisherId = args?['publisherId'] as int?;

    if (publisherId != null) {
      _loadPublisherDetails(publisherId);
    } else {
      setState(() {
        _error = 'لم يتم تحديد الناشر';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPublisherDetails(int publisherId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final publisherData = await _apiService.getPublisherById(publisherId);
      final booksData = await _apiService.getBooksByPublisherId(publisherId);

      setState(() {
        _publisher = Publisher.fromJson(publisherData);
        _books = booksData.map((book) => Book.fromJson(book)).toList();
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
      appBar: AppBar(title: const Text('تفاصيل الناشر'), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('خطأ: $_error'))
              : _publisher == null
              ? const Center(child: Text('لا توجد بيانات للناشر'))
              : _buildPublisherDetails(),
    );
  }

  Widget _buildPublisherDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business, size: 80, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _publisher!.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('المدينة:', _publisher!.city),
          const SizedBox(height: 24),
          const Text(
            'كتب الناشر:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _books.isEmpty
              ? const Center(child: Text('لا توجد كتب لهذا الناشر'))
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(book.title),
                      subtitle: Text('${book.type} - ${book.price} \$'),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/book-details',
                          arguments: {'bookId': book.id},
                        );
                      },
                    ),
                  );
                },
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
