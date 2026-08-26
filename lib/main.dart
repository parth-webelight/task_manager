import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/binding/all_controller_bindings.dart';
import 'package:task_manager/app/routes/app_pages.dart';
import 'app/core/themes/app_theme.dart';
import 'app/core/themes/theme_controller.dart';
import 'app/core/utils/session_manager.dart';
import 'app/localizations/delegation.dart';

import 'package:task_manager/app/core/widgets/connectivity_banner_overlay.dart';

import 'package:task_manager/app/services/notification_service.dart';

/// i push my code 07-08-26
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase Connected Successfully!');
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }
  try {
    await NotificationService().init();
    debugPrint('Notification Service Initialized!');
  } catch (e) {
    debugPrint('Notification Initialization Error: $e');
  }
  final themeController = Get.put(ThemeController());
  await themeController.loadThemeFromPrefs();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    SessionManager().getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(
          () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Task Manager',
            initialRoute: AppPage.INITIAL,
            getPages: AppPage.routes,
            initialBinding: AllControllerBinding(),
            locale: _locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('hi', ''),
              Locale('gu', ''),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            theme: AppTheme.getLightTheme(themeController.colorScheme),
            darkTheme: AppTheme.getDarkTheme(themeController.colorScheme),
            themeMode: themeController.themeMode,
            builder: (context, child) {
              return GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                behavior: HitTestBehavior.opaque,
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: ConnectivityBannerOverlay(child: child!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
