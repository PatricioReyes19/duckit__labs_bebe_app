import 'package:app_base/src/router/router.dart';
import 'package:flutter/material.dart';

class BebeApp extends StatelessWidget {
  const BebeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DuckIT BebéApp',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2F7194),
      ),
    );
  }
}
