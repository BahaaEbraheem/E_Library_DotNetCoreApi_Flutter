import 'package:flutter/material.dart';
import 'package:e_library_frontend/services/api_service.dart';
import 'package:e_library_frontend/models/publisher.dart';

class PublishersScreen extends StatefulWidget {
  const PublishersScreen({super.key});

  @override
  State<PublishersScreen> createState() => _PublishersScreenState();
}

class _PublishersScreenState extends State<PublishersScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Publisher> _publishers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPublishers();
  }

  Future<void> _loadPublishers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final publishersData = await _apiService.getAllPublishers();
      setState(() {
        _publishers =
            publishersData.map((data) => Publisher.fromJson(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchPublishers(String query) async {
    if (query.isEmpty) {
      _loadPublishers();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final publishersData = await _apiService.searchPublishers(query);
      setState(() {
        _publishers =
            publishersData.map((data) => Publisher.fromJson(data)).toList();
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
      appBar: AppBar(title: const Text('الناشرون'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'البحث عن ناشر',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadPublishers();
                  },
                ),
              ),
              onSubmitted: (value) {
                _searchPublishers(value);
              },
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text('خطأ: $_error'))
                    : _buildPublishersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishersList() {
    if (_publishers.isEmpty) {
      return const Center(child: Text('لا يوجد ناشرون'));
    }

    return ListView.builder(
      itemCount: _publishers.length,
      itemBuilder: (context, index) {
        final publisher = _publishers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(publisher.name),
            subtitle: Text(publisher.city),
          ),
        );
      },
    );
  }
}
