import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wate_management/Home.dart';
import 'package:wate_management/login.dart';

void main() {
  runApp(changepassword());
}

class changepassword extends StatelessWidget {
  const changepassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: changepasswordsub(),
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
      ),
    );
  }
}

class changepasswordsub extends StatefulWidget {
  const changepasswordsub({Key? key}) : super(key: key);

  @override
  State<changepasswordsub> createState() => _changepasswordsubState();
}

class _changepasswordsubState extends State<changepasswordsub> {
  TextEditingController currentpassword = TextEditingController();
  TextEditingController newpassword = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _newPasswordError;
  String? _confirmPasswordError;

  void _validateNewPassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _newPasswordError = 'New password is required';
      });
    } else if (value.length < 6) {
      setState(() {
        _newPasswordError = 'Password must be at least 6 characters';
      });
    } else {
      setState(() {
        _newPasswordError = null;
      });
    }
  }

  void _validateConfirmPassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Please confirm your password';
      });
    } else if (value != newpassword.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
    } else {
      setState(() {
        _confirmPasswordError = null;
      });
    }
  }

  bool _isFormValid() {
    return currentpassword.text.isNotEmpty &&
        newpassword.text.isNotEmpty &&
        confirmpassword.text.isNotEmpty &&
        _newPasswordError == null &&
        _confirmPasswordError == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf8f9fa),
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
        leading: Container(
          margin: EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
            },
          ),
        ),
        title: Text(
          "Change Password",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        elevation: 2,
        shadowColor: Color(0xFF2E7D32).withOpacity(0.3),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Header Section
              _buildHeaderSection(),
              SizedBox(height: 32),

              // Password Form Card
              _buildPasswordForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF4CAF50),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF4CAF50).withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: 35,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Waste Management",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Color(0xFF1B5E20),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Update Your Password",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(28),
      child: Column(
        children: [
          // Current Password Field
          _buildPasswordField(
            controller: currentpassword,
            label: 'Current Password',
            hintText: 'Enter your current password',
            obscureText: _obscureCurrentPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureCurrentPassword = !_obscureCurrentPassword;
              });
            },
          ),
          SizedBox(height: 20),

          // New Password Field
          _buildNewPasswordField(),
          SizedBox(height: 20),

          // Confirm Password Field
          _buildConfirmPasswordField(),
          SizedBox(height: 32),

          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1B5E20),
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF1B5E20),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: Container(
                margin: EdgeInsets.only(right: 12, left: 8),
                child: Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1B5E20),
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: newpassword,
            obscureText: _obscureNewPassword,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF1B5E20),
            ),
            onChanged: (value) {
              _validateNewPassword(value);
              // Also validate confirm password when new password changes
              if (confirmpassword.text.isNotEmpty) {
                _validateConfirmPassword(confirmpassword.text);
              }
            },
            decoration: InputDecoration(
              hintText: 'Enter your new password',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: Container(
                margin: EdgeInsets.only(right: 12, left: 8),
                child: Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              errorText: _newPasswordError,
              errorStyle: TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 12,
              ),
            ),
          ),
        ),
        if (_newPasswordError != null)
          SizedBox(height: 4),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1B5E20),
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: confirmpassword,
            obscureText: _obscureConfirmPassword,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF1B5E20),
            ),
            onChanged: (value) {
              _validateConfirmPassword(value);
            },
            decoration: InputDecoration(
              hintText: 'Confirm your new password',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: Container(
                margin: EdgeInsets.only(right: 12, left: 8),
                child: Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              errorText: _confirmPasswordError,
              errorStyle: TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 12,
              ),
            ),
          ),
        ),
        if (_confirmPasswordError != null)
          SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2E7D32).withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading || !_isFormValid() ? null : () async {
          setState(() {
            _isLoading = true;
          });

          try {
            SharedPreferences sh = await SharedPreferences.getInstance();
            var response = await http.post(
              Uri.parse("${sh.getString('ip')}/changepassword_user"),
              body: {
                'uid': sh.getString('uid'),
                'passw': sh.getString('passw'),
                'current': currentpassword.text,
                'neww': newpassword.text,
                'confirm': confirmpassword.text
              },
            );

            // Reset loading state
            setState(() {
              _isLoading = false;
            });

            // Check response status
            if (response.statusCode == 200) {
              // Show success dialog
              _showSuccessDialog(context);
            } else {
              _showErrorDialog(context, 'Password Change Failed',
                  'Current Password Mismatch');
            }
          } catch (e) {
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog(context, 'Network Error',
                'Please check your internet connection and try again.${e}');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid() ? Color(0xFF2E7D32) : Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
            Icon(Icons.lock_open_rounded, size: 20, color: Colors.white),
            SizedBox(width: 12),
            Text(
              "UPDATE PASSWORD",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF4CAF50),
                  size: 30,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Password Updated!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Your password has been changed successfully. Please login again with your new password.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog

                    // Clear shared preferences if needed
                    _clearUserData().then((_) {
                      // Navigate to login page
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => login()),
                            (route) => false, // Remove all previous routes
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'CONTINUE TO LOGIN',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Future<void> _clearUserData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      // Clear only the password, or clear all user data if needed
      await sh.remove('pswd');
      // Alternatively, you can clear all user-related data:
      // await sh.remove('uid');
      // await sh.remove('pswd');
      // await sh.remove('ip');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFD32F2F),
                  size: 30,
                ),
              ),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
              SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'TRY AGAIN',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
}