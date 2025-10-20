import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../data/models/work_log.dart';
import '../../../core/utils/time_utils.dart';

class EditLogDialog extends StatefulWidget {
  final WorkLog initial;
  const EditLogDialog({super.key, required this.initial});

  @override
  State<EditLogDialog> createState() => _EditLogDialogState();
}

class _EditLogDialogState extends State<EditLogDialog> {
  late DateTime start;
  late DateTime end;
  late String workType;
  late TextEditingController note;

  @override
  void initState() {
    super.initState();
    start = widget.initial.start;
    end = widget.initial.end;
    workType = widget.initial.workType;
    note = TextEditingController(text: widget.initial.note ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final diffMinutes = end.difference(start).inMinutes;

    return AlertDialog(
      title: Text('app.edit'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DTField(
              label: 'Start',
              value: start,
              onPick: (v) => setState(() => start = v),
            ),
            _DTField(
              label: 'End',
              value: end,
              onPick: (v) => setState(() => end = v),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${'app.duration'.tr()}: ${formatDurationHM(diffMinutes)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: workType,
              onChanged: (v) => setState(() => workType = v ?? 'office'),
              items: [
                DropdownMenuItem(value: 'office', child: const Text('app.office').tr()),
                DropdownMenuItem(value: 'remote', child: const Text('app.remote').tr()),
                DropdownMenuItem(value: 'field',  child: const Text('app.field').tr()),
              ],
              decoration: InputDecoration(labelText: 'app.workType'.tr()),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: note,
              decoration: InputDecoration(labelText: 'app.note'.tr()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('app.cancel'.tr()),
        ),
        FilledButton(
          onPressed: () {
            if (end.isBefore(start)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('app.invalidTimeRange'.tr())),
              );
              return;
            }
            final minutes = end.difference(start).inMinutes;
            final updated = WorkLog(
              id: widget.initial.id,
              start: start,
              end: end,
              minutes: minutes,
              workType: workType,
              note: note.text.trim().isEmpty ? null : note.text.trim(),
            );
            Navigator.pop(context, updated);
          },
          child: Text('app.save'.tr()),
        ),
      ],
    );
  }
}

class _DTField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPick;
  const _DTField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${DateFormat.yMMMd().format(value)} ${DateFormat.Hm().format(value)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label: $formatted',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDate: value,
              );
              if (date == null) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(value),
              );
              if (time == null) return;
              onPick(DateTime(date.year, date.month, date.day, time.hour, time.minute));
            },
            child: Text('app.change'.tr()),
          ),
        ],
      ),
    );
  }
}
