import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/custom_header_setting_widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/custom_setting_appbar_widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/custom_textFeild_editData.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/logout_button_widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/notification_toggle_widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/setting_group_widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/settting_tile_widget.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/show_merchant_data/show_merchantdata_cubit.dart';
import 'package:myshop/core/Widgets/custom_loading_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final String? userId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ShowMerchantdataCubit>().getUserDataById(userId);
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
        appBar: CustomSettingAppbar(
          contexts: context,
          primaryColor: primaryColor,
        ),
        body: BlocBuilder<ShowMerchantdataCubit, ShowMerchantdataState>(
          builder: (BuildContext context, state) {
            if (state is ShowMerchantdataLoading) {
              return const Center(child: CustomLoadingWidget());
            }

            if (state is ShowMerchantdataSucsess) {
              final data = state.message;
              final storeName = data['name']?.toString() ?? 'المتجر';
              final storeId = data['id']?.toString() ?? '';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CustomHeaderSettings(
                      icon: const FaIcon(
                        FontAwesomeIcons.store,
                        color: Colors.white,
                        size: 28,
                      ),
                      primaryColor: primaryColor,
                      name: storeName,
                    ),
                    const SizedBox(height: 28),
                    SettingsGroupWidget(
                      tiles: [
                        SettingTile(
                          action: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomTextFeildToEditData(
                                  hint: 'تعديل اسم المتجر',
                                  icon: Icons.storefront_outlined,
                                  lexayData: storeName,
                                  table: 'merchont',
                                  idColumn: 'maerchont_id_fkey',
                                ),
                              ),
                            );
                            if (context.mounted) {
                              context
                                  .read<ShowMerchantdataCubit>()
                                  .getUserDataById(userId);
                            }
                          },
                          icon: Icons.edit_outlined,
                          title: storeName,
                          trailingLabel: 'تعديل',
                          primaryColor: primaryColor,
                        ),
                        SettingTile(
                          action: () {
                            Clipboard.setData(ClipboardData(text: storeId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم نسخ الرقم التعريفي (#$storeId)',
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                                backgroundColor: primaryColor,
                              ),
                            );
                          },
                          icon: Icons.tag_rounded,
                          title: 'الرقم التعريفي للمتجر: #$storeId',
                          trailingLabel: 'نسخ',
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
                    const LogoutButtonWidget(isMerchant: true),
                  ],
                ),
              );
            }

            if (state is ShowMerchantdataFailed) {
              return Center(child: Text(state.error));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
