
import 'package:flutter/material.dart';

class SettingsGroupWidget extends StatelessWidget {
  const SettingsGroupWidget({
    super.key,
    required this.tiles,
  });

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: tiles),
    );
  }
}
