import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../data/love_contract_gate_repository.dart';
import '../../data/love_contract_repository.dart';
import '../screens/love_contract_screen.dart';

/// `draw` glyph, confirmed in the bundled font's cmap at 0xe746 — the icon
/// the design source uses for the `contract` entry (`ux/uiux-spec.md` §3).
/// `chevron_right` at 0xe5cc (0xe409 aliases to the identical glyph).
/// Defined locally rather than added to the shared `CupidIcons` because this
/// phase's write scope does not include that file.
const IconData _iconDraw = IconData(0xe746, fontFamily: CupidIcons.fontFamily);
const IconData _iconChevronRight = IconData(
  0xe5cc,
  fontFamily: CupidIcons.fontFamily,
);

/// Discoverable entry point into [LoveContractScreen] (`ux/uiux-spec.md` §3):
/// a `--surf` card row with the `draw` icon, the "Love Contract" label, and a
/// chevron affordance.
///
/// AC4 is hide-not-disable (`ux/uiux-spec.md` §7): an unpaired user has no
/// partner to contract with, so the row is absent rather than locked. A gate
/// fetch that fails is treated the same way — hidden is the safe default.
///
/// [locator] exists so tests can supply a scoped [GetIt]; production callers
/// omit it and get the app's composition root. An unregistered gate
/// repository (for example the bare `CupidApp` boot in `widget_test.dart`)
/// also resolves to hidden rather than throwing.
class LoveContractEntryTile extends StatefulWidget {
  const LoveContractEntryTile({super.key, this.locator});

  final GetIt? locator;

  @override
  State<LoveContractEntryTile> createState() => _LoveContractEntryTileState();
}

class _LoveContractEntryTileState extends State<LoveContractEntryTile> {
  late final Future<PairingState> _pairingState = resolvePairingState(
    widget.locator,
  );

  void _open() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LoveContractGateRoute(locator: widget.locator),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PairingState>(
      future: _pairingState,
      builder: (BuildContext context, AsyncSnapshot<PairingState> snapshot) {
        final PairingState? state = snapshot.data;
        if (state == null || !state.isPaired) {
          return const SizedBox.shrink();
        }
        return _EntryRow(onTap: _open);
      },
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Semantics(
      button: true,
      label: l10n.loveContractEntryLabel,
      child: InkWell(
        key: const Key('love_contract_entry_tile'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
          child: Container(
            padding: EdgeInsets.all(CupidSpacing.md),
            decoration: BoxDecoration(
              color: colors.colorSurface,
              borderRadius: BorderRadius.circular(platformTokens.radiusCard),
            ),
            child: Row(
              children: <Widget>[
                ExcludeSemantics(
                  child: Icon(_iconDraw, color: colors.colorAccentPink),
                ),
                SizedBox(width: CupidSpacing.sm),
                Expanded(
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.loveContractEntryLabel,
                          style: type.cardTitle.copyWith(
                            color: colors.colorText,
                          ),
                        ),
                        Text(
                          l10n.loveContractEntrySubtitle,
                          style: type.caption.copyWith(
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ExcludeSemantics(
                  child: Icon(_iconChevronRight, color: colors.colorGhost),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Re-asserts the AC4 gate when the contract route opens, so a stale push
/// (backgrounded app, unpair while the row was on screen) cannot show
/// contract UI to a user who is no longer paired. [LoveContractScreen] is not
/// in this phase's write scope, so the re-assert lives on the route that
/// wraps it rather than inside the screen.
///
/// It re-runs the same `GET /users/me` fetch the tile did, which also yields
/// the caller's own `displayName` for the screen's header subtitle.
class LoveContractGateRoute extends StatefulWidget {
  const LoveContractGateRoute({super.key, this.locator});

  final GetIt? locator;

  @override
  State<LoveContractGateRoute> createState() => _LoveContractGateRouteState();
}

class _LoveContractGateRouteState extends State<LoveContractGateRoute> {
  late final Future<PairingState> _pairingState = resolvePairingState(
    widget.locator,
  );

  GetIt get _locator => widget.locator ?? getIt;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PairingState>(
      future: _pairingState,
      builder: (BuildContext context, AsyncSnapshot<PairingState> snapshot) {
        final PairingState? state = snapshot.data;
        if (state != null && !state.isPaired) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).maybePop();
          });
        }
        if (state == null || !state.isPaired) {
          return const _GateCheckShell();
        }
        return LoveContractScreen(
          // Explicit rather than relying on the default: this is the
          // post-home entry ADR-7 keeps chromed, and it should break loudly
          // if that default ever flips.
          entry: LoveContractEntry.standalone,
          repository: _locator<LoveContractRepository>(),
          partnerDisplayName: _locator.isRegistered<PartnerDisplayName>()
              ? _locator<PartnerDisplayName>()
              : () => null,
          myDisplayName: () => state.myDisplayName,
        );
      },
    );
  }
}

class _GateCheckShell extends StatelessWidget {
  const _GateCheckShell();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      key: const Key('love_contract_gate_check'),
      appBar: CupidHeader(
        title: l10n.loveContractScreenTitle,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: const SizedBox.shrink(),
    );
  }
}

/// Shared gate resolution for the tile and the route. A missing registration
/// or any fetch failure resolves to [PairingState.unpaired] so the AC4 gate
/// fails closed (hidden), never open.
Future<PairingState> resolvePairingState(GetIt? locator) async {
  final GetIt resolved = locator ?? getIt;
  if (!resolved.isRegistered<LoveContractGateRepository>()) {
    return PairingState.unpaired;
  }
  try {
    return await resolved<LoveContractGateRepository>().fetchPairingState();
  } on Object {
    return PairingState.unpaired;
  }
}
