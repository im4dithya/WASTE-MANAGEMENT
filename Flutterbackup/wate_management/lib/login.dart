
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wate_management/Home.dart';
import 'package:wate_management/register.dart';
import 'package:http/http.dart' as http;

void main(){
  runApp(login());
}

class login extends StatelessWidget {
  const login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: loginsub(),
      theme: ThemeData(
        primaryColor: Color(0xFF2E7D32),
        fontFamily: 'Poppins',
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class loginsub extends StatefulWidget {
  const loginsub({Key? key}) : super(key: key);

  @override
  State<loginsub> createState() => _loginsubState();
}

class _loginsubState extends State<loginsub> {
  TextEditingController username = TextEditingController(text: "ammu@gmail.com");
  TextEditingController password = TextEditingController(text: "Ammu@123");
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: Color(0xFFF5F9F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20.0 : screenWidth * 0.1,
                    vertical: isSmallScreen ? 16.0 : 24.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Spacer to push content down on large screens
                      if (!isSmallScreen) Expanded(flex: 1, child: SizedBox()),

                      // Logo and Welcome Section
                      Container(
                        margin: EdgeInsets.only(bottom: isSmallScreen ? 30.0 : 40.0),
                        child: Column(
                          children: [
                            Container(
                              width: isVerySmallScreen ? 60.0 : 80.0,
                              height: isVerySmallScreen ? 60.0 : 80.0,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2E7D32),
                                    Color(0xFF4CAF50),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(isVerySmallScreen ? 15.0 : 20.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF2E7D32).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.recycling_rounded,
                                size: isVerySmallScreen ? 30.0 : 40.0,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                            Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: isVerySmallScreen ? 24.0 : (isSmallScreen ? 28.0 : 32.0),
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B5E20),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isSmallScreen ? 4.0 : 8.0),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8.0 : 0.0),
                              child: Text(
                                "Sign in to your waste management account",
                                style: TextStyle(
                                  fontSize: isVerySmallScreen ? 13.0 : (isSmallScreen ? 14.0 : 16.0),
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Login Form Card
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: 500,
                        ),
                        padding: EdgeInsets.all(isSmallScreen ? 20.0 : 32.0),
                        margin: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 0.0 : screenWidth > 700 ? screenWidth * 0.15 : 0.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(isSmallScreen ? 20.0 : 24.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 25,
                              offset: Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Username Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email Address",
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 13.0 : 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1B5E20),
                                    // margin: EdgeInsets.only(bottom: 8, left: 4),
                                  ),
                                ),
                                TextFormField(
                                  controller: username,
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 14.0 : 15.0,
                                    color: Color(0xFF333333),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter your email",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: isVerySmallScreen ? 14.0 : null,
                                    ),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.only(right: 12),
                                      child: Icon(
                                        Icons.email_rounded,
                                        color: Color(0xFF2E7D32),
                                        size: isVerySmallScreen ? 18.0 : 20.0,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: isVerySmallScreen ? 14.0 : 16.0,
                                      horizontal: 12.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                            // Password Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Password",
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 13.0 : 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1B5E20),
                                    // margin: EdgeInsets.only(bottom: 8, left: 4),
                                  ),
                                ),
                                TextFormField(
                                  controller: password,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 14.0 : 15.0,
                                    color: Color(0xFF333333),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter your password",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: isVerySmallScreen ? 14.0 : null,
                                    ),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.only(right: 12),
                                      child: Icon(
                                        Icons.lock_rounded,
                                        color: Color(0xFF2E7D32),
                                        size: isVerySmallScreen ? 18.0 : 20.0,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                        color: Color(0xFF2E7D32),
                                        size: isVerySmallScreen ? 18.0 : 20.0,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: isVerySmallScreen ? 14.0 : 16.0,
                                      horizontal: 12.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isSmallScreen ? 6.0 : 8.0),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: isVerySmallScreen ? 13.0 : 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: isSmallScreen ? 20.0 : 28.0),

                            // Login Button
                            Container(
                              width: double.infinity,
                              height: isVerySmallScreen ? 48.0 : 54.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 14.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF2E7D32).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  SharedPreferences sh = await SharedPreferences.getInstance();
                                  var data = await http.post(
                                      Uri.parse("${sh.getString('ip')}/logiin_user"),
                                      body: {
                                        'username': username.text,
                                        'password': password.text
                                      }
                                  );
                                  var decodd = json.decode(data.body);

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  if (decodd['status'] == 'ok') {
                                    sh.setString('uid', decodd['uid'].toString());
                                    sh.setString("passw", password.text);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => home())
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: isSmallScreen ? 50.0 : 60.0,
                                                height: isSmallScreen ? 50.0 : 60.0,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFFFEBEE),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.error_outline_rounded,
                                                  color: Color(0xFFD32F2F),
                                                  size: isSmallScreen ? 25.0 : 30.0,
                                                ),
                                              ),
                                              SizedBox(height: isSmallScreen ? 16.0 : 20.0),
                                              Text(
                                                "Login Failed",
                                                style: TextStyle(
                                                  fontSize: isSmallScreen ? 18.0 : 20.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1B5E20),
                                                ),
                                              ),
                                              SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8.0 : 0.0),
                                                child: Text(
                                                  "Please enter a valid username and password",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: isSmallScreen ? 14.0 : 15.0,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: isSmallScreen ? 20.0 : 24.0),
                                              Container(
                                                width: double.infinity,
                                                height: isSmallScreen ? 44.0 : 48.0,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Color(0xFF2E7D32),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'OKAY',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                      fontSize: isSmallScreen ? 14.0 : null,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2E7D32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 14.0),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        Icons.login_rounded,
                                        size: isVerySmallScreen ? 18.0 : 20.0,
                                        color: Colors.white
                                    ),
                                    SizedBox(width: isVerySmallScreen ? 8.0 : 12.0),
                                    Text(
                                      "LOGIN",
                                      style: TextStyle(
                                        fontSize: isVerySmallScreen ? 14.0 : 15.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: isSmallScreen ? 24.0 : 32.0),

                            // Divider with OR text
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: isVerySmallScreen ? 13.0 : 14.0,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                            // Register Button
                            Container(
                              width: double.infinity,
                              height: isVerySmallScreen ? 48.0 : 54.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 14.0),
                                border: Border.all(
                                  color: Color(0xFF2E7D32),
                                  width: 2,
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => Register())
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 14.0),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: isVerySmallScreen ? 18.0 : 20.0,
                                        color: Color(0xFF2E7D32)
                                    ),
                                    SizedBox(width: isVerySmallScreen ? 8.0 : 12.0),
                                    Flexible(
                                      child: Text(
                                        "CREATE NEW ACCOUNT",
                                        style: TextStyle(
                                          fontSize: isVerySmallScreen ? 13.0 : 15.0,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2E7D32),
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                            // Footer Text
                            Text(
                              "Waste Management System",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: isVerySmallScreen ? 12.0 : 14.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isSmallScreen ? 2.0 : 4.0),
                            Text(
                              "© 2024 All rights reserved",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: isVerySmallScreen ? 10.0 : 12.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Spacer to push content up on large screens
                      if (!isSmallScreen) Expanded(flex: 1, child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// import 'dart:convert';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:wate_management/Home.dart';
// import 'package:wate_management/register.dart';
// import 'package:http/http.dart' as http;
//
// void main(){
//   runApp(login());
// }
//
// class login extends StatelessWidget {
//   const login({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: loginsub(),);
//   }
// }
//
// class loginsub extends StatefulWidget {
//   const loginsub({Key? key}) : super(key: key);
//
//   @override
//   State<loginsub> createState() => _loginsubState();
// }
//
// class _loginsubState extends State<loginsub> {
//   TextEditingController username=TextEditingController(text: "pry@gmail.com");
//   TextEditingController password=TextEditingController(text: "876");
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body:Center(child: Column(children: [TextField(controller: username,decoration: InputDecoration(hintText: "username",border: OutlineInputBorder())
//       ,),
//       TextField(controller: password,decoration: InputDecoration(hintText: "password",border: OutlineInputBorder())
//       ,),
//       ElevatedButton(onPressed: () async {
//         SharedPreferences sh=await SharedPreferences.getInstance();
//         var data=await http.post(Uri.parse("${sh.getString('ip')}/logiin_user"),body: {
//           'username':username.text,
//           'password':password.text
//         });
//         var decodd=json.decode(data.body);
//
//         if (decodd['status']=='ok'){
//           sh.setString('uid', decodd['uid'].toString());
//           sh.setString("passw", password.text);
//           Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//
//         }else{
//           showDialog(
//             context: context,
//             builder: (ctx) => AlertDialog(
//               title: const Text("Login"),
//               content: const Text("Please enter a valid username and password"),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(ctx).pop();
//                   },
//                   child: const Text("okay"),
//                 ),
//               ],
//             ),
//           );
//         }
//
//       }, child:Text("LOGIN") ),
//
//       ElevatedButton(onPressed: (){
//
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>Register()));
//
//       }, child:Text("REGISTER") ),
//     ],),),);
//   }
// }
//
