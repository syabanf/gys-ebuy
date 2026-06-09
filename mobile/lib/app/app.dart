import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class GysBuyerApp extends StatelessWidget {
  const GysBuyerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GYS E-Ordering',
      debugShowCheckedModeBanner: false,
      theme: buildGysTheme(),
      routerConfig: appRouter,
    );
  }
}
