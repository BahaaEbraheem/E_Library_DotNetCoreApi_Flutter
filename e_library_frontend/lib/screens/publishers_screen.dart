import 'package:e_library_frontend/blocs/auth/auth_bloc.dart';
import 'package:e_library_frontend/blocs/auth/auth_state.dart';
import 'package:e_library_frontend/blocs/publishers/publishers_bloc.dart';
import 'package:e_library_frontend/blocs/publishers/publishers_event.dart';
import 'package:e_library_frontend/blocs/publishers/publishers_state.dart';
import 'package:flutter/material.dart';
import 'package:e_library_frontend/services/api_service.dart';
import 'package:e_library_frontend/models/publisher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  // تعديل الدالة لتستخدم BLoC بدلاً من ApiService مباشرة
  Future<void> _loadPublishers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // استخدام BLoC لتحميل البيانات
      context.read<PublishersBloc>().add(LoadPublishersEvent());

      // الاستماع للتغييرات في BLoC
      context.read<PublishersBloc>().stream.listen((state) {
        if (state is PublishersLoaded) {
          setState(() {
            _publishers = state.publishers;
            _isLoading = false;
          });
        } else if (state is PublishersError) {
          setState(() {
            _error = state.message;
            _isLoading = false;
          });
        }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحديث البيانات في كل مرة يتم فيها العودة إلى هذه الشاشة
    _loadPublishers();
  }

  void _addPublisher() async {
    final result = await Navigator.pushNamed(context, '/add-publisher');
    if (result == true) {
      // تم إضافة ناشر جديد، قم بتحديث القائمة
      _loadPublishers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الناشرون'),
        centerTitle: true,
        actions: [
          // زر إضافة ناشر جديد (للمسؤولين فقط)
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && state.isAdmin) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addPublisher, // استخدام الدالة هنا
                  tooltip: 'إضافة ناشر جديد',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
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
          child: Column(
            children: [
              ListTile(
                title: Text(publisher.name),
                subtitle: Text(publisher.city),
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // زر عرض التفاصيل (متاح للجميع)
                        IconButton(
                          icon: const Icon(
                            Icons.visibility,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/publisher-details',
                              arguments: {'publisherId': publisher.id},
                            );
                          },
                          tooltip: 'عرض التفاصيل',
                        ),
                        // أزرار التعديل والحذف (للمسؤولين فقط)
                        if (authState is AuthAuthenticated &&
                            authState.isAdmin) ...[
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              // التنقل إلى صفحة تعديل الناشر
                              Navigator.pushNamed(
                                context,
                                '/edit-publisher',
                                arguments: {'publisher': publisher},
                              );
                            },
                            tooltip: 'تعديل',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmation(
                                context,
                                publisher,
                                authState.token,
                              );
                            },
                            tooltip: 'حذف',
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة لعرض تأكيد الحذف
  void _showDeleteConfirmation(
    BuildContext context,
    Publisher publisher,
    String token,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد من حذف الناشر "${publisher.name}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<PublishersBloc>().add(
                    DeletePublisherEvent(
                      token: token,
                      publisherId: publisher.id,
                    ),
                  );
                },
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
