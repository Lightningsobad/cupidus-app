/// The only public authentication surface (`architecture/solution.md` §2,
/// §4 Boundaries And Ownership). Feature code must import this barrel only
/// — never `package:firebase_auth/...` or the other files under
/// `mobile/lib/core/auth/` directly.
library;

export 'cupid_auth_failure.dart';
export 'cupid_session.dart';
