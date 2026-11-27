import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myshop/Features/Auth/presentation/Widgets/input_feild_widget.dart';
import 'package:myshop/core/Widgets/Custom_snakbar_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// شاشة تعيين كلمة المرور الجديدة بعد فتح رابط الاستعادة العميق (Deep Link)
class UpdatePasswordView extends StatefulWidget {
  const UpdatePasswordView({super.key});

  @override
  State<UpdatePasswordView> createState() => _UpdatePasswordViewState();
}

class _UpdatePasswordViewState extends State<UpdatePasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_passwordController.text != _confirmController.text) {
      showSnackBar(
        context,
        'تنبيه',
        'كلمتا المرور غير متطابقتين',
        ContentType.warning,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );
      if (!mounted) return;
      showSnackBar(
        context,
        'تم التحديث',
        'تم تغيير كلمة المرور بنجاح، يمكنك تسجيل الدخول الآن',
        ContentType.success,
      );
      context.go('/loginView');
    } on AuthException catch (e) {
      if (!mounted) return;
      showSnackBar(context, 'خطأ', e.message, ContentType.failure);
    } catch (_) {
      if (!mounted) return;
      showSnackBar(
        context,
        'خطأ',
        'تعذر تحديث كلمة المرور، حاول مجدداً',
        ContentType.failure,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF37ec13);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تعيين كلمة مرور جديدة'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أدخل كلمة المرور الجديدة لحسابك في بقالتي',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                const SizedBox(height: 24),
                InputField(
                  label: 'كلمة المرور الجديدة',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  isPass: true,
                  validatorid: 0,
                  control: _passwordController,
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'تأكيد كلمة المرور الجديدة',
                  hint: '••••••••',
                  icon: Icons.lock_reset_outlined,
                  isPass: true,
                  validatorid: 0,
                  control: _confirmController,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSaving ? null : _updatePassword,
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'حفظ كلمة المرور الجديدة',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
