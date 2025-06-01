import 'package:e_library/blocs/books/books_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library/blocs/auth/auth_bloc.dart';
import 'package:e_library/blocs/auth/auth_state.dart';
import 'package:e_library/blocs/books/books_bloc.dart';
import 'package:e_library/blocs/books/books_event.dart';
import 'package:e_library/models/author.dart';
import 'package:e_library/models/publisher.dart';
import 'package:e_library/services/api_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
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

  // دالة لتحويل الأرقام العربية إلى أرقام إنجليزية
  String _convertArabicToEnglishNumbers(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    for (int i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }

    return input;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
      _error = null;
    });

    try {
      // تحميل المؤلفين والناشرين
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
          // إضافة الكتاب باستخدام BooksBloc
          context.read<BooksBloc>().add(
            AddBookEvent(
              token: authState.token,
              title: _titleController.text,
              type: _typeController.text,
              price: double.parse(
                _convertArabicToEnglishNumbers(_priceController.text),
              ),
              authorId: _selectedAuthorId!,
              publisherId: _selectedPublisherId!,
            ),
          );

          // انتظار استجابة من الباك إند
          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            // تحقق من حالة الـ bloc
            final currentState = context.read<BooksBloc>().state;
            if (currentState is BooksError) {
              throw Exception(currentState.message);
            }

            // تحديث قائمة الكتب قبل العودة
            context.read<BooksBloc>().add(LoadBooksEvent());

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تمت إضافة الكتاب بنجاح')),
            );

            // العودة إلى الشاشة السابقة
            Navigator.pop(context, true);
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
          ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة كتاب'), centerTitle: true),
      body:
          _isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('خطأ: $_error'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'عنوان الكتاب',
                          border: OutlineInputBorder(),
                        ),
                        textDirection:
                            TextDirection.rtl, // Add this for RTL text
                        textAlign:
                            TextAlign.right, // Add this for RTL alignment
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال عنوان الكتاب';
                          }
                          return null;
                        },
                        // تمكين إدخال النص من لوحة المفاتيح
                        autofocus: true,
                        textInputAction: TextInputAction.next,
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
                            final convertedValue =
                                _convertArabicToEnglishNumbers(value);
                            final price = double.parse(convertedValue);
                            if (price <= 0) {
                              return 'يجب أن يكون السعر أكبر من صفر';
                            }
                          } catch (e) {
                            return 'الرجاء إدخال سعر صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'المؤلف',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedAuthorId,
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
                        hint: const Text('اختر المؤلف'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'الناشر',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedPublisherId,
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
                        hint: const Text('اختر الناشر'),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                  'إضافة الكتاب',
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/add-author');
                        },
                        child: const Text('إضافة مؤلف جديد'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/add-publisher');
                        },
                        child: const Text('إضافة ناشر جديد'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
