import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;

import 'Home.dart';
void main(){
  runApp(viewpayment());
}
class viewpayment extends StatelessWidget {
  const viewpayment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: viewpayment_sub(),);
  }
}
class viewpayment_sub extends StatefulWidget {
  const viewpayment_sub({Key? key}) : super(key: key);

  @override
  State<viewpayment_sub> createState() => _viewpayment_subState();
}

class _viewpayment_subState extends State<viewpayment_sub> {
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data =
    await http.post(Uri.parse(prefs.getString("ip").toString()+"/uview_payment"),
        body: {}
    );

    var jsonData = json.decode(data.body);
    List<Joke> jokes = [];
    for (var joke in jsonData["data"]) {
      print(joke);
      Joke newJoke = Joke(
        joke["id"].toString(),
        joke["username"].toString(),
        joke["date"].toString(),
        joke["status"].toString(),
        joke["recyclername"].toString(),
        joke["payementmode"].toString(),
        joke["amount"].toString(),
      );
      jokes.add(newJoke);
    }
    return jokes;
  }

  Color _getStatusColor(String status) {
    switch(status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payment History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
          },
          icon: Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        backgroundColor: Colors.teal[700],
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
              Colors.teal[50]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: Colors.teal[700],
              child: Row(
                children: [
                  Icon(Icons.payments, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Waste Management Payments",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FutureBuilder(
                      future: _getJokes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            "${snapshot.data!.length} Records",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Stats Overview
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard("Total", Icons.list_alt, Colors.blue),
                  _buildStatCard("Completed", Icons.check_circle, Colors.green),
                  _buildStatCard("Pending", Icons.pending, Colors.orange),
                ],
              ),
            ),

            // Payments List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder(
                  future: _getJokes(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[700]!),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Loading payment data...",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 20),
                            Text(
                              "No payment records found",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Your payment history will appear here",
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          var payment = snapshot.data![index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
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
                            child: ExpansionTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.teal[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getPaymentModeIcon(payment.paymentmode),
                                  color: Colors.teal[700],
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Payment #${payment.id}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(payment.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getStatusColor(payment.status).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      payment.status.toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(payment.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    "Date: ${payment.date}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Recycler: ${payment.recyclername}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "\$${payment.amount}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.teal[800],
                                    ),
                                  ),
                                  Text(
                                    "Amount",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      _buildDetailRow("Transaction ID", payment.id),
                                      _buildDetailRow("User", payment.username),
                                      _buildDetailRow("Recycler", payment.recyclername),
                                      _buildDetailRow("Payment Mode", payment.paymentmode),
                                      _buildDetailRow("Date", payment.date),
                                      _buildDetailRow("Status", payment.status,
                                          valueColor: _getStatusColor(payment.status)),
                                      _buildDetailRow("Amount", "\$${payment.amount}",
                                          valueStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.teal[800],
                                          )),
                                      SizedBox(height: 10),
                                      if (payment.status.toLowerCase() == "completed")
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(8),
                                            // border: Border.all(color: Colors.green[100]),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.verified, color: Colors.green, size: 16),
                                              SizedBox(width: 8),
                                              Text(
                                                "Payment Successfully Completed",
                                                style: TextStyle(
                                                  color: Colors.green[800],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? TextStyle(
                color: valueColor ?? Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentModeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'online':
        return Icons.online_prediction;
      case 'upi':
        return Icons.mobile_friendly;
      default:
        return Icons.payment;
    }
  }
}

class Joke {
  final String id;
  final String username;
  final String date;
  final String status;
  final String recyclername;
  final String paymentmode;
  final String amount;

  Joke(this.id, this.username, this.date, this.status, this.recyclername, this.paymentmode, this.amount);
}



// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart'as http;
//
// import 'Home.dart';
// void main(){
//   runApp(viewpayment());
// }
// class viewpayment extends StatelessWidget {
//   const viewpayment({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: viewpayment_sub(),);
//   }
// }
// class viewpayment_sub extends StatefulWidget {
//   const viewpayment_sub({Key? key}) : super(key: key);
//
//   @override
//   State<viewpayment_sub> createState() => _viewpayment_subState();
// }
//
// class _viewpayment_subState extends State<viewpayment_sub> {
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // String b = prefs.getString("lid").toString();
//     // String foodimage="";
//     var data =
//     await http.post(Uri.parse(prefs.getString("ip").toString()+"/uview_payment"),
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
//         joke["username"].toString(),
//         joke["date"].toString(),
//         joke["status"].toString(),
//         joke["recyclername"].toString(),
//         joke["payementmode"].toString(),
//         joke["amount"].toString(),
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
//         title: Text("view payment"),
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
//                             _buildRow("username:", i.username.toString()),
//                             _buildRow("date:", i.date.toString()),
//                             _buildRow("status:", i.status.toString()),
//                             _buildRow("recyclername:", i.recyclername.toString()),
//                             _buildRow("paymentmode:", i.payementmode.toString()),
//                             _buildRow("amount:", i.amount.toString()),
//
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
//   final String username;
//
//   final String date;
//   final String status;
//   final String recyclername;
//   final String paymentmode;
//   final String amount;
//
//
//
//
//
//   Joke(this.id,this.username, this.date,this.status,this.recyclername,this.paymentmode,this.amount);
// //  print("hiiiii");
// }
//
