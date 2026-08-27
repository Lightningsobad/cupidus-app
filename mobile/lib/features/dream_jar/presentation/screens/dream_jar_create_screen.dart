import 'dart:math' as math;

import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../data/dream_jar_amount_format.dart';
import '../../data/dream_jar_repository.dart';
import '../create_dream_jar_cubit.dart';

const Color _transparent = Color.fromARGB(0, 0, 0, 0);

/// Supported jar icons per the design system canvas (Cupid Screens.dc.html lines 959-963, 2514).
const List<({String id, IconData icon})> _kJarIcons = [
  (id: 'flight_takeoff', icon: Icons.flight_takeoff_rounded),
  (id: 'sports_esports', icon: Icons.sports_esports_rounded),
  (id: 'home', icon: Icons.home_rounded),
  (id: 'directions_car', icon: Icons.directions_car_rounded),
  (id: 'diamond', icon: Icons.diamond_outlined),
  (id: 'cake', icon: Icons.cake_rounded),
];

/// Full-screen create dream jar flow matching the locked design canvas
/// (`Cupid Screens.dc.html` lines 945-996).
class DreamJarCreateScreen extends StatelessWidget {
  const DreamJarCreateScreen({
    super.key,
    required this.repository,
    this.partnerDisplayName,
  });

  final DreamJarRepository repository;
  final String? partnerDisplayName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateDreamJarCubit>(
      create: (_) => CreateDreamJarCubit(repository),
      child: _DreamJarCreateView(partnerDisplayName: partnerDisplayName),
    );
  }
}

class _DreamJarCreateView extends StatefulWidget {
  const _DreamJarCreateView({this.partnerDisplayName});

  final String? partnerDisplayName;

  @override
  State<_DreamJarCreateView> createState() => _DreamJarCreateViewState();
}

class _DreamJarCreateViewState extends State<_DreamJarCreateView> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedIconId = 'sports_esports';
  num _targetAmount = 15000000;
  DateTime? _deadline = DateTime.now().add(const Duration(days: 120));
  bool _weeklyReminderEnabled = true;
  String? _resolvedPartnerName;

  @override
  void initState() {
    super.initState();
    _resolvedPartnerName = widget.partnerDisplayName;
    if (_resolvedPartnerName == null) {
      _loadPartnerName();
    }
  }

  Future<void> _loadPartnerName() async {
    try {
      if (getIt.isRegistered<AccountRepository>()) {
        final CupidProfile profile =
            await getIt<AccountRepository>().fetchProfile();
        if (mounted && profile.partnerDisplayName != null) {
          setState(() {
            _resolvedPartnerName = profile.partnerDisplayName;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _bumpTarget(num delta) {
    setState(() {
      _targetAmount = math.max(1000000, _targetAmount + delta);
    });
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null && mounted) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _editCustomTarget(BuildContext context) async {
    final TextEditingController customController = TextEditingController(
      text: _targetAmount.toString(),
    );
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    final num? result = await showDialog<num>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colors.colorSurface,
          title: Text(
            'Nhập số tiền mục tiêu',
            style: type.cardTitle.copyWith(color: colors.colorText),
          ),
          content: TextField(
            controller: customController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: type.body.copyWith(color: colors.colorText),
            decoration: InputDecoration(
              suffixText: '₫',
              hintText: '15000000',
              hintStyle: type.body.copyWith(color: colors.colorTextMuted),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Huỷ',
                style: type.body.copyWith(color: colors.colorTextMuted),
              ),
            ),
            TextButton(
              onPressed: () {
                final digits = customController.text.replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                );
                final val = num.tryParse(digits);
                Navigator.of(dialogContext).pop(val);
              },
              child: Text(
                'Xác nhận',
                style: type.body.copyWith(
                  color: colors.colorAccentPink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null && result > 0 && mounted) {
      setState(() {
        _targetAmount = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);
    final String partnerName = _resolvedPartnerName ?? 'người yêu';

    return BlocConsumer<CreateDreamJarCubit, CreateDreamJarState>(
      listener: (context, state) {
        if (state is CreateDreamJarSuccess) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final bool isSubmitting = state is CreateDreamJarSubmitting;
        final bool nameInvalid =
            state is CreateDreamJarValidationFailed && state.nameInvalid;
        final bool targetInvalid =
            state is CreateDreamJarValidationFailed && state.targetAmountInvalid;

        return Scaffold(
          appBar: CupidHeader(
            title: 'Tạo hũ mới',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 1. Headline section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Hai đứa để dành cho gì?',
                          textAlign: TextAlign.center,
                          style: type.display.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: colors.colorText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Cả hai phải cùng đồng ý trước khi hũ được mở',
                          textAlign: TextAlign.center,
                          style: type.caption.copyWith(
                            fontSize: 12.5,
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 2. Card 1: Name the dream
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: colors.colorSurface,
                      borderRadius: BorderRadius.circular(
                        platformTokens.radiusCard,
                      ),
                      boxShadow: platformTokens.elevationShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'ĐẶT TÊN CHO ƯỚC MƠ',
                          style: type.caption.copyWith(
                            fontSize: 11,
                            letterSpacing: 0.66,
                            fontWeight: FontWeight.w700,
                            color: colors.colorTextMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          style: type.body.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colors.colorText,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Ví dụ: Du lịch Đà Nẵng',
                            hintStyle: type.body.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: colors.colorTextMuted.withOpacity(0.5),
                            ),
                          ),
                        ),
                        if (nameInvalid) ...<Widget>[
                          const SizedBox(height: 6),
                          Text(
                            l10n.dream_jar_create_name_required,
                            style: type.caption.copyWith(
                              color: colors.colorRed,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),

                  // 3. Card 2: Pick an icon
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: colors.colorSurface,
                      borderRadius: BorderRadius.circular(
                        platformTokens.radiusCard,
                      ),
                      boxShadow: platformTokens.elevationShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'CHỌN BIỂU TƯỢNG',
                          style: type.caption.copyWith(
                            fontSize: 11,
                            letterSpacing: 0.66,
                            fontWeight: FontWeight.w700,
                            color: colors.colorTextMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: _kJarIcons.map((ic) {
                            final bool isSelected = _selectedIconId == ic.id;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: InkWell(
                                  onTap: () => setState(
                                    () => _selectedIconId = ic.id,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colors.colorAccentPink.withOpacity(
                                              0.18,
                                            )
                                          : colors.colorSurfaceAlt,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: isSelected
                                            ? colors.colorAccentPink
                                            : _transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      ic.icon,
                                      size: 21,
                                      color: isSelected
                                          ? colors.colorAccentPink
                                          : colors.colorTextMuted,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),

                  // 4. Card 3: Target Amount
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: colors.colorSurface,
                      borderRadius: BorderRadius.circular(
                        platformTokens.radiusCard,
                      ),
                      boxShadow: platformTokens.elevationShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'MỤC TIÊU',
                          style: type.caption.copyWith(
                            fontSize: 11,
                            letterSpacing: 0.66,
                            fontWeight: FontWeight.w700,
                            color: colors.colorTextMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _editCustomTarget(context),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              Text(
                                DreamJarAmountFormat.vnd(_targetAmount),
                                style: type.display.copyWith(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: colors.colorMint,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: colors.colorTextMuted.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ),
                        if (targetInvalid) ...<Widget>[
                          const SizedBox(height: 6),
                          Text(
                            l10n.dream_jar_create_target_invalid,
                            style: type.caption.copyWith(
                              color: colors.colorRed,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _BumpButton(
                                label: '−1tr',
                                onTap: () => _bumpTarget(-1000000),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _BumpButton(
                                label: '+1tr',
                                onTap: () => _bumpTarget(1000000),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _BumpButton(
                                label: '+5tr',
                                onTap: () => _bumpTarget(5000000),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),

                  // 5. Card 4: Deadline & Weekly Reminder
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    decoration: BoxDecoration(
                      color: colors.colorSurface,
                      borderRadius: BorderRadius.circular(
                        platformTokens.radiusCard,
                      ),
                      boxShadow: platformTokens.elevationShadow,
                    ),
                    child: Column(
                      children: <Widget>[
                        // Row 1: Deadline
                        InkWell(
                          onTap: () => _pickDeadline(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: colors.colorAmber.withOpacity(
                                      0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Icon(
                                    Icons.event_rounded,
                                    size: 20,
                                    color: colors.colorAmber,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Hạn chót',
                                        style: type.body.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: colors.colorText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _deadline == null
                                            ? 'Chưa đặt hạn chót'
                                            : DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(_deadline!),
                                        style: type.caption.copyWith(
                                          fontSize: 11.5,
                                          color: colors.colorTextMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 19,
                                  color: colors.colorTextMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: colors.colorSurfaceAlt,
                        ),
                        // Row 2: Weekly reminder
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: colors.colorAccentPurple.withOpacity(
                                    0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  Icons.notifications_active_rounded,
                                  size: 20,
                                  color: colors.colorAccentPurple,
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Nhắc góp hằng tuần',
                                      style: type.body.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: colors.colorText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Chủ nhật 20:00 · nhắc cả hai',
                                      style: type.caption.copyWith(
                                        fontSize: 11.5,
                                        color: colors.colorTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _weeklyReminderEnabled,
                                activeColor: colors.colorAccentPink,
                                onChanged: (val) => setState(
                                  () => _weeklyReminderEnabled = val,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),

                  // 6. Card 5: Mutual Agreement Note (Pink card)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: colors.colorAccentPink.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(
                        platformTokens.radiusCard,
                      ),
                      border: Border.all(
                        color: colors.colorAccentPink.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.handshake_outlined,
                          size: 20,
                          color: colors.colorAccentPink,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: type.caption.copyWith(
                                fontSize: 12.5,
                                height: 1.55,
                                color: colors.colorTextMuted,
                              ),
                              children: <TextSpan>[
                                const TextSpan(text: 'Tạo xong, '),
                                TextSpan(
                                  text: partnerName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: colors.colorText,
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      ' phải bấm đồng ý thì hũ mới bắt đầu nhận tiền. Rút tiền ra cũng cần cả hai.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state is CreateDreamJarFailed) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      l10n.dream_jar_create_error,
                      textAlign: TextAlign.center,
                      style: type.caption.copyWith(color: colors.colorRed),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // 7. Bottom CTA Button: Send to partner for approval
                  SizedBox(
                    height: 54,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: colors.gradientHot,
                        borderRadius: BorderRadius.circular(
                          platformTokens.radiusButton,
                        ),
                        boxShadow: platformTokens.elevationShadow,
                      ),
                      child: Material(
                        color: _transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            platformTokens.radiusButton,
                          ),
                          onTap: isSubmitting
                              ? null
                              : () => context
                                    .read<CreateDreamJarCubit>()
                                    .submit(
                                      name: _nameController.text,
                                      targetAmount: _targetAmount,
                                      deadline: _deadline,
                                    ),
                          child: Center(
                            child: isSubmitting
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: colors.colorOnAccent,
                                    ),
                                  )
                                : Text(
                                    'Gửi cho $partnerName duyệt',
                                    style: type.body.copyWith(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                      color: colors.colorOnAccent,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BumpButton extends StatelessWidget {
  const _BumpButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Material(
      color: colors.colorSurfaceAlt,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          child: Text(
            label,
            style: type.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: colors.colorText,
            ),
          ),
        ),
      ),
    );
  }
}
