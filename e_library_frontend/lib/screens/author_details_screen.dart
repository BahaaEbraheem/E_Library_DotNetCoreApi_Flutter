import 'package:flutter/material.dart';
import 'package:e_library_frontend/models/author.dart';
import 'package:e_library_frontend/models/book.dart';
import 'package:e_library_frontend/services/api_service.dart';

class AuthorDetailsScreen extends StatefulWidget {
  const AuthorDetailsScreen({super.key});

  @override
  State<AuthorDetailsScreen> createState() => _AuthorDetailsScreenState();
}

class _AuthorDetailsScreenState extends State<AuthorDetailsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Author? _author;
  List<Book> _books = [];
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استخراج معرف المؤلف من الوسائط
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final authorId = args?['authorId'] as int?;
    
    if (authorId != null) {
      _loadAuthorDetails(authorId);
    } else {
      setState(() {
        _error = 'لم يتم تحديد المؤلف';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAuthorDetails(int authorId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authorData = await _apiService.getAuthorById(authorId);
      final booksData = await _apiService.getBooksByAuthorId(authorId);
      
      setState(() {
        _author = Author.fromJson(authorData);
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
      appBar: AppBar(
        title: const Text('تفاصيل المؤلف'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('خطأ: $_error'))
              : _author == null
                  ? const Center(child: Text('لا توجد بيانات للمؤلف'))
                  : _buildAuthorDetails(),
    );
  }

  Widget _buildAuthorDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 80, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _author!.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('البلد:', _author!.country),
          _buildInfoRow('المدينة:', _author!.city),
          const SizedBox(height: 24),
          const Text(
            'كتب المؤلف:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _books.isEmpty
              ? const Center(child: Text('لا توجد كتب لهذا المؤلف'))
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}