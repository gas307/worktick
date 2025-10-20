import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? error;
  bool _obscure = true;

  static const double _cardHeight = 260;
  static const double _cardWidth = 420;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // === DUŻE LOGO (wysokość = wysokość karty logowania) ===
              SizedBox(
                height: _cardHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset(
                    'assets/logo/worktick.png',
                    color: isDark ? Colors.white : null,
                    colorBlendMode: isDark ? BlendMode.srcIn : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // === KARTA LOGOWANIA ===
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _cardWidth, minWidth: 320),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: SizedBox(
                    height: _cardHeight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'app.email'.tr(),
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (v) =>
                                  (v == null || !v.contains('@')) ? 'Invalid email' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'app.password'.tr(),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                ),
                              ),
                              validator: (v) =>
                                  (v == null || v.length < 6) ? 'Min 6 chars' : null,
                            ),
                            const SizedBox(height: 16),
                            if (error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(error!, style: const TextStyle(color: Colors.red)),
                              ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!.validate()) return;
                                        try {
                                          await context.read<AuthProvider>().signIn(
                                                _email.text.trim(),
                                                _password.text.trim(),
                                              );
                                        } catch (e) {
                                          setState(() => error = e.toString());
                                        }
                                      },
                                child: Text('app.signIn'.tr()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // brak rejestracji
            ],
          ),
        ),
      ),
    );
  }
}
