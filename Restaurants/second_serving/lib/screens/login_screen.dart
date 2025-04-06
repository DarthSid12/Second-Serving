import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:second_serving/helper/colors.dart';
import 'package:second_serving/helper/user.dart';
import 'package:second_serving/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'profile_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  // Controllers for all form fields
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLogin = true;
  bool loading = false;
  bool hidden = true;

  String? _selectedState = "California";

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    addressLine1Controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) async {
      final uid = prefs.getString('uid');
      if (uid != null) {
        try {
          DocumentSnapshot snapshot = await FirebaseFirestore.instance
              .collection('givers')
              .doc(uid)
              .get();
          if (snapshot.exists) {
            AppUser appUser =
                AppUser.fromJson(snapshot.data() as Map<String, dynamic>);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage(user: appUser)),
            );
          }
        } catch (e) {
          showError(e.toString());
        }
      }
    });
  }

  Future<void> handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user != null) {
        await saveLoginState(user.uid);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => ProfileScreen(userId: user.uid)),
        // );
      }
    } catch (e) {
      showError(e.toString());
    }
  }

  Future<void> saveLoginState(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $message")),
    );
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final name = nameController.text.trim();
    final dob = dobController.text.trim();
    final address1 = addressLine1Controller.text.trim();
    final address2 = addressLine2Controller.text.trim();
    final city = cityController.text.trim();
    final state = _selectedState;
    final email = emailController.text.trim();
    final password = passwordController.text;

    late AppUser appUser;

    try {
      UserCredential userCred;
      if (isLogin) {
        userCred = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('givers')
            .doc(userCred.user!.uid)
            .get();
        appUser = AppUser.fromJson(snapshot.data() as Map<String, dynamic>);
        if (userCred.user != null && !userCred.user!.emailVerified) {
          userCred.user?.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Verification email sent to $email. Please verify your email."),
            ),
          );
        } else {
          await saveLoginState(userCred.user!.uid);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => HomePage(
                      user: appUser,
                    )),
          );
        }
      } else {
        userCred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        appUser = AppUser.fromJson({
          'name': name,
          'dob': dob,
          'phone': phoneController.text.trim(),
          'uid': userCred.user!.uid,
          'addresses': [
            {
              'address1': address1,
              'address2': address2,
              'city': city,
              'state': state,
            }
          ],
          'email': email,
          'donations': 0,
          'mealsFed': 0,
        });
        await FirebaseFirestore.instance
            .collection('givers')
            .doc(userCred.user!.uid)
            .set(appUser.toJson());
        await userCred.user?.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Verification email sent to $email. Please verify your email."),
          ),
        );
        isLogin = true;
        emailController.clear();
        passwordController.clear();
        setState(() {});
      }
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1D1F), // Slate black background
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/logo.png'),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    (isLogin ? "Login" : "Sign Up").toUpperCase(),
                    style: GoogleFonts.nunitoSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF8F9FA), // Nearly white text
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Color(0xFFA3C9A8)), // Sage green
                    filled: true,
                    fillColor: Color(0xFF2E3239), // Olive gray input background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: Color(0xFFF8F9FA).withOpacity(0.7)), // Muted white
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Color(0xFFF8F9FA)), // Nearly white text
                  validator: (val) => val!.isEmpty ? 'Enter your email' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Color(0xFFA3C9A8)), // Sage green
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidden ? Icons.visibility : Icons.visibility_off,
                        color: Color(0xFFA3C9A8), // Sage green
                      ),
                      onPressed: () {
                        setState(() {
                          hidden = !hidden;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Color(0xFF2E3239), // Olive gray input background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: Color(0xFFF8F9FA).withOpacity(0.7)), // Muted white
                  ),
                  obscureText: hidden,
                  style: TextStyle(color: Color(0xFFF8F9FA)), // Nearly white text
                  validator: (val) =>
                      val!.length < 6 ? 'Minimum 6 characters' : null,
                ),
                SizedBox(height: 10),
                if (!isLogin) ...[
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: 'Name/Restaurant Name',
                        prefixIcon: Icon(Icons.person)),
                    validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: dobController,
                    readOnly: true,
                    onTap: () async {
                      FocusScope.of(context)
                          .unfocus(); // Close keyboard if open

                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: MyColors.primary,
                                onPrimary: MyColors.textColor,
                                surface: MyColors.darkBackground,
                                onSurface: MyColors.textColor,
                              ),
                              dialogBackgroundColor: MyColors.darkBackground,
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedDate != null) {
                        dobController.text =
                            "${pickedDate.toLocal()}".split(' ')[0];
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      labelStyle:
                          TextStyle(color: MyColors.textColor.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.calendar_today,
                          color: MyColors.textColor.withOpacity(0.7)),
                      // filled: true,
                      // fillColor: MyColors.darkBackground.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: MyColors.textColor),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number (Without Country code)',
                      prefixIcon: Icon(Icons.phone),
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(10),
                      // ),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ], // Limit input to 15 characters (for international numbers)
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }

                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: addressLine1Controller,
                    decoration: InputDecoration(labelText: 'Address Line 1'),
                    validator: (val) =>
                        val!.isEmpty ? 'Enter your address' : null,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: addressLine2Controller,
                    decoration: InputDecoration(labelText: 'Address Line 2'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(labelText: 'City'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(10), // Adjust padding if needed
                    decoration: BoxDecoration(
                      // color: Colors.grey.withOpacity(0.2), // Light grey background color (adjust if needed)
                      borderRadius:
                          BorderRadius.circular(8), // Optional rounded corners
                      // border: Border.all(
                      //     color: Colors.grey, width: 1), // Optional border
                    ),
                    child: DropdownButton<String>(
                      value: _selectedState,
                      hint: Text("Choose a state"),
                      isExpanded:
                          true, // Ensures the dropdown stretches across the screen
                      iconSize: 30,
                      onChanged: (newState) {
                        setState(() {
                          _selectedState = newState;
                        });
                      },
                      items: MyColors.states
                          .map<DropdownMenuItem<String>>((String state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Text(state),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: loading ? null : submit,
                    child: Text(
                      isLogin ? 'Login' : 'Sign Up',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1D1F), // Slate black text
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA3C9A8), // Sage green
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin
                          ? "Don't have an account? Sign Up"
                          : "Already have an account? Login",
                      style: GoogleFonts.nunitoSans(
                        color: Color(0xFFA3C9A8), // Sage green
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
