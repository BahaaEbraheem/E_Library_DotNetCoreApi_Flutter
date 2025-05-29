import 'package:flutter/material.dart';
import 'package:e_library_frontend/services/api_service.dart';
import 'package:e_library_frontend/models/book.dart';

class SearchBooksScreen extends StatefulWidget {
  const SearchBooksScreen({super.key});

  @override
  State<SearchBooksScreen> createState() => _SearchBooksScreenState();
}

class _SearchBooksScreenState extends State<SearchBooksScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Book> _books = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        _books = [];
        _hasSearched = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final booksData = await _apiService.searchBooks(query);
      setState(() {
        _books = booksData.map((data) => Book.fromJson(data)).toList();
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
        title: const Text('البحث عن كتاب'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'ابحث عن كتاب',
                hintText: 'أدخل جزءًا من عنوان الكتاب',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _books = [];
                      _hasSearched = false;
                      _error = null;
                    });
                  },
                ),
              ),
              onSubmitted: (value) {
                _searchBooks(value);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('خطأ: $_error'))
                    : !_hasSearched
                        ? const Center(
                            child: Text('أدخل جزءًا من عنوان الكتاب للبحث'),
                          )
                        : _books.isEmpty
                            ? const Center(
                                child: Text('لا توجد كتب تطابق البحث'),
                              )
                            : _buildBooksList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList() {
    return ListView.builder(
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(book.title),
            subtitle: Text('${book.type} - ${book.price} \$'),
            trailing: Text(book.authorName ?? 'غير معروف'),
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
    );
  }
}