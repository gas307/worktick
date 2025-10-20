import 'package:flutter/material.dart';

class ActiveDot extends StatelessWidget {
  final bool active;
  const ActiveDot({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.circle,
      size: 14,
      color: active ? Colors.green : Theme.of(context).disabledColor,
    );
  }
}
