import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/core/config/cupid_api_config.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_entry_card.dart';
import 'package:flutter/material.dart';

/// Renders a timeline memory photo from Base64 Data URI, HTTP/HTTPS URL, or local file.
class CupidTimelinePhoto extends StatelessWidget {
  const CupidTimelinePhoto({
    super.key,
    required this.photoUrl,
    this.width = double.infinity,
    this.height = 112,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  final String photoUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final double? borderRadius;
  final Widget? placeholder;

  static String _resolveUrl(String rawUrl) {
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }
    final base = CupidApiConfig.baseUrl.endsWith('/')
        ? CupidApiConfig.baseUrl.substring(0, CupidApiConfig.baseUrl.length - 1)
        : CupidApiConfig.baseUrl;
    final name = rawUrl.startsWith('/') ? rawUrl.substring(1) : rawUrl;
    return '$base/uploads/$name';
  }

  static Uint8List? _tryDecodeBase64(String raw) {
    try {
      final commaIndex = raw.indexOf(',');
      final base64String = commaIndex != -1 ? raw.substring(commaIndex + 1) : raw;
      return base64Decode(base64String.trim());
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? context.cupidPlatform.radiusSmall;
    final Widget fallback = placeholder ?? const TimelinePhotoPlaceholder();

    if (photoUrl.isEmpty) {
      return fallback;
    }

    Widget imageWidget;

    if (photoUrl.startsWith('data:image/') || photoUrl.contains(';base64,')) {
      final bytes = _tryDecodeBase64(photoUrl);
      if (bytes != null && bytes.isNotEmpty) {
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => fallback,
        );
      } else {
        imageWidget = fallback;
      }
    } else if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      imageWidget = Image.network(
        _resolveUrl(photoUrl),
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return fallback;
        },
        errorBuilder: (_, __, ___) => fallback,
      );
    } else {
      imageWidget = Image.network(
        _resolveUrl(photoUrl),
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return fallback;
        },
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: imageWidget,
    );
  }
}
