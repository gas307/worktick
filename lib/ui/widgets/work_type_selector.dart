import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WorkTypeSelector extends StatelessWidget {
  final String value; // 'office' | 'remote' | 'field'
  final ValueChanged<String> onChanged;

  const WorkTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      items: [
        DropdownMenuItem(value: 'office', child: const Text('app.office').tr()),
        DropdownMenuItem(value: 'remote', child: const Text('app.remote').tr()),
        DropdownMenuItem(value: 'field',  child: const Text('app.field').tr()),
      ],
    );
  }
}
