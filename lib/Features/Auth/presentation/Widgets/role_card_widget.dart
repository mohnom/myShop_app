import 'package:flutter/material.dart';

class RoleCardWidget extends StatelessWidget {
  const RoleCardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.primary,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? primary : Colors.grey.shade200,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? primary : Colors.grey, size: 28),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? const Color(0xFF0fa30f) : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
