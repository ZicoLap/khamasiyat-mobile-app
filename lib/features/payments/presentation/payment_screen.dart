import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/core/clock/stadium_time.dart';
import 'package:khamasiyat_mobile_app/features/bookings/domain/customer_booking.dart';
import 'package:khamasiyat_mobile_app/features/payments/domain/payment_models.dart';
import 'package:khamasiyat_mobile_app/features/payments/presentation/payment_controller.dart';
import 'package:khamasiyat_mobile_app/shared/formatting/sdg_formatter.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

/// Payment flow for an existing PENDING booking.
class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentControllerProvider(bookingId));
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: Text(l10n.paymentTitle),
      ),
      body: switch (state.phase) {
        PaymentUiPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        PaymentUiPhase.failure => _FailureBody(
          message: state.errorMessage ?? l10n.paymentGenericError,
          onRetry: () => ref.read(paymentControllerProvider(bookingId).notifier).load(),
        ),
        PaymentUiPhase.expired => _ExpiredBody(
          onChooseAnother: () => _backToBrowse(context, state.booking),
        ),
        PaymentUiPhase.confirmed => _ConfirmedBody(booking: state.booking),
        PaymentUiPhase.submitted => _SubmittedBody(
          booking: state.booking,
          payment: state.payment,
          localeCode: localeCode,
        ),
        PaymentUiPhase.rejected => _RejectedBody(
          booking: state.booking,
          payment: state.payment,
          remainingHold: state.remainingHold,
          onRetry: () {
            ref
                .read(paymentControllerProvider(bookingId).notifier)
                .beginRetryAfterRejection();
          },
        ),
        _ => _PaymentFormBody(
          bookingId: bookingId,
          state: state,
          localeCode: localeCode,
        ),
      },
    );
  }

  void _backToBrowse(BuildContext context, CustomerBooking? booking) {
    final pitchId = booking?.pitchId;
    if (pitchId != null && pitchId.isNotEmpty) {
      context.go(AppRoutes.pitchDetail(pitchId));
      return;
    }
    context.go(AppRoutes.home);
  }
}

class _PaymentFormBody extends ConsumerStatefulWidget {
  const _PaymentFormBody({
    required this.bookingId,
    required this.state,
    required this.localeCode,
  });

  final String bookingId;
  final PaymentViewState state;
  final String localeCode;

  @override
  ConsumerState<_PaymentFormBody> createState() => _PaymentFormBodyState();
}

class _PaymentFormBodyState extends ConsumerState<_PaymentFormBody> {
  late final TextEditingController _referenceController;

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(text: widget.state.reference);
  }

  @override
  void didUpdateWidget(covariant _PaymentFormBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.reference != _referenceController.text &&
        widget.state.reference != oldWidget.state.reference) {
      _referenceController.text = widget.state.reference;
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final bookingId = widget.bookingId;
    final localeCode = widget.localeCode;
    final l10n = context.l10n;
    final booking = state.booking;
    final notifier = ref.read(paymentControllerProvider(bookingId).notifier);
    final busy = state.isBusy;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (booking != null) ...[
                _HoldBanner(remaining: state.remainingHold),
                const SizedBox(height: AppSpacing.md),
                _SummaryCard(booking: booking, localeCode: localeCode),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                l10n.paymentChooseMethod,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (state.methods.isEmpty)
                Text(
                  l10n.paymentNoMethods,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                ),
              for (final method in state.methods)
                _MethodTile(
                  method: method,
                  selected: state.selectedMethod == method.method,
                  groupValue: state.selectedMethod,
                  enabled: !busy,
                  onTap: () => notifier.selectMethod(method.method),
                ),
              if (state.selectedMethod != null) ...[
                const SizedBox(height: AppSpacing.md),
                _MethodDetails(
                  method: state.methods.firstWhere(
                    (m) => m.method == state.selectedMethod,
                  ),
                ),
              ],
              if (state.selectedMethod?.requiresReceipt == true) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.paymentReferenceLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    enabled: !busy,
                    controller: _referenceController,
                    onChanged: notifier.setReference,
                    decoration: InputDecoration(
                      hintText: l10n.paymentReferenceHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _ReceiptPicker(
                  receipt: state.receipt,
                  enabled: !busy,
                  progress: state.uploadProgress,
                  phase: state.phase,
                  onPick: () => _pickReceipt(context, notifier),
                  onClear: () => notifier.setReceipt(null),
                ),
              ],
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _mapError(l10n, state.errorMessage!),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade800,
                      ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.canSubmit ? () => notifier.submit() : null,
                child: busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.paymentSubmit),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickReceipt(
    BuildContext context,
    PaymentController notifier,
  ) async {
    final l10n = context.l10n;
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      withData: true,
    );
    if (!context.mounted) return;
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      notifier.setReceipt(null);
      return;
    }
    final contentType = _contentTypeForName(file.name);
    if (!kReceiptAllowedContentTypes.contains(contentType)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.paymentErrorUnsupportedType)),
      );
      return;
    }
    if (bytes.length > kReceiptDefaultMaxBytes) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.paymentErrorOversized)),
      );
      return;
    }
    notifier.setReceipt(
      SelectedReceiptFile(
        name: file.name,
        bytes: bytes,
        contentType: contentType,
      ),
    );
  }

  static String _contentTypeForName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'image/jpeg';
  }

  static String _mapError(AppLocalizations l10n, String code) {
    switch (code) {
      case 'unsupported_type':
        return l10n.paymentErrorUnsupportedType;
      case 'oversized':
        return l10n.paymentErrorOversized;
      default:
        return code;
    }
  }
}

class _HoldBanner extends StatelessWidget {
  const _HoldBanner({required this.remaining});

  final Duration? remaining;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = formatHoldCountdown(remaining);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentHoldReservedTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimarySoft,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              l10n.paymentHoldRemaining(label),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandDeep,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.paymentHoldHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }
}

String formatHoldCountdown(Duration? remaining) {
  if (remaining == null) return '--:--';
  final total = remaining.isNegative ? Duration.zero : remaining;
  final minutes = total.inMinutes;
  final seconds = total.inSeconds.remainder(60);
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');
  return '$mm:$ss';
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.booking, required this.localeCode});

  final CustomerBooking booking;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateLabel = DateFormat.yMMMEd(localeCode).format(
      StadiumTime.parseIsoDate(booking.date),
    );
    final amount = SdgFormatter.format(booking.priceSdg, locale: localeCode);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.stadiumName.isEmpty
                ? l10n.paymentBookingSummary
                : booking.stadiumName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (booking.pitchName.isNotEmpty)
            Text(
              '${booking.pitchName} · ${_pitchTypeLabel(l10n, booking.pitchType)}',
            ),
          Text(dateLabel),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('${booking.startTime} → ${booking.endTime}'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.paymentAmountLabel(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

String _pitchTypeLabel(AppLocalizations l10n, PitchType type) {
  switch (type) {
    case PitchType.fiveASide:
      return l10n.pitchTypeFiveASide;
    case PitchType.sevenASide:
      return l10n.pitchTypeSevenASide;
    case PitchType.elevenASide:
      return l10n.pitchTypeElevenASide;
    case PitchType.other:
      return l10n.pitchTypeOther;
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selected,
    required this.groupValue,
    required this.enabled,
    required this.onTap,
  });

  final StadiumPaymentMethod method;
  final bool selected;
  final StadiumPaymentMethodType? groupValue;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RadioListTile<StadiumPaymentMethodType>(
      value: method.method,
      groupValue: groupValue,
      onChanged: enabled ? (_) => onTap() : null,
      selected: selected,
      title: Text(_methodLabel(l10n, method.method)),
      subtitle:
          method.instructions == null || method.instructions!.isEmpty
              ? null
              : Text(
                method.instructions!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
    );
  }
}

String _methodLabel(AppLocalizations l10n, StadiumPaymentMethodType method) {
  switch (method) {
    case StadiumPaymentMethodType.cash:
      return l10n.paymentMethodCash;
    case StadiumPaymentMethodType.bankak:
      return l10n.paymentMethodBankak;
    case StadiumPaymentMethodType.bankTransfer:
      return l10n.paymentMethodBankTransfer;
  }
}

class _MethodDetails extends StatelessWidget {
  const _MethodDetails({required this.method});

  final StadiumPaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (method.method == StadiumPaymentMethodType.cash) {
      return Text(
        method.instructions?.isNotEmpty == true
            ? method.instructions!
            : l10n.paymentCashInstructions,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final rows = <(String, String)>[];
    if (method.accountName?.isNotEmpty == true) {
      rows.add((l10n.paymentAccountHolder, method.accountName!));
    }
    if (method.accountNumber?.isNotEmpty == true) {
      rows.add((l10n.paymentAccountNumber, method.accountNumber!));
    }
    if (method.bankName?.isNotEmpty == true) {
      rows.add((l10n.paymentBankName, method.bankName!));
    }
    if (method.iban?.isNotEmpty == true) {
      rows.add((l10n.paymentIban, method.iban!));
    }
    if (method.phoneNumber?.isNotEmpty == true) {
      rows.add((l10n.paymentPhoneNumber, method.phoneNumber!));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    row.$1,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      row.$2,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (method.instructions?.isNotEmpty == true) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(method.instructions!),
        ],
      ],
    );
  }
}

class _ReceiptPicker extends StatelessWidget {
  const _ReceiptPicker({
    required this.receipt,
    required this.enabled,
    required this.progress,
    required this.phase,
    required this.onPick,
    required this.onClear,
  });

  final SelectedReceiptFile? receipt;
  final bool enabled;
  final double? progress;
  final PaymentUiPhase phase;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.paymentReceiptTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.paymentReceiptHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (receipt == null)
          OutlinedButton.icon(
            onPressed: enabled ? onPick : null,
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.paymentChooseReceipt),
          )
        else ...[
          Text(receipt!.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            l10n.paymentReceiptSize(_formatBytes(receipt!.sizeBytes)),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              TextButton(
                onPressed: enabled ? onPick : null,
                child: Text(l10n.paymentReplaceReceipt),
              ),
              TextButton(
                onPressed: enabled ? onClear : null,
                child: Text(l10n.paymentRemoveReceipt),
              ),
            ],
          ),
        ],
        if (progress != null &&
            (phase == PaymentUiPhase.uploading ||
                phase == PaymentUiPhase.requestingIntent)) ...[
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(value: progress == 0 ? null : progress),
          Text(l10n.paymentUploading),
        ],
      ],
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}

class _SubmittedBody extends StatelessWidget {
  const _SubmittedBody({
    required this.booking,
    required this.payment,
    required this.localeCode,
  });

  final CustomerBooking? booking;
  final PaymentRecord? payment;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final amount =
        booking == null
            ? '—'
            : SdgFormatter.format(booking!.priceSdg, locale: localeCode);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const Icon(Icons.hourglass_top, size: 48, color: AppColors.brandDeep),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.paymentSubmittedTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.paymentSubmittedBody),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.paymentSubmittedNotConfirmed,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        if (booking != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _SummaryCard(booking: booking!, localeCode: localeCode),
        ],
        if (payment != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(l10n.paymentMethodLabel(_methodLabel(l10n, payment!.method))),
          Text(l10n.paymentAmountLabel(amount)),
          Text(l10n.paymentStatusLabel(l10n.paymentStatusSubmitted)),
        ],
      ],
    );
  }
}

class _RejectedBody extends StatelessWidget {
  const _RejectedBody({
    required this.booking,
    required this.payment,
    required this.remainingHold,
    required this.onRetry,
  });

  final CustomerBooking? booking;
  final PaymentRecord? payment;
  final Duration? remainingHold;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reason = payment?.rejectionReason;
    final holdStillValid =
        booking != null &&
        booking!.isPending &&
        !(remainingHold == Duration.zero);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          l10n.paymentRejectedTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          reason == null || reason.isEmpty
              ? l10n.paymentRejectedBodyGeneric
              : l10n.paymentRejectedBody(reason),
        ),
        if (holdStillValid && remainingHold != null) ...[
          const SizedBox(height: AppSpacing.md),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              l10n.paymentHoldRemaining(formatHoldCountdown(remainingHold)),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (holdStillValid)
          FilledButton(
            onPressed: onRetry,
            child: Text(l10n.paymentUploadAnotherReceipt),
          ),
      ],
    );
  }
}

class _ConfirmedBody extends StatelessWidget {
  const _ConfirmedBody({required this.booking});

  final CustomerBooking? booking;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 48, color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.paymentConfirmedTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.paymentConfirmedBody),
          if (booking != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(booking!.stadiumName),
            Text(booking!.pitchName),
          ],
        ],
      ),
    );
  }
}

class _ExpiredBody extends StatelessWidget {
  const _ExpiredBody({required this.onChooseAnother});

  final VoidCallback onChooseAnother;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentExpiredTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.paymentExpiredBody),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: onChooseAnother,
            child: Text(l10n.paymentExpiredChooseAnother),
          ),
        ],
      ),
    );
  }
}

class _FailureBody extends StatelessWidget {
  const _FailureBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Text(message),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onRetry, child: Text(l10n.paymentRetryLoad)),
        ],
      ),
    );
  }
}
