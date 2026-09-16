import 'dart:math';

/// A client-generated RFC 4122 v4 id.
///
/// No `uuid` package is a direct dependency of this app, so the id is produced
/// from `dart:math`'s cryptographic RNG. It lives in `core/` rather than beside
/// a repository because the byte count and the byte range below are UUID
/// constants, and a feature that has its own rule about which integer literals
/// may appear in its directory should not have to carry them.
String newUuidV4() {
  final Random random = Random.secure();
  final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int start, int end) => bytes
      .sublist(start, end)
      .map((int byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
