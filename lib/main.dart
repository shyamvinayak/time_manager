import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:time_manager/Routes/routes.dart';
import 'package:time_manager/date_change_provider.dart';
import 'package:time_manager/splash_screen.dart';

import 'model/itemsProvider.dart';
import 'module/AttendanceDetails/userDetailsEntry.dart';
import 'utils.dart';
import 'module/AttendanceDetails/DetailsScreen.dart';
import 'module/Dashboard/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RestorationScope(
    restorationId: 'root',
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatePickerModel()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
      ],
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);  // Add observer for lifecycle events
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);  // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // Save the stopwatch state
      final stopwatchProvider = Provider.of<ItemsProvider>(context, listen: false);
      stopwatchProvider.saveStopwatchState();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: timeManger,
      restorationScopeId: 'application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: getInitialPage(),
      routes: <String, Widget Function(BuildContext)>{
        AppRoutes.splashScreen: (context) => const SplashScreen(),
        AppRoutes.dashboard: (context) => Dashboard(),
        AppRoutes.detailScreen: (context) => const DetailsScreen(),
        AppRoutes.userProfile: (context) => const UserDetailsEntry(),
      },
    );
  }

  String getInitialPage() => AppRoutes.splashScreen;
}

/*void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  */
/*await initializeService();*/
/*
  runApp(RestorationScope(
    restorationId: 'root',
    child: ChangeNotifierProvider(
      create: (context) => DatePickerModel(),
      child: const MyApp(),
    ),
  ));
}Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration:
        AndroidConfiguration(onStart: onStart, isForegroundMode: true),
  );
}@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 2), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
            title: 'Time Manager background service',
            content: "Check In:${DateTime.now()}");
      }
    }
  });
}class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: timeManger,
        restorationScopeId: 'application',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: getInitialPage(),
        routes: <String, Widget Function(BuildContext)>{
          AppRoutes.splashScreen: (context) => const SplashScreen(),
          AppRoutes.dashboard: (context) => Dashboard(),
          AppRoutes.detailScreen: (context) => const DetailsScreen(),
          AppRoutes.userProfile: (context) => const UserDetailsEntry(),
        },
      ),
    );
  }

  String getInitialPage() => AppRoutes.splashScreen;
}*/
