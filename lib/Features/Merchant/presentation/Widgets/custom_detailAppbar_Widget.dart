import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDetailAppBarWidget extends StatelessWidget {
  const CustomDetailAppBarWidget({
    super.key,
    required this.primaryGreen,
    required this.name,
    this.onShare,
  });

  final Color primaryGreen;
  final String name;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const FaIcon(
          FontAwesomeIcons.chevronRight,
          color: Colors.black87,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          const FaIcon(
            FontAwesomeIcons.user,
            color: Color(0xFF0fa30f),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (onShare != null)
          IconButton(
            onPressed: onShare,
            tooltip: 'مشاركة كشف الحساب عبر واتساب',
            icon: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Color(0xFF25D366),
              size: 22,
            ),
          ),
      ],
    );
  }
}
