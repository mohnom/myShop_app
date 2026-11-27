import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CustomAppbarCusotmerWidget extends StatelessWidget {
  const CustomAppbarCusotmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFffffff),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF13ec13).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: Color(0xFF0fa30f),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'متاجري',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111811),
                    ),
                  ),
                  Text(
                    'متابعة الديون والمشتريات والمدفوعات لحظياً',
                    style: TextStyle(fontSize: 12, color: Color(0xFF618961)),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.gear,
              color: Color(0xFF0fa30f),
              size: 20,
            ),
            onPressed: () => context.go('/customerSettingView'),
          ),
        ],
      ),
    );
  }
}
