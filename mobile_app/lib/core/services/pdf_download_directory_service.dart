import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PdfDownloadDirectoryService {
  const PdfDownloadDirectoryService();

  Future<Directory> resolveSubdirectory(String folderName) async {
    final publicDownloadDir = await _resolvePublicDownloadDirectory();
    if (publicDownloadDir != null) {
      final publicTargetDir = Directory(
        '${publicDownloadDir.path}${Platform.pathSeparator}FolonyKasir${Platform.pathSeparator}$folderName',
      );

      try {
        await publicTargetDir.create(recursive: true);
        return publicTargetDir;
      } catch (_) {
        // Fall back to app-scoped storage below.
      }
    }

    final appDownloadDir = await _resolveAppDownloadDirectory();
    final appTargetDir = Directory(
      '${appDownloadDir.path}${Platform.pathSeparator}FolonyKasir${Platform.pathSeparator}$folderName',
    );
    await appTargetDir.create(recursive: true);
    return appTargetDir;
  }

  Future<Directory?> _resolvePublicDownloadDirectory() async {
    if (!Platform.isAndroid) {
      return null;
    }

    const candidates = <String>[
      '/storage/emulated/0/Download',
      '/sdcard/Download',
    ];

    for (final path in candidates) {
      final directory = Directory(path);
      if (await directory.exists()) {
        return directory;
      }
    }

    return null;
  }

  Future<Directory> _resolveAppDownloadDirectory() async {
    final downloadDirs =
        await getExternalStorageDirectories(type: StorageDirectory.downloads);
    if (downloadDirs != null && downloadDirs.isNotEmpty) {
      return downloadDirs.first;
    }

    final externalDir = await getExternalStorageDirectory();
    if (externalDir != null) {
      return externalDir;
    }

    return getApplicationDocumentsDirectory();
  }
}
