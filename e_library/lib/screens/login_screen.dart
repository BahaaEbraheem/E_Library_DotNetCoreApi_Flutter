import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library/blocs/auth/auth_bloc.dart';
import 'package:e_library/blocs/auth/auth_event.dart';
import 'package:e_library/blocs/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // إضافة FocusNodes للتحكم في التركيز
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // تأخير قصير ثم تعيين التركيز على حقل اسم المستخدم
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_usernameFocus);
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _attemptLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginEvent(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول'), centerTitle: true),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: GestureDetector(
          // إغلاق لوحة المفاتيح عند النقر خارج حقول الإدخال
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.library_books,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 32),

                    // حقل اسم المستخدم
                    Focus(
                      onFocusChange: (hasFocus) {
                        if (hasFocus) {
                          debugPrint('حقل اسم المستخدم حصل على التركيز');
                        }
                      },
                      child: TextFormField(
                        controller: _usernameController,
                        focusNode: _usernameFocus,
                        decoration: const InputDecoration(
                          labelText: 'اسم المستخدم',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم المستخدم';
                          }
                          return null;
                        },
                        // إعدادات إضافية للإدخال
                        enableInteractiveSelection: true,
                        enableSuggestions: true,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        onEditingComplete: () {
                          // الانتقال إلى حقل كلمة المرور عند الضغط على Enter
                          FocusScope.of(context).requestFocus(_passwordFocus);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // حقل كلمة المرور
                    Focus(
                      onFocusChange: (hasFocus) {
                        if (hasFocus) {
                          debugPrint('حقل كلمة المرور حصل على التركيز');
                        }
                      },
                      child: TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال كلمة المرور';
                          }
                          return null;
                        },
                        // إعدادات إضافية للإدخال
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _attemptLogin,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // زر تسجيل الدخول
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed:
                              state is AuthLoading ? null : _attemptLogin,
                          child:
                              state is AuthLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(fontSize: 16),
                                  ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // رابط التسجيل
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: const Text('ليس لديك حساب؟ سجل الآن'),
                    ),

                    // إضافة زر لاختبار التركيز
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(_usernameFocus);
                      },
                      child: const Text('تركيز على اسم المستخدم'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
