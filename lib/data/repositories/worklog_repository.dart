import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/work_log.dart';

class WorklogRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _logsCol(String uid) =>
      _db.collection('profiles').doc(uid).collection('workLogs');

  Stream<List<WorkLog>> watchLogs(String uid) => _logsCol(uid)
      .orderBy('start', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => WorkLog.fromDoc(d)).toList());

  Future<void> updateLog(String uid, WorkLog log) async {
    await _logsCol(uid).doc(log.id).update(log.toMap());
  }
  Stream<List<WorkLog>> watchLogsForMonth(String uid, int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return FirebaseFirestore.instance
        .collection('profiles').doc(uid).collection('workLogs')
        .where('start', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('start', isLessThan: Timestamp.fromDate(end))
        .orderBy('start')
        .snapshots()
        .map((qs) => qs.docs.map((d) => WorkLog.fromDoc(d)).toList());
  }

  Future<List<WorkLog>> fetchLogsForMonth(String uid, int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final qs = await FirebaseFirestore.instance
        .collection('profiles').doc(uid).collection('workLogs')
        .where('start', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('start', isLessThan: Timestamp.fromDate(end))
        .orderBy('start')
        .get();
    return qs.docs.map((d) => WorkLog.fromDoc(d)).toList();
  }
}
