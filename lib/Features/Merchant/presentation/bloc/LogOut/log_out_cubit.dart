import 'package:entrig/entrig.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/core/services/customer_notification_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'log_out_state.dart';

class LogOutCubit extends Cubit<LogOutState> {
  LogOutCubit() : super(LogOutInitial());

  Future<void> logOutMethod() async {
    try {
      emit(LogOutLoading());

      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;

      // إيقاف مستمع الإشعارات وحذف رمز الجهاز لمنع وصول إشعارات لمستخدم آخر على نفس الهاتف
      await CustomerNotificationListener.instance.stopListening();
      if (currentUserId != null) {
        try {
          await supabase
              .from('user_devices')
              .delete()
              .eq('user_id', currentUserId);
        } catch (_) {}
      }

      try {
        await Entrig.unregister();
      } catch (_) {}

      await supabase.auth.signOut();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('role');

      emit(LogOutSucesses('تم تسجيل الخروج بنجاح'));
    } catch (e) {
      debugPrint('LogOut error: $e');
      emit(LogOutFailed('حدث خطأ غير متوقع أثناء تسجيل الخروج'));
    }
  }

  /// حذف الحساب بعد التحقق من عدم وجود مديونيات نشطة (متطلب إلزامي لمتجر Google Play)
  Future<void> deleteAccountMethod({required bool isMerchant}) async {
    try {
      emit(LogOutLoading());
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        emit(LogOutFailed('لا توجد جلسة نشطة'));
        return;
      }

      final table = isMerchant ? 'merchont' : 'cutomers';
      final fkCol = isMerchant ? 'maerchont_id_fkey' : 'customers_id_fkey';
      final connectCol = isMerchant ? 'ID_merchont' : 'ID_customer';

      final profile = await supabase
          .from(table)
          .select('id')
          .eq(fkCol, user.id)
          .maybeSingle();

      if (profile != null) {
        final int profileId = (profile['id'] as num).toInt();
        final connects = await supabase
            .from('connects')
            .select('id')
            .eq(connectCol, profileId);

        final connectIds = (connects as List<dynamic>)
            .map<int?>((c) => ((c as Map<String, dynamic>)['id'] as num?)?.toInt())
            .whereType<int>()
            .toList();

        if (connectIds.isNotEmpty) {
          final purchases = await supabase
              .from('Content')
              .select('price, Quantity')
              .inFilter('ID_Conect', connectIds);

          double gross = 0.0;
          for (final p in purchases as List<dynamic>) {
            final m = p as Map<String, dynamic>;
            gross +=
                ((m['price'] as num?)?.toDouble() ?? 0.0) *
                ((m['Quantity'] as num?)?.toInt() ?? 1);
          }

          double paid = 0.0;
          try {
            final payments = await supabase
                .from('payments')
                .select('amount')
                .inFilter('ID_Conect', connectIds);
            for (final pay in payments as List<dynamic>) {
              paid +=
                  ((pay as Map<String, dynamic>)['amount'] as num?)
                      ?.toDouble() ??
                  0.0;
            }
          } catch (_) {}

          if ((gross - paid) > 0.01) {
            emit(
              LogOutFailed(
                'لا يمكن حذف الحساب لوجود مديونيات قائمة بقيمة ${(gross - paid).toStringAsFixed(2)} ر.ي، يرجى تصفيتها أولاً',
              ),
            );
            return;
          }

          await supabase.from('connects').delete().eq(connectCol, profileId);
        }

        await supabase.from(table).delete().eq('id', profileId);
      }

      try {
        await supabase.from('user_devices').delete().eq('user_id', user.id);
      } catch (_) {}

      await CustomerNotificationListener.instance.stopListening();
      try {
        await Entrig.unregister();
      } catch (_) {}

      await supabase.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('role');

      emit(LogOutSucesses('تم حذف الحساب وبياناته بنجاح'));
    } catch (e) {
      debugPrint('deleteAccount error: $e');
      emit(LogOutFailed('تعذر إتمام حذف الحساب حالياً، حاول مرة أخرى'));
    }
  }
}
