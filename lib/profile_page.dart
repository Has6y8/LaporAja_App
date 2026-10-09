import 'package:flutter/material.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final Map user;
  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Profil')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: Column(children: [
          const CircleAvatar(radius: 45,
            backgroundColor: Color(0xFF059669),
            child: Icon(Icons.person, color: Colors.white, size: 50)),
          const SizedBox(height: 12),
          Text(user['name'] ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(user['email'] ?? '',
            style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(.15),
              borderRadius: BorderRadius.circular(20)),
            child: Text('${user['role']}'.toUpperCase(),
              style: const TextStyle(color: Color(0xFF059669),
                fontWeight: FontWeight.w600)),
          ),
        ])),
        const SizedBox(height: 30),
        _item(Icons.badge_outlined, 'ID User', '#${user['id']}'),
        _item(Icons.email_outlined, 'Email', user['email'] ?? '-'),
        _item(Icons.verified_user_outlined, 'Status Akun',
          '${user['status_akun']}'.toUpperCase()),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(double.infinity, 50)),
          onPressed: () => Navigator.pushAndRemoveUntil(c,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false),
        ),
      ],
    ),
  );

  Widget _item(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF059669)),
        title: Text(label,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}