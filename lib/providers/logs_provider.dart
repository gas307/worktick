import 'package:flutter/foundation.dart';
import '../data/models/work_log.dart';
import '../data/repositories/worklog_repository.dart';

class LogsProvider extends ChangeNotifier {
  final _repo = WorklogRepository();
  List<WorkLog> logs = [];

  void bind(String uid) {
    _repo.watchLogs(uid).listen((l) {
      logs = l;
      notifyListeners();
    });
  }
}
