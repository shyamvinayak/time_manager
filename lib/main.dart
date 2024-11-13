import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:time_manager/Routes/routes.dart';
import 'package:time_manager/splash_screen.dart';

import 'itemsProvider.dart';
import 'utils.dart';
import 'module/AttendanceDetails/DetailsScreen.dart';
import 'module/Dashboard/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: getInitialPage(),
        routes: <String, Widget Function(BuildContext)>{
          AppRoutes.splashScreen: (context) => const SplashScreen(),
          AppRoutes.dashboard: (context) => Dashboard(),
          AppRoutes.detailScreen: (context) => const DetailsScreen(),
        },
      ),
    );
  }

  String getInitialPage() => AppRoutes.splashScreen;
}
