import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library_frontend/blocs/books/books_bloc.dart';
import 'package:e_library_frontend/blocs/books/books_event.dart';
import 'package:e_library_frontend/blocs/books/books_state.dart';
import 'package:e_library_frontend/services/api_service.dart';
import 'package:e_library_frontend/models/book.dart';

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
    _booksBloc = BooksBloc(ApiService());
    _booksBloc.add(LoadBooksEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _booksBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _booksBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الكتب'),
          centerTitle: true,
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
                      _booksBloc.add(LoadBooksEvent());
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _booksBloc.add(SearchBooksEvent(query: value));
                  } else {
                    _booksBloc.add(LoadBooksEvent());
                  }
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<BooksBloc, BooksState>(
                builder: (context, state) {
                  if (state is BooksLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BooksLoaded) {
                    return _buildBooksList(state.books);
                  } else if (state is BooksError) {
                    return Center(child: Text('خطأ: ${state.message}'));
                  }
                  return const Center(child: Text('لا توجد كتب'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksList(List<Book> books) {
    if (books.isEmpty) {
      return const Center(child: Text('لا توجد كتب'));
    }

    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(book.title),
            subtitle: Text('${book.type} - ${book.price} \$'),
            trailing: Text(book.authorName ?? 'غير معروف'),
          ),
        );
      },
    );
  }
}