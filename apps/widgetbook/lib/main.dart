import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(const DuckItWidgetbookApp());
}

class DuckItWidgetbookApp extends StatelessWidget {
  const DuckItWidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookComponent(
          name: 'Atoms',
          useCases: [
            WidgetbookUseCase(
              name: 'Base text',
              builder: (context) {
                return const Center(
                  child: Text('DuckIT BebéApp Design System'),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
