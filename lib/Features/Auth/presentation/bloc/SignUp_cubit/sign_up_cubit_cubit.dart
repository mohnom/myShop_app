import 'package:entrig/entrig.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Auth/presentation/bloc/SignUp_cubit/sign_up_cubit_state.dart';
import 'package:myshop/Features/Customer/data/repositories/customer_get_notifaction.dart';
import 'package:myshop/core/services/customer_notification_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpCubitCubit extends Cubit<SignUpCubitState> {
  SignUpCubitCubit() : super(SignUpCubitInitial());

  final SupabaseClient _supabase = Supabase.instance.client;

  /// إنشاء حساب جديد مع تسجيل دخول مباشر فوري (بدون OTP)
  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(SignUpCubitLoading());

    final cleanName = name.trim();
    final cleanEmail = email.trim();

    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {'full_name': cleanName, 'role': role},
      );

      final String? userId = res.user?.id;
      if (userId == null) {
        emit(SignUpCubitFailure('تعذر إنشاء الحساب، يرجى المحاولة مرة أخرى'));
        return;
      }

      // ضمان وجود جلسة نشطة للدخول المباشر
      Session? activeSession = res.session ?? _supabase.auth.currentSession;
      if (activeSession == null) {
        try {
          final signInRes = await _supabase.auth.signInWithPassword(
            email: cleanEmail,
            password: password,
          );
          activeSession = signInRes.session;
        } catch (_) {
          // في حال كان خيار Confirm Email لا يزال مفعلاً في لوحة تحكم Supabase
        }
      }

      // إدراج بيانات المستخدم في جدول الدور المقابل مع تجنب التكرار
      if (role == 'merchant') {
        final existing = await _supabase
            .from('merchont')
            .select('id')
            .eq('maerchont_id_fkey', userId)
            .maybeSingle();
        if (existing == null) {
          await _supabase.from('merchont').insert({
            'name': cleanName,
            'email': cleanEmail,
            'maerchont_id_fkey': userId,
          });
        }
      } else if (role == 'customer') {
        final existing = await _supabase
            .from('cutomers')
            .select('id')
            .eq('customers_id_fkey', userId)
            .maybeSingle();
        if (existing == null) {
          await _supabase.from('cutomers').insert({
            'name': cleanName,
            'email': cleanEmail,
            'customers_id_fkey': userId,
          });
        }
      }

      if (activeSession != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', role);

        try {
          await Entrig.register(userId: userId);
        } catch (_) {}

        if (role == 'customer') {
          saveCustomerDeviceToken();
          CustomerNotificationListener.instance.startListening(
            authUserId: userId,
          );
        }

        emit(
          SignUpDirectLoginSuccess(
            message: 'أهلاً بك $cleanName! تم إنشاء حسابك وتسجيل دخولك بنجاح',
            role: role,
          ),
        );
      } else {
        emit(
          SignUpCubitSucsess(
            'تم إنشاء الحساب بنجاح! يرجى إيقاف تأكيد البريد من إعدادات Supabase للدخول التلقائي أو تسجيل الدخول الآن.',
          ),
        );
      }
    } on AuthException catch (e) {
      String errMsg = 'تعذر إنشاء الحساب، حاول مرة أخرى';
      final lower = e.message.toLowerCase();
      if (lower.contains('already registered') ||
          lower.contains('already exists')) {
        errMsg = 'هذا البريد الإلكتروني مسجل مسبقاً، يرجى تسجيل الدخول';
      } else if (lower.contains('password')) {
        errMsg = 'كلمة المرور ضعيفة، يجب ألا تقل عن 8 أحرف';
      } else if (lower.contains('rate limit')) {
        errMsg = 'محاولات كثيرة متتالية، يرجى الانتظار قليلاً ثم المحاولة';
      }
      emit(SignUpCubitFailure(errMsg));
    } catch (e) {
      debugPrint('SignUp error: $e');
      emit(
        SignUpCubitFailure(
          'حدث خطأ في الاتصال بالخادم، تحقق من الإنترنت وحاول مجدداً',
        ),
      );
    }
  }
}
