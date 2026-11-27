import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BuildHeaderImageWidget extends StatelessWidget {
  const BuildHeaderImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: Center(
        child: const FaIcon(
          FontAwesomeIcons.userPlus,
          size: 66,
          color: Color(0xFF37ec13),
        ),
      ),
    );
  }
}
