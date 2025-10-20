import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String uid;
  final String? email;
  final String? displayName;
  final bool active;
  final DateTime? activeStart;
  final String? activeWorkType; // office | remote | field
  final String? activeNote;
  final DateTime? updatedAt;

  Profile({
    required this.uid,
    this.email,
    this.displayName,
    this.active = false,
    this.activeStart,
    this.activeWorkType,
    this.activeNote,
    this.updatedAt,
  });

  factory Profile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Profile(
      uid: doc.id,
      email: d['email'] as String?,
      displayName: d['displayName'] as String?,
      active: (d['active'] as bool?) ?? false,
      activeStart: (d['activeStart'] as Timestamp?)?.toDate(),
      activeWorkType: d['activeWorkType'] as String?,
      activeNote: d['activeNote'] as String?,
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
