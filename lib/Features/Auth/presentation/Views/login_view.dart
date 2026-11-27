import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myshop/Features/Auth/presentation/Widgets/input_feild_widget.dart';
import 'package:myshop/Features/Auth/presentation/bloc/Login/login_cubit.dart';
import 'package:myshop/core/Widgets/Custom_snakbar_widget.dart';
import 'package:myshop/core/Widgets/Cutom_Loading_void.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> login = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (login.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<LoginCubit>().loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF37ec13);

    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Builder(
        builder: (context) {
          return BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginLoading) {
                showLoadingDialog(context);
              } else if (state is LoginFailure) {
                Navigator.of(context, rootNavigator: true).pop();
                showSnackBar(
                  context,
                  'خطأ في العملية',
                  state.error,
                  ContentType.failure,
                );
              } else if (state is LoginCusomerSucsess) {
                Navigator.of(context, rootNavigator: true).pop();
                showSnackBar(
                  context,
                  'أهلاً بك!',
                  state.massege,
                  ContentType.success,
                );
                context.go('/homeCustomerView');
              } else if (state is LoginMerchontSucsess) {
                Navigator.of(context, rootNavigator: true).pop();
                showSnackBar(
                  context,
                  'أهلاً بك!',
                  state.massege,
                  ContentType.success,
                );
                context.go('/homeMerchontView');
              }
            },
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: login,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          const SizedBox(height: 48),
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              size: 46,
                              color: Color(0xFF0fa30f),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'مرحباً بك في بقالتي',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'سجّل دخولك لإدارة حساباتك وديونك بكل سهولة وشفافية',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 36),
                          InputField(
                            label: 'البريد الإلكتروني',
                            hint: 'example@mail.com',
                            icon: Icons.mail_outline,
                            validatorid: 1,
                            control: _emailController,
                          ),
                          const SizedBox(height: 16),
                          InputField(
                            label: 'كلمة المرور',
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            isPass: true,
                            control: _passwordController,
                            validatorid: 0,
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () => context.go('/resetPasswordView'),
                              child: const Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(
                                  color: Color(0xFF0fa30f),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildButton(
                            context: context,
                            text: 'تسجيل الدخول',
                            color: primaryColor,
                            icon: Icons.login_rounded,
                            isFull: true,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'ليس لديك حساب بعد؟',
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextButton(
                                onPressed: () => context.go('/signUpView'),
                                child: const Text(
                                  'إنشاء حساب جديد',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    IconData? icon,
    bool isFull = false,
    required BuildContext context,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: isFull ? Colors.white : Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isFull
                ? BorderSide.none
                : BorderSide(color: Colors.grey.shade200),
          ),
        ),
        onPressed: () => _submitForm(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (icon != null) ...[const SizedBox(width: 8), Icon(icon)],
          ],
        ),
      ),
    );
  }
}
