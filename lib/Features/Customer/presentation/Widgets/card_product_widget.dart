import 'package:flutter/material.dart';

class CardBroductWidget extends StatelessWidget {
  const CardBroductWidget({
    super.key,
    required this.title,
    required this.sub,
    required this.price,
    required this.icon,
    required this.iconBg,
  });

  final String title;
  final String sub;
  final String price;
  final IconData icon;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    final bool isPayment = price.startsWith('-');
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0fa30f)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        sub,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: Text(
        '$price ر.ي',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          fontFamily: 'Tajawal',
          color: isPayment ? const Color(0xFF0fa30f) : Colors.black87,
        ),
      ),
    );
  }
}
