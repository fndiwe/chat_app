import 'dart:math';
import 'package:flutter/material.dart';

class RotatedSendButton extends StatelessWidget {
  const RotatedSendButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
        angle: -pi / 5, child: Icon(Icons.send_rounded));
  }
}
