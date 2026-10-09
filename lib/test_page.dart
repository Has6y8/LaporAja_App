import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ==========================================
// GANTI IP INI SESUAI CARA KAMU TEST
// Emulator: 10.0.2.2 | HP fisik: 192.168.x.x | Chrome: localhost
// ==========================================
const String TEST_HOST = '192.168.110.28';

class TestPage extends StatefulWidget {
  const TestPage({super.key});
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final List<Map<String, String>> _results = [];
  bool _running = false;

  void _addResult(String label, String status, String detail) {
    setState(() => _results.add({
      'label': label,
      'status': status,
      'detail': detail,
    }));
  }

  Future<void> _runTests() async {
    setState(() {
      _results.clear();
      _running = true;
    });

    // 1. Test koneksi dasar
    await _testConnect();

    // 2. Test login
    await _testLogin();

    // 3. Test list laporan
    await _testLaporan();

    setState(() => _running = false);
  }

  Future<void> _testConnect() async {
    final url = 'http://$TEST_HOST/laporaja_api/test.php';
    try {
      final r = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (r.statusCode == 200 && r.body.contains('Konek ke database')) {
        _addResult('Koneksi ke server', '✅ OK', 'HTTP ${r.statusCode}');
      } else {
        _addResult('Koneksi ke server', '⚠️ Respon aneh',
          'HTTP ${r.statusCode} — ${r.body.substring(0, 100)}');
      }
    } on TimeoutException {
      _addResult('Koneksi ke server', '❌ TIMEOUT',
        'Server tidak balas dalam 10 detik.\nURL: $url\n\nKemungkinan: IP salah / firewall blok / Apache mati');
    } catch (e) {
      _addResult('Koneksi ke server', '❌ GAGAL', '$e\nURL: $url');
    }
  }

  Future<void> _testLogin() async {
    final url = 'http://$TEST_HOST/laporaja_api/login.php';
    try {
      final r = await http.post(
        Uri.parse(url),
        body: {'email': 'user@laporaja.id', 'password': 'user123'},
      ).timeout(const Duration(seconds: 10));

      if (r.statusCode != 200) {
        _addResult('Test login', '❌ HTTP ${r.statusCode}', r.body);
        return;
      }

      final j = jsonDecode(r.body);
      if (j['success'] == true) {
        _addResult('Test login', '✅ OK',
          'User: ${j['user']['name']} (${j['user']['role']})');
      } else {
        _addResult('Test login', '❌ GAGAL',
          'Pesan server: ${j['message']}\n\nPassword mungkin beda — jalankan reset SQL');
      }
    } on TimeoutException {
      _addResult('Test login', '❌ TIMEOUT', 'URL: $url');
    } catch (e) {
      _addResult('Test login', '❌ ERROR', '$e\nURL: $url');
    }
  }

  Future<void> _testLaporan() async {
    final url = 'http://$TEST_HOST/laporaja_api/laporan.php?action=list&user_id=4&role=user';
    try {
      final r = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) {
        final j = jsonDecode(r.body);
        if (j['success'] == true) {
          final n = (j['data'] as List?)?.length ?? 0;
          _addResult('Test list laporan', '✅ OK', '$n laporan ditemukan');
        } else {
          _addResult('Test list laporan', '❌ GAGAL', r.body);
        }
      } else {
        _addResult('Test list laporan', '❌ HTTP ${r.statusCode}', r.body);
      }
    } on TimeoutException {
      _addResult('Test list laporan', '❌ TIMEOUT', 'URL: $url');
    } catch (e) {
      _addResult('Test list laporan', '❌ ERROR', '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Koneksi'),
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Host yang dipakai:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('http://$TEST_HOST/laporaja_api',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Jalankan Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _running ? null : _runTests,
            ),
            const SizedBox(height: 16),

            if (_running)
              const Center(child: CircularProgressIndicator()),

            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (_, i) {
                  final r = _results[i];
                  final ok = r['status']!.startsWith('✅');
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(child: Text(r['label']!,
                              style: const TextStyle(fontWeight: FontWeight.bold))),
                            Text(r['status']!,
                              style: TextStyle(
                                color: ok ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 6),
                          Text(r['detail']!,
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}