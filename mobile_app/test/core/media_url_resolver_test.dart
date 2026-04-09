import 'package:flutter_test/flutter_test.dart';
import 'package:folony_kasir_mobile/core/utils/media_url_resolver.dart';

void main() {
  group('MediaUrlResolver', () {
    test('rewrites localhost media URLs to the configured API host and port',
        () {
      final resolved = MediaUrlResolver.resolve(
        'http://localhost/storage/products/example.jpg',
      );

      expect(
        resolved,
        'http://10.0.2.2:8000/storage/products/example.jpg',
      );
    });

    test('keeps external URLs unchanged', () {
      final resolved = MediaUrlResolver.resolve(
        'https://cdn.example.com/products/example.jpg',
      );

      expect(
        resolved,
        'https://cdn.example.com/products/example.jpg',
      );
    });
  });
}
