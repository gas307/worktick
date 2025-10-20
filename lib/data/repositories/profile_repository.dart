import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile.dart';
class ProfileRepository {
  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> profileRef(String uid) =>
      _db.collection('profiles').doc(uid);

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile(String uid) =>
      profileRef(uid).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAllProfiles() =>
      _db
          .collection('profiles')
          .orderBy('updatedAt', descending: true)
          .snapshots();

  Future<void> ensureProfileBasics(
    String uid,
    String? email,
    String? displayName,
  ) async {
    await profileRef(uid).set({
      'email': email,
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // START pracy
  Future<void> startWork({
    required String uid,
    required String workType,
    required String? note,
  }) async {
    await profileRef(uid).set({
      'active': true,
      'activeStart': Timestamp.fromDate(DateTime.now()),
      'activeWorkType': workType,
      'activeNote': note,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // STOP pracy
  Future<void> stopWork(String uid) async {
    final doc = await profileRef(uid).get();
    final data = doc.data();
    if (data == null || (data['active'] as bool? ?? false) == false) return;

    final start = (data['activeStart'] as Timestamp).toDate();
    final end = DateTime.now();
    final minutes = end.difference(start).inMinutes;

    await profileRef(uid).collection('workLogs').add({
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'minutes': minutes,
      'workType': data['activeWorkType'] ?? 'office',
      'note': data['activeNote'],
      'createdAt': FieldValue.serverTimestamp(),
    });

    await profileRef(uid).update({
      'active': false,
      'activeStart': FieldValue.delete(),
      'activeWorkType': FieldValue.delete(),
      'activeNote': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  Future<List<Profile>> fetchAllProfiles() async {
    final qs = await FirebaseFirestore.instance.collection('profiles').get();
    return qs.docs.map((d) => Profile.fromDoc(d)).toList();
  }
}
