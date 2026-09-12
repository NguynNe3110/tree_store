import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resolves a backend-relative image path (e.g. `/images/cay1.jpg`) to a
/// fully qualified URL by prepending BASE_URL. Absolute http(s) URLs pass
/// through unchanged. Empty input yields empty output so widgets can show
/// their fallback.
String resolveImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final base = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8081';
  return '$base$path';
}