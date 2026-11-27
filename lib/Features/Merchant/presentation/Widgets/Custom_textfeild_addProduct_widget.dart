import 'package:flutter/material.dart';

class CustomTextFeildAddProduct extends StatelessWidget {
  const CustomTextFeildAddProduct({
    super.key,
    required this.hintText,
    this.icon,
    this.isNumber = false,
    this.maxLines = 1,
    this.textDirection,
    required this.data,
  });

  final String hintText;
  final IconData? icon;
  final bool isNumber;
  final int? maxLines;
  final TextDirection? textDirection;
  final TextEditingController data;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: data,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLines: maxLines,
      textDirection: textDirection,
      style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF1A1C1C)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: const Color(0xFF3B4A3D).withValues(alpha: 0.5),
          fontFamily: 'Cairo',
        ),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: const Color(0xFF0fa30f).withValues(alpha: 0.8),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF19e619), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
