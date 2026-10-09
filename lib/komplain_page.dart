import 'package:flutter/material.dart';
import 'api.dart';

class KomplainPage extends StatefulWidget {
  final Map user;
  const KomplainPage({super.key, required this.user});
  @override
  State<KomplainPage> createState() => _KomplainPageState();
}

class _KomplainPageState extends State<KomplainPage> {
  List items = [];
  bool loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final res = await Api.get(
        'komplain.php?action=list&user_id=${widget.user['id']}&role=${widget.user['role']}');
      setState(() {
        items = res['data'] ?? [];
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  String _tipe(String t) => {
    'lambat_respon': 'Lambat Respon',
    'kurang_jelas': 'Kurang Jelas',
    'foto_tidak_pantas': 'Foto Tidak Pantas',
    'kata_kasar': 'Kata Kasar',
    'minta_hapus_laporan': 'Minta Hapus Laporan',
    'lainnya': 'Lainnya',
  }[t] ?? t;

  Future<void> _buatKomplain() async {
    final pesanCtrl = TextEditingController();
    String tipe = 'lambat_respon';
    final laporanIdCtrl = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20),
        child: StatefulBuilder(
          builder: (ctx, setS) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Buat Komplain',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: laporanIdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ID Laporan',
                    border: OutlineInputBorder())),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipe,
                  decoration: const InputDecoration(
                    labelText: 'Tipe', border: OutlineInputBorder()),
                  items: [
                    'lambat_respon', 'kurang_jelas', 'foto_tidak_pantas',
                    'kata_kasar', 'minta_hapus_laporan', 'lainnya',
                  ].map((e) => DropdownMenuItem(
                    value: e, child: Text(_tipe(e)))).toList(),
                  onChanged: (v) => setS(() => tipe = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: pesanCtrl, maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Pesan', alignLabelWithHint: true,
                    border: OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(height: 48, child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Kirim'))),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok != true) return;
    if (pesanCtrl.text.trim().length < 5) {
      _snack('Pesan minimal 5 karakter');
      return;
    }

    final res = await Api.post('komplain.php?action=create', {
      'user_id':    '${widget.user['id']}',
      'laporan_id': laporanIdCtrl.text.trim(),
      'tipe':       tipe,
      'isi':        pesanCtrl.text.trim(),
    });
    _snack(res['message'] ?? 'Terkirim');
    _load();
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: Text(widget.user['role'] == 'user' ? 'Komplain Saya' : 'Komplain'),
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ],
    ),
    floatingActionButton: widget.user['role'] != 'admin'
      ? FloatingActionButton.extended(
          onPressed: _buatKomplain,
          backgroundColor: const Color(0xFF059669),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Buat'),
        )
      : null,
    body: loading
      ? const Center(child: CircularProgressIndicator())
      : items.isEmpty
        ? const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
              SizedBox(height: 12),
              Text('Belum ada komplain',
                style: TextStyle(color: Colors.grey)),
            ],
          ))
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final k = items[i];
                final ok = k['status'] == 'direspon';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(_tipe(k['tipe'] ?? ''),
                            style: const TextStyle(fontWeight: FontWeight.bold))),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (ok ? Colors.green : Colors.orange)
                                .withOpacity(.15),
                              borderRadius: BorderRadius.circular(12)),
                            child: Text(ok ? 'Direspon' : 'Pending',
                              style: TextStyle(
                                color: ok ? Colors.green : Colors.orange,
                                fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                        if (k['laporan_judul'] != null) ...[
                          const SizedBox(height: 4),
                          Text('Laporan: ${k['laporan_judul']}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                        const SizedBox(height: 6),
                        Text(k['isi'] ?? '', maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                        if (k['respon_admin'] != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withOpacity(.08),
                              borderRadius: BorderRadius.circular(8)),
                            child: Row(children: [
                              const Icon(Icons.reply, size: 16,
                                color: Color(0xFF059669)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(k['respon_admin'],
                                style: const TextStyle(fontSize: 13))),
                            ]),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
  );
}