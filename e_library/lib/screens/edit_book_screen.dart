import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library/models/book.dart';
import 'package:e_library/models/author.dart';
import 'package:e_library/models/publisher.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/blocs/auth/auth_bloc.dart';
import 'package:e_library/blocs/auth/auth_state.dart';
import 'package:e_library/blocs/books/books_bloc.dart';
import 'package:e_library/blocs/books/books_event.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    // تحميل البيانات مرة واحدة فقط
    if (_isLoadingData) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      // طباعة للتشخيص
      debugPrint('Arguments received: $args');

      if (args != null && args.containsKey('book')) {
        _book = args['book'] as Book;

        // طباعة للتشخيص
        debugPrint('Book data received: ${_book.toJson()}');

        _initializeFormData();
        _loadData();
      } else {
        setState(() {
          _error = 'لم يتم تمرير بيانات الكتاب';
          _isLoadingData = false;
        });
      }
    }
  }

  void _initializeFormData() {
    // طباعة للتشخيص
    debugPrint('Initializing form data with book: ${_book.toJson()}');

    _titleController.text = _book.title;
    _typeController.text = _book.type;
    _priceController.text = _book.price.toString();
    _selectedAuthorId = _book.authorId;
    _selectedPublisherId = _book.publisherId;

    // طباعة للتشخيص
    debugPrint(
      'Form initialized with: Title=${_titleController.text}, Type=${_typeController.text}, Price=${_priceController.text}',
    );
    debugPrint(
      'Selected Author ID: $_selectedAuthorId, Selected Publisher ID: $_selectedPublisherId',
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
      _error = null;
    });

    try {
      // طباعة للتشخيص
      debugPrint('Loading authors and publishers data...');

      final authorsData = await _apiService.getAllAuthors();
      final publishersData = await _apiService.getAllPublishers();

      // طباعة للتشخيص
      debugPrint('Authors data loaded: ${authorsData.length} authors');
      debugPrint('Publishers data loaded: ${publishersData.length} publishers');

      setState(() {
        _authors = authorsData.map((data) => Author.fromJson(data)).toList();
        _publishers =
            publishersData.map((data) => Publisher.fromJson(data)).toList();
        _isLoadingData = false;
      });
    } catch (e) {
      // طباعة للتشخيص
      debugPrint('Error loading data: $e');

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
        _error = null; // إضافة هذا السطر لمسح أي أخطاء سابقة
      });

      try {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          // طباعة القيم للتشخيص
          debugPrint('تحديث الكتاب:');
          debugPrint('العنوان: ${_titleController.text}');
          debugPrint('النوع: ${_typeController.text}');
          debugPrint('السعر: ${_priceController.text}');
          debugPrint('معرف المؤلف: $_selectedAuthorId');
          debugPrint('معرف الناشر: $_selectedPublisherId');

          // تحديث الكتاب باستخدام BooksBloc
          context.read<BooksBloc>().add(
            UpdateBookEvent(
              token: authState.token,
              bookId: _book.id,
              title: _titleController.text,
              type: _typeController.text,
              price: double.parse(
                _convertArabicToEnglishNumbers(_priceController.text),
              ),
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
      appBar: AppBar(title: const Text('تعديل كتاب')),
      body:
          _isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
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
                            return 'الرجاء إدخال السعر';
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
                      // تعديل قائمة المؤلفين المنسدلة
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
                        isDense: true,
                        isExpanded: true,
                      ),
                      const SizedBox(height: 16),
                      // تعديل قائمة الناشرين المنسدلة
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
                        isDense: true,
                        isExpanded: true,
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
