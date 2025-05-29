import 'package:flutter/material.dart';
import 'package:e_library_frontend/services/api_service.dart';
import 'package:e_library_frontend/models/publisher.dart';

class SearchPublishersScreen extends StatefulWidget {
  const SearchPublishersScreen({super.key});

  @override
  State<SearchPublishersScreen> createState() => _SearchPublishersScreenState();
}

class _SearchPublishersScreenState extends State<SearchPublishersScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Publisher> _publishers = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPublishers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _publishers = [];
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
      final publishersData = await _apiService.searchPublishers(query);
      setState(() {
        _publishers = publishersData.map((data) => Publisher.fromJson(data)).toList();
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
        title: const Text('البحث عن ناشر'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'ابحث عن ناشر',
                hintText: 'أدخل جزءًا من اسم الناشر',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _publishers = [];
                      _hasSearched = false;
                      _error = null;
                    });
                  },
                ),
              ),
              onSubmitted: (value) {
                _searchPublishers(value);
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
                            child: Text('أدخل جزءًا من اسم الناشر للبحث'),
                          )
                        : _publishers.isEmpty
                            ? const Center(
                                child: Text('لا يوجد ناشرون يطابقون البحث'),
                              )
                            : _buildPublishersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishersList() {
    return ListView.builder(
      itemCount: _publishers.length,
      itemBuilder: (context, index) {
        final publisher = _publishers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(publisher.name),
            subtitle: Text(publisher.city),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/publisher-details',
                arguments: {'publisherId': publisher.id},
              );
            },
          ),
        );
      },
    );
  }
}