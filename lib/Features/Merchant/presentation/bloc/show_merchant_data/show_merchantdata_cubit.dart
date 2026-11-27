import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'show_merchantdata_state.dart';

class ShowMerchantdataCubit extends Cubit<ShowMerchantdataState> {
  ShowMerchantdataCubit() : super(ShowMerchantdataInitial());

  Future<Map<String, dynamic>?> getUserDataById(String? userId) async {
    try {
      emit(ShowMerchantdataLoading());
      if (userId == null || userId.isEmpty) {
        emit(ShowMerchantdataFailed('لم يتم تسجيل الدخول'));
        return null;
      }

      final response = await Supabase.instance.client
          .from('merchont')
          .select()
          .eq('maerchont_id_fkey', userId)
          .maybeSingle();

      if (response == null) {
        emit(ShowMerchantdataFailed('لم يتم العثور على بيانات المتجر'));
        return null;
      }
      emit(ShowMerchantdataSucsess(response));
      return response;
    } catch (e) {
      debugPrint('ShowMerchantdata error: $e');
      emit(ShowMerchantdataFailed('تعذر جلب بيانات المتجر، تحقق من الاتصال'));
      return null;
    }
  }
}
