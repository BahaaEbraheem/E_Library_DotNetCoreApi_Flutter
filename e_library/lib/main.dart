import 'package:e_library/screens/edit_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/blocs/auth/auth_bloc.dart';
import 'package:e_library/blocs/books/books_bloc.dart';
import 'package:e_library/blocs/authors/authors_bloc.dart';
import 'package:e_library/blocs/publishers/publishers_bloc.dart';
import 'package:e_library/screens/login_screen.dart';
import 'package:e_library/screens/register_screen.dart';
import 'package:e_library/screens/home_screen.dart';
import 'package:e_library/screens/books_screen.dart';
import 'package:e_library/screens/book_details_screen.dart';
import 'package:e_library/screens/authors_screen.dart';
import 'package:e_library/screens/author_details_screen.dart';
import 'package:e_library/screens/publishers_screen.dart';
import 'package:e_library/screens/publisher_details_screen.dart';
import 'package:e_library/screens/add_book_screen.dart';
import 'package:e_library/screens/add_author_screen.dart';
import 'package:e_library/screens/add_publisher_screen.dart';
import 'package:e_library/screens/search_books_screen.dart';
import 'package:e_library/screens/search_authors_screen.dart';
import 'package:e_library/screens/search_publishers_screen.dart';
import 'package:e_library/utils/route_guard.dart';
import 'package:e_library/screens/edit_author_screen.dart';
import 'package:e_library/screens/edit_publisher_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  // تأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // تكوين النظام لقبول إدخال لوحة المفاتيح
  SystemChannels.textInput.invokeMethod('TextInput.setClient', [
    1,
    {
      'inputType': {'name': 'TextInputType.text'},
      'inputAction': 'TextInputAction.done',
    },
  ]);

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
        // Add these localization delegates
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Add Arabic and English as supported locales
        supportedLocales: const [
          Locale('ar'), // Arabic
          Locale('en'), // English
        ],
        // Set Arabic as the default locale
        locale: const Locale('ar'),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          // Configure text direction for RTL languages
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontFamily: 'Arial'),
          ),
          // إضافة تكوين لتحسين تجربة لوحة المفاتيح
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
        ),
        home: Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            // اختصار Enter للإرسال
            LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
            // اختصار Tab للانتقال بين الحقول
            LogicalKeySet(LogicalKeyboardKey.tab): const NextFocusIntent(),
            // اختصار Shift+Tab للانتقال للحقل السابق
            LogicalKeySet(LogicalKeyboardKey.tab, LogicalKeyboardKey.shift):
                const PreviousFocusIntent(),
          },
          child: const LoginScreen(),
        ),
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

          // مسارات البحث
          '/search-books': (context) => const SearchBooksScreen(),
          '/search-authors': (context) => const SearchAuthorsScreen(),
          '/search-publishers': (context) => const SearchPublishersScreen(),

          // مسار تعديل الكتاب
          '/edit-book': (context) => const EditBookScreen(),
          '/edit-author': (context) => const EditAuthorScreen(),
          '/edit-publisher': (context) => const EditPublisherScreen(),
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
