import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../data/models/work_log.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/utils/i18n_utils.dart';

class WorkLogTile extends StatelessWidget {
  final WorkLog log;
  final VoidCallback? onEdit;
  final bool canEdit;

  const WorkLogTile({
    super.key,
    required this.log,
    this.onEdit,
    this.canEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final range = formatTimeRange(log.start, log.end);
    final duration = formatDurationHM(log.minutes);
    final workTypeLabel = trWorkType(log.workType);

    return ListTile(
      title: Text('$range · $duration'),
      subtitle: Text(
        '${DateFormat.yMMMd().format(log.start)} · $workTypeLabel'
        '${log.note != null && log.note!.isNotEmpty ? ' · ${log.note}' : ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: canEdit
          ? IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'app.edit'.tr(),
              onPressed: onEdit,
            )
          : null,
    );
  }
}
