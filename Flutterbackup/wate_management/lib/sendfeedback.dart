import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Home.dart';

void main() {
  runApp(sendfeedback());
}

class sendfeedback extends StatelessWidget {
  const sendfeedback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: sendfeedback_sub(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
    );
  }
}

class sendfeedback_sub extends StatefulWidget {
  const sendfeedback_sub({Key? key}) : super(key: key);

  @override
  State<sendfeedback_sub> createState() => _sendfeedback_subState();
}

class _sendfeedback_subState extends State<sendfeedback_sub> {
  TextEditingController feedback = TextEditingController();
  bool _isSubmitting = false;
  int _rating = 0;
  String? _selectedCategory;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  // Validation function
  String? _validateFeedback(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please share your feedback';
    }
    if (value.trim().length < 10) {
      return 'Feedback should be at least 10 characters';
    }
    if (value.trim().length > 1000) {
      return 'Feedback should not exceed 1000 characters';
    }
    return null;
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }



    setState(() => _isSubmitting = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      var data = await http.post(
        Uri.parse("${sh.getString('ip')}/sendfeedback"),
        body: {
          'feedback': feedback.text,
          'uid': sh.getString("uid"),
          'rating': _rating.toString(), // Added rating
        },
      );

      if (data.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your valuable feedback!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
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
          content: Text('Failed to submit feedback: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            size: 40,
            color: index < _rating ? Colors.amber : Colors.grey[400],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Share Feedback",
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
                            child: Icon(Icons.feedback,
                                color: Colors.green[700], size: 28),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'Share Your Experience',
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
                        'Your feedback helps us improve waste management services in your area.',
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

              // Feedback Details
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
                          Icon(Icons.message, color: Colors.green[700], size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Your Feedback',
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
                        controller: feedback,
                        maxLines: 8,
                        maxLength: 1000,
                        decoration: InputDecoration(
                          hintText: 'Share your thoughts, suggestions, or experience...',
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
                          suffixIcon: feedback.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => feedback.clear()),
                          )
                              : null,
                        ),
                        validator: _validateFeedback,
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
                              'Be specific about what you liked or suggestions for improvement',
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
                          '${feedback.text.length}/1000',
                          style: TextStyle(
                            color: feedback.text.length > 900
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

              SizedBox(height: 25),

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
                              'Helpful Tips for Feedback:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '• Mention specific services or staff\n• Share what worked well\n• Suggest practical improvements\n• Include date/time of experience',
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

              SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
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
                        'Submit Feedback',
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

              // Privacy Note
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip, color: Colors.green[700], size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your feedback is anonymous and will be used to improve our services.',
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

  // Helper function to get icon for category
}










// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'Home.dart';
// void main(){
//   runApp(sendfeedback());
// }
// class sendfeedback extends StatelessWidget {
//   const sendfeedback({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home:sendfeedback_sub(),);
//   }
// }
// class sendfeedback_sub extends StatefulWidget {
//   const sendfeedback_sub({Key? key}) : super(key: key);
//
//   @override
//   State<sendfeedback_sub> createState() => _sendfeedback_subState();
// }
//
// class _sendfeedback_subState extends State<sendfeedback_sub> {
//   TextEditingController feedback=TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(
//
//       title: Text("send feedback"),
//       leading: IconButton(onPressed: (){
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//
//       }, icon: Icon(Icons.arrow_back)),
//     ),body: Center(child: Column(children: [TextField(controller: feedback,decoration: InputDecoration(hintText: "feedback",border: OutlineInputBorder())
//       ,),
//     ElevatedButton(onPressed: () async {
//       SharedPreferences sh=await SharedPreferences.getInstance();
//       var data=await http.post(Uri.parse("${sh.getString('ip')}/sendfeedback"),body: {
//         'feedback':feedback.text,
//         'uid':sh.getString("uid")
//       });
//       Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//
//     }, child:Text("SUBMIT"))
//     ],),),);
//   }
// }
