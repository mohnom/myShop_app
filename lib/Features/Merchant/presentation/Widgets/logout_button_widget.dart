import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/LogOut/log_out_cubit.dart';
import 'package:myshop/core/Widgets/Custom_snakbar_widget.dart';
import 'package:myshop/core/Widgets/Cutom_Loading_void.dart';

class LogoutButtonWidget extends StatefulWidget {
  const LogoutButtonWidget({super.key, this.isMerchant = true});

  final bool isMerchant;

  @override
  State<LogoutButtonWidget> createState() => _LogoutButtonWidgetState();
}

class _LogoutButtonWidgetState extends State<LogoutButtonWidget> {
  bool _loadingShown = false;

  void _confirmLogout(BuildContext context) {
    final cubit = context.read<LogOutCubit>();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'تسجيل الخروج',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF93000A),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                cubit.logOutMethod();
              },
              child: const Text('خروج'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    final cubit = context.read<LogOutCubit>();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'حذف الحساب نهائياً',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF93000A),
              fontFamily: 'Cairo',
            ),
          ),
          content: const Text(
            'سيتم حذف بيانات ملفك الشخصي من التطبيق شريطة عدم وجود مديونيات قائمة غير مسددة. هل تريد المتابعة؟',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('تراجع', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                cubit.deleteAccountMethod(isMerchant: widget.isMerchant);
              },
              child: const Text('تأكيد الحذف'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LogOutCubit(),
      child: Builder(
        builder: (context) {
          return BlocListener<LogOutCubit, LogOutState>(
            listener: (context, state) {
              if (state is LogOutLoading) {
                _loadingShown = true;
                showLoadingDialog(context);
              } else if (state is LogOutSucesses) {
                if (_loadingShown) {
                  Navigator.of(context, rootNavigator: true).pop();
                  _loadingShown = false;
                }
                showSnackBar(
                  context,
                  'تمت العملية',
                  state.message,
                  ContentType.success,
                );
                context.go('/loginView');
              } else if (state is LogOutFailed) {
                if (_loadingShown) {
                  Navigator.of(context, rootNavigator: true).pop();
                  _loadingShown = false;
                }
                showSnackBar(
                  context,
                  'تنبيه',
                  state.error,
                  ContentType.failure,
                );
              }
            },
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFDAD6),
                      foregroundColor: const Color(0xFF93000A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _confirmDeleteAccount(context),
                  icon: Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                  label: Text(
                    'حذف الحساب نهائياً',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
