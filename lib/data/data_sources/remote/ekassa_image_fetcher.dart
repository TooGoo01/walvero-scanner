import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Flutter cihazından (AZ ISP) e-kassa monitoring endpoint-ə birbaşa request.
///
/// Backend Azure West US 2 DC outbound IP-i AZ tərəfdən firewall ilə bloklanır.
/// Lakin operator-un Android cihazı AZ network-də olduğu üçün endpoint açıqdır.
/// Fetched JPEG temp file kimi saxlanır, sonra multipart-da backend-ə göndərilir.
class EkassaImageFetcher {
  static const Duration _timeout = Duration(seconds: 10);

  /// `urlTemplate` placeholder `{docId}` ilə dəyişdirilir.
  /// Uğurlu nəticədə temp file qaytarır, uğursuz halda null (silent fallback).
  static Future<File?> fetchAsync(String docId, String urlTemplate) async {
    if (docId.isEmpty || urlTemplate.isEmpty || !urlTemplate.contains('{docId}')) {
      debugPrint('[EKASSA FLUTTER FETCH] invalid docId/template');
      return null;
    }
    final url = urlTemplate.replaceAll('{docId}', Uri.encodeComponent(docId));
    debugPrint('[EKASSA FLUTTER FETCH] start url=$url');

    try {
      final resp = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'Accept': 'image/jpeg,image/png,image/*,*/*;q=0.8',
          'Referer': 'https://monitoring.e-kassa.gov.az/',
        },
      ).timeout(_timeout);

      final ct = resp.headers['content-type'] ?? '';
      debugPrint('[EKASSA FLUTTER FETCH] status=${resp.statusCode} ct=$ct len=${resp.bodyBytes.length}');

      if (resp.statusCode != 200 || resp.bodyBytes.isEmpty) {
        debugPrint('[EKASSA FLUTTER FETCH] non-success');
        return null;
      }

      // Content-type yoxlaması — image olmasa skip
      if (!ct.toLowerCase().startsWith('image/')) {
        debugPrint('[EKASSA FLUTTER FETCH] non-image content-type, skip');
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final ext = ct.contains('png') ? 'png' : 'jpg';
      // Safe filename: docId-də /, \, \\, : ola bilər
      final safeId = docId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
      final file = File('${tempDir.path}/ekassa_$safeId.$ext');
      await file.writeAsBytes(resp.bodyBytes);
      debugPrint('[EKASSA FLUTTER FETCH] saved to ${file.path}');
      return file;
    } catch (e, st) {
      debugPrint('[EKASSA FLUTTER FETCH] EXCEPTION: $e\n$st');
      return null;
    }
  }
}
