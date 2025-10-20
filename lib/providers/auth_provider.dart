import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/models/user_role.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/roles_repository.dart';
import '../data/repositories/profile_repository.dart';

class AuthProvider extends ChangeNotifier {
  final _authRepo = AuthRepository();
  final _rolesRepo = RolesRepository();
  final _profileRepo = ProfileRepository();

  StreamSubscription<User?>? _sub;

  User? user;
  UserRole role = UserRole.user;
  bool isLoading = true;

  AuthProvider() {
    _sub = _authRepo.authStateChanges().listen((u) async {
      user = u;
      if (u != null) {
        // baza profilu minimalna
        await _profileRepo.ensureProfileBasics(u.uid, u.email, u.displayName);
        final r = await _rolesRepo.getRole(u.uid);
        role = roleFromString(r);
      }
      isLoading = false;
      notifyListeners();
    });
  }

  bool get isAdmin => role == UserRole.admin;

  Future<void> signIn(String email, String password) async {
    isLoading = true;
    notifyListeners();
    await _authRepo.signIn(email, password);
  }

  Future<void> register(String email, String password) async {
    isLoading = true;
    notifyListeners();
    await _authRepo.register(email, password);
  }

  Future<void> signOut() => _authRepo.signOut();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
