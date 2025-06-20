import 'package:automation/screens/create_schedule_screen.dart';
import 'package:automation/screens/dashboard_screen.dart';
import 'package:automation/screens/login_screen.dart';
import 'package:automation/screens/schedule_screen.dart';
import 'package:automation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';

import 'helper/helper.dart';
import 'helper/noomikeys.dart';

void main() async {

  // to Change the color of status bar
  WidgetsFlutterBinding.ensureInitialized();SystemUiOverlayStyle systemUiOverlayStyle =
  const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

  // first method to run
  runApp(const MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme =  ThemeData(
        primaryColor: Helper.primaryColor,
        primaryColorDark: Helper.primaryColor,
        indicatorColor: Helper.primaryColor,
        hoverColor: Helper.primaryColor,
        progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Helper.primaryColor
        ),
        textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Helper.primaryColor
        ),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelStyle: TextStyle(color: Helper.primaryColor),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        drawerTheme: DrawerThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            surfaceTintColor: Colors.transparent
        ),
        fontFamily: "Poppins",
        appBarTheme: const AppBarTheme(
            backgroundColor: Helper.primaryColor,
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600
            ),
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0
        )
    );
    return OverlaySupport(
      child: MaterialApp(
          title: 'Warehouse',
          debugShowCheckedModeBanner: false,
          navigatorKey: NoomiKeys.navKey,
          theme: theme .copyWith(
            colorScheme:  theme.colorScheme.copyWith(secondary: Helper.primaryColor, primary: Helper.primaryColor, onSecondary: Helper.primaryColor),
          ),
          // home: SplashScreen() // run first screen of app
          home: DashboardScreen() // run first screen of app
      ),
    );
  }
}