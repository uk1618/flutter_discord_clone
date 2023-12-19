import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    CustomColors _customColors = CustomColors();
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration:  BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _customColors.dcGreen,
      ),
      child: Text(message,
      style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
