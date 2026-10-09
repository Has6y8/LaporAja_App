import 'package:flutter/material.dart';
import 'api.dart';

class LaporanListPage extends StatefulWidget {
  final Map user;
  const LaporanListPage({super.key, required this.user});
  @override
  State<LaporanListPage> createState() => _LaporanListPageState();
}

class _LaporanListPageState extends State<LaporanListPage> {
  List items = [];
  bool loading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ============ LOAD LIST ============
  Future<void> _load() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      final res = await Api.get(
        'laporan.php?action=list&user_id=${widget.user['id']}&role=${widget.user['role']}');

      if (res['success'] == true) {
        setState(() {
          items = res['data'] ?? [];
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          errorMsg = res['message'] ?? 'Gagal load';
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMsg = 'Error: $e';
      });
    }
  }

  // ============ UPDATE STATUS ============
  Future<void> _update(int id, String status) async {
    print('=== UPDATE REQUEST ===');
    print('ID: $id');
    print('Status: $status');
    print('User ID: ${widget.user['id']}');
    print('Role: ${widget.user['role']}');

    try {
      final res = await Api.post('laporan.php?action=update', {
        'id': '$id',
        'status': status,
        'user_id': '${widget.user['id']}',
      });

      print('=== UPDATE RESPONSE ===');
      print('$res');

      if (!mounted) return;

      if (res['success'] == true) {
        _snack(
          'Status berhasil diubah ke "$status"',
          color: Colors.green,
        );
        await _load();
      } else {
        _snack(
          'Gagal: ${res['message'] ?? 'Unknown error'}',
          color: Colors.red,
        );
      }
    } catch (e) {
      print('=== UPDATE ERROR ===');
      print('$e');
      if (!mounted) return;
      _snack('Error: $e', color: Colors.red);
    }
  }

  void _snack(String m, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':  return Colors.orange;
      case 'diproses': return Colors.blue;
      case 'selesai':  return Colors.green;
      case 'ditolak':  return Colors.red;
    }
    return Colors.grey;
  }

  // ============ KONFIRMASI ============
  Future<bool> _confirm(String status) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Ubah status laporan menjadi "$status"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Ubah'),
          ),
        ],
      ),
    ) ?? false;
  }

  // ============ UI ============
  @override
  Widget build(BuildContext c) {
    final isStaff = widget.user['role'] != 'user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Laporan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: loading
        ? const Center(child: CircularProgressIndicator())

        : errorMsg != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(errorMsg!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      onPressed: _load,
                    ),
                  ],
                ),
              ),
            )

        : items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Belum ada laporan',
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
                ],
              ),
            )

          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (_, i) => _buildCard(items[i], isStaff),
              ),
            ),
    );
  }

  Widget _buildCard(Map l, bool isStaff) {
    final status = l['status'] ?? 'pending';
    final canProcess = isStaff && status == 'pending';
    final canFinish  = isStaff && status == 'diproses';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto bukti
            if (l['foto_bukti'] != null && l['foto_bukti'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  '${Api.img}${l['foto_bukti']}',
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, prog) => prog == null
                    ? child
                    : Container(
                        height: 130,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // Judul + badge
            Row(children: [
              Expanded(child: Text(
                l['judul'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status,
                  style: TextStyle(
                    color: _statusColor(status),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  )),
              ),
            ]),
            const SizedBox(height: 4),

            // Info
            Text('Lokasi: ${l['lokasi']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Pelapor: ${l['pelapor']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(l['deskripsi'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis),

            // Foto perbaikan
            if (l['foto_perbaikan'] != null &&
                l['foto_perbaikan'].toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Foto Perbaikan:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  '${Api.img}${l['foto_perbaikan']}',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            // Tombol aksi
            if (isStaff && (canProcess || canFinish)) ...[
              const SizedBox(height: 12),
              Row(children: [
                if (canProcess)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Proses'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        minimumSize: const Size(0, 44),
                      ),
                      onPressed: () async {
                        final ok = await _confirm('diproses');
                        if (ok) _update(l['id'], 'diproses');
                      },
                    ),
                  ),
                if (canFinish)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(0, 44),
                      ),
                      onPressed: () async {
                        final ok = await _confirm('selesai');
                        if (ok) _update(l['id'], 'selesai');
                      },
                    ),
                  ),
              ]),
            ],

            // Info kalau bukan staff
            if (!isStaff && status != 'selesai' && status != 'ditolak') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Menunggu tindakan staff',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}