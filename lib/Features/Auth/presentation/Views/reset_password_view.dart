import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:myshop/Features/Auth/presentation/Widgets/input_feild_widget.dart';
import 'package:myshop/Features/Auth/presentation/bloc/Forget_Password/forgot_password_cubit.dart';
import 'package:myshop/core/Widgets/Custom_snakbar_widget.dart';
import 'package:myshop/core/Widgets/Cutom_Loading_void.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<ForgotPasswordCubit>().sendResetEmail(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF37ec13);

    return BlocProvider(
      create: (context) => ForgotPasswordCubit(),
      child: Builder(
        builder: (context) {
          return BlocListener<ForgotPasswordCubit, ResetPasswordState>(
            listener: (context, state) {
              if (state is ResetPasswordLoading) {
                showLoadingDialog(context);
              } else if (state is ResetPasswordFailure) {
                Navigator.of(context, rootNavigator: true).pop();
                showSnackBar(
                  context,
                  'خطأ في العملية',
                  state.error,
                  ContentType.failure,
                );
              } else if (state is ResetPasswordSuccess) {
                Navigator.of(context, rootNavigator: true).pop();
                showSnackBar(
                  context,
                  'تم الإرسال',
                  state.message,
                  ContentType.success,
                );
              }
            },
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => context.go('/loginView'),
                    icon: const FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 24,
                      color: Colors.black87,
                    ),
                  ),
                ),
                body: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Form(
                                key: _formKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 96,
                                        height: 96,
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(
                                            alpha: 0.2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.lock_reset_rounded,
                                          color: primaryColor,
                                          size: 48,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    const Text(
                                      'نسيت كلمة المرور',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'أدخل بريدك الإلكتروني وسنرسل لك رابطاً آمناً لاستعادة كلمة المرور الخاصة بك',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    InputField(
                                      control: _emailController,
                                      label: 'البريد الإلكتروني',
                                      hint: 'example@mail.com',
                                      icon: Icons.mail_outline,
                                      validatorid: 1,
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: () => submit(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 2,
                                          shadowColor: primaryColor.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                        child: const Text(
                                          'إرسال الرابط',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24.0,
                                      ),
                                      child: Center(
                                        child: TextButton.icon(
                                          onPressed: () =>
                                              context.go('/loginView'),
                                          icon: const Icon(
                                            Icons.login,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                          label: const Text(
                                            'العودة لتسجيل الدخول',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Opacity(
                                      opacity: 0.4,
                                      child: Center(
                                        child: Text(
                                          'Baqalati • بقالتي',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
