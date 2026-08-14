import 'package:flutter/material.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_colors.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_radii.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';
import 'package:khamasiyat_mobile_app/features/catalog/domain/stadium_models.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/catalog_l10n.dart';
import 'package:khamasiyat_mobile_app/shared/geo/sudan_locations.dart';

/// Opens the modern filters bottom sheet. Returns applied filters, or null if dismissed.
Future<CatalogFilters?> showCatalogFilterSheet({
  required BuildContext context,
  required CatalogFilters initial,
}) {
  return showModalBottomSheet<CatalogFilters>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: CatalogFilterSheet(initial: initial),
      );
    },
  );
}

class CatalogFilterSheet extends StatefulWidget {
  const CatalogFilterSheet({super.key, required this.initial});

  final CatalogFilters initial;

  @override
  State<CatalogFilterSheet> createState() => _CatalogFilterSheetState();
}

class _CatalogFilterSheetState extends State<CatalogFilterSheet> {
  late CatalogFilters _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
  }

  List<SudanCity> get _cities {
    if (_draft.state == null) {
      return const [];
    }
    return SudanLocations.citiesForState(_draft.state!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.86;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.filtersSheetTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed:
                      () => setState(() => _draft = CatalogFilters.empty),
                  child: Text(l10n.filtersReset),
                ),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              children: [
                _SectionLabel(l10n.filterState),
                const SizedBox(height: AppSpacing.xs),
                _ChoiceWrap<SudanState>(
                  values: SudanState.values,
                  selected: _draft.state,
                  labelOf: (s) => s.label(l10n),
                  onSelected: (value) {
                    setState(() => _draft = _draft.withState(value));
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel(l10n.filterCity),
                const SizedBox(height: AppSpacing.xs),
                if (_draft.state == null)
                  Text(
                    l10n.filterAny,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  _ChoiceWrap<SudanCity>(
                    values: _cities,
                    selected: _draft.city,
                    labelOf: (c) => c.label(l10n),
                    onSelected: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          city: value,
                          clearCity: value == null,
                        );
                      });
                    },
                  ),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel(l10n.filterPitchType),
                const SizedBox(height: AppSpacing.xs),
                _ChoiceWrap<PitchType>(
                  values: PitchType.values,
                  selected: _draft.pitchType,
                  labelOf: (p) => p.label(l10n),
                  onSelected: (value) {
                    setState(() {
                      _draft = _draft.copyWith(
                        pitchType: value,
                        clearPitchType: value == null,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_draft),
                child: Text(l10n.filtersApply),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(color: AppColors.onSurfaceMuted),
    );
  }
}

class _ChoiceWrap<T> extends StatelessWidget {
  const _ChoiceWrap({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> values;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        _ChoiceChip(
          label: l10n.filterAny,
          selected: selected == null,
          onTap: () => onSelected(null),
        ),
        ...values.map(
          (value) => _ChoiceChip(
            label: labelOf(value),
            selected: selected == value,
            onTap: () => onSelected(value),
          ),
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primarySoft,
      checkmarkColor: AppColors.primary,
      backgroundColor: AppColors.surfaceMuted,
      side: BorderSide(
        color: selected ? AppColors.primary : Colors.transparent,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? AppColors.onPrimarySoft : AppColors.onSurface,
      ),
    );
  }
}
