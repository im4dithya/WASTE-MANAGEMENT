import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'login.dart';

void main() {
  runApp(mainpage());
}

class mainpage extends StatelessWidget {
  const mainpage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: mainpagesub(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
      ),
    );
  }
}

class mainpagesub extends StatefulWidget {
  const mainpagesub({Key? key}) : super(key: key);

  @override
  State<mainpagesub> createState() => _mainpagesubState();
}

class _mainpagesubState extends State<mainpagesub> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController(text: "192.168.239.185");
  bool _isConnecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.blue[50]!,
              Colors.green[100]!,
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Stack(
                      children: [
                        // Background decorative elements
                        Positioned(
                          top: -30,
                          right: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.green[100]!.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -50,
                          left: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.blue[100]!.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // Content
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // App Logo and Title
                            Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(25),
                                    decoration: BoxDecoration(
                                      color: Colors.green[700],
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 15,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.recycling,
                                      size: 70,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 25),
                                  Text(
                                    "Eco Manager",
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Waste Management System",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Connect to your server",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 40),

                            // Connection Card
                            Container(
                              padding: EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.settings,
                                          color: Colors.green[700],
                                          size: 24,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Server Configuration",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[800],
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20),

                                    // IP Address Field
                                    Text(
                                      "Server IP Address",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    TextFormField(
                                      controller: name,
                                      decoration: InputDecoration(
                                        hintText: "Enter server IP address",
                                        prefixIcon: Icon(
                                          Icons.dns,
                                          color: Colors.green[700],
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            Icons.content_paste,
                                            color: Colors.green[700],
                                          ),
                                          onPressed: () async {
                                            ClipboardData? clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                                            if (clipboardData != null && clipboardData.text != null) {
                                              setState(() {
                                                name.text = clipboardData.text!;
                                              });
                                            }
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.green),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.green, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.green[50]!.withOpacity(0.3),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter server IP address';
                                        }

                                        // Basic IP validation pattern
                                        final ipPattern = RegExp(
                                            r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
                                        );

                                        if (!ipPattern.hasMatch(value)) {
                                          return 'Please enter a valid IP address (e.g., 192.168.1.1)';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                                      ],
                                    ),

                                    SizedBox(height: 15),

                                    // Example IP addresses
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(10),
                                        // border: Border.all(color: Colors.grey[200]),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Common IP Examples:",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Wrap(
                                            spacing: 10,
                                            children: [
                                              Chip(
                                                label: Text("192.168.1.1"),
                                                backgroundColor: Colors.green[100],
                                                onDeleted: () {
                                                  setState(() {
                                                    name.text = "192.168.1.1";
                                                  });
                                                },
                                                deleteIcon: Icon(Icons.arrow_back, size: 16),
                                              ),
                                              Chip(
                                                label: Text("10.0.0.1"),
                                                backgroundColor: Colors.blue[100],
                                                onDeleted: () {
                                                  setState(() {
                                                    name.text = "10.0.0.1";
                                                  });
                                                },
                                                deleteIcon: Icon(Icons.arrow_back, size: 16),
                                              ),
                                              Chip(
                                                label: Text("172.16.0.1"),
                                                backgroundColor: Colors.orange[100],
                                                onDeleted: () {
                                                  setState(() {
                                                    name.text = "172.16.0.1";
                                                  });
                                                },
                                                deleteIcon: Icon(Icons.arrow_back, size: 16),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 30),

                                    // Connection Status
                                    if (_isConnecting)
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(10),
                                          // border: Border.all(color: Colors.blue[200]),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                "Connecting to server...",
                                                style: TextStyle(
                                                  color: Colors.blue[800],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    SizedBox(height: 20),

                                    // Start Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed: _isConnecting
                                            ? null
                                            : () async {
                                          if (_formKey.currentState!.validate()) {
                                            setState(() {
                                              _isConnecting = true;
                                            });

                                            await _connectToServer();

                                            setState(() {
                                              _isConnecting = false;
                                            });
                                          }
                                        },
                                        child: _isConnecting
                                            ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text("CONNECTING..."),
                                          ],
                                        )
                                            : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.play_arrow, size: 24),
                                            SizedBox(width: 10),
                                            Text(
                                              "START CONNECTION",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 5,
                                          shadowColor: Colors.green.withOpacity(0.5),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 15),

                                    // Additional Info
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info,
                                          color: Colors.grey[500],
                                          size: 16,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "Ensure your server is running on port 8000",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 30),

                            // Server Status Information
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.green[100]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Default port: 8000 • Format: http://IP:8000",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20),

                            // Footer
                            Text(
                              "© 2024 Eco Manager • Waste Management Solution",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Version 1.0.0",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
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

  Future<void> _connectToServer() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      sh.setString("ip", "http://${name.text}:8000");

      // Simulate connection delay for better UX
      await Future.delayed(Duration(seconds: 1));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text("Connected successfully!"),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Navigate to login page
      await Future.delayed(Duration(milliseconds: 1500));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => login()),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text("Connection failed. Please try again."),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}







// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'login.dart';
//
// void main(){
//   runApp(mainpage());
// }
//
// class mainpage extends StatelessWidget {
//   const mainpage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: mainpagesub(),);
//   }
// }
//
//
// class mainpagesub extends StatefulWidget {
//   const mainpagesub({Key? key}) : super(key: key);
//
//   @override
//   State<mainpagesub> createState() => _mainpagesubState();
// }
//
// class _mainpagesubState extends State<mainpagesub> {
//   @override
//   Widget build(BuildContext context) {
//     TextEditingController name=TextEditingController(text: "192.168.152.185");
//     return Scaffold(body: SingleChildScrollView(child: Column(
//       children: [
//         SizedBox(height: 20,),
//         SizedBox(width: 200,child: TextField(controller:name,decoration: InputDecoration(
//           hintText: "ip",border:
//             OutlineInputBorder(borderRadius: BorderRadius.circular(12))
//         ),),),
//
//         SizedBox(height: 20,),
//         ElevatedButton(onPressed: ()async{
//           SharedPreferences sh =await SharedPreferences.getInstance();
//           sh.setString("ip","http://${name.text}:8000");
//           Navigator.push(context,MaterialPageRoute(builder: (context)=>login()));
//         }, child: Text("START"))
//       ],
//     ),),);
//   }
// }
