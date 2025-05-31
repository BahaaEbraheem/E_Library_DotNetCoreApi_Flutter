import 'package:e_library/blocs/auth/auth_bloc.dart';
import 'package:e_library/blocs/auth/auth_state.dart';
import 'package:e_library/blocs/authors/authors_bloc.dart';
import 'package:e_library/blocs/authors/authors_event.dart';
import 'package:e_library/blocs/authors/authors_state.dart';
import 'package:flutter/material.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/models/author.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  // تعديل الدالة لتستخدم BLoC
  Future<void> _loadAuthors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // استخدام BLoC لتحميل البيانات
      context.read<AuthorsBloc>().add(LoadAuthorsEvent());

      // الاستماع للتغييرات في BLoC
      context.read<AuthorsBloc>().stream.listen((state) {
        if (state is AuthorsLoaded) {
          setState(() {
            _authors = state.authors;
            _isLoading = false;
          });
        } else if (state is AuthorsError) {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحديث البيانات في كل مرة يتم فيها العودة إلى هذه الشاشة
    _loadAuthors();
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
      appBar: AppBar(
        title: const Text('المؤلفون'),
        centerTitle: true,
        actions: [
          // زر إضافة مؤلف جديد (للمسؤولين فقط)
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && state.isAdmin) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-author');
                  },
                  tooltip: 'إضافة مؤلف جديد',
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
          child: Column(
            children: [
              ListTile(
                title: Text(author.fullName),
                subtitle: Text('${author.country}, ${author.city}'),
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
                              '/author-details',
                              arguments: {'authorId': author.id},
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
                              // التنقل إلى صفحة تعديل المؤلف
                              Navigator.pushNamed(
                                context,
                                '/edit-author',
                                arguments: {'author': author},
                              );
                            },
                            tooltip: 'تعديل',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmation(
                                context,
                                author,
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
    Author author,
    String token,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد من حذف المؤلف "${author.fullName}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthorsBloc>().add(
                    DeleteAuthorEvent(token: token, authorId: author.id),
                  );
                },
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
