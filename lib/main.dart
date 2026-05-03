import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'home_screen.dart';
import 'splash_screen.dart';
import 'add_screen.dart';


final ValueNotifier<ThemeMode> themeNotifier =
ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,


          themeMode: currentMode,


          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
          ),


          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
          ),

          initialRoute: "/",

          routes: {
            "/": (context) => const SplashScreen(),
            "/home": (context) => const HomeScreen(),
            "/add": (context) => const AddScreen(),
          },
        );
      },
    );
  }
}