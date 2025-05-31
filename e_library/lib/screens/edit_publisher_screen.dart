import 'package:e_library/blocs/publishers/publishers_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library/models/publisher.dart';
import 'package:e_library/blocs/auth/auth_bloc.dart';
import 'package:e_library/blocs/auth/auth_state.dart';
import 'package:e_library/blocs/publishers/publishers_bloc.dart';
import 'package:e_library/blocs/publishers/publishers_event.dart';

class EditPublisherScreen extends StatefulWidget {
  const EditPublisherScreen({super.key});

  @override
  State<EditPublisherScreen> createState() => _EditPublisherScreenState();
}

class _EditPublisherScreenState extends State<EditPublisherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  late Publisher _publisher;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('publisher')) {
      _publisher = args['publisher'] as Publisher;
      _initializeFormData();

      // أضف هذا السطر للتأكد من طباعة البيانات للتصحيح
      debugPrint(
        'تم تهيئة بيانات الناشر: ${_publisher.name}, ${_publisher.city}',
      );
    } else {
      setState(() {
        _error = 'لم يتم تمرير بيانات الناشر';
      });
    }
  }

  void _initializeFormData() {
    _nameController.text = _publisher.name;
    _cityController.text = _publisher.city;

    // أضف هذه الأسطر للتأكد من تعيين النص بشكل صحيح
    setState(() {});
    debugPrint(
      'تم تعيين النص في الحقول: ${_nameController.text}, ${_cityController.text}',
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          // تحقق من صلاحية التوكن
          final String token = authState.token;
          debugPrint('التوكن المستخدم للتحديث: $token');

          if (token.isEmpty) {
            throw Exception('التوكن فارغ، يرجى تسجيل الدخول مرة أخرى');
          }

          // استخدام PublishersBloc لتحديث الناشر
          context.read<PublishersBloc>().add(
            UpdatePublisherEvent(
              token: token,
              publisherId: _publisher.id,
              name: _nameController.text,
              city: _cityController.text,
            ),
          );

          // انتظار لحظة للسماح للعملية بالاكتمال
          await Future.delayed(const Duration(seconds: 2));

          // التحقق من حالة الـ bloc بعد التحديث
          if (!mounted) return; // Add this check

          final currentState = context.read<PublishersBloc>().state;
          if (currentState is PublishersError) {
            throw Exception(currentState.message);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث الناشر بنجاح')),
            );
            Navigator.pop(context);
          }
        } else {
          throw Exception('يجب تسجيل الدخول لتحديث الناشر');
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
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل ناشر'), centerTitle: true),
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
                          labelText: 'اسم الناشر',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم الناشر';
                          }
                          return null;
                        },
                        // تأكد من أن الحقل قابل للتعديل
                        enabled: true,
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
                        // تأكد من أن الحقل قابل للتعديل
                        enabled: true,
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
