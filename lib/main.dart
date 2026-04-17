import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait on phones
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Register StorageService as a permanent GetX singleton
  await Get.putAsync<StorageService>(
    () async {
      final s = StorageService();
      s.onInit();
      return s;
    },
    permanent: true,
  );

  // Always start with splash — it handles navigation to login/dashboard
  runApp(const EskooliaApp(initialRoute: AppRoutes.splash));
}

class EskooliaApp extends StatelessWidget {
  final String initialRoute;
  const EskooliaApp({super.key, this.initialRoute = AppRoutes.splash});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'eSkoolia',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => Scaffold(
          appBar: AppBar(title: const Text('Coming Soon')),
          body: const Center(
            child: Text('This module is not yet implemented.'),
          ),
        ),
      ),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 180),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF9FBFF),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF1F2937),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF374151)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
