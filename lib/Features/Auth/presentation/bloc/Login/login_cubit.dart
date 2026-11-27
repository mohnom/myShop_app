import 'package:entrig/entrig.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Customer/data/repositories/customer_get_notifaction.dart';
import 'package:myshop/core/services/customer_notification_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    emit(LoginLoading());

    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      if (user == null) {
        emit(LoginFailure('تعذر تسجيل الدخول، يرجى المحاولة مرة أخرى'));
        return;
      }

      final String userId = user.id;
      String? role = user.userMetadata?['role'] as String?;

      // في حال عدم وجود الدور في metadata، نستنتجه من جداول قاعدة البيانات
      if (role == null || (role != 'merchant' && role != 'customer')) {
        final m = await _supabase
            .from('merchont')
            .select('id')
            .eq('maerchont_id_fkey', userId)
            .maybeSingle();
        if (m != null) {
          role = 'merchant';
        } else {
          final c = await _supabase
              .from('cutomers')
              .select('id')
              .eq('customers_id_fkey', userId)
              .maybeSingle();
          if (c != null) {
            role = 'customer';
          }
        }
      }

      try {
        await Entrig.register(userId: userId);
      } catch (e) {
        debugPrint('Entrig register warning: $e');
      }

      if (role == 'merchant') {
        await prefs.setString('role', 'merchant');
        emit(LoginMerchontSucsess('عزيزي التاجر، تم تسجيل دخولك بنجاح'));
      } else if (role == 'customer') {
        await prefs.setString('role', 'customer');
        saveCustomerDeviceToken();
        CustomerNotificationListener.instance.startListening(
          authUserId: userId,
        );
        emit(LoginCusomerSucsess('عزيزي العميل، تم تسجيل دخولك بنجاح'));
      } else {
        emit(LoginFailure('لم يتم العثور على ملف تعريف مرتبط بهذا الحساب'));
      }
    } on AuthException catch (e) {
      String errorMessage = 'خطأ في تسجيل الدخول';
      if (e.message.contains('Invalid login credentials')) {
        errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      } else if (e.message.contains('Email not confirmed')) {
        errorMessage =
            'البريد الإلكتروني غير مفعّل في Supabase؛ أوقف خيار Confirm Email للدخول المباشر';
      }
      emit(LoginFailure(errorMessage));
    } catch (e) {
      debugPrint('Login error: $e');
      emit(
        LoginFailure(
          'تعذر الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت والمحاولة مجدداً',
        ),
      );
    }
  }
}
