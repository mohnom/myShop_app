import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';


class CustomSettingAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomSettingAppbar({
    super.key,
    required this.contexts,
    required this.primaryColor,
  });

  final BuildContext contexts;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9F9),
      elevation: 0,
      centerTitle: true,
      title: Text(
        'الإعدادات',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: primaryColor,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        icon: FaIcon(
          FontAwesomeIcons.chevronRight, // This is the "Cool" sleek back icon
          size: 28,
          color: primaryColor,
        ),
        onPressed: () => context.go('/homeMerchontView'),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
