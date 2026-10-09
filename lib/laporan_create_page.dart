import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'api.dart';

class LaporanCreatePage extends StatefulWidget {
  final Map user;
  const LaporanCreatePage({super.key, required this.user});
  @override
  State<LaporanCreatePage> createState() => _LaporanCreatePageState();
}

class _LaporanCreatePageState extends State<LaporanCreatePage> {
  final judul = TextEditingController();
  final lokasi = TextEditingController();
  final desk = TextEditingController();

  Uint8List? fotoBytes;
  String? fotoName;
  bool loading = false;

  // ============ AMBIL FOTO ============
  Future<void> _pick(ImageSource src) async {
    try {
      final x = await ImagePicker().pickImage(
        source: src,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (x == null) return;

      final bytes = await x.readAsBytes();
      setState(() {
        fotoBytes = bytes;
        fotoName = x.name;
      });
    } catch (e) {
      _snack('Gagal ambil foto: $e');
    }
  }

  // ============ KIRIM LAPORAN ============
  Future<void> _submit() async {
    if (judul.text.trim().isEmpty ||
        lokasi.text.trim().isEmpty ||
        fotoBytes == null) {
      _snack('Judul, lokasi, dan foto wajib diisi');
      return;
    }

    setState(() => loading = true);

    try {
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('${Api.base}/laporan.php?action=create'),
      )
        ..fields['user_id']   = '${widget.user['id']}'
        ..fields['judul']     = judul.text.trim()
        ..fields['lokasi']    = lokasi.text.trim()
        ..fields['deskripsi'] = desk.text.trim()
        ..files.add(http.MultipartFile.fromBytes(
          'foto_bukti',
          fotoBytes!,
          filename: fotoName ?? 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));

      final stream = await req.send().timeout(const Duration(seconds: 30));
      final body = await stream.stream.bytesToString();

      setState(() => loading = false);
      if (!mounted) return;

      if (body.contains('"success":true')) {
        _snack('Laporan berhasil dikirim');
        Navigator.pop(context, true);
      } else {
        _snack('Gagal: $body');
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

  // ============ UI ============
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Buat Laporan')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ============ PREVIEW FOTO ============
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.hardEdge,
            child: fotoBytes == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 6),
                      Text('Belum ada foto',
                        style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      fotoBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    // Tombol hapus foto
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          fotoBytes = null;
                          fotoName = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
          ),

          const SizedBox(height: 10),

          // ============ TOMBOL KAMERA / GALERI ============
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Kamera'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  side: const BorderSide(color: Color(0xFF059669)),
                  foregroundColor: const Color(0xFF059669),
                ),
                onPressed: () => _pick(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text('Galeri'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  side: const BorderSide(color: Color(0xFF059669)),
                  foregroundColor: const Color(0xFF059669),
                ),
                onPressed: () => _pick(ImageSource.gallery),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // ============ FORM ============
          TextField(
            controller: judul,
            maxLength: 150,
            decoration: const InputDecoration(
              labelText: 'Judul Laporan',
              hintText: 'Contoh: Lampu kelas XII RPL C mati',
              prefixIcon: Icon(Icons.title),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: lokasi,
            maxLength: 150,
            decoration: const InputDecoration(
              labelText: 'Lokasi',
              hintText: 'Contoh: Gedung A, Ruang 12',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: desk,
            maxLines: 5,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: 'Deskripsi Kerusakan',
              hintText: 'Jelaskan detail kerusakan...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          // ============ TOMBOL KIRIM ============
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: loading
                ? const SizedBox.shrink()
                : const Icon(Icons.send),
              label: loading
                ? const SizedBox(
                    height: 22, width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text('Kirim Laporan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: loading ? null : _submit,
            ),
          ),

          const SizedBox(height: 12),

          // Info kecil di bawah
          const Center(
            child: Text(
              'Foto wajib diisi sebagai bukti kerusakan',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
  );
}