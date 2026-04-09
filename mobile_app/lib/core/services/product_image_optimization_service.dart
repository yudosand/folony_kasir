import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ProductImageOptimizationResult {
  const ProductImageOptimizationResult({
    required this.filePath,
    required this.bytes,
  });

  final String filePath;
  final Uint8List bytes;
}

class ProductImageOptimizationService {
  static const int _maxWidth = 1280;
  static const int _jpegQuality = 78;

  Future<ProductImageOptimizationResult> optimize(String sourcePath) async {
    final sourceFile = File(sourcePath);
    final sourceBytes = await sourceFile.readAsBytes();

    final targetPath = await _buildTargetPath(sourcePath);
    final format = _detectFormat(sourcePath);

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      minWidth: _maxWidth,
      quality: _jpegQuality,
      format: format,
      keepExif: false,
    );

    if (compressedFile == null) {
      return ProductImageOptimizationResult(
        filePath: sourcePath,
        bytes: sourceBytes,
      );
    }

    final optimizedBytes = await compressedFile.readAsBytes();
    if (optimizedBytes.length >= sourceBytes.length) {
      try {
        await File(compressedFile.path).delete();
      } catch (_) {
        // Ignore temp cleanup failures and fall back to the original file.
      }
      return ProductImageOptimizationResult(
        filePath: sourcePath,
        bytes: sourceBytes,
      );
    }

    return ProductImageOptimizationResult(
      filePath: compressedFile.path,
      bytes: optimizedBytes,
    );
  }

  Future<String> _buildTargetPath(String sourcePath) async {
    final tempDir = await getTemporaryDirectory();
    final extension = _targetExtension(sourcePath);
    final fileName =
        'product_${DateTime.now().microsecondsSinceEpoch}$extension';

    return '${tempDir.path}${Platform.pathSeparator}$fileName';
  }

  CompressFormat _detectFormat(String sourcePath) {
    return sourcePath.toLowerCase().endsWith('.png')
        ? CompressFormat.png
        : CompressFormat.jpeg;
  }

  String _targetExtension(String sourcePath) {
    return sourcePath.toLowerCase().endsWith('.png') ? '.png' : '.jpg';
  }
}
