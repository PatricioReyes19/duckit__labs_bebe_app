import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Filtros interactivos',
  type: BebeAgendaCategoryFilters,
  path: '[Organisms]/Agenda',
)
Widget bebeAgendaCategoryFiltersUseCase(
  BuildContext context,
) {
  return const _AgendaCategoryFiltersExample();
}

class _AgendaCategoryFiltersExample extends StatefulWidget {
  const _AgendaCategoryFiltersExample();

  @override
  State<_AgendaCategoryFiltersExample> createState() =>
      _AgendaCategoryFiltersExampleState();
}

class _AgendaCategoryFiltersExampleState
    extends State<_AgendaCategoryFiltersExample> {
  String _selectedId = 'all';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 430,
        ),
        child: BebeAgendaCategoryFilters(
          selectedId: _selectedId,
          onItemPressed: (id) {
            setState(() {
              _selectedId = id;
            });
          },
          items: const [
            BebeAgendaFilterData(
              id: 'all',
              label: 'Todos',
              icon: Icon(
                Icons.grid_view_rounded,
              ),
              variant: BebeFilterChipVariant.brand,
            ),
            BebeAgendaFilterData(
              id: 'vaccines',
              label: 'Vacunas',
              icon: Icon(
                Icons.vaccines_outlined,
              ),
              variant: BebeFilterChipVariant.accent,
            ),
            BebeAgendaFilterData(
              id: 'controls',
              label: 'Controles',
              icon: Icon(
                Icons.medical_services_outlined,
              ),
              variant: BebeFilterChipVariant.information,
            ),
            BebeAgendaFilterData(
              id: 'medication',
              label: 'Medicación',
              icon: Icon(
                Icons.medication_outlined,
              ),
              variant: BebeFilterChipVariant.warning,
            ),
            BebeAgendaFilterData(
              id: 'exams',
              label: 'Exámenes',
              icon: Icon(
                Icons.science_outlined,
              ),
              variant: BebeFilterChipVariant.information,
            ),
          ],
        ),
      ),
    );
  }
}
