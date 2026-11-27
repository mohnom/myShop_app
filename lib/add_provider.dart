import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Auth/presentation/bloc/Forget_Password/forgot_password_cubit.dart';
import 'package:myshop/Features/Auth/presentation/bloc/Login/login_cubit.dart';
import 'package:myshop/Features/Auth/presentation/bloc/SignUp_cubit/sign_up_cubit_cubit.dart';
import 'package:myshop/Features/Customer/presentation/bloc/add_merchant/add_merchant_cubit.dart';
import 'package:myshop/Features/Customer/presentation/bloc/delete_merchant/delete_merchant_cubit.dart';
import 'package:myshop/Features/Customer/presentation/bloc/show_customer_data/show_customerdata_cubit.dart';
import 'package:myshop/Features/Customer/presentation/bloc/show_customer_purchases/show_customer_purchases_cubit.dart';
import 'package:myshop/Features/Customer/presentation/bloc/show_merchonts/show_merchonts_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/Add_Debt/add_debt_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/Edit_userData/edit_user_data_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/LogOut/log_out_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/delete_purchase/delete_purchase_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/make_payment/make_payment_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/show_customers/show_customers_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/show_merchant_data/show_merchantdata_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/show_purchases/show_purchases_cubit.dart';

class AddProvider {
  static List<BlocProvider> get allProviders => [
    // ── Auth ──────────────────────────────────────
    BlocProvider<SignUpCubitCubit>(
      create: (BuildContext context) => SignUpCubitCubit(),
    ),
    BlocProvider<LoginCubit>(
      create: (BuildContext context) => LoginCubit(),
    ),
    BlocProvider<ForgotPasswordCubit>(
      create: (BuildContext context) => ForgotPasswordCubit(),
    ),

    // ── Merchant ──────────────────────────────────
    BlocProvider<EditUserDataCubit>(
      create: (BuildContext context) => EditUserDataCubit(),
    ),
    BlocProvider<LogOutCubit>(
      create: (BuildContext context) => LogOutCubit(),
    ),
    BlocProvider<ShowMerchantdataCubit>(
      create: (BuildContext context) => ShowMerchantdataCubit(),
    ),
    BlocProvider<ShowCustomersCubit>(
      create: (BuildContext context) => ShowCustomersCubit(),
    ),
    BlocProvider<AddDebtCubit>(
      create: (BuildContext context) => AddDebtCubit(),
    ),
    BlocProvider<ShowPurchasesCubit>(
      create: (BuildContext context) => ShowPurchasesCubit(),
    ),
    BlocProvider<DeletePurchaseCubit>(
      create: (BuildContext context) => DeletePurchaseCubit(),
    ),
    BlocProvider<MakePaymentCubit>(
      create: (BuildContext context) => MakePaymentCubit(),
    ),

    // ── Customer ──────────────────────────────────
    BlocProvider<ShowCustomerdataCubit>(
      create: (BuildContext context) => ShowCustomerdataCubit(),
    ),
    BlocProvider<AddMerchantCubit>(
      create: (BuildContext context) => AddMerchantCubit(),
    ),
    BlocProvider<ShowMerchontsCubit>(
      create: (BuildContext context) => ShowMerchontsCubit(),
    ),
    BlocProvider<ShowCustomerPurchasesCubit>(
      create: (BuildContext context) => ShowCustomerPurchasesCubit(),
    ),
    BlocProvider<DeleteMerchantCubit>(
      create: (BuildContext context) => DeleteMerchantCubit(),
    ),
  ];
}
