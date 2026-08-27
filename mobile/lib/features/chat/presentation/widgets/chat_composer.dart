import 'dart:io';
import 'dart:math' as math;

import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/auth_failure_text.dart';
import '../chat_strings.dart';
import '../ghost_cubit.dart' show GhostConsentLevel;

// Off-scale metrics transcribed verbatim from the design source
const double _barPaddingX = 10;
const double _barPaddingY = 8;
const double _barBottomGap = 8;
const double _barGap = 7;
const double _warnRowPaddingX = 18;
const double _warnRowPaddingTop = 8;
const double _warnRowGap = 6;
const double _warnFontSize = 11;
const double _warnIconSize = 13;
const double _ghostButtonSize = 46;
const double _ghostButtonIconSize = 19;
const double _ghostButtonLabelSize = 7;
const double _inputMinHeight = 44;
const double _inputRadius = 22;
const double _inputPaddingLeft = 12;
const double _inputPaddingRight = 6;
const double _inputFontSize = 15;
const double _sendButtonSize = 36;
const double _sendIconSize = 19;

const double _ghostButtonOnBorderAlpha = 0.75;

/// Message composer with Text input, Ghost Mode toggle, Photo Attachment,
/// and Emoji/Sticker drawer trigger.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    required this.showNetworkUnavailableError,
    required this.ghostConsentLevel,
    required this.onGhostTogglePressed,
    required this.partnerDisplayName,
    this.onDraftChanged,
    this.onSendImage,
    this.onEmojiTogglePressed,
    this.isEmojiDrawerOpen = false,
  });

  /// Returns `true` on a successful send.
  final Future<bool> Function(String draft) onSend;

  /// Surfaces the reused `NetworkUnavailableFailure` copy after a send failed.
  final bool showNetworkUnavailableError;

  /// Drives the 3-state ghost toggle's visual.
  final GhostConsentLevel ghostConsentLevel;

  final VoidCallback onGhostTogglePressed;

  final String? partnerDisplayName;

  final ValueChanged<String>? onDraftChanged;

  /// Triggered when a photo is selected & compressed to send.
  final Future<bool> Function(File file)? onSendImage;

  /// Toggles the emoji drawer.
  final VoidCallback? onEmojiTogglePressed;

  final bool isEmojiDrawerOpen;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _hasDraft = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleDraftChanged);
  }

  void _handleDraftChanged() {
    final String draft = _controller.text;
    final bool hasDraft = draft.trim().isNotEmpty;
    if (hasDraft != _hasDraft) {
      setState(() => _hasDraft = hasDraft);
    }
    widget.onDraftChanged?.call(draft);
  }

  Future<void> _handleSendPressed() async {
    final String draft = _controller.text.trim();
    if (draft.isEmpty) return;
    final bool sent = await widget.onSend(draft);
    if (sent && mounted) _controller.clear();
  }

  Future<void> _handlePickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      // Compression budget: max 1600px dimension and 80 quality keeps payload under 300KB
      final XFile? picked = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      if (picked == null || !mounted) return;

      setState(() => _isUploadingPhoto = true);
      if (widget.onSendImage != null) {
        await widget.onSendImage!(File(picked.path));
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showImagePickerModal() {
    final CupidColorTokens colors = context.cupidColors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.colorSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.colorLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Gửi Hình Ảnh Yêu Thương 📸',
                  style: context.cupidType.display.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.colorText,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.colorAccentPink.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_library, color: colors.colorAccentPink),
                  ),
                  title: Text(
                    'Chọn từ Thư viện ảnh',
                    style: context.cupidType.body.copyWith(color: colors.colorText),
                  ),
                  subtitle: Text(
                    'Đã nén tối ưu dung lượng',
                    style: context.cupidType.caption.copyWith(color: colors.colorTextMuted),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _handlePickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.colorMint.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt, color: colors.colorMint),
                  ),
                  title: Text(
                    'Chụp ảnh mới',
                    style: context.cupidType.body.copyWith(color: colors.colorText),
                  ),
                  subtitle: Text(
                    'Lưu giữ khoảnh khắc cùng bạn',
                    style: context.cupidType.caption.copyWith(color: colors.colorTextMuted),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _handlePickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleDraftChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final bool ghostIsOn = widget.ghostConsentLevel == GhostConsentLevel.on;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.colorSurface.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: colors.colorLine)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showNetworkUnavailableError)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _warnRowPaddingX,
                  _warnRowPaddingTop,
                  _warnRowPaddingX,
                  0,
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    authFailureMessage(
                      context,
                      const NetworkUnavailableFailure(),
                    ),
                    style: context.cupidType.caption.copyWith(
                      fontSize: _warnFontSize,
                      fontWeight: FontWeight.w700,
                      color: colors.colorRed,
                    ),
                  ),
                ),
              ),
            if (ghostIsOn && _hasDraft && widget.partnerDisplayName != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _warnRowPaddingX,
                  _warnRowPaddingTop,
                  _warnRowPaddingX,
                  0,
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: _warnIconSize,
                        color: colors.colorAccentPurple,
                      ),
                      const SizedBox(width: _warnRowGap),
                      Flexible(
                        child: Text(
                          ChatStrings.ghostWatchingWarning(
                            context,
                            widget.partnerDisplayName!,
                          ),
                          style: context.cupidType.caption.copyWith(
                            fontSize: _warnFontSize,
                            fontWeight: FontWeight.w700,
                            color: colors.colorAccentPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _barPaddingX,
                _barPaddingY,
                _barPaddingX,
                _barBottomGap,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 1. Ghost Mode Toggle
                  _GhostToggleButton(
                    colors: colors,
                    platformTokens: platformTokens,
                    consentLevel: widget.ghostConsentLevel,
                    onPressed: widget.onGhostTogglePressed,
                  ),
                  const SizedBox(width: _barGap),

                  // 2. Photo / Image Picker Action Button
                  _IconButton(
                    icon: _isUploadingPhoto ? Icons.hourglass_top : Icons.photo_camera,
                    color: _isUploadingPhoto ? colors.colorMint : colors.colorAccentPink,
                    onTap: _isUploadingPhoto ? null : _showImagePickerModal,
                    colors: colors,
                  ),
                  const SizedBox(width: _barGap),

                  // 3. Main Text Input Field
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: platformTokens.tapTarget,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: _inputMinHeight,
                        ),
                        padding: const EdgeInsets.only(
                          left: _inputPaddingLeft,
                          right: _inputPaddingRight,
                        ),
                        decoration: BoxDecoration(
                          color: colors.colorSurfaceAlt.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(_inputRadius),
                          border: Border.all(
                            color: colors.colorLine.withValues(alpha: 0.6),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                minLines: 1,
                                maxLines: 4,
                                style: context.cupidType.body.copyWith(
                                  fontSize: _inputFontSize,
                                  color: colors.colorText,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintStyle: context.cupidType.body.copyWith(
                                    fontSize: _inputFontSize,
                                    color: colors.colorTextMuted,
                                  ),
                                  hintText: ghostIsOn
                                      ? ChatStrings.composerHintGhostOn(context)
                                      : ChatStrings.composerHint(context),
                                ),
                              ),
                            ),
                            // Emoji trigger inside input box
                            InkWell(
                              onTap: widget.onEmojiTogglePressed,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  widget.isEmojiDrawerOpen ? '⌨️' : '😊',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: _barGap),

                  // 4. Send Message Button
                  _SendButton(
                    colors: colors,
                    platformTokens: platformTokens,
                    enabled: _hasDraft,
                    onPressed: _handleSendPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 44,
      child: Center(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.colorSurfaceAlt.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.colorLine),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.colors,
    required this.platformTokens,
    required this.enabled,
    required this.onPressed,
  });

  final CupidColorTokens colors;
  final CupidPlatformTokens platformTokens;
  final bool enabled;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: platformTokens.tapTarget,
      height: platformTokens.tapTarget,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled ? colors.gradientHot : null,
            color: enabled ? null : colors.colorSurfaceAlt,
            shape: BoxShape.circle,
            boxShadow: enabled ? colors.glowShadow : null,
          ),
          child: SizedBox(
            width: _sendButtonSize,
            height: _sendButtonSize,
            child: IconButton(
              onPressed: enabled ? onPressed : null,
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.arrow_upward,
                size: _sendIconSize,
                color: enabled ? colors.colorOnAccent : colors.colorTextMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostToggleButton extends StatelessWidget {
  const _GhostToggleButton({
    required this.colors,
    required this.platformTokens,
    required this.consentLevel,
    required this.onPressed,
  });

  final CupidColorTokens colors;
  final CupidPlatformTokens platformTokens;
  final GhostConsentLevel consentLevel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isOn = consentLevel == GhostConsentLevel.on;
    final Color foreground =
        isOn ? colors.colorAccentPurple : colors.colorTextMuted;
    final double slot = math.max(platformTokens.tapTarget, _ghostButtonSize);

    return Semantics(
      button: true,
      label: ChatStrings.ghostToggleSemanticLabel(context, consentLevel),
      child: ExcludeSemantics(
        child: SizedBox(
          width: slot,
          height: slot,
          child: Center(
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(
                platformTokens.radiusSmall,
              ),
              child: Container(
                width: _ghostButtonSize,
                height: _ghostButtonSize,
                decoration: BoxDecoration(
                  color: isOn
                      ? colors.colorAccentPurple.withValues(alpha: 0.24)
                      : colors.colorSurface,
                  borderRadius: BorderRadius.circular(
                    platformTokens.radiusSmall,
                  ),
                  border: Border.all(
                    color: isOn
                        ? colors.colorAccentPurple.withValues(
                            alpha: _ghostButtonOnBorderAlpha,
                          )
                        : colors.colorLine,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.blur_on,
                      size: _ghostButtonIconSize,
                      color: foreground,
                    ),
                    Text(
                      ChatStrings.ghostToggleGlyph(consentLevel),
                      style: context.cupidType.labelMono.copyWith(
                        fontSize: _ghostButtonLabelSize,
                        letterSpacing: _ghostButtonLabelSize * 0.06,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
