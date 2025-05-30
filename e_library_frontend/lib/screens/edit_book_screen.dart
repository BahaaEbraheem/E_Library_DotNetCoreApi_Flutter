import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library_frontend/models/book.dart';
import 'package:e_library_frontend/models/author.dart';
import 'package:e_library_frontend/models/publisher.dart';
import 'package:e_library_frontend/services/api_service.dart';
import 'package:e_library_frontend/blocs/auth/auth_bloc.dart';
import 'package:e_library_frontend/blocs/auth/auth_state.dart';
import 'package:e_library_frontend/blocs/books/books_bloc.dart';
import 'package:e_library_frontend/blocs/books/books_event.dart';

class EditBookScreen extends StatefulWidget {
  const EditBookScreen({super.key});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();

  final ApiService _apiService = ApiService();

  List<Author> _authors = [];
  List<Publisher> _publishers = [];
  int? _selectedAuthorId;
  int? _selectedPublisherId;

  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _error;
  late Book _book;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('book')) {
      _book = args['book'] as Book;
      _initializeFormData();
      _loadData();
    } else {
      setState(() {
        _error = 'لم يتم تمرير بيانات الكتاب';
        _isLoadingData = false;
      });
    }
  }

  void _initializeFormData() {
    _titleController.text = _book.title;
    _typeController.text = _book.type;
    _priceController.text = _book.price.toString();
    _selectedAuthorId = _book.authorId;
    _selectedPublisherId = _book.publisherId;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
      _error = null;
    });

    try {
      final authorsData = await _apiService.getAllAuthors();
      final publishersData = await _apiService.getAllPublishers();

      setState(() {
        _authors = authorsData.map((data) => Author.fromJson(data)).toList();
        _publishers =
            publishersData.map((data) => Publisher.fromJson(data)).toList();
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل البيانات: ${e.toString()}';
        _isLoadingData = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          // تحديث الكتاب باستخدام BooksBloc
          context.read<BooksBloc>().add(
            UpdateBookEvent(
              token: authState.token,
              bookId: _book.id,
              title: _titleController.text,
              type: _typeController.text,
              price: double.parse(_priceController.text),
              authorId: _selectedAuthorId!,
              publisherId: _selectedPublisherId!,
            ),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث الكتاب بنجاح')),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: $_error')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل كتاب'), centerTitle: true),
      body:
          _isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _error!.contains('لم يتم تمرير')
              ? Center(child: Text(_error!))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'عنوان الكتاب',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال عنوان الكتاب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _typeController,
                        decoration: const InputDecoration(
                          labelText: 'نوع الكتاب',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال نوع الكتاب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'السعر',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال سعر الكتاب';
                          }
                          try {
                            double.parse(value);
                          } catch (e) {
                            return 'الرجاء إدخال رقم صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedAuthorId,
                        decoration: const InputDecoration(
                          labelText: 'المؤلف',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _authors.map((author) {
                              return DropdownMenuItem<int>(
                                value: author.id,
                                child: Text(author.fullName),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAuthorId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'الرجاء اختيار المؤلف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedPublisherId,
                        decoration: const InputDecoration(
                          labelText: 'الناشر',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _publishers.map((publisher) {
                              return DropdownMenuItem<int>(
                                value: publisher.id,
                                child: Text(publisher.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPublisherId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'الرجاء اختيار الناشر';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        child:
                            _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('حفظ التغييرات'),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}
