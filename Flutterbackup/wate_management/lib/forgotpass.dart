
import 'forgotemail.dart';
import 'login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(forgotpass());
}

class forgotpass extends StatelessWidget {
  const forgotpass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: forgotpasssub(),
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
    );
  }
}

class forgotpasssub extends StatefulWidget {
  const forgotpasssub({Key? key}) : super(key: key);

  @override
  State<forgotpasssub> createState() => _forgotpasssubState();
}

class _forgotpasssubState extends State<forgotpasssub> {
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (password.text != confirmpassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      await http.post(
        Uri.parse("${sh.getString("ip")}/forgotpass"),
        body: {
          'email': sh.getString('email'),
          'password': password.text,
          'confirmpassword': confirmpassword.text
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reset password. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to determine font size based on screen width
  double _getFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 350) return baseSize - 2;
    if (width > 600) return baseSize + 2;
    return baseSize;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 350;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : isLargeScreen ? 32 : 24,
                      vertical: isSmallScreen ? 16 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: Colors.grey[700],
                              size: isSmallScreen ? 22 : 24),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => forgotemail()));
                          },
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),

                        // Main Content - Centered
                        Expanded(
                          child: Center(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 500,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Header Section
                                  Container(
                                    margin: EdgeInsets.only(bottom: 32),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.lock_reset,
                                          size: isSmallScreen ? 60 : isLargeScreen ? 90 : 80,
                                          color: Color(0xFF2E7D32),
                                        ),
                                        SizedBox(height: isSmallScreen ? 12 : 20),
                                        Text(
                                          'Reset Password',
                                          style: TextStyle(
                                            fontSize: _getFontSize(context, 28),
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E7D32),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: isSmallScreen ? 8 : 12),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 8 : 0,
                                          ),
                                          child: Text(
                                            "Create a new password for your account",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: _getFontSize(context, 16),
                                              color: Colors.grey[600],
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Password Reset Card
                                  Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'New Password',
                                              style: TextStyle(
                                                fontSize: _getFontSize(context, 18),
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            SizedBox(height: isSmallScreen ? 16 : 20),

                                            // Password Field
                                            TextFormField(
                                              controller: password,
                                              obscureText: _obscurePassword,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please enter a password';
                                                }
                                                if (value.length < 6) {
                                                  return 'Password must be at least 6 characters';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                labelText: "New Password",
                                                labelStyle: TextStyle(
                                                  fontSize: _getFontSize(context, 14),
                                                ),
                                                prefixIcon: Icon(Icons.lock_outline,
                                                    color: Colors.grey[600],
                                                    size: isSmallScreen ? 20 : 24),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                                    color: Colors.grey[600],
                                                    size: isSmallScreen ? 20 : 24,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscurePassword = !_obscurePassword;
                                                    });
                                                  },
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: Colors.grey[400]!),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: Colors.grey[400]!),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: Colors.red),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: Colors.red, width: 2),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: isSmallScreen ? 14 : 16,
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontSize: _getFontSize(context, 14),
                                              ),
                                            ),

                                            SizedBox(height: isSmallScreen ? 12 : 16),

                                            // Confirm Password Field
                                            TextFormField(
                                              controller: confirmpassword,
                                              obscureText: _obscureConfirmPassword,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please confirm your password';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                labelText: "Confirm New Password",
                                                labelStyle: TextStyle(
                                                  fontSize: _getFontSize(context, 14),
                                                ),
                                                prefixIcon: Icon(Icons.lock_outline,
                                                    color: Colors.grey[600],
                                                    size: isSmallScreen ? 20 : 24),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                                    color: Colors.grey[600],
                                                    size: isSmallScreen ? 20 : 24,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                                    });
                                                  },
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: Colors.grey[400]!),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: Colors.grey[400]!),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: Colors.red),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: Colors.red, width: 2),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: isSmallScreen ? 14 : 16,
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontSize: _getFontSize(context, 14),
                                              ),
                                            ),

                                            SizedBox(height: isSmallScreen ? 8 : 12),

                                            // Password Requirements
                                            Container(
                                              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Password Requirements:',
                                                    style: TextStyle(
                                                      fontSize: _getFontSize(context, 12),
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.green[800],
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    '• At least 6 characters long',
                                                    style: TextStyle(
                                                      fontSize: _getFontSize(context, 11),
                                                      color: Colors.green[700],
                                                    ),
                                                  ),
                                                  Text(
                                                    '• Make sure both passwords match',
                                                    style: TextStyle(
                                                      fontSize: _getFontSize(context, 11),
                                                      color: Colors.green[700],
                                                    ),
                                                  ),
                                                  if (isLargeScreen) ...[
                                                    Text(
                                                      '• Use a mix of letters, numbers, and symbols',
                                                      style: TextStyle(
                                                        fontSize: _getFontSize(context, 11),
                                                        color: Colors.green[700],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: isSmallScreen ? 24 : 32),

                                  // Reset Password Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: isSmallScreen ? 48 : 56,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _resetPassword,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF2E7D32),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                        height: isSmallScreen ? 18 : 20,
                                        width: isSmallScreen ? 18 : 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                          : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.lock_reset,
                                              size: isSmallScreen ? 18 : 20,
                                              color: Colors.white),
                                          SizedBox(width: isSmallScreen ? 6 : 8),
                                          Text(
                                            'RESET PASSWORD',
                                            style: TextStyle(
                                              fontSize: _getFontSize(context, 16),
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: isSmallScreen ? 16 : 20),

                                  // Security Info - Responsive layout
                                  Container(
                                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: isSmallScreen
                                        ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.security,
                                              color: Color(0xFF2E7D32),
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Security Notice",
                                              style: TextStyle(
                                                fontSize: _getFontSize(context, 14),
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2E7D32),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Your password has been securely updated. You can now log in with your new password.",
                                          style: TextStyle(
                                            fontSize: _getFontSize(context, 12),
                                            color: Colors.green[800],
                                          ),
                                        ),
                                      ],
                                    )
                                        : Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 2),
                                          child: Icon(
                                            Icons.security,
                                            color: Color(0xFF2E7D32),
                                            size: isSmallScreen ? 18 : 20,
                                          ),
                                        ),
                                        SizedBox(width: isSmallScreen ? 8 : 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Security Notice",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF2E7D32),
                                                  fontSize: _getFontSize(context, 14),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "Your password has been securely updated. You can now log in with your new password.",
                                                style: TextStyle(
                                                  fontSize: _getFontSize(context, 12),
                                                  color: Colors.green[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Additional Tips for Large Screens
                                  if (isLargeScreen) ...[
                                    SizedBox(height: 20),
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.tips_and_updates,
                                            color: Color(0xFF2E7D32),
                                            size: 20,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Password Tips",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF2E7D32),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  "For better security, avoid using personal information and don't reuse passwords across different sites.",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom Spacer
                        SizedBox(height: isSmallScreen ? 20 : 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}










// import 'forgotemail.dart';
// import 'login.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() {
//   runApp(forgotpass());
// }
//
// class forgotpass extends StatelessWidget {
//   const forgotpass({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: forgotpasssub(),
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Roboto',
//       ),
//     );
//   }
// }
//
// class forgotpasssub extends StatefulWidget {
//   const forgotpasssub({Key? key}) : super(key: key);
//
//   @override
//   State<forgotpasssub> createState() => _forgotpasssubState();
// }
//
// class _forgotpasssubState extends State<forgotpasssub> {
//   TextEditingController password = TextEditingController();
//   TextEditingController confirmpassword = TextEditingController();
//
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//
//   Future<void> _resetPassword() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     if (password.text != confirmpassword.text) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Passwords do not match'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       await http.post(
//         Uri.parse("${sh.getString("ip")}/forgotpass"),
//         body: {
//           'email': sh.getString('email'),
//           'password': password.text,
//           'confirmpassword': confirmpassword.text
//         },
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Password reset successfully!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to reset password. Please try again.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 // Back Button
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: IconButton(
//                     icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
//                     onPressed: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (context) => forgotemail()));
//                     },
//                   ),
//                 ),
//
//                 // Header Section
//                 Container(
//                   margin: EdgeInsets.only(top: 20, bottom: 40),
//                   child: Column(
//                     children: [
//                       Icon(
//                         Icons.lock_reset,
//                         size: 80,
//                         color: Color(0xFF1976D2),
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         'Reset Password',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1976D2),
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       Text(
//                         "Create a new password for your account",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[600],
//                           height: 1.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Password Reset Card
//                 Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(24),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'New Password',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[800],
//                             ),
//                           ),
//                           SizedBox(height: 20),
//
//                           // Password Field
//                           TextFormField(
//                             controller: password,
//                             obscureText: _obscurePassword,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter a password';
//                               }
//                               if (value.length < 6) {
//                                 return 'Password must be at least 6 characters';
//                               }
//                               return null;
//                             },
//                             decoration: InputDecoration(
//                               labelText: "New Password",
//                               prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                                   color: Colors.grey[600],
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _obscurePassword = !_obscurePassword;
//                                   });
//                                 },
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.grey[400]!),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.grey[400]!),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
//                               ),
//                               errorBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.red),
//                               ),
//                               focusedErrorBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.red, width: 2),
//                               ),
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                             ),
//                           ),
//
//                           SizedBox(height: 16),
//
//                           // Confirm Password Field
//                           TextFormField(
//                             controller: confirmpassword,
//                             obscureText: _obscureConfirmPassword,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please confirm your password';
//                               }
//                               return null;
//                             },
//                             decoration: InputDecoration(
//                               labelText: "Confirm New Password",
//                               prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
//                                   color: Colors.grey[600],
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _obscureConfirmPassword = !_obscureConfirmPassword;
//                                   });
//                                 },
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.grey[400]!),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.grey[400]!),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
//                               ),
//                               errorBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.red),
//                               ),
//                               focusedErrorBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.red, width: 2),
//                               ),
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                             ),
//                           ),
//
//                           SizedBox(height: 8),
//
//                           // Password Requirements
//                           Container(
//                             padding: EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.blue[50],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Password Requirements:',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.blue[800],
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   '• At least 6 characters long',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: Colors.blue[700],
//                                   ),
//                                 ),
//                                 Text(
//                                   '• Make sure both passwords match',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: Colors.blue[700],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(height: 30),
//
//                 // Reset Password Button
//                 Container(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _resetPassword,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF1976D2),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 2,
//                     ),
//                     child: _isLoading
//                         ? SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                         : Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.lock_reset, size: 20, color: Colors.white),
//                         SizedBox(width: 8),
//                         Text(
//                           'RESET PASSWORD',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(height: 20),
//
//                 // Security Info
//                 Container(
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.green[50],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.security,
//                         color: Colors.green,
//                         size: 20,
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           "Your password has been securely updated. You can now log in with your new password.",
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.green[800],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
