import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPass = false,
    this.validatorid,
    required this.control,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final bool isPass;
  final int? validatorid;
  final TextEditingController control;
  final TextInputType? keyboardType;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPass;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.control,
          obscureText: widget.isPass ? _obscure : false,
          keyboardType:
              widget.keyboardType ??
              (widget.validatorid == 1
                  ? TextInputType.emailAddress
                  : TextInputType.text),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(widget.icon, color: Colors.grey),
            suffixIcon: widget.isPass
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF37ec13),
                width: 2.0,
              ),
            ),
          ),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (widget.validatorid == 0) {
              if (trimmed.length < 8) {
                return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
              }
              return null;
            } else if (widget.validatorid == 1) {
              final emailRegex = RegExp(
                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$",
              );
              if (trimmed.isEmpty) {
                return 'الرجاء إدخال البريد الإلكتروني';
              } else if (!emailRegex.hasMatch(trimmed)) {
                return 'الرجاء إدخال بريد إلكتروني صحيح';
              }
              return null;
            } else if (widget.validatorid == 2) {
              if (trimmed.length < 2) {
                return 'الرجاء إدخال الاسم بشكل صحيح';
              }
              return null;
            }
            return null;
          },
        ),
      ],
    );
  }
}
