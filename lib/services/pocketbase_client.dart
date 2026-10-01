import 'package:pocketbase/pocketbase.dart';

String normalizePocketBaseUrl(String value) {
  final uri = Uri.parse(value.trim());
  final index = uri.path.indexOf('/_/');
  final path = index >= 0 ? uri.path.substring(0, index) : uri.path;
  return uri
      .replace(path: path.isEmpty ? '/' : path, query: '', fragment: '')
      .toString()
      .replaceFirst(RegExp(r'/$'), '');
}

final pocketBase = PocketBase(normalizePocketBaseUrl(
  const String.fromEnvironment(
    'POCKETBASE_URL',
    defaultValue: 'http://192.168.1.21:8090',
  ),
));
