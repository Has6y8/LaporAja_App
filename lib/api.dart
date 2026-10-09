import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  // Ganti IP kalau pindah device
  static const String host = '10.134.117.97';
  static const String base = 'http://$host/laporaja_api';
  static const String img  = 'http://$host/laporaja_api/uploads/';

  static Future<Map> post(String url, Map body) async {
    final r = await http.post(Uri.parse('$base/$url'), body: body)
        .timeout(const Duration(seconds: 15));
    return jsonDecode(r.body);
  }

  static Future<Map> get(String url) async {
    final r = await http.get(Uri.parse('$base/$url'))
        .timeout(const Duration(seconds: 15));
    return jsonDecode(r.body);
  }
}