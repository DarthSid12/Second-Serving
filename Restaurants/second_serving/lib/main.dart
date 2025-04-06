import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:second_serving/helper/colors.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add the new API key to the environment

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyD59LE9kzPv0xqlqCGnC5l4xUS7eLShTTs',
      appId: '1:426857757301:web:0634a16e0d3d217d1a963c',
      messagingSenderId: '426857757301',
      projectId: 'second-srving',
      authDomain: 'second-srving.firebaseapp.com',
      storageBucket: 'second-srving.firebasestorage.app',
      measurementId: 'G-3F273CP9ZX',
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Second Serving',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF1C1D1F), // Slate black background
        primaryColor: Color(0xFFA3C9A8), // Sage green accent
        colorScheme: ColorScheme.dark(
          primary: Color(0xFFA3C9A8), // Sage green
          secondary: Color(0xFFA3C9A8), // Sage green
          surface: Color(0xFF2E3239), // Olive gray card background
          onPrimary: Color(0xFFF8F9FA), // Nearly white text
          onSecondary: Color(0xFFF8F9FA), // Nearly white text
          onSurface: Color(0xFFF8F9FA), // Nearly white text
        ),
        textTheme: GoogleFonts.nunitoSansTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: Color(0xFFF8F9FA), // Nearly white text
          displayColor: Color(0xFFF8F9FA), // Nearly white text
        ),
        cardColor: Color(0xFF2E3239), // Olive gray card background
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF2E3239), // Olive gray input background
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), // Border radius
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: Color(0xFFF8F9FA).withOpacity(0.7)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFA3C9A8), // Sage green
            foregroundColor: Color(0xFF1C1D1F), // Slate black text
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), // Border radius
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFFA3C9A8), // Sage green
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}