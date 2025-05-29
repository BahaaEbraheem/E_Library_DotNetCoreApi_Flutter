import 'package:flutter/material.dart';
import 'package:e_library_frontend/services/api_service.dart';
import 'package:e_library_frontend/models/author.dart';

class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Author> _authors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAuthors();
  }

  Future<void> _loadAuthors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authorsData = await _apiService.getAllAuthors();
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

  Future<void> _searchAuthors(String query) async {
    if (query.isEmpty) {
      _loadAuthors();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المؤلفون'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'البحث عن مؤلف',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadAuthors();
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
                    : _buildAuthorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorsList() {
    if (_authors.isEmpty) {
      return const Center(child: Text('لا يوجد مؤلفون'));
    }

    return ListView.builder(
      itemCount: _authors.length,
      itemBuilder: (context, index) {
        final author = _authors[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(author.fullName),
            subtitle: Text('${author.country}, ${author.city}'),
          ),
        );
      },
    );
  }
}
