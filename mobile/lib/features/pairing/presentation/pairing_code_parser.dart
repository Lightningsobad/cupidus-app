/// Length of a pairing code, mirroring `_codeLength` in `joincode_screen.dart`.
const int pairingCodeLength = 6;

final RegExp _nonAlphanumeric = RegExp(r'[^A-Za-z0-9]');
final RegExp _alphanumericCode = RegExp('^[A-Z0-9]{$pairingCodeLength}\$');

/// Normalizes an untrusted QR payload into a pairing code, or returns `null`
/// when the payload is not one.
///
/// STORY-002 owns QR *generation*, so the payload shape is not fixed by this
/// story: this accepts both a bare code and a URL or deep link whose trailing
/// segment is the code.
///
/// This deliberately does not reuse `_pasteCode`'s truncate-to-the-first-six
/// rule. That rule reads `https://cupid.app/join/ABC123` as `HTTPS:`, which
/// would turn a malformed scan into a real backend call and, on rejection,
/// into an error the user cannot act on.
String? parsePairingCode(String raw) {
  final String trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  // Take the tail after whichever separator appears last, so both a path
  // (`.../join/ABC123`) and a scheme (`cupid://ABC123`) collapse to the code.
  final int lastSlash = trimmed.lastIndexOf('/');
  final int lastColon = trimmed.lastIndexOf(':');
  final int cut = lastSlash > lastColon ? lastSlash : lastColon;
  final String tail = cut >= 0 ? trimmed.substring(cut + 1) : trimmed;

  final String normalized = tail.replaceAll(_nonAlphanumeric, '').toUpperCase();
  return _alphanumericCode.hasMatch(normalized) ? normalized : null;
}
