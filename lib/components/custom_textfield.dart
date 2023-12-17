import 'package:flutter/material.dart';

import '../constants/custom_color.dart';

class CmTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  const CmTextField(
      {super.key, this.controller, this.hintText, required this.obscureText});

  @override
  Widget build(BuildContext context) {
    CustomColors _customColors = CustomColors();
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          hintText: hintText,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: _customColors.dcGrey),
    );
  }
}
