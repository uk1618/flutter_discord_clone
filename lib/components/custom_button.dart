import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';

class CmButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const CmButton({super.key, this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    CustomColors _customColors = CustomColors();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: _customColors.dcBlue,
            borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
