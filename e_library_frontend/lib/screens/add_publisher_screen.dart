import 'package:e_library_frontend/blocs/publishers/publishers_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library_frontend/blocs/auth/auth_bloc.dart';
import 'package:e_library_frontend/blocs/auth/auth_state.dart';
import 'package:e_library_frontend/blocs/publishers/publishers_bloc.dart';
import 'package:e_library_frontend/blocs/publishers/publishers_event.dart';

class AddPublisherScreen extends StatefulWidget {
  const AddPublisherScreen({super.key});

  @override
  State<AddPublisherScreen> createState() => _AddPublisherScreenState();
}

class _AddPublisherScreenState extends State<AddPublisherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          // استخدام PublishersBloc لإضافة الناشر
          context.read<PublishersBloc>().add(
            AddPublisherEvent(
              token: authState.token,
              name: _nameController.text,
              city: _cityController.text,
            ),
          );

          // انتظار استجابة من الباك إند
          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            // تحقق من حالة الـ bloc
            final currentState = context.read<PublishersBloc>().state;
            if (currentState is PublishersError) {
              throw Exception(currentState.message);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تمت إضافة الناشر بنجاح')),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
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
      appBar: AppBar(title: const Text('إضافة ناشر'), centerTitle: true),
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
                  labelText: 'اسم الناشر',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم الناشر';
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                          'إضافة الناشر',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
