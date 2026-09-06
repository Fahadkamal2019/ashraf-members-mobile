import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_theme.dart';
import 'core/fcm_service.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MembersApp()));
  // Not awaited, and deliberately called after runApp(): FcmService.initialize() calls
  // FirebaseMessaging.requestPermission(), which presents a native iOS permission dialog. Doing
  // that before the Flutter engine has an actual window/view ready to present on hangs forever
  // on iOS (blank white screen, no crash) - this was only ever exercised on Android before, which
  // has no such restriction.
  unawaited(FcmService.initialize());
}

class MembersApp extends ConsumerWidget {
  const MembersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'بوابة الأعضاء',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
