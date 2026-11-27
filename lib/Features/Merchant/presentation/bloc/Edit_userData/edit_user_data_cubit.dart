import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'edit_user_data_state.dart';

class EditUserDataCubit extends Cubit<EditUserDataState> {
  EditUserDataCubit() : super(EditUserDataInitial());
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> editUserDataMethod(
    String data, {
    String table = 'merchont',
    String idColumn = 'maerchont_id_fkey',
  }) async {
    final cleanName = data.trim();
    if (cleanName.length < 2) {
      emit(EditUserDataFalied('يرجى إدخال اسم صحيح لا يقل عن حرفين'));
      return;
    }

    emit(EditUserDataLoading());

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        emit(EditUserDataFalied('لم يتم العثور على جلسة مستخدم نشطة'));
        return;
      }

      final userId = user.id;

      final updatedRow = await supabase
          .from(table)
          .update({'name': cleanName})
          .eq(idColumn, userId)
          .select('id')
          .maybeSingle();

      // مزامنة الاسم في جدول connects حتى يظهر الاسم الجديد فوراً لدى الطرف الآخر
      final int? numericId = (updatedRow?['id'] as num?)?.toInt();
      if (numericId != null) {
        try {
          if (table == 'merchont') {
            await supabase
                .from('connects')
                .update({'Name_merchont': cleanName})
                .eq('ID_merchont', numericId);
          } else if (table == 'cutomers') {
            await supabase
                .from('connects')
                .update({'Name_customer': cleanName})
                .eq('ID_customer', numericId);
          }
        } catch (e) {
          debugPrint('Connects name sync warning: $e');
        }
      }

      emit(EditUserDataSucesses('تم تحديث الاسم بنجاح'));
    } catch (e) {
      debugPrint('editUserData error: $e');
      emit(EditUserDataFalied('تعذر حفظ التعديلات، تحقق من الاتصال'));
    }
  }
}
