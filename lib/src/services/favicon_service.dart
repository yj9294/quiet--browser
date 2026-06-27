import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class FaviconService {
  Future<String> fetchAndStore(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return '';
    }

    try {
      final iconUri = await _discoverIconUri(uri) ?? _fallbackIconUri(uri);
      final bytes = await _downloadBytes(iconUri);
      if (bytes == null || bytes.isEmpty) {
        return '';
      }

      final baseDir = await getDatabasesPath();
      final iconDir = Directory(
        p.join(baseDir, 'quiet_vault_browser_favicons'),
      );
      if (!await iconDir.exists()) {
        await iconDir.create(recursive: true);
      }

      final extension = _safeExtension(iconUri.path);
      final fileName =
          '${uri.host.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')}$extension';
      final file = File(p.join(iconDir.path, fileName));
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return '';
    }
  }

  Future<Uri?> _discoverIconUri(Uri pageUri) async {
    final html = await _downloadText(pageUri);
    if (html == null || html.isEmpty) {
      return null;
    }

    final linkTags = RegExp(
      r'<link\b[^>]*>',
      caseSensitive: false,
    ).allMatches(html);

    for (final match in linkTags) {
      final tag = match.group(0) ?? '';
      final rel = _extractAttribute(tag, 'rel').toLowerCase();
      if (!rel.contains('icon')) {
        continue;
      }

      final href = _extractAttribute(tag, 'href');
      if (href.isEmpty) {
        continue;
      }

      final resolved = pageUri.resolve(href.trim());
      if (resolved.scheme == 'http' || resolved.scheme == 'https') {
        return resolved;
      }
    }

    return null;
  }

  String _extractAttribute(String tag, String attribute) {
    final doubleQuoted = RegExp(
      '$attribute\\s*=\\s*"([^"]+)"',
      caseSensitive: false,
    ).firstMatch(tag)?.group(1);
    if (doubleQuoted != null && doubleQuoted.isNotEmpty) {
      return doubleQuoted;
    }

    final singleQuoted = RegExp(
      "$attribute\\s*=\\s*'([^']+)'",
      caseSensitive: false,
    ).firstMatch(tag)?.group(1);
    if (singleQuoted != null && singleQuoted.isNotEmpty) {
      return singleQuoted;
    }

    return '';
  }

  Uri _fallbackIconUri(Uri uri) {
    return uri.replace(path: '/favicon.ico', query: null, fragment: null);
  }

  Future<String?> _downloadText(Uri uri) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.userAgentHeader, 'QuietVaultBrowser/1.0');
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      return await utf8.decodeStream(response);
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<List<int>?> _downloadBytes(Uri uri) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.userAgentHeader, 'QuietVaultBrowser/1.0');
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      return bytes;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  String _safeExtension(String path) {
    final extension = p.extension(path).toLowerCase();
    const allowed = {'.png', '.jpg', '.jpeg', '.webp', '.ico', '.gif', '.bmp'};
    if (allowed.contains(extension)) {
      return extension;
    }
    return '.ico';
  }
}
