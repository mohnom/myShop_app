import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:myshop/Features/Auth/presentation/Widgets/build_header_image_widget.dart';
import 'package:myshop/Features/Auth/presentation/Widgets/input_feild_widget.dart';
import 'package:myshop/Features/Auth/presentation/Widgets/role_card_widget.dart';
import 'package:myshop/Features/Auth/presentation/bloc/SignUp_cubit/sign_up_cubit_cubit.dart';
import 'package:myshop/Features/Auth/presentation/bloc/SignUp_cubit/sign_up_cubit_state.dart';
import 'package:myshop/core/Widgets/Custom_snakbar_widget.dart';
import 'package:myshop/core/Widgets/Cutom_Loading_void.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  String _role = 'merchant';
  final GlobalKey<FormState> signUp = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context, String role) {
    if (signUp.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<SignUpCubitCubit>().signUpUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: role,
      );
    }
  }

  void _showTermsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الشروط والأحكام وسياسة الخصوصية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '• تطبيق «بقالتي» مخصص لتوثيق المعاملات المالية والديون بين التاجر والزبون بشفافية.\n'
                '• تُحفظ بيانات الحساب والفواتير بشكل مشفّر وآمن ولا تتم مشاركتها مع أي طرف ثالث.\n'
                '• يحق للمستخدم طلب حذف حسابه في أي وقت من شاشة الإعدادات شريطة تصفية المديونيات القائمة.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: Colors.black87,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF37ec13),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'موافق',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF37ec13);

    return BlocProvider(
      create: (context) => SignUpCubitCubit(),
      child: Builder(
        builder: (context) {
          return BlocListener<SignUpCubitCubit, SignUpCubitState>(
            listener: (context, state) {
              if (state is SignUpCubitLoading) {
                showLoadingDialog(context);
              } else if (state is SignUpDirectLoginSuccess) {
                Navigator.of(context, rootNavigator: true).pop();
                showSnackBar(
                  context,
                  'مبروك!',
                  state.message,
                  ContentType.success,
                );
                if (state.role == 'merchant') {
                  context.go('/homeMerchontView');
                } else {
                  context.go('/homeCustomerView');
                }
              } else if (state is SignUpCubitSucsess) {
                Navigator.of(context, rootNavigator: true).pop();
                showSnackBar(
                  context,
                  'مبروك',
                  state.message,
                  ContentType.success,
                );
                context.go('/loginView');
              } else if (state is SignUpCubitFailure) {
                Navigator.of(context, rootNavigator: true).pop();
                showSnackBar(
                  context,
                  'تنبيه',
                  state.error,
                  ContentType.failure,
                );
              }
            },
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    onPressed: () => context.go('/loginView'),
                    icon: const FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 24,
                      color: Colors.black87,
                    ),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: signUp,
                    child: Column(
                      children: [
                        const BuildHeaderImageWidget(),
                        const Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'اختر نوع حسابك وابدأ فوراً بدون تعقيد',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            RoleCardWidget(
                              title: 'تاجر (بقالة)',
                              icon: Icons.storefront,
                              selected: _role == 'merchant',
                              onTap: () => setState(() => _role = 'merchant'),
                              primary: primary,
                            ),
                            const SizedBox(width: 16),
                            RoleCardWidget(
                              title: 'زبون',
                              icon: Icons.person,
                              selected: _role == 'customer',
                              onTap: () => setState(() => _role = 'customer'),
                              primary: primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        InputField(
                          control: _nameController,
                          label: _role == 'customer'
                              ? 'الاسم الكامل'
                              : 'اسم البقالة / المتجر',
                          hint: _role == 'customer'
                              ? 'أدخل اسمك الكامل'
                              : 'أدخل اسم بقالتك',
                          icon: Icons.badge_outlined,
                          validatorid: 2,
                        ),
                        const SizedBox(height: 16),
                        InputField(
                          control: _emailController,
                          label: 'البريد الإلكتروني',
                          hint: 'example@mail.com',
                          icon: Icons.mail_outline,
                          validatorid: 1,
                        ),
                        const SizedBox(height: 16),
                        InputField(
                          control: _passwordController,
                          label: 'كلمة المرور',
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          isPass: true,
                          validatorid: 0,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _submitForm(context, _role),
                            child: const Text(
                              'إنشاء الحساب والدخول مباشرة',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => _showTermsSheet(context),
                          child: const Text(
                            'بالتسجيل أنت توافق على الشروط والأحكام وسياسة الخصوصية',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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
}
