import 'package:flutter/material.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/models/author.dart';

class SearchAuthorsScreen extends StatefulWidget {
  const SearchAuthorsScreen({super.key});

  @override
  State<SearchAuthorsScreen> createState() => _SearchAuthorsScreenState();
}

class _SearchAuthorsScreenState extends State<SearchAuthorsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Author> _authors = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchAuthors(String query) async {
    if (query.isEmpty) {
      setState(() {
        _authors = [];
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
      final authorsData = await _apiService.searchAuthors(query);
      setState(() {
        _authors = authorsData.map((data) => Author.fromJson(data)).toList();
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
      appBar: AppBar(title: const Text('البحث عن مؤلف'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'ابحث عن مؤلف',
                hintText: 'أدخل جزءًا من اسم المؤلف',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _authors = [];
                      _hasSearched = false;
                      _error = null;
                    });
                  },
                ),
              ),
              onSubmitted: (value) {
                _searchAuthors(value);
              },
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text('خطأ: $_error'))
                    : !_hasSearched
                    ? const Center(
                      child: Text('أدخل جزءًا من اسم المؤلف للبحث'),
                    )
                    : _authors.isEmpty
                    ? const Center(child: Text('لا يوجد مؤلفون يطابقون البحث'))
                    : _buildAuthorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorsList() {
    return ListView.builder(
      itemCount: _authors.length,
      itemBuilder: (context, index) {
        final author = _authors[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(author.fullName),
            subtitle: Text('${author.country}, ${author.city}'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/author-details',
                arguments: {'authorId': author.id},
              );
            },
          ),
        );
      },
    );
  }
}
