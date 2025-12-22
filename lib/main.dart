import 'dart:ui';

import 'package:Annujoom/firebase_options.dart';
import 'package:Annujoom/src/data/services/crashlytics_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/services/navigation_service.dart';
import 'package:Annujoom/src/data/services/notification_service/notification_service.dart';
import 'package:Annujoom/src/data/utils/install_checker.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/data/router/router.dart' as router;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  final checker = InstallChecker();
  await checker.checkFirstInstall();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await CrashlyticsService.setCrashlyticsCollectionEnabled(true);

  await dotenv.load(fileName: ".env");
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ml')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = ref.watch(notificationServiceProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      notificationService.initialize();
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      scaffoldMessengerKey: SnackbarService.scaffoldMessengerKey,
      onGenerateRoute: router.generateRoute,
      initialRoute: 'Splash',
      title: 'ANNUJOOM',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        fontFamily: 'Manrope',
        useMaterial3: true,
      ),
      builder: (context, child) {
        return SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: child,
          ),
        );
      },
    );
  }
}
