import 'package:cloud_firestore/cloud_firestore.dart';

class WorkLog {
  final String id;
  final DateTime start;
  final DateTime end;
  final int minutes;
  final String workType; // office | remote | field
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkLog({
    required this.id,
    required this.start,
    required this.end,
    required this.minutes,
    required this.workType,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return WorkLog(
      id: doc.id,
      start: (d['start'] as Timestamp).toDate(),
      end: (d['end'] as Timestamp).toDate(),
      minutes: (d['minutes'] as num).toInt(),
      workType: d['workType'] as String? ?? 'office',
      note: d['note'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'start': Timestamp.fromDate(start),
    'end': Timestamp.fromDate(end),
    'minutes': minutes,
    'workType': workType,
    'note': note,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
