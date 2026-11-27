import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.primaryColor,
    this.trailingLabel,
    required this.action,
    this.id = 10,
  });

  final VoidCallback action;
  final IconData icon;
  final String title;
  final Color primaryColor;
  final String? trailingLabel;
  final int id;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingLabel != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                trailingLabel!,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
      onTap: action,
    );
  }
}
