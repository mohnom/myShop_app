import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:myshop/Features/Customer/presentation/bloc/show_customer_data/show_customerdata_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/custom_header_setting_widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/custom_textFeild_editData.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/logout_button_widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/notification_toggle_widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/setting_group_widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/settting_tile_widget.dart';
import 'package:myshop/core/Widgets/custom_loading_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerSettingsView extends StatefulWidget {
  const CustomerSettingsView({super.key});

  @override
  State<CustomerSettingsView> createState() => _CustomerSettingsViewState();
}

class _CustomerSettingsViewState extends State<CustomerSettingsView> {
  final String? userId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ShowCustomerdataCubit>().getUserDataById(userId);
      }
    });
  }

  String _formatDate(dynamic date) {
    if (date == null) return '..';
    final s = date.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0fa30f);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9F9),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'الإعدادات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 24,
              color: primaryColor,
            ),
            onPressed: () => context.go('/homeCustomerView'),
          ),
        ),
        body: BlocBuilder<ShowCustomerdataCubit, ShowCustomerdataState>(
          builder: (context, state) {
            if (state is ShowCustomerdataLoading) {
              return const Center(child: CustomLoadingWidget());
            }

            if (state is ShowCustomerdataSucsess) {
              final data = state.message;
              final customerName = data['name']?.toString() ?? 'العميل';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CustomHeaderSettings(
                      primaryColor: primaryColor,
                      name: customerName,
                      icon: const FaIcon(
                        FontAwesomeIcons.user,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SettingsGroupWidget(
                      tiles: [
                        SettingTile(
                          action: () async {
                            final cubit = context.read<ShowCustomerdataCubit>();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomTextFeildToEditData(
                                  hint: 'تعديل الاسم الكامل',
                                  icon: Icons.person_outline,
                                  lexayData: customerName,
                                  table: 'cutomers',
                                  idColumn: 'customers_id_fkey',
                                ),
                              ),
                            );
                            if (mounted) {
                              cubit.getUserDataById(userId);
                            }
                          },
                          icon: Icons.edit_outlined,
                          title: customerName,
                          trailingLabel: 'تعديل',
                          primaryColor: primaryColor,
                        ),
                        SettingTile(
                          action: () {},
                          icon: Icons.date_range_outlined,
                          title:
                              'تاريخ الانضمام: ${_formatDate(data['created_at'])}',
                          primaryColor: primaryColor,
                        ),
                        SettingTile(
                          action: () {},
                          icon: Icons.mail_outline,
                          title: data['email']?.toString() ?? '..',
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const NotificationToggleWidget(primaryColor: primaryColor),
                    const SizedBox(height: 28),
                    const LogoutButtonWidget(isMerchant: false),
                  ],
                ),
              );
            }

            if (state is ShowCustomerdataFailed) {
              return Center(child: Text(state.error));
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
