import 'package:flutter/material.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_radii.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_l10n.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/widgets/catalog_filter_sheet.dart';

/// Primary Filters control + removable selected-value chips.
class CatalogFilterControls extends StatelessWidget {
  const CatalogFilterControls({
    super.key,
    required this.filters,
    required this.onApplied,
    this.onClearAll,
    this.dense = false,
  });

  final CatalogFilters filters;
  final ValueChanged<CatalogFilters> onApplied;
  final VoidCallback? onClearAll;
  final bool dense;

  Future<void> _openSheet(BuildContext context) async {
    final next = await showCatalogFilterSheet(
      context: context,
      initial: filters,
    );
    if (next != null) {
      onApplied(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activeCount =
        [
          filters.state,
          filters.city,
          filters.pitchType,
        ].whereType<Object>().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _openSheet(context),
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: Text(
                activeCount == 0
                    ? l10n.filtersAction
                    : '${l10n.filtersAction} · $activeCount',
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    activeCount > 0 ? AppColors.primarySoft : AppColors.surface,
                foregroundColor:
                    activeCount > 0
                        ? AppColors.onPrimarySoft
                        : AppColors.onSurface,
                minimumSize: Size(0, dense ? 40 : 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  side: BorderSide(
                    color:
                        activeCount > 0
                            ? AppColors.primary.withValues(alpha: 0.35)
                            : AppColors.outlineSubtle,
                  ),
                ),
              ),
            ),
            if (filters.hasAny && onClearAll != null) ...[
              const SizedBox(width: AppSpacing.xs),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(l10n.catalogClearFilters),
              ),
            ],
          ],
        ),
        if (filters.hasAny) ...[
          const SizedBox(height: AppSpacing.xs),
          ActiveFilterChips(filters: filters, onChanged: onApplied),
        ],
      ],
    );
  }
}

class ActiveFilterChips extends StatelessWidget {
  const ActiveFilterChips({
    super.key,
    required this.filters,
    required this.onChanged,
  });

  final CatalogFilters filters;
  final ValueChanged<CatalogFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chips = <Widget>[];

    if (filters.state != null) {
      chips.add(
        _RemovableChip(
          label: filters.state!.label(l10n),
          onDeleted: () => onChanged(filters.withState(null)),
        ),
      );
    }
    if (filters.city != null) {
      chips.add(
        _RemovableChip(
          label: filters.city!.label(l10n),
          onDeleted: () => onChanged(filters.copyWith(clearCity: true)),
        ),
      );
    }
    if (filters.pitchType != null) {
      chips.add(
        _RemovableChip(
          label: filters.pitchType!.label(l10n),
          onDeleted: () => onChanged(filters.copyWith(clearPitchType: true)),
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: chips,
    );
  }
}

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: AppColors.primarySoft,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.onPrimarySoft,
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
