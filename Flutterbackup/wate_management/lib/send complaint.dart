import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Home.dart';

void main() {
  runApp(sendcomplaint());
}

class sendcomplaint extends StatelessWidget {
  const sendcomplaint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: sendcomplaint_sub(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
    );
  }
}

class sendcomplaint_sub extends StatefulWidget {
  const sendcomplaint_sub({Key? key}) : super(key: key);

  @override
  State<sendcomplaint_sub> createState() => _State();
}

class _State extends State<sendcomplaint_sub> {
  TextEditingController complaint = TextEditingController();
  bool _isSubmitting = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  // Validation function
  String? _validateComplaint(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please describe your complaint';
    }
    if (value.trim().length < 10) {
      return 'Complaint should be at least 10 characters';
    }
    if (value.trim().length > 500) {
      return 'Complaint should not exceed 500 characters';
    }
    return null;
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }



    setState(() => _isSubmitting = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      var data = await http.post(
        Uri.parse("${sh.getString('ip')}/sendcomplaint"),
        body: {
          'complaint': complaint.text,
          'uid': sh.getString("uid"),
        },
      );

      if (data.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(Duration(milliseconds: 1500));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => home()),
        );
      } else {
        throw Exception('Server error: ${data.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit complaint: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Report Waste Issue",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 2,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => home()),
            );
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Go Back',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => home()),
              );
            },
            tooltip: 'Go Home',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.report_problem,
                                color: Colors.green[700], size: 28),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'File a Complaint',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Report waste management issues. Your feedback helps us improve services.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25),

              // Complaint Type Selection

              SizedBox(height: 25),

              // Complaint Details
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: Colors.green[700], size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Complaint Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: complaint,
                        maxLines: 6,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText: 'Describe the issue in detail...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.green, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.red, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(16),
                          prefixIcon: Icon(Icons.edit, color: Colors.green[600]),
                          suffixIcon: complaint.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => complaint.clear()),
                          )
                              : null,
                        ),
                        validator: _validateComplaint,
                        onChanged: (value) => setState(() {}),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue[700], size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please be specific about location, time, and nature of the waste issue',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${complaint.text.length}/500',
                          style: TextStyle(
                            color: complaint.text.length > 450
                                ? Colors.orange[800]
                                : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Tips Card
              Card(
                elevation: 0,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue[100]!),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: Colors.orange[700], size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tips for Effective Complaints:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '• Mention exact location\n• Specify date/time of incident\n• Describe waste type and quantity\n• Include any safety concerns',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Submitting...'),
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Submit Complaint',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => home()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Footer Note
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.green[700], size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Complaints are typically addressed within 24-48 hours.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to get icon for complaint type
  // IconData _getComplaintIcon(String type) {
  //   switch (type) {
  //     case 'Missed Collection':
  //       return Icons.timer_off;
  //     case 'Improper Waste Disposal':
  //       return Icons.warning;
  //     case 'Dustbin Overflow':
  //       return Icons.delete_sweep;
  //     case 'Vehicle Not Coming':
  //       return Icons.local_shipping;
  //     case 'Waste Not Segregated':
  //       return Icons.sort;
  //     case 'Unhygienic Area':
  //       return Icons.health_and_safety;
  //     default:
  //       return Icons.report_problem;
  //   }
  // }
}










// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'Home.dart';
//
// void main(){
//   runApp(sendcomplaint());
// }
// class sendcomplaint extends StatelessWidget {
//   const sendcomplaint({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: sendcomplaint_sub(),);
//   }
// }
// class sendcomplaint_sub extends StatefulWidget {
//   const sendcomplaint_sub({Key? key}) : super(key: key);
//
//   @override
//   State<sendcomplaint_sub> createState() => _State();
// }
//
// class _State extends State<sendcomplaint_sub> {
//   TextEditingController complaint=TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(
//
//       title: Text("send complaint"),
//       leading: IconButton(onPressed: (){
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//
//       }, icon: Icon(Icons.arrow_back)),
//     ),body: Center(child: Column(children: [TextField(controller: complaint,decoration: InputDecoration(hintText: "complaint",border: OutlineInputBorder())
//       ,),
//       ElevatedButton(onPressed: () async {
//         SharedPreferences sh=await SharedPreferences.getInstance();
//         var data=await http.post(Uri.parse("${sh.getString('ip')}/sendcomplaint"),body: {
//           'complaint':complaint.text,
//           'uid':sh.getString("uid")
//         });
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//       }, child:Text("SUBMIT"))
//     ],),),);
//   }
// }
