import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// A shipped content package failed its schema check. Loading never degrades
/// to a partial or empty package: a malformed asset is a loud error at load
/// time (R-15a), because the content source moves to an out-of-repo CMS whose
/// exports never pass through this repository's review.
class ContentPackageFormatException implements Exception {
  const ContentPackageFormatException(this.source, this.message);

  /// Asset key or other origin label, so the message names the bad file.
  final String source;
  final String message;

  @override
  String toString() => 'ContentPackageFormatException($source): $message';
}

/// Every package item carries an author-assigned identifier that survives
/// reordering, insertion, and a CMS re-export (R-15a). A list index is never
/// an identifier.
abstract interface class ContentItem {
  String get id;
}

typedef ContentItemParser<T extends ContentItem> =
    T Function(Map<String, Object?> json, String source);

/// A versioned, schema-checked bundle of preset content
/// (`architecture/contract-summary.md` §2). The shape STORY-002+ preset stores
/// reuse.
class ContentPackage<T extends ContentItem> {
  const ContentPackage({
    required this.id,
    required this.version,
    required this.schemaId,
    required this.items,
  });

  final String id;
  final String version;
  final String schemaId;
  final List<T> items;

  /// Package size is a property of the data, never a compile-time constant
  /// (R-15b). Callers read this; they never assume a seed count.
  int get length => items.length;

  T? itemById(String itemId) {
    for (final item in items) {
      if (item.id == itemId) {
        return item;
      }
    }
    return null;
  }

  /// Parses and validates [jsonSource]. [expectedSchemaId] pins the consumer
  /// to one schema, so a CMS that ships a newer shape under the same asset key
  /// fails here instead of silently feeding the wrong fields downstream.
  static ContentPackage<T> parse<T extends ContentItem>(
    String jsonSource, {
    required String expectedSchemaId,
    required ContentItemParser<T> itemParser,
    String source = '<memory>',
  }) {
    final Object? decoded;
    try {
      decoded = jsonDecode(jsonSource);
    } on FormatException catch (error) {
      throw ContentPackageFormatException(source, 'invalid JSON: ${error.message}');
    }
    if (decoded is! Map<String, Object?>) {
      throw ContentPackageFormatException(
        source,
        'expected a JSON object at the package root',
      );
    }

    final schemaId = requireContentString(decoded, 'schema_id', source);
    if (schemaId != expectedSchemaId) {
      throw ContentPackageFormatException(
        source,
        'schema_id "$schemaId" does not match the expected "$expectedSchemaId"',
      );
    }

    final rawItems = decoded['items'];
    if (rawItems is! List) {
      throw ContentPackageFormatException(source, 'field "items" must be a list');
    }

    final items = <T>[];
    final seenIds = <String>{};
    for (final rawItem in rawItems) {
      if (rawItem is! Map<String, Object?>) {
        throw ContentPackageFormatException(
          source,
          'every entry of "items" must be a JSON object',
        );
      }
      final item = itemParser(rawItem, source);
      if (!seenIds.add(item.id)) {
        throw ContentPackageFormatException(
          source,
          'duplicate item id "${item.id}"',
        );
      }
      items.add(item);
    }

    return ContentPackage<T>(
      id: requireContentString(decoded, 'id', source),
      version: requireContentString(decoded, 'version', source),
      schemaId: schemaId,
      items: List<T>.unmodifiable(items),
    );
  }
}

/// Reads a mandatory non-empty string field, or throws.
String requireContentString(
  Map<String, Object?> json,
  String key,
  String source,
) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw ContentPackageFormatException(
      source,
      'field "$key" must be a non-empty string',
    );
  }
  return value;
}

/// Reads an optional string field. A missing field is a valid `null`; a
/// present-but-wrong-typed field is still an error.
String? optionalContentString(
  Map<String, Object?> json,
  String key,
  String source,
) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String || value.isEmpty) {
    throw ContentPackageFormatException(
      source,
      'optional field "$key" must be a non-empty string when present',
    );
  }
  return value;
}

/// Reads a mandatory list-of-objects field, or throws.
List<Map<String, Object?>> requireContentObjectList(
  Map<String, Object?> json,
  String key,
  String source,
) {
  final value = json[key];
  if (value is! List) {
    throw ContentPackageFormatException(source, 'field "$key" must be a list');
  }
  final entries = <Map<String, Object?>>[];
  for (final entry in value) {
    if (entry is! Map<String, Object?>) {
      throw ContentPackageFormatException(
        source,
        'every entry of "$key" must be a JSON object',
      );
    }
    entries.add(entry);
  }
  return entries;
}

/// Reads a mandatory list-of-strings field, or throws.
List<String> requireContentStringList(
  Map<String, Object?> json,
  String key,
  String source,
) {
  final value = json[key];
  if (value is! List) {
    throw ContentPackageFormatException(source, 'field "$key" must be a list');
  }
  final entries = <String>[];
  for (final entry in value) {
    if (entry is! String || entry.isEmpty) {
      throw ContentPackageFormatException(
        source,
        'every entry of "$key" must be a non-empty string',
      );
    }
    entries.add(entry);
  }
  return entries;
}

/// Loads a [ContentPackage] from a Flutter asset. Asset-only by construction:
/// there is no HTTP client, no base URL, and no model call on this path
/// (R-7, BR-8).
class ContentPackageLoader {
  const ContentPackageLoader({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;

  Future<ContentPackage<T>> load<T extends ContentItem>(
    String assetKey, {
    required String expectedSchemaId,
    required ContentItemParser<T> itemParser,
  }) async {
    final jsonSource = await (_bundle ?? rootBundle).loadString(assetKey);
    return ContentPackage.parse<T>(
      jsonSource,
      expectedSchemaId: expectedSchemaId,
      itemParser: itemParser,
      source: assetKey,
    );
  }
}
