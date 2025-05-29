import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library_frontend/services/api_service.dart';
import 'package:e_library_frontend/blocs/auth/auth_bloc.dart';
import 'package:e_library_frontend/blocs/books/books_bloc.dart';
import 'package:e_library_frontend/blocs/authors/authors_bloc.dart';
import 'package:e_library_frontend/blocs/publishers/publishers_bloc.dart';
import 'package:e_library_frontend/screens/login_screen.dart';
import 'package:e_library_frontend/screens/register_screen.dart';
import 'package:e_library_frontend/screens/home_screen.dart';
import 'package:e_library_frontend/screens/books_screen.dart';
import 'package:e_library_frontend/screens/book_details_screen.dart';
import 'package:e_library_frontend/screens/authors_screen.dart';
import 'package:e_library_frontend/screens/author_details_screen.dart';
import 'package:e_library_frontend/screens/publishers_screen.dart';
import 'package:e_library_frontend/screens/publisher_details_screen.dart';
import 'package:e_library_frontend/screens/add_book_screen.dart';
import 'package:e_library_frontend/screens/add_author_screen.dart';
import 'package:e_library_frontend/screens/add_publisher_screen.dart';
import 'package:e_library_frontend/screens/search_books_screen.dart';
import 'package:e_library_frontend/screens/search_authors_screen.dart';
import 'package:e_library_frontend/screens/search_publishers_screen.dart';
import 'package:e_library_frontend/utils/route_guard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(apiService)),
        BlocProvider(create: (context) => BooksBloc(apiService)),
        BlocProvider(create: (context) => AuthorsBloc(apiService)),
        BlocProvider(create: (context) => PublishersBloc(apiService)),
      ],
      child: MaterialApp(
        title: 'E-Library',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        initialRoute: '/login',
        routes: {
          // المسارات الأساسية
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),

          // مسارات عرض البيانات (متاحة لجميع المستخدمين)
          '/books': (context) => const BooksScreen(),
          '/book-details': (context) => const BookDetailsScreen(),
          '/authors': (context) => const AuthorsScreen(),
          '/author-details': (context) => const AuthorDetailsScreen(),
          '/publishers': (context) => const PublishersScreen(),
          '/publisher-details': (context) => const PublisherDetailsScreen(),

          // مسارات البحث (متاحة لجميع المستخدمين)
          '/search-books': (context) => const SearchBooksScreen(),
          '/search-authors': (context) => const SearchAuthorsScreen(),
          '/search-publishers': (context) => const SearchPublishersScreen(),
        },
        // استخدام onGenerateRoute للمسارات التي تحتاج إلى حماية (للمسؤول فقط)
        onGenerateRoute: (settings) {
          // التحقق من المسارات التي تتطلب صلاحيات المسؤول
          if (settings.name == '/add-book' ||
              settings.name == '/add-author' ||
              settings.name == '/add-publisher') {
            return MaterialPageRoute(
              builder: (context) {
                // استخدام RouteGuard للتحقق من صلاحيات المستخدم
                return RouteGuard(
                  guardedRoute: () {
                    switch (settings.name) {
                      case '/add-book':
                        return const AddBookScreen();
                      case '/add-author':
                        return const AddAuthorScreen();
                      case '/add-publisher':
                        return const AddPublisherScreen();
                      default:
                        return const HomeScreen();
                    }
                  },
                );
              },
            );
          }

          // إذا لم يكن المسار محمotp، إرجاع null للسماح للمسارات العادية بالعمل
          return null;
        },
      ),
    );
  }
}
