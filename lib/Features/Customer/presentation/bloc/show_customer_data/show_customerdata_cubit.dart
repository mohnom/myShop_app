import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'show_customerdata_state.dart';

class ShowCustomerdataCubit extends Cubit<ShowCustomerdataState> {
  ShowCustomerdataCubit() : super(ShowCustomerdataInitial());

  Future<Map<String, dynamic>?> getUserDataById(String? userId) async {
    try {
      emit(ShowCustomerdataLoading());
      if (userId == null || userId.isEmpty) {
        emit(ShowCustomerdataFailed('لم يتم تسجيل الدخول'));
        return null;
      }

      final response = await Supabase.instance.client
          .from('cutomers')
          .select()
          .eq('customers_id_fkey', userId)
          .maybeSingle();

      if (response == null) {
        emit(ShowCustomerdataFailed('لم يتم العثور على بيانات العميل'));
        return null;
      }

      emit(ShowCustomerdataSucsess(response));
      return response;
    } catch (e) {
      debugPrint('ShowCustomerdata error: $e');
      emit(ShowCustomerdataFailed('تعذر جلب البيانات، تحقق من الاتصال'));
      return null;
    }
  }
}
