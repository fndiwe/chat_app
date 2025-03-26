import 'package:flutter/material.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 25,
        width: 25,
        child: CircularProgressIndicator.adaptive(
          strokeCap: StrokeCap.round,
          valueColor:
              AlwaysStoppedAnimation(Theme.of(context).colorScheme.onSurface),
        ));
  }
}
