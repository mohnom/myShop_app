import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ResetPasswordState> {
  ForgotPasswordCubit() : super(ResetPasswordInitial());
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> sendResetEmail(String email) async {
    emit(ResetPasswordLoading());
    try {
      await supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.flutter://reset-callback/',
      );
      emit(
        ResetPasswordSuccess(
          'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني بنجاح',
        ),
      );
    } on AuthException catch (e) {
      emit(ResetPasswordFailure(e.message));
    } catch (_) {
      emit(ResetPasswordFailure('تعذر إرسال الرابط، تحقق من اتصال الإنترنت'));
    }
  }
}
