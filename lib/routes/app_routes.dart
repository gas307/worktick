import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ui/screens/sign_in/sign_in_page.dart';
import '../ui/screens/home/home_page.dart';
import '../providers/auth_provider.dart';

class AppRoutes {
  static const wrapper = '/';
  static const signIn = '/signIn';
  static const home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case wrapper:
        return MaterialPageRoute(builder: (_) => _Wrapper()); // bez const
      case signIn:
        return MaterialPageRoute(builder: (_) => SignInPage()); // bez const
      case home:
        return MaterialPageRoute(builder: (_) => HomePage()); // bez const
      default:
        return MaterialPageRoute(builder: (_) => _Wrapper());
    }
  }
}

class _Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return auth.user == null ? SignInPage() : HomePage(); // bez const
  }
}
