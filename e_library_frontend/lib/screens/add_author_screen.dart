import 'dart:async';
import 'dart:math' show min;
import 'package:e_library_frontend/blocs/authors/authors_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library_frontend/blocs/auth/auth_bloc.dart';
import 'package:e_library_frontend/blocs/auth/auth_state.dart';
import 'package:e_library_frontend/blocs/authors/authors_bloc.dart';
import 'package:e_library_frontend/blocs/authors/authors_event.dart';

class AddAuthorScreen extends StatefulWidget {
  const AddAuthorScreen({super.key});

  @override
  State<AddAuthorScreen> createState() => _AddAuthorScreenState();
}

class _AddAuthorScreenState extends State<AddAuthorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController(); // إضافة حقل للعنوان

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose(); // التخلص من المتحكم عند الانتهاء
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null; // إعادة تعيين الخطأ
      });

      try {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          // طباعة البيانات للتشخيص
          debugPrint(
            'إرسال بيانات المؤلف: ${_nameController.text}, ${_countryController.text}, ${_cityController.text}, ${_addressController.text}',
          );

          // طباعة معلومات التوكن
          debugPrint(
            'توكن المستخدم: ${authState.token.substring(0, min(20, authState.token.length))}...',
          );

          // تعريف المتغير قبل استخدامه
          late StreamSubscription<AuthorsState> subscription;

          // الاستماع لتغييرات حالة AuthorsBloc
          subscription = context.read<AuthorsBloc>().stream.listen((state) {
            debugPrint('حالة AuthorsBloc الجديدة: $state');

            if (state is AuthorsLoaded) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت إضافة المؤلف بنجاح')),
                );
                Navigator.pop(context, true);
              }
              subscription.cancel();
            } else if (state is AuthorsError) {
              if (mounted) {
                setState(() {
                  _error = state.message;
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطأ: ${state.message}')),
                );
              }
              subscription.cancel();
            }
          });

          // استخدام AuthorsBloc لإضافة المؤلف
          context.read<AuthorsBloc>().add(
            AddAuthorEvent(
              token: authState.token,
              fullName: _nameController.text,
              country: _countryController.text,
              city: _cityController.text,
              address: _addressController.text,
            ),
          );

          // إلغاء الاشتراك بعد فترة زمنية محددة لتجنب التسريب
          Future.delayed(const Duration(seconds: 10), () {
            subscription.cancel();
            if (mounted && _isLoading) {
              setState(() {
                _isLoading = false;
                _error = 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.'),
                ),
              );
            }
          });
        }
      } catch (e) {
        debugPrint('خطأ غير متوقع: $e');
        if (mounted) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مؤلف'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                // تمكين إدخال النص من لوحة المفاتيح
                autofocus: true,
                textInputAction: TextInputAction.next,
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
                // تمكين إدخال النص من لوحة المفاتيح
                textInputAction: TextInputAction.next,
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
                // تمكين إدخال النص من لوحة المفاتيح
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(),
                ),
                // العنوان اختياري، لذلك لا نحتاج إلى مصادق
                // تمكين إدخال النص من لوحة المفاتيح
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitForm(),
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
                          'إضافة المؤلف',
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
            ],
          ),
        ),
      ),
    );
  }
}
