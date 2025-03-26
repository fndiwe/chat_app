import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField(
      {super.key,
      this.hintText,
      required this.obscureText,
      required this.controller,
      this.prefixIcon,
      this.suffixIcon,
      this.otherValidators, this.textCapitalization, this.labelText, this.isBio = false});

  final String? hintText;
  final bool obscureText;
  final TextEditingController controller;
  final String? labelText;
  final bool isBio;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextCapitalization? textCapitalization;
  final String? Function(String?)? otherValidators;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) => (value == null || value.isEmpty)
          ? "Please fill this field"
          : otherValidators?.call(value),
      controller: controller,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      maxLength: isBio ? 100 : null,
      maxLines: isBio ? 3 : 1,
      textCapitalization: labelText != null ? TextCapitalization.sentences : textCapitalization ?? TextCapitalization.none,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
