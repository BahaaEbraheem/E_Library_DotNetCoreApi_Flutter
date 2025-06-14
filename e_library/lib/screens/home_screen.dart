import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library/blocs/auth/auth_bloc.dart';
import 'package:e_library/blocs/auth/auth_state.dart';
import 'package:e_library/blocs/auth/auth_event.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('المكتبة الإلكترونية'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutEvent());
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
              ],
            ),

            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ عرض معلومات المستخدم
                  Card(
                    color: Colors.blue[50],
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('مرحباً، ${state.user.username}'),
                      subtitle: Text(state.isAdmin ? 'مسؤول' : 'مستخدم عادي'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ القائمة الرئيسية
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildMenuCard(
                          context,
                          'الكتب',
                          Icons.book,
                          () => Navigator.pushNamed(context, '/books'),
                        ),
                        _buildMenuCard(
                          context,
                          'المؤلفون',
                          Icons.person,
                          () => Navigator.pushNamed(context, '/authors'),
                        ),
                        _buildMenuCard(
                          context,
                          'الناشرون',
                          Icons.business,
                          () => Navigator.pushNamed(context, '/publishers'),
                        ),
                        _buildMenuCard(
                          context,
                          'البحث عن كتاب',
                          Icons.search,
                          () => Navigator.pushNamed(context, '/search-books'),
                        ),
                        _buildMenuCard(
                          context,
                          'البحث عن مؤلف',
                          Icons.person_search,
                          () => Navigator.pushNamed(context, '/search-authors'),
                        ),
                        _buildMenuCard(
                          context,
                          'البحث عن ناشر',
                          Icons.business_center,
                          () => Navigator.pushNamed(
                            context,
                            '/search-publishers',
                          ),
                        ),

                        // ✅ خيارات المسؤول فقط
                        if (state.isAdmin) ...[
                          _buildMenuCard(
                            context,
                            'إضافة كتاب',
                            Icons.add_box,
                            () => Navigator.pushNamed(context, '/add-book'),
                          ),
                          _buildMenuCard(
                            context,
                            'إضافة مؤلف',
                            Icons.person_add,
                            () => Navigator.pushNamed(context, '/add-author'),
                          ),
                          _buildMenuCard(
                            context,
                            'إضافة ناشر',
                            Icons.add_business,
                            () =>
                                Navigator.pushNamed(context, '/add-publisher'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
