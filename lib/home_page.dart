import 'package:flutter/material.dart';
import 'api.dart';
import 'laporan_list_page.dart';
import 'laporan_create_page.dart';
import 'komplain_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final Map user;
  const HomePage({super.key, required this.user});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map stats = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final res = await Api.get(
        'dashboard.php?user_id=${widget.user['id']}&role=${widget.user['role']}');
      setState(() {
        stats = res['stats'] ?? {};
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final u = widget.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _welcome(u),
            const SizedBox(height: 16),
            if (loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator()))
            else
              _stats(),
            const SizedBox(height: 20),
            const Text('Menu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            if (u['role'] == 'user')
              _menu(Icons.add_circle, 'Buat Laporan', () {
                Navigator.push(c, MaterialPageRoute(
                  builder: (_) => LaporanCreatePage(user: u)));
              }),
            _menu(Icons.list_alt, 'Daftar Laporan', () {
              Navigator.push(c, MaterialPageRoute(
                builder: (_) => LaporanListPage(user: u)));
            }),
            _menu(Icons.chat_bubble_outline, 'Komplain', () {
              Navigator.push(c, MaterialPageRoute(
                builder: (_) => KomplainPage(user: u)));
            }),
            _menu(Icons.person, 'Profil', () {
              Navigator.push(c, MaterialPageRoute(
                builder: (_) => ProfilePage(user: u)));
            }),
          ],
        ),
      ),
    );
  }

  Widget _welcome(Map u) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF059669), Color(0xFF064E3B)]),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(children: [
      const CircleAvatar(radius: 26, backgroundColor: Colors.white24,
        child: Icon(Icons.person, color: Colors.white, size: 30)),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Halo, ${u['name']}',
            style: const TextStyle(color: Colors.white,
              fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12)),
            child: Text('${u['role']}'.toUpperCase(),
              style: const TextStyle(color: Colors.white,
                fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      )),
    ]),
  );

  Widget _stats() {
    final labels = {
      'total': 'Total', 'pending': 'Menunggu', 'diproses': 'Diproses',
      'selesai': 'Selesai', 'komplain': 'Komplain',
    };
    final entries = stats.entries.toList();
    if (entries.isEmpty) return const SizedBox();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10, crossAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: entries.map((e) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${e.value}', style: const TextStyle(fontSize: 22,
              fontWeight: FontWeight.bold, color: Color(0xFF059669))),
            Text(labels[e.key] ?? e.key,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _menu(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF059669).withOpacity(.1),
          child: Icon(icon, color: const Color(0xFF059669))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}