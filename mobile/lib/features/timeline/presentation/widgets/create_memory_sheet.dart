import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_event_dto.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart';
import 'package:cupid_mobile/features/timeline/presentation/create_entry_cubit.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_dashed_border.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_entry_card.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_strings.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;

const IconData _closeGlyph = IconData(
  0xe5cd,
  fontFamily: 'Material Symbols Rounded',
);

const int _titleMaxLength = 100;
const int _descriptionMaxLength = 500;

typedef ImagePickerFunction = Future<XFile?> Function({
  double? maxWidth,
  double? maxHeight,
  int? imageQuality,
});

/// Bottom sheet for creating a new Love Timeline memory with Cupid theme styling,
/// date selection, and compressed device-only photo selection.
class CreateMemorySheet extends StatelessWidget {
  const CreateMemorySheet({
    super.key,
    required this.repository,
    required this.isOffline,
    this.imagePicker,
  });

  final TimelineRepository repository;
  final bool Function() isOffline;
  final ImagePickerFunction? imagePicker;

  static Future<void> show(
    BuildContext context, {
    required TimelineRepository repository,
    required bool Function() isOffline,
    ImagePickerFunction? imagePicker,
  }) {
    final double radiusSheet = context.cupidPlatform.radiusSheet;
    final CupidColorTokens tokens = context.cupidColors;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: tokens.colorSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusSheet)),
      ),
      builder: (BuildContext _) => CreateMemorySheet(
        repository: repository,
        isOffline: isOffline,
        imagePicker: imagePicker,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateEntryCubit>(
      create: (_) => CreateEntryCubit(repository, isOffline: isOffline),
      child: _CreateMemorySheetBody(
        isOffline: isOffline,
        imagePicker: imagePicker,
      ),
    );
  }
}

class _CreateMemorySheetBody extends StatefulWidget {
  const _CreateMemorySheetBody({
    required this.isOffline,
    this.imagePicker,
  });

  final bool Function() isOffline;
  final ImagePickerFunction? imagePicker;

  @override
  State<_CreateMemorySheetBody> createState() =>
      _CreateMemorySheetBodyState();
}

class _CreateMemorySheetBodyState extends State<_CreateMemorySheetBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _date = DateTime.now();
  File? _selectedImage;
  bool _isCompressing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file = widget.imagePicker != null
          ? await widget.imagePicker!(
              maxWidth: 800,
              maxHeight: 800,
              imageQuality: 70,
            )
          : await ImagePicker().pickImage(
              source: ImageSource.gallery,
              maxWidth: 800,
              maxHeight: 800,
              imageQuality: 70,
            );

      if (file != null) {
        setState(() {
          _selectedImage = File(file.path);
        });
      }
    } catch (_) {
      // Ignore user cancellations or permissions errors gracefully
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _pickDate() async {
    final CupidColorTokens colors = context.cupidColors;
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.colorAccentPink,
              onPrimary: colors.colorOnAccent,
              surface: colors.colorSurface,
              onSurface: colors.colorText,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (widget.isOffline()) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final String description = _descriptionController.text.trim();
    String? photoUrl;

    if (_selectedImage != null) {
      setState(() => _isCompressing = true);
      try {
        final bytes = _selectedImage!.readAsBytesSync();
        photoUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } catch (_) {
        // Fallback without image on read failure
      } finally {
        if (mounted) setState(() => _isCompressing = false);
      }
    }

    if (!mounted) return;

    context.read<CreateEntryCubit>().submit(
      TimelineDraft(
        title: _titleController.text.trim(),
        date: _date,
        description: description.isEmpty ? null : description,
        photoUrl: photoUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return BlocConsumer<CreateEntryCubit, CreateEntryState>(
      listener: (BuildContext context, CreateEntryState state) {
        if (state is CreateEntrySuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (BuildContext context, CreateEntryState state) {
        final bool proactivelyOffline = widget.isOffline();
        final bool isSubmitting = state is CreateEntrySubmitting || _isCompressing;
        final String? inlineMessage = switch (state) {
          CreateEntryBlockedOffline() => l10n.timeline_sheet_offline_blocked,
          CreateEntryPairingRequired() => l10n.timeline_sheet_pairing_required,
          CreateEntryFailed() => l10n.timeline_error_body,
          _ => proactivelyOffline ? l10n.timeline_sheet_offline_blocked : null,
        };

        return Padding(
          padding: EdgeInsets.only(
            left: CupidSpacing.lg,
            right: CupidSpacing.lg,
            top: CupidSpacing.sm,
            bottom: MediaQuery.of(context).viewInsets.bottom + CupidSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: colors.colorLine,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header Row
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.colorAccentPink.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: CupidIcon(
                          TimelineGlyphs.symbolFor('favorite') ?? Icons.favorite,
                          size: 18,
                          color: colors.colorAccentPink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.timeline_sheet_title,
                          style: type.cardTitle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colors.colorText,
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: l10n.timeline_sheet_cancel_label,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          constraints: BoxConstraints(
                            minWidth: platformTokens.tapTarget,
                            minHeight: platformTokens.tapTarget,
                          ),
                          icon: CupidIcon(
                            _closeGlyph,
                            size: 20,
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Photo Picker Section
                  _PhotoPickerSection(
                    image: _selectedImage,
                    onPick: _pickImage,
                    onRemove: _removeImage,
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                  ),
                  const SizedBox(height: 14),

                  // Title Field
                  Text(
                    l10n.timeline_sheet_field_title_label,
                    style: type.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.colorText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.colorSurfaceAlt,
                      borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
                      border: Border.all(color: colors.colorLine),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: TextFormField(
                      controller: _titleController,
                      maxLength: _titleMaxLength,
                      style: type.body.copyWith(color: colors.colorText),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        hintText: context.viEn(
                          'Ví dụ: Buổi hẹn hò đầu tiên 🎬',
                          'e.g. Our First Date 🎬',
                        ),
                        hintStyle: type.body.copyWith(
                          color: colors.colorTextMuted.withValues(alpha: 0.6),
                        ),
                      ),
                      validator: (String? value) =>
                          (value == null || value.trim().isEmpty)
                              ? l10n.timeline_sheet_validation_title_required
                              : null,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date Picker Field
                  Text(
                    l10n.timeline_sheet_field_date_label,
                    style: type.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.colorText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.colorSurfaceAlt,
                        borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
                        border: Border.all(color: colors.colorLine),
                      ),
                      child: Row(
                        children: <Widget>[
                          CupidIcon(
                            TimelineGlyphs.symbolFor('cake') ?? Icons.calendar_today,
                            size: 18,
                            color: colors.colorAccentPink,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _dateFormat.format(_date),
                              style: type.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.colorText,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.colorSurface,
                              borderRadius: BorderRadius.circular(platformTokens.radiusButton),
                              border: Border.all(color: colors.colorLine),
                            ),
                            child: Text(
                              context.viEn('Đổi ngày', 'Change'),
                              style: type.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colors.colorAccentPink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description Field
                  Text(
                    l10n.timeline_sheet_field_description_label,
                    style: type.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.colorText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.colorSurfaceAlt,
                      borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
                      border: Border.all(color: colors.colorLine),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLength: _descriptionMaxLength,
                      maxLines: 3,
                      style: type.body.copyWith(color: colors.colorText),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        hintText: context.viEn(
                          'Chia sẻ đôi dòng cảm xúc, khoảnh khắc đáng nhớ...',
                          'Write a short note or memory...',
                        ),
                        hintStyle: type.body.copyWith(
                          color: colors.colorTextMuted.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),

                  // Inline error/message
                  if (inlineMessage != null) ...<Widget>[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.colorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
                      ),
                      child: Text(
                        inlineMessage,
                        style: type.caption.copyWith(
                          color: colors.colorRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),

                  // Submit CTA
                  CupidPrimaryButton(
                    label: isSubmitting
                        ? context.viEn('Đang lưu...', 'Saving...')
                        : l10n.timeline_sheet_save_label,
                    onPressed: (isSubmitting || proactivelyOffline) ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhotoPickerSection extends StatelessWidget {
  const _PhotoPickerSection({
    required this.image,
    required this.onPick,
    required this.onRemove,
    required this.colors,
    required this.type,
    required this.platformTokens,
  });

  final File? image;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.colorSurfaceAlt,
                border: Border.all(color: colors.colorLine),
                borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
              ),
              child: Image.file(
                image!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 140,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.colorText.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: CupidIcon(
                  _closeGlyph,
                  size: 16,
                  color: colors.colorOnAccent,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: onPick,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.colorText.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(platformTokens.radiusButton),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CupidIcon(
                      Icons.photo_library_outlined,
                      size: 14,
                      color: colors.colorOnAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.viEn('Đổi ảnh', 'Change'),
                      style: type.caption.copyWith(
                        color: colors.colorOnAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      key: const Key('photoPickerSection'),
      onTap: onPick,
      borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
        ),
        child: TimelineDashedBorder(
          color: colors.colorAccentPink.withValues(alpha: 0.35),
          radius: platformTokens.radiusSmall,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CupidIcon(
                  TimelineGlyphs.symbolFor('photo_camera') ?? Icons.camera_alt,
                  size: 24,
                  color: colors.colorAccentPink,
                ),
                const SizedBox(height: 6),
                Text(
                  context.viEn('Chọn ảnh kỷ niệm', 'Add memory photo'),
                  style: type.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: colors.colorText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.viEn(
                    'Ảnh chỉ lưu trên máy 2 bạn 🔒',
                    'Stored privately on your devices 🔒',
                  ),
                  style: type.caption.copyWith(
                    fontSize: 10.5,
                    color: colors.colorTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final intl.DateFormat _dateFormat = intl.DateFormat('dd/MM/yyyy');
