import 'package:flutter/material.dart';
import '../my_logs/my_logs_body.dart';

class AdminUserLogsPage extends StatelessWidget {
  final String uid;
  final String? title; // np. nazwa/Email użytkownika do AppBar

  const AdminUserLogsPage({
    super.key,
    required this.uid,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // domyślna strzałka „back” pojawi się automatycznie
        title: Text(title ?? 'Logs'),
      ),
      body: MyLogsBody(forUid: uid),
    );
  }
}
