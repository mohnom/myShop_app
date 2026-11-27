import 'package:flutter/material.dart';
import 'package:myshop/core/services/notification_service.dart';

class NotificationToggleWidget extends StatefulWidget {
  const NotificationToggleWidget({
    super.key,
    required this.primaryColor,
  });

  final Color primaryColor;

  @override
  State<NotificationToggleWidget> createState() =>
      _NotificationToggleWidgetState();
}

class _NotificationToggleWidgetState extends State<NotificationToggleWidget> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.isNotificationsEnabled().then((val) {
      if (mounted) setState(() => _enabled = val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: widget.primaryColor),
          const SizedBox(width: 12),
          const Text(
            'تنبيهات وإشعارات العمليات',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Switch(
            value: _enabled,
            activeThumbColor: widget.primaryColor,
            onChanged: (v) async {
              setState(() => _enabled = v);
              await NotificationService.instance.setNotificationsEnabled(v);
            },
          ),
        ],
      ),
    );
  }
}
