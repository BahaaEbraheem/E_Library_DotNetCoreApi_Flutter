import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library_frontend/blocs/books/books_bloc.dart';
import 'package:e_library_frontend/blocs/books/books_event.dart';
import 'package:e_library_frontend/blocs/books/books_state.dart';
import 'package:e_library_frontend/models/book.dart';
import 'package:e_library_frontend/blocs/auth/auth_bloc.dart';
import 'package:e_library_frontend/blocs/auth/auth_state.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  late BooksBloc _booksBloc;

  @override
  void initState() {
    super.initState();
    _booksBloc = context.read<BooksBloc>();
    _loadBooks();
  }

  // تعديل الدالة لتستخدم BLoC
  Future<void> _loadBooks() async {
    // استخدام BLoC لتحميل البيانات
    // Check if bloc is closed before adding event
    if (!_booksBloc.isClosed) {
      context.read<BooksBloc>().add(LoadBooksEvent());
    } else {
      // If bloc is closed, get a new instance
      _booksBloc = context.read<BooksBloc>();
      _booksBloc.add(LoadBooksEvent());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحديث البيانات في كل مرة يتم فيها العودة إلى هذه الشاشة
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Don't close the bloc here as it's provided by a parent widget
    // and might be needed elsewhere
    // _booksBloc.close(); // Remove this line
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الكتب'),
        centerTitle: true,
        actions: [
          // زر إضافة كتاب جديد (للمسؤولين فقط)
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && state.isAdmin) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-book');
                  },
                  tooltip: 'إضافة كتاب جديد',
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
                labelText: 'البحث عن كتاب',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadBooks();
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<BooksBloc>().add(SearchBooksEvent(query: value));
                } else {
                  _loadBooks();
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<BooksBloc, BooksState>(
              builder: (context, state) {
                if (state is BooksLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BooksError) {
                  return Center(child: Text('خطأ: ${state.message}'));
                } else if (state is BooksLoaded) {
                  return state.books.isEmpty
                      ? const Center(child: Text('لا توجد كتب'))
                      : _buildBooksList(state.books);
                }
                return const Center(child: Text('قم بتحميل الكتب'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList(List<Book> books) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  book.title.isNotEmpty ? book.title : 'عنوان غير معروف',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${book.type} - ${book.price} \$'),
                    // إضافة سجل للتشخيص
                    Text(
                      'المؤلف: ${book.authorName ?? 'غير معروف'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                // إضافة سجل للتشخيص
                onTap: () {
                  debugPrint('بيانات الكتاب: ${book.toJson()}');
                },
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
                              '/book-details',
                              arguments: {'bookId': book.id},
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
                              // التنقل إلى صفحة تعديل الكتاب
                              Navigator.pushNamed(
                                context,
                                '/edit-book',
                                arguments: {'book': book},
                              );
                              // إضافة سجل للتشخيص
                              debugPrint(
                                'تم تمرير بيانات الكتاب للتعديل: ${book.toJson()}',
                              );
                            },
                            tooltip: 'تعديل',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmation(
                                context,
                                book,
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
  void _showDeleteConfirmation(BuildContext context, Book book, String token) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد من حذف كتاب "${book.title}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _booksBloc.add(
                    DeleteBookEvent(token: token, bookId: book.id),
                  );
                },
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
