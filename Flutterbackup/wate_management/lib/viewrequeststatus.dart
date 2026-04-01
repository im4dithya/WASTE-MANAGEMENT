import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Home.dart';
void main(){
  runApp(viewstatus1());
}
class viewstatus1 extends StatelessWidget {
  const viewstatus1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: viewstatus_sub(),);
  }
}
class viewstatus_sub extends StatefulWidget {
  const viewstatus_sub({Key? key}) : super(key: key);

  @override
  State<viewstatus_sub> createState() => _viewstatus_subState();
}

class _viewstatus_subState extends State<viewstatus_sub> {
  Future<List<WasteRequest>> _getWasteRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString("uid");

    var data = await http.post(
        Uri.parse(prefs.getString("ip").toString() + "/view_status"),
        body: {'uid': uid}
    );

    var jsonData = json.decode(data.body);
    List<WasteRequest> requests = [];

    for (var req in jsonData["data"]) {
      print(req);

      List<WasteItem> items = [];
      if (req['waste_items'] != null) {
        for (var item in req['waste_items']) {
          items.add(WasteItem(
            item['id'].toString(),
            item['waste_type'].toString(),
            item['base_quantity'].toString(),
            item['collected_quantity'].toString(),
            item['reward_per_unit'].toString(),
          ));
        }
      }

      WasteRequest newRequest = WasteRequest(
        req['id'].toString(),
        req['requested_date'].toString(),
        req['collection_date'].toString(),
        req['status'].toString(),
        req['total_reward'].toString(),
        req['total_collected_qty'].toString(),
        items,
      );
      requests.add(newRequest);
    }
    return requests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Waste Collection Status",
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
        centerTitle: true,
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
            // Stats Overview
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: FutureBuilder<List<WasteRequest>>(
                future: _getWasteRequests(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    int collected = snapshot.data!.where((req) => req.status.toLowerCase() == 'collected').length;
                    int pending = snapshot.data!.where((req) => req.status.toLowerCase() == 'pending').length;
                    int completed = snapshot.data!.where((req) => req.status.toLowerCase() == 'completed').length;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF0A7A5E).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.recycling,
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
                                    "Your Waste Collection",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "${snapshot.data!.length} total requests",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatCard("Collected", collected.toString(), Colors.green, Icons.check_circle),
                            _buildStatCard("Pending", pending.toString(), Colors.orange, Icons.pending),
                            _buildStatCard("Completed", completed.toString(), Colors.blue, Icons.done_all),
                          ],
                        ),
                      ],
                    );
                  }
                  return SizedBox();
                },
              ),
            ),
            SizedBox(height: 8),
            // Requests List
            Expanded(
              child: FutureBuilder<List<WasteRequest>>(
                future: _getWasteRequests(),
                builder: (BuildContext context, AsyncSnapshot<List<WasteRequest>> snapshot) {
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
                            "Loading waste requests...",
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
                            Icons.delete_outline,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 20),
                          Text(
                            "No waste requests yet",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Submit a waste collection request to get started",
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
                        var request = snapshot.data![index];
                        bool isCollected = request.status.toLowerCase() == 'collected';
                        bool isCompleted = request.status.toLowerCase() == 'completed';
                        bool isPending = request.status.toLowerCase() == 'pending';

                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getStatusColor(request.status).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getStatusIcon(request.status),
                                color: _getStatusColor(request.status),
                                size: 20,
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Request #${request.id}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Requested: ${request.requestedDate}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(request.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(request.status).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    request.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(request.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "₹${request.totalReward}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.orange[700],
                                  ),
                                ),
                                Text(
                                  "Reward",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Dates Section
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF0F7FF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Request Date",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                request.requestedDate,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 30,
                                            width: 1,
                                            color: Colors.grey[300],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Collection Date",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                request.collectionDate != 'pending' ? request.collectionDate : 'Pending',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: request.collectionDate != 'pending' ? Colors.green : Colors.orange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    // Waste Items Section
                                    Text(
                                      "♻️ Waste Items (${request.items.length})",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A7A5E),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    if (request.items.isEmpty)
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "No waste items added",
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Column(
                                        children: request.items.map((item) {
                                          double collectedQty = double.tryParse(item.collectedQuantity) ?? 0;
                                          double rewardPerUnit = double.tryParse(item.rewardPerUnit) ?? 0;
                                          double totalItemReward = collectedQty * rewardPerUnit;

                                          return Container(
                                            margin: EdgeInsets.only(bottom: 8),
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey[200]!,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.teal[50],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(
                                                    Icons.recycling,
                                                    size: 20,
                                                    color: Color(0xFF0A7A5E),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.wasteType,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          _buildItemStat("Base", "${item.baseQuantity}u", Colors.grey[600]!),
                                                          SizedBox(width: 8),
                                                          _buildItemStat("Collected", "${item.collectedQuantity}u", Colors.green),
                                                          SizedBox(width: 8),
                                                          _buildItemStat("Reward", "₹${item.rewardPerUnit}/u", Colors.orange),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "₹${totalItemReward.toStringAsFixed(2)}",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors.orange,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Total",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    SizedBox(height: 16),
                                    // Summary Section
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFF8E6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.orange[100]!,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Total Collected",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "${request.totalCollectedQty} units",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "Total Reward",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "₹${request.totalReward}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.orange[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    // Status Actions
                                    if (isPending)
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.info, size: 16, color: Colors.orange),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Your waste collection request is pending approval",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.orange[800],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (isCollected)
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle, size: 16, color: Colors.green),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Waste has been collected. Reward will be processed shortly.",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green[800],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (isCompleted)
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.verified, size: 16, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Transaction completed. Reward has been processed.",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue[800],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildItemStat(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'collected':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'collected':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'completed':
        return Icons.verified;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WasteRequest {
  final String id;
  final String requestedDate;
  final String collectionDate;
  final String status;
  final String totalReward;
  final String totalCollectedQty;
  final List<WasteItem> items;

  WasteRequest(
      this.id,
      this.requestedDate,
      this.collectionDate,
      this.status,
      this.totalReward,
      this.totalCollectedQty,
      this.items,
      );
}

class WasteItem {
  final String id;
  final String wasteType;
  final String baseQuantity;
  final String collectedQuantity;
  final String rewardPerUnit;

  WasteItem(
      this.id,
      this.wasteType,
      this.baseQuantity,
      this.collectedQuantity,
      this.rewardPerUnit,
      );
}





// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart'as http;
//
// import 'Home.dart';
// void main(){
//   runApp(viewstatus1());
// }
// class viewstatus1 extends StatelessWidget {
//   const viewstatus1({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: viewstatus_sub(),);
//   }
// }
// class viewstatus_sub extends StatefulWidget {
//   const viewstatus_sub({Key? key}) : super(key: key);
//
//   @override
//   State<viewstatus_sub> createState() => _viewstatus_subState();
// }
//
// class _viewstatus_subState extends State<viewstatus_sub> {
//   Future<List<WasteRequest>> _getWasteRequests() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? uid = prefs.getString("uid");
//
//     var data = await http.post(
//       Uri.parse(prefs.getString("ip").toString() + "/view_status"),
//       body: {'uid': uid}
//     );
//
//     var jsonData = json.decode(data.body);
//     List<WasteRequest> requests = [];
//
//     for (var req in jsonData["data"]) {
//       print(req);
//
//       List<WasteItem> items = [];
//       if (req['waste_items'] != null) {
//         for (var item in req['waste_items']) {
//           items.add(WasteItem(
//             item['id'].toString(),
//             item['waste_type'].toString(),
//             item['base_quantity'].toString(),
//             item['collected_quantity'].toString(),
//             item['reward_per_unit'].toString(),
//           ));
//         }
//       }
//
//       WasteRequest newRequest = WasteRequest(
//         req['id'].toString(),
//         req['requested_date'].toString(),
//         req['collection_date'].toString(),
//         req['status'].toString(),
//         req['total_reward'].toString(),
//         req['total_collected_qty'].toString(),
//         items,
//       );
//       requests.add(newRequest);
//     }
//     return requests;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Waste Collection Status"),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//       ),
//       body: Container(
//         child: FutureBuilder(
//           future: _getWasteRequests(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (snapshot.data == null) {
//               return Container(
//                 child: Center(
//                   child: Text("Loading..."),
//                 ),
//               );
//             } else if (snapshot.data.isEmpty) {
//               return Center(
//                 child: Text("No waste requests yet"),
//               );
//             } else {
//               return ListView.builder(
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   var request = snapshot.data![index];
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Card(
//                       elevation: 5,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         side: BorderSide(color: Colors.green.shade300),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Header with status
//                             Container(
//                               padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                               decoration: BoxDecoration(
//                                 color: Colors.green.shade50,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     "Request #${request.id}",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.green.shade800,
//                                     ),
//                                   ),
//                                   Container(
//                                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                                     decoration: BoxDecoration(
//                                       color: _getStatusColor(request.status),
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     child: Text(
//                                       request.status,
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             SizedBox(height: 12),
//
//                             // Request Information
//                             _buildRow("📅 Requested Date:", request.requestedDate),
//                             _buildRow("📦 Collection Date:", request.collectionDate != 'pending' ? request.collectionDate : 'Pending'),
//
//                             SizedBox(height: 12),
//                             Divider(thickness: 1),
//                             SizedBox(height: 12),
//
//                             // Waste Items Section
//                             Text(
//                               "♻️ Waste Items (${request.items.length})",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.teal.shade800,
//                               ),
//                             ),
//
//                             SizedBox(height: 8),
//
//                             if (request.items.isEmpty)
//                               Text(
//                                 "No items added",
//                                 style: TextStyle(color: Colors.grey, fontSize: 12),
//                               )
//                             else
//                               ...request.items.map((item) => Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 6.0),
//                                 child: Container(
//                                   padding: EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                     color: Colors.teal.shade50,
//                                     borderRadius: BorderRadius.circular(8),
//                                       border: Border(
//                                         left: BorderSide(
//                                           color: Colors.teal,
//                                           width: 3,
//                                         ),
//                                     ),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         item.wasteType,
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 13,
//                                         ),
//                                       ),
//                                       SizedBox(height: 6),
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 "Base Qty: ${item.baseQuantity} units",
//                                                 style: TextStyle(fontSize: 12),
//                                               ),
//                                               Text(
//                                                 "Collected: ${item.collectedQuantity} units",
//                                                 style: TextStyle(
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.green,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           Column(
//                                             crossAxisAlignment: CrossAxisAlignment.end,
//                                             children: [
//                                               Text(
//                                                 "Reward/Unit: ₹${item.rewardPerUnit}",
//                                                 style: TextStyle(fontSize: 11, color: Colors.orange),
//                                               ),
//                                               Text(
//                                                 "Total: ₹${(double.tryParse(item.collectedQuantity) ?? 0) * (double.tryParse(item.rewardPerUnit) ?? 0)}",
//                                                 style: TextStyle(
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.orange,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               )).toList(),
//
//                             SizedBox(height: 12),
//
//                             // Summary Section
//                             Container(
//                               padding: EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.shade50,
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(color: Colors.orange.shade300),
//                               ),
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "Total Collected Qty:",
//                                         style: TextStyle(fontWeight: FontWeight.bold),
//                                       ),
//                                       Text(
//                                         "${request.totalCollectedQty} units",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 13,
//                                           color: Colors.green,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 6),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "Total Reward Earned:",
//                                         style: TextStyle(fontWeight: FontWeight.bold),
//                                       ),
//                                       Text(
//                                         "₹${request.totalReward}",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 14,
//                                           color: Colors.orange,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'collected':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'completed':
//         return Colors.blue;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: Colors.grey.shade800,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class WasteRequest {
//   final String id;
//   final String requestedDate;
//   final String collectionDate;
//   final String status;
//   final String totalReward;
//   final String totalCollectedQty;
//   final List<WasteItem> items;
//
//   WasteRequest(
//     this.id,
//     this.requestedDate,
//     this.collectionDate,
//     this.status,
//     this.totalReward,
//     this.totalCollectedQty,
//     this.items,
//   );
// }
//
// class WasteItem {
//   final String id;
//   final String wasteType;
//   final String baseQuantity;
//   final String collectedQuantity;
//   final String rewardPerUnit;
//
//   WasteItem(
//     this.id,
//     this.wasteType,
//     this.baseQuantity,
//     this.collectedQuantity,
//     this.rewardPerUnit,
//   );
// }
//
