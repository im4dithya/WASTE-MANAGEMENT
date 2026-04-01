import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Home.dart';
void main(){
  runApp(viewworkers());
}
class viewworkers extends StatelessWidget {
  const viewworkers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: viewworkers_sub(),);
  }
}
class viewworkers_sub extends StatefulWidget {
  const viewworkers_sub({Key? key}) : super(key: key);

  @override
  State<viewworkers_sub> createState() => _viewworkers_subState();
}

class _viewworkers_subState extends State<viewworkers_sub> {
  String _searchQuery = '';

  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data =
    await http.post(Uri.parse(prefs.getString("ip").toString()+"/view_workers"),
        body: {}
    );

    var jsonData = json.decode(data.body);
    List<Joke> jokes = [];
    for (var joke in jsonData["data"]) {
      print(joke);
      Joke newJoke = Joke(
        joke["id"].toString(),
        joke["name"].toString(),
        joke["email"].toString(),
        joke["phonenumber"].toString(),
        joke["photo"].toString(),
        joke["proof"].toString(),
        joke["status"].toString(),
        joke["type"].toString(),
      );
      jokes.add(newJoke);
    }
    return jokes;
  }

  List<Joke> _filterWorkers(List<Joke> workers) {
    if (_searchQuery.isEmpty) return workers;
    return workers.where((worker) {
      return worker.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          worker.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          worker.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          worker.status.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch(status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'inactive': return Colors.red;
      case 'pending': return Colors.orange;
      case 'verified': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getWorkerIcon(String type) {
    switch(type.toLowerCase()) {
      case 'collector': return Icons.local_shipping;
      case 'recycler': return Icons.recycling;
      case 'supervisor': return Icons.supervisor_account;
      case 'manager': return Icons.manage_accounts;
      case 'driver': return Icons.drive_eta;
      default: return Icons.work;
    }
  }

  Color _getTypeColor(String type) {
    switch(type.toLowerCase()) {
      case 'collector': return Colors.blue;
      case 'recycler': return Colors.green;
      case 'supervisor': return Colors.purple;
      case 'manager': return Colors.orange;
      case 'driver': return Colors.brown;
      default: return Color(0xFF0A7A5E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Waste Management Team",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF0A7A5E),
        leading: IconButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
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
            // Search and Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search workers by name, type or status...",
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Color(0xFF0A7A5E)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Stats Header
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFF0A7A5E).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.people,
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
                                "Team Members",
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
                                    int active = snapshot.data!.where((w) => w.status.toLowerCase() == 'active').length;
                                    return Text(
                                      "${snapshot.data!.length} workers (${active} active)",
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
                ],
              ),
            ),
            // Workers List
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
                            "Loading team members...",
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
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 20),
                          Text(
                            "No team members found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Add workers to manage waste operations",
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    List<Joke> filteredWorkers = _filterWorkers(snapshot.data!);

                    if (filteredWorkers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 20),
                            Text(
                              "No matching workers",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Try a different search term",
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredWorkers.length,
                      itemBuilder: (BuildContext context, int index) {
                        var worker = filteredWorkers[index];
                        Color statusColor = _getStatusColor(worker.status);
                        Color typeColor = _getTypeColor(worker.type);

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
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
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: typeColor.withOpacity(0.1),
                              child: Icon(
                                _getWorkerIcon(worker.type),
                                color: typeColor,
                                size: 20,
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  worker.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  worker.type.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: typeColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.email, size: 10, color: Colors.grey[600]),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        worker.email,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                worker.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            children: [
                              Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Profile Info
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          // Profile Photo Placeholder
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: typeColor.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: worker.photo.isNotEmpty
                                                ? ClipOval(
                                              child: Image.network(
                                                worker.photo,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                                : Center(
                                              child: Text(
                                                worker.name.substring(0, 1).toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: typeColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  worker.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  worker.type,
                                                  style: TextStyle(
                                                    color: typeColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    // Contact Details
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blue[100]!),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.contact_mail, size: 14, color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text(
                                                "Contact Details",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.blue[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          _buildDetailRow("Email", worker.email, Icons.email),
                                          _buildDetailRow("Phone", worker.phonenumbere, Icons.phone),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    // Verification Status
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: statusColor.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            worker.status.toLowerCase() == 'active'
                                                ? Icons.verified
                                                : Icons.pending,
                                            size: 16,
                                            color: statusColor,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Status: ${worker.status.toUpperCase()}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: statusColor,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  _getStatusMessage(worker.status),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (worker.proof.isNotEmpty)
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.verified_user, size: 10, color: Colors.green),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    "Verified",
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    // Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {},
                                            icon: Icon(Icons.message, size: 16),
                                            label: Text("Message"),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Color(0xFF0A7A5E),
                                              side: BorderSide(color: Color(0xFF0A7A5E)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {},
                                            icon: Icon(Icons.call, size: 16),
                                            label: Text("Call"),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.green,
                                              side: BorderSide(color: Colors.green),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 12, color: Colors.blue[800]),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch(status.toLowerCase()) {
      case 'active': return "Worker is currently active and available";
      case 'inactive': return "Worker is currently not available";
      case 'pending': return "Worker approval is pending";
      case 'verified': return "Worker has been verified and approved";
      default: return "Status: $status";
    }
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
  final String name;
  final String email;
  final String phonenumbere;
  final String photo;
  final String proof;
  final String status;
  final String type;

  Joke(this.id, this.name, this.email, this.phonenumbere, this.photo, this.proof, this.status, this.type);
}





// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart'as http;
//
// import 'Home.dart';
// void main(){
//   runApp(viewworkers());
// }
// class viewworkers extends StatelessWidget {
//   const viewworkers({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: viewworkers_sub(),);
//   }
// }
// class viewworkers_sub extends StatefulWidget {
//   const viewworkers_sub({Key? key}) : super(key: key);
//
//   @override
//   State<viewworkers_sub> createState() => _viewworkers_subState();
// }
//
// class _viewworkers_subState extends State<viewworkers_sub> {
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // String b = prefs.getString("lid").toString();
//     // String foodimage="";
//     var data =
//     await http.post(Uri.parse(prefs.getString("ip").toString()+"/view_workers"),
//         body: {}
//     );
//
//     var jsonData = json.decode(data.body);
// //    print(jsonData);
//     List<Joke> jokes = [];
//     for (var joke in jsonData["data"]) {
//       print(joke);
//       Joke newJoke = Joke(
//         joke["id"].toString(),
//         joke["name"].toString(),
//         joke["email"].toString(),
//         joke["phonenumber"].toString(),
//         joke["photo"].toString(),
//         joke["proof"].toString(),
//         joke["status"].toString(),
//         joke["type"].toString(),
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
//         title: Text("view workers"),
//         leading: IconButton(onPressed: (){
//           Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//
//         }, icon: Icon(Icons.arrow_back)),
//       ),
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
//
//                             SizedBox(height: 10),
//                             _buildRow("id:", i.id.toString()),
//                             _buildRow("name:", i.name.toString()),
//                             _buildRow("email:", i.email.toString()),
//                             _buildRow("phonenumber:", i.phonenumber.toString()),
//                             _buildRow("photo:", i.photo.toString()),
//                             _buildRow("proof:", i.proof.toString()),
//                             _buildRow("status:", i.status.toString()),
//                             _buildRow("type:", i.type.toString()),
//
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
//   final String name;
//
//   final String email;
//   final String phonenumbere;
//   final String photo;
//   final String proof;
//   final String status;
//   final String type;
//
//
//
//
//
//   Joke(this.id,this.name, this.email, this.phonenumbere, this.photo, this.proof, this.status, this.type,);
// //  print("hiiiii");
// }
//
