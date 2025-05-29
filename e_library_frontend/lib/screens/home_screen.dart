import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library_frontend/blocs/auth/auth_bloc.dart';
import 'package:e_library_frontend/blocs/auth/auth_state.dart';
import 'package:e_library_frontend/blocs/auth/auth_event.dart';
import 'package:e_library_frontend/screens/books_screen.dart';
import 'package:e_library_frontend/screens/authors_screen.dart';
import 'package:e_library_frontend/screens/add_book_screen.dart';
import 'package:e_library_frontend/screens/add_author_screen.dart';
import 'package:e_library_frontend/screens/add_publisher_screen.dart';
import 'package:e_library_frontend/screens/publishers_screen.dart';

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
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    'الكتب',
                    Icons.book,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BooksScreen()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'المؤلفون',
                    Icons.person,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthorsScreen()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'الناشرون',
                    Icons.business,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PublishersScreen(),
                      ),
                    ),
                  ),
                  if (state.isAdmin) ...[
                    _buildMenuCard(
                      context,
                      'إضافة كتاب',
                      Icons.add_box,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddBookScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'إضافة مؤلف',
                      Icons.person_add,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddAuthorScreen(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'إضافة ناشر',
                      Icons.add_business,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddPublisherScreen(),
                        ),
                      ),
                    ),
                  ],
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
