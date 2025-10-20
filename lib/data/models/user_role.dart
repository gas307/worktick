enum UserRole { user, admin }

UserRole roleFromString(String? s) =>
    s == 'admin' ? UserRole.admin : UserRole.user;
String roleToString(UserRole r) => r == UserRole.admin ? 'admin' : 'user';
