import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library/models/author.dart';
import 'package:e_library/blocs/auth/auth_bloc.dart';
import 'package:e_library/blocs/auth/auth_state.dart';
import 'package:e_library/blocs/authors/authors_bloc.dart';
import 'package:e_library/blocs/authors/authors_event.dart';

class EditAuthorScreen extends StatefulWidget {
  const EditAuthorScreen({super.key});

  @override
  State<EditAuthorScreen> createState() => _EditAuthorScreenState();
}

class _EditAuthorScreenState extends State<EditAuthorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  late Author _author;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('author')) {
      _author = args['author'] as Author;
      _initializeFormData();
    } else {
      setState(() {
        _error = 'لم يتم تمرير بيانات المؤلف';
      });
    }
  }

  void _initializeFormData() {
    _nameController.text = _author.fullName;
    _countryController.text = _author.country;
    _cityController.text = _author.city;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          // استخدام AuthorsBloc لتحديث المؤلف
          context.read<AuthorsBloc>().add(
            UpdateAuthorEvent(
              token: authState.token,
              authorId: _author.id,
              fullName: _nameController.text,
              country: _countryController.text,
              city: _cityController.text,
            ),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث المؤلف بنجاح')),
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
    _nameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل مؤلف'), centerTitle: true),
      body:
          _error != null && _error!.contains('لم يتم تمرير')
              ? Center(child: Text(_error!))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم المؤلف',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم المؤلف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _countryController,
                        decoration: const InputDecoration(
                          labelText: 'البلد',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال البلد';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'المدينة',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال المدينة';
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
                      if (_error != null &&
                          !_error!.contains('لم يتم تمرير')) ...[
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
