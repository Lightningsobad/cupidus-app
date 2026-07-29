/// The REST error contract every feature story consumes
/// (`architecture/solution.md` §2). Errors reach callers on
/// `DioException.error`; feature code must not switch on raw
/// `DioExceptionType`.
sealed class CupidApiFailure {
  const CupidApiFailure();
}

/// No connection could be established (offline, DNS failure, refused, etc.).
class NetworkUnavailableFailure extends CupidApiFailure {
  const NetworkUnavailableFailure();
}

/// A connect, send, or receive timeout elapsed before a response arrived.
class TimeoutFailure extends CupidApiFailure {
  const TimeoutFailure();
}

/// The server responded `401 Unauthorized`.
class UnauthorizedFailure extends CupidApiFailure {
  const UnauthorizedFailure();
}

/// The server responded with a non-401 error status.
class HttpStatusFailure extends CupidApiFailure {
  const HttpStatusFailure(this.statusCode, this.message);

  final int statusCode;
  final String? message;
}

/// Any other failure (cancellation, bad certificate, unparseable response,
/// etc.) that does not fit a more specific case.
class UnexpectedFailure extends CupidApiFailure {
  const UnexpectedFailure();
}
