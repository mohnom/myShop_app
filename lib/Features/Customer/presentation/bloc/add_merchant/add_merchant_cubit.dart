import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'add_merchant_state.dart';

class AddMerchantCubit extends Cubit<AddMerchantState> {
  AddMerchantCubit() : super(AddMerchantInitial());

  Future<void> addMerchant({
    required String merchantId,
    required String userId,
  }) async {
    emit(AddMerchantLoading());
    try {
      final cleaned = merchantId.trim().replaceAll('#', '');
      if (cleaned.isEmpty) {
        emit(AddMerchantFailed('يرجى إدخال الرقم التعريفي للتاجر'));
        return;
      }

      final int? parsedMerchantId = int.tryParse(cleaned);
      if (parsedMerchantId == null || parsedMerchantId <= 0) {
        emit(AddMerchantFailed('يرجى إدخال رقم تعريفي صحيح بالأرقام فقط'));
        return;
      }

      final supabase = Supabase.instance.client;
      final responseCustomer = await supabase
          .from('cutomers')
          .select('id,name')
          .eq('customers_id_fkey', userId)
          .maybeSingle();

      if (responseCustomer == null) {
        emit(AddMerchantFailed('لم يتم العثور على بيانات حسابك'));
        return;
      }

      final responseMerchant = await supabase
          .from('merchont')
          .select('name')
          .eq('id', parsedMerchantId)
          .maybeSingle();

      if (responseMerchant == null) {
        emit(
          AddMerchantFailed(
            'لا يوجد متجر بهذا الرقم التعريفي (#$parsedMerchantId)',
          ),
        );
        return;
      }

      final existingConnection = await supabase
          .from('connects')
          .select('id')
          .eq('ID_customer', responseCustomer['id'])
          .eq('ID_merchont', parsedMerchantId)
          .maybeSingle();

      if (existingConnection != null) {
        emit(AddMerchantFailed('هذا المتجر مضاف مسبقاً في قائمتك'));
        return;
      }

      await supabase.from('connects').insert({
        'Name_merchont': responseMerchant['name'],
        'Name_customer': responseCustomer['name'],
        'ID_customer': responseCustomer['id'],
        'ID_merchont': parsedMerchantId,
      });

      emit(AddMerchantSuccess());
    } catch (e) {
      debugPrint('addMerchant error: $e');
      emit(AddMerchantFailed('تعذر إضافة المتجر، تحقق من اتصال الإنترنت'));
    }
  }
}
