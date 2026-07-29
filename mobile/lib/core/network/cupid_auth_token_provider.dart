/// The `auth` slot's token source (`architecture/solution.md` §2). STORY-003
/// supplies the real implementation and no token logic lives in this story.
abstract interface class CupidAuthTokenProvider {
  Future<String?> readAccessToken();
  Future<String?> refreshAccessToken();
}

/// STORY-002's default: no user is authenticated, so every call reads and
/// refreshes to `null`.
class UnauthenticatedTokenProvider implements CupidAuthTokenProvider {
  const UnauthenticatedTokenProvider();

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> refreshAccessToken() async => null;
}
