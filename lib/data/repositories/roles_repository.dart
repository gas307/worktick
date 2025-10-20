import 'package:cloud_firestore/cloud_firestore.dart';

class RolesRepository {
  final _db = FirebaseFirestore.instance;

  Future<String?> getRole(String uid) async {
    final doc = await _db.collection('roles').doc(uid).get();
    return doc.data()?['role'] as String?; // 'admin' | 'user' | null
  }
}
