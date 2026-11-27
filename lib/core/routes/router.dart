import 'package:go_router/go_router.dart';
import 'package:myshop/Features/Auth/presentation/Views/login_view.dart';
import 'package:myshop/Features/Auth/presentation/Views/reset_password_view.dart';
import 'package:myshop/Features/Auth/presentation/Views/sign_up_view.dart';
import 'package:myshop/Features/Auth/presentation/Views/splash_view.dart';
import 'package:myshop/Features/Auth/presentation/Views/update_password_view.dart';
import 'package:myshop/Features/Customer/presentation/Views/customer_settings_view.dart';
import 'package:myshop/Features/Customer/presentation/Views/details_of_items_view.dart';
import 'package:myshop/Features/Customer/presentation/Views/home_customer_view.dart';
import 'package:myshop/Features/Merchant/presentation/Views/home_merchant_view.dart';
import 'package:myshop/Features/Merchant/presentation/Views/settings_view.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashView()),
    GoRoute(path: '/loginView', builder: (context, state) => const LoginView()),
    GoRoute(
      path: '/signUpView',
      builder: (context, state) => const SignUpView(),
    ),
    GoRoute(
      path: '/resetPasswordView',
      builder: (context, state) => const ForgotPasswordView(),
    ),
    GoRoute(
      path: '/updatePasswordView',
      builder: (context, state) => const UpdatePasswordView(),
    ),
    GoRoute(
      path: '/homeCustomerView',
      builder: (context, state) => const HomeCustomerView(),
    ),
    GoRoute(
      path: '/homeMerchontView',
      builder: (context, state) => const HomeMerchantView(),
    ),
    GoRoute(
      path: '/detailsItemsView',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return DetailsItemsView(
          conectId: (extra?['conectId'] as num?)?.toInt() ?? 0,
          merchantName: (extra?['merchantName'] as String?) ?? 'المتجر',
        );
      },
    ),
    GoRoute(
      path: '/merchantSettingView',
      builder: (context, state) => const SettingsView(),
    ),
    GoRoute(
      path: '/customerSettingView',
      builder: (context, state) => const CustomerSettingsView(),
    ),
  ],
);
