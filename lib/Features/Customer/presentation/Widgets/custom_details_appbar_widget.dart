import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myshop/Features/Customer/presentation/bloc/delete_merchant/delete_merchant_cubit.dart';
import 'package:myshop/core/Widgets/Custom_snakbar_widget.dart';

class CustomDetailAppbarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomDetailAppbarWidget({
    super.key,
    required this.conectId,
    this.merchantName = '',
  });

  final int conectId;
  final String merchantName;

  void _confirmUnlink(BuildContext context) {
    final deleteCubit = context.read<DeleteMerchantCubit>();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'فك الارتباط بالمتجر',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل ترغب في إزالة «${merchantName.isEmpty ? "هذا المتجر" : merchantName}» من قائمتك؟\n'
            'ملاحظة: لا يمكن إزالة المتجر إلا إذا كان رصيد المديونية المتبقي صفراً.',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                deleteCubit.deleteMerchant(conectId);
              },
              child: const Text('تأكيد الإزالة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const FaIcon(
          FontAwesomeIcons.chevronRight,
          color: Colors.black87,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: const Text(
        'تفاصيل كشف الحساب',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        BlocConsumer<DeleteMerchantCubit, DeleteMerchantState>(
          listener: (context, state) {
            if (state is DeleteMerchantFailed) {
              showSnackBar(
                context,
                'تعذر الحذف',
                state.error,
                ContentType.failure,
              );
            } else if (state is DeleteMerchantSuccess) {
              showSnackBar(
                context,
                'تمت الإزالة',
                'تم فك الارتباط بالمتجر بنجاح',
                ContentType.success,
              );
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          },
          builder: (context, state) {
            if (state is DeleteMerchantLoading) {
              return const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Color(0xFF0fa30f),
                  ),
                ),
              );
            }

            return IconButton(
              tooltip: 'إزالة المتجر (عند تصفير الحساب)',
              icon: const Icon(
                Icons.link_off_rounded,
                color: Color(0xFFe11d48),
              ),
              onPressed: () => _confirmUnlink(context),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
