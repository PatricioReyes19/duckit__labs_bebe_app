import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeAgendaFilterData {
  const BebeAgendaFilterData({
    required this.id,
    required this.label,
    required this.variant,
    this.icon,
    this.enabled = true,
    this.semanticLabel,
  });

  final String id;
  final String label;
  final Widget? icon;
  final BebeFilterChipVariant variant;
  final bool enabled;
  final String? semanticLabel;
}

class BebeAgendaCategoryFilters extends StatefulWidget {
  const BebeAgendaCategoryFilters({
    required this.items,
    required this.selectedId,
    required this.onItemPressed,
    this.semanticLabel,
    super.key,
  });

  final List<BebeAgendaFilterData> items;
  final String selectedId;
  final ValueChanged<String> onItemPressed;
  final String? semanticLabel;

  @override
  State<BebeAgendaCategoryFilters> createState() {
    return _BebeAgendaCategoryFiltersState();
  }
}

class _BebeAgendaCategoryFiltersState extends State<BebeAgendaCategoryFilters> {
  late final ScrollController _scrollController;
  late Map<String, GlobalKey> _itemKeys;

  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  static const double _containerHeight = 52;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(_updateScrollIndicators);

    _itemKeys = {for (final item in widget.items) item.id: GlobalKey()};

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollIndicators();
      _ensureSelectedFilterVisible();
    });
  }

  @override
  void didUpdateWidget(covariant BebeAgendaCategoryFilters oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items != widget.items) {
      _itemKeys = {
        for (final item in widget.items)
          item.id: _itemKeys[item.id] ?? GlobalKey(),
      };
    }

    if (oldWidget.selectedId != widget.selectedId ||
        oldWidget.items != widget.items) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScrollIndicators();
        _ensureSelectedFilterVisible();
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollIndicators)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.items.isNotEmpty);

    assert(widget.items.any((item) => item.id == widget.selectedId));

    final spacing = context.theme.spacing;

    final filters = ListView.separated(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: spacing.spacingXs),
      itemCount: widget.items.length,
      separatorBuilder: (_, _) {
        return SizedBox(width: spacing.spacingS);
      },
      itemBuilder: (context, index) {
        final item = widget.items[index];

        return KeyedSubtree(
          key: _itemKeys[item.id],
          child: BebeFilterChip(
            label: item.label,
            icon: item.icon,
            variant: item.variant,
            size: BebeFilterChipSize.medium,
            isSelected: item.id == widget.selectedId,
            enabled: item.enabled,
            semanticLabel: item.semanticLabel,
            onPressed: item.enabled
                ? () => widget.onItemPressed(item.id)
                : null,
          ),
        );
      },
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel ?? 'Filtros de la agenda',
      child: SizedBox(
        width: double.infinity,
        height: _containerHeight,
        child: filters,
      ),
    );
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    final canScrollLeft = position.pixels > position.minScrollExtent;

    final canScrollRight = position.pixels < position.maxScrollExtent;

    if (canScrollLeft == _canScrollLeft && canScrollRight == _canScrollRight) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _canScrollLeft = canScrollLeft;
      _canScrollRight = canScrollRight;
    });
  }

  void _ensureSelectedFilterVisible() {
    final selectedContext = _itemKeys[widget.selectedId]?.currentContext;

    if (selectedContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      selectedContext,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: 0.5,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }
}
