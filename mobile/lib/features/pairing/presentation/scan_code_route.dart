import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'camera_permission_gate.dart';
import 'joincode_cubit.dart';
import 'screens/scan_code_screen.dart';

/// Why the scan overlay closed, so the join-code screen underneath knows
/// whether to put the caret back in the code row.
enum ScanCodeExit {
  /// Closed with the top-left control or the system back gesture.
  dismissed,

  /// The user chose "Nhập mã thủ công", so focus belongs on the code row.
  manualEntry,
}

/// ~150ms, matching `ux/ux-spec.md` State 1's "fades in over ~150ms".
const Duration scanCodeFadeDuration = Duration(milliseconds: 150);

/// The scan overlay, as a full-screen opaque route.
///
/// The UX spec calls this an overlay and asks that the join-code screen's
/// typed characters and scroll survive underneath. A pushed opaque route
/// already guarantees that — the screen below stays mounted — and it brings
/// focus trapping and a back-gesture dismiss that a `showGeneralDialog`
/// overlay would have to re-implement. The rendered result is what the spec
/// describes: full-screen, dark, fading in.
class ScanCodeRoute extends PageRouteBuilder<ScanCodeExit> {
  ScanCodeRoute({
    required JoincodeCubit joincodeCubit,
    CameraPermissionGate permissionGate = const PermissionHandlerCameraGate(),
    ScanPreviewBuilder? previewBuilder,
  }) : super(
         transitionDuration: scanCodeFadeDuration,
         reverseTransitionDuration: scanCodeFadeDuration,
         pageBuilder: (BuildContext context, _, _) {
           // `.value`, not `create`: this is the join-code screen's own cubit,
           // and the overlay must not own its lifecycle. Sharing the instance
           // is what makes a scanned code and a typed one the same pairing
           // call.
           return BlocProvider<JoincodeCubit>.value(
             value: joincodeCubit,
             child: ScanCodeScreen(
               permissionGate: permissionGate,
               previewBuilder: previewBuilder,
             ),
           );
         },
         transitionsBuilder:
             (BuildContext context, Animation<double> animation, _, Widget child) {
               return FadeTransition(opacity: animation, child: child);
             },
       );
}
