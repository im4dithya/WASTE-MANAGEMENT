import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wate_management/send%20complaint.dart';

import 'Home.dart';

void main() {
  runApp(viewreply());
}

class viewreply extends StatelessWidget {
  const viewreply({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: viewreply_sub());
  }
}

class viewreply_sub extends StatefulWidget {
  const viewreply_sub({Key? key}) : super(key: key);

  @override
  State<viewreply_sub> createState() => _viewreply_subState();
}

class _viewreply_subState extends State<viewreply_sub> {
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = await http.post(
      Uri.parse(prefs.getString("ip").toString() + "/view_reply"),
      body: {'uid': prefs.getString("uid")},
    );

    var jsonData = json.decode(data.body);
    List<Joke> jokes = [];
    for (var joke in jsonData["data"]) {
      print(joke);
      Joke newJoke = Joke(
        joke["id"].toString(),
        joke["complaint"],
        joke["complaintdate"].toString(),
        joke["reply"],
        joke["reply_date"].toString(),
        joke["username"].toString(),
      );
      jokes.add(newJoke);
    }
    return jokes;
  }

  Color _getStatusColor(String reply) {
    if (reply.isEmpty || reply.toLowerCase() == "pending") {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Complaint Replies",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF0A7A5E), // Eco-friendly green
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0A7A5E),
        child: Icon(Icons.add_comment, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => sendcomplaint()));
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A7A5E).withOpacity(0.05),
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF0A7A5E).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.feedback,
                      color: Color(0xFF0A7A5E),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Complaint History",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        FutureBuilder<List<Joke>>(
                          future: _getJokes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              int replied = snapshot.data!
                                  .where((complaint) =>
                              complaint.reply.isNotEmpty && complaint.reply.toLowerCase() != "pending")
                                  .length;
                              return Text(
                                "$replied of ${snapshot.data!.length} complaints replied",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              );
                            }
                            return SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            // Complaint List
            Expanded(
              child: FutureBuilder<List<Joke>>(
                future: _getJokes(),
                builder: (BuildContext context, AsyncSnapshot<List<Joke>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF0A7A5E),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Loading complaints...",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 20),
                          Text(
                            "No complaints yet",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Click the + button to submit a complaint",
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        var complaint = snapshot.data![index];
                        bool hasReply =
                            complaint.reply.isNotEmpty && complaint.reply.toLowerCase() != "pending";

                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getStatusColor(complaint.reply).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                hasReply ? Icons.check_circle : Icons.pending,
                                color: _getStatusColor(complaint.reply),
                              ),
                            ),
                            title: Text(
                              complaint.complaint.length > 30
                                  ? "${complaint.complaint.substring(0, 30)}..."
                                  : complaint.complaint,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  complaint.username,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  "Submitted: ${complaint.complaintdate}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(complaint.reply).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(complaint.reply).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                hasReply ? "RESOLVED" : "PENDING",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(complaint.reply),
                                ),
                              ),
                            ),
                            children: [
                              Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Complaint Details
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF0F7FF),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blue.shade100),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.report_problem, size: 16, color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text(
                                                "COMPLAINT DETAILS",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade800,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            complaint.complaint,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.person, size: 12, color: Colors.grey[600]),
                                              SizedBox(width: 4),
                                              Text(
                                                complaint.username,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Spacer(),
                                              Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                                              SizedBox(width: 4),
                                              Text(
                                                complaint.complaintdate,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    // Admin Reply
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: hasReply ? Color(0xFFF0FFF4) : Color(0xFFFFF8E1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: hasReply ? Colors.green.shade100 : Colors.orange.shade100,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                hasReply ? Icons.verified_user : Icons.schedule,
                                                size: 16,
                                                color: hasReply ? Colors.green : Colors.orange,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                hasReply ? "ADMIN REPLY" : "STATUS",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: hasReply ? Colors.green.shade800 : Colors.orange.shade800,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          if (hasReply)
                                            Text(
                                              complaint.reply,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[800],
                                              ),
                                            )
                                          else
                                            Text(
                                              "Your complaint is pending review",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[800],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          SizedBox(height: 8),
                                          if (hasReply)
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Replied on: ${complaint.reply_date}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    // Action Buttons
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Joke {
  final String id;
  final String complaint;
  final String complaintdate;
  final String reply;
  final String reply_date;
  final String username;

  Joke(this.id, this.complaint, this.complaintdate, this.reply, this.reply_date, this.username);
}





// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart'as http;
// import 'package:wate_management/send%20complaint.dart';
//
// import 'Home.dart';
// void main(){
//   runApp(viewreply());
// }
// class viewreply extends StatelessWidget {
//   const viewreply({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home:viewreply_sub() ,);
//   }
// }
// class viewreply_sub extends StatefulWidget {
//   const viewreply_sub({Key? key}) : super(key: key);
//
//   @override
//   State<viewreply_sub> createState() => _viewreply_subState();
// }
//
// class _viewreply_subState extends State<viewreply_sub> {
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var data =
//     await http.post(Uri.parse(prefs.getString("ip").toString()+"/view_reply"),
//         body: {'uid':prefs.getString("uid")}
//     );
//
//     var jsonData = json.decode(data.body);
//     List<Joke> jokes = [];
//     for (var joke in jsonData["data"]) {
//       print(joke);
//       Joke newJoke = Joke(
//           joke["id"].toString(),
//           joke["complaint"],
//           joke["complaintdate"].toString(),
//           joke["reply"],
//           joke["reply_date"].toString(),
//           joke["username"].toString(),
//       );
//       jokes.add(newJoke);
//     }
//     return jokes;
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//
//         title: Text("view reply"),
//         leading: IconButton(onPressed: (){
//           Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//
//         }, icon: Icon(Icons.arrow_back)),
//       ),
//       floatingActionButton: FloatingActionButton(child: Icon(Icons.add),onPressed: (){
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>sendcomplaint()));
//       }),
//       body:
//
//
//       Container(
//
//         child:
//         FutureBuilder(
//           future: _getJokes(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
// //              print("snapshot"+snapshot.toString());
//             if (snapshot.data == null) {
//               return Container(
//                 child: Center(
//                   child: Text("Loading..."),
//                 ),
//               );
//             } else {
//               return ListView.builder(
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   var i = snapshot.data![index];
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         side: BorderSide(color: Colors.grey.shade300),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Complaint Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
//                             SizedBox(height: 8),
//                             _buildRow("Username:", i.username.toString()),
//                             _buildRow("Date:", i.complaintdate.toString()),
//                             _buildRow("Complaint:", i.complaint.toString()),
//                             SizedBox(height: 12),
//                             Divider(thickness: 1, color: Colors.grey.shade400),
//                             SizedBox(height: 8),
//                             Text('Admin Reply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
//                             SizedBox(height: 8),
//                             _buildRow("Reply:", i.reply.toString()),
//                             _buildRow("Reply Date:", i.reply_date.toString()),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//
//
//             }
//           },
//
//
//         ),
//
//
//
//
//
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   child: Icon(Icons.add),
//       //   onPressed: () {
//       //     Navigator.push(context, MaterialPageRoute(
//       //         builder: (context)=>user_send_complaint(
//       //         )));
//       //   },
//       //
//       // ),
//     );
//   }
//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           SizedBox(width: 5),
//           Flexible(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: Colors.grey.shade800,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
// class Joke {
//   final String id;
//   final String complaint;
//   final String complaintdate;
//   final String reply;
//   final String reply_date;
//   final String username;
//
//   Joke(this.id, this.complaint, this.complaintdate, this.reply, this.reply_date, this.username);
// }
