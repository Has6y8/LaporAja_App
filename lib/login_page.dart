import 'package:flutter/material.dart';
import 'api.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass  = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);
    try {
      final res = await Api.post('login.php', {
        'email': email.text.trim(),
        'password': pass.text,
      });
      setState(() => loading = false);
      if (!mounted) return;

      if (res['success'] == true) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => HomePage(user: res['user'])));
      } else {
        _snack(res['message'] ?? 'Login gagal');
      }
    } catch (e) {
      setState(() => loading = false);
      _snack('Error: $e');
    }
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Icon(Icons.school, size: 80, color: Color(0xFF059669)),
            const SizedBox(height: 12),
            const Text('LaporAja',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text('Sistem Pengaduan Sarana Sekolah',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 30),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Demo: user@laporaja.id / user123',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ),
      ),
    ),
  );
}