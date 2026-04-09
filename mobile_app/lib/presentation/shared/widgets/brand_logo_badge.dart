import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/utils/media_url_resolver.dart';

class BrandLogoBadge extends StatelessWidget {
  const BrandLogoBadge({
    super.key,
    this.width = 116,
    this.height,
    this.imageUrl,
    this.filePath,
    this.fit = BoxFit.contain,
  });

  final double width;
  final double? height;
  final String? imageUrl;
  final String? filePath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = MediaUrlResolver.resolve(imageUrl);
    final hasFileImage = filePath != null && filePath!.trim().isNotEmpty;
    final hasNetworkImage =
        resolvedImageUrl != null && resolvedImageUrl.trim().isNotEmpty;

    return SizedBox(
      width: width,
      height: height,
      child: hasFileImage
          ? Image.file(
              File(filePath!),
              fit: fit,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => _FallbackLogo(fit: fit),
            )
          : hasNetworkImage
              ? Image.network(
                  resolvedImageUrl,
                  fit: fit,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => _FallbackLogo(fit: fit),
                )
              : _FallbackLogo(fit: fit),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({
    required this.fit,
  });

  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/folony_logo.png',
      fit: fit,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}
