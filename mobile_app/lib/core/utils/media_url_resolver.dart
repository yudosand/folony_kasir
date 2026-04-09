import '../network/network_config.dart';

class MediaUrlResolver {
  const MediaUrlResolver._();

  static String? resolve(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return null;
    }

    final normalized = rawUrl.trim();
    final rawUri = Uri.tryParse(normalized);
    if (rawUri == null) {
      return normalized;
    }

    final apiUri = Uri.parse(NetworkConfig.apiBaseUrl);
    final mediaBaseUri = apiUri.replace(
      pathSegments: const [],
      query: null,
      fragment: null,
    );

    if (!rawUri.hasScheme || rawUri.host.isEmpty) {
      return mediaBaseUri.resolveUri(rawUri).toString();
    }

    if (_shouldUseApiHost(rawUri, mediaBaseUri)) {
      return rawUri
          .replace(
            scheme: mediaBaseUri.scheme,
            host: mediaBaseUri.host,
            port: mediaBaseUri.hasPort ? mediaBaseUri.port : 80,
          )
          .toString();
    }

    return normalized;
  }

  static bool _shouldUseApiHost(Uri rawUri, Uri mediaBaseUri) {
    final localHosts = {'localhost', '127.0.0.1', '10.0.2.2'};
    if (!localHosts.contains(rawUri.host)) {
      return false;
    }

    if (rawUri.host != mediaBaseUri.host) {
      return true;
    }

    if (!rawUri.hasPort && mediaBaseUri.hasPort) {
      return true;
    }

    if (rawUri.hasPort &&
        mediaBaseUri.hasPort &&
        rawUri.port != mediaBaseUri.port) {
      return true;
    }

    return false;
  }
}
