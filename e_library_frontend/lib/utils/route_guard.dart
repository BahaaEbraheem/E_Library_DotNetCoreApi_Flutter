import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library_frontend/blocs/auth/auth_bloc.dart';
import 'package:e_library_frontend/blocs/auth/auth_state.dart';

class RouteGuard extends StatelessWidget {
  final Function guardedRoute;

  const RouteGuard({
    super.key,
    required this.guardedRoute,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.isAdmin) {
            // المستخدم مسجل الدخول وهو مسؤول، السماح بالوصول
            return guardedRoute();
          } else {
            // المستخدم مسجل الدخول ولكنه ليس مسؤولاً
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ليس لديك صلاحية للوصول إلى هذه الصفحة'),
                ),
              );
              Navigator.of(context).pushReplacementNamed('/home');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        } else {
          // المستخدم غير مسجل الدخول، توجيهه إلى صفحة تسجيل الدخول
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يجب تسجيل الدخول أولاً'),
              ),
            );
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}