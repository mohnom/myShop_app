import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Customer/presentation/bloc/add_merchant/add_merchant_cubit.dart';
import 'package:myshop/core/Widgets/Custom_snakbar_widget.dart';
import 'package:myshop/core/Widgets/Cutom_Loading_void.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomDialogAddMerchant extends StatefulWidget {
  const CustomDialogAddMerchant({super.key});

  @override
  State<CustomDialogAddMerchant> createState() =>
      _CustomDialogAddMerchantState();
}

class _CustomDialogAddMerchantState extends State<CustomDialogAddMerchant> {
  final TextEditingController _idController = TextEditingController();
  bool _loadingDialogShown = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _closeLoadingIfOpen() {
    if (_loadingDialogShown && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      _loadingDialogShown = false;
    }
  }

  void _submit(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    context.read<AddMerchantCubit>().addMerchant(
      merchantId: _idController.text,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddMerchantCubit, AddMerchantState>(
      listener: (context, state) {
        if (state is AddMerchantLoading) {
          _loadingDialogShown = true;
          showLoadingDialog(context);
        } else if (state is AddMerchantSuccess) {
          _closeLoadingIfOpen();
          showSnackBar(
            context,
            'تم الربط بنجاح',
            'تمت إضافة المتجر إلى قائمتك بنجاح',
            ContentType.success,
          );
          Navigator.of(context).pop(true);
        } else if (state is AddMerchantFailed) {
          _closeLoadingIfOpen();
          showSnackBar(
            context,
            'تنبيه',
            state.errMessage,
            ContentType.failure,
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'إضافة متجر جديد',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'أدخل الرقم التعريفي الخاص بالمتجر (البقالة):',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _idController,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.tag_rounded, color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF37ec13),
                      width: 2.0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'مثال: 12',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF13ec13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _submit(context),
              child: const Text(
                'إضافة المتجر',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
