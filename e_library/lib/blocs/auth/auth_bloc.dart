import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_library/blocs/auth/auth_event.dart';
import 'package:e_library/blocs/auth/auth_state.dart';
import 'package:e_library/services/api_service.dart';
import 'package:e_library/models/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;

  AuthBloc(this._apiService) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // التحقق من الاتصال بالخادم أولاً
      bool isServerReachable = await _apiService.isServerReachable();
      if (!isServerReachable) {
        throw Exception(
          'لا يمكن الوصول إلى الخادم. تأكد من تشغيل الخادم واتصالك بالإنترنت.',
        );
      }

      debugPrint('بدء تسجيل الدخول...');
      final response = await _apiService.login(event.username, event.password);
      debugPrint('تم تسجيل الدخول بنجاح، استلام الرمز المميز');
      final token = response['token'];

      // استخراج معلومات المستخدم من الـ JWT
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      debugPrint('تم فك تشفير الرمز المميز: $decodedToken');

      // طباعة جميع المفاتيح المتاحة في الرمز المميز
      debugPrint('مفاتيح الرمز المميز: ${decodedToken.keys.toList()}');

      // التحقق من وجود المفاتيح المطلوبة
      final String userId =
          decodedToken['nameid'] ?? decodedToken['unique_name'] ?? '0';
      final String username =
          decodedToken['name'] ?? decodedToken['unique_name'] ?? 'user';

      final user = User(
        id: int.parse(userId),
        username: username,
        firstName: decodedToken['given_name'] ?? '',
        lastName: decodedToken['family_name'] ?? '',
        isAdmin: decodedToken['role'] == 'Admin',
      );

      debugPrint('إرسال حالة AuthAuthenticated');
      emit(AuthAuthenticated(token: token, user: user, isAdmin: user.isAdmin));
    } catch (e) {
      debugPrint('خطأ في تسجيل الدخول: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _apiService.register(
        event.username,
        event.password,
        event.firstName,
        event.lastName,
        isAdmin: event.isAdmin,
      );

      // بعد التسجيل، قم بتسجيل الدخول تلقائ<|im_start|>
      add(LoginEvent(username: event.username, password: event.password));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }
}
