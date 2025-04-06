import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:second_serving/helper/colors.dart';
import 'screens/login_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Second Serving',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: MyColors.darkBackground,
        primaryColor: MyColors.primary,
        colorScheme: ColorScheme.dark(
          primary: MyColors.primary,
          secondary: MyColors.accentGreen,
          surface: MyColors.primary,
          onPrimary: MyColors.textColor,
          onSecondary: MyColors.textColor,
          onSurface: MyColors.textColor,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: MyColors.textColor,
              displayColor: MyColors.textColor,
            ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: MyColors.textColor.withOpacity(0.7)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.primary,
            foregroundColor: MyColors.textColor,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: MyColors.accentGreen,
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}